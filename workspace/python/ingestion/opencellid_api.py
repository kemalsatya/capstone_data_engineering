#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
opencellid_api.py - Unduh snapshot OpenCelliD untuk SRC-05 ke <root>/SRC-05/.

Berkas disimpan IMMUTABLE dengan timestamp, namanya cocok dengan pola FILES SRC-05
di profile_sources.py, sehingga profile_sources.py dan loaders.py tidak perlu diubah.

Token: variabel lingkungan OPENCELLID_TOKEN (jangan di-commit). Akun gratis punya kuota
unduhan, jadi script ini TIDAK mengunduh ulang bila berkas hari ini sudah ada.
"""
import argparse
import csv
import gzip
import hashlib
import os
import sys
from datetime import datetime
from pathlib import Path

# Template URL bisa ditimpa lewat .env bila format di halaman Downloads berbeda.
DEFAULT_URL = "https://opencellid.org/ocid/downloads"
DEFAULT_MCC_FILE = "{mcc}.csv.gz"        # unduhan per negara (verifikasi di halaman Downloads)
DEFAULT_FULL_FILE = "cell_towers.csv.gz"  # snapshot global
OCID_COLS = ["radio", "mcc", "net", "area", "cell", "unit", "lon", "lat", "range",
             "samples", "changeable", "created", "updated", "averageSignal"]


def token() -> str:
    tok = (os.getenv("OPENCELLID_TOKEN") or "").strip()
    if not tok:
        sys.exit("OPENCELLID_TOKEN belum diset (lihat .env.example).")
    return tok


def target_name(mode: str, mcc: str, stamp: str) -> str:
    # Cocok dengan pola 'cell.*towers.*\\.csv(\\.gz)?$' pada FILES SRC-05.
    scope = f"mcc{mcc}" if mode == "mcc" else "global"
    return f"cell_towers_{scope}_{stamp}.csv.gz"


def fetch(mode: str, mcc: str, dest: Path, timeout: int = 600) -> Path:
    import requests

    url = os.getenv("OPENCELLID_URL") or DEFAULT_URL
    file_param = DEFAULT_MCC_FILE.format(mcc=mcc) if mode == "mcc" else DEFAULT_FULL_FILE
    params = {"token": token(), "type": mode, "file": file_param}
    part = dest.with_suffix(dest.suffix + ".part")
    with requests.get(url, params=params, stream=True, timeout=timeout,
                      headers={"User-Agent": "capstone-de-opencellid/1.0"}) as r:
        if r.status_code in (401, 403):
            sys.exit(f"HTTP {r.status_code}: token ditolak atau kuota habis. Periksa OPENCELLID_TOKEN.")
        r.raise_for_status()
        with open(part, "wb") as fh:
            for chunk in r.iter_content(1 << 20):
                fh.write(chunk)
    # Kegagalan OpenCelliD sering berupa teks (HTTP 200), bukan gzip.
    with open(part, "rb") as fh:
        magic = fh.read(2)
        fh.seek(0)
        head = fh.read(200)
    if magic != b"\x1f\x8b":
        part.unlink(missing_ok=True)
        sys.exit(f"Respons bukan file gzip (token/kuota/URL?): {head.decode('utf-8', 'replace')!r}")
    part.replace(dest)
    return dest


def validate(path: Path, mcc: str) -> dict:
    """Cek gzip valid, jumlah baris, dan MCC pada sampel (kolom 2 bila tanpa header)."""
    rows, bad_mcc, header = 0, 0, False
    with gzip.open(path, "rt", encoding="utf-8-sig", newline="") as fh:
        for i, rec in enumerate(csv.reader(fh)):
            if i == 0 and rec and rec[0].strip().lower() == "radio":
                header = True
                continue
            rows += 1
            if rows <= 5000 and len(rec) > 1 and rec[1].strip() != mcc:
                bad_mcc += 1
    if rows == 0:
        sys.exit("Berkas kosong setelah diunduh.")
    return {"rows": rows, "header": header, "bad_mcc_in_sample": bad_mcc}


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    ap = argparse.ArgumentParser(description="Unduh OpenCelliD ke SRC-05.")
    ap.add_argument("--root", default="data_raw")
    ap.add_argument("--mode", choices=["mcc", "full"], default="mcc",
                    help="mcc = unduh per negara; full = global (lalu jalankan profile_sources.py prepare --preset opencellid)")
    ap.add_argument("--mcc", default="510")
    ap.add_argument("--force", action="store_true", help="unduh ulang walau berkas hari ini sudah ada")
    a = ap.parse_args()

    out_dir = Path(a.root) / "SRC-05"
    out_dir.mkdir(parents=True, exist_ok=True)
    dest = out_dir / target_name(a.mode, a.mcc, datetime.now().strftime("%Y%m%d"))
    if dest.exists() and not a.force:
        sys.exit(f"{dest.name} sudah ada; pakai --force bila memang ingin mengunduh ulang (hemat kuota).")

    path = fetch(a.mode, a.mcc, dest)
    info = validate(path, a.mcc)
    print(f"OK: {path} | {path.stat().st_size / 1e6:.1f} MB | baris={info['rows']:,} | "
          f"header={'ya' if info['header'] else 'tidak'} | sha256={sha256(path)[:12]}")
    if a.mode == "mcc" and info["bad_mcc_in_sample"]:
        print(f"PERINGATAN: {info['bad_mcc_in_sample']} baris sampel bukan MCC {a.mcc}; periksa URL/parameter.")
    if a.mode == "full":
        print("Mode global: saring dulu ke Indonesia dengan "
              f"`python profile_sources.py prepare --in {path} --out {out_dir}/cell_towers_mcc510.csv --preset opencellid`, "
              "lalu pindahkan berkas global dari folder SRC-05 agar tidak ikut termuat.")


if __name__ == "__main__":
    main()