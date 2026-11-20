-- AUTO-DRAFT dari profile_sources.py v3.0. Tinjau sebelum dijalankan.
-- Raw = bentuk asli: semua kolom text. Tipe dibuat di staging.
CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE IF NOT EXISTS raw.src_01_bmkg_gempa (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-01',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    no text,
    event_id text,
    date text,
    time_utc text,
    latitude text,
    longitude text,
    magnitude text,
    mag_type text,
    depth_km text,
    source text,
    source_event_id text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_01_bmkg_gempa IS 'SRC-01 bmkg_earthquake_catalog; contoh file BMKG_Earthquake_Catalog.csv';
COMMENT ON COLUMN raw.src_01_bmkg_gempa.no IS 'sumber: No';
COMMENT ON COLUMN raw.src_01_bmkg_gempa.event_id IS 'sumber: Event ID';
COMMENT ON COLUMN raw.src_01_bmkg_gempa.date IS 'sumber: Date';
COMMENT ON COLUMN raw.src_01_bmkg_gempa.time_utc IS 'sumber: Time (UTC)';
COMMENT ON COLUMN raw.src_01_bmkg_gempa.latitude IS 'sumber: Latitude';
COMMENT ON COLUMN raw.src_01_bmkg_gempa.longitude IS 'sumber: Longitude';
COMMENT ON COLUMN raw.src_01_bmkg_gempa.magnitude IS 'sumber: Magnitude';
COMMENT ON COLUMN raw.src_01_bmkg_gempa.mag_type IS 'sumber: Mag Type';
COMMENT ON COLUMN raw.src_01_bmkg_gempa.depth_km IS 'sumber: Depth (km)';
COMMENT ON COLUMN raw.src_01_bmkg_gempa.source IS 'sumber: Source';
COMMENT ON COLUMN raw.src_01_bmkg_gempa.source_event_id IS 'sumber: Source Event ID';

CREATE TABLE IF NOT EXISTS raw.src_02_bnpb_bencana (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-02',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    city_id text,
    date text,
    disaster_type text,
    city text,
    province text,
    cause text,
    death text,
    missing_person text,
    injured_person text,
    damaged_house text,
    flooded_house text,
    damaged_facility text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_02_bnpb_bencana IS 'SRC-02 data_bencana; contoh file data_bencana.xlsx';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.city_id IS 'sumber: city_id';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.date IS 'sumber: date';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.disaster_type IS 'sumber: disaster_type';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.city IS 'sumber: city';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.province IS 'sumber: province';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.cause IS 'sumber: cause';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.death IS 'sumber: death';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.missing_person IS 'sumber: missing_person';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.injured_person IS 'sumber: injured_person';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.damaged_house IS 'sumber: damaged_house';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.flooded_house IS 'sumber: flooded_house';
COMMENT ON COLUMN raw.src_02_bnpb_bencana.damaged_facility IS 'sumber: damaged_facility';

CREATE TABLE IF NOT EXISTS raw.src_03_iklim_harian (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-03',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    date text,
    tn text,
    tx text,
    tavg text,
    rh_avg text,
    rr text,
    ss text,
    ff_x text,
    ddd_x text,
    ff_avg text,
    ddd_car text,
    station_id text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_03_iklim_harian IS 'SRC-03 climate_data; contoh file climate_data.csv';
COMMENT ON COLUMN raw.src_03_iklim_harian.date IS 'sumber: date';
COMMENT ON COLUMN raw.src_03_iklim_harian.tn IS 'sumber: Tn';
COMMENT ON COLUMN raw.src_03_iklim_harian.tx IS 'sumber: Tx';
COMMENT ON COLUMN raw.src_03_iklim_harian.tavg IS 'sumber: Tavg';
COMMENT ON COLUMN raw.src_03_iklim_harian.rh_avg IS 'sumber: RH_avg';
COMMENT ON COLUMN raw.src_03_iklim_harian.rr IS 'sumber: RR';
COMMENT ON COLUMN raw.src_03_iklim_harian.ss IS 'sumber: ss';
COMMENT ON COLUMN raw.src_03_iklim_harian.ff_x IS 'sumber: ff_x';
COMMENT ON COLUMN raw.src_03_iklim_harian.ddd_x IS 'sumber: ddd_x';
COMMENT ON COLUMN raw.src_03_iklim_harian.ff_avg IS 'sumber: ff_avg';
COMMENT ON COLUMN raw.src_03_iklim_harian.ddd_car IS 'sumber: ddd_car';
COMMENT ON COLUMN raw.src_03_iklim_harian.station_id IS 'sumber: station_id';

CREATE TABLE IF NOT EXISTS raw.src_03_iklim_provinsi (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-03',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    province_id text,
    province_name text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_03_iklim_provinsi IS 'SRC-03 province_detail; contoh file province_detail.csv';
COMMENT ON COLUMN raw.src_03_iklim_provinsi.province_id IS 'sumber: province_id';
COMMENT ON COLUMN raw.src_03_iklim_provinsi.province_name IS 'sumber: province_name';

CREATE TABLE IF NOT EXISTS raw.src_03_iklim_stasiun (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-03',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    station_id text,
    station_name text,
    region_name text,
    latitude text,
    longitude text,
    region_id text,
    province_id text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_03_iklim_stasiun IS 'SRC-03 station_detail; contoh file station_detail.csv';
COMMENT ON COLUMN raw.src_03_iklim_stasiun.station_id IS 'sumber: station_id';
COMMENT ON COLUMN raw.src_03_iklim_stasiun.station_name IS 'sumber: station_name';
COMMENT ON COLUMN raw.src_03_iklim_stasiun.region_name IS 'sumber: region_name';
COMMENT ON COLUMN raw.src_03_iklim_stasiun.latitude IS 'sumber: latitude';
COMMENT ON COLUMN raw.src_03_iklim_stasiun.longitude IS 'sumber: longitude';
COMMENT ON COLUMN raw.src_03_iklim_stasiun.region_id IS 'sumber: region_id';
COMMENT ON COLUMN raw.src_03_iklim_stasiun.province_id IS 'sumber: province_id';

CREATE TABLE IF NOT EXISTS raw.src_04_fitur_kabkota (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-04',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    bps_kabkota_code text,
    kabkota_name text,
    prov_name text,
    shapename text,
    crosswalk_match_type text,
    crosswalk_match_score text,
    ipm_2023 text,
    ipm_2024 text,
    ppm_2023 text,
    ppm_2024 text,
    population_2023 text,
    population_2024 text,
    ntl_radiance_mean text,
    ntl_no_data text,
    elevation_mean_m text,
    elevation_std_m text,
    elevation_no_data text,
    pct_tree_cover text,
    pct_shrubland text,
    pct_grassland text,
    pct_cropland text,
    pct_built_up text,
    pct_bare_sparse_veg text,
    pct_snow_ice text,
    pct_water text,
    pct_wetland text,
    pct_mangroves text,
    pct_moss_lichen text,
    landcover_no_data text,
    tertinggal_status text,
    is_tertinggal text,
    allsky_sfc_sw_dwn_mean text,
    t2m_mean text,
    ws10m_mean text,
    ws50m_mean text,
    rh2m_mean text,
    prectotcorr_mean text,
    solar_zonal_fallback text,
    weather_zonal_fallback text,
    wind_speed_100m_mean_ms text,
    wind_no_data text,
    road_length_km text,
    road_density_km_per_km2 text,
    dist_to_primary_trunk_km text,
    centroid_type text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_04_fitur_kabkota IS 'SRC-04 master_features_v4; contoh file master_features_v4.csv';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.bps_kabkota_code IS 'sumber: bps_kabkota_code';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.kabkota_name IS 'sumber: kabkota_name';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.prov_name IS 'sumber: prov_name';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.shapename IS 'sumber: shapeName';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.crosswalk_match_type IS 'sumber: crosswalk_match_type';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.crosswalk_match_score IS 'sumber: crosswalk_match_score';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.ipm_2023 IS 'sumber: ipm_2023';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.ipm_2024 IS 'sumber: ipm_2024';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.ppm_2023 IS 'sumber: ppm_2023';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.ppm_2024 IS 'sumber: ppm_2024';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.population_2023 IS 'sumber: population_2023';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.population_2024 IS 'sumber: population_2024';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.ntl_radiance_mean IS 'sumber: ntl_radiance_mean';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.ntl_no_data IS 'sumber: ntl_no_data';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.elevation_mean_m IS 'sumber: elevation_mean_m';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.elevation_std_m IS 'sumber: elevation_std_m';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.elevation_no_data IS 'sumber: elevation_no_data';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.pct_tree_cover IS 'sumber: pct_tree_cover';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.pct_shrubland IS 'sumber: pct_shrubland';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.pct_grassland IS 'sumber: pct_grassland';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.pct_cropland IS 'sumber: pct_cropland';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.pct_built_up IS 'sumber: pct_built_up';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.pct_bare_sparse_veg IS 'sumber: pct_bare_sparse_veg';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.pct_snow_ice IS 'sumber: pct_snow_ice';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.pct_water IS 'sumber: pct_water';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.pct_wetland IS 'sumber: pct_wetland';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.pct_mangroves IS 'sumber: pct_mangroves';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.pct_moss_lichen IS 'sumber: pct_moss_lichen';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.landcover_no_data IS 'sumber: landcover_no_data';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.tertinggal_status IS 'sumber: tertinggal_status';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.is_tertinggal IS 'sumber: is_tertinggal';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.allsky_sfc_sw_dwn_mean IS 'sumber: allsky_sfc_sw_dwn_mean';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.t2m_mean IS 'sumber: t2m_mean';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.ws10m_mean IS 'sumber: ws10m_mean';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.ws50m_mean IS 'sumber: ws50m_mean';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.rh2m_mean IS 'sumber: rh2m_mean';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.prectotcorr_mean IS 'sumber: prectotcorr_mean';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.solar_zonal_fallback IS 'sumber: solar_zonal_fallback';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.weather_zonal_fallback IS 'sumber: weather_zonal_fallback';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.wind_speed_100m_mean_ms IS 'sumber: wind_speed_100m_mean_ms';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.wind_no_data IS 'sumber: wind_no_data';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.road_length_km IS 'sumber: road_length_km';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.road_density_km_per_km2 IS 'sumber: road_density_km_per_km2';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.dist_to_primary_trunk_km IS 'sumber: dist_to_primary_trunk_km';
COMMENT ON COLUMN raw.src_04_fitur_kabkota.centroid_type IS 'sumber: centroid_type';

CREATE TABLE IF NOT EXISTS raw.src_05_opencellid (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-05',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    radio text,
    mcc text,
    net text,
    area text,
    cell text,
    unit text,
    lon text,
    lat text,
    range text,
    samples text,
    changeable text,
    created text,
    updated text,
    averagesignal text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_05_opencellid IS 'SRC-05 cell_towers_in_indonesia_510; contoh file Cell Towers in Indonesia 510.csv';
COMMENT ON COLUMN raw.src_05_opencellid.radio IS 'sumber: radio';
COMMENT ON COLUMN raw.src_05_opencellid.mcc IS 'sumber: mcc';
COMMENT ON COLUMN raw.src_05_opencellid.net IS 'sumber: net';
COMMENT ON COLUMN raw.src_05_opencellid.area IS 'sumber: area';
COMMENT ON COLUMN raw.src_05_opencellid.cell IS 'sumber: cell';
COMMENT ON COLUMN raw.src_05_opencellid.unit IS 'sumber: unit';
COMMENT ON COLUMN raw.src_05_opencellid.lon IS 'sumber: lon';
COMMENT ON COLUMN raw.src_05_opencellid.lat IS 'sumber: lat';
COMMENT ON COLUMN raw.src_05_opencellid.range IS 'sumber: range';
COMMENT ON COLUMN raw.src_05_opencellid.samples IS 'sumber: samples';
COMMENT ON COLUMN raw.src_05_opencellid.changeable IS 'sumber: changeable';
COMMENT ON COLUMN raw.src_05_opencellid.created IS 'sumber: created';
COMMENT ON COLUMN raw.src_05_opencellid.updated IS 'sumber: updated';
COMMENT ON COLUMN raw.src_05_opencellid.averagesignal IS 'sumber: averageSignal';

CREATE TABLE IF NOT EXISTS raw.src_06_ookla_tiles (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-06',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    quadkey text,
    tile text,
    tile_x text,
    tile_y text,
    avg_d_kbps text,
    avg_u_kbps text,
    avg_lat_ms text,
    avg_lat_down_ms text,
    avg_lat_up_ms text,
    tests text,
    devices text,
    quarter text,
    type text,
    year text,
    lon text,
    lat text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_06_ookla_tiles IS 'SRC-06 ookla_fixed_2024q4_indonesia; contoh file ookla_fixed_2024q4_indonesia.csv';
COMMENT ON COLUMN raw.src_06_ookla_tiles.quadkey IS 'sumber: quadkey';
COMMENT ON COLUMN raw.src_06_ookla_tiles.tile IS 'sumber: tile';
COMMENT ON COLUMN raw.src_06_ookla_tiles.tile_x IS 'sumber: tile_x';
COMMENT ON COLUMN raw.src_06_ookla_tiles.tile_y IS 'sumber: tile_y';
COMMENT ON COLUMN raw.src_06_ookla_tiles.avg_d_kbps IS 'sumber: avg_d_kbps';
COMMENT ON COLUMN raw.src_06_ookla_tiles.avg_u_kbps IS 'sumber: avg_u_kbps';
COMMENT ON COLUMN raw.src_06_ookla_tiles.avg_lat_ms IS 'sumber: avg_lat_ms';
COMMENT ON COLUMN raw.src_06_ookla_tiles.avg_lat_down_ms IS 'sumber: avg_lat_down_ms';
COMMENT ON COLUMN raw.src_06_ookla_tiles.avg_lat_up_ms IS 'sumber: avg_lat_up_ms';
COMMENT ON COLUMN raw.src_06_ookla_tiles.tests IS 'sumber: tests';
COMMENT ON COLUMN raw.src_06_ookla_tiles.devices IS 'sumber: devices';
COMMENT ON COLUMN raw.src_06_ookla_tiles.quarter IS 'sumber: quarter';
COMMENT ON COLUMN raw.src_06_ookla_tiles.type IS 'sumber: type';
COMMENT ON COLUMN raw.src_06_ookla_tiles.year IS 'sumber: year';
COMMENT ON COLUMN raw.src_06_ookla_tiles.lon IS 'sumber: lon';
COMMENT ON COLUMN raw.src_06_ookla_tiles.lat IS 'sumber: lat';

CREATE TABLE IF NOT EXISTS raw.src_07_gppd (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-07',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    country text,
    country_long text,
    name text,
    gppd_idnr text,
    capacity_mw text,
    latitude text,
    longitude text,
    primary_fuel text,
    other_fuel1 text,
    other_fuel2 text,
    other_fuel3 text,
    commissioning_year text,
    owner text,
    source text,
    url text,
    geolocation_source text,
    wepp_id text,
    year_of_capacity_data text,
    generation_gwh_2013 text,
    generation_gwh_2014 text,
    generation_gwh_2015 text,
    generation_gwh_2016 text,
    generation_gwh_2017 text,
    generation_gwh_2018 text,
    generation_gwh_2019 text,
    generation_data_source text,
    estimated_generation_gwh_2013 text,
    estimated_generation_gwh_2014 text,
    estimated_generation_gwh_2015 text,
    estimated_generation_gwh_2016 text,
    estimated_generation_gwh_2017 text,
    estimated_generation_note_2013 text,
    estimated_generation_note_2014 text,
    estimated_generation_note_2015 text,
    estimated_generation_note_2016 text,
    estimated_generation_note_2017 text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_07_gppd IS 'SRC-07 global_power_plant_database; contoh file global_power_plant_database.csv';
COMMENT ON COLUMN raw.src_07_gppd.country IS 'sumber: country';
COMMENT ON COLUMN raw.src_07_gppd.country_long IS 'sumber: country_long';
COMMENT ON COLUMN raw.src_07_gppd.name IS 'sumber: name';
COMMENT ON COLUMN raw.src_07_gppd.gppd_idnr IS 'sumber: gppd_idnr';
COMMENT ON COLUMN raw.src_07_gppd.capacity_mw IS 'sumber: capacity_mw';
COMMENT ON COLUMN raw.src_07_gppd.latitude IS 'sumber: latitude';
COMMENT ON COLUMN raw.src_07_gppd.longitude IS 'sumber: longitude';
COMMENT ON COLUMN raw.src_07_gppd.primary_fuel IS 'sumber: primary_fuel';
COMMENT ON COLUMN raw.src_07_gppd.other_fuel1 IS 'sumber: other_fuel1';
COMMENT ON COLUMN raw.src_07_gppd.other_fuel2 IS 'sumber: other_fuel2';
COMMENT ON COLUMN raw.src_07_gppd.other_fuel3 IS 'sumber: other_fuel3';
COMMENT ON COLUMN raw.src_07_gppd.commissioning_year IS 'sumber: commissioning_year';
COMMENT ON COLUMN raw.src_07_gppd.owner IS 'sumber: owner';
COMMENT ON COLUMN raw.src_07_gppd.source IS 'sumber: source';
COMMENT ON COLUMN raw.src_07_gppd.url IS 'sumber: url';
COMMENT ON COLUMN raw.src_07_gppd.geolocation_source IS 'sumber: geolocation_source';
COMMENT ON COLUMN raw.src_07_gppd.wepp_id IS 'sumber: wepp_id';
COMMENT ON COLUMN raw.src_07_gppd.year_of_capacity_data IS 'sumber: year_of_capacity_data';
COMMENT ON COLUMN raw.src_07_gppd.generation_gwh_2013 IS 'sumber: generation_gwh_2013';
COMMENT ON COLUMN raw.src_07_gppd.generation_gwh_2014 IS 'sumber: generation_gwh_2014';
COMMENT ON COLUMN raw.src_07_gppd.generation_gwh_2015 IS 'sumber: generation_gwh_2015';
COMMENT ON COLUMN raw.src_07_gppd.generation_gwh_2016 IS 'sumber: generation_gwh_2016';
COMMENT ON COLUMN raw.src_07_gppd.generation_gwh_2017 IS 'sumber: generation_gwh_2017';
COMMENT ON COLUMN raw.src_07_gppd.generation_gwh_2018 IS 'sumber: generation_gwh_2018';
COMMENT ON COLUMN raw.src_07_gppd.generation_gwh_2019 IS 'sumber: generation_gwh_2019';
COMMENT ON COLUMN raw.src_07_gppd.generation_data_source IS 'sumber: generation_data_source';
COMMENT ON COLUMN raw.src_07_gppd.estimated_generation_gwh_2013 IS 'sumber: estimated_generation_gwh_2013';
COMMENT ON COLUMN raw.src_07_gppd.estimated_generation_gwh_2014 IS 'sumber: estimated_generation_gwh_2014';
COMMENT ON COLUMN raw.src_07_gppd.estimated_generation_gwh_2015 IS 'sumber: estimated_generation_gwh_2015';
COMMENT ON COLUMN raw.src_07_gppd.estimated_generation_gwh_2016 IS 'sumber: estimated_generation_gwh_2016';
COMMENT ON COLUMN raw.src_07_gppd.estimated_generation_gwh_2017 IS 'sumber: estimated_generation_gwh_2017';
COMMENT ON COLUMN raw.src_07_gppd.estimated_generation_note_2013 IS 'sumber: estimated_generation_note_2013';
COMMENT ON COLUMN raw.src_07_gppd.estimated_generation_note_2014 IS 'sumber: estimated_generation_note_2014';
COMMENT ON COLUMN raw.src_07_gppd.estimated_generation_note_2015 IS 'sumber: estimated_generation_note_2015';
COMMENT ON COLUMN raw.src_07_gppd.estimated_generation_note_2016 IS 'sumber: estimated_generation_note_2016';
COMMENT ON COLUMN raw.src_07_gppd.estimated_generation_note_2017 IS 'sumber: estimated_generation_note_2017';

CREATE TABLE IF NOT EXISTS raw.src_08_osm_gardu (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-08',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    id text,
    id_2 text,
    m_hazard_prone text,
    access_roof text,
    addr_city text,
    addr_country text,
    addr_full text,
    addr_housenumber text,
    addr_postcode text,
    addr_street text,
    addr_subdistrict text,
    alt_name text,
    amenity text,
    backup_generator text,
    barrier text,
    building text,
    building_condition text,
    building_levels text,
    building_material text,
    building_roof text,
    building_structure text,
    building_use text,
    building_walls text,
    cables text,
    capacity text,
    check_date text,
    description text,
    design text,
    designation text,
    fixme text,
    frequency text,
    gas_insulated text,
    generator_source text,
    height text,
    landuse text,
    layer text,
    leisure text,
    location text,
    man_made text,
    name text,
    name_en text,
    name_id text,
    name_ms text,
    not_operator_wikidata text,
    note text,
    office text,
    official_name text,
    opening_date text,
    opening_hours text,
    operator text,
    operator_short text,
    operator_wikidata text,
    operator_wikipedia text,
    phone text,
    power text,
    power_supply text,
    public_service_provider_type_idn text,
    rating text,
    ref text,
    roof_levels text,
    roof_material text,
    roof_orientation text,
    roof_shape text,
    shelter_type text,
    short_name text,
    source text,
    start_date text,
    substation text,
    type text,
    utility text,
    voltage text,
    geometry text,
    longitude text,
    latitude text,
    geometry_wkt text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_08_osm_gardu IS 'SRC-08 gardu_induk_dan_elektrik; contoh file Gardu Induk dan Elektrik.csv';
COMMENT ON COLUMN raw.src_08_osm_gardu.id IS 'sumber: id';
COMMENT ON COLUMN raw.src_08_osm_gardu.id_2 IS 'sumber: @id';
COMMENT ON COLUMN raw.src_08_osm_gardu.m_hazard_prone IS 'sumber: M:hazard_prone';
COMMENT ON COLUMN raw.src_08_osm_gardu.access_roof IS 'sumber: access:roof';
COMMENT ON COLUMN raw.src_08_osm_gardu.addr_city IS 'sumber: addr:city';
COMMENT ON COLUMN raw.src_08_osm_gardu.addr_country IS 'sumber: addr:country';
COMMENT ON COLUMN raw.src_08_osm_gardu.addr_full IS 'sumber: addr:full';
COMMENT ON COLUMN raw.src_08_osm_gardu.addr_housenumber IS 'sumber: addr:housenumber';
COMMENT ON COLUMN raw.src_08_osm_gardu.addr_postcode IS 'sumber: addr:postcode';
COMMENT ON COLUMN raw.src_08_osm_gardu.addr_street IS 'sumber: addr:street';
COMMENT ON COLUMN raw.src_08_osm_gardu.addr_subdistrict IS 'sumber: addr:subdistrict';
COMMENT ON COLUMN raw.src_08_osm_gardu.alt_name IS 'sumber: alt_name';
COMMENT ON COLUMN raw.src_08_osm_gardu.amenity IS 'sumber: amenity';
COMMENT ON COLUMN raw.src_08_osm_gardu.backup_generator IS 'sumber: backup_generator';
COMMENT ON COLUMN raw.src_08_osm_gardu.barrier IS 'sumber: barrier';
COMMENT ON COLUMN raw.src_08_osm_gardu.building IS 'sumber: building';
COMMENT ON COLUMN raw.src_08_osm_gardu.building_condition IS 'sumber: building:condition';
COMMENT ON COLUMN raw.src_08_osm_gardu.building_levels IS 'sumber: building:levels';
COMMENT ON COLUMN raw.src_08_osm_gardu.building_material IS 'sumber: building:material';
COMMENT ON COLUMN raw.src_08_osm_gardu.building_roof IS 'sumber: building:roof';
COMMENT ON COLUMN raw.src_08_osm_gardu.building_structure IS 'sumber: building:structure';
COMMENT ON COLUMN raw.src_08_osm_gardu.building_use IS 'sumber: building:use';
COMMENT ON COLUMN raw.src_08_osm_gardu.building_walls IS 'sumber: building:walls';
COMMENT ON COLUMN raw.src_08_osm_gardu.cables IS 'sumber: cables';
COMMENT ON COLUMN raw.src_08_osm_gardu.capacity IS 'sumber: capacity';
COMMENT ON COLUMN raw.src_08_osm_gardu.check_date IS 'sumber: check_date';
COMMENT ON COLUMN raw.src_08_osm_gardu.description IS 'sumber: description';
COMMENT ON COLUMN raw.src_08_osm_gardu.design IS 'sumber: design';
COMMENT ON COLUMN raw.src_08_osm_gardu.designation IS 'sumber: designation';
COMMENT ON COLUMN raw.src_08_osm_gardu.fixme IS 'sumber: fixme';
COMMENT ON COLUMN raw.src_08_osm_gardu.frequency IS 'sumber: frequency';
COMMENT ON COLUMN raw.src_08_osm_gardu.gas_insulated IS 'sumber: gas_insulated';
COMMENT ON COLUMN raw.src_08_osm_gardu.generator_source IS 'sumber: generator:source';
COMMENT ON COLUMN raw.src_08_osm_gardu.height IS 'sumber: height';
COMMENT ON COLUMN raw.src_08_osm_gardu.landuse IS 'sumber: landuse';
COMMENT ON COLUMN raw.src_08_osm_gardu.layer IS 'sumber: layer';
COMMENT ON COLUMN raw.src_08_osm_gardu.leisure IS 'sumber: leisure';
COMMENT ON COLUMN raw.src_08_osm_gardu.location IS 'sumber: location';
COMMENT ON COLUMN raw.src_08_osm_gardu.man_made IS 'sumber: man_made';
COMMENT ON COLUMN raw.src_08_osm_gardu.name IS 'sumber: name';
COMMENT ON COLUMN raw.src_08_osm_gardu.name_en IS 'sumber: name:en';
COMMENT ON COLUMN raw.src_08_osm_gardu.name_id IS 'sumber: name:id';
COMMENT ON COLUMN raw.src_08_osm_gardu.name_ms IS 'sumber: name:ms';
COMMENT ON COLUMN raw.src_08_osm_gardu.not_operator_wikidata IS 'sumber: not:operator:wikidata';
COMMENT ON COLUMN raw.src_08_osm_gardu.note IS 'sumber: note';
COMMENT ON COLUMN raw.src_08_osm_gardu.office IS 'sumber: office';
COMMENT ON COLUMN raw.src_08_osm_gardu.official_name IS 'sumber: official_name';
COMMENT ON COLUMN raw.src_08_osm_gardu.opening_date IS 'sumber: opening_date';
COMMENT ON COLUMN raw.src_08_osm_gardu.opening_hours IS 'sumber: opening_hours';
COMMENT ON COLUMN raw.src_08_osm_gardu.operator IS 'sumber: operator';
COMMENT ON COLUMN raw.src_08_osm_gardu.operator_short IS 'sumber: operator:short';
COMMENT ON COLUMN raw.src_08_osm_gardu.operator_wikidata IS 'sumber: operator:wikidata';
COMMENT ON COLUMN raw.src_08_osm_gardu.operator_wikipedia IS 'sumber: operator:wikipedia';
COMMENT ON COLUMN raw.src_08_osm_gardu.phone IS 'sumber: phone';
COMMENT ON COLUMN raw.src_08_osm_gardu.power IS 'sumber: power';
COMMENT ON COLUMN raw.src_08_osm_gardu.power_supply IS 'sumber: power_supply';
COMMENT ON COLUMN raw.src_08_osm_gardu.public_service_provider_type_idn IS 'sumber: public_service_provider:type_idn';
COMMENT ON COLUMN raw.src_08_osm_gardu.rating IS 'sumber: rating';
COMMENT ON COLUMN raw.src_08_osm_gardu.ref IS 'sumber: ref';
COMMENT ON COLUMN raw.src_08_osm_gardu.roof_levels IS 'sumber: roof:levels';
COMMENT ON COLUMN raw.src_08_osm_gardu.roof_material IS 'sumber: roof:material';
COMMENT ON COLUMN raw.src_08_osm_gardu.roof_orientation IS 'sumber: roof:orientation';
COMMENT ON COLUMN raw.src_08_osm_gardu.roof_shape IS 'sumber: roof:shape';
COMMENT ON COLUMN raw.src_08_osm_gardu.shelter_type IS 'sumber: shelter_type';
COMMENT ON COLUMN raw.src_08_osm_gardu.short_name IS 'sumber: short_name';
COMMENT ON COLUMN raw.src_08_osm_gardu.source IS 'sumber: source';
COMMENT ON COLUMN raw.src_08_osm_gardu.start_date IS 'sumber: start_date';
COMMENT ON COLUMN raw.src_08_osm_gardu.substation IS 'sumber: substation';
COMMENT ON COLUMN raw.src_08_osm_gardu.type IS 'sumber: type';
COMMENT ON COLUMN raw.src_08_osm_gardu.utility IS 'sumber: utility';
COMMENT ON COLUMN raw.src_08_osm_gardu.voltage IS 'sumber: voltage';
COMMENT ON COLUMN raw.src_08_osm_gardu.geometry IS 'sumber: @geometry';
COMMENT ON COLUMN raw.src_08_osm_gardu.longitude IS 'sumber: longitude';
COMMENT ON COLUMN raw.src_08_osm_gardu.latitude IS 'sumber: latitude';
COMMENT ON COLUMN raw.src_08_osm_gardu.geometry_wkt IS 'sumber: geometry_wkt';

CREATE TABLE IF NOT EXISTS raw.src_09_pop_isp (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-09',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    provinsi text,
    sebaran_pop_isp text,
    tahun text,
    source text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_09_pop_isp IS 'SRC-09 sebaran_point_of_presence_po; contoh file sebaran-point-of-presence-pop-layanan-jasa-internet-service-provider-isp_2026-11-13.csv';
COMMENT ON COLUMN raw.src_09_pop_isp.provinsi IS 'sumber: Provinsi';
COMMENT ON COLUMN raw.src_09_pop_isp.sebaran_pop_isp IS 'sumber: Sebaran PoP ISP';
COMMENT ON COLUMN raw.src_09_pop_isp.tahun IS 'sumber: Tahun';
COMMENT ON COLUMN raw.src_09_pop_isp.source IS 'sumber: Source';

CREATE TABLE IF NOT EXISTS raw.src_10_iklh_provinsi (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-10',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    provinsi text,
    indeks_kualitas_udara text,
    indeks_kualitas_air text,
    indeks_kualitas_tutupan_lahan_iktl text,
    indeks_kualitas_lahan_ikl text,
    indeks_kualitas_ekosistem_gambut_ikeg text,
    indeks_kualitas_air_laut_ikal text,
    tahun text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_10_iklh_provinsi IS 'SRC-10 komponen_penyusun_indeks_kua; contoh file Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2021.csv';
COMMENT ON COLUMN raw.src_10_iklh_provinsi.provinsi IS 'sumber: provinsi';
COMMENT ON COLUMN raw.src_10_iklh_provinsi.indeks_kualitas_udara IS 'sumber: Indeks Kualitas Udara';
COMMENT ON COLUMN raw.src_10_iklh_provinsi.indeks_kualitas_air IS 'sumber: Indeks Kualitas Air';
COMMENT ON COLUMN raw.src_10_iklh_provinsi.indeks_kualitas_tutupan_lahan_iktl IS 'sumber: Indeks Kualitas Tutupan Lahan (IKTL)';
COMMENT ON COLUMN raw.src_10_iklh_provinsi.indeks_kualitas_lahan_ikl IS 'sumber: Indeks Kualitas Lahan (IKL)';
COMMENT ON COLUMN raw.src_10_iklh_provinsi.indeks_kualitas_ekosistem_gambut_ikeg IS 'sumber: Indeks Kualitas Ekosistem Gambut (IKEG)';
COMMENT ON COLUMN raw.src_10_iklh_provinsi.indeks_kualitas_air_laut_ikal IS 'sumber: Indeks Kualitas Air Laut (IKAL)';
COMMENT ON COLUMN raw.src_10_iklh_provinsi.tahun IS 'sumber: tahun';

CREATE TABLE IF NOT EXISTS raw.src_11_adm1 (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-11',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    adm1_name text,
    adm1_name1 text,
    adm1_name2 text,
    adm1_name3 text,
    adm1_pcode text,
    adm0_name text,
    adm0_name1 text,
    adm0_name2 text,
    adm0_name3 text,
    adm0_pcode text,
    valid_on text,
    valid_to text,
    area_sqkm text,
    version text,
    lang text,
    lang1 text,
    lang2 text,
    lang3 text,
    adm1_ref_name text,
    center_lat text,
    center_lon text,
    geom_geojson text,
    geometry_type text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_11_adm1 IS 'SRC-11 idn_admin1; contoh file idn_admin1.geojson';
COMMENT ON COLUMN raw.src_11_adm1.adm1_name IS 'sumber: adm1_name';
COMMENT ON COLUMN raw.src_11_adm1.adm1_name1 IS 'sumber: adm1_name1';
COMMENT ON COLUMN raw.src_11_adm1.adm1_name2 IS 'sumber: adm1_name2';
COMMENT ON COLUMN raw.src_11_adm1.adm1_name3 IS 'sumber: adm1_name3';
COMMENT ON COLUMN raw.src_11_adm1.adm1_pcode IS 'sumber: adm1_pcode';
COMMENT ON COLUMN raw.src_11_adm1.adm0_name IS 'sumber: adm0_name';
COMMENT ON COLUMN raw.src_11_adm1.adm0_name1 IS 'sumber: adm0_name1';
COMMENT ON COLUMN raw.src_11_adm1.adm0_name2 IS 'sumber: adm0_name2';
COMMENT ON COLUMN raw.src_11_adm1.adm0_name3 IS 'sumber: adm0_name3';
COMMENT ON COLUMN raw.src_11_adm1.adm0_pcode IS 'sumber: adm0_pcode';
COMMENT ON COLUMN raw.src_11_adm1.valid_on IS 'sumber: valid_on';
COMMENT ON COLUMN raw.src_11_adm1.valid_to IS 'sumber: valid_to';
COMMENT ON COLUMN raw.src_11_adm1.area_sqkm IS 'sumber: area_sqkm';
COMMENT ON COLUMN raw.src_11_adm1.version IS 'sumber: version';
COMMENT ON COLUMN raw.src_11_adm1.lang IS 'sumber: lang';
COMMENT ON COLUMN raw.src_11_adm1.lang1 IS 'sumber: lang1';
COMMENT ON COLUMN raw.src_11_adm1.lang2 IS 'sumber: lang2';
COMMENT ON COLUMN raw.src_11_adm1.lang3 IS 'sumber: lang3';
COMMENT ON COLUMN raw.src_11_adm1.adm1_ref_name IS 'sumber: adm1_ref_name';
COMMENT ON COLUMN raw.src_11_adm1.center_lat IS 'sumber: center_lat';
COMMENT ON COLUMN raw.src_11_adm1.center_lon IS 'sumber: center_lon';
COMMENT ON COLUMN raw.src_11_adm1.geom_geojson IS 'sumber: geom_geojson';
COMMENT ON COLUMN raw.src_11_adm1.geometry_type IS 'sumber: _geometry_type';

CREATE TABLE IF NOT EXISTS raw.src_11_adm2 (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-11',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    adm2_name text,
    adm2_name1 text,
    adm2_name2 text,
    adm2_name3 text,
    adm2_pcode text,
    adm1_name text,
    adm1_name1 text,
    adm1_name2 text,
    adm1_name3 text,
    adm1_pcode text,
    adm0_name text,
    adm0_name1 text,
    adm0_name2 text,
    adm0_name3 text,
    adm0_pcode text,
    valid_on text,
    valid_to text,
    area_sqkm text,
    version text,
    lang text,
    lang1 text,
    lang2 text,
    lang3 text,
    adm2_ref_name text,
    center_lat text,
    center_lon text,
    geom_geojson text,
    geometry_type text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_11_adm2 IS 'SRC-11 idn_admin2; contoh file idn_admin2.geojson';
COMMENT ON COLUMN raw.src_11_adm2.adm2_name IS 'sumber: adm2_name';
COMMENT ON COLUMN raw.src_11_adm2.adm2_name1 IS 'sumber: adm2_name1';
COMMENT ON COLUMN raw.src_11_adm2.adm2_name2 IS 'sumber: adm2_name2';
COMMENT ON COLUMN raw.src_11_adm2.adm2_name3 IS 'sumber: adm2_name3';
COMMENT ON COLUMN raw.src_11_adm2.adm2_pcode IS 'sumber: adm2_pcode';
COMMENT ON COLUMN raw.src_11_adm2.adm1_name IS 'sumber: adm1_name';
COMMENT ON COLUMN raw.src_11_adm2.adm1_name1 IS 'sumber: adm1_name1';
COMMENT ON COLUMN raw.src_11_adm2.adm1_name2 IS 'sumber: adm1_name2';
COMMENT ON COLUMN raw.src_11_adm2.adm1_name3 IS 'sumber: adm1_name3';
COMMENT ON COLUMN raw.src_11_adm2.adm1_pcode IS 'sumber: adm1_pcode';
COMMENT ON COLUMN raw.src_11_adm2.adm0_name IS 'sumber: adm0_name';
COMMENT ON COLUMN raw.src_11_adm2.adm0_name1 IS 'sumber: adm0_name1';
COMMENT ON COLUMN raw.src_11_adm2.adm0_name2 IS 'sumber: adm0_name2';
COMMENT ON COLUMN raw.src_11_adm2.adm0_name3 IS 'sumber: adm0_name3';
COMMENT ON COLUMN raw.src_11_adm2.adm0_pcode IS 'sumber: adm0_pcode';
COMMENT ON COLUMN raw.src_11_adm2.valid_on IS 'sumber: valid_on';
COMMENT ON COLUMN raw.src_11_adm2.valid_to IS 'sumber: valid_to';
COMMENT ON COLUMN raw.src_11_adm2.area_sqkm IS 'sumber: area_sqkm';
COMMENT ON COLUMN raw.src_11_adm2.version IS 'sumber: version';
COMMENT ON COLUMN raw.src_11_adm2.lang IS 'sumber: lang';
COMMENT ON COLUMN raw.src_11_adm2.lang1 IS 'sumber: lang1';
COMMENT ON COLUMN raw.src_11_adm2.lang2 IS 'sumber: lang2';
COMMENT ON COLUMN raw.src_11_adm2.lang3 IS 'sumber: lang3';
COMMENT ON COLUMN raw.src_11_adm2.adm2_ref_name IS 'sumber: adm2_ref_name';
COMMENT ON COLUMN raw.src_11_adm2.center_lat IS 'sumber: center_lat';
COMMENT ON COLUMN raw.src_11_adm2.center_lon IS 'sumber: center_lon';
COMMENT ON COLUMN raw.src_11_adm2.geom_geojson IS 'sumber: geom_geojson';
COMMENT ON COLUMN raw.src_11_adm2.geometry_type IS 'sumber: _geometry_type';

CREATE TABLE IF NOT EXISTS raw.src_12_penduduk_provinsi (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-12',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    provinsi text,
    jumlah_penduduk_ribu text,
    laju_pertumbuhan_penduduk_per_tahun text,
    persentase_penduduk text,
    kepadatan_penduduk_per_km_persegi_km2 text,
    rasio_jenis_kelamin_penduduk text,
    tahun text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON TABLE raw.src_12_penduduk_provinsi IS 'SRC-12 penduduk_laju_pertumbuhan_pe; contoh file Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2022.csv';
COMMENT ON COLUMN raw.src_12_penduduk_provinsi.provinsi IS 'sumber: Provinsi';
COMMENT ON COLUMN raw.src_12_penduduk_provinsi.jumlah_penduduk_ribu IS 'sumber: Jumlah Penduduk (Ribu)';
COMMENT ON COLUMN raw.src_12_penduduk_provinsi.laju_pertumbuhan_penduduk_per_tahun IS 'sumber: Laju Pertumbuhan Penduduk per Tahun';
COMMENT ON COLUMN raw.src_12_penduduk_provinsi.persentase_penduduk IS 'sumber: Persentase Penduduk';
COMMENT ON COLUMN raw.src_12_penduduk_provinsi.kepadatan_penduduk_per_km_persegi_km2 IS 'sumber: Kepadatan Penduduk per km persegi (Km2)';
COMMENT ON COLUMN raw.src_12_penduduk_provinsi.rasio_jenis_kelamin_penduduk IS 'sumber: Rasio Jenis Kelamin Penduduk';
COMMENT ON COLUMN raw.src_12_penduduk_provinsi.tahun IS 'sumber: tahun';
