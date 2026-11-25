#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# version: 0.3

# -----------------------------------------------------------
# lokasi file: workspace/python/ingestion/api_ingest.py
# API Credentials (.env tambahan) untuk ingestion/api_ingest.py
# Berkas .env dibaca dari root repo (satu tingkat di atas workspace/).
#
# Wajib untuk sumber ber-kredensial (diisi manual; tidak dibuat oleh `init`):
#   KAGGLE_API_TOKEN=isi_token_kaggle         # SRC-02, SRC-03 (token KGAT_..., tanpa username)
#   KAGGLE_USERNAME=isi_username_kaggle       # alias legacy: pakai bersama KAGGLE_KEY
#   KAGGLE_KEY=isi_api_key_kaggle             # alias legacy: API key 32-hex, bukan KGAT_
#   OPENCELLID_TOKEN=isi_token_opencellid      # SRC-05
# Opsional:
#   OVERPASS_URL=https://overpass-api.de/api/interpreter   # SRC-08, ganti bila rate-limit
#   BPS_API_KEY=isi_token_webapi_bps                       # SRC-10, SRC-12 (dipakai dengan --from-api)
#
# SRC-10 & SRC-12 dapat diunduh via WebAPI BPS (bps_api.py) dengan --from-api.
# SRC-09 tidak dapat diunduh via API; unduh manual dari portal Komdigi
# lalu jalankan `python api_ingest.py --verify` untuk memeriksanya.
# -----------------------------------------------------------

"""
api_ingest.py - Mengunduh dan menyiapkan dataset SRC-01..SRC-12 ke workspace/data/Sumber Data/SRC-*
agar 100% kompatibel dengan profile_sources.py dan loaders.py (raw.src_*).

Contoh penggunaan:
  python api_ingest.py                      # jalankan semua sumber (skip jika file sudah ada)
  python api_ingest.py --only SRC-06,SRC-08 # jalankan sumber tertentu saja
  python api_ingest.py --only SRC-08 --force
  python api_ingest.py --verify             # hanya cek ketersediaan berkas (exit 1 bila ada yang hilang)
  python api_ingest.py --only SRC-12 --from-api   # SRC-10/12 via WebAPI BPS (butuh BPS_API_KEY)

Exit code 0 = semua sumber siap; 1 = ada kegagalan unduhan atau berkas yang belum tersedia.
"""
import argparse
import gzip
import io
import os
import shutil
import sys
import time
import zipfile
from contextlib import contextmanager
from pathlib import Path

import pandas as pd
import requests
from dotenv import load_dotenv

# Arahkan ke workspace/ (2 tingkat di atas workspace/python/ingestion/)
WORKSPACE_DIR = Path(__file__).resolve().parents[2]
DATA_ROOT = WORKSPACE_DIR / "data" / "Sumber Data"
PROFILING_DIR = WORKSPACE_DIR / "python" / "profiling"

if str(PROFILING_DIR) not in sys.path:
    sys.path.insert(0, str(PROFILING_DIR))

import profile_sources as ps  # noqa: E402
import bps_api  # noqa: E402

load_dotenv(WORKSPACE_DIR.parent / ".env")
load_dotenv(WORKSPACE_DIR / ".env")

HEADERS = {"User-Agent": "CapstoneDataEngineering-Ingest/1.0"}
LAT_MIN, LON_MIN, LAT_MAX, LON_MAX = ps.IDN_BBOX  # (-11.5, 94.0, 6.5, 141.5)

