-- =============================================================================
-- load_mart.sql
-- Loader Idempotent Star Schema (mart.*) dari Vault, Business Vault, & MDM
-- Bobot 4 pilar & tahun snapshot dibaca dinamis dari ops.scoring_parameters
-- =============================================================================

TRUNCATE TABLE
  mart.fact_hazard_events_annual,
  mart.fact_site_suitability,
  mart.dim_parameter_scoring,
  mart.dim_waktu,
  mart.dim_wilayah,
  mart.dim_provinsi;

-- -----------------------------------------------------------------------------
-- 1. Load mart.dim_parameter_scoring
-- -----------------------------------------------------------------------------
INSERT INTO mart.dim_parameter_scoring (param_key, param_group, param_value, unit, description)
SELECT param_key, param_group, param_value, unit, description
FROM ops.scoring_parameters;

-- -----------------------------------------------------------------------------
-- 2. Load mart.dim_waktu (2010 - 2026)
-- -----------------------------------------------------------------------------
WITH assess_yr AS (
  SELECT COALESCE(MAX(CASE WHEN param_key = 'assessment_year' THEN param_value END)::int, 2024) AS yr
  FROM ops.scoring_parameters
)
INSERT INTO mart.dim_waktu (waktu_sk, tahun, dekade, is_assessment_year)
SELECT
  y AS waktu_sk,
  y AS tahun,
  ((y / 10) * 10)::text || 's' AS dekade,
  (y = a.yr) AS is_assessment_year
FROM generate_series(2010, 2026) AS y
CROSS JOIN assess_yr a;

-- -----------------------------------------------------------------------------
-- 3. Load mart.dim_provinsi (38 Provinsi)
-- -----------------------------------------------------------------------------
WITH prov_env_net AS (
  SELECT
    lwp.hk_provinsi,
    MAX(n.prov_pop_isp_count) AS pop_isp_count,
    MAX(e.prov_iklh_year)     AS iklh_year,
    MAX(e.prov_iklh_avg_score) AS iklh_avg_score,
    MAX(e.prov_penduduk_year) AS penduduk_year,
    MAX(e.prov_penduduk_ribu) AS penduduk_ribu,
    MAX(e.prov_kepadatan_km2) AS kepadatan_km2
  FROM vault.link_wilayah_provinsi lwp
  LEFT JOIN bv.sat_bv_wilayah_network n ON n.hk_wilayah = lwp.hk_wilayah
  LEFT JOIN bv.sat_bv_wilayah_environment e ON e.hk_wilayah = lwp.hk_wilayah
  GROUP BY lwp.hk_provinsi
)
INSERT INTO mart.dim_provinsi (
  prov_sk, hk_provinsi, bps_prov_code, prov_name, adm1_pcode_2020,
  is_papua_split_prov, pop_isp_count, iklh_year, iklh_avg_score,
  penduduk_year, penduduk_ribu, kepadatan_km2
)
SELECT
  hp.bps_prov_code::integer AS prov_sk,
  hp.hk_provinsi,
  hp.bps_prov_code,
  pw.prov_name_canonical,
  pw.adm1_pcode_2020,
  pw.is_papua_split_prov,
  pen.pop_isp_count,
  pen.iklh_year,
  pen.iklh_avg_score,
  pen.penduduk_year,
  pen.penduduk_ribu,
  pen.kepadatan_km2
FROM vault.hub_provinsi hp
JOIN mdm.provinsi_crosswalk pw ON pw.bps_prov_code = hp.bps_prov_code
LEFT JOIN prov_env_net pen ON pen.hk_provinsi = hp.hk_provinsi;

