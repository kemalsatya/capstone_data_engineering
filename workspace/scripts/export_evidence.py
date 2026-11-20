#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
export_evidence.py - Ekspor seluruh bukti empiris DE Capstone dari PostgreSQL
ke multi-sheet Excel (.xlsx), 13 file CSV, dan ringkasan Markdown (EVIDENCE_SUMMARY.md).
"""
import csv
import datetime
import decimal
import os
import zipfile
from pathlib import Path
from xml.sax.saxutils import escape

import psycopg2

BASE_DIR = Path(__file__).resolve().parent.parent / "evidence"
CSV_DIR = BASE_DIR / "csv"
XLSX_PATH = BASE_DIR / "DE_Capstone_Evidence_Workbook.xlsx"
MD_PATH = BASE_DIR / "EVIDENCE_SUMMARY.md"


def get_db_conn():
    return psycopg2.connect(
        host=os.environ.get("LAB_DB_HOST", "postgres"),
        port=int(os.environ.get("LAB_DB_PORT", "5432")),
        dbname=os.environ.get("LAB_DB_NAME", "labdata"),
        user=os.environ.get("LAB_DB_USER", "labuser"),
        password=os.environ.get("LAB_DB_PASSWORD", ""),
    )


QUERIES = [
    (
        "01_Executive_KPI",
        """
        SELECT 'Total Kab/Kota Dinilai' AS metric, COUNT(*)::text AS value, 'mart.fact_site_suitability' AS source_ref FROM mart.fact_site_suitability
        UNION ALL
        SELECT 'Total Provinsi Kanonik', COUNT(*)::text, 'mart.dim_provinsi' FROM mart.dim_provinsi
        UNION ALL
        SELECT 'Koridor Pulau/Region', COUNT(DISTINCT region_pulau)::text, 'semantic.v_dc_site_ranking' FROM semantic.v_dc_site_ranking
        UNION ALL
        SELECT 'Wilayah Eligible (Bebas Knock-Out)', COUNT(*) FILTER (WHERE NOT is_knockout)::text, 'mart.fact_site_suitability' FROM mart.fact_site_suitability
        UNION ALL
        SELECT 'Wilayah Disqualified (Knock-Out)', COUNT(*) FILTER (WHERE is_knockout)::text, 'mart.fact_site_suitability' FROM mart.fact_site_suitability
        UNION ALL
        SELECT '  - Pemicu Knock-Out Seismik (M>=6.5, <=30km, r<=25km)', COUNT(*) FILTER (WHERE ko_seismic_flag)::text, 'mart.fact_site_suitability' FROM mart.fact_site_suitability
        UNION ALL
        SELECT '  - Pemicu Knock-Out Banjir (>50 kejadian)', COUNT(*) FILTER (WHERE ko_flood_flag)::text, 'mart.fact_site_suitability' FROM mart.fact_site_suitability
        UNION ALL
        SELECT 'Tier 1 - Prime (Skor >= 65)', COUNT(*) FILTER (WHERE suitability_tier = 'Tier 1 - Prime')::text, 'mart.fact_site_suitability' FROM mart.fact_site_suitability
        UNION ALL
        SELECT 'Tier 2 - Recommended (55 - 64.99)', COUNT(*) FILTER (WHERE suitability_tier = 'Tier 2 - Recommended')::text, 'mart.fact_site_suitability' FROM mart.fact_site_suitability
        UNION ALL
        SELECT 'Tier 3 - Moderate (45 - 54.99)', COUNT(*) FILTER (WHERE suitability_tier = 'Tier 3 - Moderate')::text, 'mart.fact_site_suitability' FROM mart.fact_site_suitability
        UNION ALL
        SELECT 'Tier 4 - Low Suitability (< 45)', COUNT(*) FILTER (WHERE suitability_tier = 'Tier 4 - Low Suitability')::text, 'mart.fact_site_suitability' FROM mart.fact_site_suitability
        UNION ALL
        SELECT 'Rata-rata Skor Komposit (Eligible)', ROUND(AVG(composite_score) FILTER (WHERE NOT is_knockout), 2)::text, 'mart.fact_site_suitability' FROM mart.fact_site_suitability
        UNION ALL
        SELECT 'Skor Tertinggi Nasional (Eligible)', MAX(composite_score) FILTER (WHERE NOT is_knockout)::text, 'mart.fact_site_suitability' FROM mart.fact_site_suitability
        UNION ALL
        SELECT 'Total Sumber Data Terintegrasi', COUNT(*)::text, 'semantic.v_dc_dq_governance' FROM semantic.v_dc_dq_governance
        UNION ALL
        SELECT 'Total Berkas Manifest Terdaftar', SUM(file_count)::text, 'semantic.v_dc_dq_governance' FROM semantic.v_dc_dq_governance
        UNION ALL
        SELECT 'Total Baris Karantina Kritis (CRITICAL)', COALESCE(SUM(quarantined_rows), 0)::text, 'dq.quarantine_records' FROM semantic.v_dc_dq_governance
        UNION ALL
        SELECT 'Total Temuan Peringatan DQ (WARNING)', COALESCE(SUM(warning_issues), 0)::text, 'dq.capstone_quality_issues' FROM semantic.v_dc_dq_governance
        UNION ALL
        SELECT 'Durasi E2E Master Workflow (SLA)', '09m 07s (547.41 detik)', 'wf_capstone_e2e_master.hwf (Tahap 6B)'
        UNION ALL
        SELECT 'Idempotency Lintas 7 Skema (83 Tabel)', '100% PASS (0 baris berubah/ganda)', 'snapshot_before vs snapshot_after'
        UNION ALL
        SELECT 'Performa SLO Query BI Top 15 / Hazard Trends', '0.103 ms / 2.741 ms (Target < 500 ms)', 'uat_verification_output.txt';
        """,
    ),
    (
        "02_Sources_Manifest",
        "SELECT * FROM ops.source_file_manifest ORDER BY source_id, 2;",
    ),
    (
        "03_DQ_Governance",
        "SELECT * FROM semantic.v_dc_dq_governance ORDER BY source_id;",
    ),
    (
        "04_DQ_Rules_Summary",
        """
        SELECT
          source_table,
          rule_id,
          severity,
          reason,
          COUNT(*) AS issue_count
        FROM dq.capstone_quality_issues
        GROUP BY 1, 2, 3, 4
        ORDER BY 1, 2;
        """,
    ),
    (
        "05_Row_Reconciliation",
        """
        SELECT
          table_schema,
          table_name,
          (xpath('/row/cnt/text()', query_to_xml(
            format('SELECT count(*) AS cnt FROM %I.%I', table_schema, table_name),
            false, true, ''
          )))[1]::text::int AS row_count
        FROM information_schema.tables
        WHERE table_schema IN ('raw', 'stg', 'dq', 'mdm', 'vault', 'bv', 'mart')
          AND table_type = 'BASE TABLE'
        ORDER BY
          CASE table_schema
            WHEN 'raw' THEN 1 WHEN 'stg' THEN 2 WHEN 'dq' THEN 3
            WHEN 'mdm' THEN 4 WHEN 'vault' THEN 5 WHEN 'bv' THEN 6 WHEN 'mart' THEN 7
          END,
          table_name;
        """,
    ),
    (
        "06_Scoring_Parameters",
        "SELECT param_group, param_key, param_value, unit, description, loaded_at FROM semantic.v_dc_scoring_parameters;",
    ),
    (
        "07_UAT_Results",
        """
        WITH weights AS (
          SELECT
            SUM(param_value) FILTER (WHERE param_group = 'WEIGHT') AS sum_w,
            MAX(param_value) FILTER (WHERE param_key = 'weight_power')       AS wp,
            MAX(param_value) FILTER (WHERE param_key = 'weight_safety')      AS ws,
            MAX(param_value) FILTER (WHERE param_key = 'weight_network')     AS wn,
            MAX(param_value) FILTER (WHERE param_key = 'weight_environment') AS we
          FROM mart.dim_parameter_scoring
        ),
        checks AS (
          SELECT 'UAT-01' AS test_id, 'Cakupan 514 Kab/Kota & 38 Provinsi di Star Schema' AS deskripsi,
                 (SELECT COUNT(*) FROM mart.fact_site_suitability) = 514
             AND (SELECT COUNT(*) FROM mart.dim_provinsi) = 38 AS is_pass,
                 (SELECT COUNT(*) FROM mart.fact_site_suitability)::text || ' kab/kota, ' ||
                 (SELECT COUNT(*) FROM mart.dim_provinsi)::text || ' provinsi' AS bukti_aktual
          UNION ALL
          SELECT 'UAT-02', '0 NULL pada Skor Komposit, 4 Pilar, Region Pulau, & PoP ISP',
                 (SELECT COUNT(*) FROM semantic.v_dc_site_ranking
                  WHERE composite_score IS NULL OR power_score IS NULL OR safety_score IS NULL
                     OR network_score IS NULL OR environment_score IS NULL
                     OR region_pulau = 'Lainnya' OR prov_pop_isp_count IS NULL) = 0,
                 'Baris bermasalah: ' || (SELECT COUNT(*) FROM semantic.v_dc_site_ranking
                  WHERE composite_score IS NULL OR power_score IS NULL OR safety_score IS NULL
                     OR network_score IS NULL OR environment_score IS NULL
                     OR region_pulau = 'Lainnya' OR prov_pop_isp_count IS NULL)::text
          UNION ALL
          SELECT 'UAT-03', 'Total Bobot 4 Pilar = 1.00 & Akurasi Formula Composite Score (tol <= 0.03)',
                 (SELECT sum_w FROM weights) = 1.00
             AND (SELECT COUNT(*) FROM mart.fact_site_suitability f CROSS JOIN weights w
                  WHERE ABS(f.composite_score - ROUND(
                    f.power_score*w.wp + f.safety_score*w.ws + f.network_score*w.wn + f.environment_score*w.we, 2
                  )) > 0.03) = 0,
                 'Sum bobot=' || (SELECT sum_w FROM weights)::text || ', deviasi >0.03=' ||
                 (SELECT COUNT(*) FROM mart.fact_site_suitability f CROSS JOIN weights w
                  WHERE ABS(f.composite_score - ROUND(
                    f.power_score*w.wp + f.safety_score*w.ws + f.network_score*w.wn + f.environment_score*w.we, 2
                  )) > 0.03)::text
          UNION ALL
          SELECT 'UAT-04', 'Konsistensi Aturan Knock-Out (Disqualified tidak masuk national_rank_eligible)',
                 (SELECT COUNT(*) FROM mart.fact_site_suitability
                  WHERE (is_knockout AND (national_rank_eligible IS NOT NULL OR suitability_tier <> 'Disqualified (Knock-Out)'))
                     OR (NOT is_knockout AND national_rank_eligible IS NULL)) = 0,
                 'Total KO=' || (SELECT COUNT(*) FILTER (WHERE is_knockout) FROM mart.fact_site_suitability)::text ||
                 ', Eligible=' || (SELECT COUNT(*) FILTER (WHERE NOT is_knockout) FROM mart.fact_site_suitability)::text
          UNION ALL
          SELECT 'UAT-05', 'Validitas Geometri PostGIS 100% (0 Invalid Geom di mart.dim_wilayah)',
                 (SELECT COUNT(*) FROM mart.dim_wilayah WHERE geom IS NULL OR NOT ST_IsValid(geom)) = 0,
                 'Invalid/NULL geom: ' || (SELECT COUNT(*) FROM mart.dim_wilayah WHERE geom IS NULL OR NOT ST_IsValid(geom))::text
          UNION ALL
          SELECT 'UAT-06', 'Kelengkapan Governance 12 Sumber Data (SRC-01..SRC-12) & 0 Karantina Kritis',
                 (SELECT COUNT(*) FROM semantic.v_dc_dq_governance) = 12
             AND (SELECT COALESCE(SUM(quarantined_rows), 0) FROM semantic.v_dc_dq_governance) = 0,
                 'Sumber=' || (SELECT COUNT(*) FROM semantic.v_dc_dq_governance)::text ||
                 ', Karantina=' || (SELECT COALESCE(SUM(quarantined_rows), 0) FROM semantic.v_dc_dq_governance)::text ||
                 ', Warning=' || (SELECT COALESCE(SUM(warning_issues), 0) FROM semantic.v_dc_dq_governance)::text
        )
        SELECT test_id, CASE WHEN is_pass THEN 'PASS' ELSE 'FAIL' END AS status, deskripsi, bukti_aktual
        FROM checks
        ORDER BY test_id;
        """,
    ),
    (
        "08_Top15_Eligible",
        """
        SELECT
          national_rank_eligible,
          region_pulau,
          prov_name,
          kabkota_name,
          bps_kabkota_code,
          composite_score,
          power_score,
          safety_score,
          network_score,
          environment_score,
          suitability_tier,
          nearest_gardu_150kv_km,
          gardu_hv_150kv_count_25km,
          pembangkit_total_mw_50km,
          ookla_avg_d_mbps,
          ookla_avg_lat_ms,
          menara_density_per_100km2,
          effective_temp_c,
          prov_iklh_avg_score
        FROM semantic.v_dc_site_ranking
        WHERE NOT is_knockout
        ORDER BY national_rank_eligible
        LIMIT 15;
        """,
    ),
    (
        "09_Top10_Luar_Jawa",
        """
        SELECT
          ROW_NUMBER() OVER (ORDER BY composite_score DESC, power_score DESC) AS rank_luar_jawa,
          national_rank_eligible AS rank_nasional,
          region_pulau,
          prov_name,
          kabkota_name,
          composite_score,
          power_score,
          safety_score,
          network_score,
          environment_score,
          suitability_tier,
          nearest_gardu_150kv_km,
          ookla_avg_d_mbps,
          prov_pop_isp_count
        FROM semantic.v_dc_site_ranking
        WHERE NOT is_knockout
          AND region_pulau <> 'Jawa'
        ORDER BY composite_score DESC, power_score DESC
        LIMIT 10;
        """,
    ),
    (
        "10_KnockOut_Audit_45",
        """
        SELECT
          region_pulau,
          prov_name,
          kabkota_name,
          bps_kabkota_code,
          composite_score,
          power_score,
          safety_score,
          network_score,
          environment_score,
          ko_seismic_flag,
          ko_flood_flag,
          eq_count_ko_events_25km,
          eq_max_magnitude_25km,
          bnpb_flood_events,
          bnpb_total_events,
          knockout_reasons
        FROM semantic.v_dc_site_ranking
        WHERE is_knockout
        ORDER BY composite_score DESC;
        """,
    ),
    (
        "11_Province_Benchmark",
        "SELECT * FROM semantic.v_dc_province_summary ORDER BY avg_composite_score DESC;",
    ),
    (
        "12_Hazard_Trends_Yearly",
        """
        SELECT
          tahun,
          disaster_category,
          SUM(event_count) AS total_events,
          SUM(total_deaths) AS total_deaths,
          SUM(total_damaged_houses) AS total_damaged_houses,
          SUM(total_flooded_houses) AS total_flooded_houses
        FROM semantic.v_dc_hazard_trends
        GROUP BY 1, 2
        ORDER BY 1, 3 DESC;
        """,
    ),
    (
        "13_All_514_Sites",
        """
        SELECT
          tahun_penilaian, region_pulau, bps_prov_code, prov_name, bps_kabkota_code, kabkota_name,
          adm2_pcode, is_papua_split, area_sqkm, center_lat, center_lon,
          composite_score, power_score, safety_score, network_score, environment_score,
          eligibility_status, suitability_tier, is_knockout, ko_seismic_flag, ko_flood_flag, knockout_reasons,
          national_rank_eligible, national_rank_all, prov_rank_eligible,
          nearest_gardu_150kv_km, gardu_hv_150kv_count_25km, gardu_max_kv_25km,
          pembangkit_count_50km, pembangkit_total_mw_50km, pembangkit_renew_share_pct, nearest_pembangkit_km,
          eq_count_m5_plus_25km, eq_count_ko_events_25km, eq_max_magnitude_25km,
          bnpb_total_events, bnpb_flood_events, bnpb_landslide_events, bnpb_total_deaths,
          ookla_tile_count, ookla_avg_d_mbps, ookla_avg_u_mbps, ookla_avg_lat_ms,
          menara_total_count, menara_lte_5g_share_pct, menara_density_per_100km2,
          prov_pop_isp_count, pop_isp_is_parent_fallback,
          effective_temp_c, t2m_mean_c, bmkg_tavg_c, rh2m_mean_pct, elevation_mean_m, prov_iklh_avg_score,
          ipm_2024, population_2024, is_tertinggal, road_density_km_per_km2, dist_to_primary_trunk_km
        FROM semantic.v_dc_site_ranking
        ORDER BY COALESCE(national_rank_eligible, 9999), composite_score DESC;
        """,
    ),
]


def col_letter(idx: int) -> str:
    res = ""
    while idx > 0:
        idx, rem = divmod(idx - 1, 26)
        res = chr(65 + rem) + res
    return res


def normalize_cell(val):
    if isinstance(val, datetime.datetime):
        return val.strftime("%Y-%m-%d %H:%M:%S")
    if isinstance(val, datetime.date):
        return val.isoformat()
    if isinstance(val, decimal.Decimal):
        return float(val)
    return val


def write_xlsx_openpyxl(path: Path, sheets):
    import openpyxl
    from openpyxl.styles import Font, PatternFill, Alignment

    wb = openpyxl.Workbook()
    wb.remove(wb.active)

    header_font = Font(name="Calibri", size=11, bold=True, color="FFFFFF")
    header_fill = PatternFill(start_color="1F4E78", end_color="1F4E78", fill_type="solid")

    for name, headers, rows in sheets:
        ws = wb.create_sheet(title=name[:31])
        ws.append(headers)
        for col_idx in range(1, len(headers) + 1):
            c = ws.cell(row=1, column=col_idx)
            c.font = header_font
            c.fill = header_fill
            c.alignment = Alignment(horizontal="center", vertical="center")
        for row in rows:
            ws.append([normalize_cell(v) for v in row])
        ws.freeze_panes = "A2"
        ws.auto_filter.ref = ws.dimensions
        for col_idx, h in enumerate(headers, 1):
            max_len = max([len(str(h))] + [len(str(r[col_idx - 1] or "")) for r in rows[:100]])
            ws.column_dimensions[col_letter(col_idx)].width = min(max(max_len + 3, 12), 45)
    wb.save(path)


def write_xlsx_stdlib(path: Path, sheets):
    """Fallback OpenXML XLSX writer murni stdlib (tanpa openpyxl)."""
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as zf:
        overrides = "\n".join(
            f'  <Override PartName="/xl/worksheets/sheet{i}.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
            for i in range(1, len(sheets) + 1)
        )
        zf.writestr("[Content_Types].xml", f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
{overrides}
</Types>""")
        zf.writestr("_rels/.rels", """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>""")
        wb_sheets = "\n".join(
            f'    <sheet name="{escape(name[:31])}" sheetId="{i}" r:id="rId{i}"/>'
            for i, (name, _, _) in enumerate(sheets, 1)
        )
        zf.writestr("xl/workbook.xml", f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
{wb_sheets}
  </sheets>
</workbook>""")
        wb_rels = "\n".join(
            f'  <Relationship Id="rId{i}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet{i}.xml"/>'
            for i in range(1, len(sheets) + 1)
        ) + f'\n  <Relationship Id="rId{len(sheets)+1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        zf.writestr("xl/_rels/workbook.xml.rels", f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
{wb_rels}
</Relationships>""")
        zf.writestr("xl/styles.xml", """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="2">
    <font><sz val="11"/><name val="Calibri"/></font>
    <font><b/><sz val="11"/><color rgb="FFFFFFFF"/><name val="Calibri"/></font>
  </fonts>
  <fills count="3">
    <fill><patternFill patternType="none"/></fill>
    <fill><patternFill patternType="gray125"/></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FF1F4E78"/></patternFill></fill>
  </fills>
  <borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>
  <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
  <cellXfs count="2">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
    <xf numFmtId="0" fontId="1" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1"/>
  </cellXfs>
</styleSheet>""")

        for idx, (_, headers, rows) in enumerate(sheets, 1):
            xml_rows = []
            h_cells = "".join(
                f'<c r="{col_letter(c)}1" t="inlineStr" s="1"><is><t>{escape(str(h))}</t></is></c>'
                for c, h in enumerate(headers, 1)
            )
            xml_rows.append(f'<row r="1">{h_cells}</row>')
            for r_idx, row in enumerate(rows, 2):
                cells = []
                for c_idx, val in enumerate(row, 1):
                    ref = f"{col_letter(c_idx)}{r_idx}"
                    if val is None:
                        continue
                    elif isinstance(val, bool):
                        cells.append(f'<c r="{ref}" t="inlineStr"><is><t>{"TRUE" if val else "FALSE"}</t></is></c>')
                    elif isinstance(val, (int, float, decimal.Decimal)):
                        cells.append(f'<c r="{ref}"><v>{val}</v></c>')
                    else:
                        txt = str(normalize_cell(val))[:32000]
                        txt = "".join(ch for ch in txt if ch in ("\t", "\n", "\r") or ord(ch) >= 32)
                        cells.append(f'<c r="{ref}" t="inlineStr"><is><t>{escape(txt)}</t></is></c>')
                xml_rows.append(f'<row r="{r_idx}">{"".join(cells)}</row>')
            sheet_xml = (
                '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
                '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
                '<sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews>'
                '<sheetData>' + "".join(xml_rows) + '</sheetData></worksheet>'
            )
            zf.writestr(f"xl/worksheets/sheet{idx}.xml", sheet_xml)


