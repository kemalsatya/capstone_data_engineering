-- =============================================================================
-- audit_reconciliation.sql
-- Komponen 4: Rekonsiliasi Ukuran Auditif (SUM) & Penjelasan Delta Baris
-- =============================================================================

\echo '=== 1. REKONSILIASI UKURAN AUDITIF #1: KAPASITAS PEMBANGKIT (SRC-07 GPPD, MW) ==='
WITH r AS (
  SELECT COUNT(*) AS row_cnt,
         ROUND(SUM(NULLIF(TRIM(capacity_mw), '')::numeric), 2) AS sum_mw
  FROM raw.src_07_gppd
),
s AS (
  SELECT COUNT(*) AS row_cnt,
         ROUND(SUM(capacity_mw), 2) AS sum_mw
  FROM stg.src_07_gppd
)
SELECT
  'SRC-07 GPPD' AS domain,
  r.row_cnt AS raw_rows, s.row_cnt AS stg_rows, (s.row_cnt - r.row_cnt) AS delta_rows,
  r.sum_mw  AS raw_total_mw, s.sum_mw AS stg_total_mw, (s.sum_mw - r.sum_mw) AS delta_mw,
  CASE WHEN r.row_cnt = s.row_cnt AND r.sum_mw = s.sum_mw THEN 'MATCH_100%' ELSE 'DELTA_FOUND' END AS recon_status
FROM r CROSS JOIN s;

\echo ''
\echo '=== 2. REKONSILIASI UKURAN AUDITIF #2: BENCANA BNPB (SRC-02: RAW -> STG -> MART) ==='
WITH raw_agg AS (
  SELECT
    COUNT(*) AS row_cnt,
    ROUND(SUM(CASE WHEN TRIM(COALESCE(death,'')) ~ '^[0-9]+(\.[0-9]+)?$' THEN TRIM(death)::numeric ELSE 0 END), 2) AS sum_deaths,
    ROUND(SUM(CASE WHEN TRIM(COALESCE(damaged_house,'')) ~ '^[0-9]+(\.[0-9]+)?$' THEN TRIM(damaged_house)::numeric ELSE 0 END), 2) AS sum_damaged_houses,
    ROUND(SUM(CASE WHEN TRIM(COALESCE(flooded_house,'')) ~ '^[0-9]+(\.[0-9]+)?$' THEN TRIM(flooded_house)::numeric ELSE 0 END), 2) AS sum_flooded_houses
  FROM raw.src_02_bnpb_bencana
),
stg_agg AS (
  SELECT
    COUNT(*) AS row_cnt,
    ROUND(SUM(COALESCE(death, 0)), 2) AS sum_deaths,
    ROUND(SUM(COALESCE(damaged_house, 0)), 2) AS sum_damaged_houses,
    ROUND(SUM(COALESCE(flooded_house, 0)), 2) AS sum_flooded_houses
  FROM stg.src_02_bnpb_bencana
),
mart_agg AS (
  SELECT
    SUM(event_count) AS row_cnt,
    ROUND(SUM(COALESCE(total_deaths, 0)), 2) AS sum_deaths,
    ROUND(SUM(COALESCE(total_damaged_houses, 0)), 2) AS sum_damaged_houses,
    ROUND(SUM(COALESCE(total_flooded_houses, 0)), 2) AS sum_flooded_houses
  FROM mart.fact_hazard_events_annual
)
SELECT '1. raw.src_02_bnpb_bencana' AS layer, row_cnt AS events, sum_deaths, sum_damaged_houses, sum_flooded_houses FROM raw_agg
UNION ALL
SELECT '2. stg.src_02_bnpb_bencana', row_cnt, sum_deaths, sum_damaged_houses, sum_flooded_houses FROM stg_agg
UNION ALL
SELECT '3. mart.fact_hazard_events_annual', row_cnt, sum_deaths, sum_damaged_houses, sum_flooded_houses FROM mart_agg
ORDER BY 1;

\echo ''
\echo '=== 3. ROOT-CAUSE AUDIT: DELTA 329 BARIS (RAW 28.773 vs STG 28.444) ==='
SELECT
  COUNT(*) AS total_excluded_rows,
  COUNT(*) FILTER (WHERE NULLIF(TRIM(COALESCE(r.date,'')), '') IS NULL) AS null_date,
  COUNT(*) FILTER (WHERE NULLIF(TRIM(COALESCE(r.city,'')), '') IS NULL) AS null_city,
  COUNT(*) FILTER (WHERE NULLIF(TRIM(COALESCE(r.disaster_type,'')), '') IS NULL) AS null_disaster_type,
  COUNT(*) FILTER (WHERE NULLIF(TRIM(COALESCE(r.province,'')), '') IS NULL) AS null_province
FROM raw.src_02_bnpb_bencana r
LEFT JOIN stg.src_02_bnpb_bencana s ON s._row_no = r._row_no
WHERE s._row_no IS NULL;

SELECT
  COALESCE(NULLIF(TRIM(r.date),''), '<NULL>') AS raw_date,
  COALESCE(NULLIF(TRIM(r.disaster_type),''), '<NULL>') AS raw_type,
  COALESCE(NULLIF(TRIM(r.city),''), '<NULL>') AS raw_city,
  COALESCE(NULLIF(TRIM(r.province),''), '<NULL>') AS raw_prov,
  COUNT(*) AS jml_baris
FROM raw.src_02_bnpb_bencana r
LEFT JOIN stg.src_02_bnpb_bencana s ON s._row_no = r._row_no
WHERE s._row_no IS NULL
GROUP BY 1, 2, 3, 4
ORDER BY jml_baris DESC
LIMIT 10;