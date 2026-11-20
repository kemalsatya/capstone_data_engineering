#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_hop_assets.py - Generator 15 pipeline staging+DQ (.hpl) dan 1 master workflow (.hwf)
untuk Apache Hop 2.19.0 berdasarkan pipeline_manifest.json + introspeksi skema PostgreSQL.
"""
import json
import os
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from xml.sax.saxutils import escape

import psycopg2

BASE_DIR = Path(__file__).resolve().parent
MANIFEST_PATH = BASE_DIR / "pipeline_manifest.json"
PIPELINES_DIR = BASE_DIR / "pipelines"
WORKFLOWS_DIR = BASE_DIR / "workflows"

META_COLS = {"_batch_id", "_src_id", "_src_file", "_row_no", "_loaded_at"}


def get_db_conn():
    return psycopg2.connect(
        host=os.environ.get("LAB_DB_HOST", "postgres"),
        port=int(os.environ.get("LAB_DB_PORT", "5432")),
        dbname=os.environ.get("LAB_DB_NAME", "labdata"),
        user=os.environ.get("LAB_DB_USER", "labuser"),
        password=os.environ.get("LAB_DB_PASSWORD", ""),
    )


def fetch_stg_columns(cur, schema: str, table: str) -> list[tuple[str, str]]:
    """Kembalikan list (column_name, data_type) dari stg.<table> sesuai urutan kolom."""
    cur.execute(
        """
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = %s AND table_name = %s
        ORDER BY ordinal_position
        """,
        (schema, table),
    )
    cols = cur.fetchall()
    if not cols:
        raise RuntimeError(f"Tabel {schema}.{table} tidak ditemukan di PostgreSQL.")
    return cols


def sql_quote_lit(val: str) -> str:
    return "'" + str(val).replace("'", "''") + "'"


def clean_expr(col: str, sentinels_sql: str) -> str:
    q = f'"{col}"'
    return f"CASE WHEN LOWER(TRIM(r.{q})) IN ({sentinels_sql}) THEN NULL ELSE TRIM(r.{q}) END"


def build_cast_expr(col: str, data_type: str, spec: dict, sentinels_sql: str) -> str:
    """Bangun ekspresi SQL safe-casting sesuai tipe kolom aktual di stg.*."""
    c = clean_expr(col, sentinels_sql)
    date_fmts = spec.get("date_formats") or {}
    epoch_cols = set(spec.get("epoch_columns") or [])

    if col in epoch_cols:
        return (
            f"CASE WHEN ({c}) ~ '^[0-9]+(?:\\.0+)?$' "
            f"THEN TO_TIMESTAMP(TRUNC(({c})::numeric)) ELSE NULL END"
        )

    if data_type in ("integer", "bigint", "smallint"):
        return (
            f"CASE WHEN ({c}) ~ '^[-+]?[0-9]+(?:\\.0+)?$' "
            f"THEN TRUNC(({c})::numeric)::{data_type} ELSE NULL END"
        )

    if data_type in ("numeric", "double precision", "real"):
        return (
            f"CASE "
            f"WHEN ({c}) ~ '^[-+]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN ({c})::numeric "
            f"WHEN ({c}) ~ '^[-+]?[0-9]+,[0-9]+$' THEN REPLACE(({c}), ',', '.')::numeric "
            f"ELSE NULL END"
        )

    if data_type == "date":
        fmt = date_fmts.get(col)
        if fmt == "DD-Mon-YYYY":
            return (
                f"CASE "
                f"WHEN ({c}) ~ '^[0-9]{{1,2}}-[A-Za-z]{{3}}-[0-9]{{4}}$' THEN TO_DATE(({c}), 'DD-Mon-YYYY') "
                f"WHEN ({c}) ~ '^[0-9]{{4}}-[0-9]{{2}}-[0-9]{{2}}' THEN SUBSTRING(({c}) FROM 1 FOR 10)::date "
                f"ELSE NULL END"
            )
        if fmt == "DD-MM-YYYY":
            return (
                f"CASE "
                f"WHEN ({c}) ~ '^[0-9]{{1,2}}-[0-9]{{1,2}}-[0-9]{{4}}$' THEN TO_DATE(({c}), 'DD-MM-YYYY') "
                f"WHEN ({c}) ~ '^[0-9]{{4}}-[0-9]{{2}}-[0-9]{{2}}' THEN SUBSTRING(({c}) FROM 1 FOR 10)::date "
                f"ELSE NULL END"
            )
        return (
            f"CASE WHEN ({c}) ~ '^[0-9]{{4}}-[0-9]{{2}}-[0-9]{{2}}' "
            f"THEN SUBSTRING(({c}) FROM 1 FOR 10)::date ELSE NULL END"
        )

    if data_type == "timestamp with time zone":
        return (
            f"CASE WHEN ({c}) ~ '^[0-9]{{4}}-[0-9]{{2}}-[0-9]{{2}}' "
            f"THEN ({c})::timestamptz ELSE NULL END"
        )

    if data_type == "boolean":
        return (
            f"CASE "
            f"WHEN LOWER({c}) IN ('true','t','1','yes','y','ya') THEN TRUE "
            f"WHEN LOWER({c}) IN ('false','f','0','no','n','tidak') THEN FALSE "
            f"ELSE NULL END"
        )

    # text / character varying
    return c


def build_table_input_sql(spec: dict, stg_cols: list[tuple[str, str]], manifest: dict) -> tuple[str, list[str]]:
    """Bangun kueri CTE lengkap (latest_raw -> [deduped] -> typed -> dq_eval) untuk TableInput."""
    raw_schema = manifest["raw_schema"]
    table = spec["table"]
    sentinels_sql = ", ".join(sql_quote_lit(s) for s in manifest["sentinels"])

    # Kolom non-geom dan non-_loaded_at yang akan ditulis ke stg.<table>
    data_cols = [(c, t) for c, t in stg_cols if c not in META_COLS and t != "USER-DEFINED"]
    stg_output_cols = ["_batch_id", "_src_id", "_src_file", "_row_no"] + [c for c, _ in data_cols]

    # Bangun daftar aturan DQ (gabungkan aturan eksplisit + aturan dinamis numeric_range_all jika ada)
    rules = list(spec.get("dq_rules") or [])
    nra = spec.get("numeric_range_all")
    if nra:
        excl = set(nra.get("exclude") or [])
        num_cols = [
            c for c, t in data_cols
            if t in ("numeric", "integer", "bigint", "double precision", "real") and c not in excl
        ]
        if num_cols:
            cond = " OR ".join(
                f'("{c}" IS NOT NULL AND "{c}" NOT BETWEEN {nra["min"]} AND {nra["max"]})'
                for c in num_cols
            )
            rules.append({
                "rule_id": nra["rule_id"],
                "severity": nra["severity"],
                "column": ",".join(num_cols),
                "value_expr": "CONCAT_WS(',', " + ", ".join(f"'{c}=' || COALESCE(\"{c}\"::text,'NULL')" for c in num_cols[:4]) + ")",
                "condition": cond,
                "reason": nra["reason"],
            })

    # Urutkan CRITICAL lebih dulu agar jika satu baris melanggar CRITICAL & WARNING, CRITICAL yang menang
    rules_sorted = sorted(rules, key=lambda r: 0 if r["severity"] == "CRITICAL" else 1)
    crit_rules = [r for r in rules_sorted if r["severity"] == "CRITICAL"]

    # CTE 1: Ambil _batch_id terbaru PER _src_file (mendukung tabel multi-file seperti SRC-10 & SRC-12)
    ctes = [
        f"""latest_batches AS (
  SELECT _src_file, MAX(_batch_id) AS max_batch_id
  FROM {raw_schema}.{table}
  GROUP BY _src_file
)""",
        f"""latest_raw AS (
  SELECT r.*
  FROM {raw_schema}.{table} r
  JOIN latest_batches lb
    ON r._src_file = lb._src_file
   AND r._batch_id = lb.max_batch_id
)""",
    ]

    src_cte = "latest_raw"
    if spec.get("dedup_exact"):
        part_cols = ", ".join(f'r."{c}"' for c, _ in data_cols)
        sel_cols = ", ".join(f'sub."{c}"' for c in ["_batch_id", "_src_id", "_src_file", "_row_no"] + [c for c, _ in data_cols])
        ctes.append(
            f"""deduped AS (
  SELECT {sel_cols}
  FROM (
    SELECT r.*,
           ROW_NUMBER() OVER (PARTITION BY {part_cols} ORDER BY r._row_no) AS _dedup_rn
    FROM latest_raw r
  ) sub
  WHERE _dedup_rn = 1
)"""
        )
        src_cte = "deduped"

    # CTE typed: safe casting semua kolom + simpan payload_raw JSON dari baris mentah
    cast_lines = [
        "  r._batch_id",
        "  r._src_id",
        "  r._src_file",
        "  r._row_no",
        "  to_jsonb(r)::text AS dq_payload_raw",
    ]
    for col, dtype in data_cols:
        expr = build_cast_expr(col, dtype, spec, sentinels_sql)
        cast_lines.append(f'  ({expr}) AS "{col}"')

    ctes.append(
        "typed AS (\nSELECT\n" + ",\n".join(cast_lines) + f"\nFROM {src_cte} r\n)"
    )

    # CTE dq_eval: evaluasi aturan CRITICAL & WARNING pada nilai hasil cast sebelum nullifikasi sensor
    if crit_rules:
        crit_cond = " OR ".join(f"({r['condition']})" for r in crit_rules)
        is_crit_expr = f"CASE WHEN {crit_cond} THEN 'Y' ELSE 'N' END"
    else:
        is_crit_expr = "'N'::text"

    if rules_sorted:
        any_cond = " OR ".join(f"({r['condition']})" for r in rules_sorted)
        has_issue_expr = f"CASE WHEN {any_cond} THEN 'Y' ELSE 'N' END"

        rule_id_cases = "\n    ".join(f"WHEN {r['condition']} THEN {sql_quote_lit(r['rule_id'])}" for r in rules_sorted)
        sev_cases = "\n    ".join(f"WHEN {r['condition']} THEN {sql_quote_lit(r['severity'])}" for r in rules_sorted)
        col_cases = "\n    ".join(f"WHEN {r['condition']} THEN {sql_quote_lit(r['column'])}" for r in rules_sorted)
        val_cases = "\n    ".join(f"WHEN {r['condition']} THEN ({r.get('value_expr', 'NULL::text')})::text" for r in rules_sorted)
        reason_cases = "\n    ".join(f"WHEN {r['condition']} THEN {sql_quote_lit(r['reason'])}" for r in rules_sorted)

        rule_id_expr = f"CASE\n    {rule_id_cases}\n    ELSE NULL\n  END"
        sev_expr = f"CASE\n    {sev_cases}\n    ELSE NULL\n  END"
        col_expr = f"CASE\n    {col_cases}\n    ELSE NULL\n  END"
        val_expr = f"CASE\n    {val_cases}\n    ELSE NULL\n  END"
        reason_expr = f"CASE\n    {reason_cases}\n    ELSE NULL\n  END"
    else:
        has_issue_expr = "'N'::text"
        rule_id_expr = sev_expr = col_expr = val_expr = reason_expr = "NULL::text"

    # Terapkan nullifikasi nilai sensor ekstrem pada kolom output staging jika diatur di manifest
    nullify_rules = spec.get("nullify_rules") or {}
    final_data_lines = []
    for col, _ in data_cols:
        if col in nullify_rules:
            final_data_lines.append(f'  CASE WHEN ({nullify_rules[col]}) THEN NULL ELSE "{col}" END AS "{col}"')
        else:
            final_data_lines.append(f'  "{col}"')

    rec_id_expr = spec.get("record_id_expr", "_src_file || '#' || _row_no")
    final_select = (
        "SELECT\n"
        "  _batch_id,\n"
        "  _src_id,\n"
        "  _src_file,\n"
        "  _row_no,\n"
        + ",\n".join(final_data_lines)
        + ",\n"
        f"  {is_crit_expr} AS dq_is_critical,\n"
        f"  {has_issue_expr} AS dq_has_issue,\n"
        f"  {rule_id_expr} AS dq_rule_id,\n"
        f"  {sev_expr} AS dq_severity,\n"
        f"  {col_expr} AS dq_failed_column,\n"
        f"  {val_expr} AS dq_failed_value,\n"
        f"  {reason_expr} AS dq_reason,\n"
        f"  ({rec_id_expr})::text AS dq_record_id,\n"
        f"  {sql_quote_lit(f'{raw_schema}.{table}')}::text AS dq_source_table,\n"
        "  dq_payload_raw\n"
        "FROM typed"
    )

    full_sql = "WITH\n" + ",\n".join(ctes) + "\n" + final_select + ";"
    return full_sql, stg_output_cols


def build_hpl_xml(table_name: str, sql: str, stg_fields: list[str], manifest: dict) -> str:
    conn = manifest["connection"]
    stg_schema = manifest["stg_schema"]
    dq_schema = manifest["dq_schema"]

    stg_fields_xml = "\n".join(
        f"      <field>\n        <column_name>{escape(col)}</column_name>\n        <stream_name>{escape(col)}</stream_name>\n      </field>"
        for col in stg_fields
    )

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<pipeline>
  <info>
    <name>pl_stg_{escape(table_name)}</name>
    <name_sync_with_filename>Y</name_sync_with_filename>
    <description>Staging &amp; DQ pipeline untuk {escape(table_name)}</description>
    <extended_description/>
    <pipeline_version/>
    <pipeline_type>Normal</pipeline_type>
    <parameters/>
    <capture_transform_performance>N</capture_transform_performance>
    <transform_performance_capturing_delay>1000</transform_performance_capturing_delay>
    <transform_performance_capturing_size_limit>100</transform_performance_capturing_size_limit>
    <created_user>generate_hop_assets</created_user>
    <created_date>2026/11/19 00:00:00.000</created_date>
    <modified_user>generate_hop_assets</modified_user>
    <modified_date>2026/11/19 00:00:00.000</modified_date>
  </info>
  <notepads/>
  <order>
    <hop><from>Read &amp; Validate Raw</from><to>Filter Critical DQ</to><enabled>Y</enabled></hop>
    <hop><from>Read &amp; Validate Raw</from><to>Filter DQ Issues</to><enabled>Y</enabled></hop>
    <hop><from>Filter Critical DQ</from><to>Quarantine Records</to><enabled>Y</enabled></hop>
    <hop><from>Filter Critical DQ</from><to>Load Staging</to><enabled>Y</enabled></hop>
    <hop><from>Filter DQ Issues</from><to>Log DQ Issues</to><enabled>Y</enabled></hop>
    <hop><from>Filter DQ Issues</from><to>No DQ Issue</to><enabled>Y</enabled></hop>
  </order>
  <transform>
    <name>Read &amp; Validate Raw</name>
    <type>TableInput</type>
    <description/>
    <distribute>N</distribute>
    <custom_distribution/>
    <copies>1</copies>
    <partitioning><method>none</method><schema_name/></partitioning>
    <connection>{escape(conn)}</connection>
    <execute_each_row>N</execute_each_row>
    <limit>0</limit>
    <sql>{escape(sql)}</sql>
    <variables_active>Y</variables_active>
    <attributes/>
    <GUI><xloc>120</xloc><yloc>200</yloc></GUI>
  </transform>
  <transform>
    <name>Filter Critical DQ</name>
    <type>FilterRows</type>
    <description/>
    <distribute>Y</distribute>
    <custom_distribution/>
    <copies>1</copies>
    <partitioning><method>none</method><schema_name/></partitioning>
    <send_true_to>Quarantine Records</send_true_to>
    <send_false_to>Load Staging</send_false_to>
    <compare>
      <condition>
        <negated>N</negated>
        <leftvalue>dq_is_critical</leftvalue>
        <function>=</function>
        <rightvalue/>
        <value>
          <name>constant</name>
          <type>String</type>
          <text>Y</text>
          <length>-1</length>
          <precision>-1</precision>
          <isnull>N</isnull>
          <mask/>
        </value>
      </condition>
    </compare>
    <attributes/>
    <GUI><xloc>360</xloc><yloc>120</yloc></GUI>
  </transform>
  <transform>
    <name>Filter DQ Issues</name>
    <type>FilterRows</type>
    <description/>
    <distribute>Y</distribute>
    <custom_distribution/>
    <copies>1</copies>
    <partitioning><method>none</method><schema_name/></partitioning>
    <send_true_to>Log DQ Issues</send_true_to>
    <send_false_to>No DQ Issue</send_false_to>
    <compare>
      <condition>
        <negated>N</negated>
        <leftvalue>dq_has_issue</leftvalue>
        <function>=</function>
        <rightvalue/>
        <value>
          <name>constant</name>
          <type>String</type>
          <text>Y</text>
          <length>-1</length>
          <precision>-1</precision>
          <isnull>N</isnull>
          <mask/>
        </value>
      </condition>
    </compare>
    <attributes/>
    <GUI><xloc>360</xloc><yloc>300</yloc></GUI>
  </transform>
  <transform>
    <name>Load Staging</name>
    <type>TableOutput</type>
    <description/>
    <distribute>Y</distribute>
    <custom_distribution/>
    <copies>1</copies>
    <partitioning><method>none</method><schema_name/></partitioning>
    <connection>{escape(conn)}</connection>
    <schema>{escape(stg_schema)}</schema>
    <table>{escape(table_name)}</table>
    <commit>5000</commit>
    <truncate>N</truncate>
    <ignore_errors>N</ignore_errors>
    <use_batch>Y</use_batch>
    <specify_fields>Y</specify_fields>
    <partitioning_enabled>N</partitioning_enabled>
    <partitioning_field/>
    <partitioning_daily>N</partitioning_daily>
    <partitioning_monthly>Y</partitioning_monthly>
    <tablename_in_field>N</tablename_in_field>
    <tablename_field/>
    <tablename_in_table>Y</tablename_in_table>
    <return_keys>N</return_keys>
    <return_field/>
    <fields>
{stg_fields_xml}
    </fields>
    <attributes/>
    <GUI><xloc>640</xloc><yloc>160</yloc></GUI>
  </transform>
  <transform>
    <name>Quarantine Records</name>
    <type>TableOutput</type>
    <description/>
    <distribute>Y</distribute>
    <custom_distribution/>
    <copies>1</copies>
    <partitioning><method>none</method><schema_name/></partitioning>
    <connection>{escape(conn)}</connection>
    <schema>{escape(dq_schema)}</schema>
    <table>quarantine_records</table>
    <commit>1000</commit>
    <truncate>N</truncate>
    <ignore_errors>N</ignore_errors>
    <use_batch>Y</use_batch>
    <specify_fields>Y</specify_fields>
    <partitioning_enabled>N</partitioning_enabled>
    <partitioning_field/>
    <partitioning_daily>N</partitioning_daily>
    <partitioning_monthly>Y</partitioning_monthly>
    <tablename_in_field>N</tablename_in_field>
    <tablename_field/>
    <tablename_in_table>Y</tablename_in_table>
    <return_keys>N</return_keys>
    <return_field/>
    <fields>
      <field><column_name>run_id</column_name><stream_name>_batch_id</stream_name></field>
      <field><column_name>source_table</column_name><stream_name>dq_source_table</stream_name></field>
      <field><column_name>record_id</column_name><stream_name>dq_record_id</stream_name></field>
      <field><column_name>rule_id</column_name><stream_name>dq_rule_id</stream_name></field>
      <field><column_name>failed_column</column_name><stream_name>dq_failed_column</stream_name></field>
      <field><column_name>failed_value</column_name><stream_name>dq_failed_value</stream_name></field>
      <field><column_name>reason</column_name><stream_name>dq_reason</stream_name></field>
      <field><column_name>payload_raw</column_name><stream_name>dq_payload_raw</stream_name></field>
    </fields>
    <attributes/>
    <GUI><xloc>640</xloc><yloc>60</yloc></GUI>
  </transform>
  <transform>
    <name>Log DQ Issues</name>
    <type>TableOutput</type>
    <description/>
    <distribute>Y</distribute>
    <custom_distribution/>
    <copies>1</copies>
    <partitioning><method>none</method><schema_name/></partitioning>
    <connection>{escape(conn)}</connection>
    <schema>{escape(dq_schema)}</schema>
    <table>capstone_quality_issues</table>
    <commit>1000</commit>
    <truncate>N</truncate>
    <ignore_errors>N</ignore_errors>
    <use_batch>Y</use_batch>
    <specify_fields>Y</specify_fields>
    <partitioning_enabled>N</partitioning_enabled>
    <partitioning_field/>
    <partitioning_daily>N</partitioning_daily>
    <partitioning_monthly>Y</partitioning_monthly>
    <tablename_in_field>N</tablename_in_field>
    <tablename_field/>
    <tablename_in_table>Y</tablename_in_table>
    <return_keys>N</return_keys>
    <return_field/>
    <fields>
      <field><column_name>run_id</column_name><stream_name>_batch_id</stream_name></field>
      <field><column_name>rule_id</column_name><stream_name>dq_rule_id</stream_name></field>
      <field><column_name>source_table</column_name><stream_name>dq_source_table</stream_name></field>
      <field><column_name>record_id</column_name><stream_name>dq_record_id</stream_name></field>
      <field><column_name>severity</column_name><stream_name>dq_severity</stream_name></field>
      <field><column_name>reason</column_name><stream_name>dq_reason</stream_name></field>
    </fields>
    <attributes/>
    <GUI><xloc>640</xloc><yloc>260</yloc></GUI>
  </transform>
  <transform>
    <name>No DQ Issue</name>
    <type>Dummy</type>
    <description/>
    <distribute>Y</distribute>
    <custom_distribution/>
    <copies>1</copies>
    <partitioning><method>none</method><schema_name/></partitioning>
    <attributes/>
    <GUI><xloc>640</xloc><yloc>360</yloc></GUI>
  </transform>
  <transform_error_handling/>
  <attributes/>
</pipeline>
"""


