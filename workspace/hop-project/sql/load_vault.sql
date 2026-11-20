-- =============================================================================
-- load_vault.sql
-- Loader Insert-Only Raw Data Vault 2.0 (9 Hub, 3 Link, 14 Satellite)
-- Idempotent: aman dijalankan berulang kali (tidak menggandakan baris)
-- =============================================================================

-- ------------------------- 1. HUBS -------------------------
INSERT INTO vault.hub_provinsi (hk_provinsi, bps_prov_code, record_source)
SELECT md5(UPPER(TRIM(bps_prov_code))), bps_prov_code, 'mdm.provinsi_crosswalk'
FROM mdm.provinsi_crosswalk
ON CONFLICT (hk_provinsi) DO NOTHING;

INSERT INTO vault.hub_wilayah (hk_wilayah, bps_kabkota_code, record_source)
SELECT md5(UPPER(TRIM(bps_kabkota_code))), bps_kabkota_code, 'mdm.wilayah_crosswalk'
FROM mdm.wilayah_crosswalk
ON CONFLICT (hk_wilayah) DO NOTHING;

INSERT INTO vault.hub_gempa (hk_gempa, event_id, record_source)
SELECT DISTINCT md5(UPPER(TRIM(event_id))), TRIM(event_id), 'stg.src_01_bmkg_gempa'
FROM stg.src_01_bmkg_gempa
WHERE event_id IS NOT NULL
ON CONFLICT (hk_gempa) DO NOTHING;

INSERT INTO vault.hub_bencana (hk_bencana, bencana_bk, record_source)
SELECT DISTINCT
  md5(bk), bk, 'stg.src_02_bnpb_bencana'
FROM (
  SELECT md5(concat_ws('|',
    coalesce(city_id,''), coalesce(date::text,''), coalesce(disaster_type,''),
    coalesce(city,''), coalesce(province,''), coalesce(cause,''),
    coalesce(death::text,''), coalesce(missing_person::text,''),
    coalesce(injured_person::text,''), coalesce(damaged_house::text,''),
    coalesce(flooded_house::text,''), coalesce(damaged_facility::text,'')
  )) AS bk
  FROM stg.src_02_bnpb_bencana
) s
ON CONFLICT (hk_bencana) DO NOTHING;

INSERT INTO vault.hub_stasiun (hk_stasiun, station_id, record_source)
SELECT DISTINCT md5(UPPER(TRIM(station_id))), TRIM(station_id), 'stg.src_03_iklim_stasiun'
FROM stg.src_03_iklim_stasiun
WHERE station_id IS NOT NULL
ON CONFLICT (hk_stasiun) DO NOTHING;

INSERT INTO vault.hub_pembangkit (hk_pembangkit, gppd_idnr, record_source)
SELECT DISTINCT md5(UPPER(TRIM(gppd_idnr))), TRIM(gppd_idnr), 'stg.src_07_gppd'
FROM stg.src_07_gppd
WHERE gppd_idnr IS NOT NULL
ON CONFLICT (hk_pembangkit) DO NOTHING;

INSERT INTO vault.hub_gardu (hk_gardu, osm_id, record_source)
SELECT DISTINCT md5(UPPER(TRIM(id))), TRIM(id), 'stg.src_08_osm_gardu'
FROM stg.src_08_osm_gardu
WHERE id IS NOT NULL
ON CONFLICT (hk_gardu) DO NOTHING;

INSERT INTO vault.hub_menara (hk_menara, menara_bk, record_source)
SELECT DISTINCT
  md5(UPPER(bk)), UPPER(bk), 'stg.src_05_opencellid'
FROM (
  SELECT concat_ws('|', coalesce(radio,''), coalesce(net,''), coalesce(area,''), coalesce(cell,'')) AS bk
  FROM stg.src_05_opencellid
  WHERE radio IS NOT NULL AND cell IS NOT NULL
) s
ON CONFLICT (hk_menara) DO NOTHING;

INSERT INTO vault.hub_ookla_tile (hk_ookla_tile, quadkey, record_source)
SELECT DISTINCT md5(UPPER(TRIM(quadkey))), TRIM(quadkey), 'stg.src_06_ookla_tiles'
FROM stg.src_06_ookla_tiles
WHERE quadkey IS NOT NULL
ON CONFLICT (hk_ookla_tile) DO NOTHING;

