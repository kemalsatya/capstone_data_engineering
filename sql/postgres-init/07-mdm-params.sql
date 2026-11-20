-- =============================================================================
-- 07-mdm-params.sql
-- Parameter bisnis (non-hardcoded) & Master Data Management Crosswalk Wilayah
-- Kanonik: 514 Kab/Kota & 38 Provinsi berbasis kode BPS 4-digit (SRC-04)
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS ops;
CREATE SCHEMA IF NOT EXISTS mdm;

-- -----------------------------------------------------------------------------
-- 1. Tabel Parameter Skor & Ambang Bisnis (Keputusan D6 & D13)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ops.scoring_parameters (
  param_key   text PRIMARY KEY,
  param_group text NOT NULL,
  param_value numeric,
  param_text  text,
  unit        text,
  description text NOT NULL,
  updated_at  timestamptz NOT NULL DEFAULT now()
);

INSERT INTO ops.scoring_parameters (param_key, param_group, param_value, param_text, unit, description)
VALUES
  -- Bobot 4 Pilar Utama (total = 1.00)
  ('weight_power',          'WEIGHT',     0.35, NULL, 'ratio',  'Bobot pilar utilitas daya listrik (Pembangkit & Gardu)'),
  ('weight_safety',         'WEIGHT',     0.25, NULL, 'ratio',  'Bobot pilar keamanan bencana (Gempa & Hidrometeorologi BNPB)'),
  ('weight_network',        'WEIGHT',     0.25, NULL, 'ratio',  'Bobot pilar konektivitas (Ookla, OpenCelliD, PoP ISP)'),
  ('weight_environment',    'WEIGHT',     0.15, NULL, 'ratio',  'Bobot pilar iklim & lingkungan (Suhu, IKLH, Elevasi)'),

  -- Parameter Jendela Waktu & Penilaian
  ('assessment_year',       'WINDOW',     2024, NULL, 'year',   'Tahun snapshot penilaian utama'),
  ('eq_window_start_year',  'WINDOW',     2014, NULL, 'year',   'Tahun awal jendela analisis gempa BMKG (11 tahun terakhir)'),
  ('eq_window_end_year',    'WINDOW',     2024, NULL, 'year',   'Tahun akhir jendela analisis gempa BMKG'),
  ('bnpb_window_start_year','WINDOW',     2010, NULL, 'year',   'Tahun awal jendela kejadian bencana BNPB'),
  ('bnpb_window_end_year',  'WINDOW',     2025, NULL, 'year',   'Tahun akhir jendela kejadian bencana BNPB'),

  -- Ambang Bahaya & Kriteria Knock-Out (Disqualification)
  ('eq_radius_km',          'HAZARD',     25,   NULL, 'km',     'Radius paparan gempa dari batas poligon kab/kota'),
  ('eq_hazard_min_mag',     'HAZARD',     5.0,  NULL, 'Mw',     'Magnitudo minimum untuk perhitungan paparan gempa signifikan'),
  ('eq_ko_min_mag',         'KNOCKOUT',   6.5,  NULL, 'Mw',     'Magnitudo minimum pemicu knock-out seismik'),
  ('eq_ko_max_depth_km',    'KNOCKOUT',   30,   NULL, 'km',     'Kedalaman maksimum (gempa dangkal) pemicu knock-out seismik'),
  ('flood_ko_max_events',   'KNOCKOUT',   50,   NULL, 'events', 'Batas jumlah kejadian banjir historis pemicu knock-out'),

  -- Parameter Utilitas & Konektivitas
  ('substation_min_kv',     'UTILITY',    150,  NULL, 'kV',     'Tegangan minimum gardu induk transmisi untuk data center'),
  ('substation_radius_km',  'UTILITY',    25,   NULL, 'km',     'Radius pencarian gardu induk terdekat dari wilayah'),
  ('powerplant_radius_km',  'UTILITY',    50,   NULL, 'km',     'Radius pencarian pembangkit listrik dari wilayah'),
  ('tower_radius_km',       'NETWORK',    10,   NULL, 'km',     'Radius tambahan kepadatan menara seluler')
ON CONFLICT (param_key) DO UPDATE SET
  param_group = EXCLUDED.param_group,
  param_value = EXCLUDED.param_value,
  param_text  = EXCLUDED.param_text,
  unit        = EXCLUDED.unit,
  description = EXCLUDED.description,
  updated_at  = now();

