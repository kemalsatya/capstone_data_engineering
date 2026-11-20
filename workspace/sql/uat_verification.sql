-- =============================================================================
-- uat_verification.sql
-- Suite Uji UAT, Integritas Model, Transparansi Formula, & Performa SLO
-- =============================================================================

\echo '=== 1. UAT RINGKASAN PASS / FAIL (ACCEPTANCE CRITERIA) ==='
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
SELECT
  test_id,
  CASE WHEN is_pass THEN 'PASS' ELSE 'FAIL' END AS status,
  deskripsi,
  bukti_aktual
FROM checks
ORDER BY test_id;

\echo ''
\echo '=== 2. UAT PERSONA EKSPANSI (Q2): TOP 10 KANDIDAT ELGIBLE DI LUAR PULAU JAWA ==='
SELECT
  ROW_NUMBER() OVER (ORDER BY composite_score DESC, power_score DESC) AS rank_luar_jawa,
  national_rank_eligible AS rank_nas,
  region_pulau,
  kabkota_name,
  prov_name,
  composite_score,
  power_score AS pwr,
  safety_score AS saf,
  network_score AS net,
  environment_score AS env,
  suitability_tier
FROM semantic.v_dc_site_ranking
WHERE NOT is_knockout
  AND region_pulau <> 'Jawa'
ORDER BY composite_score DESC, power_score DESC
LIMIT 10;

\echo ''
\echo '=== 3. UJI PERFORMA SLO QUERY BI (EXPLAIN ANALYZE) ==='
EXPLAIN (ANALYZE, SUMMARY, COSTS OFF, BUFFERS OFF)
SELECT region_pulau, prov_name, kabkota_name, composite_score, suitability_tier
FROM semantic.v_dc_site_ranking
WHERE NOT is_knockout
ORDER BY composite_score DESC
LIMIT 15;

EXPLAIN (ANALYZE, SUMMARY, COSTS OFF, BUFFERS OFF)
SELECT tahun, disaster_category, SUM(event_count) AS total_events
FROM semantic.v_dc_hazard_trends
GROUP BY 1, 2
ORDER BY 1, 2;