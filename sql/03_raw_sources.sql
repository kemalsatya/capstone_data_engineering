-- =============================================================================
-- DDL SCHEMA RAW: Data Produk Intelijen Fasilitas Kritis (Data Center Site Suitability)
-- Sumber Data SRC-01 s/d SRC-12
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS raw;

-- -----------------------------------------------------------------------------
-- SRC-01: BMKG Earthquake Catalog
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src01_earthquake_catalog (
    id BIGSERIAL PRIMARY KEY,
    no_urutan TEXT,
    event_id TEXT,
    event_date TEXT,
    time_utc TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    magnitude NUMERIC(5,2),
    mag_type TEXT,
    depth_km NUMERIC(8,2),
    source TEXT,
    source_event_id TEXT,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- SRC-02: Rekapitulasi Data Bencana BNPB/BPBD
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src02_disaster_records (
    id BIGSERIAL PRIMARY KEY,
    city_id TEXT,
    event_date_serial TEXT,
    disaster_type TEXT,
    city TEXT,
    province TEXT,
    cause TEXT,
    death NUMERIC(10,2),
    missing_person NUMERIC(10,2),
    injured_person NUMERIC(10,2),
    damaged_house NUMERIC(10,2),
    flooded_house NUMERIC(10,2),
    damaged_facility NUMERIC(10,2),
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- SRC-03: BMKG Data Iklim Harian & Master Stasiun/Provinsi
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src03_climate_daily (
    id BIGSERIAL PRIMARY KEY,
    obs_date TEXT,
    tn NUMERIC(6,2),
    tx NUMERIC(6,2),
    tavg NUMERIC(6,2),
    rh_avg NUMERIC(6,2),
    rr NUMERIC(8,2),
    ss NUMERIC(6,2),
    ff_x NUMERIC(6,2),
    ddd_x NUMERIC(6,2),
    ff_avg NUMERIC(6,2),
    ddd_car TEXT,
    station_id TEXT,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw.src03_station_detail (
    station_id TEXT PRIMARY KEY,
    station_name TEXT,
    region_name TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    region_id TEXT,
    province_id TEXT,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw.src03_province_detail (
    province_id TEXT PRIMARY KEY,
    province_name TEXT,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- SRC-04: Master Features & Agregat Baseline Kabupaten/Kota
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src04_master_features (
    bps_kabkota_code TEXT PRIMARY KEY,
    kabkota_name TEXT,
    prov_name TEXT,
    shape_name TEXT,
    crosswalk_match_type TEXT,
    crosswalk_match_score TEXT,
    ipm_2023 TEXT,
    ipm_2024 TEXT,
    ppm_2023 TEXT,
    ppm_2024 TEXT,
    population_2023 TEXT,
    population_2024 TEXT,
    ntl_radiance_mean TEXT,
    elevation_mean_m TEXT,
    elevation_std_m TEXT,
    pct_tree_cover TEXT,
    pct_built_up TEXT,
    pct_water TEXT,
    tertinggal_status TEXT,
    is_tertinggal TEXT,
    allsky_sfc_sw_dwn_mean TEXT,
    t2m_mean TEXT,
    ws10m_mean TEXT,
    ws50m_mean TEXT,
    rh2m_mean TEXT,
    prectotcorr_mean TEXT,
    road_length_km TEXT,
    road_density_km_per_km2 TEXT,
    dist_to_primary_trunk_km TEXT,
    centroid_type TEXT,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- SRC-05: Infrastruktur Telekomunikasi - Cell Towers (Menara BTS)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src05_cell_towers (
    id BIGSERIAL PRIMARY KEY,
    radio TEXT,
    mcc TEXT,
    net TEXT,
    area TEXT,
    cell TEXT,
    unit TEXT,
    lon DOUBLE PRECISION,
    lat DOUBLE PRECISION,
    range TEXT,
    samples TEXT,
    changeable TEXT,
    created_epoch TEXT,
    updated_epoch TEXT,
    average_signal TEXT,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- SRC-06: Kualitas Jaringan Internet - Ookla Fixed Broadband
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src06_ookla_fixed_broadband (
    id BIGSERIAL PRIMARY KEY,
    quadkey TEXT,
    tile_geom TEXT,
    tile_x DOUBLE PRECISION,
    tile_y DOUBLE PRECISION,
    avg_d_kbps BIGINT,
    avg_u_kbps BIGINT,
    avg_lat_ms INTEGER,
    avg_lat_down_ms INTEGER,
    avg_lat_up_ms INTEGER,
    tests INTEGER,
    devices INTEGER,
    quarter TEXT,
    network_type TEXT,
    year_val TEXT,
    lon DOUBLE PRECISION,
    lat DOUBLE PRECISION,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- SRC-07: Pembangkit Listrik (Global Power Plant Database)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src07_power_plants (
    id BIGSERIAL PRIMARY KEY,
    country TEXT,
    country_long TEXT,
    name TEXT,
    gppd_idnr TEXT,
    capacity_mw NUMERIC(12,3),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    primary_fuel TEXT,
    other_fuel1 TEXT,
    other_fuel2 TEXT,
    other_fuel3 TEXT,
    commissioning_year TEXT,
    owner TEXT,
    source TEXT,
    url TEXT,
    geolocation_source TEXT,
    wepp_id TEXT,
    year_of_capacity_data TEXT,
    generation_gwh_2019 TEXT,
    estimated_generation_gwh_2017 TEXT,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- SRC-08: Gardu Induk & Jaringan Listrik Elektrik (OpenStreetMap PLN)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src08_substations (
    id BIGSERIAL PRIMARY KEY,
    osm_id TEXT,
    name TEXT,
    operator TEXT,
    operator_short TEXT,
    power TEXT,
    substation TEXT,
    voltage TEXT,
    longitude DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    geometry_wkt TEXT,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- SRC-09: Point of Presence (POP) ISP di Indonesia (Komdigi)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src09_isp_pop (
    id BIGSERIAL PRIMARY KEY,
    province TEXT,
    pop_isp_count INTEGER,
    year_val TEXT,
    source_url TEXT,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- SRC-10: Indeks Kualitas Lingkungan Hidup (IKLH) KLHK
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src10_iklh (
    id BIGSERIAL PRIMARY KEY,
    province TEXT,
    indeks_kualitas_udara NUMERIC(6,2),
    indeks_kualitas_air NUMERIC(6,2),
    indeks_kualitas_tutupan_lahan NUMERIC(6,2),
    indeks_kualitas_lahan NUMERIC(6,2),
    indeks_kualitas_ekosistem_gambut NUMERIC(6,2),
    indeks_kualitas_air_laut NUMERIC(6,2),
    year_val INTEGER,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- SRC-11: Batas Administrasi Wilayah Spasial (Indonesia Admin 0, 1, 2)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src11_admin_boundaries (
    id BIGSERIAL PRIMARY KEY,
    admin_level INTEGER,
    pcode TEXT,
    name TEXT,
    parent_pcode TEXT,
    parent_name TEXT,
    center_lat DOUBLE PRECISION,
    center_lon DOUBLE PRECISION,
    area_sqkm DOUBLE PRECISION,
    geom_geojson TEXT,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- SRC-12: Demografi & Kepadatan Penduduk (BPS)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw.src12_population_demographics (
    id BIGSERIAL PRIMARY KEY,
    province TEXT,
    jumlah_penduduk_ribu NUMERIC(10,2),
    laju_pertumbuhan_tahunan NUMERIC(6,2),
    persentase_penduduk NUMERIC(6,2),
    kepadatan_per_km2 NUMERIC(10,2),
    rasio_jenis_kelamin NUMERIC(6,2),
    year_val INTEGER,
    _source_file TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW()
);
