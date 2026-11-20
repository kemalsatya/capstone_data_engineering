-- =============================================================================
-- 08-vault.sql
-- DDL Raw Data Vault 2.0: 9 Hub, 3 Link Administratif, 14 Satellite
-- Konvensi: md5 char(32) hash key, timestamptz UTC, SRID 4326, insert-only
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS vault;

-- =============================================================================
-- A. HUBS (9 Entitas Bisnis Inti)
-- =============================================================================
CREATE TABLE IF NOT EXISTS vault.hub_provinsi (
  hk_provinsi   char(32) PRIMARY KEY,
  bps_prov_code text NOT NULL UNIQUE,
  load_date     timestamptz NOT NULL DEFAULT now(),
  record_source text NOT NULL
);

CREATE TABLE IF NOT EXISTS vault.hub_wilayah (
  hk_wilayah       char(32) PRIMARY KEY,
  bps_kabkota_code text NOT NULL UNIQUE,
  load_date        timestamptz NOT NULL DEFAULT now(),
  record_source    text NOT NULL
);

CREATE TABLE IF NOT EXISTS vault.hub_gempa (
  hk_gempa      char(32) PRIMARY KEY,
  event_id      text NOT NULL UNIQUE,
  load_date     timestamptz NOT NULL DEFAULT now(),
  record_source text NOT NULL
);

CREATE TABLE IF NOT EXISTS vault.hub_bencana (
  hk_bencana    char(32) PRIMARY KEY,
  bencana_bk    text NOT NULL UNIQUE,
  load_date     timestamptz NOT NULL DEFAULT now(),
  record_source text NOT NULL
);

CREATE TABLE IF NOT EXISTS vault.hub_stasiun (
  hk_stasiun    char(32) PRIMARY KEY,
  station_id    text NOT NULL UNIQUE,
  load_date     timestamptz NOT NULL DEFAULT now(),
  record_source text NOT NULL
);

CREATE TABLE IF NOT EXISTS vault.hub_pembangkit (
  hk_pembangkit char(32) PRIMARY KEY,
  gppd_idnr     text NOT NULL UNIQUE,
  load_date     timestamptz NOT NULL DEFAULT now(),
  record_source text NOT NULL
);

CREATE TABLE IF NOT EXISTS vault.hub_gardu (
  hk_gardu      char(32) PRIMARY KEY,
  osm_id        text NOT NULL UNIQUE,
  load_date     timestamptz NOT NULL DEFAULT now(),
  record_source text NOT NULL
);

CREATE TABLE IF NOT EXISTS vault.hub_menara (
  hk_menara     char(32) PRIMARY KEY,
  menara_bk     text NOT NULL UNIQUE,
  load_date     timestamptz NOT NULL DEFAULT now(),
  record_source text NOT NULL
);

CREATE TABLE IF NOT EXISTS vault.hub_ookla_tile (
  hk_ookla_tile char(32) PRIMARY KEY,
  quadkey       text NOT NULL UNIQUE,
  load_date     timestamptz NOT NULL DEFAULT now(),
  record_source text NOT NULL
);

-- =============================================================================
-- B. LINKS ADMINISTRATIF (3 Relasi Non-Spasial; Relasi Spasial di Business Vault)
-- =============================================================================
CREATE TABLE IF NOT EXISTS vault.link_wilayah_provinsi (
  hk_link_wilayah_provinsi char(32) PRIMARY KEY,
  hk_wilayah               char(32) NOT NULL REFERENCES vault.hub_wilayah(hk_wilayah),
  hk_provinsi              char(32) NOT NULL REFERENCES vault.hub_provinsi(hk_provinsi),
  load_date                timestamptz NOT NULL DEFAULT now(),
  record_source            text NOT NULL
);

CREATE TABLE IF NOT EXISTS vault.link_bencana_wilayah (
  hk_link_bencana_wilayah char(32) PRIMARY KEY,
  hk_bencana              char(32) NOT NULL REFERENCES vault.hub_bencana(hk_bencana),
  hk_wilayah              char(32) NOT NULL REFERENCES vault.hub_wilayah(hk_wilayah),
  load_date               timestamptz NOT NULL DEFAULT now(),
  record_source           text NOT NULL
);

CREATE TABLE IF NOT EXISTS vault.link_stasiun_wilayah (
  hk_link_stasiun_wilayah char(32) PRIMARY KEY,
  hk_stasiun              char(32) NOT NULL REFERENCES vault.hub_stasiun(hk_stasiun),
  hk_wilayah              char(32) NOT NULL REFERENCES vault.hub_wilayah(hk_wilayah),
  load_date               timestamptz NOT NULL DEFAULT now(),
  record_source           text NOT NULL
);

