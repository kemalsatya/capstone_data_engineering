#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
run_ingestion.py - Runner CLI untuk memuat seluruh sumber SRC-01..SRC-12 ke 15 tabel raw.src_*
Contoh:
  python3 /config/workspace/python/run_ingestion.py --root "/config/workspace/data/Sumber Data" --only SRC-09
  python3 /config/workspace/python/run_ingestion.py --root "/config/workspace/data/Sumber Data"
"""
import argparse
import sys
import time
from pathlib import Path

INGESTION_DIR = Path(__file__).resolve().parent / "ingestion"
if str(INGESTION_DIR) not in sys.path:
    sys.path.insert(0, str(INGESTION_DIR))

import loaders  # noqa: E402
import profile_sources as ps  # noqa: E402


def main():
    ap = argparse.ArgumentParser(description="Ingestion SRC-01..SRC-12 ke tabel raw.src_* di PostgreSQL.")
    ap.add_argument("--root", default="/config/workspace/data/Sumber Data", help="Folder induk berisi SRC-01..SRC-12")
    ap.add_argument("--only", default="", help="Filter sumber tertentu, mis. SRC-01,SRC-09")
    ap.add_argument("--schema", default="raw", help="Skema tujuan (default: raw)")
    args = ap.parse_args()

    dirs = ps.find_source_dirs(args.root)
    if not dirs:
        sys.exit(f"ERROR: Folder SRC-xx tidak ditemukan di '{args.root}'")

    target_srcs = [s.strip().upper() for s in args.only.split(",") if s.strip()] if args.only else list(ps.SOURCES.keys())

    conn = loaders.get_db_conn()
    summary = {}
    t_all = time.time()

    try:
        for sid in target_srcs:
            folder = dirs.get(sid)
            if folder is None:
                print(f"[SKIP] {sid}: folder tidak ditemukan")
                continue

            items, _docs, _dups = ps.discover(folder, sid)
            for item in items:
                table = loaders.resolve_target_table(sid, item["spec"], item["rel"])
                if table is None:
                    print(f"[SKIP] {sid} | {item['rel']} ({item['spec'].get('role')})")
                    continue

                t0 = time.time()
                print(f"[LOAD] {sid} | {item['rel']} -> {args.schema}.{table} ...", flush=True)
                res = loaders.ingest_source_item(conn, sid, item, raw_schema=args.schema)
                if res:
                    tbl, n_rows, run_id = res
                    summary[tbl] = summary.get(tbl, 0) + n_rows
                    print(f"       OK: {n_rows:,} baris (run_id={run_id}, {time.time() - t0:.1f}s)", flush=True)
    finally:
        conn.close()

    print("\n=== RINGKASAN INGESTION ===")
    for tbl in sorted(summary):
        print(f"  {args.schema}.{tbl:<28s} : {summary[tbl]:>10,} baris")
    print(f"Total tabel dimuat : {len(summary)} | Waktu total: {time.time() - t_all:.1f}s")


if __name__ == "__main__":
    main()