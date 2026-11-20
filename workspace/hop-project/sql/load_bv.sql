-- =============================================================================
-- load_bv.sql
-- Loader Idempotent Business Vault Spasial (bv.*) dari Raw Data Vault (vault.*)
-- Membaca seluruh ambang & parameter langsung dari ops.scoring_parameters (D6)
-- =============================================================================

-- Bersihkan seluruh tabel turunan Business Vault agar 100% idempotent
TRUNCATE TABLE
  bv.wilayah_geom_subdiv,
  bv.link_gempa_wilayah,
  bv.link_pembangkit_wilayah,
  bv.link_gardu_wilayah,
  bv.link_menara_wilayah,
  bv.link_ookla_wilayah,
  bv.sat_bv_wilayah_safety,
  bv.sat_bv_wilayah_power,
  bv.sat_bv_wilayah_network,
  bv.sat_bv_wilayah_environment;

-- -----------------------------------------------------------------------------
-- 1. Bangun Poligon Subdivisi (<= 256 vertex) + Update Statistik Planner
-- -----------------------------------------------------------------------------
WITH latest_geom AS (
  SELECT DISTINCT ON (hk_wilayah) hk_wilayah, geom
  FROM vault.sat_wilayah_geom
  WHERE geom IS NOT NULL
  ORDER BY hk_wilayah, load_date DESC
)
INSERT INTO bv.wilayah_geom_subdiv (hk_wilayah, geom)
SELECT hk_wilayah, ST_Subdivide(ST_MakeValid(geom), 256)
FROM latest_geom;

ANALYZE bv.wilayah_geom_subdiv;

-- -----------------------------------------------------------------------------
-- 2. Spatial Link: Gempa BMKG (2014-2024, M >= eq_hazard_min_mag) radius 25 km
-- -----------------------------------------------------------------------------
WITH params AS (
  SELECT
    MAX(CASE WHEN param_key = 'eq_window_start_year' THEN param_value END)::int AS yr_start,
    MAX(CASE WHEN param_key = 'eq_window_end_year'   THEN param_value END)::int AS yr_end,
    MAX(CASE WHEN param_key = 'eq_radius_km'         THEN param_value END)      AS radius_km,
    MAX(CASE WHEN param_key = 'eq_hazard_min_mag'    THEN param_value END)      AS min_mag,
    MAX(CASE WHEN param_key = 'eq_ko_min_mag'        THEN param_value END)      AS ko_mag,
    MAX(CASE WHEN param_key = 'eq_ko_max_depth_km'   THEN param_value END)      AS ko_depth
  FROM ops.scoring_parameters
),
latest_gempa AS (
  SELECT DISTINCT ON (g.hk_gempa)
    g.hk_gempa, g.event_date, g.magnitude, g.depth_km, g.geom
  FROM vault.sat_gempa_detail g
  CROSS JOIN params p
  WHERE g.geom IS NOT NULL
    AND g.event_date IS NOT NULL
    AND EXTRACT(YEAR FROM g.event_date) BETWEEN p.yr_start AND p.yr_end
    AND g.magnitude >= p.min_mag
  ORDER BY g.hk_gempa, g.load_date DESC
)
INSERT INTO bv.link_gempa_wilayah (
  hk_wilayah, hk_gempa, event_date, magnitude, depth_km,
  distance_km, is_inside_wilayah, is_knockout_event
)
SELECT
  sub.hk_wilayah,
  g.hk_gempa,
  g.event_date,
  g.magnitude,
  g.depth_km,
  ROUND((MIN(ST_Distance(sub.geom::geography, g.geom::geography)) / 1000.0)::numeric, 3) AS distance_km,
  BOOL_OR(ST_Intersects(sub.geom, g.geom)) AS is_inside_wilayah,
  (g.magnitude >= p.ko_mag AND g.depth_km IS NOT NULL AND g.depth_km <= p.ko_depth) AS is_knockout_event
FROM bv.wilayah_geom_subdiv sub
CROSS JOIN params p
JOIN latest_gempa g
  ON ST_DWithin(sub.geom, g.geom, (p.radius_km::double precision / 111.0) * 1.15)
 AND ST_DWithin(sub.geom::geography, g.geom::geography, p.radius_km::double precision * 1000.0)