-- -----------------------------------------------------------------------------
-- 4. Load mart.dim_wilayah (514 Kab/Kota + GeoJSON Ringan untuk Superset)
-- -----------------------------------------------------------------------------
WITH latest_fitur AS (
  SELECT DISTINCT ON (hk_wilayah) *
  FROM vault.sat_wilayah_fitur
  ORDER BY hk_wilayah, load_date DESC
),
latest_geom AS (
  SELECT DISTINCT ON (hk_wilayah) *
  FROM vault.sat_wilayah_geom
  ORDER BY hk_wilayah, load_date DESC
)
INSERT INTO mart.dim_wilayah (
  wilayah_sk, hk_wilayah, bps_kabkota_code, prov_sk,
  kabkota_name, prov_name, adm2_pcode, mapping_method, is_papua_split,
  area_sqkm, center_lat, center_lon,
  ipm_2024, ppm_2024, population_2024, ntl_radiance_mean,
  tertinggal_status, is_tertinggal, road_density_km_per_km2, dist_to_primary_trunk_km,
  geom, geom_geojson_simple
)
SELECT
  hw.bps_kabkota_code::integer AS wilayah_sk,
  hw.hk_wilayah,
  hw.bps_kabkota_code,
  wc.bps_prov_code::integer AS prov_sk,
  wc.kabkota_name_canonical,
  wc.prov_name_canonical,
  wc.adm2_pcode,
  wc.mapping_method,
  wc.is_papua_split,
  lg.area_sqkm,
  COALESCE(lg.center_lat, ROUND(ST_Y(ST_PointOnSurface(lg.geom))::numeric, 7)),
  COALESCE(lg.center_lon, ROUND(ST_X(ST_PointOnSurface(lg.geom))::numeric, 7)),
  lf.ipm_2024,
  lf.ppm_2024,
  lf.population_2024,
  lf.ntl_radiance_mean,
  lf.tertinggal_status,
  lf.is_tertinggal,
  lf.road_density_km_per_km2,
  lf.dist_to_primary_trunk_km,
  lg.geom,
  ST_AsGeoJSON(ST_SimplifyPreserveTopology(lg.geom, 0.01), 4) AS geom_geojson_simple
FROM vault.hub_wilayah hw
JOIN mdm.wilayah_crosswalk wc ON wc.bps_kabkota_code = hw.bps_kabkota_code
LEFT JOIN latest_fitur lf ON lf.hk_wilayah = hw.hk_wilayah
LEFT JOIN latest_geom lg ON lg.hk_wilayah = hw.hk_wilayah;

