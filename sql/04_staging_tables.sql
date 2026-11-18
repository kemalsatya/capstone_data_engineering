-- =============================================================================
-- DDL SCHEMA STAGING: Data Produk Intelijen Fasilitas Kritis (Data Center Site Suitability)
-- Layer Pembersihan & Standardisasi Tipe Data (stg.*)
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS stg;

-- -----------------------------------------------------------------------------
-- 1. Gempa Bumi BMKG
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.earthquakes (
    earthquake_id BIGSERIAL PRIMARY KEY,
    event_id TEXT UNIQUE,
    event_timestamp TIMESTAMPTZ,
    event_date DATE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    magnitude NUMERIC(4,2) NOT NULL,
    mag_type TEXT,
    depth_km NUMERIC(6,2),
    source TEXT,
    is_significant BOOLEAN DEFAULT FALSE, -- Flag M >= 5.0
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 2. Kejadian Bencana BNPB/BPBD
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.disasters (
    disaster_id BIGSERIAL PRIMARY KEY,
    city_id TEXT,
    event_date DATE,
    disaster_type TEXT NOT NULL,
    city_name TEXT,
    province_name TEXT,
    cause TEXT,
    death_count INTEGER DEFAULT 0,
    missing_count INTEGER DEFAULT 0,
    injured_count INTEGER DEFAULT 0,
    damaged_house_count INTEGER DEFAULT 0,
    flooded_house_count INTEGER DEFAULT 0,
    damaged_facility_count INTEGER DEFAULT 0,
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 3. Stasiun & Cuaca BMKG
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.climate_stations (
    station_id TEXT PRIMARY KEY,
    station_name TEXT NOT NULL,
    region_name TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    province_name TEXT,
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stg.climate_daily (
    climate_id BIGSERIAL PRIMARY KEY,
    station_id TEXT REFERENCES stg.climate_stations(station_id),
    obs_date DATE NOT NULL,
    temp_min_c NUMERIC(4,1),
    temp_max_c NUMERIC(4,1),
    temp_avg_c NUMERIC(4,1),
    humidity_avg_pct NUMERIC(4,1),
    rainfall_mm NUMERIC(6,1),
    sunshine_hours NUMERIC(4,1),
    wind_speed_avg_ms NUMERIC(4,1),
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 4. Fitur Agregat Regional (Master Features Kab/Kota)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.regional_features (
    bps_kabkota_code TEXT PRIMARY KEY,
    kabkota_name TEXT NOT NULL,
    province_name TEXT NOT NULL,
    ipm_2024 NUMERIC(5,2),
    population_2024 INTEGER,
    elevation_mean_m NUMERIC(7,2),
    pct_built_up NUMERIC(5,2),
    tertinggal_status TEXT,
    temp_ambient_mean_c NUMERIC(4,2),
    humidity_ambient_mean_pct NUMERIC(5,2),
    rainfall_ambient_mean_mm NUMERIC(6,2),
    road_density_km_per_km2 NUMERIC(6,2),
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 5. Menara Seluler BTS (OpenCelliD)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.cell_towers (
    tower_id BIGSERIAL PRIMARY KEY,
    radio_type TEXT,
    mcc TEXT,
    net TEXT,
    cell_id TEXT,
    longitude DOUBLE PRECISION NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    coverage_range_m INTEGER,
    samples_count INTEGER,
    updated_at TIMESTAMPTZ,
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 6. Ookla Fixed Broadband Performance
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.ookla_broadband (
    tile_id BIGSERIAL PRIMARY KEY,
    quadkey TEXT,
    tile_center_lon DOUBLE PRECISION NOT NULL,
    tile_center_lat DOUBLE PRECISION NOT NULL,
    avg_download_mbps NUMERIC(8,2),
    avg_upload_mbps NUMERIC(8,2),
    avg_latency_ms INTEGER,
    test_count INTEGER,
    device_count INTEGER,
    year_val INTEGER,
    quarter_val INTEGER,
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 7. Pembangkit Listrik (Wilayah Indonesia Saja)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.power_plants (
    plant_id BIGSERIAL PRIMARY KEY,
    gppd_idnr TEXT UNIQUE,
    name TEXT NOT NULL,
    capacity_mw NUMERIC(10,2) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    primary_fuel TEXT NOT NULL,
    is_renewable BOOLEAN DEFAULT FALSE,
    commissioning_year INTEGER,
    owner TEXT,
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 8. Gardu Induk & Jaringan Listrik PLN
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.substations (
    substation_id BIGSERIAL PRIMARY KEY,
    osm_id TEXT UNIQUE,
    name TEXT,
    operator TEXT,
    voltage_kv NUMERIC(6,1),
    longitude DOUBLE PRECISION NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    geometry_wkt TEXT,
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 9. Sebaran PoP ISP
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.isp_points_of_presence (
    pop_id BIGSERIAL PRIMARY KEY,
    province_name TEXT NOT NULL,
    pop_count INTEGER NOT NULL,
    year_val INTEGER,
    loaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 10. Kualitas Air (Fokus IKA untuk Sistem Pendingin DC)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.water_quality_index (
    wqi_id BIGSERIAL PRIMARY KEY,
    province_name TEXT NOT NULL,
    year_val INTEGER NOT NULL,
    water_quality_index NUMERIC(5,2) NOT NULL, -- IKA
    air_quality_index NUMERIC(5,2),
    loaded_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (province_name, year_val)
);

-- -----------------------------------------------------------------------------
-- 11. Batas Wilayah Administrasi Spasial
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.admin_boundaries (
    boundary_id BIGSERIAL PRIMARY KEY,
    admin_level INTEGER NOT NULL,
    pcode TEXT NOT NULL,
    name TEXT NOT NULL,
    parent_pcode TEXT,
    parent_name TEXT,
    center_lat DOUBLE PRECISION,
    center_lon DOUBLE PRECISION,
    area_sqkm DOUBLE PRECISION,
    geom_geojson TEXT,
    loaded_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (admin_level, pcode)
);

-- -----------------------------------------------------------------------------
-- 12. Demografi & Kepadatan Penduduk (BPS)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.population_demographics (
    demo_id BIGSERIAL PRIMARY KEY,
    province_name TEXT NOT NULL,
    year_val INTEGER NOT NULL,
    population_thousands NUMERIC(10,2),
    growth_rate_pct NUMERIC(5,2),
    density_per_km2 NUMERIC(10,2),
    sex_ratio NUMERIC(5,2),
    loaded_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (province_name, year_val)
);