GROUP BY sub.hk_wilayah, g.hk_gempa, g.event_date, g.magnitude, g.depth_km, p.ko_mag, p.ko_depth;

-- -----------------------------------------------------------------------------
-- 3. Spatial Link: Pembangkit Listrik GPPD radius 50 km
-- -----------------------------------------------------------------------------
WITH params AS (
  SELECT MAX(CASE WHEN param_key = 'powerplant_radius_km' THEN param_value END) AS radius_km
  FROM ops.scoring_parameters
),
latest_plant AS (
  SELECT DISTINCT ON (hk_pembangkit)
    hk_pembangkit, capacity_mw, primary_fuel, geom
  FROM vault.sat_pembangkit_detail
  WHERE geom IS NOT NULL
  ORDER BY hk_pembangkit, load_date DESC
)
INSERT INTO bv.link_pembangkit_wilayah (
  hk_wilayah, hk_pembangkit, capacity_mw, primary_fuel,
  is_renewable, distance_km, is_inside_wilayah
)
SELECT
  sub.hk_wilayah,
  pl.hk_pembangkit,
  pl.capacity_mw,
  pl.primary_fuel,
  (pl.primary_fuel IN ('Hydro', 'Geothermal', 'Solar', 'Wind', 'Biomass', 'Wave and Tidal')) AS is_renewable,
  ROUND((MIN(ST_Distance(sub.geom::geography, pl.geom::geography)) / 1000.0)::numeric, 3) AS distance_km,
  BOOL_OR(ST_Intersects(sub.geom, pl.geom)) AS is_inside_wilayah
FROM bv.wilayah_geom_subdiv sub
CROSS JOIN params p
JOIN latest_plant pl
  ON ST_DWithin(sub.geom, pl.geom, (p.radius_km::double precision / 111.0) * 1.15)
 AND ST_DWithin(sub.geom::geography, pl.geom::geography, p.radius_km::double precision * 1000.0)
GROUP BY sub.hk_wilayah, pl.hk_pembangkit, pl.capacity_mw, pl.primary_fuel;

-- -----------------------------------------------------------------------------
-- 4. Spatial Link: Gardu Induk OSM radius 25 km
-- -----------------------------------------------------------------------------
WITH params AS (
  SELECT
    MAX(CASE WHEN param_key = 'substation_radius_km' THEN param_value END) AS radius_km,
    MAX(CASE WHEN param_key = 'substation_min_kv'    THEN param_value END) AS min_kv
  FROM ops.scoring_parameters
),
latest_gardu AS (
  SELECT DISTINCT ON (hk_gardu)
    hk_gardu, voltage_max_kv, geom
  FROM vault.sat_gardu_detail
  WHERE geom IS NOT NULL
  ORDER BY hk_gardu, load_date DESC
)
INSERT INTO bv.link_gardu_wilayah (
  hk_wilayah, hk_gardu, voltage_max_kv, is_hv_150kv_plus,
  distance_km, is_inside_wilayah
)
SELECT
  sub.hk_wilayah,
  gd.hk_gardu,
  gd.voltage_max_kv,
  (gd.voltage_max_kv IS NOT NULL AND gd.voltage_max_kv >= p.min_kv) AS is_hv_150kv_plus,
  ROUND((MIN(ST_Distance(sub.geom::geography, gd.geom::geography)) / 1000.0)::numeric, 3) AS distance_km,
  BOOL_OR(ST_Intersects(sub.geom, gd.geom)) AS is_inside_wilayah
FROM bv.wilayah_geom_subdiv sub
CROSS JOIN params p
JOIN latest_gardu gd
  ON ST_DWithin(sub.geom, gd.geom, (p.radius_km::double precision / 111.0) * 1.15)
 AND ST_DWithin(sub.geom::geography, gd.geom::geography, p.radius_km::double precision * 1000.0)
GROUP BY sub.hk_wilayah, gd.hk_gardu, gd.voltage_max_kv, p.min_kv;

-- -----------------------------------------------------------------------------
-- 5. Spatial Link: Menara Seluler OpenCelliD (Point-in-Polygon)
-- -----------------------------------------------------------------------------
WITH latest_menara AS (
  SELECT DISTINCT ON (hk_menara) hk_menara, radio, geom
  FROM vault.sat_menara_detail
  WHERE geom IS NOT NULL
  ORDER BY hk_menara, load_date DESC
)
INSERT INTO bv.link_menara_wilayah (hk_menara, hk_wilayah, radio)
SELECT DISTINCT ON (m.hk_menara)
  m.hk_menara,
  sub.hk_wilayah,
  m.radio