# Urutan 75 kolom standar ekspor Overpass Turbo untuk SRC-08 (sesuai 03-raw.sql)
OSM_BASE_COLS = [
    "id", "@id", "M:hazard_prone", "access:roof", "addr:city", "addr:country", "addr:full",
    "addr:housenumber", "addr:postcode", "addr:street", "addr:subdistrict", "alt_name", "amenity",
    "backup_generator", "barrier", "building", "building:condition", "building:levels",
    "building:material", "building:roof", "building:structure", "building:use", "building:walls",
    "cables", "capacity", "check_date", "description", "design", "designation", "fixme",
    "frequency", "gas_insulated", "generator:source", "height", "landuse", "layer", "leisure",
    "location", "man_made", "name", "name:en", "name:id", "name:ms", "not:operator:wikidata",
    "note", "office", "official_name", "opening_date", "opening_hours", "operator",
    "operator:short", "operator:wikidata", "operator:wikipedia", "phone", "power", "power_supply",
    "public_service_provider:type_idn", "rating", "ref", "roof:levels", "roof:material",
    "roof:orientation", "roof:shape", "shelter_type", "short_name", "source", "start_date",
    "substation", "type", "utility", "voltage", "@geometry", "longitude", "latitude", "geometry_wkt",
]


def ensure_dir(src_id: str) -> Path:
    target = DATA_ROOT / src_id
    target.mkdir(parents=True, exist_ok=True)
    return target


def is_ready(path: Path, force: bool) -> bool:
    return path.exists() and path.stat().st_size > 0 and not force


@contextmanager
def atomic_write(path: Path, mode: str = "wb", **open_kwargs):
    """Tulis ke berkas .part lalu rename, agar unduhan terputus tidak pernah terlihat 'siap'."""
    tmp = path.with_suffix(path.suffix + ".part")
    try:
        with open(tmp, mode, **open_kwargs) as fh:
            yield fh
        tmp.replace(path)
    except Exception:
        if tmp.exists():
            tmp.unlink()
        raise


def fetch(url: str, *, method: str = "get", attempts: int = 3, timeout: int = 180, **kw):
    """HTTP request dengan retry eksponensial dan pesan error yang jelas untuk 401/403."""
    for attempt in range(1, attempts + 1):
        try:
            resp = requests.request(method, url, headers=HEADERS, timeout=timeout, **kw)
            if resp.status_code in (401, 403):
                raise PermissionError(
                    f"HTTP {resp.status_code} untuk {url} - periksa token/kredensial "
                    "(KAGGLE_USERNAME/KAGGLE_KEY, OPENCELLID_TOKEN)"
                )
            resp.raise_for_status()
            return resp
        except (requests.RequestException, PermissionError) as exc:
            if attempt == attempts or isinstance(exc, PermissionError):
                raise
            print(f"[WARN] percobaan {attempt} gagal: {exc}")
            time.sleep(5 * attempt)


# ---------------------------------------------------------------------------
# SRC-01 & SRC-04: Mendeley Data Public API
# ---------------------------------------------------------------------------
def ingest_mendeley(dataset_id: str, src_id: str, target_filename: str, force: bool = False):
    target_dir = ensure_dir(src_id)
    out_path = target_dir / target_filename
    if is_ready(out_path, force):
        print(f"[SKIP] {src_id}: {target_filename} sudah ada.")
        return

    meta_url = f"https://data.mendeley.com/public-api/datasets/{dataset_id}/files"
    resp = fetch(meta_url, timeout=30)
    files = resp.json()

    # Cari file utama (.csv) dan file kamus data opsional (jika ada)
    csv_candidates = [f for f in files if f.get("filename", "").lower().endswith(".csv")]
    main_file = next(
        (f for f in csv_candidates if "dictionary" not in f["filename"].lower()),
        csv_candidates[0] if csv_candidates else files[0],
    )

    dl_url = (
        main_file.get("content_details", {}).get("download_url")
        or f"https://data.mendeley.com/public-api/files/{main_file['id']}/downloaded"
    )
    with fetch(dl_url, stream=True, timeout=120) as r, atomic_write(out_path) as f:
        shutil.copyfileobj(r.raw, f)
    print(f"[OK]   {src_id}: {out_path.name} ({out_path.stat().st_size / 1e6:.2f} MB)")

    # Unduh data_dictionary jika tersedia di dataset Mendeley (berguna untuk profile_sources.py)
    for extra in csv_candidates:
        if "dictionary" in extra["filename"].lower():
            dict_path = target_dir / extra["filename"]
            if not is_ready(dict_path, force):
                d_url = (
                    extra.get("content_details", {}).get("download_url")
                    or f"https://data.mendeley.com/public-api/files/{extra['id']}/downloaded"
                )
                r = fetch(d_url, timeout=60)
                with atomic_write(dict_path) as fh:
                    fh.write(r.content)
                print(f"[OK]   {src_id}: kamus pendamping {dict_path.name} diunduh.")


