-- =============================================================================
-- 09-bv.sql
-- DDL Business Vault Spasial (bv.*): 1 Helper Subdivisi, 5 Spatial Links,
-- dan 4 Business Satellites pada grain 514 kab/kota kanonik
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS bv;

-- -----------------------------------------------------------------------------
-- 1. Helper Spasial: Poligon ADM2 Terpecah (<= 256 vertex) + Indeks GIST
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bv.wilayah_geom_subdiv (
  subdiv_id  bigserial PRIMARY KEY,
  hk_wilayah char(32) NOT NULL REFERENCES vault.hub_wilayah(hk_wilayah),
  geom       geometry(Geometry, 4326) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_bv_wilayah_subdiv_geom ON bv.wilayah_geom_subdiv USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_bv_wilayah_subdiv_hk   ON bv.wilayah_geom_subdiv (hk_wilayah);

-- -----------------------------------------------------------------------------
-- 2. Spatial Links (5 Tabel Relasi Spasial Terhitung)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bv.link_gempa_wilayah (
  hk_wilayah        char(32) NOT NULL REFERENCES vault.hub_wilayah(hk_wilayah),
  hk_gempa          char(32) NOT NULL REFERENCES vault.hub_gempa(hk_gempa),
  event_date        date,
  magnitude         numeric,
  depth_km          numeric,
  distance_km       numeric(10,3) NOT NULL,
  is_inside_wilayah boolean NOT NULL DEFAULT false,
  is_knockout_event boolean NOT NULL DEFAULT false,
  computed_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (hk_wilayah, hk_gempa)
);

CREATE TABLE IF NOT EXISTS bv.link_pembangkit_wilayah (
  hk_wilayah        char(32) NOT NULL REFERENCES vault.hub_wilayah(hk_wilayah),
  hk_pembangkit     char(32) NOT NULL REFERENCES vault.hub_pembangkit(hk_pembangkit),
  capacity_mw       numeric,
  primary_fuel      text,
  is_renewable      boolean NOT NULL DEFAULT false,
  distance_km       numeric(10,3) NOT NULL,
  is_inside_wilayah boolean NOT NULL DEFAULT false,
  computed_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (hk_wilayah, hk_pembangkit)
);

CREATE TABLE IF NOT EXISTS bv.link_gardu_wilayah (
  hk_wilayah        char(32) NOT NULL REFERENCES vault.hub_wilayah(hk_wilayah),
  hk_gardu          char(32) NOT NULL REFERENCES vault.hub_gardu(hk_gardu),
  voltage_max_kv    numeric,
  is_hv_150kv_plus  boolean NOT NULL DEFAULT false,
  distance_km       numeric(10,3) NOT NULL,
  is_inside_wilayah boolean NOT NULL DEFAULT false,
  computed_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (hk_wilayah, hk_gardu)
);

CREATE TABLE IF NOT EXISTS bv.link_menara_wilayah (
  hk_menara   char(32) PRIMARY KEY REFERENCES vault.hub_menara(hk_menara),
  hk_wilayah  char(32) NOT NULL REFERENCES vault.hub_wilayah(hk_wilayah),
  radio       text,
  computed_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bv.link_ookla_wilayah (
  hk_ookla_tile char(32) PRIMARY KEY REFERENCES vault.hub_ookla_tile(hk_ookla_tile),
  hk_wilayah    char(32) NOT NULL REFERENCES vault.hub_wilayah(hk_wilayah),
  computed_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_bv_link_gempa_w      ON bv.link_gempa_wilayah (hk_wilayah);
CREATE INDEX IF NOT EXISTS idx_bv_link_pembangkit_w ON bv.link_pembangkit_wilayah (hk_wilayah);
CREATE INDEX IF NOT EXISTS idx_bv_link_gardu_w      ON bv.link_gardu_wilayah (hk_wilayah);
CREATE INDEX IF NOT EXISTS idx_bv_link_menara_w     ON bv.link_menara_wilayah (hk_wilayah);
CREATE INDEX IF NOT EXISTS idx_bv_link_ookla_w      ON bv.link_ookla_wilayah (hk_wilayah);

-- -----------------------------------------------------------------------------
-- 3. Business Satellites 4 Pilar (514 Baris per Tabel, Grain = Kab/Kota)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bv.sat_bv_wilayah_safety (
  hk_wilayah                 char(32) PRIMARY KEY REFERENCES vault.hub_wilayah(hk_wilayah),
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
  bnpb_total_flooded_houses  numeric NOT NULL DEFAULT 0,
  ko_seismic_flag            boolean NOT NULL DEFAULT false,
  ko_flood_flag              boolean NOT NULL DEFAULT false,
  is_knockout                boolean NOT NULL DEFAULT false,
  knockout_reasons           text,
  computed_at                timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bv.sat_bv_wilayah_power (
  hk_wilayah                char(32) PRIMARY KEY REFERENCES vault.hub_wilayah(hk_wilayah),
  pembangkit_count_50km     integer NOT NULL DEFAULT 0,
  pembangkit_inside_count   integer NOT NULL DEFAULT 0,
  pembangkit_total_mw_50km  numeric NOT NULL DEFAULT 0,
  pembangkit_renew_mw_50km  numeric NOT NULL DEFAULT 0,
  pembangkit_renew_share_pct numeric(6,2) NOT NULL DEFAULT 0,
  nearest_pembangkit_km     numeric(10,3),
  gardu_total_count_25km    integer NOT NULL DEFAULT 0,
  gardu_hv_150kv_count_25km integer NOT NULL DEFAULT 0,
  gardu_hv_inside_count     integer NOT NULL DEFAULT 0,
  gardu_max_kv_25km         numeric,
  nearest_gardu_150kv_km    numeric(10,3),
  computed_at               timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bv.sat_bv_wilayah_network (
  hk_wilayah                 char(32) PRIMARY KEY REFERENCES vault.hub_wilayah(hk_wilayah),
  ookla_tile_count           integer NOT NULL DEFAULT 0,
  ookla_total_tests          bigint NOT NULL DEFAULT 0,
  ookla_total_devices        bigint NOT NULL DEFAULT 0,
  ookla_avg_d_mbps           numeric(10,3),
  ookla_avg_u_mbps           numeric(10,3),
  ookla_avg_lat_ms           numeric(10,2),
  menara_total_count         integer NOT NULL DEFAULT 0,
  menara_lte_5g_count        integer NOT NULL DEFAULT 0,
  menara_lte_5g_share_pct    numeric(6,2) NOT NULL DEFAULT 0,
  menara_density_per_100km2  numeric(12,3) NOT NULL DEFAULT 0,
  prov_pop_isp_count         integer,
  pop_isp_is_parent_fallback boolean NOT NULL DEFAULT false,
  computed_at                timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bv.sat_bv_wilayah_environment (
  hk_wilayah              char(32) PRIMARY KEY REFERENCES vault.hub_wilayah(hk_wilayah),
  t2m_mean_c              numeric,
  rh2m_mean_pct           numeric,
  prectotcorr_mean_mm     numeric,
  elevation_mean_m        numeric,
  elevation_std_m         numeric,
  solar_sw_dwn_mean       numeric,
  wind_speed_100m_ms      numeric,
  bmkg_station_count      integer NOT NULL DEFAULT 0,
  bmkg_match_method       text NOT NULL DEFAULT 'NONE',
  bmkg_nearest_station_km numeric(10,3),
  bmkg_tavg_c             numeric(6,2),
  bmkg_tx_avg_c           numeric(6,2),
  bmkg_rh_avg_pct         numeric(6,2),
  bmkg_rr_avg_mm          numeric(8,2),
  prov_iklh_year          integer,
  prov_iku_udara          numeric,
  prov_ika_air            numeric,
  prov_iktl_tutupan       numeric,
  prov_ikl_lahan          numeric,
  prov_iklh_avg_score     numeric(6,2),
  prov_penduduk_year      integer,
  prov_penduduk_ribu      numeric,
  prov_kepadatan_km2      numeric,
  computed_at             timestamptz NOT NULL DEFAULT now()
);