FROM latest_menara m
JOIN bv.wilayah_geom_subdiv sub
  ON ST_Intersects(sub.geom, m.geom)
ORDER BY m.hk_menara, sub.hk_wilayah;

-- -----------------------------------------------------------------------------
-- 6. Spatial Link: Tile Ookla Fixed (Centroid-in-Polygon)
-- -----------------------------------------------------------------------------
WITH latest_ookla AS (
  SELECT DISTINCT ON (hk_ookla_tile)
    hk_ookla_tile,
    ST_SetSRID(ST_MakePoint(tile_x::double precision, tile_y::double precision), 4326) AS centroid_geom
  FROM vault.sat_ookla_detail
  WHERE tile_x IS NOT NULL AND tile_y IS NOT NULL
  ORDER BY hk_ookla_tile, load_date DESC
)
INSERT INTO bv.link_ookla_wilayah (hk_ookla_tile, hk_wilayah)
SELECT DISTINCT ON (o.hk_ookla_tile)
  o.hk_ookla_tile,
  sub.hk_wilayah
FROM latest_ookla o
JOIN bv.wilayah_geom_subdiv sub
  ON ST_Intersects(sub.geom, o.centroid_geom)
ORDER BY o.hk_ookla_tile, sub.hk_wilayah;

-- -----------------------------------------------------------------------------
-- 7. Business Satellite Pilar 1: SAFETY (Gempa + Bencana BNPB + Knock-Out)
-- -----------------------------------------------------------------------------
WITH params AS (
  SELECT
    MAX(CASE WHEN param_key = 'bnpb_window_start_year' THEN param_value END)::int AS bnpb_start,
    MAX(CASE WHEN param_key = 'bnpb_window_end_year'   THEN param_value END)::int AS bnpb_end,
    MAX(CASE WHEN param_key = 'flood_ko_max_events'    THEN param_value END)::int AS flood_ko_max
  FROM ops.scoring_parameters
),
eq_agg AS (
  SELECT
    hk_wilayah,
    COUNT(*)::int AS eq_count_m5_plus_25km,
    COUNT(*) FILTER (WHERE is_knockout_event)::int AS eq_count_ko_events_25km,
    MAX(magnitude) AS eq_max_magnitude_25km,
    MIN(distance_km) FILTER (WHERE is_knockout_event) AS eq_min_distance_ko_km
  FROM bv.link_gempa_wilayah
  GROUP BY hk_wilayah
),
latest_bencana AS (
  SELECT DISTINCT ON (hk_bencana)
    hk_bencana, event_date, disaster_type, death, damaged_house, flooded_house
  FROM vault.sat_bencana_detail
  ORDER BY hk_bencana, load_date DESC
),
bnpb_agg AS (
  SELECT
    lbw.hk_wilayah,
    COUNT(*)::int AS bnpb_total_events,
    COUNT(*) FILTER (WHERE bd.disaster_type ~* '(banjir|flood)')::int AS bnpb_flood_events,
    COUNT(*) FILTER (WHERE bd.disaster_type ~* '(longsor|landslide)')::int AS bnpb_landslide_events,
    COUNT(*) FILTER (WHERE bd.disaster_type !~* '(banjir|flood|longsor|landslide)')::int AS bnpb_other_events,
    COALESCE(SUM(bd.death), 0) AS bnpb_total_deaths,
    COALESCE(SUM(bd.damaged_house), 0) AS bnpb_total_damaged_houses,
    COALESCE(SUM(bd.flooded_house), 0) AS bnpb_total_flooded_houses
  FROM vault.link_bencana_wilayah lbw
  JOIN latest_bencana bd ON bd.hk_bencana = lbw.hk_bencana
  CROSS JOIN params p
  WHERE bd.event_date IS NOT NULL
    AND EXTRACT(YEAR FROM bd.event_date) BETWEEN p.bnpb_start AND p.bnpb_end
  GROUP BY lbw.hk_wilayah
)
INSERT INTO bv.sat_bv_wilayah_safety (
  hk_wilayah, eq_count_m5_plus_25km, eq_count_ko_events_25km, eq_max_magnitude_25km, eq_min_distance_ko_km,
  bnpb_total_events, bnpb_flood_events, bnpb_landslide_events, bnpb_other_events,
  bnpb_total_deaths, bnpb_total_damaged_houses, bnpb_total_flooded_houses,
  ko_seismic_flag, ko_flood_flag, is_knockout, knockout_reasons
)
SELECT
  hw.hk_wilayah,
  COALESCE(e.eq_count_m5_plus_25km, 0),
  COALESCE(e.eq_count_ko_events_25km, 0),
  e.eq_max_magnitude_25km,
  e.eq_min_distance_ko_km,
  COALESCE(b.bnpb_total_events, 0),
  COALESCE(b.bnpb_flood_events, 0),
  COALESCE(b.bnpb_landslide_events, 0),
  COALESCE(b.bnpb_other_events, 0),
  COALESCE(b.bnpb_total_deaths, 0),
  COALESCE(b.bnpb_total_damaged_houses, 0),
  COALESCE(b.bnpb_total_flooded_houses, 0),
  (COALESCE(e.eq_count_ko_events_25km, 0) > 0) AS ko_seismic_flag,
  (COALESCE(b.bnpb_flood_events, 0) > p.flood_ko_max) AS ko_flood_flag,
  (COALESCE(e.eq_count_ko_events_25km, 0) > 0 OR COALESCE(b.bnpb_flood_events, 0) > p.flood_ko_max) AS is_knockout,
  NULLIF(concat_ws(', ',
    CASE WHEN COALESCE(e.eq_count_ko_events_25km, 0) > 0 THEN 'SEISMIC_KO_M6.5_SHALLOW_25KM' END,
    CASE WHEN COALESCE(b.bnpb_flood_events, 0) > p.flood_ko_max THEN 'FLOOD_KO_GT_50_EVENTS' END
  ), '') AS knockout_reasons