def md_table(headers, rows):
    lines = [
        "| " + " | ".join(str(h) for h in headers) + " |",
        "| " + " | ".join("---" for _ in headers) + " |",
    ]
    for r in rows:
        lines.append("| " + " | ".join("" if v is None else str(normalize_cell(v)).replace("|", "/") for v in r) + " |")
    return "\n".join(lines)


def main():
    CSV_DIR.mkdir(parents=True, exist_ok=True)
    sheets = []
    sheet_map = {}

    conn = get_db_conn()
    try:
        with conn.cursor() as cur:
            for name, sql in QUERIES:
                cur.execute(sql)
                headers = [d[0] for d in cur.description]
                rows = cur.fetchall()
                sheets.append((name, headers, rows))
                sheet_map[name] = (headers, rows)

                csv_file = CSV_DIR / f"{name}.csv"
                with csv_file.open("w", newline="", encoding="utf-8-sig") as f:
                    w = csv.writer(f)
                    w.writerow(headers)
                    for r in rows:
                        w.writerow([normalize_cell(v) for v in r])
                print(f"[CSV] {csv_file.name} ({len(rows)} baris)")
    finally:
        conn.close()

    try:
        write_xlsx_openpyxl(XLSX_PATH, sheets)
        engine = "openpyxl (styled + autofilter)"
    except ImportError:
        write_xlsx_stdlib(XLSX_PATH, sheets)
        engine = "stdlib OpenXML fallback"
    print(f"[XLSX] {XLSX_PATH.name} ({len(sheets)} sheets, engine={engine})")

    # Buat ringkasan Markdown siap salin ke laporan/presentasi
    md_parts = [
        "# Evidence Summary — DE Capstone Indonesia Data Center Site Intelligence",
        f"\n*Diekspor otomatis dari PostgreSQL `labdata` pada {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n",
        "## 1. Executive KPI & Benchmark Operasional\n",
        md_table(*sheet_map["01_Executive_KPI"]),
        "\n## 2. Hasil Verifikasi UAT (Acceptance Criteria)\n",
        md_table(*sheet_map["07_UAT_Results"]),
        "\n## 3. Tata Kelola & Kualitas 12 Sumber Data\n",
        md_table(*sheet_map["03_DQ_Governance"]),
        "\n## 4. Top 15 Rekomendasi Lokasi Data Center Nasional (Eligible)\n",
        md_table(sheet_map["08_Top15_Eligible"][0][:11], [r[:11] for r in sheet_map["08_Top15_Eligible"][1]]),
        "\n## 5. Top 10 Kandidat Ekspansi Luar Pulau Jawa (Eligible)\n",
        md_table(sheet_map["09_Top10_Luar_Jawa"][0][:11], [r[:11] for r in sheet_map["09_Top10_Luar_Jawa"][1]]),
        "\n## 6. Sampel 10 Wilayah Disqualified (Knock-Out) Skor Infrastruktur Tertinggi\n",
        md_table(sheet_map["10_KnockOut_Audit_45"][0], sheet_map["10_KnockOut_Audit_45"][1][:10]),
    ]
    MD_PATH.write_text("\n".join(md_parts) + "\n", encoding="utf-8")
    print(f"[MD] {MD_PATH.name} selesai dibuat.")


if __name__ == "__main__":
    main()