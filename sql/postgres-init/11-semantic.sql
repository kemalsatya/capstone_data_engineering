-- =============================================================================
-- 11-semantic.sql
-- Semantic Views (semantic.*) untuk konsumsi Apache Superset & BI
-- Tidak mengubah view demo bawaan (semantic.v_data_quality)
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS semantic;

DROP VIEW IF EXISTS
  semantic.v_dc_pillar_breakdown,
  semantic.v_dc_site_ranking,
  semantic.v_dc_province_summary,
  semantic.v_dc_hazard_trends,
  semantic.v_dc_dq_governance CASCADE;

-- 1. View Utama Peringkat & Peta Kesesuaian Lokasi Data Center (514 Kab/Kota)
CREATE OR REPLACE VIEW semantic.v_dc_site_ranking AS
SELECT
  f.waktu_sk AS tahun_penilaian,
  w.bps_kabkota_code,
  w.kabkota_name,
  p.bps_prov_code,
  p.prov_name,
  w.adm2_pcode,
  w.is_papua_split,
  w.area_sqkm,
  w.center_lat,
  w.center_lon,
  w.geom_geojson_simple,

  -- Skor & Peringkat
  f.composite_score,
  f.power_score,
  f.safety_score,
  f.network_score,
  f.environment_score,
  f.eligibility_status,
  f.suitability_tier,
  f.is_knockout,
  f.ko_seismic_flag,
  f.ko_flood_flag,
  f.knockout_reasons,
  f.national_rank_eligible,
  f.national_rank_all,
  f.prov_rank_eligible,

  -- KPI Detail Pilar Power
  f.nearest_gardu_150kv_km,
  f.gardu_hv_150kv_count_25km,
  f.gardu_max_kv_25km,
  f.pembangkit_count_50km,
  f.pembangkit_total_mw_50km,
  f.pembangkit_renew_share_pct,
  f.nearest_pembangkit_km,

  -- KPI Detail Pilar Safety
  f.eq_count_m5_plus_25km,
  f.eq_count_ko_events_25km,
  f.eq_max_magnitude_25km,
  f.bnpb_total_events,
  f.bnpb_flood_events,
  f.bnpb_landslide_events,
  f.bnpb_total_deaths,

  -- KPI Detail Pilar Network
  f.ookla_tile_count,
  f.ookla_avg_d_mbps,
  f.ookla_avg_u_mbps,
  f.ookla_avg_lat_ms,
  f.menara_total_count,
  f.menara_lte_5g_share_pct,
  f.menara_density_per_100km2,
  f.prov_pop_isp_count,
  f.pop_isp_is_parent_fallback,

  -- KPI Detail Pilar Environment & Sosial-Ekonomi
  f.effective_temp_c,
  f.t2m_mean_c,
  f.bmkg_tavg_c,
  f.rh2m_mean_pct,
  f.elevation_mean_m,
  f.prov_iklh_avg_score,
  w.ipm_2024,
  w.population_2024,
  w.is_tertinggal,
  w.road_density_km_per_km2,
  w.dist_to_primary_trunk_km
FROM mart.fact_site_suitability f
JOIN mart.dim_wilayah  w ON w.wilayah_sk = f.wilayah_sk
JOIN mart.dim_provinsi p ON p.prov_sk    = f.prov_sk;