-- -----------------------------------------------------------------------------
-- 2. Fungsi Normalisasi Nama Wilayah (konsisten dengan profile_sources.py)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION mdm.norm_wilayah(raw_name text, lvl text DEFAULT 'kab')
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  s text;
BEGIN
  IF raw_name IS NULL THEN
    RETURN NULL;
  END IF;

  s := UPPER(raw_name);
  s := regexp_replace(s, '[^A-Z0-9 ]+', ' ', 'g');
  s := trim(regexp_replace(s, '\s+', ' ', 'g'));

  -- Perbaiki nama yang terspasi per huruf (mis. "A C E H")
  IF s ~ '^(?:[A-Z] )+[A-Z]$' THEN
    s := replace(s, ' ', '');
  END IF;

  IF lvl = 'kab' THEN
    s := regexp_replace(s, '\yKOTA ADMINISTRASI\y|\yKOTA ADM\y|\yADM KOTA\y', 'KOTA', 'g');
    s := regexp_replace(s, '\yKABUPATEN ADMINISTRASI\y|\yKAB ADM\y|\yADM KAB\y|\yKABUPATEN\y|\yKAB\y', ' ', 'g');
    s := regexp_replace(s, '\yKEP\y', 'KEPULAUAN', 'g');
  ELSE
    s := regexp_replace(s, '\yPROVINSI\y|\yPROV\y', ' ', 'g');
    s := regexp_replace(s, '\yKEP\y', 'KEPULAUAN', 'g');
    s := regexp_replace(s, '\yNANGGROE ACEH DARUSSALAM\y|\yNAD\y', 'ACEH', 'g');
    s := regexp_replace(s, '\yDAERAH ISTIMEWA YOGYAKARTA\y|\yD I YOGYAKARTA\y|\yDIY\y', 'DI YOGYAKARTA', 'g');
    s := regexp_replace(s, '\yDAERAH KHUSUS IBUKOTA JAKARTA\y', 'DKI JAKARTA', 'g');
  END IF;

  RETURN trim(regexp_replace(s, '\s+', ' ', 'g'));
END;
$$;