def build_cleanup_sql(table: str, manifest: dict) -> str:
    raw_s, stg_s, dq_s = manifest["raw_schema"], manifest["stg_schema"], manifest["dq_schema"]
    batch_subq = f"(SELECT MAX(_batch_id) FROM {raw_s}.{table} GROUP BY _src_file)"
    return (
        f"DELETE FROM {stg_s}.{table} WHERE _batch_id IN {batch_subq};\n"
        f"DELETE FROM {dq_s}.quarantine_records WHERE source_table = '{raw_s}.{table}' AND run_id IN {batch_subq};\n"
        f"DELETE FROM {dq_s}.capstone_quality_issues WHERE source_table IN ('{raw_s}.{table}', '{stg_s}.{table}') AND run_id IN {batch_subq};"
    )


def build_spatial_sql(spec: dict, manifest: dict) -> str | None:
    sp = spec.get("spatial")
    if not sp:
        return None
    stg_s, dq_s, table = manifest["stg_schema"], manifest["dq_schema"], spec["table"]
    if sp["type"] == "point":
        lon, lat = sp["lon"], sp["lat"]
        return (
            f'UPDATE {stg_s}.{table} '
            f'SET geom = ST_SetSRID(ST_MakePoint("{lon}"::double precision, "{lat}"::double precision), 4326) '
            f'WHERE geom IS NULL AND "{lon}" IS NOT NULL AND "{lat}" IS NOT NULL;'
        )
    if sp["type"] == "wkt_polygon":
        wkt = sp["wkt_col"]
        return (
            f'UPDATE {stg_s}.{table} '
            f'SET geom = ST_SetSRID(ST_GeomFromText("{wkt}"), 4326) '
            f'WHERE geom IS NULL AND "{wkt}" IS NOT NULL;'
        )
    if sp["type"] == "geojson_makevalid":
        gj, pcode = sp["geojson_col"], sp["pcode_col"]
        return (
            f'UPDATE {stg_s}.{table} '
            f'SET geom = ST_MakeValid(ST_SetSRID(ST_GeomFromGeoJSON("{gj}"), 4326)) '
            f'WHERE geom IS NULL AND "{gj}" IS NOT NULL;\n'
            f"INSERT INTO {dq_s}.capstone_quality_issues (run_id, rule_id, source_table, record_id, severity, reason)\n"
            f'SELECT _batch_id, \'AB-GEO-02\', \'{stg_s}.{table}\', "{pcode}", \'HIGH\', '
            f"'Geometri tidak valid setelah ST_MakeValid: ' || ST_IsValidReason(geom)\n"
            f"FROM {stg_s}.{table}\n"
            f"WHERE geom IS NOT NULL AND NOT ST_IsValid(geom);"
        )
    return None