FROM vault.hub_wilayah hw
CROSS JOIN params p
LEFT JOIN eq_agg e ON e.hk_wilayah = hw.hk_wilayah
LEFT JOIN bnpb_agg b ON b.hk_wilayah = hw.hk_wilayah;

-- -----------------------------------------------------------------------------
-- 8. Business Satellite Pilar 2: POWER (Pembangkit GPPD + Gardu HV >= 150 kV)
-- -----------------------------------------------------------------------------
WITH params AS (
  SELECT MAX(CASE WHEN param_key = 'substation_min_kv' THEN param_value END) AS min_kv
  FROM ops.scoring_parameters
),
w_centroid AS (
  SELECT DISTINCT ON (hk_wilayah)
    hk_wilayah,
    COALESCE(
      CASE WHEN center_lon IS NOT NULL AND center_lat IS NOT NULL
           THEN ST_SetSRID(ST_MakePoint(center_lon::double precision, center_lat::double precision), 4326) END,
      ST_PointOnSurface(geom)
    ) AS c_geom
  FROM vault.sat_wilayah_geom
  ORDER BY hk_wilayah, load_date DESC
),
plant_agg AS (
  SELECT
    hk_wilayah,
    COUNT(*)::int AS pembangkit_count_50km,
    COUNT(*) FILTER (WHERE is_inside_wilayah)::int AS pembangkit_inside_count,
    COALESCE(SUM(capacity_mw), 0) AS pembangkit_total_mw_50km,
    COALESCE(SUM(capacity_mw) FILTER (WHERE is_renewable), 0) AS pembangkit_renew_mw_50km,
    MIN(distance_km) AS min_dist_km
  FROM bv.link_pembangkit_wilayah
  GROUP BY hk_wilayah
),
gardu_agg AS (
  SELECT
    hk_wilayah,
    COUNT(*)::int AS gardu_total_count_25km,
    COUNT(*) FILTER (WHERE is_hv_150kv_plus)::int AS gardu_hv_150kv_count_25km,
    COUNT(*) FILTER (WHERE is_hv_150kv_plus AND is_inside_wilayah)::int AS gardu_hv_inside_count,
    MAX(voltage_max_kv) AS gardu_max_kv_25km,
    MIN(distance_km) FILTER (WHERE is_hv_150kv_plus) AS min_hv_dist_km
  FROM bv.link_gardu_wilayah
  GROUP BY hk_wilayah
),
latest_plant_all AS (
  SELECT DISTINCT ON (hk_pembangkit) hk_pembangkit, geom
  FROM vault.sat_pembangkit_detail
  WHERE geom IS NOT NULL
  ORDER BY hk_pembangkit, load_date DESC
),
latest_gardu_hv AS (
  SELECT DISTINCT ON (g.hk_gardu) g.hk_gardu, g.geom
  FROM vault.sat_gardu_detail g
  CROSS JOIN params p
  WHERE g.geom IS NOT NULL AND g.voltage_max_kv >= p.min_kv
  ORDER BY g.hk_gardu, g.load_date DESC
)
INSERT INTO bv.sat_bv_wilayah_power (
  hk_wilayah, pembangkit_count_50km, pembangkit_inside_count,
  pembangkit_total_mw_50km, pembangkit_renew_mw_50km, pembangkit_renew_share_pct,
  nearest_pembangkit_km, gardu_total_count_25km, gardu_hv_150kv_count_25km,
  gardu_hv_inside_count, gardu_max_kv_25km, nearest_gardu_150kv_km
)
SELECT
  hw.hk_wilayah,
  COALESCE(pa.pembangkit_count_50km, 0),
  COALESCE(pa.pembangkit_inside_count, 0),
  COALESCE(pa.pembangkit_total_mw_50km, 0),
  COALESCE(pa.pembangkit_renew_mw_50km, 0),
  CASE WHEN COALESCE(pa.pembangkit_total_mw_50km, 0) > 0
       THEN ROUND((pa.pembangkit_renew_mw_50km / pa.pembangkit_total_mw_50km) * 100.0, 2)
       ELSE 0 END,
  COALESCE(pa.min_dist_km, np.dist_km),
  COALESCE(ga.gardu_total_count_25km, 0),
  COALESCE(ga.gardu_hv_150kv_count_25km, 0),
  COALESCE(ga.gardu_hv_inside_count, 0),
  ga.gardu_max_kv_25km,
  COALESCE(ga.min_hv_dist_km, ng.dist_km)
