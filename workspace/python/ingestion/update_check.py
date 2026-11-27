#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
update_check.py - Deteksi apakah sumber SRC-* punya data terbaru, tanpa mengunduh isi.

Cara kerja: kirim permintaan kondisional (If-None-Match / If-Modified-Since) memakai
ETag dan Last-Modified yang tersimpan di ops.source_file_manifest.
  - HTTP 304 Not Modified -> tidak ada pembaruan, 0 byte terpakai
  - HTTP 200              -> ada versi baru; ETag/Last-Modified baru dilaporkan

Untuk sumber yang tidak mendukung header tersebut:
  - SRC-02/03 (Kaggle)  : API publik menyediakan `lastUpdated` + nomor versi
  - SRC-10/SRC-12 (BPS) : metadata `last_update` / `table_updated` di dalam JSON
  - SRC-11 (HDX)        : stempel waktu resource (tidak ada 304)

Tidak dapat diperiksa: SRC-05 (endpoint unduhan tanpa header/versi),
SRC-08 (query live Overpass), SRC-09 (portal HTML statis, unduhan manual).

Pemakaian:
  python update_check.py                 # periksa semua sumber yang didukung
  python update_check.py --only SRC-06,SRC-07
  python update_check.py --json          # keluaran mesin
  python update_check.py --save          # simpan etag/last_modified ke manifest lokal