-- ------------------------- 2. LINKS ADMINISTRATIF -------------------------
INSERT INTO vault.link_wilayah_provinsi (hk_link_wilayah_provinsi, hk_wilayah, hk_provinsi, record_source)
SELECT
  md5(md5(UPPER(TRIM(bps_kabkota_code))) || '|' || md5(UPPER(TRIM(bps_prov_code)))),
  md5(UPPER(TRIM(bps_kabkota_code))),
  md5(UPPER(TRIM(bps_prov_code))),
  'mdm.wilayah_crosswalk'
FROM mdm.wilayah_crosswalk
ON CONFLICT (hk_link_wilayah_provinsi) DO NOTHING;

INSERT INTO vault.link_bencana_wilayah (hk_link_bencana_wilayah, hk_bencana, hk_wilayah, record_source)
SELECT DISTINCT
  md5(hk_b || '|' || hk_w), hk_b, hk_w, 'stg.src_02_bnpb_bencana'
FROM (
  SELECT
    md5(md5(concat_ws('|',
      coalesce(city_id,''), coalesce(date::text,''), coalesce(disaster_type,''),
      coalesce(city,''), coalesce(province,''), coalesce(cause,''),
      coalesce(death::text,''), coalesce(missing_person::text,''),
      coalesce(injured_person::text,''), coalesce(damaged_house::text,''),
      coalesce(flooded_house::text,''), coalesce(damaged_facility::text,'')
    ))) AS hk_b,
    md5(UPPER(TRIM(mdm.resolve_bps_kabkota('SRC-02', city, province)))) AS hk_w
  FROM stg.src_02_bnpb_bencana
) s
WHERE hk_w IS NOT NULL
ON CONFLICT (hk_link_bencana_wilayah) DO NOTHING;

INSERT INTO vault.link_stasiun_wilayah (hk_link_stasiun_wilayah, hk_stasiun, hk_wilayah, record_source)
SELECT DISTINCT
  md5(hk_s || '|' || hk_w), hk_s, hk_w, 'stg.src_03_iklim_stasiun'
FROM (
  SELECT
    md5(UPPER(TRIM(station_id))) AS hk_s,
    md5(UPPER(TRIM(mdm.resolve_bps_kabkota('SRC-03', region_name, NULL)))) AS hk_w
  FROM stg.src_03_iklim_stasiun
  WHERE station_id IS NOT NULL
) s
WHERE hk_w IS NOT NULL
ON CONFLICT (hk_link_stasiun_wilayah) DO NOTHING;

-- ------------------------- 3. SATELLITES (INSERT-ONLY BY HASHDIFF) -------------------------

-- 3.1 sat_provinsi_detail
WITH src AS (
  SELECT
    md5(UPPER(TRIM(bps_prov_code))) AS hk_provinsi,
    md5(concat_ws('|', coalesce(prov_name_canonical,''), coalesce(adm1_pcode_2020,''), coalesce(is_papua_split_prov::text,''))) AS hashdiff,
    prov_name_canonical, adm1_pcode_2020, is_papua_split_prov
  FROM mdm.provinsi_crosswalk
)
INSERT INTO vault.sat_provinsi_detail (hk_provinsi, hashdiff, record_source, prov_name_canonical, adm1_pcode_2020, is_papua_split_prov)
SELECT s.hk_provinsi, s.hashdiff, 'mdm.provinsi_crosswalk', s.prov_name_canonical, s.adm1_pcode_2020, s.is_papua_split_prov
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_provinsi_detail t WHERE t.hk_provinsi = s.hk_provinsi AND t.hashdiff = s.hashdiff);

