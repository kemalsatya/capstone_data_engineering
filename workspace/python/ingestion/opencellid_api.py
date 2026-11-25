#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
opencellid_api.py - Unduh snapshot OpenCelliD untuk SRC-05.

Pencarian berkas memakai urutan fallback:
  1. <repo>/data_raw/SRC-05/                  (arsip immutable bertanggal)
  2. <workspace>/data/Sumber Data/SRC-05/     (berkas kanonik untuk pipeline)
Bila salah satu sudah ada, unduhan dilewati agar kuota token harian tidak terpakai.

Berkas disimpan dengan nama yang cocok dengan pola FILES SRC-05 di profile_sources.py,
sehingga profile_sources.py dan loaders.py tidak perlu diubah.

Token: variabel lingkungan OPENCELLID_TOKEN (jangan di-commit).
Modul ini melempar exception (bukan sys.exit) agar bisa dipanggil dari api_ingest.py;
CLI di bawah mengubahnya menjadi exit code.
"""
import argparse
import csv
import gzip
import hashlib
import os
import shutil
import sys
from datetime import datetime
from pathlib import Path

# Template URL bisa ditimpa lewat .env bila format di halaman Downloads berbeda.
DEFAULT_URL = "https://opencellid.org/ocid/downloads"
DEFAULT_MCC_FILE = "{mcc}.csv.gz"        # unduhan per negara (verifikasi di halaman Downloads)
DEFAULT_FULL_FILE = "cell_towers.csv.gz"  # snapshot global
OCID_COLS = ["radio", "mcc", "net", "area", "cell", "unit", "lon", "lat", "range",
             "samples", "changeable", "created", "updated", "averageSignal"]

WORKSPACE_DIR = Path(__file__).resolve().parents[2]
REPO_DIR = WORKSPACE_DIR.parent
ARCHIVE_ROOT = REPO_DIR / "data_raw"
CANONICAL_ROOT = WORKSPACE_DIR / "data" / "Sumber Data"
CANONICAL_NAME = "Cell Towers in Indonesia 510.csv"


def token() -> str:
    tok = (os.getenv("OPENCELLID_TOKEN") or "").strip()
    if not tok:
        raise RuntimeError("OPENCELLID_TOKEN belum diset (lihat .env.example).")
    return tok


def target_name(mode: str, mcc: str, stamp: str) -> str:
    # Cocok dengan pola 'cell.*towers.*\.csv(\.gz)?$' pada FILES SRC-05.
    scope = f"mcc{mcc}" if mode == "mcc" else "global"
    return f"cell_towers_{scope}_{stamp}.csv.gz"


def archive_dir() -> Path:
    return ARCHIVE_ROOT / "SRC-05"


def canonical_dir() -> Path:
    return CANONICAL_ROOT / "SRC-05"


def existing_snapshot() -> Path | None:
    """Cari berkas SRC-05 yang sudah ada. data_raw didahulukan, lalu Sumber Data.

    Menerima arsip .csv.gz maupun berkas kanonik .csv (termasuk nama lama
    'Cell Towers in Indonesia 510.csv'), selama ukurannya tidak nol.
    """
    for root in (archive_dir(), canonical_dir()):
        if not root.is_dir():
            continue
        hits = [p for p in sorted(root.glob("*.csv.gz")) if p.is_file() and p.stat().st_size > 0]
        if hits:
            return hits[-1]
        canonical = root / CANONICAL_NAME
        if canonical.is_file() and canonical.stat().st_size > 0:
            return canonical
        plain = [p for p in sorted(root.glob("*.csv")) if p.is_file() and p.stat().st_size > 0]
        if plain:
            return plain[-1]
    return None


def download(mode: str, mcc: str, dest: Path, timeout: int = 600) -> Path:
    """Unduh snapshot ke `dest` secara atomik. Melempar exception bila gagal."""
    import requests

    url = os.getenv("OPENCELLID_URL") or DEFAULT_URL
    file_param = DEFAULT_MCC_FILE.format(mcc=mcc) if mode == "mcc" else DEFAULT_FULL_FILE
    params = {"token": token(), "type": mode, "file": file_param}
    dest.parent.mkdir(parents=True, exist_ok=True)
    part = dest.with_suffix(dest.suffix + ".part")
    try:
        with requests.get(url, params=params, stream=True, timeout=timeout,
                          headers={"User-Agent": "capstone-de-opencellid/1.0"}) as r:
            if r.status_code in (401, 403):
                raise PermissionError(
                    f"HTTP {r.status_code}: token ditolak atau kuota habis. Periksa OPENCELLID_TOKEN."
                )
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
            raise RuntimeError(
                f"Respons bukan file gzip (token/kuota/URL?): {head.decode('utf-8', 'replace')!r}"
            )
        part.replace(dest)
    finally:
        if part.exists():
            part.unlink()
    return dest


def decompress_to(source: Path, dest: Path) -> Path:
    """Tulis CSV tak-terkompres ke `dest` secara atomik. Menerima .gz maupun .csv."""
    dest.parent.mkdir(parents=True, exist_ok=True)
    part = dest.with_suffix(dest.suffix + ".part")
    try:
        if source.suffix.lower() == ".gz":
            with gzip.open(source, "rb") as src, open(part, "wb") as out:
                shutil.copyfileobj(src, out)
        elif source.resolve() != dest.resolve():
            shutil.copyfile(source, part)
        else:
            return dest
        part.replace(dest)
    finally:
        if part.exists():
            part.unlink()
    return dest


def ensure_archive(mcc: str = "510", force: bool = False) -> Path:
    """Kembalikan path berkas SRC-05, mengunduh hanya bila belum ada di mana pun."""
    if not force:
        found = existing_snapshot()
        if found is not None:
            return found
    dest = archive_dir() / target_name("mcc", mcc, datetime.now().strftime("%Y%m%d"))
    return download("mcc", mcc, dest)


def validate(path: Path, mcc: str) -> dict:
    """Cek gzip valid, jumlah baris, dan MCC pada sampel (kolom 2 bila tanpa header)."""
    rows, bad_mcc, header = 0, 0, False
    opener = gzip.open if path.suffix.lower() == ".gz" else open
    with opener(path, "rt", encoding="utf-8-sig", newline="") as fh:
        for i, rec in enumerate(csv.reader(fh)):
            if i == 0 and rec and rec[0].strip().lower() == "radio":
                header = True
                continue
            rows += 1
            if rows <= 5000 and len(rec) > 1 and rec[1].strip() != mcc:
                bad_mcc += 1
    if rows == 0:
        raise RuntimeError("Berkas kosong setelah diunduh.")
    return {"rows": rows, "header": header, "bad_mcc_in_sample": bad_mcc}


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    ap = argparse.ArgumentParser(description="Unduh OpenCelliD ke SRC-05.")
    ap.add_argument("--root", default=None,
                    help="folder tujuan (default: <repo>/data_raw). Bila berkas sudah ada "
                         "di data_raw atau Sumber Data, unduhan dilewati.")
    ap.add_argument("--mode", choices=["mcc", "full"], default="mcc",
                    help="mcc = unduh per negara; full = global (lalu jalankan profile_sources.py prepare --preset opencellid)")
    ap.add_argument("--mcc", default="510")
    ap.add_argument("--force", action="store_true", help="unduh ulang walau berkas sudah ada")
    a = ap.parse_args()

    if not a.force:
        found = existing_snapshot()
        if found is not None:
            info = validate(found, a.mcc)
            print(f"SKIP: sudah ada {found} | baris={info['rows']:,} | sha256={sha256(found)[:12]}")
            return

    out_dir = (Path(a.root) / "SRC-05") if a.root else archive_dir()
    out_dir.mkdir(parents=True, exist_ok=True)
    dest = out_dir / target_name(a.mode, a.mcc, datetime.now().strftime("%Y%m%d"))

    path = download(a.mode, a.mcc, dest)
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
    try:
        main()
    except (RuntimeError, PermissionError) as exc:
        sys.exit(str(exc))