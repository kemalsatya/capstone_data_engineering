-- =============================================================================
-- test_security_rbac.sql
-- Uji Positif & Negatif Otorisasi RBAC (Komponen 7 & Komponen 9)
-- =============================================================================

CREATE TEMP TABLE tmp_sec_results (
  test_id     TEXT,
  role_tested TEXT,
  test_type   TEXT,
  deskripsi   TEXT,
  expected    TEXT,
  observed    TEXT,
  status      TEXT
);

DO $$
DECLARE
  v_cnt BIGINT;
  v_obs TEXT;
  v_ok  BOOLEAN;
BEGIN
  -- SEC-01 (Positive): bi_reader BOLEH membaca protected view semantic
  SET ROLE bi_reader;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM semantic.v_dc_site_ranking_protected;
    v_ok  := (v_cnt = 514);
    v_obs := 'ALLOWED: ' || v_cnt::text || ' rows';
  EXCEPTION WHEN OTHERS THEN
    v_ok  := FALSE;
    v_obs := 'ERROR: ' || SQLERRM;
  END;
  RESET ROLE;
  INSERT INTO tmp_sec_results VALUES (
    'SEC-01', 'bi_reader', 'POSITIVE',
    'SELECT semantic.v_dc_site_ranking_protected',
    'ALLOWED (514 rows)', v_obs, CASE WHEN v_ok THEN 'PASS' ELSE 'FAIL' END
  );

  -- SEC-02 (Negative): bi_reader DILARANG membaca skema raw
  SET ROLE bi_reader;
  BEGIN
    PERFORM 1 FROM raw.src_01_bmkg_gempa LIMIT 1;
    v_ok  := FALSE;
    v_obs := 'UNEXPECTED_ALLOW';
  EXCEPTION WHEN insufficient_privilege THEN
    v_ok  := TRUE;
    v_obs := 'DENIED: ' || SQLERRM;
  END;
  RESET ROLE;
  INSERT INTO tmp_sec_results VALUES (
    'SEC-02', 'bi_reader', 'NEGATIVE',
    'SELECT raw.src_01_bmkg_gempa',
    'DENIED (insufficient_privilege)', v_obs, CASE WHEN v_ok THEN 'PASS' ELSE 'FAIL' END
  );

  -- SEC-03 (Negative): bi_reader DILARANG membaca parameter internal ops
  SET ROLE bi_reader;
  BEGIN
    PERFORM 1 FROM ops.scoring_parameters LIMIT 1;
    v_ok  := FALSE;
    v_obs := 'UNEXPECTED_ALLOW';
  EXCEPTION WHEN insufficient_privilege THEN
    v_ok  := TRUE;
    v_obs := 'DENIED: ' || SQLERRM;
  END;
  RESET ROLE;
  INSERT INTO tmp_sec_results VALUES (
    'SEC-03', 'bi_reader', 'NEGATIVE',
    'SELECT ops.scoring_parameters',
    'DENIED (insufficient_privilege)', v_obs, CASE WHEN v_ok THEN 'PASS' ELSE 'FAIL' END
  );

  -- SEC-04 (Negative): bi_reader DILARANG menghapus data di mart
  SET ROLE bi_reader;
  BEGIN
    DELETE FROM mart.fact_site_suitability WHERE 1 = 0;
    v_ok  := FALSE;
    v_obs := 'UNEXPECTED_ALLOW';
  EXCEPTION WHEN insufficient_privilege THEN
    v_ok  := TRUE;
    v_obs := 'DENIED: ' || SQLERRM;
  END;
  RESET ROLE;
  INSERT INTO tmp_sec_results VALUES (
    'SEC-04', 'bi_reader', 'NEGATIVE',
    'DELETE FROM mart.fact_site_suitability',
    'DENIED (insufficient_privilege)', v_obs, CASE WHEN v_ok THEN 'PASS' ELSE 'FAIL' END
  );

  -- SEC-05 (Negative): dq_steward BOLEH baca DQ, tetapi DILARANG menghapus log DQ
  SET ROLE dq_steward;
  BEGIN
    DELETE FROM dq.capstone_quality_issues WHERE 1 = 0;
    v_ok  := FALSE;
    v_obs := 'UNEXPECTED_ALLOW';
  EXCEPTION WHEN insufficient_privilege THEN
    v_ok  := TRUE;
    v_obs := 'DENIED: ' || SQLERRM;
  END;
  RESET ROLE;
  INSERT INTO tmp_sec_results VALUES (
    'SEC-05', 'dq_steward', 'NEGATIVE',
    'DELETE FROM dq.capstone_quality_issues (read-only steward)',
    'DENIED (insufficient_privilege)', v_obs, CASE WHEN v_ok THEN 'PASS' ELSE 'FAIL' END
  );

  -- SEC-06 (Negative): etl_runner DILARANG menjalankan DDL (CREATE TABLE) di mart
  SET ROLE etl_runner;
  BEGIN
    EXECUTE 'CREATE TABLE mart._unauthorized_ddl_test (id int)';
    v_ok  := FALSE;
    v_obs := 'UNEXPECTED_ALLOW';
  EXCEPTION WHEN insufficient_privilege THEN
    v_ok  := TRUE;
    v_obs := 'DENIED: ' || SQLERRM;
  END;
  RESET ROLE;
  INSERT INTO tmp_sec_results VALUES (
    'SEC-06', 'etl_runner', 'NEGATIVE',
    'CREATE TABLE di skema mart (no DDL privilege)',
    'DENIED (insufficient_privilege)', v_obs, CASE WHEN v_ok THEN 'PASS' ELSE 'FAIL' END
  );
END $$;

\echo '=== HASIL UJI RBAC & NEGATIVE AUTHORIZATION TEST ==='
SELECT test_id, role_tested, test_type, status, deskripsi, observed
FROM tmp_sec_results
ORDER BY test_id;

\echo ''
\echo '=== SAMPEL PROTECTED VIEW (MINIMIZATION & MASKING) ==='
SELECT national_rank_eligible, kabkota_name, approx_lat, approx_lon, composite_score, permitted_purpose_notice
FROM semantic.v_dc_site_ranking_protected
WHERE NOT is_knockout
ORDER BY national_rank_eligible
LIMIT 5;

\echo ''
\echo '=== KEBIJAKAN KLASIFIKASI & RETENSI DATA ==='
SELECT policy_id, layer_schema, classification, retention_days, data_owner_role
FROM ops.data_classification_policy
ORDER BY policy_id;