-- =============================================================================
-- C. SATELLITES (14 Satelit Atribut & Observasi)
-- =============================================================================
CREATE TABLE IF NOT EXISTS vault.sat_provinsi_detail (
  hk_provinsi         char(32) NOT NULL REFERENCES vault.hub_provinsi(hk_provinsi),
  load_date           timestamptz NOT NULL DEFAULT now(),
  hashdiff            char(32) NOT NULL,
  record_source       text NOT NULL,
  prov_name_canonical text NOT NULL,
  adm1_pcode_2020     text,
  is_papua_split_prov boolean,
  PRIMARY KEY (hk_provinsi, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_provinsi_pop_isp (
  hk_provinsi     char(32) NOT NULL REFERENCES vault.hub_provinsi(hk_provinsi),
  tahun           integer NOT NULL,
  load_date       timestamptz NOT NULL DEFAULT now(),
  hashdiff        char(32) NOT NULL,
  record_source   text NOT NULL,
  sebaran_pop_isp integer,
  source_url      text,
  PRIMARY KEY (hk_provinsi, tahun, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_provinsi_iklh (
  hk_provinsi   char(32) NOT NULL REFERENCES vault.hub_provinsi(hk_provinsi),
  tahun         integer NOT NULL,
  load_date     timestamptz NOT NULL DEFAULT now(),
  hashdiff      char(32) NOT NULL,
  record_source text NOT NULL,
  iku_udara     numeric,
  ika_air       numeric,
  iktl_tutupan  numeric,
  ikl_lahan     numeric,
  ikeg_gambut   numeric,
  ikal_air_laut numeric,
  PRIMARY KEY (hk_provinsi, tahun, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_provinsi_penduduk (
  hk_provinsi            char(32) NOT NULL REFERENCES vault.hub_provinsi(hk_provinsi),
  tahun                  integer NOT NULL,
  load_date              timestamptz NOT NULL DEFAULT now(),
  hashdiff               char(32) NOT NULL,
  record_source          text NOT NULL,
  jumlah_penduduk_ribu   numeric,
  laju_pertumbuhan_pct   numeric,
  persentase_penduduk    numeric,
  kepadatan_per_km2      numeric,
  rasio_jenis_kelamin    numeric,
  PRIMARY KEY (hk_provinsi, tahun, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_wilayah_fitur (
  hk_wilayah               char(32) NOT NULL REFERENCES vault.hub_wilayah(hk_wilayah),
  load_date                timestamptz NOT NULL DEFAULT now(),
  hashdiff                 char(32) NOT NULL,
  record_source            text NOT NULL,
  kabkota_name             text,
  prov_name                text,
  ipm_2023                 numeric,
  ipm_2024                 numeric,
  ppm_2023                 numeric,
  ppm_2024                 numeric,
  population_2023          numeric,
  population_2024          numeric,
  ntl_radiance_mean        numeric,
  elevation_mean_m         numeric,
  elevation_std_m          numeric,
  pct_built_up             numeric,
  pct_water                numeric,
  pct_wetland              numeric,
  pct_tree_cover           numeric,
  tertinggal_status        text,
  is_tertinggal            boolean,
  allsky_sfc_sw_dwn_mean   numeric,
  t2m_mean                 numeric,
  rh2m_mean                numeric,
  prectotcorr_mean         numeric,
  ws10m_mean               numeric,
  ws50m_mean               numeric,
  wind_speed_100m_mean_ms  numeric,
  road_length_km           numeric,
  road_density_km_per_km2  numeric,
  dist_to_primary_trunk_km numeric,
  PRIMARY KEY (hk_wilayah, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_wilayah_geom (
  hk_wilayah    char(32) NOT NULL REFERENCES vault.hub_wilayah(hk_wilayah),
  load_date     timestamptz NOT NULL DEFAULT now(),
  hashdiff      char(32) NOT NULL,
  record_source text NOT NULL,
  adm2_pcode    text,
  adm2_name     text,
  adm1_pcode    text,
  area_sqkm     numeric,
  center_lat    numeric(10,7),
  center_lon    numeric(10,7),
  geom          geometry(Geometry, 4326),
  PRIMARY KEY (hk_wilayah, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_gempa_detail (
  hk_gempa      char(32) NOT NULL REFERENCES vault.hub_gempa(hk_gempa),
  load_date     timestamptz NOT NULL DEFAULT now(),
  hashdiff      char(32) NOT NULL,
  record_source text NOT NULL,
  event_date    date,
  time_utc      text,
  latitude      numeric(10,7),
  longitude     numeric(10,7),
  magnitude     numeric,
  mag_type      text,
  depth_km      numeric,
  source_net    text,
  geom          geometry(Point, 4326),
  PRIMARY KEY (hk_gempa, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_bencana_detail (
  hk_bencana       char(32) NOT NULL REFERENCES vault.hub_bencana(hk_bencana),
  load_date        timestamptz NOT NULL DEFAULT now(),
  hashdiff         char(32) NOT NULL,
  record_source    text NOT NULL,
  event_date       date,
  disaster_type    text,
  city_raw         text,
  province_raw     text,
  cause            text,
  death            numeric,
  missing_person   numeric,
  injured_person   numeric,
  damaged_house    numeric,
  flooded_house    numeric,
  damaged_facility numeric,
  PRIMARY KEY (hk_bencana, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_stasiun_detail (
  hk_stasiun    char(32) NOT NULL REFERENCES vault.hub_stasiun(hk_stasiun),
  load_date     timestamptz NOT NULL DEFAULT now(),
  hashdiff      char(32) NOT NULL,
  record_source text NOT NULL,
  station_name  text,
  region_name   text,
  latitude      numeric(10,7),
  longitude     numeric(10,7),
  geom          geometry(Point, 4326),
  PRIMARY KEY (hk_stasiun, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_iklim_harian (
  hk_stasiun    char(32) NOT NULL REFERENCES vault.hub_stasiun(hk_stasiun),
  obs_date      date NOT NULL,
  load_date     timestamptz NOT NULL DEFAULT now(),
  hashdiff      char(32) NOT NULL,
  record_source text NOT NULL,
  tn            numeric,
  tx            numeric,
  tavg          numeric,
  rh_avg        numeric,
  rr            numeric,
  ss            numeric,
  ff_x          numeric,
  ddd_x         numeric,
  ff_avg        numeric,
  ddd_car       text,
  PRIMARY KEY (hk_stasiun, obs_date, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_pembangkit_detail (
  hk_pembangkit      char(32) NOT NULL REFERENCES vault.hub_pembangkit(hk_pembangkit),
  load_date          timestamptz NOT NULL DEFAULT now(),
  hashdiff           char(32) NOT NULL,
  record_source      text NOT NULL,
  plant_name         text,
  capacity_mw        numeric,
  primary_fuel       text,
  other_fuel1        text,
  commissioning_year numeric,
  owner              text,
  latitude           numeric(10,7),
  longitude          numeric(10,7),
  geom               geometry(Point, 4326),
  PRIMARY KEY (hk_pembangkit, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_gardu_detail (
  hk_gardu       char(32) NOT NULL REFERENCES vault.hub_gardu(hk_gardu),
  load_date      timestamptz NOT NULL DEFAULT now(),
  hashdiff       char(32) NOT NULL,
  record_source  text NOT NULL,
  gardu_name     text,
  substation     text,
  voltage_raw    text,
  voltage_max_kv numeric,
  operator       text,
  latitude       numeric(10,7),
  longitude      numeric(10,7),
  geom           geometry(Point, 4326),
  PRIMARY KEY (hk_gardu, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_menara_detail (
  hk_menara     char(32) NOT NULL REFERENCES vault.hub_menara(hk_menara),
  load_date     timestamptz NOT NULL DEFAULT now(),
  hashdiff      char(32) NOT NULL,
  record_source text NOT NULL,
  radio         text,
  mcc           text,
  net           text,
  area          text,
  cell          text,
  range_m       integer,
  samples       integer,
  created_at    timestamptz,
  updated_at    timestamptz,
  latitude      numeric(10,7),
  longitude     numeric(10,7),
  geom          geometry(Point, 4326),
  PRIMARY KEY (hk_menara, load_date)
);

CREATE TABLE IF NOT EXISTS vault.sat_ookla_detail (
  hk_ookla_tile char(32) NOT NULL REFERENCES vault.hub_ookla_tile(hk_ookla_tile),
  load_date     timestamptz NOT NULL DEFAULT now(),
  hashdiff      char(32) NOT NULL,
  record_source text NOT NULL,
  data_year     integer,
  data_quarter  integer,
  avg_d_mbps    numeric,
  avg_u_mbps    numeric,
  avg_lat_ms    numeric,
  tests         integer,
  devices       integer,
  tile_x        numeric,
  tile_y        numeric,
  geom          geometry(Polygon, 4326),
  PRIMARY KEY (hk_ookla_tile, load_date)
);

-- =============================================================================
-- D. INDEKS SPASIAL (GIST) & INDEKS PERFORMA VAULT
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_vault_sat_wilayah_geom     ON vault.sat_wilayah_geom     USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_vault_sat_gempa_geom       ON vault.sat_gempa_detail     USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_vault_sat_stasiun_geom     ON vault.sat_stasiun_detail   USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_vault_sat_pembangkit_geom  ON vault.sat_pembangkit_detail USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_vault_sat_gardu_geom       ON vault.sat_gardu_detail     USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_vault_sat_menara_geom      ON vault.sat_menara_detail    USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_vault_sat_ookla_geom       ON vault.sat_ookla_detail     USING GIST (geom);

CREATE INDEX IF NOT EXISTS idx_vault_sat_gempa_date_mag   ON vault.sat_gempa_detail (event_date, magnitude, depth_km);
CREATE INDEX IF NOT EXISTS idx_vault_sat_gardu_kv         ON vault.sat_gardu_detail (voltage_max_kv);
CREATE INDEX IF NOT EXISTS idx_vault_link_bencana_wilayah ON vault.link_bencana_wilayah (hk_wilayah);
CREATE INDEX IF NOT EXISTS idx_vault_link_stasiun_wilayah ON vault.link_stasiun_wilayah (hk_wilayah);