-- 3.2 sat_provinsi_pop_isp (SRC-09)
WITH src AS (
  SELECT DISTINCT ON (pw.bps_prov_code, s.tahun)
    md5(UPPER(TRIM(pw.bps_prov_code))) AS hk_provinsi,
    s.tahun::integer AS tahun,
    md5(concat_ws('|', coalesce(s.sebaran_pop_isp::text,''), coalesce(s.source,''))) AS hashdiff,
    s.sebaran_pop_isp::integer AS sebaran_pop_isp,
    s.source AS source_url
  FROM stg.src_09_pop_isp s
  JOIN mdm.provinsi_crosswalk pw ON mdm.norm_wilayah(s.provinsi, 'prov') = pw.prov_name_norm
  WHERE s.tahun IS NOT NULL
  ORDER BY pw.bps_prov_code, s.tahun, s._row_no
)
INSERT INTO vault.sat_provinsi_pop_isp (hk_provinsi, tahun, hashdiff, record_source, sebaran_pop_isp, source_url)
SELECT s.hk_provinsi, s.tahun, s.hashdiff, 'stg.src_09_pop_isp', s.sebaran_pop_isp, s.source_url
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_provinsi_pop_isp t WHERE t.hk_provinsi = s.hk_provinsi AND t.tahun = s.tahun AND t.hashdiff = s.hashdiff);

-- 3.3 sat_provinsi_iklh (SRC-10)
WITH src AS (
  SELECT DISTINCT ON (pw.bps_prov_code, s.tahun)
    md5(UPPER(TRIM(pw.bps_prov_code))) AS hk_provinsi,
    s.tahun::integer AS tahun,
    md5(concat_ws('|',
      coalesce(s.indeks_kualitas_udara::text,''), coalesce(s.indeks_kualitas_air::text,''),
      coalesce(s.indeks_kualitas_tutupan_lahan_iktl::text,''), coalesce(s.indeks_kualitas_lahan_ikl::text,''),
      coalesce(s.indeks_kualitas_ekosistem_gambut_ikeg::text,''), coalesce(s.indeks_kualitas_air_laut_ikal::text,'')
    )) AS hashdiff,
    s.indeks_kualitas_udara, s.indeks_kualitas_air,
    s.indeks_kualitas_tutupan_lahan_iktl, s.indeks_kualitas_lahan_ikl,
    s.indeks_kualitas_ekosistem_gambut_ikeg, s.indeks_kualitas_air_laut_ikal
  FROM stg.src_10_iklh_provinsi s
  JOIN mdm.provinsi_crosswalk pw ON mdm.norm_wilayah(s.provinsi, 'prov') = pw.prov_name_norm
  WHERE s.tahun IS NOT NULL
  ORDER BY pw.bps_prov_code, s.tahun, s._row_no
)
INSERT INTO vault.sat_provinsi_iklh (hk_provinsi, tahun, hashdiff, record_source, iku_udara, ika_air, iktl_tutupan, ikl_lahan, ikeg_gambut, ikal_air_laut)
SELECT s.hk_provinsi, s.tahun, s.hashdiff, 'stg.src_10_iklh_provinsi',
       s.indeks_kualitas_udara, s.indeks_kualitas_air,
       s.indeks_kualitas_tutupan_lahan_iktl, s.indeks_kualitas_lahan_ikl,
       s.indeks_kualitas_ekosistem_gambut_ikeg, s.indeks_kualitas_air_laut_ikal
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_provinsi_iklh t WHERE t.hk_provinsi = s.hk_provinsi AND t.tahun = s.tahun AND t.hashdiff = s.hashdiff);

-- 3.4 sat_provinsi_penduduk (SRC-12)
WITH src AS (
  SELECT DISTINCT ON (pw.bps_prov_code, s.tahun)
    md5(UPPER(TRIM(pw.bps_prov_code))) AS hk_provinsi,
    s.tahun::integer AS tahun,
    md5(concat_ws('|',
      coalesce(s.jumlah_penduduk_ribu::text,''), coalesce(s.laju_pertumbuhan_penduduk_per_tahun::text,''),
      coalesce(s.persentase_penduduk::text,''), coalesce(s.kepadatan_penduduk_per_km_persegi_km2::text,''),
      coalesce(s.rasio_jenis_kelamin_penduduk::text,'')
    )) AS hashdiff,
    s.jumlah_penduduk_ribu, s.laju_pertumbuhan_penduduk_per_tahun,
    s.persentase_penduduk, s.kepadatan_penduduk_per_km_persegi_km2,
    s.rasio_jenis_kelamin_penduduk
  FROM stg.src_12_penduduk_provinsi s
  JOIN mdm.provinsi_crosswalk pw ON mdm.norm_wilayah(s.provinsi, 'prov') = pw.prov_name_norm
  WHERE s.tahun IS NOT NULL
  ORDER BY pw.bps_prov_code, s.tahun, s._row_no
)
INSERT INTO vault.sat_provinsi_penduduk (hk_provinsi, tahun, hashdiff, record_source, jumlah_penduduk_ribu, laju_pertumbuhan_pct, persentase_penduduk, kepadatan_per_km2, rasio_jenis_kelamin)
SELECT s.hk_provinsi, s.tahun, s.hashdiff, 'stg.src_12_penduduk_provinsi',
       s.jumlah_penduduk_ribu, s.laju_pertumbuhan_penduduk_per_tahun,
       s.persentase_penduduk, s.kepadatan_penduduk_per_km_persegi_km2,
       s.rasio_jenis_kelamin_penduduk
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_provinsi_penduduk t WHERE t.hk_provinsi = s.hk_provinsi AND t.tahun = s.tahun AND t.hashdiff = s.hashdiff);

