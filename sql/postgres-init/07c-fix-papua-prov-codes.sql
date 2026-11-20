-- =============================================================================
-- 07c-fix-papua-prov-codes.sql
-- Penyelarasan kode provinsi Papua berbasis BPS 2023+ terhadap COD-AB 2020
-- agar parent fallback PoP ISP mencapai 514/514 kab/kota (100%)
-- =============================================================================

UPDATE mdm.provinsi_crosswalk
SET
  adm1_pcode_2020 = CASE bps_prov_code
    WHEN '91' THEN 'ID91' -- Papua Barat (induk)
    WHEN '92' THEN 'ID91' -- Papua Barat Daya (pemekaran dari Papua Barat)
    WHEN '94' THEN 'ID94' -- Papua (induk)
    WHEN '95' THEN 'ID94' -- Papua Selatan (pemekaran dari Papua)
    WHEN '96' THEN 'ID94' -- Papua Tengah (pemekaran dari Papua)
    WHEN '97' THEN 'ID94' -- Papua Pegunungan (pemekaran dari Papua)
    ELSE adm1_pcode_2020
  END,
  is_papua_split_prov = CASE
    WHEN bps_prov_code IN ('92', '95', '96', '97') THEN true
    WHEN bps_prov_code IN ('91', '94')             THEN false
    ELSE is_papua_split_prov
  END,
  updated_at = now()
WHERE bps_prov_code IN ('91', '92', '94', '95', '96', '97');