# ---------------------------------------------------------------------------
# SRC-02 & SRC-03: Kaggle API
# ---------------------------------------------------------------------------
def ingest_kaggle(dataset_slug: str, src_id: str, expected_files: list[str], force: bool = False):
    target_dir = ensure_dir(src_id)
    if all(is_ready(target_dir / f, force) for f in expected_files):
        print(f"[SKIP] {src_id}: semua file target sudah ada.")
        return

    # Token akses modern (KGAT_...) cukup sendiri: username diambil dari server Kaggle
    # lewat introspect. Pasangan username+key hanya untuk API key legacy 32-hex.
    has_token = bool(os.getenv("KAGGLE_API_TOKEN"))
    has_legacy = bool(os.getenv("KAGGLE_USERNAME") and os.getenv("KAGGLE_KEY"))
    has_json = (Path.home() / ".kaggle" / "kaggle.json").exists()
    if not (has_token or has_legacy or has_json):
        print(
            f"[WARN] {src_id}: KAGGLE_API_TOKEN (atau KAGGLE_USERNAME+KAGGLE_KEY) "
            f"belum diset di .env; lewati {dataset_slug}."
        )
        return

    from kaggle.api.kaggle_api_extended import KaggleApi

    api = KaggleApi()
    api.authenticate()
    api.dataset_download_files(dataset_slug, path=str(target_dir), unzip=True, force=True)

    # Normalisasi nama file XLSX jika nama arsip Kaggle berbeda dengan target SRC-02
    if len(expected_files) == 1 and not (target_dir / expected_files[0]).exists():
        ext = Path(expected_files[0]).suffix.lower()
        found = sorted(target_dir.glob(f"*{ext}"))
        if found:
            found[0].rename(target_dir / expected_files[0])

    print(f"[OK]   {src_id}: selesai diunduh dari Kaggle ({dataset_slug}).")


# ---------------------------------------------------------------------------
# SRC-05: OpenCelliD MCC 510 (Indonesia)
# ---------------------------------------------------------------------------
def ingest_src05_opencellid(force: bool = False):
    out_path = ensure_dir("SRC-05") / "Cell Towers in Indonesia 510.csv"
    if is_ready(out_path, force):
        print("[SKIP] SRC-05: Cell Towers in Indonesia 510.csv sudah ada (hemat kuota token harian).")
        return

    token = os.getenv("OPENCELLID_TOKEN")
    if not token:
        print("[WARN] SRC-05: OPENCELLID_TOKEN belum diset di .env.")
        return

    url = f"https://opencellid.org/ocid/downloads?token={token}&type=mcc&file=510.csv.gz"
    with fetch(url, stream=True, timeout=180) as resp, atomic_write(out_path) as f_out:
        with gzip.GzipFile(fileobj=resp.raw) as gz_in:
            shutil.copyfileobj(gz_in, f_out)

    print(f"[OK]   SRC-05: {out_path.name} ({out_path.stat().st_size / 1e6:.2f} MB)")


