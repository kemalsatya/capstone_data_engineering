-- =============================================================================
-- DDL SCHEMA MART: Data Produk Intelijen Lokasi Fasilitas Kritis
-- Site Suitability Score untuk Ekspansi Data Center di Indonesia
-- Layer Agregasi & Scoring (mart.*)
--
-- Keputusan Tim:
--   - Level Analisis : Kabupaten/Kota (514 wilayah)
--   - Metode Evaluasi: Two-Stage Filtering (Knock-out + Scoring 0-100)
--   - Bobot Standar  : Power 35% | Safety 25% | Network 25% | Environment 15%
--   - Window Gempa   : 26-thn (1998-2024) & 10-thn (2014-2024) di mart
--   - Papua NULL     : tetap NULL di stg, diakomodasi di mart
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS mart;

-- =============================================================================
-- DIMENSI 1: Wilayah (Kabupaten / Kota)
-- Kunci utama: bps_code (kode BPS 4-digit, cocok dengan stg.regional_features)
-- =============================================================================
CREATE TABLE IF NOT EXISTS mart.dim_wilayah (
    wilayah_id      BIGSERIAL PRIMARY KEY,
    bps_code        TEXT        NOT NULL UNIQUE,  -- ex: "1107" = Aceh Barat
    pcode           TEXT,                          -- ex: "ID1107" dari admin_boundaries
    kabkota_name    TEXT        NOT NULL,
    province_name   TEXT        NOT NULL,
    center_lat      DOUBLE PRECISION,
    center_lon      DOUBLE PRECISION,
    area_sqkm       DOUBLE PRECISION,
    geom_geojson    TEXT,
    population_2024 INTEGER,
    elevation_mean_m NUMERIC(7,2),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- DIMENSI 2: Profil Kelistrikan per Wilayah
-- =============================================================================
CREATE TABLE IF NOT EXISTS mart.dim_utilitas_energi (
    energi_id              BIGSERIAL PRIMARY KEY,
    bps_code               TEXT NOT NULL UNIQUE REFERENCES mart.dim_wilayah(bps_code),
    -- Gardu Induk
    nearest_substation_km  NUMERIC(7,2),  -- Jarak ke gardu induk terdekat (km)
    substation_count_50km  INTEGER DEFAULT 0, -- Jumlah gardu dalam radius 50km
    max_voltage_kv         NUMERIC(6,1),  -- Tegangan tertinggi gardu terdekat (kV)
    -- Pembangkit Listrik
    total_capacity_mw      NUMERIC(12,2) DEFAULT 0, -- Total kapasitas dalam radius 100km
    renewable_capacity_mw  NUMERIC(12,2) DEFAULT 0, -- Kapasitas EBT dalam radius 100km
    renewable_ratio_pct    NUMERIC(5,2)  DEFAULT 0, -- Rasio EBT (%)
    plant_count_100km      INTEGER DEFAULT 0,
    created_at             TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- DIMENSI 3: Profil Konektivitas Jaringan per Wilayah
-- =============================================================================
CREATE TABLE IF NOT EXISTS mart.dim_konektivitas_jaringan (
    konektivitas_id      BIGSERIAL PRIMARY KEY,
    bps_code             TEXT NOT NULL UNIQUE REFERENCES mart.dim_wilayah(bps_code),
    -- Broadband (Ookla 2024-Q4)
    avg_download_mbps    NUMERIC(8,2),
    avg_upload_mbps      NUMERIC(8,2),
    avg_latency_ms       NUMERIC(6,2),
    broadband_tile_count INTEGER DEFAULT 0, -- Jumlah tile Ookla dalam wilayah (proxy kepadatan coverage)
    -- BTS (OpenCelliD)
    bts_count_30km       INTEGER DEFAULT 0, -- Jumlah menara BTS dalam radius 30km
    -- ISP PoP (level provinsi)
    isp_pop_count        INTEGER DEFAULT 0, -- Jumlah PoP ISP di provinsi yang sama
    created_at           TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- DIMENSI 4: Profil Risiko Bencana per Wilayah
-- =============================================================================
CREATE TABLE IF NOT EXISTS mart.dim_risiko_bencana (
    risiko_id               BIGSERIAL PRIMARY KEY,
    bps_code                TEXT NOT NULL UNIQUE REFERENCES mart.dim_wilayah(bps_code),
    -- Gempa Bumi (window 26 tahun: 1998-2024)
    eq_count_26yr           INTEGER DEFAULT 0,  -- Total kejadian dalam 200km
    eq_significant_26yr     INTEGER DEFAULT 0,  -- M >= 5.0 dalam 200km
    eq_max_magnitude_26yr   NUMERIC(4,2),
    eq_shallow_severe_26yr  INTEGER DEFAULT 0,  -- M >= 6.5 & depth <= 30km dalam 25km
    -- Gempa Bumi (window 10 tahun: 2014-2024)
    eq_count_10yr           INTEGER DEFAULT 0,
    eq_significant_10yr     INTEGER DEFAULT 0,
    eq_max_magnitude_10yr   NUMERIC(4,2),
    eq_shallow_severe_10yr  INTEGER DEFAULT 0,  -- M >= 6.5 & depth <= 30km dalam 25km (knock-out trigger)
    -- Bencana Hidrometeorologi (2018-2024, semua tersedia)
    flood_count_5yr         INTEGER DEFAULT 0,  -- Banjir dalam 5 tahun terakhir (2019-2024)
    landslide_count_5yr     INTEGER DEFAULT 0,  -- Tanah Longsor
    extreme_weather_count_5yr INTEGER DEFAULT 0, -- Cuaca Ekstrem
    total_disaster_count    INTEGER DEFAULT 0,  -- Total semua tipe bencana
    -- Flag Knock-out (Opsi A Two-Stage Filtering)
    is_knocked_out          BOOLEAN DEFAULT FALSE, -- TRUE jika lolos threshold eliminasi
    knockout_reason         TEXT,                   -- Alasan eliminasi (jika ada)
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- DIMENSI 5: Profil Lingkungan & Air per Wilayah
-- =============================================================================
CREATE TABLE IF NOT EXISTS mart.dim_lingkungan_air (
    lingkungan_id           BIGSERIAL PRIMARY KEY,
    bps_code                TEXT NOT NULL UNIQUE REFERENCES mart.dim_wilayah(bps_code),
    -- Kualitas Air (IKA KLHK - level provinsi)
    water_quality_index     NUMERIC(5,2), -- IKA terbaru yang tersedia
    water_quality_year      INTEGER,
    water_quality_category  TEXT,         -- Baik / Cukup / Kurang / Buruk
    -- Iklim Ambien (dari stg.regional_features)
    temp_ambient_mean_c     NUMERIC(4,2),
    humidity_ambient_pct    NUMERIC(5,2),
    rainfall_mean_mm        NUMERIC(6,2),
    -- Fisik Lahan
    elevation_mean_m        NUMERIC(7,2),
    pct_built_up            NUMERIC(5,2),
    tertinggal_status       TEXT,         -- Wilayah tertinggal? (dari BPS)
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- TABEL FAKTA: Site Suitability Score
-- Satu baris per wilayah (514 Kab/Kota)
-- =============================================================================
CREATE TABLE IF NOT EXISTS mart.fact_site_suitability (
    suitability_id          BIGSERIAL PRIMARY KEY,
    bps_code                TEXT NOT NULL UNIQUE REFERENCES mart.dim_wilayah(bps_code),

    -- === STAGE 1: KNOCK-OUT FILTER ===
    is_knocked_out          BOOLEAN DEFAULT FALSE,
    knockout_reason         TEXT,

    -- === STAGE 2: SUB-SKOR PER PILAR (skala 0-100) ===
    -- Hanya dihitung jika is_knocked_out = FALSE
    score_power             NUMERIC(5,2),   -- Skor Kelistrikan (0-100)
    score_safety            NUMERIC(5,2),   -- Skor Ketahanan Risiko (0-100)
    score_network           NUMERIC(5,2),   -- Skor Konektivitas (0-100)
    score_environment       NUMERIC(5,2),   -- Skor Lingkungan & Air (0-100)

    -- === SKOR AKHIR TERTIMBANG (Bobot Standar) ===
    -- Formula: (0.35 * power) + (0.25 * safety) + (0.25 * network) + (0.15 * env)
    final_score             NUMERIC(5,2),   -- NULL jika knocked_out

    -- === TIER / LABEL REKOMENDASI ===
    -- Tier 1 (Sangat Layak)   : final_score >= 70
    -- Tier 2 (Layak Bersyarat): final_score >= 45
    -- Tier 3 (Tidak Disarankan): final_score < 45
    -- NULL                    : Tidak Direkomendasikan (knocked_out)
    suitability_tier        TEXT,

    -- === METADATA ===
    computed_at             TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- INDEX PENDUKUNG
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_dim_wilayah_pcode        ON mart.dim_wilayah(pcode);
CREATE INDEX IF NOT EXISTS idx_dim_wilayah_province     ON mart.dim_wilayah(province_name);
CREATE INDEX IF NOT EXISTS idx_fact_tier                ON mart.fact_site_suitability(suitability_tier);
CREATE INDEX IF NOT EXISTS idx_fact_final_score         ON mart.fact_site_suitability(final_score DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_fact_knocked_out         ON mart.fact_site_suitability(is_knocked_out);