FROM vault.hub_wilayah hw
LEFT JOIN w_centroid wc ON wc.hk_wilayah = hw.hk_wilayah
LEFT JOIN plant_agg pa ON pa.hk_wilayah = hw.hk_wilayah
LEFT JOIN gardu_agg ga ON ga.hk_wilayah = hw.hk_wilayah
LEFT JOIN LATERAL (
  SELECT ROUND((ST_Distance(wc.c_geom::geography, lp.geom::geography) / 1000.0)::numeric, 3) AS dist_km
  FROM latest_plant_all lp
  ORDER BY wc.c_geom <-> lp.geom
  LIMIT 1
) np ON pa.min_dist_km IS NULL AND wc.c_geom IS NOT NULL
LEFT JOIN LATERAL (
  SELECT ROUND((ST_Distance(wc.c_geom::geography, lg.geom::geography) / 1000.0)::numeric, 3) AS dist_km
  FROM latest_gardu_hv lg
  ORDER BY wc.c_geom <-> lg.geom
  LIMIT 1
) ng ON ga.min_hv_dist_km IS NULL AND wc.c_geom IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 9. Business Satellite Pilar 3: NETWORK (Ookla + OpenCelliD + PoP ISP Provinsi)
-- -----------------------------------------------------------------------------
WITH latest_geom AS (
  SELECT DISTINCT ON (hk_wilayah) hk_wilayah, area_sqkm
  FROM vault.sat_wilayah_geom
  ORDER BY hk_wilayah, load_date DESC
),
latest_ookla AS (
  SELECT DISTINCT ON (hk_ookla_tile)
    hk_ookla_tile, avg_d_mbps, avg_u_mbps, avg_lat_ms, tests, devices
  FROM vault.sat_ookla_detail
  ORDER BY hk_ookla_tile, load_date DESC
),
ookla_agg AS (
  SELECT
    lo.hk_wilayah,
    COUNT(*)::int AS ookla_tile_count,
    COALESCE(SUM(so.tests), 0)::bigint AS ookla_total_tests,
    COALESCE(SUM(so.devices), 0)::bigint AS ookla_total_devices,
    CASE WHEN SUM(so.tests) > 0
         THEN ROUND((SUM(so.avg_d_mbps * so.tests) / SUM(so.tests))::numeric, 3)
         ELSE ROUND(AVG(so.avg_d_mbps)::numeric, 3) END AS ookla_avg_d_mbps,
    CASE WHEN SUM(so.tests) > 0
         THEN ROUND((SUM(so.avg_u_mbps * so.tests) / SUM(so.tests))::numeric, 3)
         ELSE ROUND(AVG(so.avg_u_mbps)::numeric, 3) END AS ookla_avg_u_mbps,
    CASE WHEN SUM(so.tests) > 0
         THEN ROUND((SUM(so.avg_lat_ms * so.tests) / SUM(so.tests))::numeric, 2)
         ELSE ROUND(AVG(so.avg_lat_ms)::numeric, 2) END AS ookla_avg_lat_ms
  FROM bv.link_ookla_wilayah lo
  JOIN latest_ookla so ON so.hk_ookla_tile = lo.hk_ookla_tile
  GROUP BY lo.hk_wilayah
),
menara_agg AS (
  SELECT
    hk_wilayah,
    COUNT(*)::int AS menara_total_count,
    COUNT(*) FILTER (WHERE UPPER(COALESCE(radio, '')) IN ('LTE', 'NR', '5G'))::int AS menara_lte_5g_count
  FROM bv.link_menara_wilayah
  GROUP BY hk_wilayah
),
latest_prov_detail AS (
  SELECT DISTINCT ON (hk_provinsi) hk_provinsi, adm1_pcode_2020, is_papua_split_prov
  FROM vault.sat_provinsi_detail
  ORDER BY hk_provinsi, load_date DESC
),
latest_pop_isp AS (
  SELECT DISTINCT ON (hk_provinsi) hk_provinsi, sebaran_pop_isp
  FROM vault.sat_provinsi_pop_isp
  ORDER BY hk_provinsi, tahun DESC, load_date DESC
),
prov_pop_resolved AS (
  SELECT
    pd.hk_provinsi,
    COALESCE(direct_pop.sebaran_pop_isp, parent_pop.sebaran_pop_isp) AS prov_pop_isp_count,
    (direct_pop.sebaran_pop_isp IS NULL AND parent_pop.sebaran_pop_isp IS NOT NULL) AS pop_isp_is_parent_fallback
  FROM latest_prov_detail pd
  LEFT JOIN latest_pop_isp direct_pop ON direct_pop.hk_provinsi = pd.hk_provinsi
  LEFT JOIN latest_prov_detail parent_pd
    ON parent_pd.adm1_pcode_2020 = pd.adm1_pcode_2020
   AND parent_pd.is_papua_split_prov = false
  LEFT JOIN latest_pop_isp parent_pop ON parent_pop.hk_provinsi = parent_pd.hk_provinsi
)
INSERT INTO bv.sat_bv_wilayah_network (
  hk_wilayah, ookla_tile_count, ookla_total_tests, ookla_total_devices,
  ookla_avg_d_mbps, ookla_avg_u_mbps, ookla_avg_lat_ms,
  menara_total_count, menara_lte_5g_count, menara_lte_5g_share_pct, menara_density_per_100km2,
  prov_pop_isp_count, pop_isp_is_parent_fallback
)
SELECT
  hw.hk_wilayah,
  COALESCE(oa.ookla_tile_count, 0),
  COALESCE(oa.ookla_total_tests, 0),
  COALESCE(oa.ookla_total_devices, 0),
  oa.ookla_avg_d_mbps,
  oa.ookla_avg_u_mbps,
  oa.ookla_avg_lat_ms,
  COALESCE(ma.menara_total_count, 0),
  COALESCE(ma.menara_lte_5g_count, 0),
  CASE WHEN COALESCE(ma.menara_total_count, 0) > 0
       THEN ROUND((ma.menara_lte_5g_count::numeric / ma.menara_total_count) * 100.0, 2)
       ELSE 0 END,
  CASE WHEN COALESCE(lg.area_sqkm, 0) > 0
       THEN ROUND((COALESCE(ma.menara_total_count, 0)::numeric / lg.area_sqkm) * 100.0, 3)
       ELSE 0 END,
  pr.prov_pop_isp_count,
  COALESCE(pr.pop_isp_is_parent_fallback, false)