def build_master_workflow_xml(manifest: dict) -> str:
    conn = manifest["connection"]
    run_cfg = manifest["run_configuration"]
    actions_xml = []
    hops_xml = []

    actions_xml.append(
        """    <action>
      <name>Start</name>
      <type>SPECIAL</type>
      <repeat>N</repeat>
      <schedulerType>0</schedulerType>
      <intervalSeconds>0</intervalSeconds>
      <intervalMinutes>60</intervalMinutes>
      <hour>12</hour>
      <minutes>0</minutes>
      <weekDay>1</weekDay>
      <DayOfMonth>1</DayOfMonth>
      <parallel>N</parallel>
      <xloc>80</xloc>
      <yloc>80</yloc>
    </action>"""
    )

    prev = "Start"
    for idx, spec in enumerate(manifest["tables"]):
        tbl = spec["table"]
        y = 80 + idx * 90

        # 1. Pre-cleanup SQL action
        clean_name = f"Clean {tbl}"
        clean_sql = build_cleanup_sql(tbl, manifest)
        actions_xml.append(
            f"""    <action>
      <name>{escape(clean_name)}</name>
      <type>SQL</type>
      <sql>{escape(clean_sql)}</sql>
      <useVariableSubstitution>T</useVariableSubstitution>
      <sqlfromfile>F</sqlfromfile>
      <sqlfilename/>
      <sendOneStatement>F</sendOneStatement>
      <connection>{escape(conn)}</connection>
      <parallel>N</parallel>
      <xloc>260</xloc>
      <yloc>{y}</yloc>
    </action>"""
        )
        hops_xml.append(
            f"    <hop><from>{escape(prev)}</from><to>{escape(clean_name)}</to><enabled>Y</enabled><evaluation>Y</evaluation><unconditional>{'Y' if prev == 'Start' else 'N'}</unconditional></hop>"
        )
        prev = clean_name

        # 2. Pipeline execution action
        pipe_name = f"Run pl_stg_{tbl}"
        actions_xml.append(
            f"""    <action>
      <name>{escape(pipe_name)}</name>
      <type>PIPELINE</type>
      <filename>${{PROJECT_HOME}}/pipelines/pl_stg_{escape(tbl)}.hpl</filename>
      <params_from_previous>N</params_from_previous>
      <exec_per_row>N</exec_per_row>
      <clear_rows>N</clear_rows>
      <clear_files>N</clear_files>
      <set_logfile>N</set_logfile>
      <logfile/>
      <logext/>
      <add_date>N</add_date>
      <add_time>N</add_time>
      <loglevel>Basic</loglevel>
      <set_append_logfile>N</set_append_logfile>
      <wait_until_finished>Y</wait_until_finished>
      <create_parent_folder>N</create_parent_folder>
      <run_configuration>{escape(run_cfg)}</run_configuration>
      <parameters>
        <pass_all_parameters>Y</pass_all_parameters>
      </parameters>
      <parallel>N</parallel>
      <xloc>500</xloc>
      <yloc>{y}</yloc>
    </action>"""
        )
        hops_xml.append(
            f"    <hop><from>{escape(prev)}</from><to>{escape(pipe_name)}</to><enabled>Y</enabled><evaluation>Y</evaluation><unconditional>N</unconditional></hop>"
        )
        prev = pipe_name

        # 3. PostGIS geometry update + ST_IsValid check (spatial tables only)
        sp_sql = build_spatial_sql(spec, manifest)
        if sp_sql:
            sp_name = f"PostGIS {tbl}"
            actions_xml.append(
                f"""    <action>
      <name>{escape(sp_name)}</name>
      <type>SQL</type>
      <sql>{escape(sp_sql)}</sql>
      <useVariableSubstitution>T</useVariableSubstitution>
      <sqlfromfile>F</sqlfromfile>
      <sqlfilename/>
      <sendOneStatement>F</sendOneStatement>
      <connection>{escape(conn)}</connection>
      <parallel>N</parallel>
      <xloc>740</xloc>
      <yloc>{y}</yloc>
    </action>"""
            )
            hops_xml.append(
                f"    <hop><from>{escape(prev)}</from><to>{escape(sp_name)}</to><enabled>Y</enabled><evaluation>Y</evaluation><unconditional>N</unconditional></hop>"
            )
            prev = sp_name

    # Final Success action
    actions_xml.append(
        f"""    <action>
      <name>Success</name>
      <type>SUCCESS</type>
      <parallel>N</parallel>
      <xloc>960</xloc>
      <yloc>{80 + (len(manifest['tables']) - 1) * 90}</yloc>
    </action>"""
    )
    hops_xml.append(
        f"    <hop><from>{escape(prev)}</from><to>Success</to><enabled>Y</enabled><evaluation>Y</evaluation><unconditional>N</unconditional></hop>"
    )

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<workflow>
  <name>wf_stg_master</name>
  <name_sync_with_filename>Y</name_sync_with_filename>
  <description>Master workflow staging, DQ, dan PostGIS untuk 15 tabel SRC-01..SRC-12</description>
  <extended_description/>
  <workflow_version/>
  <created_user>generate_hop_assets</created_user>
  <created_date>2026/11/19 00:00:00.000</created_date>
  <modified_user>generate_hop_assets</modified_user>
  <modified_date>2026/11/19 00:00:00.000</modified_date>
  <parameters/>
  <actions>
{chr(10).join(actions_xml)}
  </actions>
  <hops>
{chr(10).join(hops_xml)}
  </hops>
  <notepads/>
  <attributes/>