-- -----------------------------------------------------------------------------
-- 5. Load mart.fact_site_suitability (514 Kab/Kota + Scoring 4 Pilar)
-- -----------------------------------------------------------------------------
WITH weights AS (
  SELECT
    MAX(CASE WHEN param_key = 'assessment_year'    THEN param_value END)::int AS assess_yr,
    MAX(CASE WHEN param_key = 'weight_power'       THEN param_value END)      AS w_power,
    MAX(CASE WHEN param_key = 'weight_safety'      THEN param_value END)      AS w_safety,
    MAX(CASE WHEN param_key = 'weight_network'     THEN param_value END)      AS w_network,
    MAX(CASE WHEN param_key = 'weight_environment' THEN param_value END)      AS w_env
  FROM ops.scoring_parameters
),
base AS (
  SELECT
    dw.wilayah_sk,
    dw.prov_sk,
    w.assess_yr AS waktu_sk,
    w.w_power, w.w_safety, w.w_network, w.w_env,

    -- Power
    p.pembangkit_count_50km,
    p.pembangkit_total_mw_50km,
    p.pembangkit_renew_share_pct,
    p.nearest_pembangkit_km,
    p.gardu_total_count_25km,
    p.gardu_hv_150kv_count_25km,
    p.gardu_max_kv_25km,
    p.nearest_gardu_150kv_km,

    -- Safety
    s.eq_count_m5_plus_25km,
    s.eq_count_ko_events_25km,
    s.eq_max_magnitude_25km,
    s.eq_min_distance_ko_km,
    s.bnpb_total_events,
    s.bnpb_flood_events,
    s.bnpb_landslide_events,
    s.bnpb_other_events,
    s.bnpb_total_deaths,
    s.bnpb_total_damaged_houses,
    s.ko_seismic_flag,
    s.ko_flood_flag,
    s.is_knockout,
    s.knockout_reasons,

    -- Network
    n.ookla_tile_count,
    n.ookla_total_tests,
    n.ookla_avg_d_mbps,
    n.ookla_avg_u_mbps,
    n.ookla_avg_lat_ms,
    n.menara_total_count,
    n.menara_lte_5g_share_pct,
    n.menara_density_per_100km2,
    n.prov_pop_isp_count,
    n.pop_isp_is_parent_fallback,

    -- Environment
    e.t2m_mean_c,
    e.rh2m_mean_pct,
    e.bmkg_tavg_c,
    e.bmkg_match_method,
    ROUND(COALESCE(e.t2m_mean_c, e.bmkg_tavg_c, 27.0)::numeric, 2) AS effective_temp_c,
    e.elevation_mean_m,
    e.prov_iklh_avg_score
  FROM mart.dim_wilayah dw
  CROSS JOIN weights w
  JOIN bv.sat_bv_wilayah_power       p ON p.hk_wilayah = dw.hk_wilayah
  JOIN bv.sat_bv_wilayah_safety      s ON s.hk_wilayah = dw.hk_wilayah
  JOIN bv.sat_bv_wilayah_network     n ON n.hk_wilayah = dw.hk_wilayah
  JOIN bv.sat_bv_wilayah_environment e ON e.hk_wilayah = dw.hk_wilayah
),
pillar_scores AS (
  SELECT
    b.*,

    -- Pilar 1: Power Score (0 - 100)
    ROUND((
      0.40 * GREATEST(0.0, 100.0 * (1.0 - LEAST(COALESCE(b.nearest_gardu_150kv_km, 100.0), 100.0) / 100.0)) +
      0.30 * COALESCE(100.0 * LN(1.0 + b.gardu_hv_150kv_count_25km) / NULLIF(MAX(LN(1.0 + b.gardu_hv_150kv_count_25km)) OVER (), 0), 0.0) +
      0.20 * COALESCE(100.0 * LN(1.0 + b.pembangkit_total_mw_50km)  / NULLIF(MAX(LN(1.0 + b.pembangkit_total_mw_50km)) OVER (), 0), 0.0) +
      0.10 * LEAST(100.0, GREATEST(0.0, COALESCE(b.pembangkit_renew_share_pct, 0.0)))
    )::numeric, 2) AS power_score,

    -- Pilar 2: Safety Score (0 - 100, semakin tinggi semakin aman)
    ROUND((
      0.45 * (100.0 * (1.0 - COALESCE(LN(1.0 + b.eq_count_m5_plus_25km) / NULLIF(MAX(LN(1.0 + b.eq_count_m5_plus_25km)) OVER (), 0), 0.0))) +
      0.35 * (100.0 * (1.0 - COALESCE(LN(1.0 + b.bnpb_flood_events)     / NULLIF(MAX(LN(1.0 + b.bnpb_flood_events)) OVER (), 0), 0.0))) +
      0.20 * (100.0 * (1.0 - COALESCE(LN(1.0 + b.bnpb_landslide_events + b.bnpb_other_events)
             / NULLIF(MAX(LN(1.0 + b.bnpb_landslide_events + b.bnpb_other_events)) OVER (), 0), 0.0)))
    )::numeric, 2) AS safety_score,

    -- Pilar 3: Network Score (0 - 100)
    ROUND((
      0.35 * COALESCE(100.0 * LN(1.0 + COALESCE(b.ookla_avg_d_mbps, 0.0)) / NULLIF(MAX(LN(1.0 + COALESCE(b.ookla_avg_d_mbps, 0.0))) OVER (), 0), 0.0) +
      0.25 * GREATEST(0.0, 100.0 * (1.0 - LEAST(GREATEST(COALESCE(b.ookla_avg_lat_ms, 100.0), 5.0) - 5.0, 95.0) / 95.0)) +
      0.25 * COALESCE(100.0 * LN(1.0 + b.menara_density_per_100km2) / NULLIF(MAX(LN(1.0 + b.menara_density_per_100km2)) OVER (), 0), 0.0) +
      0.15 * COALESCE(100.0 * LN(1.0 + COALESCE(b.prov_pop_isp_count, 0)) / NULLIF(MAX(LN(1.0 + COALESCE(b.prov_pop_isp_count, 0))) OVER (), 0), 0.0)
    )::numeric, 2) AS network_score,

    -- Pilar 4: Environment & Climate Score (0 - 100)
    ROUND((
      0.40 * LEAST(100.0, GREATEST(0.0, 100.0 * (30.0 - b.effective_temp_c) / 12.0)) +
      0.30 * LEAST(100.0, GREATEST(0.0, COALESCE(b.prov_iklh_avg_score, 50.0))) +
      0.15 * CASE
               WHEN b.elevation_mean_m BETWEEN 50 AND 800 THEN 100.0
               WHEN b.elevation_mean_m < 50  THEN GREATEST(20.0, 20.0 + (GREATEST(b.elevation_mean_m, 0.0) / 50.0) * 80.0)
               WHEN b.elevation_mean_m > 800 THEN GREATEST(20.0, 100.0 - ((b.elevation_mean_m - 800.0) / 1500.0) * 80.0)
               ELSE 50.0
             END +
      0.15 * LEAST(100.0, GREATEST(0.0, 100.0 * (95.0 - COALESCE(b.rh2m_mean_pct, 80.0)) / 35.0))
    )::numeric, 2) AS environment_score
  FROM base b
),
scored AS (
  SELECT
    ps.*,
    ROUND((
      ps.power_score       * ps.w_power +
      ps.safety_score      * ps.w_safety +
      ps.network_score     * ps.w_network +
      ps.environment_score * ps.w_env
    )::numeric, 2) AS composite_score
  FROM pillar_scores ps
)
INSERT INTO mart.fact_site_suitability (
  wilayah_sk, prov_sk, waktu_sk,
  pembangkit_count_50km, pembangkit_total_mw_50km, pembangkit_renew_share_pct, nearest_pembangkit_km,
  gardu_total_count_25km, gardu_hv_150kv_count_25km, gardu_max_kv_25km, nearest_gardu_150kv_km,
  eq_count_m5_plus_25km, eq_count_ko_events_25km, eq_max_magnitude_25km, eq_min_distance_ko_km,
  bnpb_total_events, bnpb_flood_events, bnpb_landslide_events, bnpb_other_events,
  bnpb_total_deaths, bnpb_total_damaged_houses,
  ookla_tile_count, ookla_total_tests, ookla_avg_d_mbps, ookla_avg_u_mbps, ookla_avg_lat_ms,
  menara_total_count, menara_lte_5g_share_pct, menara_density_per_100km2,
  prov_pop_isp_count, pop_isp_is_parent_fallback,
  t2m_mean_c, rh2m_mean_pct, bmkg_tavg_c, bmkg_match_method, effective_temp_c,
  elevation_mean_m, prov_iklh_avg_score,
  power_score, safety_score, network_score, environment_score, composite_score,
  ko_seismic_flag, ko_flood_flag, is_knockout, knockout_reasons,
  eligibility_status, suitability_tier,
  national_rank_all, national_rank_eligible, prov_rank_eligible
)
SELECT
  sc.wilayah_sk, sc.prov_sk, sc.waktu_sk,
  sc.pembangkit_count_50km, sc.pembangkit_total_mw_50km, sc.pembangkit_renew_share_pct, sc.nearest_pembangkit_km,
  sc.gardu_total_count_25km, sc.gardu_hv_150kv_count_25km, sc.gardu_max_kv_25km, sc.nearest_gardu_150kv_km,
  sc.eq_count_m5_plus_25km, sc.eq_count_ko_events_25km, sc.eq_max_magnitude_25km, sc.eq_min_distance_ko_km,
  sc.bnpb_total_events, sc.bnpb_flood_events, sc.bnpb_landslide_events, sc.bnpb_other_events,
  sc.bnpb_total_deaths, sc.bnpb_total_damaged_houses,
  sc.ookla_tile_count, sc.ookla_total_tests, sc.ookla_avg_d_mbps, sc.ookla_avg_u_mbps, sc.ookla_avg_lat_ms,
  sc.menara_total_count, sc.menara_lte_5g_share_pct, sc.menara_density_per_100km2,
  sc.prov_pop_isp_count, sc.pop_isp_is_parent_fallback,
  sc.t2m_mean_c, sc.rh2m_mean_pct, sc.bmkg_tavg_c, sc.bmkg_match_method, sc.effective_temp_c,
  sc.elevation_mean_m, sc.prov_iklh_avg_score,
  sc.power_score, sc.safety_score, sc.network_score, sc.environment_score, sc.composite_score,
  sc.ko_seismic_flag, sc.ko_flood_flag, sc.is_knockout, sc.knockout_reasons,
  CASE WHEN sc.is_knockout THEN 'KNOCKED_OUT' ELSE 'ELIGIBLE' END AS eligibility_status,
  CASE
    WHEN sc.is_knockout          THEN 'Disqualified (Knock-Out)'
    WHEN sc.composite_score >= 65 THEN 'Tier 1 - Prime'
    WHEN sc.composite_score >= 55 THEN 'Tier 2 - Recommended'
    WHEN sc.composite_score >= 45 THEN 'Tier 3 - Moderate'
    ELSE 'Tier 4 - Low Suitability'
  END AS suitability_tier,
  RANK() OVER (ORDER BY sc.composite_score DESC, sc.power_score DESC) AS national_rank_all,
  CASE WHEN NOT sc.is_knockout
       THEN RANK() OVER (PARTITION BY sc.is_knockout ORDER BY sc.composite_score DESC, sc.power_score DESC)
  END AS national_rank_eligible,
  CASE WHEN NOT sc.is_knockout
       THEN RANK() OVER (PARTITION BY sc.prov_sk, sc.is_knockout ORDER BY sc.composite_score DESC, sc.power_score DESC)
  END AS prov_rank_eligible
