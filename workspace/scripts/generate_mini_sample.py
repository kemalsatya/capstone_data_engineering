#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_mini_sample.py
Komponen 2 & 10: Menghasilkan paket mini-sample tersanitasi (< 2 MB) dari 15 tabel raw.*
ke workspace/sample-data/ agar reviewer dapat menguji ulang dari lingkungan bersih
tanpa mengunduh 1,8 GB data mentah.
"""
import csv
import os
from pathlib import Path
import psycopg2

WORKSPACE_DIR = Path(__file__).resolve().parent.parent
SAMPLE_DIR = WORKSPACE_DIR / "sample-data"
RAW_SAMPLE_DIR = SAMPLE_DIR / "raw_csv"

RAW_TABLES = [
    ("src_01_bmkg_gempa", 100),
    ("src_02_bnpb_bencana", 100),
    ("src_03_iklim_harian", 100),
    ("src_03_iklim_provinsi", 34),
    ("src_03_iklim_stasiun", 50),
    ("src_04_fitur_kabkota", 50),
    ("src_05_opencellid", 100),
    ("src_06_ookla_tiles", 100),
    ("src_07_gppd", 50),
    ("src_08_osm_gardu", 100),
    ("src_09_pop_isp", 34),
    ("src_10_iklh_provinsi", 50),
    ("src_11_adm1", 10),
    ("src_11_adm2", 25),
    ("src_12_penduduk_provinsi", 50),
]


def get_db_conn():
    return psycopg2.connect(
        host=os.environ.get("LAB_DB_HOST", "postgres"),
        port=int(os.environ.get("LAB_DB_PORT", "5432")),
        dbname=os.environ.get("LAB_DB_NAME", "labdata"),
        user=os.environ.get("LAB_DB_USER", "labuser"),
        password=os.environ.get("LAB_DB_PASSWORD", ""),
    )


def simplify_geojson_if_large(cur, val):
    if not isinstance(val, str) or len(val) <= 2000:
        return val
    stripped = val.strip()
    if stripped.startswith("{") and '"type"' in stripped[:80]:
        try:
            cur.execute(
                "SELECT ST_AsGeoJSON(ST_Envelope(ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326)), 4)",
                (stripped,),
            )
            res = cur.fetchone()
            if res and res[0]:
                return res[0]
        except Exception:
            cur.connection.rollback()
            return val[:2000]
    return val[:2000]


def main():
    RAW_SAMPLE_DIR.mkdir(parents=True, exist_ok=True)
    conn = get_db_conn()
    manifest_rows = []
    total_bytes = 0

    try:
        with conn.cursor() as cur, conn.cursor() as aux_cur:
            for tbl, lim in RAW_TABLES:
                cur.execute(f'SELECT * FROM raw."{tbl}" LIMIT %s', (lim,))
                headers = [d[0] for d in cur.description]
                rows = cur.fetchall()

                out_path = RAW_SAMPLE_DIR / f"sample_{tbl}.csv"
                with out_path.open("w", newline="", encoding="utf-8-sig") as f:
                    w = csv.writer(f)
                    w.writerow(headers)
                    for r in rows:
                        clean_r = []
                        for col_name, val in zip(headers, r):
                            if col_name == "_src_file":
                                clean_r.append(f"SAMPLE_{tbl}.csv")
                            elif isinstance(val, str) and len(val) > 2000:
                                clean_r.append(simplify_geojson_if_large(aux_cur, val))
                            else:
                                clean_r.append(val)
                        w.writerow(clean_r)

                sz = out_path.stat().st_size
                total_bytes += sz
                manifest_rows.append((tbl, out_path.name, len(rows), round(sz / 1024, 2)))
                print(f"[SAMPLE] {out_path.name} ({len(rows)} baris, {sz/1024:.1f} KB)")
    finally:
        conn.close()

    readme_lines = [
        "# Paket Mini-Sample Tersanitasi (DE Capstone)",
        "",
        "Folder ini menyediakan cuplikan data tersanitasi dari seluruh **15 tabel `raw.*`** (12 sumber data `SRC-01` s.d. `SRC-12`) berukuran ringan untuk keperluan inspeksi struktur skema dan uji reproduksibilitas reviewer tanpa harus mengunduh 1,8 GB dataset mentah.",
        "",
        "## Catatan Sanitasi & Lisensi",
        "- Kolom `_src_file` disanitasi menjadi `SAMPLE_<table>.csv` (tidak mengandung path direktori lokal).",
        "- Geometri poligon resolusi tinggi pada `src_11_adm1` dan `src_11_adm2` disederhanakan menggunakan `ST_Envelope` PostGIS agar ukuran berkas ringan namun tetap berformat GeoJSON valid.",
        "- Tidak mengandung kredensial, data LABFIK non-sintetis, atau PII pribadi.",
        "- Sampel `SRC-06` (Ookla) tetap tunduk pada lisensi **CC BY-NC-SA 4.0 (Non-Commercial)**.",
        "",
        "## Daftar Berkas Sampel",
        "",
        "| Tabel Raw | Nama Berkas | Jumlah Baris | Ukuran (KB) |",
        "| :--- | :--- | ---: | ---: |",
    ]
    for tbl, fname, rcnt, kb in manifest_rows:
        readme_lines.append(f"| `raw.{tbl}` | `raw_csv/{fname}` | {rcnt} | {kb:.2f} |")
    readme_lines.append(f"\n**Total ukuran paket sampel:** `{total_bytes/1024:.2f} KB` (`{total_bytes/(1024*1024):.3f} MB`).")

    (SAMPLE_DIR / "README_SAMPLE.md").write_text("\n".join(readme_lines) + "\n", encoding="utf-8")
    print(f"[DONE] Total paket sampel: {total_bytes/1024:.2f} KB ({len(manifest_rows)} CSV + README_SAMPLE.md)")


if __name__ == "__main__":
    main()