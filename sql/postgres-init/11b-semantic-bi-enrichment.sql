-- =============================================================================
-- 11b-semantic-bi-enrichment.sql
-- Pengayaan Semantic Layer untuk Apache Superset:
-- 1. Fungsi pemetaan Pulau/Region (7 koridor besar Indonesia)
-- 2. Tambahan kolom region_pulau & koordinat double precision untuk Deck.gl
-- 3. View unpivoted 4 pilar (v_dc_pillar_breakdown) & parameter (v_dc_scoring_parameters)
-- =============================================================================

CREATE OR REPLACE FUNCTION mdm.get_region_pulau(p_bps_prov_code text)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE
    WHEN p_bps_prov_code BETWEEN '11' AND '21' THEN 'Sumatera'
    WHEN p_bps_prov_code BETWEEN '31' AND '36' THEN 'Jawa'
    WHEN p_bps_prov_code BETWEEN '51' AND '53' THEN 'Bali & Nusa Tenggara'
    WHEN p_bps_prov_code BETWEEN '61' AND '65' THEN 'Kalimantan'
    WHEN p_bps_prov_code BETWEEN '71' AND '76' THEN 'Sulawesi'
    WHEN p_bps_prov_code BETWEEN '81' AND '82' THEN 'Maluku'
    WHEN p_bps_prov_code BETWEEN '91' AND '97' THEN 'Papua'
    ELSE 'Lainnya'
  END;
$$;

-- Re-create view utama agar kolom region_pulau dan tipe float koordinat tersedia bersih
DROP VIEW IF EXISTS semantic.v_dc_pillar_breakdown, semantic.v_dc_site_ranking CASCADE;
CREATE VIEW semantic.v_dc_site_ranking AS
SELECT
  f.waktu_sk AS tahun_penilaian,
  mdm.get_region_pulau(p.bps_prov_code) AS region_pulau,
  p.bps_prov_code,
  p.prov_name,
  w.bps_kabkota_code,
  w.kabkota_name,
  w.adm2_pcode,
  w.is_papua_split,
  w.area_sqkm,
  w.center_lat::double precision AS center_lat,
  w.center_lon::double precision AS center_lon,
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

-- Perbarui ringkasan provinsi dengan kolom region_pulau
DROP VIEW IF EXISTS semantic.v_dc_province_summary;
CREATE VIEW semantic.v_dc_province_summary AS
WITH top_city AS (
  SELECT DISTINCT ON (f.prov_sk)
    f.prov_sk,
    w.kabkota_name AS top_eligible_kabkota,
    f.composite_score AS top_eligible_score
  FROM mart.fact_site_suitability f
  JOIN mart.dim_wilayah w ON w.wilayah_sk = f.wilayah_sk
  WHERE NOT f.is_knockout
  ORDER BY f.prov_sk, f.composite_score DESC, f.power_score DESC
)
SELECT
  mdm.get_region_pulau(p.bps_prov_code) AS region_pulau,
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
  mdm.get_region_pulau(p.bps_prov_code),
  p.bps_prov_code, p.prov_name, p.is_papua_split_prov,
  p.pop_isp_count, p.iklh_avg_score, p.penduduk_ribu,
  tc.top_eligible_kabkota, tc.top_eligible_score;

-- Perbarui tren bencana dengan kolom region_pulau
DROP VIEW IF EXISTS semantic.v_dc_hazard_trends;
CREATE VIEW semantic.v_dc_hazard_trends AS
SELECT
  h.waktu_sk AS tahun,
  mdm.get_region_pulau(p.bps_prov_code) AS region_pulau,
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

-- View baru: format unpivoted 4 pilar (2.056 baris = 514 wilayah x 4 pilar)
CREATE OR REPLACE VIEW semantic.v_dc_pillar_breakdown AS
SELECT
  r.region_pulau,
  r.prov_name,
  r.bps_kabkota_code,
  r.kabkota_name,
  r.eligibility_status,
  r.suitability_tier,
  r.is_knockout,
  r.composite_score,
  r.national_rank_eligible,
  v.pillar_name,
  v.pillar_weight_pct,
  v.pillar_score
FROM semantic.v_dc_site_ranking r
CROSS JOIN LATERAL (
  VALUES
    ('Power (35%)',       35, r.power_score),
    ('Safety (25%)',      25, r.safety_score),
    ('Network (25%)',     25, r.network_score),
    ('Environment (15%)', 15, r.environment_score)
) AS v(pillar_name, pillar_weight_pct, pillar_score);

-- View baru: parameter bobot & ambang aktif dari Star Schema untuk Tab Governance
CREATE OR REPLACE VIEW semantic.v_dc_scoring_parameters AS
SELECT
  param_group,
  param_key,
  param_value,
  unit,
  description,
  loaded_at
FROM mart.dim_parameter_scoring
ORDER BY param_group, param_key;