-- 3.5 sat_wilayah_fitur (SRC-04)
WITH src AS (
  SELECT DISTINCT ON (bps_kabkota_code)
    md5(UPPER(TRIM(bps_kabkota_code))) AS hk_wilayah,
    md5(concat_ws('|',
      coalesce(ipm_2024::text,''), coalesce(ppm_2024::text,''), coalesce(population_2024::text,''),
      coalesce(ntl_radiance_mean::text,''), coalesce(elevation_mean_m::text,''),
      coalesce(t2m_mean::text,''), coalesce(rh2m_mean::text,''), coalesce(prectotcorr_mean::text,''),
      coalesce(road_density_km_per_km2::text,''), coalesce(dist_to_primary_trunk_km::text,'')
    )) AS hashdiff,
    kabkota_name, prov_name, ipm_2023, ipm_2024, ppm_2023, ppm_2024,
    population_2023, population_2024, ntl_radiance_mean, elevation_mean_m, elevation_std_m,
    pct_built_up, pct_water, pct_wetland, pct_tree_cover, tertinggal_status, is_tertinggal,
    allsky_sfc_sw_dwn_mean, t2m_mean, rh2m_mean, prectotcorr_mean, ws10m_mean, ws50m_mean,
    wind_speed_100m_mean_ms, road_length_km, road_density_km_per_km2, dist_to_primary_trunk_km
  FROM stg.src_04_fitur_kabkota
  WHERE bps_kabkota_code IS NOT NULL
  ORDER BY bps_kabkota_code, _row_no
)
INSERT INTO vault.sat_wilayah_fitur (
  hk_wilayah, hashdiff, record_source, kabkota_name, prov_name, ipm_2023, ipm_2024, ppm_2023, ppm_2024,
  population_2023, population_2024, ntl_radiance_mean, elevation_mean_m, elevation_std_m,
  pct_built_up, pct_water, pct_wetland, pct_tree_cover, tertinggal_status, is_tertinggal,
  allsky_sfc_sw_dwn_mean, t2m_mean, rh2m_mean, prectotcorr_mean, ws10m_mean, ws50m_mean,
  wind_speed_100m_mean_ms, road_length_km, road_density_km_per_km2, dist_to_primary_trunk_km
)
SELECT
  s.hk_wilayah, s.hashdiff, 'stg.src_04_fitur_kabkota', s.kabkota_name, s.prov_name, s.ipm_2023, s.ipm_2024, s.ppm_2023, s.ppm_2024,
  s.population_2023, s.population_2024, s.ntl_radiance_mean, s.elevation_mean_m, s.elevation_std_m,
  s.pct_built_up, s.pct_water, s.pct_wetland, s.pct_tree_cover, s.tertinggal_status, s.is_tertinggal,
  s.allsky_sfc_sw_dwn_mean, s.t2m_mean, s.rh2m_mean, s.prectotcorr_mean, s.ws10m_mean, s.ws50m_mean,
  s.wind_speed_100m_mean_ms, s.road_length_km, s.road_density_km_per_km2, s.dist_to_primary_trunk_km
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_wilayah_fitur t WHERE t.hk_wilayah = s.hk_wilayah AND t.hashdiff = s.hashdiff);