# ---------------------------------------------------------------------------
# SRC-06: Ookla Open Data (S3 Parquet -> filter bbox Indonesia -> CSV 16 kolom)
# ---------------------------------------------------------------------------
def ingest_src06_ookla(force: bool = False):
    out_path = ensure_dir("SRC-06") / "ookla_fixed_2024q4_indonesia.csv"
    if is_ready(out_path, force):
        print("[SKIP] SRC-06: ookla_fixed_2024q4_indonesia.csv sudah ada.")
        return

    s3_url = (
        "https://ookla-open-data.s3.amazonaws.com/parquet/performance/"
        "type=fixed/year=2024/quarter=4/2024-10-01_performance_fixed_tiles.parquet"
    )
    print("[INFO] SRC-06: menyaring Parquet Ookla S3 untuk bounding box Indonesia...")

    try:
        import duckdb

        con = duckdb.connect()
        con.execute("INSTALL httpfs; LOAD httpfs;")
        tmp_csv = out_path.with_suffix(out_path.suffix + ".part")
        query = f"""
            COPY (
                SELECT
                    CAST(quadkey AS VARCHAR) AS quadkey,
                    tile,
                    tile_x,
                    tile_y,
                    avg_d_kbps,
                    avg_u_kbps,
                    avg_lat_ms,
                    avg_lat_down_ms,
                    avg_lat_up_ms,
                    tests,
                    devices,
                    4 AS quarter,
                    'fixed' AS type,
                    2024 AS year,
                    CAST(regexp_extract(tile, '\\(\\(\\s*(-?\\d+\\.?\\d*)\\s+(-?\\d+\\.?\\d*)', 1) AS DOUBLE) AS lon,
                    CAST(regexp_extract(tile, '\\(\\(\\s*(-?\\d+\\.?\\d*)\\s+(-?\\d+\\.?\\d*)', 2) AS DOUBLE) AS lat
                FROM read_parquet('{s3_url}')
                WHERE tile_y BETWEEN {LAT_MIN} AND {LAT_MAX}
                  AND tile_x BETWEEN {LON_MIN} AND {LON_MAX}
            ) TO '{tmp_csv.as_posix()}' (HEADER, DELIMITER ',');
        """
        try:
            con.execute(query)
            tmp_csv.replace(out_path)
        finally:
            if tmp_csv.exists():
                tmp_csv.unlink()
    except ImportError:
        # Fallback PyArrow streaming jika duckdb tidak terpasang di lingkungan Python
        import pyarrow.parquet as pq

        tmp_pq = out_path.with_suffix(".tmp.parquet")
        with fetch(s3_url, stream=True, timeout=300) as r, atomic_write(tmp_pq) as f:
            shutil.copyfileobj(r.raw, f)

        try:
            pf = pq.ParquetFile(tmp_pq)
            parts = []
            for batch in pf.iter_batches(batch_size=100_000):
                df = batch.to_pandas()
                mask = df["tile_y"].between(LAT_MIN, LAT_MAX) & df["tile_x"].between(LON_MIN, LON_MAX)
                sub = df.loc[mask].copy()
                if sub.empty:
                    continue
                xy = sub["tile"].astype(str).str.extract(r"\(\(\s*(-?\d+\.?\d*)\s+(-?\d+\.?\d*)")
                sub["quarter"] = 4
                sub["type"] = "fixed"
                sub["year"] = 2024
                sub["lon"] = pd.to_numeric(xy[0], errors="coerce")
                sub["lat"] = pd.to_numeric(xy[1], errors="coerce")
                parts.append(sub)

            out = pd.concat(parts, ignore_index=True) if parts else pd.DataFrame()
            with atomic_write(out_path, mode="w") as fh:
                out.to_csv(fh, index=False)
        finally:
            if tmp_pq.exists():
                tmp_pq.unlink()

    print(f"[OK]   SRC-06: {out_path.name} ({out_path.stat().st_size / 1e6:.2f} MB)")


# ---------------------------------------------------------------------------
# SRC-07: Global Power Plant Database v1.3.0 (WRI)
# ---------------------------------------------------------------------------
def ingest_src07_gppd(force: bool = False):
    out_path = ensure_dir("SRC-07") / "global_power_plant_database.csv"
    if is_ready(out_path, force):
        print("[SKIP] SRC-07: global_power_plant_database.csv sudah ada.")
        return

    zip_url = "https://wri-dataportal-prod.s3.amazonaws.com/manual/global_power_plant_database_v_1_3.zip"
    resp = fetch(zip_url, timeout=180)

    with zipfile.ZipFile(io.BytesIO(resp.content)) as zf:
        csv_name = next(
            (n for n in zf.namelist() if n.endswith("global_power_plant_database.csv")),
            None,
        )
        if csv_name is None:
            raise FileNotFoundError(
                f"global_power_plant_database.csv tidak ada di arsip; isi: {zf.namelist()}"
            )
        with zf.open(csv_name) as src, atomic_write(out_path) as dst:
            shutil.copyfileobj(src, dst)

    print(f"[OK]   SRC-07: {out_path.name} ({out_path.stat().st_size / 1e6:.2f} MB)")