-- 2. View Ringkasan Eksekutif Per Provinsi (38 Provinsi)
CREATE OR REPLACE VIEW semantic.v_dc_province_summary AS
WITH top_city AS (
  SELECT DISTINCT ON (prov_sk)
    f.prov_sk,
    w.kabkota_name AS top_eligible_kabkota,
    f.composite_score AS top_eligible_score
  FROM mart.fact_site_suitability f
  JOIN mart.dim_wilayah w ON w.wilayah_sk = f.wilayah_sk
  WHERE NOT f.is_knockout
  ORDER BY f.prov_sk, f.composite_score DESC, f.power_score DESC
)
SELECT
  p.bps_prov_code,
  p.prov_name,
  p.is_papua_split_prov,
  COUNT(*)::int AS total_kabkota,
  COUNT(*) FILTER (WHERE NOT f.is_knockout)::int AS eligible_kabkota,
  COUNT(*) FILTER (WHERE f.is_knockout)::int AS knockout_kabkota,
  COUNT(*) FILTER (WHERE f.suitability_tier = 'Tier 1 - Prime')::int AS tier1_prime_count,
  ROUND(AVG(f.composite_score), 2) AS avg_composite_score,
  ROUND(AVG(f.power_score), 2) AS avg_power_score,
  ROUND(AVG(f.safety_score), 2) AS avg_safety_score,
  ROUND(AVG(f.network_score), 2) AS avg_network_score,
  ROUND(AVG(f.environment_score), 2) AS avg_environment_score,
  ROUND(AVG(f.ookla_avg_d_mbps), 2) AS avg_download_mbps,
  p.pop_isp_count,
  p.iklh_avg_score,
  p.penduduk_ribu,
  tc.top_eligible_kabkota,
  tc.top_eligible_score
FROM mart.fact_site_suitability f
JOIN mart.dim_provinsi p ON p.prov_sk = f.prov_sk
LEFT JOIN top_city tc ON tc.prov_sk = p.prov_sk
GROUP BY
  p.bps_prov_code, p.prov_name, p.is_papua_split_prov,
  p.pop_isp_count, p.iklh_avg_score, p.penduduk_ribu,
  tc.top_eligible_kabkota, tc.top_eligible_score;

-- 3. View Tren Kejadian Bencana Tahunan BNPB (2010 - 2025)
CREATE OR REPLACE VIEW semantic.v_dc_hazard_trends AS
SELECT
  h.waktu_sk AS tahun,
  p.bps_prov_code,
  p.prov_name,
  w.bps_kabkota_code,
  w.kabkota_name,
  h.disaster_category,
  h.event_count,
  h.total_deaths,
  h.total_damaged_houses,
  h.total_flooded_houses
FROM mart.fact_hazard_events_annual h
JOIN mart.dim_wilayah  w ON w.wilayah_sk = h.wilayah_sk
JOIN mart.dim_provinsi p ON p.prov_sk    = h.prov_sk;

-- 4. View Tata Kelola & Observabilitas Data Quality (Governance Dashboard)
CREATE OR REPLACE VIEW semantic.v_dc_dq_governance AS
WITH manifest_agg AS (
  SELECT
    source_id,
    COUNT(*)::int AS file_count,
    SUM(row_count)::bigint AS manifest_rows,
    ROUND(SUM(bytes)::numeric / (1024 * 1024), 2) AS total_size_mb,
    MIN(license) AS license
  FROM ops.source_file_manifest
  GROUP BY source_id
),
dq_agg AS (
  SELECT
    'SRC-' || SUBSTRING(source_table FROM 'src_([0-9]{2})') AS source_id,
    COUNT(*) FILTER (WHERE severity = 'CRITICAL')::int AS critical_issues,
    COUNT(*) FILTER (WHERE severity = 'HIGH')::int AS high_issues,
    COUNT(*) FILTER (WHERE severity = 'WARNING')::int AS warning_issues,
    COUNT(*)::int AS total_dq_issues
  FROM dq.capstone_quality_issues
  GROUP BY 1
),
q_agg AS (
  SELECT
    'SRC-' || SUBSTRING(source_table FROM 'src_([0-9]{2})') AS source_id,
    COUNT(*)::int AS quarantined_rows
  FROM dq.quarantine_records
  GROUP BY 1
)
SELECT
  m.source_id,
  m.file_count,
  m.manifest_rows,
  m.total_size_mb,
  m.license,
  COALESCE(q.quarantined_rows, 0) AS quarantined_rows,
  COALESCE(d.critical_issues, 0) AS critical_issues,
  COALESCE(d.high_issues, 0) AS high_issues,
  COALESCE(d.warning_issues, 0) AS warning_issues,
  COALESCE(d.total_dq_issues, 0) AS total_dq_issues
FROM manifest_agg m
LEFT JOIN dq_agg d ON d.source_id = m.source_id
LEFT JOIN q_agg  q ON q.source_id = m.source_id
ORDER BY m.source_id;