-- 3.6 sat_wilayah_geom (SRC-11 ADM2 via mdm.wilayah_crosswalk -> 514 wilayah kanonik)
WITH src AS (
  SELECT DISTINCT ON (w.bps_kabkota_code)
    md5(UPPER(TRIM(w.bps_kabkota_code))) AS hk_wilayah,
    md5(concat_ws('|', coalesce(a.adm2_pcode,''), coalesce(a.area_sqkm::text,''), coalesce(ST_NPoints(a.geom)::text,''))) AS hashdiff,
    a.adm2_pcode, a.adm2_name, a.adm1_pcode, a.area_sqkm, a.center_lat, a.center_lon, a.geom
  FROM mdm.wilayah_crosswalk w
  JOIN stg.src_11_adm2 a ON a.adm2_pcode = w.adm2_pcode
  ORDER BY w.bps_kabkota_code, a._row_no
)
INSERT INTO vault.sat_wilayah_geom (hk_wilayah, hashdiff, record_source, adm2_pcode, adm2_name, adm1_pcode, area_sqkm, center_lat, center_lon, geom)
SELECT s.hk_wilayah, s.hashdiff, 'stg.src_11_adm2', s.adm2_pcode, s.adm2_name, s.adm1_pcode, s.area_sqkm, s.center_lat, s.center_lon, s.geom
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_wilayah_geom t WHERE t.hk_wilayah = s.hk_wilayah AND t.hashdiff = s.hashdiff);

-- 3.7 sat_gempa_detail (SRC-01)
WITH src AS (
  SELECT DISTINCT ON (event_id)
    md5(UPPER(TRIM(event_id))) AS hk_gempa,
    md5(concat_ws('|', coalesce(date::text,''), coalesce(time_utc,''), coalesce(latitude::text,''), coalesce(longitude::text,''), coalesce(magnitude::text,''), coalesce(depth_km::text,''))) AS hashdiff,
    date AS event_date, time_utc, latitude, longitude, magnitude, mag_type, depth_km, source AS source_net, geom
  FROM stg.src_01_bmkg_gempa
  WHERE event_id IS NOT NULL
  ORDER BY event_id, _row_no
)
INSERT INTO vault.sat_gempa_detail (hk_gempa, hashdiff, record_source, event_date, time_utc, latitude, longitude, magnitude, mag_type, depth_km, source_net, geom)
SELECT s.hk_gempa, s.hashdiff, 'stg.src_01_bmkg_gempa', s.event_date, s.time_utc, s.latitude, s.longitude, s.magnitude, s.mag_type, s.depth_km, s.source_net, s.geom
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_gempa_detail t WHERE t.hk_gempa = s.hk_gempa AND t.hashdiff = s.hashdiff);

-- 3.8 sat_bencana_detail (SRC-02)
WITH src AS (
  SELECT DISTINCT ON (bk)
    md5(bk) AS hk_bencana,
    bk AS hashdiff,
    date AS event_date, disaster_type, city AS city_raw, province AS province_raw, cause,
    death, missing_person, injured_person, damaged_house, flooded_house, damaged_facility
  FROM (
    SELECT *,
      md5(concat_ws('|',
        coalesce(city_id,''), coalesce(date::text,''), coalesce(disaster_type,''),
        coalesce(city,''), coalesce(province,''), coalesce(cause,''),
        coalesce(death::text,''), coalesce(missing_person::text,''),
        coalesce(injured_person::text,''), coalesce(damaged_house::text,''),
        coalesce(flooded_house::text,''), coalesce(damaged_facility::text,'')
      )) AS bk
    FROM stg.src_02_bnpb_bencana
  ) x
  ORDER BY bk, _row_no
)
INSERT INTO vault.sat_bencana_detail (hk_bencana, hashdiff, record_source, event_date, disaster_type, city_raw, province_raw, cause, death, missing_person, injured_person, damaged_house, flooded_house, damaged_facility)
SELECT s.hk_bencana, s.hashdiff, 'stg.src_02_bnpb_bencana', s.event_date, s.disaster_type, s.city_raw, s.province_raw, s.cause,
       s.death, s.missing_person, s.injured_person, s.damaged_house, s.flooded_house, s.damaged_facility
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_bencana_detail t WHERE t.hk_bencana = s.hk_bencana AND t.hashdiff = s.hashdiff);

