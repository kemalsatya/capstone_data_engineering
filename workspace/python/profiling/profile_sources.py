#!/usr/bin/env python3
"""
Data Profiler for Capstone Data Engineering
Analyzes all datasets under workspace/data/Sumber Data/
Output: JSON profiling summary and Markdown report
"""

import os
import sys
import csv
import json
import zipfile
import datetime
import xml.etree.ElementTree as ET
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[2] / "data" / "Sumber Data"
REPORT_DIR = Path(__file__).resolve().parent

def detect_delimiter_and_encoding(filepath):
    encodings = ['utf-8', 'utf-8-sig', 'iso-8859-1', 'windows-1252']
    delimiters = [',', ';', '\t', '|']
    
    for enc in encodings:
        try:
            with open(filepath, 'r', encoding=enc) as f:
                sample = f.read(8192)
            if not sample:
                return ',', enc
            
            # Count delimiter frequencies in the first non-empty lines
            lines = [l for l in sample.splitlines() if l.strip()]
            if not lines:
                return ',', enc
            
            first_line = lines[0]
            delim_scores = {d: first_line.count(d) for d in delimiters}
            best_delim = max(delim_scores, key=delim_scores.get)
            if delim_scores[best_delim] == 0:
                best_delim = ','
            return best_delim, enc
        except (UnicodeDecodeError, UnicodeError):
            continue
    return ',', 'iso-8859-1'

def profile_csv(filepath, max_sample_rows=1000):
    delim, enc = detect_delimiter_and_encoding(filepath)
    file_size_bytes = os.path.getsize(filepath)
    
    columns = []
    sample_rows = []
    total_rows = 0
    null_counts = {}
    
    with open(filepath, 'r', encoding=enc, errors='replace') as f:
        reader = csv.reader(f, delimiter=delim)
        try:
            header = next(reader)
        except StopIteration:
            header = []
            
        columns = [c.strip() for c in header]
        null_counts = {c: 0 for c in columns}
        
        for i, row in enumerate(reader):
            total_rows += 1
            if i < 3:
                sample_rows.append(row)
            if i < max_sample_rows:
                for col_idx, col_name in enumerate(columns):
                    val = row[col_idx].strip() if col_idx < len(row) else ''
                    if val == '' or val.lower() in ('null', 'nan', 'none', '-', 'na', 'n/a'):
                        null_counts[col_name] += 1
                        
    # Calculate null percentage based on sampled rows
    sampled = min(total_rows, max_sample_rows)
    null_pct = {k: round((v / sampled * 100), 1) if sampled > 0 else 0 for k, v in null_counts.items()}
    
    return {
        "file_name": filepath.name,
        "format": "CSV",
        "size_mb": round(file_size_bytes / (1024 * 1024), 2),
        "delimiter": delim,
        "encoding": enc,
        "total_rows": total_rows,
        "column_count": len(columns),
        "columns": columns,
        "sample_rows": sample_rows,
        "null_percentage_sample": null_pct
    }

