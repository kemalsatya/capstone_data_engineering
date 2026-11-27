#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
bps_api.py - Klien + transform WebAPI BPS untuk SRC-10 (IKLH) dan SRC-12 (Penduduk).

Tujuan: menghasilkan CSV dengan SKEMA IDENTIK seperti berkas unduhan portal, agar
profile_sources.py (read_bps) dan loaders.py (raw.src_*) tidak perlu diubah.

Dua keluarga endpoint BPS menghasilkan bentuk JSON berbeda:
  1. `model/data`  -> datacontent berupa dict dengan kunci gabungan
                      vervar + var + turvar + tahun + turtahun.
                      Dipakai SRC-10.
  2. tabel statistik -> {"data":[paginasi, {kolom:..., data:[...]}]}.
                      Dipakai SRC-12. Angka berformat Indonesia ("5.695,9").
"""
import csv
import io
import json
import os
import sys
from pathlib import Path

# --------------------------------------------------------------------------- endpoint
# URL diambil dari tombol JSON pada halaman tabel statistik BPS, dengan token
# diganti placeholder {key}. Bisa ditimpa lewat variabel lingkungan.
#
# SRC-10: var statis (model/data), satu panggilan per tahun lewat parameter th.
# Kode `th` = tahun - 1900 (2024 -> 124, 2021 -> 121), dan sama dengan `tahun.val` di respons.
DEFAULT_IKLH_URL = (
    "https://webapi.bps.go.id/v1/api/list/model/data/lang/ind/domain/0000/"
    "var/2532/th/{th}/key/{key}/"
)
# SRC-12: SIMDASI interoperability. Endpoint ini WAJIB menyertakan `id_tabel` dan `wilayah`.
# id_tabel = string base64 dari tabel statistik (bukan mms_id), wilayah = 0000000 (nasional).
DEFAULT_PENDUDUK_ID_TABEL = "WVRlTTcySlZDa3lUcFp6czNwbHl4QT09"
DEFAULT_PENDUDUK_WILAYAH = "0000000"
DEFAULT_PENDUDUK_URL = (
    "https://webapi.bps.go.id/v1/api/interoperabilitas/datasource/simdasi/"
    "id/25/tahun/{tahun}/id_tabel/{id_tabel}/wilayah/{wilayah}/key/{key}/"
)
PENDUDUK_YEARS = (2022, 2023, 2024, 2025, 2026)
IKLH_YEARS = (2021, 2022, 2023, 2024)

IKLH_PROVINCE_LABEL = "38 Provinsi"


def penduduk_params() -> tuple[str, str]:
    """(id_tabel, wilayah) untuk SIMDASI; bisa ditimpa lewat .env."""
    id_tabel = (os.getenv("BPS_PENDUDUK_ID_TABEL") or "").strip() or DEFAULT_PENDUDUK_ID_TABEL
    wilayah = (os.getenv("BPS_PENDUDUK_WILAYAH") or "").strip() or DEFAULT_PENDUDUK_WILAYAH
    return id_tabel, wilayah


def th_code(year: int) -> int:
    """Kode tahun pada parameter `th` BPS: tahun - 1900."""
    return int(year) - 1900


# --------------------------------------------------------------------------- utilitas
def fmt_num(value, decimals: int | None = None) -> str:
    """Format angka persis seperti portal: '96' / '92.81' / '287198.4'.

    `decimals` diambil dari metadata kolom BPS (angka_desimal_dibelakang_koma);
    tanpa itu, nol desimal di belakang dibuang (96.0 -> '96').
    """
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if decimals is not None:
        # Portal memangkas nol di belakang: 2.40 -> "2.4", 100.00 -> "100".
        text = f"{value:.{decimals}f}"
        if "." in text:
            text = text.rstrip("0").rstrip(".")
        return text
    if isinstance(value, int) or float(value) == int(value):
        return str(int(value))
    return repr(float(value))


# Token nilai-hilang BPS (lihat `keterangan_data` pada respons). Portal menuliskannya
# apa adanya, jadi harus dipertahankan verbatim: '...' = data tidak tersedia,
# '-'/'–' = tidak ada atau nol, 'NA' = tidak dapat ditampilkan, dst.
MISSING_TOKENS = {"...", "…", "-", "–", "NA", "N/A", "~0", "*", "**", "***", "e", "r"}


def idn_to_float(text: str) -> float | None:
    """Ubah angka format Indonesia ("5.695,9") ke float. Token hilang -> None."""
    if text is None:
        return None
    s = str(text).strip()
    if s in MISSING_TOKENS or s == "":
        return None
    s = s.replace(".", "").replace(",", ".")
    try:
        return float(s)
    except ValueError:
        return None


# --------------------------------------------------------------------------- model/data (SRC-10)
def parse_model_data(payload: dict, src_tag: str = "SRC-10") -> dict:
    """Bongkar respons `model/data` menjadi struktur siap-tulis."""
    if payload.get("status") != "OK":
        raise ValueError(f"{src_tag}: status API bukan OK: {payload.get('status')!r} "
                         f"({payload.get('message') or payload.get('code')})")
    var = payload["var"][0]["val"]
    tahun = payload["tahun"][0]
    turtahun = payload["turtahun"][0]["val"] if payload.get("turtahun") else 0
    return {
        "title": payload["var"][0]["label"],
        "var": var,
        "year": tahun["label"],
        "tahun_val": tahun["val"],
        "turtahun": turtahun,
        "vervar": payload.get("vervar") or [],
        "turvar": payload.get("turvar") or [],
        "datacontent": payload.get("datacontent") or {},
    }


def model_data_matrix(parsed: dict) -> tuple[list[str], list[str], list[list[str]]]:
    """Kembalikan (labels_turvar, labels_vervar, baris nilai) dengan '-' bila kosong."""
    labels_turvar = [t["label"] for t in parsed["turvar"]]
    labels_vervar = [v["label"] for v in parsed["vervar"]]
    dc = parsed["datacontent"]
    rows = []
    for v in parsed["vervar"]:
        row = []
        for t in parsed["turvar"]:
            key = f"{v['val']}{parsed['var']}{t['val']}{parsed['tahun_val']}{parsed['turtahun']}"
            row.append(fmt_num(dc[key]) if key in dc else "-")
        rows.append(row)
    return labels_turvar, labels_vervar, rows


def write_iklh_csv(payload: dict, out_path: Path, province_label: str = IKLH_PROVINCE_LABEL) -> int:
    """Tulis CSV SRC-10 dengan 4 baris header bertingkat, persis seperti ekspor BPS."""
    parsed = parse_model_data(payload, "SRC-10")
    labels_turvar, labels_vervar, rows = model_data_matrix(parsed)
    year = parsed["year"]
    width = len(labels_turvar)

    out = io.StringIO()
    w = csv.writer(out, lineterminator="\n")
    w.writerow([province_label] + [""] * width)
    w.writerow(["", parsed["title"]] + [""] * (width - 1))
    w.writerow([""] + labels_turvar)
    w.writerow([""] + [year] * width)
    for label, values in zip(labels_vervar, rows):
        w.writerow([label] + values)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, "w", encoding="utf-8-sig", newline="") as fh:
        fh.write(out.getvalue().rstrip("\n"))
    return len(rows)


# --------------------------------------------------------------------------- tabel statistik (SRC-12)
PENDUDUK_COLUMNS = [
    ("nzudy5elv7", "Jumlah Penduduk (Ribu)"),
    ("d8efayjxld", "Laju Pertumbuhan Penduduk per Tahun"),
    ("efg2cjrdn2", "Persentase Penduduk"),
    ("xauol4vjpj", "Kepadatan Penduduk per km persegi (Km2)"),
    ("ztxhjlhyqd", "Rasio Jenis Kelamin Penduduk"),
]


def _stat_table(payload: dict, src_tag: str = "SRC-12") -> dict:
    if payload.get("status") != "OK":
        raise ValueError(f"{src_tag}: status API bukan OK: {payload.get('status')!r}")
    data = payload.get("data") or []
    table = next((d for d in data if isinstance(d, dict) and "kolom" in d), None)
    if table is None:
        raise ValueError(f"{src_tag}: tidak menemukan objek tabel dengan kunci 'kolom'")
    return table


def penduduk_year(payload: dict) -> int:
    return int(_stat_table(payload)["tahun_data"])


def write_penduduk_csv(payload: dict, out_path: Path) -> int:
    """Tulis CSV SRC-12: header + 38 provinsi + baris Indonesia. Tanpa catatan kaki.

    Catatan kaki portal ("Keterangan") sengaja tidak ditulis: portal memecahnya menjadi
    jumlah baris berbeda tiap tahun, sehingga berkas hasil API dan hasil portal tidak akan
    pernah identik. Tanpa catatan kaki, keduanya identik byte-per-byte. Teks catatan tetap
    tersedia di respons API (`catatan` / `keterangan_data`) dan diarsipkan sebagai JSON.
    """
    table = _stat_table(payload)
    by_name = {meta["nama_variabel"]: code for code, meta in table["kolom"].items()}

    # Petakan kolom target ke kode acak dari API, berdasarkan nama variabel resmi.
    mapping = []
    for default_code, header in PENDUDUK_COLUMNS:
        code = next((c for name, c in by_name.items() if name in header or header.split(" (")[0] in name), None)
        code = code or default_code
        decimals = (table["kolom"].get(code) or {}).get("angka_desimal_dibelakang_koma")
        mapping.append((code, header, decimals))

    out = io.StringIO()
    w = csv.writer(out, lineterminator="\n")
    w.writerow(["Provinsi"] + [header for _, header, _ in mapping])
    for row in table["data"]:
        values = []
        for code, _, decimals in mapping:
            raw = (row.get("variables") or {}).get(code, {}).get("value")
            text = "" if raw is None else str(raw).strip()
            if text in MISSING_TOKENS:
                # Pertahankan token asli ('...', '-', 'NA') seperti portal.
                values.append(text)
                continue
            num = idn_to_float(text)
            values.append("" if num is None else fmt_num(num, decimals))
        w.writerow([row.get("label", "")] + values)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    # Tanpa newline penutup, sama seperti berkas portal yang sudah dinormalisasi.
    with open(out_path, "w", encoding="utf-8-sig", newline="") as fh:
        fh.write(out.getvalue().rstrip("\n"))
    return len(table["data"])


# --------------------------------------------------------------------------- fetch
def fetch_payload(url_template: str, key: str, tahun: int | None = None, timeout: int = 120, **extra) -> dict:
    """Ambil JSON dari WebAPI BPS. `requests` diimpor lokal agar modul bisa diuji tanpa itu."""
    import requests

    url = url_template.format(
        key=key,
        tahun=tahun,
        th=th_code(tahun) if tahun else None,
        **extra,
    )
    resp = requests.get(url, timeout=timeout, headers={"User-Agent": "capstone-de-bps/1.0"})
    if resp.status_code in (401, 403):
        raise PermissionError(f"HTTP {resp.status_code}: token BPS ditolak. Periksa BPS_API_KEY.")
    resp.raise_for_status()
    payload = resp.json()
    _check_envelope(payload, url)
    return payload


def _check_envelope(payload: dict, url: str) -> None:
    """BPS kadang membalas HTTP 200 dengan error di dalam `data[1]`."""
    if payload.get("status") not in (None, "OK"):
        raise ValueError(f"WebAPI BPS menolak permintaan: {payload.get('message') or payload.get('status')}")
    data = payload.get("data")
    if isinstance(data, list):
        for item in data:
            if isinstance(item, dict) and str(item.get("condition", "")).upper() == "ERROR":
                raise ValueError(
                    f"WebAPI BPS mengembalikan error untuk {url.split('?')[0]}: "
                    f"{item.get('message')}"
                )


def fetch_iklh(key: str, years: tuple[int, ...] = IKLH_YEARS) -> dict[int, dict]:
    """Ambil tabel IKLH per tahun lewat parameter `th` (tahun - 1900).

    Memvalidasi bahwa tahun pada respons sama dengan tahun yang diminta; tanpa itu
    nama berkas bisa tidak cocok dengan isinya.
    """
    out = {}
    for year in years:
        payload = fetch_payload(DEFAULT_IKLH_URL, key, tahun=year)
        actual = int(parse_model_data(payload)["year"])
        if actual != int(year):
            raise ValueError(
                f"SRC-10: meminta tahun {year} (th={th_code(year)}) "
                f"tetapi API mengembalikan tahun {actual}"
            )
        out[int(year)] = payload
    return out


def fetch_penduduk(key: str, years: tuple[int, ...] = PENDUDUK_YEARS) -> dict[int, dict]:
    """Ambil tabel penduduk per tahun lewat endpoint SIMDASI (id=25)."""
    id_tabel, wilayah = penduduk_params()
    out = {}
    for year in years:
        payload = fetch_payload(
            DEFAULT_PENDUDUK_URL, key, tahun=year, id_tabel=id_tabel, wilayah=wilayah
        )
        actual = penduduk_year(payload)
        if actual != int(year):
            raise ValueError(
                f"SRC-12: meminta tahun {year} tetapi API mengembalikan tahun {actual}"
            )
        out[int(year)] = payload
    return out


def penduduk_filename(year: int) -> str:
    return (
        "Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, "
        "Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, "
        f"{year}.csv"
    )


def archive_payload(payload: dict, out_dir: Path, year: int, tag: str) -> Path:
    """Simpan respons mentah sebagai JSON, karena catatan kaki tidak lagi ditulis ke CSV."""
    out_dir.mkdir(parents=True, exist_ok=True)
    path = out_dir / f"{tag}_{year}.json"
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    return path


def strip_footer(path: Path) -> bool:
    """Hapus blok catatan kaki dari CSV portal; pertahankan sampai baris Indonesia.

    Mengembalikan True bila berkas berubah.
    """
    raw = path.read_bytes()
    text = raw.decode("utf-8-sig")
    lines = text.split("\n")
    keep = []
    for line in lines:
        keep.append(line)
        if line.split(",", 1)[0].strip().upper() == "INDONESIA":
            break
    else:
        return False  # baris Indonesia tidak ditemukan; jangan sentuh berkas

    new = ("\ufeff" + "\n".join(keep)).encode("utf-8")
    if new == raw:
        return False
    path.write_bytes(new)
    return True


def iklh_filename(year: int) -> str:
    return (
        "Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, "
        f"{year}.csv"
    )


# --------------------------------------------------------------------------- selftest
def _selftest(argv: list[str]) -> int:
    """Bandingkan hasil transform dengan CSV portal yang ada di repo."""
    args = argv[2:] if len(argv) > 1 and argv[1] == "--selftest" else argv[1:]
    pairs = []
    if len(args) >= 2:
        for i in range(0, len(args) - 1, 2):
            pairs.append((Path(args[i]), Path(args[i + 1])))

    if not pairs:
        print("Pemakaian: python bps_api.py --selftest <response.json> <csv_pembanding> ...")
        return 2

    ok = True
    for json_path, csv_path in pairs:
        payload = json.load(open(json_path, encoding="utf-8"))
        tmp = Path(os.environ.get("TEMP", ".")) / f"gen_{csv_path.name}"
        if "datacontent" in payload:
            n = write_iklh_csv(payload, tmp)
        else:
            n = write_penduduk_csv(payload, tmp)
        gen = [r for r in csv.reader(open(tmp, encoding="utf-8-sig"))]
        exp = [r for r in csv.reader(open(csv_path, encoding="utf-8-sig"))]
        # Bandingkan blok data: buang baris header/legenda portal BPS (INDONESIA tetap dihitung).
        skip = ("38 Provinsi", "Provinsi", "Keterangan")
        is_note = lambda r: r[0] and (r[0][0].isdigit() or r[0].startswith("1P"))
        exp_data = [r for r in exp if r and r[0] and r[0] not in skip and not is_note(r)]
        gen_data = [r for r in gen if r and r[0] and r[0] not in ("38 Provinsi", "Provinsi") and not is_note(r)]
        same = gen_data == exp_data
        ok = ok and same
        print(f"{'OK  ' if same else 'DIFF'} {csv_path.name[:60]} -> {n} baris")
        if not same:
            for a, b in zip(gen_data, exp_data):
                if a != b:
                    print("   generated:", a)
                    print("   portal   :", b)
                    break
    return 0 if ok else 1


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--selftest":
        raise SystemExit(_selftest(sys.argv))
    print(__doc__)