-- -----------------------------------------------------------------------------
-- 3. Tabel Crosswalk Kanonik Provinsi (38 Provinsi) & Kab/Kota (514 Wilayah)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mdm.provinsi_crosswalk (
  bps_prov_code       text PRIMARY KEY,
  prov_name_canonical text NOT NULL,
  prov_name_norm      text NOT NULL,
  adm1_pcode_2020     text,
  is_papua_split_prov boolean NOT NULL DEFAULT false,
  updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS mdm.wilayah_crosswalk (
  bps_kabkota_code       text PRIMARY KEY,
  bps_prov_code          text NOT NULL REFERENCES mdm.provinsi_crosswalk(bps_prov_code),
  kabkota_name_canonical text NOT NULL,
  kabkota_name_norm      text NOT NULL,
  prov_name_canonical    text NOT NULL,
  prov_name_norm         text NOT NULL,
  adm2_pcode             text,
  adm2_name_src11        text,
  adm1_pcode_src11       text,
  mapping_method         text NOT NULL DEFAULT 'UNMAPPED',
  is_papua_split         boolean NOT NULL DEFAULT false,
  updated_at             timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS mdm.wilayah_alias (
  source_id        text NOT NULL,
  source_name_raw  text NOT NULL,
  source_name_norm text NOT NULL,
  bps_kabkota_code text NOT NULL REFERENCES mdm.wilayah_crosswalk(bps_kabkota_code),
  notes            text,
  PRIMARY KEY (source_id, source_name_norm)
);

CREATE TABLE IF NOT EXISTS mdm.provinsi_alias (
  source_name_norm    text PRIMARY KEY,
  bps_prov_code       text NOT NULL REFERENCES mdm.provinsi_crosswalk(bps_prov_code),
  prov_name_canonical text NOT NULL,
  notes               text
);

-- -----------------------------------------------------------------------------
-- 4. Populasi Otomatis 38 Provinsi Kanonik dari SRC-04 + Mapping ADM1 2020
-- -----------------------------------------------------------------------------
INSERT INTO mdm.provinsi_crosswalk (
  bps_prov_code, prov_name_canonical, prov_name_norm, adm1_pcode_2020, is_papua_split_prov
)
SELECT DISTINCT ON (LEFT(s4.bps_kabkota_code, 2))
  LEFT(s4.bps_kabkota_code, 2) AS bps_prov_code,
  s4.prov_name AS prov_name_canonical,
  mdm.norm_wilayah(s4.prov_name, 'prov') AS prov_name_norm,
  CASE
    WHEN LEFT(s4.bps_kabkota_code, 2) IN ('93','94','95') THEN 'ID94' -- Pemekaran dari Papua (2020)
    WHEN LEFT(s4.bps_kabkota_code, 2) = '96'              THEN 'ID91' -- Pemekaran dari Papua Barat (2020)
    WHEN LEFT(s4.bps_kabkota_code, 2) = '92'              THEN 'ID91' -- Papua Barat (kode BPS 92 = ID91 di COD-AB 2020)
    WHEN LEFT(s4.bps_kabkota_code, 2) = '91'              THEN 'ID94' -- Papua (kode BPS 91 = ID94 di COD-AB 2020)
    ELSE 'ID' || LEFT(s4.bps_kabkota_code, 2)
  END AS adm1_pcode_2020,
  LEFT(s4.bps_kabkota_code, 2) IN ('93','94','95','96') AS is_papua_split_prov
FROM stg.src_04_fitur_kabkota s4
ORDER BY LEFT(s4.bps_kabkota_code, 2), s4.bps_kabkota_code
ON CONFLICT (bps_prov_code) DO UPDATE SET
  prov_name_canonical = EXCLUDED.prov_name_canonical,
  prov_name_norm      = EXCLUDED.prov_name_norm,
  adm1_pcode_2020     = EXCLUDED.adm1_pcode_2020,
  is_papua_split_prov = EXCLUDED.is_papua_split_prov,
  updated_at          = now();

-- -----------------------------------------------------------------------------
-- 5. Populasi Otomatis 514 Kab/Kota Kanonik (SRC-04) & Matching ke SRC-11 ADM2
--    Poligon non-administratif (Danau, Waduk, Wadung, Hutan) otomatis dikeluarkan.
-- -----------------------------------------------------------------------------
-- Pass 1: Insert 514 wilayah + Exact Match berdasarkan 'ID' || bps_kabkota_code
INSERT INTO mdm.wilayah_crosswalk (
  bps_kabkota_code, bps_prov_code, kabkota_name_canonical, kabkota_name_norm,
  prov_name_canonical, prov_name_norm,
  adm2_pcode, adm2_name_src11, adm1_pcode_src11,
  mapping_method, is_papua_split
)
SELECT
  s4.bps_kabkota_code,
  LEFT(s4.bps_kabkota_code, 2) AS bps_prov_code,
  s4.kabkota_name,
  mdm.norm_wilayah(s4.kabkota_name, 'kab'),
  s4.prov_name,
  mdm.norm_wilayah(s4.prov_name, 'prov'),
  a2.adm2_pcode,
  a2.adm2_name,
  a2.adm1_pcode,
  CASE WHEN a2.adm2_pcode IS NOT NULL THEN 'EXACT_PCODE' ELSE 'UNMAPPED' END,
  LEFT(s4.bps_kabkota_code, 2) IN ('91','92','93','94','95','96')
FROM stg.src_04_fitur_kabkota s4
LEFT JOIN stg.src_11_adm2 a2
  ON a2.adm2_pcode = 'ID' || s4.bps_kabkota_code
 AND a2.adm2_name !~* '^(danau|waduk|wadung|hutan)(\s|$)'
ON CONFLICT (bps_kabkota_code) DO UPDATE SET
  kabkota_name_canonical = EXCLUDED.kabkota_name_canonical,
  kabkota_name_norm      = EXCLUDED.kabkota_name_norm,
  prov_name_canonical    = EXCLUDED.prov_name_canonical,
  prov_name_norm         = EXCLUDED.prov_name_norm,
  adm2_pcode             = EXCLUDED.adm2_pcode,
  adm2_name_src11        = EXCLUDED.adm2_name_src11,
  adm1_pcode_src11       = EXCLUDED.adm1_pcode_src11,
  mapping_method         = EXCLUDED.mapping_method,
  is_papua_split         = EXCLUDED.is_papua_split,
  updated_at             = now();

-- Pass 2: Fallback Match berdasarkan nama ternormalisasi (menangkap pemekaran Papua & kode bergeser)
WITH adm2_clean AS (
  SELECT DISTINCT ON (mdm.norm_wilayah(adm2_name, 'kab'))
    adm2_pcode,
    adm2_name,
    adm1_pcode,
    mdm.norm_wilayah(adm2_name, 'kab') AS norm_name
  FROM stg.src_11_adm2
  WHERE adm2_name !~* '^(danau|waduk|wadung|hutan)(\s|$)'
  ORDER BY mdm.norm_wilayah(adm2_name, 'kab'), area_sqkm DESC NULLS LAST
)
UPDATE mdm.wilayah_crosswalk w
SET
  adm2_pcode       = a.adm2_pcode,
  adm2_name_src11  = a.adm2_name,
  adm1_pcode_src11 = a.adm1_pcode,
  mapping_method   = CASE WHEN w.is_papua_split THEN 'PAPUA_SPLIT_NAME_MATCH' ELSE 'NAME_MATCH' END,
  updated_at       = now()
FROM adm2_clean a
WHERE w.adm2_pcode IS NULL
  AND (
    w.kabkota_name_norm = a.norm_name
    OR replace(w.kabkota_name_norm, ' ', '') = replace(a.norm_name, ' ', '')
  );

-- -----------------------------------------------------------------------------
-- 6. Indeks untuk percepatan lookup crosswalk di Vault & Business Vault
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_mdm_wilayah_norm     ON mdm.wilayah_crosswalk (kabkota_name_norm);
CREATE INDEX IF NOT EXISTS idx_mdm_wilayah_adm2     ON mdm.wilayah_crosswalk (adm2_pcode);
CREATE INDEX IF NOT EXISTS idx_mdm_provinsi_norm    ON mdm.provinsi_crosswalk (prov_name_norm);