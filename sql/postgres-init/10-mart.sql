-- =============================================================================
-- 10-mart.sql
-- DDL Star Schema (mart.*): 4 Dimensi & 2 Tabel Fakta
-- Konsumsi langsung untuk Semantic Layer & Apache Superset
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS mart;

-- -----------------------------------------------------------------------------
-- 1. Dimensi Provinsi (38 Baris)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mart.dim_provinsi (
  prov_sk             integer PRIMARY KEY,
  hk_provinsi         char(32) NOT NULL UNIQUE,
  bps_prov_code       text NOT NULL UNIQUE,
  prov_name           text NOT NULL,
  adm1_pcode_2020     text,
  is_papua_split_prov boolean NOT NULL DEFAULT false,
  pop_isp_count       integer,
  iklh_year           integer,
  iklh_avg_score      numeric(6,2),
  penduduk_year       integer,
  penduduk_ribu       numeric,
  kepadatan_km2       numeric,
  updated_at          timestamptz NOT NULL DEFAULT now()
);

-- -----------------------------------------------------------------------------
-- 2. Dimensi Wilayah Kab/Kota (514 Baris)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mart.dim_wilayah (
  wilayah_sk               integer PRIMARY KEY,
  hk_wilayah               char(32) NOT NULL UNIQUE,
  bps_kabkota_code         text NOT NULL UNIQUE,
  prov_sk                  integer NOT NULL REFERENCES mart.dim_provinsi(prov_sk),
  kabkota_name             text NOT NULL,
  prov_name                text NOT NULL,
  adm2_pcode               text,
  mapping_method           text,
  is_papua_split           boolean NOT NULL DEFAULT false,
  area_sqkm                numeric,
  center_lat               numeric(10,7),
  center_lon               numeric(10,7),
  ipm_2024                 numeric,
  ppm_2024                 numeric,
  population_2024          numeric,
  ntl_radiance_mean        numeric,
  tertinggal_status        text,
  is_tertinggal            boolean,
  road_density_km_per_km2  numeric,
  dist_to_primary_trunk_km numeric,
  geom                     geometry(Geometry, 4326),
  geom_geojson_simple      text,
  updated_at               timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mart_dim_wilayah_prov ON mart.dim_wilayah (prov_sk);
CREATE INDEX IF NOT EXISTS idx_mart_dim_wilayah_geom ON mart.dim_wilayah USING GIST (geom);

-- -----------------------------------------------------------------------------
-- 3. Dimensi Waktu Tahunan (2010-2026)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mart.dim_waktu (
  waktu_sk           integer PRIMARY KEY,
  tahun              integer NOT NULL UNIQUE,
  dekade             text NOT NULL,
  is_assessment_year boolean NOT NULL DEFAULT false
);

-- -----------------------------------------------------------------------------
-- 4. Dimensi Parameter Scoring (Auditabilitas Bobot & Ambang)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mart.dim_parameter_scoring (
  param_key   text PRIMARY KEY,
  param_group text NOT NULL,
  param_value numeric,
  unit        text,
  description text NOT NULL,
  loaded_at   timestamptz NOT NULL DEFAULT now()
);

-- -----------------------------------------------------------------------------
-- 5. Tabel Fakta Utama: Kesesuaian Lokasi Data Center (514 Baris)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mart.fact_site_suitability (
  wilayah_sk                 integer NOT NULL REFERENCES mart.dim_wilayah(wilayah_sk),
  prov_sk                    integer NOT NULL REFERENCES mart.dim_provinsi(prov_sk),
  waktu_sk                   integer NOT NULL REFERENCES mart.dim_waktu(waktu_sk),

  -- Metrik Pilar 1: Power (Bobot 35%)
  pembangkit_count_50km      integer NOT NULL DEFAULT 0,
  pembangkit_total_mw_50km   numeric NOT NULL DEFAULT 0,
  pembangkit_renew_share_pct numeric(6,2) NOT NULL DEFAULT 0,
  nearest_pembangkit_km      numeric(10,3),
  gardu_total_count_25km     integer NOT NULL DEFAULT 0,
  gardu_hv_150kv_count_25km  integer NOT NULL DEFAULT 0,
  gardu_max_kv_25km          numeric,
  nearest_gardu_150kv_km     numeric(10,3),

  -- Metrik Pilar 2: Safety (Bobot 25%)
  eq_count_m5_plus_25km      integer NOT NULL DEFAULT 0,
  eq_count_ko_events_25km    integer NOT NULL DEFAULT 0,
  eq_max_magnitude_25km      numeric,
  eq_min_distance_ko_km      numeric(10,3),
  bnpb_total_events          integer NOT NULL DEFAULT 0,
  bnpb_flood_events          integer NOT NULL DEFAULT 0,
  bnpb_landslide_events      integer NOT NULL DEFAULT 0,
  bnpb_other_events          integer NOT NULL DEFAULT 0,
  bnpb_total_deaths          numeric NOT NULL DEFAULT 0,
  bnpb_total_damaged_houses  numeric NOT NULL DEFAULT 0,

  -- Metrik Pilar 3: Network (Bobot 25%)
  ookla_tile_count           integer NOT NULL DEFAULT 0,
  ookla_total_tests          bigint NOT NULL DEFAULT 0,
  ookla_avg_d_mbps           numeric(10,3),
  ookla_avg_u_mbps           numeric(10,3),
  ookla_avg_lat_ms           numeric(10,2),
  menara_total_count         integer NOT NULL DEFAULT 0,
  menara_lte_5g_share_pct    numeric(6,2) NOT NULL DEFAULT 0,
  menara_density_per_100km2  numeric(12,3) NOT NULL DEFAULT 0,
  prov_pop_isp_count         integer,
  pop_isp_is_parent_fallback boolean NOT NULL DEFAULT false,

  -- Metrik Pilar 4: Environment & Climate (Bobot 15%)
  t2m_mean_c                 numeric,
  rh2m_mean_pct              numeric,
  bmkg_tavg_c                numeric(6,2),
  bmkg_match_method          text,
  effective_temp_c           numeric(6,2),
  elevation_mean_m           numeric,
  prov_iklh_avg_score        numeric(6,2),

  -- Skor Terbobot (Skala 0 - 100)
  power_score                numeric(6,2) NOT NULL,
  safety_score               numeric(6,2) NOT NULL,
  network_score              numeric(6,2) NOT NULL,
  environment_score          numeric(6,2) NOT NULL,
  composite_score            numeric(6,2) NOT NULL,

  -- Keputusan Kelayakan, Tier, & Peringkat
  ko_seismic_flag            boolean NOT NULL DEFAULT false,
  ko_flood_flag              boolean NOT NULL DEFAULT false,
  is_knockout                boolean NOT NULL DEFAULT false,
  knockout_reasons           text,
  eligibility_status         text NOT NULL,
  suitability_tier           text NOT NULL,
  national_rank_all          integer NOT NULL,
  national_rank_eligible     integer,
  prov_rank_eligible         integer,
  loaded_at                  timestamptz NOT NULL DEFAULT now(),

  PRIMARY KEY (wilayah_sk, waktu_sk)
);

CREATE INDEX IF NOT EXISTS idx_mart_fact_suit_prov   ON mart.fact_site_suitability (prov_sk);
CREATE INDEX IF NOT EXISTS idx_mart_fact_suit_tier   ON mart.fact_site_suitability (suitability_tier, composite_score DESC);
CREATE INDEX IF NOT EXISTS idx_mart_fact_suit_elig   ON mart.fact_site_suitability (is_knockout, composite_score DESC);

-- -----------------------------------------------------------------------------
-- 6. Tabel Fakta Sekunder: Tren Bencana Tahunan BNPB (2010-2025)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mart.fact_hazard_events_annual (
  wilayah_sk            integer NOT NULL REFERENCES mart.dim_wilayah(wilayah_sk),
  prov_sk               integer NOT NULL REFERENCES mart.dim_provinsi(prov_sk),
  waktu_sk              integer NOT NULL REFERENCES mart.dim_waktu(waktu_sk),
  disaster_category     text NOT NULL,
  event_count           integer NOT NULL DEFAULT 0,
  total_deaths          numeric NOT NULL DEFAULT 0,
  total_damaged_houses  numeric NOT NULL DEFAULT 0,
  total_flooded_houses  numeric NOT NULL DEFAULT 0,
  loaded_at             timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (wilayah_sk, waktu_sk, disaster_category)
);

CREATE INDEX IF NOT EXISTS idx_mart_fact_haz_prov_yr ON mart.fact_hazard_events_annual (prov_sk, waktu_sk);