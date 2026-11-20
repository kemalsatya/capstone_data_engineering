#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
loaders.py - Loader Python untuk memuat SRC-01..SRC-12 ke 15 tabel raw.src_*
Menggunakan parser yang sama dengan profile_sources.py agar 100% sinkron dengan 03-raw.sql,
serta memakai PostgreSQL COPY untuk performa tinggi dan tracking batch di ops.pipeline_runs.
"""
import csv
import io
import os
import re
import sys
from pathlib import Path

import psycopg2

# Tambahkan folder profiling ke sys.path agar bisa memakai parser yang sudah teruji
PROFILING_DIR = Path(__file__).resolve().parent.parent / "profiling"
if str(PROFILING_DIR) not in sys.path:
    sys.path.insert(0, str(PROFILING_DIR))

import profile_sources as ps  # noqa: E402


def get_db_conn():
    """Buat koneksi PostgreSQL menggunakan environment variable kontainer workbench."""
    return psycopg2.connect(
        host=os.environ.get("LAB_DB_HOST", "postgres"),
        port=int(os.environ.get("LAB_DB_PORT", "5432")),
        dbname=os.environ.get("LAB_DB_NAME", "labdata"),
        user=os.environ.get("LAB_DB_USER", "labuser"),
        password=os.environ.get("LAB_DB_PASSWORD", ""),
    )


def get_table_columns(cur, schema: str, table: str) -> list[str]:
    """Ambil daftar kolom aktual dari database (kecuali _loaded_at yang memakai DEFAULT now())."""
    cur.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s AND table_name = %s
        ORDER BY ordinal_position
        """,
        (schema, table),
    )
    return [r[0] for r in cur.fetchall() if r[0] != "_loaded_at"]


def start_pipeline_run(cur, pipeline_name: str) -> int:
    """Catat awal eksekusi batch di ops.pipeline_runs dan kembalikan run_id (_batch_id)."""
    cur.execute(
        """
        INSERT INTO ops.pipeline_runs (pipeline_name, status, rows_processed, message)
        VALUES (%s, 'RUNNING', 0, 'Ingestion started')
        RETURNING run_id
        """,
        (pipeline_name,),
    )
    return int(cur.fetchone()[0])


def finish_pipeline_run(cur, run_id: int, status: str, rows_processed: int, message: str):
    """Perbarui status akhir batch di ops.pipeline_runs."""
    cur.execute(
        """
        UPDATE ops.pipeline_runs
        SET completed_at = now(),
            status = %s,
            rows_processed = %s,
            message = %s
        WHERE run_id = %s
        """,
        (status, rows_processed, message[:1000], run_id),
    )


def resolve_target_table(src_id: str, spec: dict, rel: str) -> str | None:
    """Tentukan nama tabel raw.src_* dari spec FILES di profile_sources.py."""
    if spec.get("role"):
        return None
    m = re.search(r"(\d+)", src_id)
    nn = m.group(1) if m else "xx"
    stem = re.sub(
        r"\.(csv|tsv|txt|json|geojson|jsonl|parquet|xlsx|xlsm|xls|shp|dbf|gz)$",
        "",
        Path(rel.split("!")[-1]).name,
        flags=re.I,
    )
    base = f"src_{nn}_{spec.get('table') or ps.ascii_slug(stem, 28) or 'data'}"[:55].strip("_")
    return base


def normalize_df_columns(df):
    """Ubah nama kolom DataFrame menjadi snake_case persis seperti fungsi snake() di profile_sources.py."""
    used = set()
    new_cols = [ps.snake(c, used) for c in df.columns]
    df = df.copy()
    df.columns = new_cols
    return df


def copy_dataframe_to_raw(cur, schema: str, table: str, df, batch_id: int, src_id: str, src_file: str, chunk_size: int = 50_000) -> int:
    """Muat DataFrame ke tabel raw.* menggunakan COPY FROM STDIN (CSV) per chunk."""
    db_cols = get_table_columns(cur, schema, table)
    if not db_cols:
        raise RuntimeError(f"Tabel {schema}.{table} tidak ditemukan di database.")

    df = normalize_df_columns(df)
    data_cols = [c for c in db_cols if c not in ("_batch_id", "_src_id", "_src_file", "_row_no")]

    # Pastikan semua kolom tabel tujuan ada di DataFrame (isi None jika absen pada salah satu file tahunan)
    for col in data_cols:
        if col not in df.columns:
            df[col] = None

    col_sql = ", ".join(f'"{c}"' for c in db_cols)
    copy_sql = f"COPY {schema}.{table} ({col_sql}) FROM STDIN WITH (FORMAT csv, NULL '\\N')"

    total_rows = len(df)
    row_no = 1
    for start in range(0, total_rows, chunk_size):
        chunk = df.iloc[start : start + chunk_size]
        buf = io.StringIO()
        writer = csv.writer(buf, lineterminator="\n")

        # Ekstrak nilai per baris secara cepat
        records = chunk[data_cols].itertuples(index=False, name=None)
        for rec in records:
            cleaned = [r"\N" if (v is None or v == "") else str(v) for v in rec]
            writer.writerow([batch_id, src_id, src_file, row_no] + cleaned)
            row_no += 1

        buf.seek(0)
        cur.copy_expert(copy_sql, buf)

    return total_rows


def ingest_source_item(conn, src_id: str, item: dict, raw_schema: str = "raw") -> tuple[str, int, int] | None:
    """Baca satu file sumber dan muat ke tabel raw.* dengan transaksi + tracking ops.pipeline_runs."""
    spec = item["spec"]
    table = resolve_target_table(src_id, spec, item["rel"])
    if table is None:
        return None  # Dilewati (dictionary, geojson duplikat, atau adm0/3/4/lines/points)

    cfg = {"max_rows": 10_000_000}
    if ps.SOURCES[src_id].get("headerless"):
        cfg["headerless_names"] = ps.SOURCES[src_id]["headerless"]

    pipeline_name = f"ingest_{raw_schema}_{table}"
    with conn.cursor() as cur:
        run_id = start_pipeline_run(cur, pipeline_name)
    conn.commit()

    try:
        df, _total, _meta = ps.read_file(item["path"], spec, cfg)
        with conn.cursor() as cur:
            loaded = copy_dataframe_to_raw(
                cur=cur,
                schema=raw_schema,
                table=table,
                df=df,
                batch_id=run_id,
                src_id=src_id,
                src_file=item["rel"],
            )
            finish_pipeline_run(cur, run_id, "SUCCESS", loaded, f"Loaded {item['rel']} -> {raw_schema}.{table}")
        conn.commit()
        return (table, loaded, run_id)
    except Exception as exc:
        conn.rollback()
        with conn.cursor() as cur:
            finish_pipeline_run(cur, run_id, "FAILED", 0, f"{type(exc).__name__}: {exc}")
        conn.commit()
        raise