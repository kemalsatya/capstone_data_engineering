-- AUTO-DRAFT dari profile_sources.py v3.0. Tipe berdasarkan inferensi data; verifikasi bersama pemilik data.
-- Constraint NOT NULL/CHECK sengaja tidak dipasang: pelanggaran ditangani aturan DQ + karantina (Fase 4).
-- Nama kolom staging = nama kolom raw. Nama KANONIK vault/mart ditetapkan di Data_Contract dan Mapping_Lineage.
CREATE SCHEMA IF NOT EXISTS stg;

CREATE TABLE IF NOT EXISTS stg.src_01_bmkg_gempa (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-01',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    no integer,
    event_id text,
    date date,
    time_utc text,
    latitude numeric(10,7),
    longitude numeric(10,7),
    magnitude numeric,
    mag_type text,
    depth_km integer,
    source text,
    source_event_id text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_01_bmkg_gempa.no IS 'sumber: No; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_01_bmkg_gempa.event_id IS 'sumber: Event ID; tipe terdeteksi: text; null 0.0%; panjang 23-23';
COMMENT ON COLUMN stg.src_01_bmkg_gempa.date IS 'sumber: Date; tipe terdeteksi: date; null 0.0%';
COMMENT ON COLUMN stg.src_01_bmkg_gempa.time_utc IS 'sumber: Time (UTC); tipe terdeteksi: text; null 0.0%; panjang 8-8';
COMMENT ON COLUMN stg.src_01_bmkg_gempa.latitude IS 'sumber: Latitude; tipe terdeteksi: numeric; null 0.0%; lintang';
COMMENT ON COLUMN stg.src_01_bmkg_gempa.longitude IS 'sumber: Longitude; tipe terdeteksi: numeric; null 0.0%; bujur';
COMMENT ON COLUMN stg.src_01_bmkg_gempa.magnitude IS 'sumber: Magnitude; tipe terdeteksi: numeric; null 0.0%; maks 1 digit desimal';
COMMENT ON COLUMN stg.src_01_bmkg_gempa.mag_type IS 'sumber: Mag Type; tipe terdeteksi: text; null 0.0%; panjang 1-7';
COMMENT ON COLUMN stg.src_01_bmkg_gempa.depth_km IS 'sumber: Depth (km); tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_01_bmkg_gempa.source IS 'sumber: Source; tipe terdeteksi: text; null 0.0%; panjang 2-5';
COMMENT ON COLUMN stg.src_01_bmkg_gempa.source_event_id IS 'sumber: Source Event ID; tipe terdeteksi: text; null 0.0%; panjang 1-11';

CREATE TABLE IF NOT EXISTS stg.src_02_bnpb_bencana (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-02',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    city_id integer,
    date date,
    disaster_type text,
    city text,
    province text,
    cause text,
    death numeric,
    missing_person numeric,
    injured_person numeric,
    damaged_house numeric,
    flooded_house numeric,
    damaged_facility integer,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_02_bnpb_bencana.city_id IS 'sumber: city_id; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_02_bnpb_bencana.date IS 'sumber: date; tipe terdeteksi: date; null 0.0%; ada komponen jam tetapi selalu 00:00:00 (tanggal saja)';
COMMENT ON COLUMN stg.src_02_bnpb_bencana.disaster_type IS 'sumber: disaster_type; tipe terdeteksi: text; null 0.0%; panjang 6-27';
COMMENT ON COLUMN stg.src_02_bnpb_bencana.city IS 'sumber: city; tipe terdeteksi: text; null 0.0%; panjang 4-32';
COMMENT ON COLUMN stg.src_02_bnpb_bencana.province IS 'sumber: province; tipe terdeteksi: text; null 0.0%; panjang 4-26';
COMMENT ON COLUMN stg.src_02_bnpb_bencana.cause IS 'sumber: cause; tipe terdeteksi: text; null 0.0%; panjang 5-32766';
COMMENT ON COLUMN stg.src_02_bnpb_bencana.death IS 'sumber: death; tipe terdeteksi: numeric; null 0.0%; maks 17 digit desimal';
COMMENT ON COLUMN stg.src_02_bnpb_bencana.missing_person IS 'sumber: missing_person; tipe terdeteksi: numeric; null 3.9%; maks 18 digit desimal';
COMMENT ON COLUMN stg.src_02_bnpb_bencana.injured_person IS 'sumber: injured_person; tipe terdeteksi: numeric; null 0.0%; maks 17 digit desimal';
COMMENT ON COLUMN stg.src_02_bnpb_bencana.damaged_house IS 'sumber: damaged_house; tipe terdeteksi: numeric; null 0.0%; maks 14 digit desimal';
COMMENT ON COLUMN stg.src_02_bnpb_bencana.flooded_house IS 'sumber: flooded_house; tipe terdeteksi: numeric; null 3.9%; maks 18 digit desimal';
COMMENT ON COLUMN stg.src_02_bnpb_bencana.damaged_facility IS 'sumber: damaged_facility; tipe terdeteksi: integer; null 0.0%';

CREATE TABLE IF NOT EXISTS stg.src_03_iklim_harian (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-03',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    date date,
    tn numeric,
    tx numeric,
    tavg numeric,
    rh_avg integer,
    rr numeric,
    ss numeric,
    ff_x integer,
    ddd_x integer,
    ff_avg integer,
    ddd_car text,
    station_id integer,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_03_iklim_harian.date IS 'sumber: date; tipe terdeteksi: date; null 0.0%';
COMMENT ON COLUMN stg.src_03_iklim_harian.tn IS 'sumber: Tn; tipe terdeteksi: numeric; null 4.0%; maks 1 digit desimal';
COMMENT ON COLUMN stg.src_03_iklim_harian.tx IS 'sumber: Tx; tipe terdeteksi: numeric; null 6.4%; maks 1 digit desimal';
COMMENT ON COLUMN stg.src_03_iklim_harian.tavg IS 'sumber: Tavg; tipe terdeteksi: numeric; null 7.7%; maks 1 digit desimal';
COMMENT ON COLUMN stg.src_03_iklim_harian.rh_avg IS 'sumber: RH_avg; tipe terdeteksi: integer; null 8.2%; bilangan bulat yang ditulis dengan ''.0''';
COMMENT ON COLUMN stg.src_03_iklim_harian.rr IS 'sumber: RR; tipe terdeteksi: numeric; null 21.3%; maks 1 digit desimal';
COMMENT ON COLUMN stg.src_03_iklim_harian.ss IS 'sumber: ss; tipe terdeteksi: numeric; null 7.4%; maks 1 digit desimal';
COMMENT ON COLUMN stg.src_03_iklim_harian.ff_x IS 'sumber: ff_x; tipe terdeteksi: integer; null 1.7%; bilangan bulat yang ditulis dengan ''.0''';
COMMENT ON COLUMN stg.src_03_iklim_harian.ddd_x IS 'sumber: ddd_x; tipe terdeteksi: integer; null 2.2%; bilangan bulat yang ditulis dengan ''.0''';
COMMENT ON COLUMN stg.src_03_iklim_harian.ff_avg IS 'sumber: ff_avg; tipe terdeteksi: integer; null 1.7%; bilangan bulat yang ditulis dengan ''.0''';
COMMENT ON COLUMN stg.src_03_iklim_harian.ddd_car IS 'sumber: ddd_car; tipe terdeteksi: text; null 2.3%; panjang 1-2';
COMMENT ON COLUMN stg.src_03_iklim_harian.station_id IS 'sumber: station_id; tipe terdeteksi: integer; null 0.0%';

CREATE TABLE IF NOT EXISTS stg.src_03_iklim_provinsi (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-03',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    province_id integer,
    province_name text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_03_iklim_provinsi.province_id IS 'sumber: province_id; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_03_iklim_provinsi.province_name IS 'sumber: province_name; tipe terdeteksi: text; null 0.0%; panjang 4-24';

CREATE TABLE IF NOT EXISTS stg.src_03_iklim_stasiun (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-03',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    station_id integer,
    station_name text,
    region_name text,
    latitude numeric(10,7),
    longitude numeric(10,7),
    region_id integer,
    province_id integer,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_03_iklim_stasiun.station_id IS 'sumber: station_id; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_03_iklim_stasiun.station_name IS 'sumber: station_name; tipe terdeteksi: text; null 0.0%; panjang 22-62';
COMMENT ON COLUMN stg.src_03_iklim_stasiun.region_name IS 'sumber: region_name; tipe terdeteksi: text; null 0.0%; panjang 9-25';
COMMENT ON COLUMN stg.src_03_iklim_stasiun.latitude IS 'sumber: latitude; tipe terdeteksi: numeric; null 0.0%; lintang';
COMMENT ON COLUMN stg.src_03_iklim_stasiun.longitude IS 'sumber: longitude; tipe terdeteksi: numeric; null 0.0%; bujur';
COMMENT ON COLUMN stg.src_03_iklim_stasiun.region_id IS 'sumber: region_id; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_03_iklim_stasiun.province_id IS 'sumber: province_id; tipe terdeteksi: integer; null 0.0%';

CREATE TABLE IF NOT EXISTS stg.src_04_fitur_kabkota (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-04',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    bps_kabkota_code integer,
    kabkota_name text,
    prov_name text,
    shapename text,
    crosswalk_match_type text,
    crosswalk_match_score numeric,
    ipm_2023 numeric,
    ipm_2024 numeric,
    ppm_2023 numeric,
    ppm_2024 numeric,
    population_2023 integer,
    population_2024 integer,
    ntl_radiance_mean numeric,
    ntl_no_data boolean,
    elevation_mean_m numeric,
    elevation_std_m numeric,
    elevation_no_data boolean,
    pct_tree_cover numeric,
    pct_shrubland numeric,
    pct_grassland numeric,
    pct_cropland numeric,
    pct_built_up numeric,
    pct_bare_sparse_veg numeric,
    pct_snow_ice numeric,
    pct_water numeric,
    pct_wetland numeric,
    pct_mangroves numeric,
    pct_moss_lichen numeric,
    landcover_no_data boolean,
    tertinggal_status text,
    is_tertinggal boolean,
    allsky_sfc_sw_dwn_mean numeric,
    t2m_mean numeric,
    ws10m_mean numeric,
    ws50m_mean numeric,
    rh2m_mean numeric,
    prectotcorr_mean numeric,
    solar_zonal_fallback boolean,
    weather_zonal_fallback boolean,
    wind_speed_100m_mean_ms numeric,
    wind_no_data boolean,
    road_length_km numeric,
    road_density_km_per_km2 numeric,
    dist_to_primary_trunk_km numeric,
    centroid_type text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_04_fitur_kabkota.bps_kabkota_code IS 'sumber: bps_kabkota_code; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.kabkota_name IS 'sumber: kabkota_name; tipe terdeteksi: text; null 0.0%; panjang 4-42';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.prov_name IS 'sumber: prov_name; tipe terdeteksi: text; null 0.0%; panjang 4-20';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.shapename IS 'sumber: shapeName; tipe terdeteksi: text; null 0.0%; panjang 4-26';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.crosswalk_match_type IS 'sumber: crosswalk_match_type; tipe terdeteksi: text; null 0.0%; panjang 5-12';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.crosswalk_match_score IS 'sumber: crosswalk_match_score; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.ipm_2023 IS 'sumber: ipm_2023; tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.ipm_2024 IS 'sumber: ipm_2024; tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.ppm_2023 IS 'sumber: ppm_2023; tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.ppm_2024 IS 'sumber: ppm_2024; tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.population_2023 IS 'sumber: population_2023; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.population_2024 IS 'sumber: population_2024; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.ntl_radiance_mean IS 'sumber: ntl_radiance_mean; tipe terdeteksi: numeric; null 0.0%; maks 16 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.ntl_no_data IS 'sumber: ntl_no_data; tipe terdeteksi: boolean; null 0.0%';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.elevation_mean_m IS 'sumber: elevation_mean_m; tipe terdeteksi: numeric; null 0.0%; maks 16 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.elevation_std_m IS 'sumber: elevation_std_m; tipe terdeteksi: numeric; null 0.0%; maks 16 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.elevation_no_data IS 'sumber: elevation_no_data; tipe terdeteksi: boolean; null 0.0%';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.pct_tree_cover IS 'sumber: pct_tree_cover; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.pct_shrubland IS 'sumber: pct_shrubland; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.pct_grassland IS 'sumber: pct_grassland; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.pct_cropland IS 'sumber: pct_cropland; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.pct_built_up IS 'sumber: pct_built_up; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.pct_bare_sparse_veg IS 'sumber: pct_bare_sparse_veg; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.pct_snow_ice IS 'sumber: pct_snow_ice; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.pct_water IS 'sumber: pct_water; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.pct_wetland IS 'sumber: pct_wetland; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.pct_mangroves IS 'sumber: pct_mangroves; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.pct_moss_lichen IS 'sumber: pct_moss_lichen; tipe terdeteksi: numeric; null 0.0%; float menurut kamus data (nilai teramati bulat)';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.landcover_no_data IS 'sumber: landcover_no_data; tipe terdeteksi: boolean; null 0.0%';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.tertinggal_status IS 'sumber: tertinggal_status; tipe terdeteksi: text; null 0.0%; panjang 10-17';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.is_tertinggal IS 'sumber: is_tertinggal; tipe terdeteksi: boolean; null 0.0%';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.allsky_sfc_sw_dwn_mean IS 'sumber: allsky_sfc_sw_dwn_mean; tipe terdeteksi: numeric; null 0.0%; maks 14 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.t2m_mean IS 'sumber: t2m_mean; tipe terdeteksi: numeric; null 0.0%; maks 15 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.ws10m_mean IS 'sumber: ws10m_mean; tipe terdeteksi: numeric; null 0.0%; maks 16 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.ws50m_mean IS 'sumber: ws50m_mean; tipe terdeteksi: numeric; null 0.0%; maks 16 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.rh2m_mean IS 'sumber: rh2m_mean; tipe terdeteksi: numeric; null 0.0%; maks 14 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.prectotcorr_mean IS 'sumber: prectotcorr_mean; tipe terdeteksi: numeric; null 0.0%; maks 16 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.solar_zonal_fallback IS 'sumber: solar_zonal_fallback; tipe terdeteksi: boolean; null 0.0%';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.weather_zonal_fallback IS 'sumber: weather_zonal_fallback; tipe terdeteksi: boolean; null 0.0%';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.wind_speed_100m_mean_ms IS 'sumber: wind_speed_100m_mean_ms; tipe terdeteksi: numeric; null 0.0%; maks 16 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.wind_no_data IS 'sumber: wind_no_data; tipe terdeteksi: boolean; null 0.0%';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.road_length_km IS 'sumber: road_length_km; tipe terdeteksi: numeric; null 0.0%; maks 14 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.road_density_km_per_km2 IS 'sumber: road_density_km_per_km2; tipe terdeteksi: numeric; null 0.0%; maks 16 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.dist_to_primary_trunk_km IS 'sumber: dist_to_primary_trunk_km; tipe terdeteksi: numeric; null 0.0%; maks 16 digit desimal';
COMMENT ON COLUMN stg.src_04_fitur_kabkota.centroid_type IS 'sumber: centroid_type; tipe terdeteksi: text; null 0.0%; panjang 9-9';

CREATE TABLE IF NOT EXISTS stg.src_05_opencellid (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-05',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    radio text,
    mcc integer,
    net integer,
    area integer,
    cell integer,
    unit integer,
    lon numeric(10,7),
    lat numeric(10,7),
    range integer,
    samples integer,
    changeable integer,
    created timestamptz,
    updated timestamptz,
    averagesignal integer,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_05_opencellid.radio IS 'sumber: radio; tipe terdeteksi: text; null 0.0%; panjang 2-4';
COMMENT ON COLUMN stg.src_05_opencellid.mcc IS 'sumber: mcc; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_05_opencellid.net IS 'sumber: net; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_05_opencellid.area IS 'sumber: area; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_05_opencellid.cell IS 'sumber: cell; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_05_opencellid.unit IS 'sumber: unit; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_05_opencellid.lon IS 'sumber: lon; tipe terdeteksi: numeric; null 0.0%; bujur';
COMMENT ON COLUMN stg.src_05_opencellid.lat IS 'sumber: lat; tipe terdeteksi: numeric; null 0.0%; lintang';
COMMENT ON COLUMN stg.src_05_opencellid.range IS 'sumber: range; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_05_opencellid.samples IS 'sumber: samples; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_05_opencellid.changeable IS 'sumber: changeable; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_05_opencellid.created IS 'sumber: created; tipe terdeteksi: epoch_seconds; null 0.0%; epoch detik; to_timestamp(kolom)';
COMMENT ON COLUMN stg.src_05_opencellid.updated IS 'sumber: updated; tipe terdeteksi: epoch_seconds; null 0.0%; epoch detik; to_timestamp(kolom)';
COMMENT ON COLUMN stg.src_05_opencellid.averagesignal IS 'sumber: averageSignal; tipe terdeteksi: integer; null 0.0%';

CREATE TABLE IF NOT EXISTS stg.src_06_ookla_tiles (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-06',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    quadkey text,
    tile text,
    tile_x numeric,
    tile_y numeric,
    avg_d_kbps integer,
    avg_u_kbps integer,
    avg_lat_ms integer,
    avg_lat_down_ms integer,
    avg_lat_up_ms integer,
    tests integer,
    devices integer,
    quarter integer,
    type text,
    year integer,
    lon numeric(10,7),
    lat numeric(10,7),
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_06_ookla_tiles.quadkey IS 'sumber: quadkey; tipe terdeteksi: text; null 0.0%; panjang 16-16';
COMMENT ON COLUMN stg.src_06_ookla_tiles.tile IS 'sumber: tile; tipe terdeteksi: geometry_wkt; null 0.0%; WKT; jadikan geometry(...,4326) di staging bila PostGIS aktif';
COMMENT ON COLUMN stg.src_06_ookla_tiles.tile_x IS 'sumber: tile_x; tipe terdeteksi: numeric; null 0.0%; maks 14 digit desimal';
COMMENT ON COLUMN stg.src_06_ookla_tiles.tile_y IS 'sumber: tile_y; tipe terdeteksi: numeric; null 0.0%; maks 18 digit desimal';
COMMENT ON COLUMN stg.src_06_ookla_tiles.avg_d_kbps IS 'sumber: avg_d_kbps; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_06_ookla_tiles.avg_u_kbps IS 'sumber: avg_u_kbps; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_06_ookla_tiles.avg_lat_ms IS 'sumber: avg_lat_ms; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_06_ookla_tiles.avg_lat_down_ms IS 'sumber: avg_lat_down_ms; tipe terdeteksi: integer; null 0.7%';
COMMENT ON COLUMN stg.src_06_ookla_tiles.avg_lat_up_ms IS 'sumber: avg_lat_up_ms; tipe terdeteksi: integer; null 0.6%';
COMMENT ON COLUMN stg.src_06_ookla_tiles.tests IS 'sumber: tests; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_06_ookla_tiles.devices IS 'sumber: devices; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_06_ookla_tiles.quarter IS 'sumber: quarter; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_06_ookla_tiles.type IS 'sumber: type; tipe terdeteksi: text; null 0.0%; panjang 5-5';
COMMENT ON COLUMN stg.src_06_ookla_tiles.year IS 'sumber: year; tipe terdeteksi: integer; null 0.0%; tahun';
COMMENT ON COLUMN stg.src_06_ookla_tiles.lon IS 'sumber: lon; tipe terdeteksi: numeric; null 0.0%; bujur';
COMMENT ON COLUMN stg.src_06_ookla_tiles.lat IS 'sumber: lat; tipe terdeteksi: numeric; null 0.0%; lintang';

CREATE TABLE IF NOT EXISTS stg.src_07_gppd (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-07',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    country text,
    country_long text,
    name text,
    gppd_idnr text,
    capacity_mw numeric,
    latitude numeric(10,7),
    longitude numeric(10,7),
    primary_fuel text,
    other_fuel1 text,
    other_fuel2 text,
    other_fuel3 text,
    commissioning_year integer,
    owner text,
    source text,
    url text,
    geolocation_source text,
    wepp_id integer,
    year_of_capacity_data text,
    generation_gwh_2013 text,
    generation_gwh_2014 text,
    generation_gwh_2015 text,
    generation_gwh_2016 text,
    generation_gwh_2017 text,
    generation_gwh_2018 text,
    generation_gwh_2019 text,
    generation_data_source text,
    estimated_generation_gwh_2013 numeric,
    estimated_generation_gwh_2014 numeric,
    estimated_generation_gwh_2015 numeric,
    estimated_generation_gwh_2016 numeric,
    estimated_generation_gwh_2017 numeric,
    estimated_generation_note_2013 text,
    estimated_generation_note_2014 text,
    estimated_generation_note_2015 text,
    estimated_generation_note_2016 text,
    estimated_generation_note_2017 text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_07_gppd.country IS 'sumber: country; tipe terdeteksi: text; null 0.0%; panjang 3-3';
COMMENT ON COLUMN stg.src_07_gppd.country_long IS 'sumber: country_long; tipe terdeteksi: text; null 0.0%; panjang 9-9';
COMMENT ON COLUMN stg.src_07_gppd.name IS 'sumber: name; tipe terdeteksi: text; null 0.0%; panjang 4-41';
COMMENT ON COLUMN stg.src_07_gppd.gppd_idnr IS 'sumber: gppd_idnr; tipe terdeteksi: text; null 0.0%; panjang 10-10';
COMMENT ON COLUMN stg.src_07_gppd.capacity_mw IS 'sumber: capacity_mw; tipe terdeteksi: numeric; null 0.0%; maks 3 digit desimal';
COMMENT ON COLUMN stg.src_07_gppd.latitude IS 'sumber: latitude; tipe terdeteksi: numeric; null 0.0%; lintang';
COMMENT ON COLUMN stg.src_07_gppd.longitude IS 'sumber: longitude; tipe terdeteksi: numeric; null 0.0%; bujur';
COMMENT ON COLUMN stg.src_07_gppd.primary_fuel IS 'sumber: primary_fuel; tipe terdeteksi: text; null 0.0%; panjang 3-10';
COMMENT ON COLUMN stg.src_07_gppd.other_fuel1 IS 'sumber: other_fuel1; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.other_fuel2 IS 'sumber: other_fuel2; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.other_fuel3 IS 'sumber: other_fuel3; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.commissioning_year IS 'sumber: commissioning_year; tipe terdeteksi: integer; null 88.8%; tahun';
COMMENT ON COLUMN stg.src_07_gppd.owner IS 'sumber: owner; tipe terdeteksi: text; null 0.0%; panjang 3-111';
COMMENT ON COLUMN stg.src_07_gppd.source IS 'sumber: source; tipe terdeteksi: text; null 0.0%; panjang 4-26';
COMMENT ON COLUMN stg.src_07_gppd.url IS 'sumber: url; tipe terdeteksi: text; null 0.0%; panjang 28-46';
COMMENT ON COLUMN stg.src_07_gppd.geolocation_source IS 'sumber: geolocation_source; tipe terdeteksi: text; null 0.0%; panjang 3-5';
COMMENT ON COLUMN stg.src_07_gppd.wepp_id IS 'sumber: wepp_id; tipe terdeteksi: integer; null 34.3%';
COMMENT ON COLUMN stg.src_07_gppd.year_of_capacity_data IS 'sumber: year_of_capacity_data; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.generation_gwh_2013 IS 'sumber: generation_gwh_2013; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.generation_gwh_2014 IS 'sumber: generation_gwh_2014; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.generation_gwh_2015 IS 'sumber: generation_gwh_2015; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.generation_gwh_2016 IS 'sumber: generation_gwh_2016; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.generation_gwh_2017 IS 'sumber: generation_gwh_2017; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.generation_gwh_2018 IS 'sumber: generation_gwh_2018; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.generation_gwh_2019 IS 'sumber: generation_gwh_2019; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.generation_data_source IS 'sumber: generation_data_source; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_07_gppd.estimated_generation_gwh_2013 IS 'sumber: estimated_generation_gwh_2013; tipe terdeteksi: numeric; null 77.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_07_gppd.estimated_generation_gwh_2014 IS 'sumber: estimated_generation_gwh_2014; tipe terdeteksi: numeric; null 77.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_07_gppd.estimated_generation_gwh_2015 IS 'sumber: estimated_generation_gwh_2015; tipe terdeteksi: numeric; null 77.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_07_gppd.estimated_generation_gwh_2016 IS 'sumber: estimated_generation_gwh_2016; tipe terdeteksi: numeric; null 77.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_07_gppd.estimated_generation_gwh_2017 IS 'sumber: estimated_generation_gwh_2017; tipe terdeteksi: numeric; null 5.6%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_07_gppd.estimated_generation_note_2013 IS 'sumber: estimated_generation_note_2013; tipe terdeteksi: text; null 0.0%; panjang 8-13';
COMMENT ON COLUMN stg.src_07_gppd.estimated_generation_note_2014 IS 'sumber: estimated_generation_note_2014; tipe terdeteksi: text; null 0.0%; panjang 8-13';
COMMENT ON COLUMN stg.src_07_gppd.estimated_generation_note_2015 IS 'sumber: estimated_generation_note_2015; tipe terdeteksi: text; null 0.0%; panjang 8-13';
COMMENT ON COLUMN stg.src_07_gppd.estimated_generation_note_2016 IS 'sumber: estimated_generation_note_2016; tipe terdeteksi: text; null 0.0%; panjang 8-13';
COMMENT ON COLUMN stg.src_07_gppd.estimated_generation_note_2017 IS 'sumber: estimated_generation_note_2017; tipe terdeteksi: text; null 0.0%; panjang 8-18';

CREATE TABLE IF NOT EXISTS stg.src_08_osm_gardu (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-08',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    id text,
    id_2 text,
    m_hazard_prone boolean,
    access_roof boolean,
    addr_city text,
    addr_country text,
    addr_full text,
    addr_housenumber integer,
    addr_postcode integer,
    addr_street text,
    addr_subdistrict text,
    alt_name text,
    amenity text,
    backup_generator boolean,
    barrier text,
    building text,
    building_condition text,
    building_levels integer,
    building_material text,
    building_roof text,
    building_structure text,
    building_use text,
    building_walls text,
    cables integer,
    capacity text,
    check_date date,
    description text,
    design text,
    designation text,
    fixme text,
    frequency integer,
    gas_insulated boolean,
    generator_source text,
    height integer,
    landuse text,
    layer integer,
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
    opening_date integer,
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
    roof_levels integer,
    roof_material text,
    roof_orientation text,
    roof_shape text,
    shelter_type text,
    short_name text,
    source text,
    start_date integer,
    substation text,
    type text,
    utility text,
    voltage text,
    geometry text,
    longitude numeric(10,7),
    latitude numeric(10,7),
    geometry_wkt text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_08_osm_gardu.id IS 'sumber: id; tipe terdeteksi: text; null 0.0%; panjang 12-17';
COMMENT ON COLUMN stg.src_08_osm_gardu.id_2 IS 'sumber: @id; tipe terdeteksi: text; null 0.0%; panjang 12-17';
COMMENT ON COLUMN stg.src_08_osm_gardu.m_hazard_prone IS 'sumber: M:hazard_prone; tipe terdeteksi: boolean; null 99.9%';
COMMENT ON COLUMN stg.src_08_osm_gardu.access_roof IS 'sumber: access:roof; tipe terdeteksi: boolean; null 98.5%';
COMMENT ON COLUMN stg.src_08_osm_gardu.addr_city IS 'sumber: addr:city; tipe terdeteksi: text; null 48.5%; panjang 6-20';
COMMENT ON COLUMN stg.src_08_osm_gardu.addr_country IS 'sumber: addr:country; tipe terdeteksi: text; null 100.0%; panjang 2-2';
COMMENT ON COLUMN stg.src_08_osm_gardu.addr_full IS 'sumber: addr:full; tipe terdeteksi: text; null 56.4%; panjang 7-122';
COMMENT ON COLUMN stg.src_08_osm_gardu.addr_housenumber IS 'sumber: addr:housenumber; tipe terdeteksi: integer; null 99.9%';
COMMENT ON COLUMN stg.src_08_osm_gardu.addr_postcode IS 'sumber: addr:postcode; tipe terdeteksi: integer; null 99.8%';
COMMENT ON COLUMN stg.src_08_osm_gardu.addr_street IS 'sumber: addr:street; tipe terdeteksi: text; null 99.7%; panjang 9-29';
COMMENT ON COLUMN stg.src_08_osm_gardu.addr_subdistrict IS 'sumber: addr:subdistrict; tipe terdeteksi: text; null 100.0%; panjang 6-6';
COMMENT ON COLUMN stg.src_08_osm_gardu.alt_name IS 'sumber: alt_name; tipe terdeteksi: text; null 99.4%; panjang 9-98';
COMMENT ON COLUMN stg.src_08_osm_gardu.amenity IS 'sumber: amenity; tipe terdeteksi: text; null 100.0%; panjang 10-10';
COMMENT ON COLUMN stg.src_08_osm_gardu.backup_generator IS 'sumber: backup_generator; tipe terdeteksi: boolean; null 98.4%';
COMMENT ON COLUMN stg.src_08_osm_gardu.barrier IS 'sumber: barrier; tipe terdeteksi: text; null 99.1%; panjang 3-5';
COMMENT ON COLUMN stg.src_08_osm_gardu.building IS 'sumber: building; tipe terdeteksi: text; null 45.3%; panjang 2-16';
COMMENT ON COLUMN stg.src_08_osm_gardu.building_condition IS 'sumber: building:condition; tipe terdeteksi: text; null 99.6%; panjang 4-4';
COMMENT ON COLUMN stg.src_08_osm_gardu.building_levels IS 'sumber: building:levels; tipe terdeteksi: integer; null 99.5%';
COMMENT ON COLUMN stg.src_08_osm_gardu.building_material IS 'sumber: building:material; tipe terdeteksi: text; null 100.0%; panjang 5-5';
COMMENT ON COLUMN stg.src_08_osm_gardu.building_roof IS 'sumber: building:roof; tipe terdeteksi: text; null 100.0%; panjang 8-8';
COMMENT ON COLUMN stg.src_08_osm_gardu.building_structure IS 'sumber: building:structure; tipe terdeteksi: text; null 100.0%; panjang 20-20';
COMMENT ON COLUMN stg.src_08_osm_gardu.building_use IS 'sumber: building:use; tipe terdeteksi: text; null 100.0%; panjang 9-9';
COMMENT ON COLUMN stg.src_08_osm_gardu.building_walls IS 'sumber: building:walls; tipe terdeteksi: text; null 100.0%; panjang 5-5';
COMMENT ON COLUMN stg.src_08_osm_gardu.cables IS 'sumber: cables; tipe terdeteksi: integer; null 99.9%';
COMMENT ON COLUMN stg.src_08_osm_gardu.capacity IS 'sumber: capacity; tipe terdeteksi: text; null 100.0%; panjang 5-5';
COMMENT ON COLUMN stg.src_08_osm_gardu.check_date IS 'sumber: check_date; tipe terdeteksi: date; null 100.0%';
COMMENT ON COLUMN stg.src_08_osm_gardu.description IS 'sumber: description; tipe terdeteksi: text; null 99.9%; panjang 10-11';
COMMENT ON COLUMN stg.src_08_osm_gardu.design IS 'sumber: design; tipe terdeteksi: text; null 100.0%; panjang 11-11';
COMMENT ON COLUMN stg.src_08_osm_gardu.designation IS 'sumber: designation; tipe terdeteksi: text; null 99.9%; panjang 8-22';
COMMENT ON COLUMN stg.src_08_osm_gardu.fixme IS 'sumber: fixme; tipe terdeteksi: text; null 99.6%; panjang 6-31';
COMMENT ON COLUMN stg.src_08_osm_gardu.frequency IS 'sumber: frequency; tipe terdeteksi: integer; null 97.3%';
COMMENT ON COLUMN stg.src_08_osm_gardu.gas_insulated IS 'sumber: gas_insulated; tipe terdeteksi: boolean; null 98.9%';
COMMENT ON COLUMN stg.src_08_osm_gardu.generator_source IS 'sumber: generator:source; tipe terdeteksi: text; null 100.0%; panjang 5-5';
COMMENT ON COLUMN stg.src_08_osm_gardu.height IS 'sumber: height; tipe terdeteksi: integer; null 99.8%';
COMMENT ON COLUMN stg.src_08_osm_gardu.landuse IS 'sumber: landuse; tipe terdeteksi: text; null 99.9%; panjang 10-10';
COMMENT ON COLUMN stg.src_08_osm_gardu.layer IS 'sumber: layer; tipe terdeteksi: integer; null 99.9%';
COMMENT ON COLUMN stg.src_08_osm_gardu.leisure IS 'sumber: leisure; tipe terdeteksi: text; null 100.0%; panjang 4-4';
COMMENT ON COLUMN stg.src_08_osm_gardu.location IS 'sumber: location; tipe terdeteksi: text; null 62.0%; panjang 6-7';
COMMENT ON COLUMN stg.src_08_osm_gardu.man_made IS 'sumber: man_made; tipe terdeteksi: text; null 100.0%; panjang 5-5';
COMMENT ON COLUMN stg.src_08_osm_gardu.name IS 'sumber: name; tipe terdeteksi: text; null 14.1%; panjang 2-71';
COMMENT ON COLUMN stg.src_08_osm_gardu.name_en IS 'sumber: name:en; tipe terdeteksi: text; null 99.9%; panjang 19-20';
COMMENT ON COLUMN stg.src_08_osm_gardu.name_id IS 'sumber: name:id; tipe terdeteksi: text; null 99.9%; panjang 17-24';
COMMENT ON COLUMN stg.src_08_osm_gardu.name_ms IS 'sumber: name:ms; tipe terdeteksi: text; null 100.0%; panjang 24-24';
COMMENT ON COLUMN stg.src_08_osm_gardu.not_operator_wikidata IS 'sumber: not:operator:wikidata; tipe terdeteksi: text; null 99.9%; panjang 8-8';
COMMENT ON COLUMN stg.src_08_osm_gardu.note IS 'sumber: note; tipe terdeteksi: text; null 99.9%; panjang 11-14';
COMMENT ON COLUMN stg.src_08_osm_gardu.office IS 'sumber: office; tipe terdeteksi: text; null 99.9%; panjang 7-23';
COMMENT ON COLUMN stg.src_08_osm_gardu.official_name IS 'sumber: official_name; tipe terdeteksi: text; null 99.8%; panjang 39-48';
COMMENT ON COLUMN stg.src_08_osm_gardu.opening_date IS 'sumber: opening_date; tipe terdeteksi: integer; null 100.0%';
COMMENT ON COLUMN stg.src_08_osm_gardu.opening_hours IS 'sumber: opening_hours; tipe terdeteksi: text; null 99.9%; panjang 4-17';
COMMENT ON COLUMN stg.src_08_osm_gardu.operator IS 'sumber: operator; tipe terdeteksi: text; null 12.7%; panjang 3-48';
COMMENT ON COLUMN stg.src_08_osm_gardu.operator_short IS 'sumber: operator:short; tipe terdeteksi: text; null 58.1%; panjang 3-3';
COMMENT ON COLUMN stg.src_08_osm_gardu.operator_wikidata IS 'sumber: operator:wikidata; tipe terdeteksi: text; null 58.0%; panjang 7-8';
COMMENT ON COLUMN stg.src_08_osm_gardu.operator_wikipedia IS 'sumber: operator:wikipedia; tipe terdeteksi: text; null 94.6%; panjang 28-28';
COMMENT ON COLUMN stg.src_08_osm_gardu.phone IS 'sumber: phone; tipe terdeteksi: text; null 99.9%; panjang 14-14';
COMMENT ON COLUMN stg.src_08_osm_gardu.power IS 'sumber: power; tipe terdeteksi: text; null 0.0%; panjang 10-10';
COMMENT ON COLUMN stg.src_08_osm_gardu.power_supply IS 'sumber: power_supply; tipe terdeteksi: text; null 100.0%; panjang 7-7';
COMMENT ON COLUMN stg.src_08_osm_gardu.public_service_provider_type_idn IS 'sumber: public_service_provider:type_idn; tipe terdeteksi: text; null 100.0%; panjang 3-3';
COMMENT ON COLUMN stg.src_08_osm_gardu.rating IS 'sumber: rating; tipe terdeteksi: text; null 89.7%; panjang 1-13';
COMMENT ON COLUMN stg.src_08_osm_gardu.ref IS 'sumber: ref; tipe terdeteksi: text; null 98.7%; panjang 2-12';
COMMENT ON COLUMN stg.src_08_osm_gardu.roof_levels IS 'sumber: roof:levels; tipe terdeteksi: integer; null 99.9%';
COMMENT ON COLUMN stg.src_08_osm_gardu.roof_material IS 'sumber: roof:material; tipe terdeteksi: text; null 99.9%; panjang 10-10';
COMMENT ON COLUMN stg.src_08_osm_gardu.roof_orientation IS 'sumber: roof:orientation; tipe terdeteksi: text; null 99.9%; panjang 5-5';
COMMENT ON COLUMN stg.src_08_osm_gardu.roof_shape IS 'sumber: roof:shape; tipe terdeteksi: text; null 99.8%; panjang 4-6';
COMMENT ON COLUMN stg.src_08_osm_gardu.shelter_type IS 'sumber: shelter_type; tipe terdeteksi: text; null 100.0%; panjang 8-8';
COMMENT ON COLUMN stg.src_08_osm_gardu.short_name IS 'sumber: short_name; tipe terdeteksi: text; null 99.4%; panjang 7-28';
COMMENT ON COLUMN stg.src_08_osm_gardu.source IS 'sumber: source; tipe terdeteksi: text; null 47.3%; panjang 4-38';
COMMENT ON COLUMN stg.src_08_osm_gardu.start_date IS 'sumber: start_date; tipe terdeteksi: integer; null 100.0%';
COMMENT ON COLUMN stg.src_08_osm_gardu.substation IS 'sumber: substation; tipe terdeteksi: text; null 15.1%; panjang 3-26';
COMMENT ON COLUMN stg.src_08_osm_gardu.type IS 'sumber: type; tipe terdeteksi: text; null 99.9%; panjang 12-12';
COMMENT ON COLUMN stg.src_08_osm_gardu.utility IS 'sumber: utility; tipe terdeteksi: text; null 98.7%; panjang 5-5';
COMMENT ON COLUMN stg.src_08_osm_gardu.voltage IS 'sumber: voltage; tipe terdeteksi: text; null 61.1%; panjang 3-20';
COMMENT ON COLUMN stg.src_08_osm_gardu.geometry IS 'sumber: @geometry; tipe terdeteksi: text; null 2.4%; panjang 6-6';
COMMENT ON COLUMN stg.src_08_osm_gardu.longitude IS 'sumber: longitude; tipe terdeteksi: numeric; null 0.0%; bujur';
COMMENT ON COLUMN stg.src_08_osm_gardu.latitude IS 'sumber: latitude; tipe terdeteksi: numeric; null 0.0%; lintang';
COMMENT ON COLUMN stg.src_08_osm_gardu.geometry_wkt IS 'sumber: geometry_wkt; tipe terdeteksi: geometry_wkt; null 0.0%; WKT; jadikan geometry(...,4326) di staging bila PostGIS aktif';

CREATE TABLE IF NOT EXISTS stg.src_09_pop_isp (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-09',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    provinsi text,
    sebaran_pop_isp integer,
    tahun integer,
    source text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_09_pop_isp.provinsi IS 'sumber: Provinsi; tipe terdeteksi: text; null 0.0%; panjang 4-25';
COMMENT ON COLUMN stg.src_09_pop_isp.sebaran_pop_isp IS 'sumber: Sebaran PoP ISP; tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_09_pop_isp.tahun IS 'sumber: Tahun; tipe terdeteksi: integer; null 0.0%; tahun';
COMMENT ON COLUMN stg.src_09_pop_isp.source IS 'sumber: Source; tipe terdeteksi: text; null 0.0%; panjang 29-29';

CREATE TABLE IF NOT EXISTS stg.src_10_iklh_provinsi (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-10',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    provinsi text,
    indeks_kualitas_udara numeric,
    indeks_kualitas_air numeric,
    indeks_kualitas_tutupan_lahan_iktl numeric,
    indeks_kualitas_lahan_ikl numeric,
    indeks_kualitas_ekosistem_gambut_ikeg numeric,
    indeks_kualitas_air_laut_ikal numeric,
    tahun integer,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_10_iklh_provinsi.provinsi IS 'sumber: provinsi; tipe terdeteksi: text; null 0.0%; panjang 4-20';
COMMENT ON COLUMN stg.src_10_iklh_provinsi.indeks_kualitas_udara IS 'sumber: Indeks Kualitas Udara; tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_10_iklh_provinsi.indeks_kualitas_air IS 'sumber: Indeks Kualitas Air; tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_10_iklh_provinsi.indeks_kualitas_tutupan_lahan_iktl IS 'sumber: Indeks Kualitas Tutupan Lahan (IKTL); tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_10_iklh_provinsi.indeks_kualitas_lahan_ikl IS 'sumber: Indeks Kualitas Lahan (IKL); tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_10_iklh_provinsi.indeks_kualitas_ekosistem_gambut_ikeg IS 'sumber: Indeks Kualitas Ekosistem Gambut (IKEG); tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_10_iklh_provinsi.indeks_kualitas_air_laut_ikal IS 'sumber: Indeks Kualitas Air Laut (IKAL); tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_10_iklh_provinsi.tahun IS 'sumber: tahun; tipe terdeteksi: integer; null 0.0%; tahun';

CREATE TABLE IF NOT EXISTS stg.src_11_adm1 (
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
    valid_on date,
    valid_to text,
    area_sqkm numeric,
    version text,
    lang text,
    lang1 text,
    lang2 text,
    lang3 text,
    adm1_ref_name text,
    center_lat numeric(10,7),
    center_lon numeric(10,7),
    geometry_type text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_11_adm1.adm1_name IS 'sumber: adm1_name; tipe terdeteksi: text; null 0.0%; panjang 4-26';
COMMENT ON COLUMN stg.src_11_adm1.adm1_name1 IS 'sumber: adm1_name1; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm1.adm1_name2 IS 'sumber: adm1_name2; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm1.adm1_name3 IS 'sumber: adm1_name3; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm1.adm1_pcode IS 'sumber: adm1_pcode; tipe terdeteksi: text; null 0.0%; panjang 4-4';
COMMENT ON COLUMN stg.src_11_adm1.adm0_name IS 'sumber: adm0_name; tipe terdeteksi: text; null 0.0%; panjang 9-9';
COMMENT ON COLUMN stg.src_11_adm1.adm0_name1 IS 'sumber: adm0_name1; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm1.adm0_name2 IS 'sumber: adm0_name2; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm1.adm0_name3 IS 'sumber: adm0_name3; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm1.adm0_pcode IS 'sumber: adm0_pcode; tipe terdeteksi: text; null 0.0%; panjang 2-2';
COMMENT ON COLUMN stg.src_11_adm1.valid_on IS 'sumber: valid_on; tipe terdeteksi: date; null 0.0%';
COMMENT ON COLUMN stg.src_11_adm1.valid_to IS 'sumber: valid_to; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm1.area_sqkm IS 'sumber: area_sqkm; tipe terdeteksi: numeric; null 0.0%; maks 8 digit desimal';
COMMENT ON COLUMN stg.src_11_adm1.version IS 'sumber: version; tipe terdeteksi: text; null 0.0%; panjang 3-3';
COMMENT ON COLUMN stg.src_11_adm1.lang IS 'sumber: lang; tipe terdeteksi: text; null 0.0%; panjang 2-2';
COMMENT ON COLUMN stg.src_11_adm1.lang1 IS 'sumber: lang1; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm1.lang2 IS 'sumber: lang2; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm1.lang3 IS 'sumber: lang3; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm1.adm1_ref_name IS 'sumber: adm1_ref_name; tipe terdeteksi: text; null 0.0%; panjang 4-26';
COMMENT ON COLUMN stg.src_11_adm1.center_lat IS 'sumber: center_lat; tipe terdeteksi: numeric; null 0.0%; lintang';
COMMENT ON COLUMN stg.src_11_adm1.center_lon IS 'sumber: center_lon; tipe terdeteksi: numeric; null 0.0%; bujur';
COMMENT ON COLUMN stg.src_11_adm1.geometry_type IS 'sumber: _geometry_type; tipe terdeteksi: text; null 0.0%; panjang 12-12';

CREATE TABLE IF NOT EXISTS stg.src_11_adm2 (
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
    valid_on date,
    valid_to text,
    area_sqkm numeric,
    version text,
    lang text,
    lang1 text,
    lang2 text,
    lang3 text,
    adm2_ref_name text,
    center_lat numeric(10,7),
    center_lon numeric(10,7),
    geometry_type text,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_11_adm2.adm2_name IS 'sumber: adm2_name; tipe terdeteksi: text; null 0.0%; panjang 4-26';
COMMENT ON COLUMN stg.src_11_adm2.adm2_name1 IS 'sumber: adm2_name1; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.adm2_name2 IS 'sumber: adm2_name2; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.adm2_name3 IS 'sumber: adm2_name3; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.adm2_pcode IS 'sumber: adm2_pcode; tipe terdeteksi: text; null 0.0%; panjang 6-6';
COMMENT ON COLUMN stg.src_11_adm2.adm1_name IS 'sumber: adm1_name; tipe terdeteksi: text; null 0.0%; panjang 4-26';
COMMENT ON COLUMN stg.src_11_adm2.adm1_name1 IS 'sumber: adm1_name1; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.adm1_name2 IS 'sumber: adm1_name2; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.adm1_name3 IS 'sumber: adm1_name3; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.adm1_pcode IS 'sumber: adm1_pcode; tipe terdeteksi: text; null 0.0%; panjang 4-4';
COMMENT ON COLUMN stg.src_11_adm2.adm0_name IS 'sumber: adm0_name; tipe terdeteksi: text; null 0.0%; panjang 9-9';
COMMENT ON COLUMN stg.src_11_adm2.adm0_name1 IS 'sumber: adm0_name1; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.adm0_name2 IS 'sumber: adm0_name2; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.adm0_name3 IS 'sumber: adm0_name3; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.adm0_pcode IS 'sumber: adm0_pcode; tipe terdeteksi: text; null 0.0%; panjang 2-2';
COMMENT ON COLUMN stg.src_11_adm2.valid_on IS 'sumber: valid_on; tipe terdeteksi: date; null 0.0%';
COMMENT ON COLUMN stg.src_11_adm2.valid_to IS 'sumber: valid_to; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.area_sqkm IS 'sumber: area_sqkm; tipe terdeteksi: numeric; null 0.0%; maks 8 digit desimal';
COMMENT ON COLUMN stg.src_11_adm2.version IS 'sumber: version; tipe terdeteksi: text; null 0.0%; panjang 3-3';
COMMENT ON COLUMN stg.src_11_adm2.lang IS 'sumber: lang; tipe terdeteksi: text; null 0.0%; panjang 2-2';
COMMENT ON COLUMN stg.src_11_adm2.lang1 IS 'sumber: lang1; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.lang2 IS 'sumber: lang2; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.lang3 IS 'sumber: lang3; tipe terdeteksi: empty; null 100.0%';
COMMENT ON COLUMN stg.src_11_adm2.adm2_ref_name IS 'sumber: adm2_ref_name; tipe terdeteksi: text; null 0.0%; panjang 4-26';
COMMENT ON COLUMN stg.src_11_adm2.center_lat IS 'sumber: center_lat; tipe terdeteksi: numeric; null 0.0%; lintang';
COMMENT ON COLUMN stg.src_11_adm2.center_lon IS 'sumber: center_lon; tipe terdeteksi: numeric; null 0.0%; bujur';
COMMENT ON COLUMN stg.src_11_adm2.geometry_type IS 'sumber: _geometry_type; tipe terdeteksi: text; null 0.0%; panjang 7-12';

CREATE TABLE IF NOT EXISTS stg.src_12_penduduk_provinsi (
    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id
    _src_id     text        NOT NULL DEFAULT 'SRC-12',
    _src_file   text        NOT NULL,
    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber
    _loaded_at  timestamptz NOT NULL DEFAULT now(),
    provinsi text,
    jumlah_penduduk_ribu numeric,
    laju_pertumbuhan_penduduk_per_tahun numeric,
    persentase_penduduk numeric,
    kepadatan_penduduk_per_km_persegi_km2 integer,
    rasio_jenis_kelamin_penduduk numeric,
    tahun integer,
    PRIMARY KEY (_batch_id, _src_file, _row_no)
);
COMMENT ON COLUMN stg.src_12_penduduk_provinsi.provinsi IS 'sumber: Provinsi; tipe terdeteksi: text; null 0.0%; panjang 4-25';
COMMENT ON COLUMN stg.src_12_penduduk_provinsi.jumlah_penduduk_ribu IS 'sumber: Jumlah Penduduk (Ribu); tipe terdeteksi: numeric; null 0.0%; maks 1 digit desimal';
COMMENT ON COLUMN stg.src_12_penduduk_provinsi.laju_pertumbuhan_penduduk_per_tahun IS 'sumber: Laju Pertumbuhan Penduduk per Tahun; tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_12_penduduk_provinsi.persentase_penduduk IS 'sumber: Persentase Penduduk; tipe terdeteksi: numeric; null 0.0%; maks 2 digit desimal';
COMMENT ON COLUMN stg.src_12_penduduk_provinsi.kepadatan_penduduk_per_km_persegi_km2 IS 'sumber: Kepadatan Penduduk per km persegi (Km2); tipe terdeteksi: integer; null 0.0%';
COMMENT ON COLUMN stg.src_12_penduduk_provinsi.rasio_jenis_kelamin_penduduk IS 'sumber: Rasio Jenis Kelamin Penduduk; tipe terdeteksi: numeric; null 0.0%; maks 1 digit desimal';
COMMENT ON COLUMN stg.src_12_penduduk_provinsi.tahun IS 'sumber: tahun; tipe terdeteksi: integer; null 0.0%; tahun';
