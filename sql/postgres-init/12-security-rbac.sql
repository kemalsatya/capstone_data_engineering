-- =============================================================================
-- 12-security-rbac.sql
-- Komponen 7: Klasifikasi Data, Retensi, Protected Views, & RBAC Least Privilege
-- Catatan Keamanan: Role dibuat NOLOGIN (tanpa password plaintext di repo Git).
-- =============================================================================

-- 1. Tabel Kebijakan Klasifikasi, Permitted Purpose, Masking, & Siklus Hidup Data
CREATE TABLE IF NOT EXISTS ops.data_classification_policy (
  policy_id                 TEXT PRIMARY KEY,
  layer_schema              TEXT NOT NULL,
  asset_scope               TEXT NOT NULL,
  classification            TEXT NOT NULL,
  permitted_purpose         TEXT NOT NULL,
  minimization_masking_rule TEXT NOT NULL,
  retention_days            INT  NOT NULL,
  deletion_method           TEXT NOT NULL,
  data_owner_role           TEXT NOT NULL,
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO ops.data_classification_policy (
  policy_id, layer_schema, asset_scope, classification, permitted_purpose,
  minimization_masking_rule, retention_days, deletion_method, data_owner_role
) VALUES
  ('POL-01', 'raw',      'raw.src_01..src_12 (15 tabel mentah)', 'Internal-Landing',
   'Arsip pendaratan audit ETL; dilarang diakses langsung oleh konsumen BI.',
   'Isolasi skema penuh (REVOKE PUBLIC & bi_reader).', 90,
   'TRUNCATE & arsip terenkripsi per siklus rilis', 'etl_runner'),
  ('POL-02', 'stg',      'stg.src_01..src_12 (15 tabel staging)', 'Internal-Operational',
   'Validasi kualitas data dan pembentukan geometri PostGIS pra-Vault.',
   'Sanitasi anomali sensor/sentinel; dilarang diakses bi_reader.', 90,
   'TRUNCATE per eksekusi idempotent wf_stg_master', 'etl_runner'),
  ('POL-03', 'dq',       'dq.quarantine_records & dq.capstone_quality_issues', 'Internal-Governance',
   'Audit pelanggaran aturan DQ (CRITICAL/WARNING) oleh Data Steward.',
   'Akses baca terbatas untuk dq_steward; tanpa hak ubah/hapus.', 180,
   'DELETE berbasis timestamp (>180 hari) pasca arsip laporan', 'dq_steward'),
  ('POL-04', 'ops',      'ops.source_file_manifest, scoring_parameters, etl_run_log', 'Internal-Governance',
   'Kontrol manifest berkas, parameter scoring, dan observability pipeline.',
   'Path berkas lokal disembunyikan pada semantic.v_dc_dq_governance_protected.', 365,
   'Arsip tahunan & rotasi log (>365 hari)', 'dq_steward'),
  ('POL-05', 'vault/bv', 'vault.* (26 tabel) & bv.* (10 tabel)', 'Internal-Curated',
   'Integrasi historis insert-only Data Vault 2.0 & spatial links PostGIS.',
   'Kunci bisnis di-hash MD5; dilarang diakses langsung konsumen BI.', 730,
   'Retensi historis selama siklus proyek; purge via skrip migrasi', 'etl_runner'),
  ('POL-06', 'mart',     'mart.dim_* & mart.fact_* (6 tabel)', 'Internal-Analytical',
   'Lapisan agregasi Star Schema sumber semantic layer.',
   'Diakses konsumen hanya melalui view semantic terkelola.', 365,
   'Full rebuild idempotent per siklus penilaian', 'etl_runner'),
  ('POL-07', 'semantic', 'semantic.v_dc_site_ranking_protected & v_dc_dq_governance_protected', 'Restricted-NonCommercial',
   'Konsumsi dashboard BI akademik/non-komersial (mengandung turunan SRC-06 Ookla CC BY-NC-SA 4.0).',
   'Minimization (tanpa GeoJSON mentah & path internal) + masking presisi koordinat ke 2 desimal (~1,1 km).', 365,
   'View logis (mengikuti siklus retensi mart)', 'bi_reader')
ON CONFLICT (policy_id) DO UPDATE SET
  layer_schema              = EXCLUDED.layer_schema,
  asset_scope               = EXCLUDED.asset_scope,
  classification            = EXCLUDED.classification,
  permitted_purpose         = EXCLUDED.permitted_purpose,
  minimization_masking_rule = EXCLUDED.minimization_masking_rule,
  retention_days            = EXCLUDED.retention_days,
  deletion_method           = EXCLUDED.deletion_method,
  data_owner_role           = EXCLUDED.data_owner_role,
  updated_at                = NOW();

-- 2. Protected Views (Minimization & Masking untuk Konsumen BI)
DROP VIEW IF EXISTS semantic.v_dc_site_ranking_protected;
CREATE VIEW semantic.v_dc_site_ranking_protected AS
SELECT
  tahun_penilaian,
  region_pulau,
  bps_prov_code,
  prov_name,
  bps_kabkota_code,
  kabkota_name,
  -- Spatial precision minimization: dibulatkan ke 2 desimal (~1,1 km)
  ROUND(center_lat::numeric, 2) AS approx_lat,
  ROUND(center_lon::numeric, 2) AS approx_lon,
  composite_score,
  power_score,
  safety_score,
  network_score,
  environment_score,
  eligibility_status,
  suitability_tier,
  is_knockout,
  knockout_reasons,
  national_rank_eligible,
  prov_rank_eligible,
  nearest_gardu_150kv_km,
  ookla_avg_d_mbps,
  bnpb_flood_events,
  eq_count_ko_events_25km,
  effective_temp_c,
  pop_isp_is_parent_fallback,
  'ACADEMIC / NON-COMMERCIAL ONLY (SRC-06 CC BY-NC-SA 4.0; SRC-08 ODbL)'::text AS permitted_purpose_notice
FROM semantic.v_dc_site_ranking;

DROP VIEW IF EXISTS semantic.v_dc_dq_governance_protected;
CREATE VIEW semantic.v_dc_dq_governance_protected AS
SELECT
  source_id,
  file_count,
  manifest_rows,
  total_size_mb,
  license,
  CASE
    WHEN source_id = 'SRC-06' THEN 'Restricted-NonCommercial'
    WHEN source_id = 'SRC-08' THEN 'Public-ShareAlike (ODbL)'
    ELSE 'Public-OpenData'
  END AS data_classification,
  CASE
    WHEN source_id = 'SRC-06' THEN FALSE
    ELSE TRUE
  END AS commercial_use_allowed,
  quarantined_rows,
  critical_issues,
  high_issues,
  warning_issues,
  total_dq_issues
FROM semantic.v_dc_dq_governance;

-- 3. Pembuatan 3 Role Least Privilege (Idempotent, NOLOGIN)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'bi_reader') THEN
    CREATE ROLE bi_reader NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dq_steward') THEN
    CREATE ROLE dq_steward NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'etl_runner') THEN
    CREATE ROLE etl_runner NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
  END IF;