-- 3.9 sat_stasiun_detail (SRC-03 stasiun)
WITH src AS (
  SELECT DISTINCT ON (station_id)
    md5(UPPER(TRIM(station_id))) AS hk_stasiun,
    md5(concat_ws('|', coalesce(station_name,''), coalesce(region_name,''), coalesce(latitude::text,''), coalesce(longitude::text,''))) AS hashdiff,
    station_name, region_name, latitude, longitude, geom
  FROM stg.src_03_iklim_stasiun
  WHERE station_id IS NOT NULL
  ORDER BY station_id, _row_no
)
INSERT INTO vault.sat_stasiun_detail (hk_stasiun, hashdiff, record_source, station_name, region_name, latitude, longitude, geom)
SELECT s.hk_stasiun, s.hashdiff, 'stg.src_03_iklim_stasiun', s.station_name, s.region_name, s.latitude, s.longitude, s.geom
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_stasiun_detail t WHERE t.hk_stasiun = s.hk_stasiun AND t.hashdiff = s.hashdiff);

-- 3.10 sat_iklim_harian (SRC-03 climate_data, satellite dengan obs_date sesuai D4)
WITH src AS (
  SELECT DISTINCT ON (s.station_id, s.date)
    md5(UPPER(TRIM(s.station_id))) AS hk_stasiun,
    s.date AS obs_date,
    md5(concat_ws('|', coalesce(s.tn::text,''), coalesce(s.tx::text,''), coalesce(s.tavg::text,''), coalesce(s.rh_avg::text,''), coalesce(s.rr::text,''), coalesce(s.ss::text,''))) AS hashdiff,
    s.tn, s.tx, s.tavg, s.rh_avg, s.rr, s.ss, s.ff_x, s.ddd_x, s.ff_avg, s.ddd_car
  FROM stg.src_03_iklim_harian s
  JOIN vault.hub_stasiun h ON h.hk_stasiun = md5(UPPER(TRIM(s.station_id)))
  WHERE s.station_id IS NOT NULL AND s.date IS NOT NULL
  ORDER BY s.station_id, s.date, s._row_no
)
INSERT INTO vault.sat_iklim_harian (hk_stasiun, obs_date, hashdiff, record_source, tn, tx, tavg, rh_avg, rr, ss, ff_x, ddd_x, ff_avg, ddd_car)
SELECT s.hk_stasiun, s.obs_date, s.hashdiff, 'stg.src_03_iklim_harian', s.tn, s.tx, s.tavg, s.rh_avg, s.rr, s.ss, s.ff_x, s.ddd_x, s.ff_avg, s.ddd_car
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_iklim_harian t WHERE t.hk_stasiun = s.hk_stasiun AND t.obs_date = s.obs_date AND t.hashdiff = s.hashdiff);

-- 3.11 sat_pembangkit_detail (SRC-07)
WITH src AS (
  SELECT DISTINCT ON (gppd_idnr)
    md5(UPPER(TRIM(gppd_idnr))) AS hk_pembangkit,
    md5(concat_ws('|', coalesce(name,''), coalesce(capacity_mw::text,''), coalesce(primary_fuel,''), coalesce(commissioning_year::text,''), coalesce(owner,''))) AS hashdiff,
    name AS plant_name, capacity_mw, primary_fuel, other_fuel1, commissioning_year, owner, latitude, longitude, geom
  FROM stg.src_07_gppd
  WHERE gppd_idnr IS NOT NULL
  ORDER BY gppd_idnr, _row_no
)
INSERT INTO vault.sat_pembangkit_detail (hk_pembangkit, hashdiff, record_source, plant_name, capacity_mw, primary_fuel, other_fuel1, commissioning_year, owner, latitude, longitude, geom)
SELECT s.hk_pembangkit, s.hashdiff, 'stg.src_07_gppd', s.plant_name, s.capacity_mw, s.primary_fuel, s.other_fuel1, s.commissioning_year, s.owner, s.latitude, s.longitude, s.geom
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_pembangkit_detail t WHERE t.hk_pembangkit = s.hk_pembangkit AND t.hashdiff = s.hashdiff);

