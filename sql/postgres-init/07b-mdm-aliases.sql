-- =============================================================================
-- 07b-mdm-aliases.sql
-- Pemetaan alias sisa kab/kota SRC-02 (BNPB) & SRC-03 (Stasiun BMKG)
-- + fungsi resolusi kunci wilayah kanonik mdm.resolve_bps_kabkota()
-- =============================================================================

WITH alias_rules (source_id, source_name_raw, prov_norm, pat1, pat2, notes) AS (
  VALUES
    -- 12 variasi nama SRC-02 (BNPB)
    ('SRC-02', 'PANGKAJENE KEPULAUAN',             'SULAWESI SELATAN', '%PANGKAJENE%',         NULL,               'Singkatan dari Pangkajene dan Kepulauan'),
    ('SRC-02', 'PASANGKAYU',                       'SULAWESI BARAT',   '%PASANGKAYU%',         '%MAMUJU UTARA%',   'Perubahan nama Mamuju Utara -> Pasangkayu'),
    ('SRC-02', 'KUTAI KERTANEGARA',                'KALIMANTAN TIMUR', '%KARTANEGARA%',        NULL,               'Variasi ejaan Kertanegara -> Kartanegara'),
    ('SRC-02', 'KOTA MAKASSAR',                    'SULAWESI SELATAN', '%MAKAS%',           '%UJUNG%PANDANG%',  'Penulisan Kota Makassar / Makassar'),
    ('SRC-02', 'KOTA PADANG SIDEMPUAN',            'SUMATERA UTARA',   '%PADANG%SID%MPUAN%',   NULL,               'Variasi spasi/ejaan Padangsidimpuan'),
    ('SRC-02', 'SELAYAR',                          'SULAWESI SELATAN', '%SELAYAR%',            NULL,               'Singkatan dari Kepulauan Selayar'),
    ('SRC-02', 'TOBA',                             'SUMATERA UTARA',   '%TOBA%',               NULL,               'Perubahan nama Toba Samosir -> Toba'),
    ('SRC-02', 'TOBA SAMOSIR',                     'SUMATERA UTARA',   '%TOBA%',               NULL,               'Nama lama Kabupaten Toba'),
    ('SRC-02', 'KEPULAUAN SIAU TAGULANDANG BIARO', 'SULAWESI UTARA',   '%SIAU%',               '%SITARO%',         'Variasi penulisan Kepulauan Sitaro'),
    ('SRC-02', 'KEPULAUAN TANIMBAR',               'MALUKU',           '%TANIMBAR%',           '%TENGGARA BARAT%', 'Perubahan nama Maluku Tenggara Barat -> Kepulauan Tanimbar'),
    ('SRC-02', 'MALUKU TENGGARA BARAT',            'MALUKU',           '%TANIMBAR%',           '%TENGGARA BARAT%', 'Nama lama Kepulauan Tanimbar'),

    -- 4 variasi nama wilayah stasiun SRC-03 (BMKG)
    ('SRC-03', 'Kota Makassar',                    'SULAWESI SELATAN', '%MAKAS%',           '%UJUNG%PANDANG%',  'Penulisan Kota Makassar'),
    ('SRC-03', 'Kab. Pontianak',                   'KALIMANTAN BARAT', '%MEMPAWAH%',           NULL,               'Perubahan nama Kab. Pontianak -> Mempawah (PP 58/2014)'),
    ('SRC-03', 'Kota Tangerang Selata',            'BANTEN',           '%TANGERANG SELATAN%',  NULL,               'Typo kurang huruf n pada Kota Tangerang Selatan'),
    ('SRC-03', 'Kab Maluku Tenggara Barat',        'MALUKU',           '%TANIMBAR%',           '%TENGGARA BARAT%', 'Nama lama Kepulauan Tanimbar')
)
INSERT INTO mdm.wilayah_alias (
  source_id, source_name_raw, source_name_norm, bps_kabkota_code, notes
)
SELECT
  ar.source_id,
  ar.source_name_raw,
  mdm.norm_wilayah(ar.source_name_raw, 'kab'),
  m.bps_kabkota_code,
  ar.notes
FROM alias_rules ar
JOIN LATERAL (
  SELECT w.bps_kabkota_code
  FROM mdm.wilayah_crosswalk w
  WHERE w.prov_name_norm = ar.prov_norm
    AND (
      w.kabkota_name_norm LIKE ar.pat1
      OR (ar.pat2 IS NOT NULL AND w.kabkota_name_norm LIKE ar.pat2)
    )
  ORDER BY w.bps_kabkota_code
  LIMIT 1
) m ON true
ON CONFLICT (source_id, source_name_norm) DO UPDATE SET
  source_name_raw  = EXCLUDED.source_name_raw,
  bps_kabkota_code = EXCLUDED.bps_kabkota_code,
  notes            = EXCLUDED.notes;

-- Fungsi resolusi tunggal: cek mdm.wilayah_alias -> exact+prov -> exact unik -> tanpa spasi
CREATE OR REPLACE FUNCTION mdm.resolve_bps_kabkota(
  p_source_id text,
  p_raw_city  text,
  p_raw_prov  text DEFAULT NULL
)
RETURNS text
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_city_norm text := mdm.norm_wilayah(p_raw_city, 'kab');
  v_prov_norm text := mdm.norm_wilayah(p_raw_prov, 'prov');
  v_code      text;
BEGIN
  IF v_city_norm IS NULL THEN
    RETURN NULL;
  END IF;

  -- 1. Cek kamus alias eksplisit untuk source terkait
  SELECT a.bps_kabkota_code INTO v_code
  FROM mdm.wilayah_alias a
  WHERE a.source_id = p_source_id
    AND a.source_name_norm = v_city_norm
  LIMIT 1;
  IF v_code IS NOT NULL THEN RETURN v_code; END IF;

  -- 2. Cocokkan nama kab/kota + provinsi (menghindari ambiguitas nama kembar lintas provinsi)
  IF v_prov_norm IS NOT NULL THEN
    SELECT w.bps_kabkota_code INTO v_code
    FROM mdm.wilayah_crosswalk w
    WHERE w.prov_name_norm = v_prov_norm
      AND (
        w.kabkota_name_norm = v_city_norm
        OR replace(w.kabkota_name_norm, ' ', '') = replace(v_city_norm, ' ', '')
      )
    ORDER BY w.bps_kabkota_code
    LIMIT 1;
    IF v_code IS NOT NULL THEN RETURN v_code; END IF;
  END IF;

  -- 3. Fallback cocokkan nama kab/kota lintas seluruh wilayah
  SELECT w.bps_kabkota_code INTO v_code
  FROM mdm.wilayah_crosswalk w
  WHERE w.kabkota_name_norm = v_city_norm
     OR replace(w.kabkota_name_norm, ' ', '') = replace(v_city_norm, ' ', '')
  ORDER BY w.bps_kabkota_code
  LIMIT 1;

  RETURN v_code;
END;
$$;