FROM scored sc;

-- -----------------------------------------------------------------------------
-- 6. Load mart.fact_hazard_events_annual (Tren Bencana BNPB 2010 - 2025)
-- -----------------------------------------------------------------------------
WITH latest_bencana AS (
  SELECT DISTINCT ON (hk_bencana)
    hk_bencana, event_date, disaster_type, death, damaged_house, flooded_house
  FROM vault.sat_bencana_detail
  WHERE event_date IS NOT NULL
    AND EXTRACT(YEAR FROM event_date) BETWEEN 2010 AND 2026
  ORDER BY hk_bencana, load_date DESC
)
INSERT INTO mart.fact_hazard_events_annual (
  wilayah_sk, prov_sk, waktu_sk, disaster_category,
  event_count, total_deaths, total_damaged_houses, total_flooded_houses
)
SELECT
  dw.wilayah_sk,
  dw.prov_sk,
  EXTRACT(YEAR FROM bd.event_date)::integer AS waktu_sk,
  CASE
    WHEN bd.disaster_type ~* '(banjir|flood)'      THEN 'Banjir'
    WHEN bd.disaster_type ~* '(longsor|landslide)' THEN 'Tanah Longsor'
    WHEN bd.disaster_type ~* '(puting|angin|cuaca)' THEN 'Cuaca Ekstrem'
    WHEN bd.disaster_type ~* '(gempa|tsunami)'     THEN 'Gempa & Tsunami'
    WHEN bd.disaster_type ~* '(kebakaran|karhutla)' THEN 'Karhutla'
    ELSE 'Lainnya'
  END AS disaster_category,
  COUNT(*)::integer AS event_count,
  COALESCE(SUM(bd.death), 0) AS total_deaths,
  COALESCE(SUM(bd.damaged_house), 0) AS total_damaged_houses,
  COALESCE(SUM(bd.flooded_house), 0) AS total_flooded_houses
FROM vault.link_bencana_wilayah lbw
JOIN latest_bencana bd ON bd.hk_bencana = lbw.hk_bencana
JOIN mart.dim_wilayah dw ON dw.hk_wilayah = lbw.hk_wilayah
GROUP BY dw.wilayah_sk, dw.prov_sk, EXTRACT(YEAR FROM bd.event_date)::integer, 4;