FROM vault.hub_wilayah hw
LEFT JOIN latest_geom lg ON lg.hk_wilayah = hw.hk_wilayah
LEFT JOIN ookla_agg oa ON oa.hk_wilayah = hw.hk_wilayah
LEFT JOIN menara_agg ma ON ma.hk_wilayah = hw.hk_wilayah
LEFT JOIN vault.link_wilayah_provinsi lwp ON lwp.hk_wilayah = hw.hk_wilayah
LEFT JOIN prov_pop_resolved pr ON pr.hk_provinsi = lwp.hk_provinsi;

-- -----------------------------------------------------------------------------
-- 10. Business Satellite Pilar 4: ENVIRONMENT (SRC-04 + BMKG + IKLH + Penduduk)
-- -----------------------------------------------------------------------------
WITH params AS (
  SELECT MAX(CASE WHEN param_key = 'assessment_year' THEN param_value END)::int AS target_year
  FROM ops.scoring_parameters
),
latest_fitur AS (
  SELECT DISTINCT ON (hk_wilayah)
    hk_wilayah, t2m_mean, rh2m_mean, prectotcorr_mean,
    elevation_mean_m, elevation_std_m, allsky_sfc_sw_dwn_mean, wind_speed_100m_mean_ms
  FROM vault.sat_wilayah_fitur
  ORDER BY hk_wilayah, load_date DESC
),
w_centroid AS (
  SELECT DISTINCT ON (hk_wilayah)
    hk_wilayah,
    COALESCE(
      CASE WHEN center_lon IS NOT NULL AND center_lat IS NOT NULL
           THEN ST_SetSRID(ST_MakePoint(center_lon::double precision, center_lat::double precision), 4326) END,
      ST_PointOnSurface(geom)
    ) AS c_geom
  FROM vault.sat_wilayah_geom
  ORDER BY hk_wilayah, load_date DESC
),
latest_stasiun AS (
  SELECT DISTINCT ON (hk_stasiun) hk_stasiun, geom
  FROM vault.sat_stasiun_detail
  WHERE geom IS NOT NULL
  ORDER BY hk_stasiun, load_date DESC
),
stasiun_climate AS (
  SELECT
    hk_stasiun,
    AVG(tavg) AS tavg_c,
    AVG(tx) AS tx_avg_c,
    AVG(rh_avg) AS rh_avg_pct,
    AVG(rr) AS rr_avg_mm
  FROM (
    SELECT DISTINCT ON (hk_stasiun, obs_date) hk_stasiun, obs_date, tavg, tx, rh_avg, rr
    FROM vault.sat_iklim_harian
    ORDER BY hk_stasiun, obs_date, load_date DESC
  ) d
  GROUP BY hk_stasiun
),
local_bmkg AS (
  SELECT
    lsw.hk_wilayah,
    COUNT(DISTINCT lsw.hk_stasiun)::int AS stn_cnt,
    ROUND(AVG(sc.tavg_c)::numeric, 2) AS tavg_c,
    ROUND(AVG(sc.tx_avg_c)::numeric, 2) AS tx_avg_c,
    ROUND(AVG(sc.rh_avg_pct)::numeric, 2) AS rh_avg_pct,
    ROUND(AVG(sc.rr_avg_mm)::numeric, 2) AS rr_avg_mm
  FROM vault.link_stasiun_wilayah lsw
  JOIN stasiun_climate sc ON sc.hk_stasiun = lsw.hk_stasiun
  GROUP BY lsw.hk_wilayah
),
latest_iklh AS (
  SELECT DISTINCT ON (i.hk_provinsi)
    i.hk_provinsi,
    i.tahun,
    i.iku_udara,
    i.ika_air,
    i.iktl_tutupan,
    i.ikl_lahan,
    ROUND((
      (COALESCE(i.iku_udara, 0) + COALESCE(i.ika_air, 0) + COALESCE(i.iktl_tutupan, i.ikl_lahan, 0)) /
      NULLIF((CASE WHEN i.iku_udara IS NOT NULL THEN 1 ELSE 0 END)
           + (CASE WHEN i.ika_air IS NOT NULL THEN 1 ELSE 0 END)
           + (CASE WHEN COALESCE(i.iktl_tutupan, i.ikl_lahan) IS NOT NULL THEN 1 ELSE 0 END), 0)
    )::numeric, 2) AS avg_score
  FROM vault.sat_provinsi_iklh i
  CROSS JOIN params p
  WHERE i.tahun <= p.target_year
  ORDER BY i.hk_provinsi, i.tahun DESC, i.load_date DESC
),
latest_penduduk AS (
  SELECT DISTINCT ON (pp.hk_provinsi)
    pp.hk_provinsi,
    pp.tahun,
    pp.jumlah_penduduk_ribu,
    pp.kepadatan_per_km2
  FROM vault.sat_provinsi_penduduk pp
  CROSS JOIN params p
  WHERE pp.tahun <= p.target_year
    AND pp.jumlah_penduduk_ribu IS NOT NULL
  ORDER BY pp.hk_provinsi, pp.tahun DESC, pp.load_date DESC
)
INSERT INTO bv.sat_bv_wilayah_environment (
  hk_wilayah, t2m_mean_c, rh2m_mean_pct, prectotcorr_mean_mm,
  elevation_mean_m, elevation_std_m, solar_sw_dwn_mean, wind_speed_100m_ms,
  bmkg_station_count, bmkg_match_method, bmkg_nearest_station_km,
  bmkg_tavg_c, bmkg_tx_avg_c, bmkg_rh_avg_pct, bmkg_rr_avg_mm,
  prov_iklh_year, prov_iku_udara, prov_ika_air, prov_iktl_tutupan, prov_ikl_lahan, prov_iklh_avg_score,
  prov_penduduk_year, prov_penduduk_ribu, prov_kepadatan_km2
)
SELECT
  hw.hk_wilayah,
  lf.t2m_mean,
  lf.rh2m_mean,
  lf.prectotcorr_mean,
  lf.elevation_mean_m,
  lf.elevation_std_m,
  lf.allsky_sfc_sw_dwn_mean,
  lf.wind_speed_100m_mean_ms,
  COALESCE(lb.stn_cnt, 0),
  CASE WHEN lb.stn_cnt IS NOT NULL THEN 'IN_WILAYAH'
       WHEN ns.dist_km IS NOT NULL THEN 'NEAREST_STATION'
       ELSE 'NONE' END,
  CASE WHEN lb.stn_cnt IS NOT NULL THEN 0.000 ELSE ns.dist_km END,
  COALESCE(lb.tavg_c, ns.tavg_c),
  COALESCE(lb.tx_avg_c, ns.tx_avg_c),
  COALESCE(lb.rh_avg_pct, ns.rh_avg_pct),
  COALESCE(lb.rr_avg_mm, ns.rr_avg_mm),
  ik.tahun,
  ik.iku_udara,
  ik.ika_air,
  ik.iktl_tutupan,
  ik.ikl_lahan,
  ik.avg_score,
  pd.tahun,
  pd.jumlah_penduduk_ribu,
  pd.kepadatan_per_km2
