-- =============================================================================
-- 13-ops-observability.sql
-- Komponen 3 & 8: Run Metadata (ops.etl_run_log), Checkpoint, & SLI/SLO Targets
-- =============================================================================

CREATE TABLE IF NOT EXISTS ops.etl_run_log (
  run_id         TEXT PRIMARY KEY,
  job_name       TEXT NOT NULL,
  layer          TEXT NOT NULL,
  run_mode       TEXT NOT NULL,
  data_version   TEXT NOT NULL DEFAULT 'v1.0-20261120',
  started_at     TIMESTAMPTZ NOT NULL,
  finished_at    TIMESTAMPTZ,
  duration_sec   NUMERIC(10,2),
  rows_in        BIGINT DEFAULT 0,
  rows_out       BIGINT DEFAULT 0,
  rows_rejected  BIGINT DEFAULT 0,
  rows_warning   BIGINT DEFAULT 0,
  attempt_no     INT NOT NULL DEFAULT 1,
  status         TEXT NOT NULL CHECK (status IN ('RUNNING','SUCCESS','FAILED','RECOVERED')),
  error_message  TEXT,
  operator_owner TEXT NOT NULL DEFAULT 'Kelompok DE Capstone',
  notes          TEXT
);

CREATE TABLE IF NOT EXISTS ops.pipeline_checkpoint (
  pipeline_name     TEXT PRIMARY KEY,
  source_scope      TEXT NOT NULL,
  target_scope      TEXT NOT NULL,
  load_strategy     TEXT NOT NULL,
  last_run_id       TEXT REFERENCES ops.etl_run_log(run_id),
  last_watermark    TEXT,
  last_row_count    BIGINT,
  data_freshness_ts TIMESTAMPTZ,
  status            TEXT NOT NULL,
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ops.sli_slo_targets (
  slo_id           TEXT PRIMARY KEY,
  metric_name      TEXT NOT NULL,
  target_threshold TEXT NOT NULL,
  observed_value   TEXT NOT NULL,
  unit             TEXT NOT NULL,
  compliance_status TEXT NOT NULL,
  evidence_ref     TEXT NOT NULL,
  measured_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed baseline eksekusi E2E Tahap 6B (idempotent)
INSERT INTO ops.etl_run_log (
  run_id, job_name, layer, run_mode, data_version,
  started_at, finished_at, duration_sec,
  rows_in, rows_out, rows_rejected, rows_warning,
  attempt_no, status, error_message, notes
) VALUES
  ('RUN-20261120-STG-BASE', 'wf_stg_master.hwf', 'STG', 'FULL_IDEMPOTENT', 'v1.0-20261120',
   '2026-11-20 14:50:25+07', '2026-11-20 14:56:42+07', 377.64,
   1135547, 1135547, 0, 15625, 1, 'SUCCESS', NULL, '15 pipeline staging + PostGIS GIST; 0 CRITICAL quarantine'),
  ('RUN-20261120-VAULT-BASE', 'wf_vault_load.hwf', 'VAULT', 'INSERT_ONLY_VAULT', 'v1.0-20261120',
   '2026-11-20 14:56:42+07', '2026-11-20 14:57:02+07', 19.49,
   1135547, 1135547, 0, 0, 1, 'SUCCESS', NULL, '26 tabel Raw Data Vault 2.0 (MD5 HK & hashdiff)'),
  ('RUN-20261120-BV-BASE', 'wf_bv_load.hwf', 'BV', 'SPATIAL_SNAPSHOT', 'v1.0-20261120',
   '2026-11-20 14:57:02+07', '2026-11-20 14:59:23+07', 140.70,
   514, 514, 0, 0, 1, 'SUCCESS', NULL, 'ST_Subdivide 35.882 sub-poligon + 5 spatial links + 4 pillar satellites'),
  ('RUN-20261120-MART-BASE', 'wf_mart_load.hwf', 'MART', 'FULL_SNAPSHOT', 'v1.0-20261120',
   '2026-11-20 14:59:23+07', '2026-11-20 14:59:28+07', 5.35,
   514, 514, 0, 0, 1, 'SUCCESS', NULL, 'Star Schema 6 tabel (514 kab/kota, 38 provinsi, 6.810 hazard annual)'),
  ('RUN-20261120-E2E-BASE', 'wf_capstone_e2e_master.hwf', 'E2E', 'SNAPSHOT_COMPARE_IDEMPOTENT', 'v1.0-20261120',
   '2026-11-20 14:50:24+07', '2026-11-20 14:59:31+07', 547.41,
   1135547, 1135547, 0, 15625, 1, 'SUCCESS', NULL, '100% IDEMPOTENCY PASS lintas 83 tabel / 7 skema')
ON CONFLICT (run_id) DO NOTHING;

INSERT INTO ops.pipeline_checkpoint (
  pipeline_name, source_scope, target_scope, load_strategy,
  last_run_id, last_watermark, last_row_count, data_freshness_ts, status
) VALUES
  ('wf_stg_master.hwf',     'raw.src_01..src_12', 'stg.src_01..src_12 + dq.*', 'TRUNCATE_AND_LOAD_IDEMPOTENT', 'RUN-20261120-STG-BASE',   '2025-12-31', 1135547, '2026-11-20 14:56:42+07', 'SUCCESS'),
  ('wf_vault_load.hwf',     'stg.* + mdm.*',      'vault.* (26 tabel)',        'INSERT_ONLY_HASHDIFF',         'RUN-20261120-VAULT-BASE', '2025-12-31', 1135547, '2026-11-20 14:57:02+07', 'SUCCESS'),
  ('wf_bv_load.hwf',        'vault.* + ops.*',    'bv.* (10 tabel)',           'SPATIAL_SNAPSHOT_REBUILD',     'RUN-20261120-BV-BASE',    '2025-12-31',     514, '2026-11-20 14:59:23+07', 'SUCCESS'),
  ('wf_mart_load.hwf',      'bv.* + vault.*',     'mart.* (6 tabel)',          'STAR_SCHEMA_SNAPSHOT',         'RUN-20261120-MART-BASE',  '2025-12-31',     514, '2026-11-20 14:59:28+07', 'SUCCESS')
ON CONFLICT (pipeline_name) DO UPDATE SET
  last_run_id       = EXCLUDED.last_run_id,
  last_row_count    = EXCLUDED.last_row_count,
  data_freshness_ts = EXCLUDED.data_freshness_ts,
  status            = EXCLUDED.status,
  updated_at        = NOW();

INSERT INTO ops.sli_slo_targets (
  slo_id, metric_name, target_threshold, observed_value, unit, compliance_status, evidence_ref
) VALUES
  ('SLO-01', 'Durasi Batch Master Workflow E2E',       '<= 900 (15 menit)', '547.41 (9m 07d)', 'detik',   'MEETS_SLO', 'wf_capstone_e2e_master.hwf'),
  ('SLO-02', 'Latensi Kueri BI Top 15 Site Ranking',   '<= 500',            '0.103',           'ms',      'MEETS_SLO', 'uat_verification_output.txt'),
  ('SLO-03', 'Latensi Kueri BI Hazard Trends Tahunan', '<= 500',            '2.741',           'ms',      'MEETS_SLO', 'uat_verification_output.txt'),
  ('SLO-04', 'Idempotensi Lintas 83 Tabel / 7 Skema',  '0 baris berubah',   '0 baris berubah', 'baris',   'MEETS_SLO', 'snapshot_before vs snapshot_after'),
  ('SLO-05', 'Kelengkapan Geografis & Validitas Geom', '100% (514/514)',    '100% (514/514)',  'wilayah', 'MEETS_SLO', 'UAT-01 & UAT-05'),
  ('SLO-06', 'Recovery Time Objective (RTO) Mart Load','<= 60',             '5.35',            'detik',   'MEETS_SLO', 'wf_mart_load.hwf')
ON CONFLICT (slo_id) DO UPDATE SET
  observed_value    = EXCLUDED.observed_value,
  compliance_status = EXCLUDED.compliance_status,
  measured_at       = NOW();

-- View Observability untuk dq_steward
CREATE OR REPLACE VIEW semantic.v_dc_ops_observability AS
SELECT
  run_id, job_name, layer, run_mode, status,
  started_at, finished_at, duration_sec,
  rows_in, rows_out, rows_rejected, rows_warning,
  attempt_no, error_message, notes
FROM ops.etl_run_log
ORDER BY started_at DESC;

GRANT SELECT ON ops.etl_run_log, ops.pipeline_checkpoint, ops.sli_slo_targets, semantic.v_dc_ops_observability TO dq_steward;
GRANT SELECT, INSERT, UPDATE ON ops.etl_run_log, ops.pipeline_checkpoint TO etl_runner;