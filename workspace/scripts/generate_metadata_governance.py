#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_metadata_governance.py
Komponen 6: Membangun Metadata Governance otomatis + manual ke workspace/metadata/:
  1. catalog.csv   (Metadata otomatis dari PostgreSQL + klasifikasi/owner manual)
  2. lineage.csv   (Source-to-target lineage upstream-to-downstream + job/key mapping)
  3. glossary.csv  (Business glossary KPI, 4 pilar, MDM, & kebijakan tata kelola)
"""
import csv
import datetime
import os
from pathlib import Path
import psycopg2

WORKSPACE_DIR = Path(__file__).resolve().parent.parent
META_DIR = WORKSPACE_DIR / "metadata"

LAYER_META = {
    "raw": ("Landing (Raw)", "Internal-Landing", "etl_runner", "Data Engineer (Ingestion)", "90 hari", "SRC-01..SRC-12 landing persis berkas sumber"),
    "stg": ("Staging & DQ", "Internal-Operational", "etl_runner", "Data Engineer (ETL/DQ)", "90 hari", "Tipe data standar, PostGIS GIST, lolos gerbang DQ"),
    "dq": ("Data Quality Audit", "Internal-Governance", "dq_steward", "Data Steward", "180 hari", "Karantina CRITICAL & log WARNING teraudit"),
    "ops": ("Operations & Control", "Internal-Governance", "dq_steward", "DataOps Lead", "365 hari", "Manifest 29 berkas, 18 parameter scoring, run log, SLI/SLO"),
    "mdm": ("Master Data Management", "Internal-Governance", "dq_steward", "Data Steward", "730 hari", "Crosswalk 514 kab/kota, 38 provinsi, 15 alias, fallback Papua"),
    "vault": ("Raw Data Vault 2.0", "Internal-Curated", "etl_runner", "Data Architect", "730 hari", "Insert-only Hub/Link/Satellite dengan MD5 hash key & hashdiff"),
    "bv": ("Business Vault Spasial", "Internal-Curated", "etl_runner", "Data Architect", "730 hari", "Subdivisi PostGIS, 5 spatial links, 4 pillar satellites"),
    "mart": ("Analytical Star Schema", "Internal-Analytical", "etl_runner", "Analytics Engineer", "365 hari", "4 Dimensi & 2 Fact siap agregasi BI sub-detik"),
    "semantic": ("Consumption / BI Layer", "Restricted-NonCommercial", "bi_reader", "BI / Analytics Lead", "365 hari", "Contract views Superset (termasuk protected views minimization/masking)"),
}


def get_db_conn():
    return psycopg2.connect(
        host=os.environ.get("LAB_DB_HOST", "postgres"),
        port=int(os.environ.get("LAB_DB_PORT", "5432")),
        dbname=os.environ.get("LAB_DB_NAME", "labdata"),
        user=os.environ.get("LAB_DB_USER", "labuser"),
        password=os.environ.get("LAB_DB_PASSWORD", ""),
    )


def build_catalog(cur):
    sql = """
    SELECT
      t.table_schema,
      t.table_name,
      t.table_type,
      (SELECT COUNT(*) FROM information_schema.columns c
       WHERE c.table_schema = t.table_schema AND c.table_name = t.table_name) AS column_count,
      COALESCE(s.n_live_tup, 0) AS est_row_count,
      COALESCE(obj_description((quote_ident(t.table_schema) || '.' || quote_ident(t.table_name))::regclass, 'pg_class'), '') AS pg_comment
    FROM information_schema.tables t
    LEFT JOIN pg_stat_user_tables s
      ON s.schemaname = t.table_schema AND s.relname = t.table_name
    WHERE t.table_schema IN ('raw','stg','dq','ops','mdm','vault','bv','mart','semantic')
      AND t.table_name NOT IN ('sales_orders','daily_sales','v_daily_sales','v_data_quality')
    ORDER BY
      CASE t.table_schema
        WHEN 'raw' THEN 1 WHEN 'stg' THEN 2 WHEN 'dq' THEN 3 WHEN 'ops' THEN 4
        WHEN 'mdm' THEN 5 WHEN 'vault' THEN 6 WHEN 'bv' THEN 7
        WHEN 'mart' THEN 8 WHEN 'semantic' THEN 9
      END,
      t.table_name;
    """
    cur.execute(sql)
    rows = cur.fetchall()
    now_iso = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    headers = [
        "asset_id", "schema_name", "object_name", "object_type",
        "metadata_source_auto", "column_count_auto", "row_count_auto",
        "layer_manual", "classification_manual", "db_role_manual",
        "steward_owner_manual", "retention_policy_manual",
        "version", "description", "extracted_at"
    ]
    out = []
    for idx, (sch, tbl, ttype, col_cnt, est_rows, comment) in enumerate(rows, 1):
        if ttype == "BASE TABLE":
            cur.execute(f'SELECT COUNT(*) FROM "{sch}"."{tbl}"')
            exact_rows = cur.fetchone()[0]
        else:
            exact_rows = est_rows
        layer, cls, role, steward, ret, default_desc = LAYER_META[sch]
        desc = comment.strip() if comment and comment.strip() else default_desc
        out.append([
            f"AST-{idx:03d}", sch, tbl, ttype,
            "AUTO (PostgreSQL information_schema + COUNT)", col_cnt, exact_rows,
            layer, cls, role, steward, ret,
            "v1.0-20261125", desc, now_iso
        ])
    return headers, out


def build_lineage():
    headers = [
        "lineage_id", "stage_order", "upstream_asset", "downstream_asset",
        "transformation_job", "execution_layer", "key_or_join_mapping",
        "business_rule_summary", "metadata_origin", "steward_owner"
    ]
    rows = [
        ("LIN-01", 1, "SRC-01 (BMKG Earthquake CSV)", "raw.src_01_bmkg_gempa", "run_ingestion.py", "RAW", "_batch_id + _row_no", "Landing mentah 217.807 gempa + registrasi SHA-256 di ops.source_file_manifest", "MANUAL+AUTO", "Data Engineer"),
        ("LIN-02", 1, "SRC-02 (BNPB Disaster XLSX)", "raw.src_02_bnpb_bencana", "run_ingestion.py", "RAW", "_batch_id + _row_no", "Landing mentah 28.773 kejadian bencana 2010-2025", "MANUAL+AUTO", "Data Engineer"),
        ("LIN-03", 1, "SRC-03 (BMKG Climate 3 CSV)", "raw.src_03_iklim_harian / provinsi / stasiun", "run_ingestion.py", "RAW", "station_id, province_id", "Landing 589.265 observasi harian + 192 stasiun + 34 provinsi", "MANUAL+AUTO", "Data Engineer"),
        ("LIN-04", 1, "SRC-04 (Master Features Kab/Kota)", "raw.src_04_fitur_kabkota", "run_ingestion.py", "RAW", "bps_kabkota_code (514)", "Landing master fitur 514 kab/kota (NASA POWER, elevasi, jalan, IPM)", "MANUAL+AUTO", "Data Engineer"),
        ("LIN-05", 1, "SRC-05..SRC-08 (OpenCelliD, Ookla, GPPD, OSM)", "raw.src_05..src_08", "run_ingestion.py", "RAW", "lat/lon, gppd_idnr, osm_id", "Landing aset menara (66.059), Ookla (229.305), pembangkit (178), gardu (2.821)", "MANUAL+AUTO", "Data Engineer"),
        ("LIN-06", 1, "SRC-09..SRC-12 (PoP ISP, IKLH, COD-AB, BPS)", "raw.src_09..src_12", "run_ingestion.py", "RAW", "provinsi, adm2_pcode", "Landing PoP ISP (34), IKLH (152), batas ADM1/ADM2, penduduk (186)", "MANUAL+AUTO", "Data Engineer"),
        ("LIN-07", 2, "raw.src_01..src_12 (15 tabel)", "stg.src_01..src_12 + dq.quarantine_records + dq.capstone_quality_issues", "wf_stg_master.hwf (15 .hpl)", "STG+DQ", "DQ-KEY/GEO/DOM + dedup BNPB 329 baris", "Casting tipe aman, sanitasi sentinel, BBox EQ vs LAND, PostGIS GIST; 0 CRITICAL, 15.625 WARNING", "AUTO (Hop)", "Data Engineer"),
        ("LIN-08", 3, "stg.src_04_fitur_kabkota + stg.src_11_adm2", "mdm.wilayah_crosswalk + mdm.provinsi_crosswalk + mdm.wilayah_alias", "07-mdm-params.sql / 07b / 07c", "MDM", "bps_kabkota_code <-> adm2_pcode", "Resolusi 514 kab/kota, 38 provinsi, 15 alias BNPB/BMKG, penyelarasan kode Papua 91-97", "MANUAL", "Data Steward"),
        ("LIN-09", 4, "stg.src_01..src_12 + mdm.*", "vault.hub_* (9) + vault.link_* (3) + vault.sat_* (14)", "wf_vault_load.hwf (load_vault.sql)", "VAULT", "MD5(business_key) + hashdiff", "Insert-only Raw Data Vault 2.0; normalisasi unit kV (gardu) & Mbps (Ookla)", "AUTO (SQL)", "Data Architect"),
        ("LIN-10", 5, "vault.sat_wilayah_geom + vault.sat_*_detail", "bv.wilayah_geom_subdiv + bv.link_*_wilayah (5 Spatial Links)", "wf_bv_load.hwf (load_bv.sql)", "BV-SPATIAL", "ST_Subdivide(256) + Two-Stage Geodesic", "Pemecahan 35.882 sub-poligon GIST + spatial join gempa (25km), pembangkit (50km), gardu (25km), menara, Ookla", "AUTO (PostGIS)", "Data Architect"),
        ("LIN-11", 5, "bv.link_*_wilayah + vault.* + ops.scoring_parameters", "bv.sat_bv_wilayah_power / safety / network / environment", "wf_bv_load.hwf (load_bv.sql)", "BV-PILLAR", "hk_wilayah (514)", "Agregasi 4 pilar, log-min-max scaling, parent fallback PoP ISP Papua, & flag Knock-Out", "AUTO (SQL)", "Analytics Engineer"),
        ("LIN-12", 6, "bv.sat_bv_wilayah_* + vault.* + ops.scoring_parameters", "mart.dim_* (4) + mart.fact_site_suitability + mart.fact_hazard_events_annual", "wf_mart_load.hwf (load_mart.sql)", "MART", "wilayah_sk, prov_sk, waktu_sk", "Skor komposit berbobot (35/25/25/15), tier kelayakan, peringkat eligible/all, agregasi hazard 2010-2025", "AUTO (SQL)", "Analytics Engineer"),
        ("LIN-13", 7, "mart.* + dq.* + ops.*", "semantic.v_dc_* (6) + semantic.v_dc_*_protected (2)", "11-semantic.sql / 11b / 12-security-rbac.sql", "SEMANTIC", "View contract + RBAC bi_reader", "Enrichment region_pulau (7 pulau), unpivot 4 pilar, masking koordinat 2 desimal & notice non-komersial", "MANUAL+AUTO", "BI Lead"),
        ("LIN-14", 8, "semantic.v_dc_*", "Apache Superset (4-Tab Dashboard) & DE_Capstone_Evidence_Workbook.xlsx", "dashboard_dc_site_intelligence.zip / export_evidence.py", "CONSUMER", "SQLAlchemy -> bi_reader / labdata", "Konsumsi visual eksekutif (SLO 0.103 ms & 2.741 ms) + ekspor 13 sheet bukti empiris", "AUTO", "BI Lead"),
    ]
    return headers, rows


def build_glossary():
    headers = [
        "term_id", "business_term", "domain", "definition",
        "formula_or_rule", "unit", "owner_steward", "related_asset"
    ]
    rows = [
        ("GLS-01", "Composite Suitability Score", "KPI Utama (Q1)", "Skor kelayakan gabungan 0-100 untuk pembangunan data center tingkat kabupaten/kota.", "0.35*Power + 0.25*Safety + 0.25*Network + 0.15*Environment (dibaca dari ops.scoring_parameters)", "Skor (0-100)", "Analytics Engineer", "mart.fact_site_suitability"),
        ("GLS-02", "Power Pillar Score", "Pilar 1 (35%)", "Kesiapan kelistrikan berbasis kedekatan & kepadatan gardu HV >=150kV serta kapasitas pembangkit 50km.", "0.40*dist_gardu_inv + 0.30*cnt_gardu_25km + 0.20*mw_50km + 0.10*renew_share", "Skor (0-100)", "Analytics Engineer", "bv.sat_bv_wilayah_power"),
        ("GLS-03", "Safety Pillar Score", "Pilar 2 (25%)", "Tingkat keamanan terhadap paparan gempa signifikan M>=5.0 (25km) serta banjir & longsor BNPB.", "0.45*eq_inv + 0.35*flood_inv + 0.20*other_hazard_inv (log-min-max)", "Skor (0-100)", "Data Steward", "bv.sat_bv_wilayah_safety"),
        ("GLS-04", "Network Pillar Score", "Pilar 3 (25%)", "Kualitas konektivitas berbasis kecepatan & latensi Ookla, kepadatan menara seluler, & PoP ISP.", "0.35*dl_mbps + 0.25*lat_inv + 0.25*tower_density + 0.15*pop_isp", "Skor (0-100)", "Analytics Engineer", "bv.sat_bv_wilayah_network"),
        ("GLS-05", "Environment Pillar Score", "Pilar 4 (15%)", "Kesesuaian iklim pendinginan (PUE), kualitas lingkungan (IKLH), elevasi, dan kelembapan.", "0.40*temp_eff + 0.30*iklh + 0.15*elev_fit + 0.15*rh_inv", "Skor (0-100)", "Analytics Engineer", "bv.sat_bv_wilayah_environment"),
        ("GLS-06", "Knock-Out Disqualification", "Governance / Risk (Q3)", "Gerbang diskualifikasi otomatis bagi wilayah dengan risiko seismik dangkal destruktif atau banjir kronis.", "ko_seismic (M>=6.5, depth<=30km, r<=25km, cnt>=1) OR ko_flood (bnpb_flood_events > 50)", "Boolean + Reason", "Data Steward", "mart.fact_site_suitability"),
        ("GLS-07", "Suitability Tier", "Segmentasi (Q1/Q2)", "Klasifikasi prioritas investasi dari wilayah eligible dan disqualified.", "Disqualified (KO); Tier 1 Prime (>=65); Tier 2 Recommended (55-64.99); Tier 3 Moderate (45-54.99); Tier 4 (<45)", "Kategori", "BI Lead", "semantic.v_dc_site_ranking"),
        ("GLS-08", "Papua Parent Fallback", "MDM Crosswalk", "Mekanisme pewarisan metrik provinsi induk (ID91/ID94) untuk 4 provinsi pemekaran Papua (26 kab/kota).", "pop_isp_is_parent_fallback = TRUE untuk BPS 92, 95, 96, 97", "Boolean Flag", "Data Steward", "mdm.wilayah_crosswalk"),
        ("GLS-09", "CRITICAL Quarantine vs WARNING", "Data Quality", "Pemisahan anomali fatal (diblokir ke dq.quarantine_records) vs anomali non-fatal (disanitasi & dicatat di dq.capstone_quality_issues).", "CRITICAL -> block staging; WARNING -> load safe + log issue", "Severity", "Data Steward", "dq.quarantine_records"),
        ("GLS-10", "Permitted Purpose (Non-Commercial)", "Security & Compliance", "Pembatasan tujuan penggunaan produk data sesuai lisensi SRC-06 Ookla (CC BY-NC-SA 4.0) & SRC-08 OSM (ODbL).", "Hanya untuk riset akademik/non-komersial kecuali lisensi komersial Ookla & data PLN diperoleh", "Policy", "Data Owner", "ops.data_classification_policy"),
    ]
    return headers, rows


def write_csv(path: Path, headers, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(headers)
        w.writerows(rows)
    print(f"[METADATA] {path.name} ({len(rows)} baris)")


def main():
    conn = get_db_conn()
    try:
        with conn.cursor() as cur:
            c_h, c_r = build_catalog(cur)
    finally:
        conn.close()

    l_h, l_r = build_lineage()
    g_h, g_r = build_glossary()

    write_csv(META_DIR / "catalog.csv", c_h, c_r)
    write_csv(META_DIR / "lineage.csv", l_h, l_r)
    write_csv(META_DIR / "glossary.csv", g_h, g_r)


if __name__ == "__main__":
    main()