END $$;

-- 4. Bersihkan Hak Akses Default (Deny by Default)
REVOKE ALL ON SCHEMA raw, stg, dq, ops, mdm, vault, bv, mart, semantic
  FROM PUBLIC, bi_reader, dq_steward, etl_runner;

REVOKE ALL ON ALL TABLES IN SCHEMA raw, stg, dq, ops, mdm, vault, bv, mart, semantic
  FROM PUBLIC, bi_reader, dq_steward, etl_runner;

-- 5. Hak Akses Least Privilege per Role
-- 5a. bi_reader: HANYA baca (SELECT) pada semantic views tertentu; dilarang menyentuh raw..mart
GRANT USAGE ON SCHEMA semantic TO bi_reader;
GRANT SELECT ON
  semantic.v_dc_site_ranking_protected,
  semantic.v_dc_dq_governance_protected,
  semantic.v_dc_province_summary,
  semantic.v_dc_pillar_breakdown,
  semantic.v_dc_hazard_trends,
  semantic.v_dc_scoring_parameters
TO bi_reader;

-- 5b. dq_steward: HANYA baca (SELECT) pada skema tata kelola (dq, ops, mdm, semantic); tanpa DML/DDL & tanpa akses raw/vault
GRANT USAGE ON SCHEMA dq, ops, mdm, semantic TO dq_steward;
GRANT SELECT ON ALL TABLES IN SCHEMA dq, ops, mdm, semantic TO dq_steward;

-- 5c. etl_runner: Akses DML pada lapisan pipeline (tanpa hak CREATE/DROP DDL pada skema)
GRANT USAGE ON SCHEMA raw, stg, dq, ops, mdm, vault, bv, mart, semantic TO etl_runner;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA raw, stg, dq, ops, mdm, vault, bv, mart TO etl_runner;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA raw, stg, dq, ops, mdm, vault, bv, mart TO etl_runner;
GRANT SELECT ON ALL TABLES IN SCHEMA semantic TO etl_runner;