CREATE SCHEMA IF NOT EXISTS dq;

CREATE TABLE IF NOT EXISTS dq.quarantine_records (
  quarantine_id  bigserial PRIMARY KEY,
  run_id         bigint NOT NULL REFERENCES ops.pipeline_runs(run_id),
  source_table   text   NOT NULL,
  record_id      text,
  rule_id        text   NOT NULL,
  failed_column  text,
  failed_value   text,
  reason         text   NOT NULL,
  payload_raw    jsonb  NOT NULL,
  quarantined_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS dq.capstone_quality_issues (
  issue_id     bigserial PRIMARY KEY,
  run_id       bigint NOT NULL REFERENCES ops.pipeline_runs(run_id),
  rule_id      text   NOT NULL,
  source_table text   NOT NULL,
  record_id    text,
  severity     text   NOT NULL CHECK (severity IN ('CRITICAL','HIGH','WARNING','INFO')),
  reason       text   NOT NULL,
  detected_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dq_quarantine_run_src
  ON dq.quarantine_records (run_id, source_table);

CREATE INDEX IF NOT EXISTS idx_dq_capstone_issues_run_rule
  ON dq.capstone_quality_issues (run_id, rule_id);