FROM vault.hub_wilayah hw
LEFT JOIN latest_fitur lf ON lf.hk_wilayah = hw.hk_wilayah
LEFT JOIN w_centroid wc ON wc.hk_wilayah = hw.hk_wilayah
LEFT JOIN local_bmkg lb ON lb.hk_wilayah = hw.hk_wilayah
LEFT JOIN LATERAL (
  SELECT
    ROUND((ST_Distance(wc.c_geom::geography, ls.geom::geography) / 1000.0)::numeric, 3) AS dist_km,
    ROUND(sc.tavg_c::numeric, 2) AS tavg_c,
    ROUND(sc.tx_avg_c::numeric, 2) AS tx_avg_c,
    ROUND(sc.rh_avg_pct::numeric, 2) AS rh_avg_pct,
    ROUND(sc.rr_avg_mm::numeric, 2) AS rr_avg_mm
  FROM latest_stasiun ls
  JOIN stasiun_climate sc ON sc.hk_stasiun = ls.hk_stasiun
  ORDER BY wc.c_geom <-> ls.geom
  LIMIT 1
) ns ON lb.stn_cnt IS NULL AND wc.c_geom IS NOT NULL
LEFT JOIN vault.link_wilayah_provinsi lwp ON lwp.hk_wilayah = hw.hk_wilayah
LEFT JOIN latest_iklh ik ON ik.hk_provinsi = lwp.hk_provinsi
LEFT JOIN latest_penduduk pd ON pd.hk_provinsi = lwp.hk_provinsi;