-- 3.12 sat_gardu_detail (SRC-08 + parsing tegangan baku ke kV sesuai D9)
WITH src AS (
  SELECT DISTINCT ON (s.id)
    md5(UPPER(TRIM(s.id))) AS hk_gardu,
    md5(concat_ws('|', coalesce(s.name,''), coalesce(s.substation,''), coalesce(s.voltage,''), coalesce(s.operator,''))) AS hashdiff,
    s.name AS gardu_name,
    s.substation,
    s.voltage AS voltage_raw,
    (
      SELECT MAX(m[1]::numeric) / 1000.0
      FROM regexp_matches(COALESCE(s.voltage, ''), '([0-9]{4,7})', 'g') AS m
    ) AS voltage_max_kv,
    s.operator,
    s.latitude,
    s.longitude,
    s.geom
  FROM stg.src_08_osm_gardu s
  WHERE s.id IS NOT NULL
  ORDER BY s.id, s._row_no
)
INSERT INTO vault.sat_gardu_detail (hk_gardu, hashdiff, record_source, gardu_name, substation, voltage_raw, voltage_max_kv, operator, latitude, longitude, geom)
SELECT s.hk_gardu, s.hashdiff, 'stg.src_08_osm_gardu', s.gardu_name, s.substation, s.voltage_raw, s.voltage_max_kv, s.operator, s.latitude, s.longitude, s.geom
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_gardu_detail t WHERE t.hk_gardu = s.hk_gardu AND t.hashdiff = s.hashdiff);

-- 3.13 sat_menara_detail (SRC-05)
WITH src AS (
  SELECT DISTINCT ON (bk)
    md5(UPPER(bk)) AS hk_menara,
    md5(concat_ws('|', coalesce(range::text,''), coalesce(samples::text,''), coalesce(lat::text,''), coalesce(lon::text,''))) AS hashdiff,
    radio, mcc, net, area, cell, range AS range_m, samples, created AS created_at, updated AS updated_at, lat AS latitude, lon AS longitude, geom
  FROM (
    SELECT *, concat_ws('|', coalesce(radio,''), coalesce(net,''), coalesce(area,''), coalesce(cell,'')) AS bk
    FROM stg.src_05_opencellid
    WHERE radio IS NOT NULL AND cell IS NOT NULL
  ) x
  ORDER BY bk, _row_no
)
INSERT INTO vault.sat_menara_detail (hk_menara, hashdiff, record_source, radio, mcc, net, area, cell, range_m, samples, created_at, updated_at, latitude, longitude, geom)
SELECT s.hk_menara, s.hashdiff, 'stg.src_05_opencellid', s.radio, s.mcc, s.net, s.area, s.cell, s.range_m, s.samples, s.created_at, s.updated_at, s.latitude, s.longitude, s.geom
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_menara_detail t WHERE t.hk_menara = s.hk_menara AND t.hashdiff = s.hashdiff);

-- 3.14 sat_ookla_detail (SRC-06 + konversi baku kbps -> Mbps sesuai D9)
WITH src AS (
  SELECT DISTINCT ON (quadkey)
    md5(UPPER(TRIM(quadkey))) AS hk_ookla_tile,
    md5(concat_ws('|', coalesce(year::text,''), coalesce(quarter::text,''), coalesce(avg_d_kbps::text,''), coalesce(avg_u_kbps::text,''), coalesce(avg_lat_ms::text,''), coalesce(tests::text,''))) AS hashdiff,
    year::integer AS data_year,
    quarter::integer AS data_quarter,
    ROUND(avg_d_kbps::numeric / 1000.0, 3) AS avg_d_mbps,
    ROUND(avg_u_kbps::numeric / 1000.0, 3) AS avg_u_mbps,
    avg_lat_ms,
    tests::integer AS tests,
    devices::integer AS devices,
    tile_x,
    tile_y,
    geom
  FROM stg.src_06_ookla_tiles
  WHERE quadkey IS NOT NULL
  ORDER BY quadkey, _row_no
)
INSERT INTO vault.sat_ookla_detail (hk_ookla_tile, hashdiff, record_source, data_year, data_quarter, avg_d_mbps, avg_u_mbps, avg_lat_ms, tests, devices, tile_x, tile_y, geom)
SELECT s.hk_ookla_tile, s.hashdiff, 'stg.src_06_ookla_tiles', s.data_year, s.data_quarter, s.avg_d_mbps, s.avg_u_mbps, s.avg_lat_ms, s.tests, s.devices, s.tile_x, s.tile_y, s.geom
FROM src s
WHERE NOT EXISTS (SELECT 1 FROM vault.sat_ookla_detail t WHERE t.hk_ookla_tile = s.hk_ookla_tile AND t.hashdiff = s.hashdiff);