</workflow>
"""


def main():
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    PIPELINES_DIR.mkdir(parents=True, exist_ok=True)
    WORKFLOWS_DIR.mkdir(parents=True, exist_ok=True)

    conn = get_db_conn()
    try:
        with conn.cursor() as cur:
            for spec in manifest["tables"]:
                tbl = spec["table"]
                stg_cols = fetch_stg_columns(cur, manifest["stg_schema"], tbl)
                sql, stg_fields = build_table_input_sql(spec, stg_cols, manifest)
                hpl_xml = build_hpl_xml(tbl, sql, stg_fields, manifest)

                # Validasi XML sebelum ditulis
                ET.fromstring(hpl_xml)

                # Uji sintaks SQL lewat EXPLAIN di PostgreSQL (tidak mengeksekusi insert)
                cur.execute(f"EXPLAIN {sql}")

                out_hpl = PIPELINES_DIR / f"pl_stg_{tbl}.hpl"
                out_hpl.write_text(hpl_xml, encoding="utf-8")
                print(f"[OK] {out_hpl.name} ({len(stg_fields)} kolom, SQL EXPLAIN valid)")
    finally:
        conn.close()

    wf_xml = build_master_workflow_xml(manifest)
    ET.fromstring(wf_xml)
    out_wf = WORKFLOWS_DIR / "wf_stg_master.hwf"
    out_wf.write_text(wf_xml, encoding="utf-8")
    print(f"[OK] {out_wf.name} ({len(manifest['tables'])} tabel terorkestrasi)")


if __name__ == "__main__":
    main()