# ---------------------------------------------------------------------------
# SRC-08: Overpass API (Gardu Induk / power=substation)
# ---------------------------------------------------------------------------
def ingest_src08_overpass(force: bool = False):
    out_path = ensure_dir("SRC-08") / "Gardu Induk dan Elektrik.csv"
    if is_ready(out_path, force):
        print("[SKIP] SRC-08: Gardu Induk dan Elektrik.csv sudah ada.")
        return

    query = ps.OVERPASS_QUERIES["substation"]
    endpoint = os.getenv("OVERPASS_URL", "https://overpass-api.de/api/interpreter")
    print("[INFO] SRC-08: mengambil data gardu induk (power=substation) dari Overpass API...")

    resp = fetch(endpoint, method="post", data={"data": query}, timeout=360)

    elements = resp.json().get("elements", [])
    rows = []

    for el in elements:
        tags = el.get("tags", {})
        center = el.get("center", {})
        lon = el.get("lon") if el.get("lon") is not None else center.get("lon")
        lat = el.get("lat") if el.get("lat") is not None else center.get("lat")
        osm_id = f"{el.get('type')}/{el.get('id')}"

        row = {col: tags.get(col, "") for col in OSM_BASE_COLS}
        row["id"] = osm_id
        row["@id"] = osm_id
        row["@geometry"] = "center"
        row["longitude"] = lon if lon is not None else ""
        row["latitude"] = lat if lat is not None else ""
        row["geometry_wkt"] = f"POINT ({round(float(lon), 6)} {round(float(lat), 6)})" if (lon is not None and lat is not None) else ""
        rows.append(row)

    # Kolom dipatok ke OSM_BASE_COLS agar skema CSV identik dengan raw.src_08_osm_gardu (03-raw.sql);
    # tag baru dari Overpass sengaja diabaikan supaya jumlah kolom tidak berubah antar-jalan.
    df = pd.DataFrame(rows, columns=OSM_BASE_COLS)
    with atomic_write(out_path, mode="w", encoding="utf-8-sig", newline="") as fh:
        df.to_csv(fh, index=False)
    print(f"[OK]   SRC-08: {len(df):,} gardu tersimpan ke {out_path.name}")


# ---------------------------------------------------------------------------
# SRC-11: COD-AB Indonesia via HDX CKAN API
# ---------------------------------------------------------------------------
def ingest_src11_hdx(force: bool = False):
    target_dir = ensure_dir("SRC-11")
    f_adm1 = target_dir / "idn_admin1.geojson"
    f_adm2 = target_dir / "idn_admin2.geojson"
    if is_ready(f_adm1, force) and is_ready(f_adm2, force):
        print("[SKIP] SRC-11: idn_admin1.geojson & idn_admin2.geojson sudah ada.")
        return

    meta_url = "https://data.humdata.org/api/3/action/package_show?id=cod-ab-idn"
    resp = fetch(meta_url, timeout=30)
    resources = resp.json()["result"]["resources"]

    for level, out_file in (("admin1", f_adm1), ("admin2", f_adm2)):
        if is_ready(out_file, force):
            continue
        # Prioritaskan GeoJSON langsung atau arsip ZIP GeoJSON
        cand = next(
            (r for r in resources if level in (r.get("name", "") + r.get("url", "")).lower() and "geojson" in (r.get("format", "") + r.get("name", "") + r.get("url", "")).lower()),
            None,
        )
        if not cand:
            print(f"[WARN] SRC-11: resource GeoJSON {level} tidak ditemukan otomatis di HDX.")
            continue

        dl_url = cand["url"]
        r = fetch(dl_url, timeout=180)

        if dl_url.lower().endswith(".zip") or zipfile.is_zipfile(io.BytesIO(r.content)):
            with zipfile.ZipFile(io.BytesIO(r.content)) as zf:
                gj_member = next(
                    (n for n in zf.namelist() if n.lower().endswith(".geojson")),
                    None,
                )
                if gj_member is None:
                    raise FileNotFoundError(
                        f"Tidak ada .geojson di arsip {dl_url}; isi: {zf.namelist()}"
                    )
                with zf.open(gj_member) as src, atomic_write(out_file) as dst:
                    shutil.copyfileobj(src, dst)
        else:
            with atomic_write(out_file) as dst:
                dst.write(r.content)
        print(f"[OK]   SRC-11: {out_file.name} ({out_file.stat().st_size / 1e6:.2f} MB)")