Status keluar: 0 = semua terbaru, 1 = ada pembaruan, 2 = tidak ada sumber yang
berhasil diperiksa sama sekali.
"""
import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

HEADERS = {"User-Agent": "capstone-de-update-check/1.0"}

# URL yang dipakai untuk memeriksa versi terbaru per sumber.
# SRC-05 tidak disertakan: endpoint unduhannya tidak mengirim ETag/Last-Modified.
PROBES = {
    "SRC-01": "https://data.mendeley.com/public-api/datasets/zmzywny59b/files",
    "SRC-04": "https://data.mendeley.com/public-api/datasets/xxx26vkpsb/files",
    "SRC-06": ("https://ookla-open-data.s3.amazonaws.com/parquet/performance/"
               "type=fixed/year=2024/quarter=4/2024-10-01_performance_fixed_tiles.parquet"),
    "SRC-07": "https://wri-dataportal-prod.s3.amazonaws.com/manual/global_power_plant_database_v_1_3.zip",
    "SRC-11": "https://data.humdata.org/api/3/action/package_show?id=cod-ab-idn",
}

# SRC-02/03: Kaggle API publik (tanpa kredensial), dibandingkan lewat lastUpdated.
KAGGLE_SLUGS = {
    "SRC-02": "maudiana/indonesia-natural-disaster-dataset-bnpb-records",
    "SRC-03": "greegtitan/indonesia-climate",
}

# ingestion/ -> python/ -> workspace/ -> repo root
REPO_DIR = Path(__file__).resolve().parents[3]
WORKSPACE_DIR = REPO_DIR / "workspace"
DATA_ROOT = WORKSPACE_DIR / "data" / "Sumber Data"
MANIFEST_CSV = WORKSPACE_DIR / "evidence" / "csv" / "02_Sources_Manifest.csv"


def hdx_metadata(previous: str | None = None) -> dict:
    """SRC-11: HDX tidak mendukung permintaan kondisional; bandingkan last_modified resource.

    HDX kadang membalas 202 dengan body kosong (antrean/rate-limit), jadi respons
    non-JSON diperlakukan sebagai 'tidak dapat diperiksa', bukan kegagalan keras.
    """
    try:
        req = urllib.request.Request(PROBES["SRC-11"], headers=dict(HEADERS))
        with urllib.request.urlopen(req, timeout=30) as resp:
            if resp.status not in (200,):
                return {"status": resp.status, "changed": None, "etag": None,
                        "last_modified": None, "length": None,
                        "error": f"HTTP {resp.status} (HDX belum siap; coba lagi nanti)"}
            raw = resp.read()
        try:
            doc = json.loads(raw.decode("utf-8", "replace"))
        except json.JSONDecodeError:
            return {"status": resp.status, "changed": None, "etag": None,
                    "last_modified": None, "length": None,
                    "error": "respons HDX bukan JSON (kemungkinan rate-limit)"}

        stamps = []
        for res in (doc.get("result", {}).get("resources") or []):
            name = ((res.get("name") or "") + " " + (res.get("url") or "")).lower()
            if "admin1" in name or "admin2" in name:
                stamps.append(res.get("last_modified") or res.get("created"))
        stamps.append(doc.get("result", {}).get("metadata_modified"))
        newest = max((s for s in stamps if s), default=None)
        if newest is None:
            return {"status": resp.status, "changed": None, "etag": None,
                    "last_modified": None, "length": None,
                    "error": "HDX tidak menyediakan stempel waktu"}
        return {"status": resp.status,
                "changed": (newest != previous) if previous else None,
                "etag": None, "last_modified": newest, "length": None, "error": None}
    except Exception as e:  # noqa: BLE001
        return {"status": None, "changed": None, "etag": None, "last_modified": None,
                "length": None, "error": f"{type(e).__name__}: {e}"}


def head(url: str, etag: str | None = None, last_modified: str | None = None,
         timeout: int = 30) -> dict:
    """Permintaan kondisional. Mengembalikan status + header relevan."""
    req = urllib.request.Request(url, headers=dict(HEADERS))
    if etag:
        req.add_header("If-None-Match", etag)
    if last_modified:
        req.add_header("If-Modified-Since", last_modified)

    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return {
                "status": r.status,
                "changed": True,
                "etag": r.headers.get("ETag"),
                "last_modified": r.headers.get("Last-Modified"),
                "length": r.headers.get("Content-Length"),
                "error": None,
            }
    except urllib.error.HTTPError as e:
        if e.code == 304:
            return {"status": 304, "changed": False, "etag": etag,
                    "last_modified": last_modified, "length": None, "error": None}
        if e.code in (401, 403):
            return {"status": e.code, "changed": None, "etag": None, "last_modified": None,
                    "length": None, "error": f"HTTP {e.code}: butuh kredensial"}
        return {"status": e.code, "changed": None, "etag": None, "last_modified": None,
                "length": None, "error": f"HTTP {e.code}"}
    except Exception as e:  # noqa: BLE001
        return {"status": None, "changed": None, "etag": None, "last_modified": None,
                "length": None, "error": f"{type(e).__name__}: {e}"}


def kaggle_metadata(slug: str, previous: str | None = None) -> dict:
    """SRC-02/03: Kaggle tidak mendukung permintaan kondisional, tetapi API publiknya
    (tanpa autentikasi) menyediakan `lastUpdated` dan nomor versi dataset.
    """
    url = f"https://www.kaggle.com/api/v1/datasets/view/{slug}"
    try:
        req = urllib.request.Request(url, headers=dict(HEADERS))
        with urllib.request.urlopen(req, timeout=30) as resp:
            if resp.status != 200:
                return {"status": resp.status, "changed": None, "etag": None,
                        "last_modified": None, "length": None,
                        "error": f"HTTP {resp.status}"}
            doc = json.loads(resp.read().decode("utf-8", "replace"))
        stamp = doc.get("lastUpdated") or ""
        version = doc.get("currentVersionNumber")
        if not stamp:
            return {"status": 200, "changed": None, "etag": None, "last_modified": None,
                    "length": None, "error": "Kaggle tidak menyediakan lastUpdated"}
        return {
            "status": 200,
            "changed": (stamp != previous) if previous else None,
            "etag": None,
            "last_modified": stamp,
            "length": None,
            "error": None,
            "version": version,
            "url": url,
        }
    except Exception as e:  # noqa: BLE001
        return {"status": None, "changed": None, "etag": None, "last_modified": None,
                "length": None, "error": f"{type(e).__name__}: {e}"}


def bps_metadata(src_id: str) -> dict:
    """SRC-10/12: bandingkan metadata pembaruan dari arsip _raw dengan yang tercatat.

    Bila belum ada arsip, metadata diambil langsung dari API (butuh BPS_API_KEY).
    """
    import bps_api

    raw_dir = DATA_ROOT / src_id / "_raw"
    archived: dict[str, str] = {}
    if raw_dir.is_dir():
        for p in sorted(raw_dir.glob("*.json")):
            try:
                doc = json.loads(p.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError):
                continue
            stamps = [doc.get("last_update")]
            for item in (doc.get("data") or []):
                if isinstance(item, dict):
                    stamps.append(item.get("table_updated"))
            best = max((str(s) for s in stamps if s), default=None)
            if best:
                archived[p.stem] = best

    live: dict[str, str] = {}
    key = (os.getenv("BPS_API_KEY") or "").strip()
    if key:
        try:
            if src_id == "SRC-10":
                for year, payload in bps_api.fetch_iklh(key).items():
                    live[f"iklh_{year}"] = str(payload.get("last_update") or "")
            else:
                for year, payload in bps_api.fetch_penduduk(key).items():
                    table = bps_api._stat_table(payload)
                    live[f"penduduk_{year}"] = str(table.get("table_updated") or "")
        except Exception as e:  # noqa: BLE001
            return {"status": None, "changed": None, "etag": None, "last_modified": None,
                    "length": None, "error": f"{type(e).__name__}: {e}"}

    if not archived and not live:
        return {"status": None, "changed": None, "etag": None, "last_modified": None,
                "length": None, "error": "butuh BPS_API_KEY atau arsip _raw"}

    newer = [k for k, v in live.items() if v and archived.get(k) and v > archived[k]]
    newest_stamp = max([v for v in live.values() if v] or [v for v in archived.values() if v] or [""])
    return {"status": None, "changed": bool(newer) if live else None,
            "etag": None, "last_modified": newest_stamp, "length": None, "error": None}


def load_known() -> dict[str, dict]:
    """Baca etag/last_modified yang tercatat di manifest evidence (bila ada)."""
    known: dict[str, dict] = {}
    if not MANIFEST_CSV.is_file():
        return known
    import csv as _csv

    with open(MANIFEST_CSV, encoding="utf-8-sig", newline="") as fh:
        for row in _csv.DictReader(fh):
            sid = row.get("source_id")
            if not sid:
                continue
            known.setdefault(sid, {})
            if row.get("etag"):
                known[sid]["etag"] = row["etag"]
            if row.get("last_modified"):
                known[sid]["last_modified"] = row["last_modified"]
    return known


def main() -> int:
    ap = argparse.ArgumentParser(description="Periksa apakah sumber SRC-* punya versi terbaru.")
    ap.add_argument("--only", help="Daftar SRC dipisah koma, mis. SRC-06,SRC-07")
    ap.add_argument("--json", action="store_true", help="Keluarkan JSON")
    ap.add_argument("--save", action="store_true",
                    help="Simpan etag/last_modified ke 02_Sources_Manifest.csv (lokal)")
    a = ap.parse_args()

    only = {s.strip().upper() for s in a.only.split(",") if s.strip()} if a.only else None
    known = load_known()
    results = {}

    for sid, url in PROBES.items():
        if only and sid not in only:
            continue
        prev = known.get(sid, {})
        if sid == "SRC-11":
            r = hdx_metadata(prev.get("last_modified"))
        else:
            r = head(url, prev.get("etag"), prev.get("last_modified"))
        r["url"] = url
        r["compared"] = bool(prev.get("etag") or prev.get("last_modified"))
        results[sid] = r

    for sid, slug in KAGGLE_SLUGS.items():
        if only and sid not in only:
            continue
        prev = known.get(sid, {})
        r = kaggle_metadata(slug, prev.get("last_modified"))
        r["compared"] = bool(prev.get("last_modified"))
        results[sid] = r

    for sid in ("SRC-10", "SRC-12"):
        if only and sid not in only:
            continue
        r = bps_metadata(sid)
        r["compared"] = True
        results[sid] = r

    if a.json:
        print(json.dumps(results, indent=2, ensure_ascii=False))
    else:
        print(f"{'sumber':8} {'status':>8} {'ada update':>11}  keterangan")
        print("-" * 72)
        for sid in sorted(results):
            r = results[sid]
            if r.get("error"):
                note = r["error"]
            elif r["changed"] is True:
                note = "versi baru tersedia"
            elif r["changed"] is False:
                note = "tidak ada perubahan (304)" if r["status"] == 304 else "tidak ada perubahan"
            else:
                note = f"metadata terakhir: {r.get('last_modified')}"
            if r.get("version") is not None:
                note += f" (versi {r['version']})"
            flag = {True: "YA", False: "tidak", None: "-"}[r["changed"]]
            print(f"{sid:8} {str(r['status'] or '-'):>8} {flag:>11}  {note}")

    if a.save:
        _save(results, known)

    # Exit 0/1 selama minimal satu sumber berhasil dibandingkan. Exit 2 hanya bila
    # SEMUA sumber gagal diperiksa (mis. jaringan mati), supaya rate-limit sesaat
    # atau kredensial yang belum diisi tidak dianggap kegagalan pipeline.
    checked = [r for r in results.values() if r.get("changed") is not None]
    if not checked:
        return 2
    return 1 if any(r["changed"] is True for r in checked) else 0


def _save(results: dict, known: dict) -> None:
    """Perbarui etag/last_modified pada manifest CSV evidence."""
    import csv as _csv

    if not MANIFEST_CSV.is_file():
        print(f"[WARN] {MANIFEST_CSV} tidak ada; tidak menyimpan.")
        return
    rows = list(_csv.DictReader(open(MANIFEST_CSV, encoding="utf-8-sig", newline="")))
    if not rows:
        return
    fields = list(rows[0].keys())
    for col in ("etag", "last_modified", "checked_at"):
        if col not in fields:
            fields.append(col)

    from datetime import datetime, timezone

    now = datetime.now(timezone.utc).isoformat(timespec="seconds")
    changed = 0
    for row in rows:
        r = results.get(row.get("source_id"))
        if not r:
            continue
        if r.get("etag"):
            row["etag"] = r["etag"]
        if r.get("last_modified"):
            row["last_modified"] = r["last_modified"]
        row["checked_at"] = now
        changed += 1

    with open(MANIFEST_CSV, "w", encoding="utf-8-sig", newline="") as fh:
        w = _csv.DictWriter(fh, fieldnames=fields, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)
    print(f"\n[saved] {changed} baris diperbarui di {MANIFEST_CSV.name}")


if __name__ == "__main__":
    sys.exit(main())
