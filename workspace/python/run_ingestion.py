#!/usr/bin/env python3
"""
CLI Orchestrator for Capstone Data Engineering Ingestion
Usage:
    python3 workspace/python/run_ingestion.py --all
    python3 workspace/python/run_ingestion.py --src SRC-01
    python3 workspace/python/run_ingestion.py --src SRC-01,SRC-02 --truncate
"""

import sys
import argparse
from pathlib import Path
from datetime import datetime

# Add ingestion directory to sys.path
SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR / "ingestion"))

import loaders

LOADER_MAP = {
    "SRC-01": loaders.load_src01,
    "SRC-02": loaders.load_src02,
    "SRC-03": loaders.load_src03,
    "SRC-04": loaders.load_src04,
    "SRC-05": loaders.load_src05,
    "SRC-06": loaders.load_src06,
    "SRC-07": loaders.load_src07,
    "SRC-08": loaders.load_src08,
    "SRC-09": loaders.load_src09,
    "SRC-10": loaders.load_src10,
    "SRC-11": loaders.load_src11,
    "SRC-12": loaders.load_src12,
}

TABLE_MAP = {
    "SRC-01": ["raw.src01_earthquake_catalog"],
    "SRC-02": ["raw.src02_disaster_records"],
    "SRC-03": ["raw.src03_climate_daily", "raw.src03_station_detail", "raw.src03_province_detail"],
    "SRC-04": ["raw.src04_master_features"],
    "SRC-05": ["raw.src05_cell_towers"],
    "SRC-06": ["raw.src06_ookla_fixed_broadband"],
    "SRC-07": ["raw.src07_power_plants"],
    "SRC-08": ["raw.src08_substations"],
    "SRC-09": ["raw.src09_isp_pop"],
    "SRC-10": ["raw.src10_iklh"],
    "SRC-11": ["raw.src11_admin_boundaries"],
    "SRC-12": ["raw.src12_population_demographics"],
}

def truncate_tables(sources):
    tables = []
    for s in sources:
        tables.extend(TABLE_MAP.get(s, []))
    if not tables:
        return
    print(f"--> Truncating tables before load: {', '.join(tables)}...")
    import subprocess
    cmd = loaders.get_psql_cmd() + ["-c", f"TRUNCATE {', '.join(tables)} RESTART IDENTITY;"]
    res = subprocess.run(cmd, cwd=str(loaders.PROJECT_ROOT), capture_output=True, text=True)
    if res.returncode != 0:
        print(f"Warning: Truncate failed: {res.stderr}")
    else:
        print("    [OK] Tables truncated.")

def main():
    parser = argparse.ArgumentParser(description="Automated Ingestion Runner for Data Engineering Capstone")
    parser.add_argument("--all", action="store_true", help="Ingest all 12 data sources (SRC-01 to SRC-12)")
    parser.add_argument("--src", type=str, help="Comma-separated sources to ingest, e.g. 'SRC-01' or 'SRC-01,SRC-02'")
    parser.add_argument("--truncate", action="store_true", help="Truncate target raw tables before ingestion")
    args = parser.parse_args()

    if not args.all and not args.src:
        parser.print_help()
        sys.exit(1)

    if args.all:
        selected_sources = list(LOADER_MAP.keys())
    else:
        selected_sources = [s.strip().upper() for s in args.src.split(",") if s.strip()]

    print("=" * 70)
    print("CAPSTONE DATA ENGINEERING: AUTOMATED INGESTION PIPELINE")
    print(f"Started at : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Selected   : {', '.join(selected_sources)}")
    print("=" * 70)

    if args.truncate:
        truncate_tables(selected_sources)

    results = {}
    start_all = datetime.now()

    for src in selected_sources:
        if src not in LOADER_MAP:
            print(f"[WARN] Unknown source {src}, skipping.")
            continue
        print(f"\n[{src}] Processing...")
        loader_fn = LOADER_MAP[src]
        src_start = datetime.now()
        try:
            count = loader_fn()
            duration = (datetime.now() - src_start).total_seconds()
            results[src] = {"status": "SUCCESS", "rows": count, "duration_sec": round(duration, 2)}
        except Exception as e:
            duration = (datetime.now() - src_start).total_seconds()
            results[src] = {"status": "FAILED", "error": str(e), "duration_sec": round(duration, 2)}
            print(f"    [ERROR] Failed to load {src}: {e}")

    total_duration = (datetime.now() - start_all).total_seconds()
    print("\n" + "=" * 70)
    print("INGESTION SUMMARY REPORT")
    print("=" * 70)
    for src, res in results.items():
        if res["status"] == "SUCCESS":
            print(f"  {src:<8} : SUCCESS | {res['rows']:>8,} rows loaded in {res['duration_sec']:>6.2f}s")
        else:
            print(f"  {src:<8} : FAILED  | Error: {res.get('error')} ({res['duration_sec']:.2f}s)")
    print("-" * 70)
    print(f"Total time elapsed: {total_duration:.2f} seconds\n")

if __name__ == "__main__":
    main()