def profile_xlsx(filepath):
    file_size_bytes = os.path.getsize(filepath)
    zf = zipfile.ZipFile(filepath)
    
    # Read shared strings if present
    sst = []
    if 'xl/sharedStrings.xml' in zf.namelist():
        sst_xml = zf.read('xl/sharedStrings.xml')
        sst = [t.text for t in ET.fromstring(sst_xml).iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t')]
    
    # Read sheet1
    sheet_xml = zf.read('xl/worksheets/sheet1.xml')
    sheet = ET.fromstring(sheet_xml)
    rows_elem = sheet.findall('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}sheetData/{http://schemas.openxmlformats.org/spreadsheetml/2006/main}row')
    
    rows = []
    for r in rows_elem[:1005]:
        cells = []
        for c in r.findall('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}c'):
            t = c.attrib.get('t')
            v = c.find('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}v')
            val = v.text if v is not None else None
            if t == 's' and val is not None and int(val) < len(sst):
                val = sst[int(val)]
            cells.append(val if val is not None else '')
        rows.append(cells)
        
    header = rows[0] if rows else []
    sample_rows = rows[1:4] if len(rows) > 1 else []
    total_rows = len(rows_elem) - 1
    
    return {
        "file_name": filepath.name,
        "format": "Excel XLSX",
        "size_mb": round(file_size_bytes / (1024 * 1024), 2),
        "total_rows": total_rows,
        "column_count": len(header),
        "columns": header,
        "sample_rows": sample_rows
    }

def profile_geojson(filepath):
    file_size_bytes = os.path.getsize(filepath)
    size_mb = round(file_size_bytes / (1024 * 1024), 2)
    
    # For large GeoJSON, read head to inspect properties without loading entire file
    props_sample = {}
    geom_type = "Unknown"
    
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        head_chunk = f.read(65536)
        
    try:
        # Try finding the first feature
        f_idx = head_chunk.find('"features"')
        if f_idx != -1:
            prop_idx = head_chunk.find('"properties"', f_idx)
            if prop_idx != -1:
                end_prop = head_chunk.find('}', prop_idx)
                # extract properties slice
                slice_prop = head_chunk[prop_idx + 13: end_prop + 1]
                props_sample = json.loads('{' + slice_prop.strip() + '}')
        g_idx = head_chunk.find('"geometry"')
        if g_idx != -1:
            type_idx = head_chunk.find('"type"', g_idx)
            if type_idx != -1:
                geom_type = head_chunk[type_idx:type_idx+40].split('"')[3]
    except Exception as e:
        props_sample = {"note": f"Partial parse: {str(e)}"}
        
    return {
        "file_name": filepath.name,
        "format": "GeoJSON",
        "size_mb": size_mb,
        "geometry_type": geom_type,
        "sample_properties": list(props_sample.keys()) if isinstance(props_sample, dict) else []
    }

def main():
    print(f"Profiling datasets in: {BASE_DIR}")
    results = {}
    
    src_dirs = sorted([d for d in BASE_DIR.iterdir() if d.is_dir() and d.name.startswith("SRC-")])
    
    for sdir in src_dirs:
        src_name = sdir.name
        print(f"--> Profiling {src_name}...")
        results[src_name] = []
        
        for f in sorted(sdir.iterdir()):
            if f.is_file():
                ext = f.suffix.lower()
                if ext == '.csv':
                    info = profile_csv(f)
                    results[src_name].append(info)
                elif ext == '.xlsx':
                    info = profile_xlsx(f)
                    results[src_name].append(info)
                elif ext == '.geojson':
                    info = profile_geojson(f)
                    results[src_name].append(info)
                elif ext == '.zip':
                    results[src_name].append({
                        "file_name": f.name,
                        "format": "ZIP Archive",
                        "size_mb": round(os.path.getsize(f) / (1024 * 1024), 2)
                    })
                    
    # Save JSON summary
    json_path = REPORT_DIR / "profiling_summary.json"
    with open(json_path, 'w', encoding='utf-8') as out_f:
        json.dump(results, out_f, indent=2, default=str)
    print(f"JSON profiling summary written to {json_path}")

    # Generate Markdown report
    md_path = REPORT_DIR / "profiling_report.md"
    with open(md_path, 'w', encoding='utf-8') as md:
        md.write("# Ringkasan Data Profiling 12 Sumber Data (`SRC-01` s/d `SRC-12`)\n\n")
        md.write(f"*Dihasilkan secara otomatis pada: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n")
        
        for src, files in results.items():
            md.write(f"## {src}\n\n")
            for item in files:
                md.write(f"### Berkas: `{item['file_name']}`\n")
                md.write(f"- **Format**: {item.get('format')}\n")
                md.write(f"- **Ukuran**: {item.get('size_mb')} MB\n")
                
                if item.get('format') == 'CSV':
                    md.write(f"- **Total Baris**: {item.get('total_rows'):,}\n")
                    md.write(f"- **Delimiter**: `{repr(item.get('delimiter'))}`\n")
                    md.write(f"- **Encoding**: {item.get('encoding')}\n")
                    md.write(f"- **Jumlah Kolom**: {item.get('column_count')}\n")
                    md.write(f"- **Daftar Kolom**: `{', '.join(item.get('columns', []))}`\n\n")
                    if item.get('sample_rows'):
                        md.write("**Contoh Data (Baris 1)**:\n")
                        md.write("```json\n" + json.dumps(dict(zip(item.get('columns', []), item['sample_rows'][0])), indent=2, ensure_ascii=False) + "\n```\n\n")
                        
                elif item.get('format') == 'Excel XLSX':
                    md.write(f"- **Total Baris**: {item.get('total_rows'):,}\n")
                    md.write(f"- **Jumlah Kolom**: {item.get('column_count')}\n")
                    md.write(f"- **Daftar Kolom**: `{', '.join(item.get('columns', []))}`\n\n")
                    if item.get('sample_rows'):
                        md.write("**Contoh Data (Baris 1)**:\n")
                        md.write("```json\n" + json.dumps(dict(zip(item.get('columns', []), item['sample_rows'][0])), indent=2, ensure_ascii=False) + "\n```\n\n")

                elif item.get('format') == 'GeoJSON':
                    md.write(f"- **Tipe Geometri**: {item.get('geometry_type')}\n")
                    md.write(f"- **Contoh Kolom Properti**: `{', '.join(item.get('sample_properties', []))}`\n\n")
                    
                md.write("---\n\n")
                
    print(f"Markdown profiling report written to {md_path}")

if __name__ == "__main__":
    main()