# ---------------------------------------------------------------------------
# SRC-10 & SRC-12: WebAPI BPS (opsional; butuh BPS_API_KEY)
# ---------------------------------------------------------------------------
def ingest_bps_api(src_ids: set[str], force: bool = False) -> None:
    """Unduh SRC-10/SRC-12 lewat WebAPI BPS dan tulis CSV identik dengan ekspor portal.

    CSV tetap menjadi format kanonik: profile_sources.read_bps() dan loaders.py tidak berubah,
    dan sha256 berkas hasil API sama dengan unduhan portal (sudah diverifikasi).
    """
    key = (os.getenv("BPS_API_KEY") or "").strip()
    if not key:
        print("[WARN] BPS_API_KEY belum diset di .env; lewati unduhan API SRC-10/SRC-12.")
        return

    if "SRC-10" in src_ids:
        targets = bps_api.fetch_iklh(key)
        for year, payload in targets.items():
            bps_api.archive_payload(payload, DATA_ROOT / "SRC-10" / "_raw", year, "iklh")
            out_path = ensure_dir("SRC-10") / bps_api.iklh_filename(year)
            if is_ready(out_path, force):
                print(f"[SKIP] SRC-10: {out_path.name} sudah ada.")
                continue
            n = bps_api.write_iklh_csv(payload, out_path)
            print(f"[OK]   SRC-10: {out_path.name} ({n} baris, via WebAPI)")

    if "SRC-12" in src_ids:
        targets = bps_api.fetch_penduduk(key)
        for year, payload in targets.items():
            bps_api.archive_payload(payload, DATA_ROOT / "SRC-12" / "_raw", year, "penduduk")
            out_path = ensure_dir("SRC-12") / bps_api.penduduk_filename(year)
            if is_ready(out_path, force):
                print(f"[SKIP] SRC-12: {out_path.name} sudah ada.")
                continue
            n = bps_api.write_penduduk_csv(payload, out_path)
            print(f"[OK]   SRC-12: {out_path.name} ({n} baris, via WebAPI)")


# ---------------------------------------------------------------------------
# SRC-09, SRC-10, SRC-12: Verifikasi Ekspor Portal Web (Komdigi & BPS)
# ---------------------------------------------------------------------------
def verify_portal_sources(only: set[str] | None = None) -> list[str]:
    """
    Memastikan file hasil unduhan portal web (Komdigi & BPS) tersedia.
    Menjaga agar header bertingkat dan catatan kaki tetap sesuai parser read_bps() di profile_sources.py.
    Mengembalikan daftar berkas yang belum ada.
    """
    checks = {
        "SRC-09": {
            "url": "https://datahub.komdigi.go.id/public/detail-data/173",
            "glob": "sebaran-point-of-presence*.csv",
            "expected": ["sebaran-point-of-presence-pop-layanan-jasa-internet-service-provider-isp_2026-11-13.csv"],
        },
        "SRC-10": {
            "url": "https://www.bps.go.id/id/statistics-table/2/MjUzMiMy/",
            "glob": None,
            "expected": [
                f"Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, {y}.csv"
                for y in range(2021, 2025)
            ],
        },
        "SRC-12": {
            "url": "https://www.bps.go.id/id/statistics-table/3/V1ZSbFRUY3lTbFpEYTNsVWNGcDZjek53YkhsNFFUMDkjMw==/",
            "glob": None,
            "expected": [
                f"Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, {y}.csv"
                for y in range(2022, 2027)
            ],
        },
    }

    missing_all = []
    for src_id, info in checks.items():
        if only and src_id not in only:
            continue
        target_dir = ensure_dir(src_id)
        if info["glob"] and list(target_dir.glob(info["glob"])):
            print(f"[OK]   {src_id}: file CSV Komdigi terverifikasi.")
            continue

        missing = [f for f in info["expected"] if not (target_dir / f).exists()]
        if not missing:
            print(f"[OK]   {src_id}: seluruh {len(info['expected'])} file terverifikasi.")
        else:
            print(f"[MISSING] {src_id}: {len(missing)} file belum ada (unduh CSV dari {info['url']}):")
            for m in missing:
                print(f"          - {m}")
            missing_all.extend(f"{src_id}: {m}" for m in missing)
    return missing_all


