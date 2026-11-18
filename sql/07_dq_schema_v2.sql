-- =============================================================================
-- DDL SCHEMA DQ (Version 2 - Option B Full)
-- Schema Kualitas Data & Karantina (Audit Log + Full Raw Payload Karantina)
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS dq;

-- Drop legacy table (with order_id demo artifact) and old objects if any
DROP TABLE IF EXISTS dq.quality_issues CASCADE;
DROP TABLE IF EXISTS dq.quarantine_records CASCADE;

-- 1. Tabel Karantina: Menyimpan seluruh baris mentah yang gagal validasi via JSONB
CREATE TABLE dq.quarantine_records (
    quarantine_id   BIGSERIAL PRIMARY KEY,
    run_id          TEXT NOT NULL,
    source_table    TEXT NOT NULL,
    record_id       TEXT,
    rule_id         TEXT NOT NULL,
    failed_column   TEXT,
    failed_value    TEXT,
    reason          TEXT NOT NULL,
    payload_raw     JSONB NOT NULL,
    quarantined_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Tabel Audit Log Kualitas: Telemetri dan visualisasi metrik error
CREATE TABLE dq.quality_issues (
    issue_id        BIGSERIAL PRIMARY KEY,
    run_id          TEXT NOT NULL,
    rule_id         TEXT NOT NULL,
    source_table    TEXT NOT NULL,
    record_id       TEXT,
    severity        TEXT NOT NULL CHECK (severity IN ('CRITICAL', 'HIGH', 'WARNING', 'INFO')),
    reason          TEXT NOT NULL,
    detected_at     TIMESTAMPTZ DEFAULT NOW()
);

-- Index penunjang performa query audit
CREATE INDEX idx_dq_quarantine_src ON dq.quarantine_records(source_table, rule_id);
CREATE INDEX idx_dq_issues_rule ON dq.quality_issues(rule_id, severity);