def main():
    ap = argparse.ArgumentParser(description="Ingest dataset SRC-01..SRC-12 ke folder Sumber Data.")
    ap.add_argument("--only", help="Daftar SRC dipisah koma, mis. SRC-01,SRC-06,SRC-08")
    ap.add_argument("--force", action="store_true", help="Unduh ulang walau file target sudah ada")
    ap.add_argument("--verify", action="store_true",
                    help="Hanya periksa ketersediaan berkas (termasuk SRC-09/10/12); keluar non-zero bila ada yang hilang")
    ap.add_argument("--from-api", action="store_true",
                    help="SRC-10 & SRC-12 diunduh dari WebAPI BPS bila BPS_API_KEY tersedia "
                         "(default: pakai CSV portal yang sudah ada)")
    args = ap.parse_args()

    only = {s.strip().upper() for s in args.only.split(",") if s.strip()} if args.only else None

    if args.verify:
        missing = verify_portal_sources(only)
        if missing:
            print(f"\n{len(missing)} berkas belum tersedia.")
            sys.exit(1)
        print("Semua berkas tersedia.")
        return

    tasks = {
        "SRC-01": lambda: ingest_mendeley("zmzywny59b", "SRC-01", "BMKG_Earthquake_Catalog.csv", args.force),
        "SRC-02": lambda: ingest_kaggle("maudiana/indonesia-natural-disaster-dataset-bnpb-records", "SRC-02", ["data_bencana.xlsx"], args.force),
        "SRC-03": lambda: ingest_kaggle("greegtitan/indonesia-climate", "SRC-03", ["climate_data.csv", "province_detail.csv", "station_detail.csv"], args.force),
        "SRC-04": lambda: ingest_mendeley("xxx26vkpsb", "SRC-04", "master_features_v4.csv", args.force),
        "SRC-05": lambda: ingest_src05_opencellid(args.force),
        "SRC-06": lambda: ingest_src06_ookla(args.force),
        "SRC-07": lambda: ingest_src07_gppd(args.force),
        "SRC-08": lambda: ingest_src08_overpass(args.force),
        "SRC-11": lambda: ingest_src11_hdx(args.force),
    }

    failures = []
    for src_id, fn in tasks.items():
        if only and src_id not in only:
            continue
        try:
            fn()
        except Exception as exc:
            print(f"[ERROR] {src_id}: {type(exc).__name__}: {exc}")
            failures.append(f"{src_id}: {type(exc).__name__}: {exc}")

    if args.from_api:
        bps_targets = {s for s in ("SRC-10", "SRC-12") if not only or s in only}
        if bps_targets:
            try:
                ingest_bps_api(bps_targets, args.force)
            except Exception as exc:
                print(f"[ERROR] BPS API: {type(exc).__name__}: {exc}")
                failures.append(f"BPS API: {type(exc).__name__}: {exc}")

    missing = verify_portal_sources(only)
    failures.extend(missing)

    if failures:
        print(f"\n=== GAGAL ({len(failures)}) ===")
        for item in failures:
            print(f"  - {item}")
        sys.exit(1)


if __name__ == "__main__":
    main()