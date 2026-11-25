#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
profile_sources.py (v3) - profiling SRC-01..SRC-12 berbasis spesifikasi, untuk Fase 2 capstone.

Dibuat setelah menganalisis data sumber yang sebenarnya (ZIP 'Sumber Data'): pembaca khusus untuk CSV ala BPS
(judul/header bertingkat/catatan kaki), GeoJSON sangat besar (streaming, tanpa memuat file), penyaringan Indonesia
pada data global, deteksi tanggal teks dan epoch, aturan domain, probe relasi antar-sumber, dan kamus data.

PERINTAH
  python profile_sources.py status   --root "Sumber Data"        # cek folder SRC-01..SRC-12
  python profile_sources.py profile  --root "Sumber Data"        # profil semua -> profile_out/
  python profile_sources.py profile  --root "Sumber Data" --spatial   # + uji penugasan titik ke poligon ADM2 (butuh shapely)
  python profile_sources.py profile  --only SRC-10,SRC-12
  python profile_sources.py decisions                            # menulis formulir keputusan desain (juga otomatis ada di profile_out/)
  python profile_sources.py init     --root data_raw             # membuat folder kosong + README per sumber (opsional)
  python profile_sources.py prepare  ...                         # menyaring file besar (OpenCelliD/Ookla/GPPD) ke Indonesia
  python profile_sources.py fetch-overpass ...                   # mengunduh gardu/jalur listrik OSM (opsional)

Folder sumber dikenali dari namanya (SRC-01, SRC 01, src_1, dst.) sehingga folder asli tidak perlu diubah.
KEBUTUHAN  Python 3.9+ dan pandas (XLSX: openpyxl; Parquet: pyarrow; --spatial: shapely).  Semua proses lokal.
"""
import argparse
import csv
import gzip
import hashlib
import itertools
import json
import re
import shutil
import struct
import sys
import time
import unicodedata
import urllib.parse
import urllib.request
import warnings
import zipfile
from datetime import datetime
from pathlib import Path

import pandas as pd

warnings.filterwarnings("ignore")

VERSION = "3.0"
DEFAULT_MAX_ROWS = 3_000_000
COUNT_LIMIT_BYTES = 600 * 1024 * 1024   # file CSV lebih besar: jumlah baris total tidak dihitung
GEO_FULL_LIMIT = 60_000          # GeoJSON dengan fitur <= ini dibaca penuh (properti saja); selebihnya sampel awal
GEO_SAMPLE = 20_000
GEO_BBOX_FEATURES = 600          # bounding box geometri dihitung dari maks. sekian fitur pertama
PACK_CHARS = 60_000
IDN_BBOX = (-11.5, 94.0, 6.5, 141.5)   # lat_min, lon_min, lat_max, lon_max (KASAR)
OCID_COLS = ["radio", "mcc", "net", "area", "cell", "unit", "lon", "lat", "range", "samples", "changeable",
             "created", "updated", "averageSignal"]
NULL_TOKENS = {"null", "none", "nan", "na", "n/a", "-", "--", "?", "#n/a", "undefined", "tidak ada", "–", "...", "…", "n.a", "n.a."}
MISSING_TOK = {"-", "–", "...", "…", "n.a", "n.a.", "na", "x", "*", "**"}
RESERVED = {
    "all", "analyse", "analyze", "and", "any", "array", "as", "asc", "asymmetric", "both", "case", "cast",
    "check", "collate", "column", "constraint", "create", "current_date", "current_time", "current_timestamp",
    "current_user", "default", "deferrable", "desc", "distinct", "do", "else", "end", "except", "false",
    "fetch", "for", "foreign", "from", "grant", "group", "having", "in", "initially", "intersect", "into",
    "lateral", "leading", "limit", "localtime", "localtimestamp", "not", "null", "offset", "on", "only", "or",
    "order", "placing", "primary", "references", "returning", "select", "session_user", "some", "symmetric",
    "table", "then", "to", "trailing", "true", "union", "unique", "user", "using", "variadic", "when", "where",
    "window", "with",
}
CONTRACT_COLS = ["Contract_ID", "Source_ID", "Source_Dataset", "Source_Field", "Source_Type", "Target_Dataset",
                 "Target_Field", "Target_Type", "Key_Null_Rule", "Business_Definition", "Classification",
                 "Validation_Rule"]
MONTHS = "jan|feb|mar|apr|mei|may|jun|jul|agu|aug|sep|okt|oct|nov|des|dec"


# ----------------------------------------------------------------------------- registri sumber
def E(label, rx):
    return (label, re.compile(rx, re.I))


LAT_RX = r"(^|[^a-z])(lat|latitude|lintang)([^a-z]|$)"
LON_RX = r"(^|[^a-z])(lon|lng|long|longitude|bujur)([^a-z]|$)"

SOURCES = {
    "SRC-01": dict(name="BMKG Earthquake Catalog 1998-2024", where=["https://data.mendeley.com/datasets/zmzywny59b/1"],
                   license="CC BY 4.0 (atribusi BMKG)", grain="titik: 1 baris = 1 kejadian gempa", claim=(1998, 2024),
                   expect=[E("ID kejadian", r"event.?id"), E("tanggal", r"^date$"), E("lintang", LAT_RX), E("bujur", LON_RX),
                           E("magnitudo", r"^mag"), E("kedalaman", r"depth")]),
    "SRC-02": dict(name="Kejadian Bencana BNPB (Kaggle maudiana)", where=["https://www.kaggle.com/datasets/maudiana/indonesia-natural-disaster-dataset-bnpb-records"],
                   license="lihat panel License di halaman Kaggle (data asal BNPB)", grain="kejadian: 1 baris = 1 kejadian bencana per kab/kota per hari",
                   claim=(2010, 2025),
                   expect=[E("tanggal", r"^date$"), E("kabupaten/kota", r"^city$"), E("provinsi", r"^province$"),
                           E("jenis bencana", r"disaster_type"), E("korban", r"death")]),
    "SRC-03": dict(name="Iklim Harian BMKG (Kaggle greegtitan)", where=["https://www.kaggle.com/datasets/greegtitan/indonesia-climate"],
                   license="lihat panel License di halaman Kaggle (atribusi BMKG)", grain="stasiun-hari + tabel detail stasiun/provinsi",
                   expect=[E("tanggal", r"^date$"), E("stasiun", r"station_id"), E("suhu rata-rata", r"^tavg$"),
                           E("curah hujan", r"^rr$"), E("kelembaban", r"rh_avg")]),
    "SRC-04": dict(name="District-Level Geospatial & Socioeconomic Dataset (514 kab/kota)", where=["https://data.mendeley.com/datasets/xxx26vkpsb/1"],
                   license="CC BY 4.0", grain="kabupaten/kota: 1 baris = 1 wilayah (514)",
                   expect=[E("kode BPS", r"bps.*code"), E("nama wilayah", r"kabkota_name"), E("provinsi", r"prov_name"),
                           E("elevasi", r"elevation_mean")]),
    "SRC-05": dict(name="OpenCelliD menara seluler MCC 510", where=["https://opencellid.org"],
                   license="CC BY-SA 4.0 (atribusi OpenCelliD)", grain="titik: 1 baris = 1 sel (radio, net, area, cell)",
                   headerless=OCID_COLS,
                   expect=[E("radio", r"^radio$"), E("mcc", r"^mcc$"), E("net", r"^net$"), E("area", r"^area$"), E("cell", r"^cell$"),
                           E("bujur", LON_RX), E("lintang", LAT_RX)]),
    "SRC-06": dict(name="Ookla Open Data fixed tiles 2024 Q4 (Indonesia)", where=["https://ookla-open-data.s3.amazonaws.com/parquet/performance/type=fixed/year=2024/quarter=4/"],
                   license="CC BY-NC-SA 4.0 (non-komersial, atribusi Ookla)", grain="tile geografis zoom 16 per kuartal (quadkey)",
                   expect=[E("quadkey", r"quadkey"), E("tile (WKT)", r"^tile$"), E("kecepatan unduh", r"avg_d_kbps"),
                           E("latensi", r"avg_lat_ms"), E("jumlah tes", r"^tests$")]),
    "SRC-07": dict(name="Global Power Plant Database v1.3.0 (WRI)", where=["https://datasets.wri.org/dataset/globalpowerplantdatabase"],
                   license="CC BY 4.0", grain="titik: 1 baris = 1 pembangkit (global; saring country = IDN)",
                   expect=[E("negara", r"^country$"), E("ID pembangkit", r"gppd_idnr"), E("kapasitas MW", r"capacity_mw"),
                           E("lintang", LAT_RX), E("bujur", LON_RX), E("bahan bakar", r"primary_fuel")]),
    "SRC-08": dict(name="OpenStreetMap gardu induk (Overpass Turbo export)", where=["https://overpass-turbo.eu"],
                   license="ODbL (atribusi (c) OpenStreetMap contributors)", grain="titik pusat: 1 elemen OSM (node/way/relation) bertag power=substation",
                   expect=[E("id elemen", r"^id$|^@id$"), E("tag power", r"^power$"), E("tag voltage", r"voltage"), E("operator", r"^operator$")]),
    "SRC-09": dict(name="Sebaran PoP ISP (Komdigi)", where=["https://datahub.komdigi.go.id/public/detail-data/173"],
                   license="Data publik (atribusi Komdigi)", grain="provinsi x tahun",
                   expect=[E("provinsi", r"provinsi"), E("jumlah PoP", r"pop"), E("tahun", r"tahun")]),
    "SRC-10": dict(name="Komponen Penyusun Indeks Kualitas Lingkungan Hidup (BPS)", where=["https://www.bps.go.id"],
                   license="Data publik BPS (atribusi BPS)", grain="provinsi x tahun (satu file per tahun; komponen sebagai kolom)", claim=(2019, 2024),
                   expect=[E("provinsi", r"^provinsi$"), E("tahun", r"^tahun$"), E("indeks kualitas air", r"air")]),
    "SRC-11": dict(name="COD-AB Indonesia (OCHA/BPS via HDX)", where=["https://data.humdata.org/dataset/cod-ab-idn"],
                   license="CC BY-IGO (atribusi OCHA/BPS)", grain="poligon batas wilayah ADM0..ADM4 + garis + titik",
                   expect=[E("kode ADM2", r"adm2_pcode"), E("nama ADM2", r"adm2_name$"), E("kode ADM1", r"adm1_pcode")]),
    "SRC-12": dict(name="Penduduk, Laju, Kepadatan menurut Provinsi (BPS)", where=["https://www.bps.go.id"],
                   license="Data publik BPS (atribusi BPS)", grain="provinsi x tahun (satu file per tahun)",
                   expect=[E("provinsi", r"^provinsi$"), E("tahun", r"^tahun$"), E("penduduk", r"penduduk"), E("kepadatan", r"kepadatan")]),
}


def R(col, lo=None, hi=None, label="", cols_re=False, integer=False):
    return dict(col=col, min=lo, max=hi, label=label, cols_re=cols_re, integer=integer)


def X(a, op, b, label=""):
    return dict(expr=(a, op, b), label=label or f"{a} {op} {b}")


# Spesifikasi per file nyata. pat = regex nama file (tanpa peduli huruf besar/kecil).
FILES = [
    dict(src="SRC-01", pat=r"bmkg.*catalog.*\.csv$", table="bmkg_gempa", reader="csv", keys=[["Event ID"]], drop_unnamed=True, geo=("Latitude", "Longitude"),
         defs={"No": "Nomor urut baris pada katalog sumber (tidak berurutan penuh; bukan kunci)",
               "Event ID": "ID kejadian BMKG berpola BMKG-yyyymmddhhmmss-nnn; kunci bisnis",
               "Date": "Tanggal kejadian (UTC), format dd-Mon-yyyy (bulan bahasa Inggris)",
               "Time (UTC)": "Jam kejadian (UTC) hh:mm:ss",
               "Latitude": "Lintang episenter (derajat desimal, WGS84)", "Longitude": "Bujur episenter (derajat desimal, WGS84)",
               "Magnitude": "Magnitudo gempa", "Mag Type": "Jenis skala magnitudo (MLv, M, mb, Mw, ...); '-' = tidak tercatat",
               "Depth (km)": "Kedalaman hiposenter (km)", "Source": "Kode jaringan/sumber data (NC, RC_xx)",
               "Source Event ID": "ID kejadian pada sumber asal; '-' = tidak ada"},
         rules=[R("Magnitude", 0, 10, "magnitudo wajar"), R("Depth (km)", 0, 800, "kedalaman wajar (km)")]),
    dict(src="SRC-02", pat=r"data_bencana.*\.xlsx?$", table="bnpb_bencana", reader="xlsx", keys=[],
         defs={"city_id": "Kode kab/kota versi dataset BNPB. PERINGATAN: bukan kode BPS (tidak konsisten dengan nama kota pada sebagian baris)",
               "date": "Tanggal kejadian bencana", "disaster_type": "Jenis bencana", "city": "Nama kabupaten/kota (huruf besar; awalan KOTA dipertahankan)",
               "province": "Nama provinsi (variasi penulisan)", "cause": "Penyebab kejadian",
               "death": "Jumlah korban meninggal", "missing_person": "Jumlah korban hilang", "injured_person": "Jumlah korban luka",
               "damaged_house": "Jumlah rumah rusak", "flooded_house": "Jumlah rumah terendam", "damaged_facility": "Jumlah fasilitas rusak"},
         rules=[R(c, 0, None, "tidak boleh negatif", integer=True) for c in ("death", "missing_person", "injured_person", "damaged_house", "flooded_house", "damaged_facility")]),
    dict(src="SRC-03", pat=r"climate_data.*\.csv$", table="iklim_harian", reader="csv", keys=[["station_id", "date"]],
         defs={"date": "Tanggal pengamatan (dd-mm-yyyy)", "Tn": "Suhu minimum harian (derajat C)", "Tx": "Suhu maksimum harian (derajat C)",
               "Tavg": "Suhu rata-rata harian (derajat C)", "RH_avg": "Kelembapan relatif rata-rata (%)", "RR": "Curah hujan harian (mm)",
               "ss": "Lama penyinaran matahari (jam)", "ff_x": "Kecepatan angin maksimum (m/s)", "ddd_x": "Arah angin saat kecepatan maksimum (derajat)",
               "ff_avg": "Kecepatan angin rata-rata (m/s)", "ddd_car": "Arah angin terbanyak (kardinal)", "station_id": "ID stasiun BMKG (FK ke station_detail)"},
         rules=[R(r"^(Tn|Tx|Tavg)$", 0, 45, "suhu harian wajar (derajat C)", True), R("RH_avg", 0, 100, "kelembapan 0-100 %"),
                R("RR", 0, 500, "curah hujan harian wajar (mm)"), R("ss", 0, 24, "penyinaran 0-24 jam"),
                R(r"^(ff_x|ff_avg)$", 0, 60, "kecepatan angin wajar (m/s)", True), R("ddd_x", 0, 360, "arah angin 0-360 derajat"),
                X("Tn", "<=", "Tx"), X("Tn", "<=", "Tavg"), X("Tavg", "<=", "Tx")]),
    dict(src="SRC-03", pat=r"station_detail.*\.csv$", table="iklim_stasiun", reader="csv", keys=[["station_id"]], geo=("latitude", "longitude"),
         defs={"station_id": "ID stasiun BMKG", "station_name": "Nama stasiun", "region_name": "Nama kab/kota lokasi stasiun (berawalan Kab./Kota)",
               "latitude": "Lintang stasiun", "longitude": "Bujur stasiun", "region_id": "ID wilayah internal dataset (bukan kode BPS)",
               "province_id": "ID provinsi internal dataset (FK ke province_detail; bukan kode BPS)"}),
    dict(src="SRC-03", pat=r"province_detail.*\.csv$", table="iklim_provinsi", reader="csv", keys=[["province_id"]],
         defs={"province_id": "ID provinsi internal dataset (1..34)", "province_name": "Nama provinsi (penamaan lama, 34 provinsi)"}),
    dict(src="SRC-04", pat=r"master_features.*\.csv$", table="fitur_kabkota", reader="csv", keys=[["bps_kabkota_code"]], expect_rows=514, dict_file=True,
         rules=[R(r"^(ipm|ppm)_\d{4}$|^pct_", 0, 100, "indeks/persentase 0-100", True), R(r"^population_\d{4}$", 1, None, "penduduk > 0", True)]),
    dict(src="SRC-04", pat=r"data_dictionary.*\.csv$", table="kamus_fitur", reader="csv", keys=[["column_name"]], role="dictionary"),
    dict(src="SRC-05", pat=r"cell.*towers.*\.csv(\.gz)?$|opencellid.*\.csv(\.gz)?$", table="opencellid", reader="csv", keys=[["radio", "net", "area", "cell"]], geo=("lat", "lon"),
         epoch=["created", "updated"],
         defs={"radio": "Teknologi radio (GSM, UMTS, LTE, NR)", "mcc": "Mobile Country Code (510 = Indonesia)", "net": "Mobile Network Code (operator)",
               "area": "Location/Tracking Area Code", "cell": "Cell ID", "unit": "PSC/PCI (-1 = tidak ada)", "lon": "Bujur perkiraan sel",
               "lat": "Lintang perkiraan sel", "range": "Radius perkiraan cakupan (meter)", "samples": "Jumlah pengukuran yang membentuk posisi",
               "changeable": "1 = posisi hasil perhitungan, 0 = posisi dari sumber langsung", "created": "Waktu data pertama dibuat (epoch detik)",
               "updated": "Waktu data terakhir diperbarui (epoch detik)", "averageSignal": "Rata-rata kekuatan sinyal (0 = tidak ada)"},
         rules=[R("range", 1, 100000, "radius > 0 m"), R("samples", 1, None, "sampel >= 1")]),
    dict(src="SRC-06", pat=r"ookla.*\.(csv|parquet)$", table="ookla_tiles", reader="auto", keys=[["quadkey"]], geo=("tile_y", "tile_x"), text_cols=["quadkey"],
         defs={"quadkey": "ID tile (quadkey zoom 16); WAJIB text", "tile": "Poligon tile (WKT, WGS84)", "tile_x": "Bujur centroid tile", "tile_y": "Lintang centroid tile",
               "avg_d_kbps": "Rata-rata kecepatan unduh (kbps)", "avg_u_kbps": "Rata-rata kecepatan unggah (kbps)", "avg_lat_ms": "Rata-rata latensi (ms)",
               "avg_lat_down_ms": "Latensi saat unduh (ms)", "avg_lat_up_ms": "Latensi saat unggah (ms)", "tests": "Jumlah pengujian",
               "devices": "Jumlah perangkat unik", "quarter": "Kuartal", "type": "Jenis layanan (fixed)", "year": "Tahun", "lon": "Bujur sudut barat laut tile",
               "lat": "Lintang sudut barat laut tile"},
         rules=[R(r"^(avg_d_kbps|avg_u_kbps)$", 1, None, "kecepatan > 0", True), R(r"^(tests|devices)$", 1, None, "jumlah >= 1", True), R("avg_lat_ms", 0, None, "latensi >= 0")]),
    dict(src="SRC-07", pat=r"global_power_plant_database.*\.csv$", table="gppd", reader="csv", keys=[["gppd_idnr"]], geo=("latitude", "longitude"),
         filter=("country", "IDN"), dict_from="readme",
         rules=[R("capacity_mw", 1, 20000, "kapasitas 1-20000 MW")]),
    dict(src="SRC-08", pat=r"\.csv$", table="osm_gardu", reader="csv", keys=[["id"]], geo=("latitude", "longitude"), custom="osm_voltage", sparse=True,
         defs={"id": "ID elemen OSM (tipe/id)", "@id": "ID elemen OSM (tipe/id)", "power": "Tag power (selalu substation pada ekspor ini)",
               "substation": "Jenis gardu (transmission, distribution, minor_distribution, ...)", "voltage": "Tegangan dalam volt; dapat multi-nilai dipisah ';'",
               "operator": "Operator (variasi penulisan PLN)", "name": "Nama gardu", "latitude": "Lintang titik pusat", "longitude": "Bujur titik pusat",
               "geometry_wkt": "Geometri titik pusat (WKT)"}),
    dict(src="SRC-08", pat=r"\.geojson$", table="osm_gardu_geojson", reader="geojson", keys=[["@id"]], custom="osm_voltage", sparse=True, role="setara dengan CSV (pilih salah satu untuk ingestion)"),
    dict(src="SRC-09", pat=r"\.csv$", table="pop_isp", reader="csv", keys=[["Provinsi", "Tahun"]],
         defs={"Provinsi": "Nama provinsi (34 provinsi; penamaan sebelum pemekaran Papua)", "Sebaran PoP ISP": "Jumlah Point of Presence ISP",
               "Tahun": "Tahun data", "Source": "URL sumber (konstan)"},
         rules=[R("Sebaran PoP ISP", 0, None, "jumlah >= 0")]),
    dict(src="SRC-10", pat=r"\.csv$", table="iklh_provinsi", reader="bps", first_col="provinsi", drop_total=["INDONESIA"], keys=[["provinsi", "tahun"]], num_rule=(0, 100),
         defs={"provinsi": "Nama provinsi (HURUF BESAR; 38 provinsi)", "tahun": "Tahun (diturunkan dari baris header)",
               "Indeks Kualitas Udara": "Komponen IKLH: indeks kualitas udara (0-100)", "Indeks Kualitas Air": "Komponen IKLH: indeks kualitas air sungai/permukaan (0-100); bukan ukuran ketersediaan air",
               "Indeks Kualitas Tutupan Lahan (IKTL)": "Komponen IKLH: tutupan lahan (0-100)", "Indeks Kualitas Lahan (IKL)": "Komponen IKLH: kualitas lahan (0-100)",
               "Indeks Kualitas Ekosistem Gambut (IKEG)": "Komponen IKLH: ekosistem gambut (0-100); '-' = provinsi tanpa gambut",
               "Indeks Kualitas Air Laut (IKAL)": "Komponen IKLH: air laut (0-100); '-' = tidak ada pengukuran"}),
    dict(src="SRC-11", pat=r"idn_admin0", table="adm0", reader="geojson", keys=[["adm0_pcode"]], geo=("center_lat", "center_lon"), role="di luar cakupan model (batas negara)"),
    dict(src="SRC-11", pat=r"idn_admin1", table="adm1", reader="geojson", keys=[["adm1_pcode"]], geo=("center_lat", "center_lon"), expect_rows=34,
         rules=[R("area_sqkm", 0.0001, None, "luas > 0")]),
    dict(src="SRC-11", pat=r"idn_admin2", table="adm2", reader="geojson", keys=[["adm2_pcode"]], geo=("center_lat", "center_lon"), expect_rows=522, rows_tol=10,
         defs={"adm2_pcode": "Kode kab/kota OCHA: 'ID' + kode BPS 4 digit (mis. ID1107)", "adm2_name": "Nama kab/kota (awalan Kota; 4 poligon bernama Danau, waduk, hutan)",
               "adm1_pcode": "Kode provinsi OCHA (ID + kode BPS 2 digit)", "area_sqkm": "Luas poligon (km2)", "valid_on": "Tanggal berlaku batas wilayah"},
         rules=[R("area_sqkm", 0.0001, None, "luas > 0")]),
    dict(src="SRC-11", pat=r"idn_admin3", table="adm3", reader="geojson", keys=[["adm3_pcode"]], geo=("center_lat", "center_lon"), role="di luar cakupan model (kecamatan)"),
    dict(src="SRC-11", pat=r"idn_admin4", table="adm4", reader="geojson", keys=[["adm4_pcode"]], geo=("center_lat", "center_lon"), role="di luar cakupan model (desa; sangat besar)"),
    dict(src="SRC-11", pat=r"idn_adminlines", table="adm_lines", reader="geojson", keys=[], role="di luar cakupan model (garis batas)"),
    dict(src="SRC-11", pat=r"idn_adminpoints", table="adm_points", reader="geojson", keys=[], geo=("y_coord", "x_coord"), role="di luar cakupan model (titik pusat semua level)"),
    dict(src="SRC-12", pat=r"\.csv$", table="penduduk_provinsi", reader="bps", first_col="Provinsi", drop_total=["INDONESIA"], year_from_filename=True, keys=[["Provinsi", "tahun"]],
         defs={"Provinsi": "Nama provinsi", "tahun": "Tahun (diturunkan dari nama file)", "Jumlah Penduduk (Ribu)": "Jumlah penduduk (ribu jiwa)",
               "Laju Pertumbuhan Penduduk per Tahun": "Laju pertumbuhan penduduk per tahun (%)", "Persentase Penduduk": "Distribusi persentase penduduk (%)",
               "Kepadatan Penduduk per km persegi (Km2)": "Kepadatan penduduk (jiwa/km2)", "Rasio Jenis Kelamin Penduduk": "Rasio jenis kelamin (laki-laki per 100 perempuan)"},
         rules=[R("Jumlah Penduduk (Ribu)", 1, None, "penduduk > 0"), R("Persentase Penduduk", 0, 100, "persentase 0-100"),
                R("Kepadatan Penduduk per km persegi (Km2)", 1, None, "kepadatan > 0")]),
]

# Probe relasi: kind fk = cakupan FK; code_name = konsistensi kode vs nama; names = kecocokan nama wilayah.
# Referensi = (sumber, potongan nama file, kolom[, transformasi]); transformasi: after2 = buang 2 huruf awal ('ID1107' -> '1107')
PROBES = [
    dict(id="P1", kind="fk", left=("SRC-03", "climate_data", "station_id"), right=("SRC-03", "station_detail", "station_id"), desc="Pengamatan harian -> detail stasiun"),
    dict(id="P2", kind="fk", left=("SRC-03", "station_detail", "province_id"), right=("SRC-03", "province_detail", "province_id"), desc="Stasiun -> provinsi (ID internal)"),
    dict(id="P3", kind="fk", left=("SRC-08", ".csv", "id"), right=("SRC-08", ".geojson", "@id"), desc="SRC-08: CSV atribut <-> GeoJSON (ID elemen OSM)", both=True),
    dict(id="P4", kind="fk", left=("SRC-04", "master_features", "bps_kabkota_code"), right=("SRC-11", "admin2", "adm2_pcode", "after2"),
         desc="Kode BPS (SRC-04) <-> pcode ADM2 tanpa awalan ID (SRC-11)", both=True),
    dict(id="P5", kind="fk", left=("SRC-02", "data_bencana", "city_id"), right=("SRC-04", "master_features", "bps_kabkota_code"),
         desc="city_id BNPB -> kode BPS (SRC-04)"),
    dict(id="P6", kind="code_name", left=("SRC-02", "data_bencana", "city_id", "city"), right=("SRC-04", "master_features", "bps_kabkota_code", "kabkota_name"),
         desc="Jika kode sama, apakah nama kab/kota juga sama? (menguji city_id BNPB)"),
    dict(id="P7", kind="names", level="kab", left=("SRC-02", "data_bencana", "city"), right=("SRC-04", "master_features", "kabkota_name"), desc="Nama kab/kota BNPB -> SRC-04"),
    dict(id="P8", kind="names", level="kab", left=("SRC-03", "station_detail", "region_name"), right=("SRC-04", "master_features", "kabkota_name"), desc="Wilayah stasiun -> SRC-04"),
    dict(id="P9", kind="names", level="kab", left=("SRC-11", "admin2", "adm2_name"), right=("SRC-04", "master_features", "kabkota_name"), desc="Nama ADM2 (SRC-11) -> SRC-04"),
    dict(id="P10", kind="names", level="prov", left=("SRC-02", "data_bencana", "province"), right=("SRC-04", "master_features", "prov_name"), desc="Provinsi BNPB -> SRC-04"),
    dict(id="P11", kind="names", level="prov", left=("SRC-03", "province_detail", "province_name"), right=("SRC-04", "master_features", "prov_name"), desc="Provinsi iklim -> SRC-04"),
    dict(id="P12", kind="names", level="prov", left=("SRC-09", ".csv", "Provinsi"), right=("SRC-04", "master_features", "prov_name"), desc="Provinsi PoP ISP -> SRC-04"),
    dict(id="P13", kind="names", level="prov", left=("SRC-10", ".csv", "provinsi"), right=("SRC-04", "master_features", "prov_name"), desc="Provinsi IKLH -> SRC-04"),
    dict(id="P14", kind="names", level="prov", left=("SRC-12", ".csv", "Provinsi"), right=("SRC-04", "master_features", "prov_name"), desc="Provinsi penduduk -> SRC-04"),
    dict(id="P15", kind="names", level="prov", left=("SRC-11", "admin1", "adm1_name"), right=("SRC-04", "master_features", "prov_name"), desc="Provinsi ADM1 (SRC-11) -> SRC-04"),
]
PROBE_COLS = {}
for _p in PROBES:
    for _k in ("left", "right"):
        _r = _p[_k]
        PROBE_COLS.setdefault((_r[0], _r[1].lower()), set()).update(_r[2:4] if _p["kind"] == "code_name" else _r[2:3])

DECISIONS_TEMPLATE = """# PHASE2_DECISIONS.md  (isi lalu kirim bersama ai_input_pack_part*.md)
Beri tanda [x] pada pilihan dan isi kolom bergaris bawah. Jika setuju dengan rekomendasi, cukup tulis "ikuti rekomendasi".

## D1 Grain fakta utama
[ ] Periodic snapshot: 1 baris = 1 kab/kota x assessment_year (rekomendasi)   [ ] lainnya: ______
assessment_year: ____   jendela bahaya per jenis (isi sesuai cakupan data nyata di temporal_coverage.md):
 gempa (SRC-01): ____ s.d. ____   banjir/longsor (SRC-02): ____ s.d. ____   iklim (SRC-03): ____ s.d. ____
## D2 Definisi paparan gempa (lihat spatial_probe di pack: titik-dalam-poligon hanya menangkap sebagian kecil gempa)
[ ] Radius jarak dari wilayah (rekomendasi), radius: ____ km    [ ] Titik-dalam-poligon
## D3 Kunci wilayah kanonik
[ ] Kode BPS 4 digit dari SRC-04 (514 wilayah, 38 provinsi)   [ ] pcode ADM2 SRC-11 (522 poligon, 34 provinsi, batas 2020)   [ ] lainnya: ______
Aturan crosswalk: SRC-11 pcode = 'ID' + kode BPS (lihat relationship_probe). Pemekaran Papua (26 kab) dipetakan ke: ______
SRC-02 city_id BUKAN kode BPS: [ ] cocokkan dengan nama+provinsi (rekomendasi)   Poligon non-wilayah (Danau/Waduk/Hutan) di SRC-11: [ ] dikeluarkan
## D4 Pola Data Vault
Penugasan spasial (titik -> wilayah) di business vault (bv_): [ ] setuju   Pengamatan harian sebagai satelit dengan obs_date: [ ] setuju
## D5 Model dimensional
[ ] fact_site_assessment + fact_kejadian_bencana (opsional) + dim_wilayah, dim_waktu, dim_jenis_bencana (rekomendasi)   [ ] lainnya: ______
## D6 KPI, ambang, bobot (tabel parameter, bukan hard-code)
KPI-01 rumus: ______   ambang status 'Tinggi': ______
KPI-02 rumus: ______   sumber suhu/iklim: [ ] SRC-04 (t2m_mean, 514 wilayah)  [ ] SRC-03 (stasiun, s.d. 2020)  [ ] keduanya
KPI-03 bobot: keamanan __% utilitas __% iklim __%   level ranking: [ ] kab/kota  [ ] provinsi
Parameter: tegangan minimum gardu = ___ kV; radius gardu = ___ km; radius menara = ___ km; magnitudo minimum bahaya = ___
## D7 Database target
Database: ______   Image PostGIS (tag persis): ______   hasil SELECT postgis_version(): ______
## D8 Kebijakan raw
[ ] Raw append-only dengan _batch_id; staging reload per batch; vault insert-only (rekomendasi)
## D9 Konvensi
snake_case; hash key char(32)=md5; timestamptz UTC; SRID 4326; unit baku kV, MW, km, Mbps: [ ] setuju   perubahan: ______
## D10 Strategi muat per sumber (FULL / INCREMENTAL / SNAPSHOT)
SRC-01 ____ SRC-02 ____ SRC-03 ____ SRC-04 ____ SRC-05 ____ SRC-06 ____ SRC-07 ____ SRC-08 ____ SRC-09 ____ SRC-10 ____ SRC-11 ____ SRC-12 ____
## D11 Nilai pecahan pada kolom korban/kerusakan SRC-02 (death, missing_person, injured_person, flooded_house; lihat readiness_report)
[ ] simpan apa adanya sebagai numeric dan beri catatan 'bukan hitungan asli' (rekomendasi)  [ ] bulatkan  [ ] jangan pakai kolom ini di KPI   Alasan/konfirmasi pemilik data: ______
## D12 Baris duplikat penuh SRC-02 (lihat readiness_report)
[ ] hapus duplikat di staging (rekomendasi)  [ ] pertahankan   Kunci surrogate: [ ] hash seluruh kolom + nomor urut duplikat
## D13 Jendela bahaya dan klaim proposal (lihat temporal_coverage.md)
Banjir/longsor/bencana lain memakai rentang data aktual SRC-02: ____ s.d. ____ ; proposal diperbarui: [ ] ya   Gempa (SRC-01) jendela: ____ s.d. ____ (cakupan deteksi tidak merata antar tahun; tetapkan ambang magnitudo)
## D14 Sumber suhu/iklim dan cakupan stasiun (SRC-03 berakhir 2020, hanya sebagian kab/kota punya stasiun)
[ ] SRC-04 sebagai sumber utama (514 wilayah, rata-rata 2020-2024), SRC-03 untuk validasi/detail stasiun   [ ] SRC-03 utama   [ ] lainnya: ______
## Catatan lain / pertanyaan untuk AI
______
"""


# ----------------------------------------------------------------------------- utilitas
def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def count_lines(path):
    n = 0
    opener = gzip.open if str(path).lower().endswith(".gz") else open
    with opener(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            n += chunk.count(b"\n")
    return n


def ascii_slug(text, maxlen=30):
    text = unicodedata.normalize("NFKD", str(text)).encode("ascii", "ignore").decode()
    text = re.sub(r"[^0-9a-zA-Z]+", "_", text).strip("_").lower()
    return text[:maxlen].strip("_")


def snake(name, used):
    base = ascii_slug(name, 55) or "col"
    if base[0].isdigit():
        base = "c_" + base
    if base in RESERVED:
        base += "_col"
    cand, i = base, 2
    while cand in used:
        cand = f"{base}_{i}"
        i += 1
    used.add(cand)
    return cand


def dedupe(cols):
    seen, out = {}, []
    for c in cols:
        if c in seen:
            seen[c] += 1
            out.append(f"{c}.{seen[c]}")
        else:
            seen[c] = 0
            out.append(c)
    return out


def md_cell(v, n=60):
    s = "" if v is None else str(v)
    s = s.replace("|", "\\|").replace("\n", " ").replace("\r", " ")
    return s if len(s) <= n else s[: n - 1] + "…"


def fmt_pct(x):
    return f"{x:.1f}%"


def stringify(df, already_str=False):
    """Ubah semua nilai menjadi str / None agar profil seragam."""
    df = df.copy()
    df.columns = dedupe([str(c).strip() for c in df.columns])
    if already_str:
        return df.astype(object).where(df.notna(), None)
    out = {}
    for c in df.columns:
        vals = df[c].astype(object)
        vals = vals.where(vals.notna(), None).tolist()

        def conv(v):
            if v is None or isinstance(v, str):
                return v
            if isinstance(v, (list, dict, tuple)):
                return json.dumps(v, ensure_ascii=False, default=str)
            if hasattr(v, "tolist"):
                return json.dumps(v.tolist(), ensure_ascii=False, default=str)
            return str(v)

        out[c] = [conv(v) for v in vals]
    return pd.DataFrame(out, dtype=object)


# ----------------------------------------------------------------------------- GeoJSON streaming
def iter_geojson_features(path, chunk=8 << 20, limit=None):
    """Iterasi fitur GeoJSON tanpa memuat seluruh file (memori ~ ukuran satu fitur + satu chunk)."""
    dec = json.JSONDecoder()
    with open(path, "r", encoding="utf-8") as f:
        buf, started, pos, n = "", False, 0, 0
        while True:
            data = f.read(chunk)
            if data:
                buf += data
            elif not buf:
                return
            if not started:
                m = re.search(r'"features"\s*:\s*\[', buf)
                if not m:
                    if not data:
                        return
                    continue
                pos, started = m.end(), True
            while True:
                while pos < len(buf) and buf[pos] in " \r\n\t,":
                    pos += 1
                if pos >= len(buf):
                    break
                if buf[pos] == "]":
                    return
                try:
                    obj, end = dec.raw_decode(buf, pos)
                except json.JSONDecodeError:
                    break
                yield obj
                pos, n = end, n + 1
                if limit and n >= limit:
                    return
            buf, pos = buf[pos:], 0
            if not data:
                return


def count_geojson_features(path, chunk=32 << 20):
    pat = re.compile(rb'"type"\s*:\s*"Feature"')
    n, tail = 0, b""
    with open(path, "rb") as f:
        while True:
            d = f.read(chunk)
            if not d:
                break
            buf = tail + d
            n += sum(1 for m in pat.finditer(buf) if m.end() > len(tail))
            tail = buf[-48:]
    return n


def walk_coords(coords, acc):
    st = [coords]
    while st:
        c = st.pop()
        if isinstance(c, list):
            if len(c) >= 2 and isinstance(c[0], (int, float)) and isinstance(c[1], (int, float)):
                acc[0], acc[1] = min(acc[0], c[0]), min(acc[1], c[1])
                acc[2], acc[3] = max(acc[2], c[0]), max(acc[3], c[1])
            else:
                st.extend(c)


# ----------------------------------------------------------------------------- penjelajah folder
TABULAR = {".csv": "csv", ".tsv": "tsv", ".xlsx": "xlsx", ".xlsm": "xlsx", ".xls": "xls", ".json": "json",
           ".geojson": "geojson", ".jsonl": "jsonl", ".ndjson": "jsonl", ".parquet": "parquet", ".shp": "shp", ".dbf": "dbf"}
SRC_DIR_RE = re.compile(r"^src[\s_\-]*0*(\d{1,2})(?!\d)", re.I)
IGNORE_NAME = re.compile(r"^(readme|license|licence|_|\.)", re.I)
SHP_TYPES = {0: "Null", 1: "Point", 3: "PolyLine", 5: "Polygon", 8: "MultiPoint", 11: "PointZ", 13: "PolyLineZ",
             15: "PolygonZ", 18: "MultiPointZ", 21: "PointM", 23: "PolyLineM", 25: "PolygonM", 28: "MultiPointM", 31: "MultiPatch"}
SHA_LIMIT = 400 << 20


def guess_format(path):
    n = Path(path).name.lower()
    if n.endswith(".gz"):
        n = n[:-3]
    return TABULAR.get(Path(n).suffix, "")


def find_source_dirs(root):
    out = {}
    for d in sorted(Path(root).iterdir()) if Path(root).exists() else []:
        m = SRC_DIR_RE.match(d.name)
        if d.is_dir() and m:
            out[f"SRC-{int(m.group(1)):02d}"] = d
    return out


def match_spec(src, name):
    for sp in FILES:
        if sp["src"] == src and re.search(sp["pat"], name, re.I):
            return sp
    return {"src": src, "pat": "", "reader": "auto", "keys": []}


def quick_sha(path):
    return sha256(path) if Path(path).stat().st_size <= SHA_LIMIT else None


def discover(folder, src):
    """Kembalikan (items, docs, dups). items: file tabular untuk diprofil; ZIP hanya diekstrak bila isinya belum ada sebagai file lepas."""
    items, docs, dups, loose_sha = [], [], [], {}
    folder = Path(folder)
    for p in sorted(folder.rglob("*")):
        if not p.is_file() or "_unzipped" in p.parts or "_raw" in p.parts or "__MACOSX" in p.parts or p.suffix.lower() == ".zip":
            continue
        if IGNORE_NAME.match(p.name):
            continue
        fmt = guess_format(p)
        if not fmt or (fmt == "dbf" and any(p.with_suffix(s).exists() for s in (".shp", ".SHP"))):
            if p.suffix.lower() in (".pdf", ".docx", ".doc", ".txt", ".md"):
                docs.append({"name": p.name, "path": p, "text": p.read_text(errors="ignore")[:200_000] if p.suffix.lower() in (".txt", ".md") else None})
            continue
        rel = str(p.relative_to(folder)).replace("\\", "/")
        sha = quick_sha(p) if fmt in ("csv", "tsv", "xlsx", "xlsm", "xls") else None
        if sha:
            loose_sha[sha] = rel
        items.append({"path": p, "rel": rel, "spec": match_spec(src, p.name), "from_zip": None})
    for z in sorted(folder.rglob("*.zip")):
        if "_unzipped" in z.parts:
            continue
        with zipfile.ZipFile(z) as zf:
            for m in zf.infolist():
                nm = Path(m.filename).name
                if m.is_dir() or "__MACOSX" in m.filename or not nm or nm.startswith("."):
                    continue
                fmt = guess_format(nm)
                low = nm.lower()
                if not fmt or IGNORE_NAME.match(nm):
                    text = None
                    if low.endswith((".txt", ".md")) and m.file_size < 400_000:
                        text = zf.read(m).decode("utf-8", "replace")
                    docs.append({"name": f"{z.name}:{m.filename}", "path": z, "text": text})
                    continue
                sha = None
                if fmt in ("csv", "tsv", "xlsx", "xlsm", "xls") and m.file_size <= SHA_LIMIT:
                    h = hashlib.sha256()
                    with zf.open(m) as fh:
                        for chunk in iter(lambda: fh.read(1 << 20), b""):
                            h.update(chunk)
                    sha = h.hexdigest()
                if sha and sha in loose_sha:
                    dups.append(f"{z.name}:{m.filename} identik dengan {loose_sha[sha]} (dilewati)")
                    continue
                dest = folder / "_unzipped" / ascii_slug(z.stem, 50) / m.filename
                if not dest.exists():
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    with zf.open(m) as src_f, open(dest, "wb") as out:
                        shutil.copyfileobj(src_f, out)
                items.append({"path": dest, "rel": f"{z.name}!{m.filename}", "spec": match_spec(src, nm), "from_zip": z.name})
    return items, docs, dups


# ----------------------------------------------------------------------------- pembaca
def sniff_sep(head):
    try:
        return csv.Sniffer().sniff(head, delimiters=",;\t|").delimiter
    except csv.Error:
        return ","


def drop_unnamed(df, meta):
    bad = [c for c in df.columns if str(c).startswith("Unnamed:")]
    drop = [c for c in bad if df[c].isna().all()]
    keep_bad = [c for c in bad if c not in drop]
    if drop:
        meta["notes"].append(f"{len(drop)} kolom tanpa judul dan kosong seluruhnya dibuang (posisi: {', '.join(str(df.columns.get_loc(c) + 1) for c in drop)}).")
        df = df.drop(columns=drop)
    if keep_bad:
        df.columns = [f"kolom_{i + 1}" if c in keep_bad else c for i, c in enumerate(df.columns)]
        meta["notes"].append(f"{len(keep_bad)} kolom tanpa judul tetapi berisi data diberi nama kolom_N.")
    return df


def read_csv_generic(path, spec, cfg, meta):
    path = Path(path)
    maxr = int(cfg.get("max_rows") or DEFAULT_MAX_ROWS)
    enc = cfg.get("encoding") or "utf-8-sig"
    sep = cfg.get("sep") or "auto"
    sep = "\t" if sep == "tab" else sep
    opener = gzip.open if path.name.lower().endswith(".gz") else open
    with opener(path, "rb") as f:
        head = f.read(65536).decode(enc, errors="replace")
    if sep == "auto":
        sep = "\t" if path.suffix.lower() == ".tsv" else sniff_sep(head)
    lines = head.splitlines()
    first = lines[0] if lines else ""
    names, hdr = None, max(int(cfg.get("header_row") or 1) - 1, 0)
    if cfg.get("headerless_names") and not re.search(r"(^|[,;\t|])\s*mcc\s*($|[,;\t|])", first, re.I):
        names, hdr = cfg["headerless_names"][: first.count(sep) + 1], None
        meta["notes"].append("File tanpa baris header; nama kolom standar OpenCelliD dipakai.")
    kw = dict(sep=sep, dtype=str, keep_default_na=False, na_values=[""], nrows=maxr, header=hdr, low_memory=False, on_bad_lines="warn")
    if names:
        kw["names"] = names
    try:
        df = pd.read_csv(path, encoding=enc, **kw)
    except UnicodeDecodeError:
        enc = "latin-1"
        df = pd.read_csv(path, encoding=enc, **kw)
        meta["notes"].append("Encoding utf-8 gagal; dibaca sebagai latin-1. Periksa karakter khusus.")
    meta.update(encoding=enc, delimiter="TAB" if sep == "\t" else sep)
    if path.stat().st_size > COUNT_LIMIT_BYTES:
        total = None
        meta["notes"].append("File sangat besar: jumlah baris total tidak dihitung.")
    elif len(df) < maxr:
        total = len(df)
    else:
        total = count_lines(path) - (0 if hdr is None else 1 + hdr)
        meta["notes"].append(f"Hanya {maxr:,} baris pertama diprofil dari {total:,} (naikkan --max-rows bila memori cukup).")
    return stringify(drop_unnamed(df, meta), already_str=True), total


def detect_header_row(raw):
    counts = raw.notna().sum(axis=1).tolist()
    if not counts:
        return 0
    mx = max(counts)
    for i, c in enumerate(counts):
        if c >= max(2, 0.7 * mx):
            return i
    return 0


def read_xlsx(path, spec, cfg, meta):
    maxr = int(cfg.get("max_rows") or DEFAULT_MAX_ROWS)
    try:
        xls = pd.ExcelFile(path)
    except ImportError:
        sys.exit("Excel membutuhkan openpyxl (xlsx) atau xlrd (xls): pip install openpyxl xlrd")
    sheet = cfg.get("sheet") or xls.sheet_names[0]
    meta["sheet"] = sheet
    meta["notes"].append("Sheet tersedia: " + ", ".join(map(str, xls.sheet_names)))
    if cfg.get("header_row"):
        hdr = max(int(cfg["header_row"]) - 1, 0)
    else:
        hdr = detect_header_row(xls.parse(sheet_name=sheet, header=None, dtype=str, nrows=40))
        if hdr > 0:
            meta["notes"].append(f"Baris header terdeteksi otomatis: baris {hdr + 1}.")
    full = xls.parse(sheet_name=sheet, header=hdr, dtype=str).dropna(how="all").dropna(axis=1, how="all")
    foot = 0
    while len(full) > 0 and full.shape[1] > 2 and full.iloc[-1].notna().sum() == 1:
        full, foot = full.iloc[:-1], foot + 1
    if foot:
        meta["notes"].append(f"{foot} baris catatan kaki di akhir tabel dilewati.")
    return stringify(drop_unnamed(full, meta).head(maxr), already_str=True), len(full)


NUM_RE = re.compile(r"^-?\d+(?:\.\d+)?$")


def read_bps(path, spec, cfg, meta):
    """CSV ekspor BPS: baris judul, header 1-2 baris (baris tahun), baris data, baris total, catatan kaki."""
    enc = cfg.get("encoding") or "utf-8-sig"
    try:
        rows = list(csv.reader(open(path, encoding=enc, newline="")))
    except UnicodeDecodeError:
        rows = list(csv.reader(open(path, encoding="latin-1", newline="")))
        meta["notes"].append("Encoding latin-1.")
    width = max((len(r) for r in rows), default=0)
    rows = [r + [""] * (width - len(r)) for r in rows]
    isnum = lambda x: bool(NUM_RE.match(x.strip()))  # noqa: E731
    ds = next((i for i, r in enumerate(rows) if r[0].strip() and sum(isnum(x) for x in r[1:]) >= 2), None)
    if ds is None:
        sys.exit("Tidak ditemukan baris data numerik; periksa format file BPS ini.")
    hdr_rows = [i for i in range(max(0, ds - 3), ds) if sum(bool(x.strip()) for x in rows[i]) >= 2]
    hdr_rows = hdr_rows[-2:]
    de = ds
    while de < len(rows) and rows[de][0].strip() and sum(isnum(x) or x.strip().lower() in MISSING_TOK for x in rows[de][1:]) >= 2:
        de += 1
    nxt = next((r for r in rows[de:] if any(x.strip() for x in r)), None)
    if nxt is not None and nxt[0].strip() and not re.match(r"^(keterangan|catatan|sumber|note|source|\*|\d+\))", nxt[0].strip(), re.I):
        meta.setdefault("alerts", []).append(f"Baris tepat setelah tabel tidak dikenali sebagai catatan kaki ('{nxt[0].strip()[:40]}'): data mungkin terpotong; periksa file.")
    year_row = next((i for i in hdr_rows if sum(bool(re.fullmatch(r"\d{4}", x.strip())) for x in rows[i]) >= max(2, 0.5 * sum(bool(x.strip()) for x in rows[i]))), None)
    name_rows = [i for i in hdr_rows if i != year_row]
    names = []
    for j in range(width):
        parts = [rows[i][j].strip() for i in name_rows if rows[i][j].strip()]
        names.append(" ".join(parts) if parts else (cfg.get("first_col") or spec.get("first_col") or "kolom_1") if j == 0 else f"kolom_{j + 1}")
    data = rows[ds:de]
    df = pd.DataFrame(data, columns=dedupe(names)).replace({"": None})
    derived = []
    if year_row is not None:
        ys = {x.strip() for x in rows[year_row] if re.fullmatch(r"\d{4}", x.strip())}
        if len(ys) == 1:
            df["tahun"] = ys.pop()
            derived.append("tahun")
            meta["notes"].append(f"Kolom tahun diturunkan dari baris header {year_row + 1}.")
        else:
            meta["notes"].append(f"Baris header {year_row + 1} berisi beberapa tahun ({sorted(ys)}): format lebar-menurut-tahun; unpivot di staging.")
    elif spec.get("year_from_filename") or cfg.get("year_from_filename"):
        ym = re.findall(r"(20\d{2})", Path(path).stem)
        if ym:
            df["tahun"] = ym[-1]
            derived.append("tahun")
            meta["notes"].append(f"Kolom tahun diturunkan dari nama file ({ym[-1]}).")
    dropped = 0
    tot = [t.upper() for t in spec.get("drop_total", [])]
    if tot:
        mask = df.iloc[:, 0].astype(str).str.strip().str.upper().isin(tot)
        dropped = int(mask.sum())
        df = df[~mask]
        if dropped:
            meta["notes"].append(f"{dropped} baris total nasional ({', '.join(spec['drop_total'])}) dilewati; bukan data wilayah.")
    foot = [" ".join(r).strip() for r in rows[de:] if any(x.strip() for x in r)]
    if foot:
        snippet = re.sub(r"<[^>]+>", "", foot[1] if len(foot) > 1 else foot[0])[:110]
        meta["notes"].append(f"{len(foot)} baris catatan kaki setelah tabel diabaikan (mis. '{snippet}').")
    meta["notes"].append(f"Header memakai baris {', '.join(str(i + 1) for i in hdr_rows)}; data baris {ds + 1}-{de}.")
    meta["derived"] = derived
    return stringify(df.reset_index(drop=True), already_str=True), len(df)


def prune_sparse(df, meta, threshold=0.01, max_cols=60):
    if df.shape[1] <= max_cols or len(df) == 0:
        return df
    fill = df.notna().mean()
    keep = fill[fill >= threshold].index.tolist()
    dropped = [c for c in df.columns if c not in keep]
    if dropped:
        meta["notes"].append(f"{len(dropped)} kolom dengan isi < {threshold:.0%} tidak ditampilkan (mis. {', '.join(map(str, dropped[:6]))}); "
                             "kolom tersebut tetap ada di file sumber.")
    return df[keep]


def read_geojson(path, spec, cfg, meta):
    n_total = count_geojson_features(path)
    limit = None if n_total <= GEO_FULL_LIMIT else GEO_SAMPLE
    rows, types, acc, k = [], {}, [1e18, 1e18, -1e18, -1e18], 0
    for ft in iter_geojson_features(path, limit=limit):
        g = ft.get("geometry") or {}
        gt = g.get("type")
        types[gt] = types.get(gt, 0) + 1
        if k < GEO_BBOX_FEATURES and g.get("coordinates") is not None:
            walk_coords(g["coordinates"], acc)
        r = dict(ft.get("properties") or {})
        if g and not spec.get("role"):
            r["geom_geojson"] = json.dumps(g, separators=(",", ":"))
        if ft.get("id") is not None:
            r["_feature_id"] = ft["id"]
        r["_geometry_type"] = gt
        rows.append(r)
        k += 1
    with open(path, "rb") as f:
        head = f.read(4096).decode("utf-8", "replace")
    m = re.search(r'"crs"\s*:\s*\{.*?"name"\s*:\s*"([^"]+)"', head, re.S)
    meta["geo"] = {"types": types, "bbox": acc if acc[0] < 1e17 else None, "crs": m.group(1) if m else "(tidak dinyatakan; GeoJSON baku = WGS84)",
                   "n_features": n_total}
    meta["notes"].append("GeoJSON dibaca streaming: hanya atribut yang diprofil; geometri hanya dilaporkan jenis dan bounding box "
                         f"(dari {min(k, GEO_BBOX_FEATURES):,} fitur pertama).")
    if limit:
        meta["notes"].append(f"File besar ({n_total:,} fitur): atribut diprofil dari {k:,} fitur pertama.")
    df = pd.DataFrame(rows)
    df = stringify(df)
    if spec.get("sparse"):
        df = prune_sparse(df, meta)
    return df, n_total


def read_parquet(path, spec, cfg, meta):
    maxr = int(cfg.get("max_rows") or DEFAULT_MAX_ROWS)
    try:
        import pyarrow.parquet as pq
    except ImportError:
        sys.exit("Parquet membutuhkan pyarrow: pip install pyarrow")
    pf = pq.ParquetFile(path)
    total = pf.metadata.num_rows
    meta["parquet_schema"] = [(f.name, str(f.type)) for f in pf.schema_arrow]
    parts, got = [], 0
    for b in pf.iter_batches(batch_size=min(maxr, 65536)):
        parts.append(b.to_pandas())
        got += b.num_rows
        if got >= maxr:
            break
    df = pd.concat(parts, ignore_index=True).head(maxr) if parts else pd.DataFrame()
    if total > maxr:
        meta["notes"].append("Profil memakai baris pertama saja; saring file besar dengan 'prepare' agar relevan.")
    return stringify(df), total


def sibling(path, ext):
    for cand in (path.with_suffix(ext.lower()), path.with_suffix(ext.upper())):
        if cand.exists():
            return cand
    return None


def read_dbf(path, encoding, maxr):
    with open(path, "rb") as f:
        head = f.read(32)
        nrec = struct.unpack("<I", head[4:8])[0]
        hlen = struct.unpack("<H", head[8:10])[0]
        rlen = struct.unpack("<H", head[10:12])[0]
        fields = []
        while True:
            fd = f.read(32)
            if not fd or fd[0] == 0x0D:
                break
            fields.append((fd[:11].split(b"\x00")[0].decode("ascii", "ignore"), chr(fd[11]), fd[16], fd[17]))
        f.seek(hlen)
        rows = []
        for _ in range(min(nrec, maxr)):
            rec = f.read(rlen)
            if len(rec) < rlen:
                break
            if rec[:1] == b"*":
                continue
            pos, row = 1, []
            for _n, _t, flen, _d in fields:
                val = rec[pos:pos + flen].decode(encoding, "replace").strip()
                row.append(val if val != "" else None)
                pos += flen
            rows.append(row)
    return pd.DataFrame(rows, columns=[x[0] for x in fields]), nrec, fields


def read_shp(path, spec, cfg, meta):
    fmt = guess_format(path)
    dbf = Path(path) if fmt == "dbf" else sibling(Path(path), ".dbf")
    if dbf is None:
        sys.exit(f"File .dbf pendamping tidak ditemukan untuk {Path(path).name}")
    cpg = sibling(dbf, ".cpg")
    enc = cfg.get("encoding") or (cpg.read_text(errors="ignore").strip() if cpg else "") or "utf-8"
    df, nrec, fields = read_dbf(dbf, enc, int(cfg.get("max_rows") or DEFAULT_MAX_ROWS))
    meta["encoding"] = enc
    if fmt == "shp":
        with open(path, "rb") as f:
            h = f.read(100)
        stype = SHP_TYPES.get(struct.unpack("<i", h[32:36])[0], "?")
        prj = sibling(Path(path), ".prj")
        meta["geo"] = {"types": {stype: nrec}, "bbox": list(struct.unpack("<4d", h[36:68])), "n_features": nrec,
                       "crs": prj.read_text(errors="ignore").strip()[:90] if prj else "(tidak ada .prj)"}
    return stringify(df, already_str=True), nrec


def read_file(path, spec, cfg):
    path = Path(path)
    reader = spec.get("reader", "auto")
    fmt = guess_format(path)
    if reader == "auto":
        reader = {"csv": "csv", "tsv": "csv", "xlsx": "xlsx", "xls": "xlsx", "parquet": "parquet", "geojson": "geojson",
                  "json": "geojson", "shp": "shp", "dbf": "shp"}.get(fmt, "csv")
    meta = {"format": fmt, "reader": reader, "notes": [], "encoding": None, "delimiter": None, "sheet": None, "geo": None, "derived": []}
    if reader == "csv":
        df, total = read_csv_generic(path, spec, cfg, meta)
    elif reader == "xlsx":
        df, total = read_xlsx(path, spec, cfg, meta)
    elif reader == "bps":
        df, total = read_bps(path, spec, cfg, meta)
    elif reader == "geojson":
        df, total = read_geojson(path, spec, cfg, meta)
    elif reader == "parquet":
        df, total = read_parquet(path, spec, cfg, meta)
    elif reader == "shp":
        df, total = read_shp(path, spec, cfg, meta)
    else:
        sys.exit(f"Reader tidak dikenal: {reader}")
    if spec.get("filter"):
        col, val = spec["filter"]
        if col in df.columns:
            n0 = len(df)
            df = df[df[col].astype(str).str.strip() == val].reset_index(drop=True)
            meta["notes"].append(f"Disaring {col} = {val}: {n0:,} -> {len(df):,} baris (sisanya di luar cakupan proyek).")
            meta["filtered_from"] = n0
            total = len(df)
    return df, total, meta


# ----------------------------------------------------------------------------- profil kolom
DATE_RES = [re.compile(r"^\d{4}[-/]\d{1,2}[-/]\d{1,2}"), re.compile(r"^\d{1,2}[-/]\d{1,2}[-/]\d{2,4}"),
            re.compile(rf"^\d{{1,2}}[ \-/]({MONTHS})[a-z]*[ \-/]\d{{2,4}}", re.I),
            re.compile(rf"^({MONTHS})[a-z]* \d{{1,2}},? \d{{4}}", re.I)]
WKT_RE = r"^(?:MULTI)?(?:POINT|LINESTRING|POLYGON)\s*\(|^GEOMETRYCOLLECTION\s*\("
TZ_RE = r"(?:Z|[+-]\d{2}:?\d{2})$"
LAT_TOK = {"lat", "latitude", "lintang"}
LON_TOK = {"lon", "lng", "long", "longitude", "bujur"}
NOT_COORD_TOK = {"ms", "latency", "kbps", "mbps", "down", "up", "tests", "devices"}
EPOCH_NAME = re.compile(r"(created|updated|time|date|ts|epoch|timestamp)", re.I)


def coord_hint(name):
    toks = set(t for t in re.split(r"[^a-z0-9]+", name.lower()) if t)
    if toks & NOT_COORD_TOK:
        return None
    if toks & LAT_TOK:
        return "lat"
    if toks & LON_TOK:
        return "lon"
    return None


def profile_column(name, s, n_rows):
    blank = s.map(lambda v: v is None or (isinstance(v, str) and v.strip() == ""))
    raw_nn = s[~blank].astype(str)
    nn = raw_nn.str.strip()
    info = {"name": name, "nulls": int(n_rows - len(nn)), "null_pct": 0.0 if n_rows == 0 else 100.0 * (n_rows - len(nn)) / n_rows,
            "type": "text", "pg_type": "text", "distinct": 0, "min": None, "max": None, "examples": [], "warnings": [],
            "candidate_key": False, "hint": None, "years": None, "definition": None, "q": None}
    if len(nn) == 0:
        info.update(type="empty", warnings=["Kolom kosong seluruhnya."])
        return info
    info["distinct"] = int(nn.nunique())
    ws = int((raw_nn != nn).sum())
    if ws:
        info["warnings"].append(f"{ws:,} nilai punya spasi di awal/akhir (perlu TRIM)")
    tok = nn.str.lower().isin(NULL_TOKENS)
    nl = int(tok.sum())
    if nl:
        vals = ", ".join(f"'{v}'" for v in nn[tok].value_counts().head(3).index)
        info["warnings"].append(f"{nl:,} nilai berupa token kosong ({vals}) - jadikan NULL di staging")
    if info["distinct"] == 1 and len(nn) == n_rows:
        info["warnings"].append(f"kolom KONSTAN (selalu '{nn.iloc[0]}')")
    typed = nn[~tok] if nl < len(nn) else nn          # inferensi tipe tanpa token kosong
    num = pd.to_numeric(typed, errors="coerce")
    num_ratio = float(num.notna().mean())
    lead_zero = int(typed.str.match(r"^0\d+$").sum())
    dec_comma = float(typed.str.match(r"^-?\d+,\d+$").mean())

    if num_ratio >= 0.98 and lead_zero > 0:
        info["warnings"].append(f"{lead_zero:,} nilai berawalan nol (kode?) - simpan sebagai text")
    elif num_ratio >= 0.98:
        nums = num.dropna()
        sn = typed[num.notna()]
        is_int = not sn.str.contains(r"[.eE]", regex=True).any()
        info["min"], info["max"] = nums.min(), nums.max()
        zero_dec = False
        if not is_int and (nums % 1 == 0).all():
            dp = sn.str.extract(r"\.(\d+)$")[0].dropna()
            if len(dp) and dp.str.fullmatch(r"0+").all():
                is_int, zero_dec = True, True
        if is_int:
            digits = int(sn.str.lstrip("-").str.len().max())
            if digits >= 15:
                info["warnings"].append(f"ID numerik {digits} digit - simpan sebagai text (hindari kehilangan presisi)")
            else:
                info["type"] = "integer"
                info["pg_type"] = "bigint" if max(abs(nums.min()), abs(nums.max())) >= 2147483647 else "integer"
                if zero_dec:
                    info["hint"] = "bilangan bulat yang ditulis dengan '.0'"
                if info["distinct"] == 2 and set(nums.unique()) <= {0, 1}:
                    info["hint"] = "flag 0/1"
                lo, hi = nums.min(), nums.max()
                if EPOCH_NAME.search(name) and 315_532_800 <= lo and hi <= 4_102_444_800:
                    parsed = pd.to_datetime(nums, unit="s", utc=True)
                    info.update(type="epoch_seconds", pg_type="timestamptz", hint="epoch detik; to_timestamp(kolom)",
                                min=parsed.min().isoformat()[:19], max=parsed.max().isoformat()[:19])
                    info["years"] = {int(k): int(v) for k, v in parsed.dt.year.value_counts().sort_index().items()}
                elif re.search(r"(tahun|year)$", name, re.I) and 1900 <= lo and hi <= 2100:
                    info["years"] = {int(k): int(v) for k, v in nums.astype(int).value_counts().sort_index().items()}
                    info["hint"] = "tahun"
        else:
            info["type"], info["pg_type"] = "numeric", "numeric"
            dec = sn.str.extract(r"\.(\d+)")[0].dropna().str.len()
            if len(dec):
                info["hint"] = f"maks {int(dec.max())} digit desimal"
        if info["type"] in ("integer", "numeric"):
            q = nums.quantile([0.01, 0.5, 0.99])
            info["q"] = {"p01": float(q.iloc[0]), "p50": float(q.iloc[1]), "p99": float(q.iloc[2])}
            span = info["q"]["p99"] - info["q"]["p01"]
            if span > 0 and (float(nums.max()) - info["q"]["p99"] > 10 * span or info["q"]["p01"] - float(nums.min()) > 10 * span):
                info["warnings"].append(f"NILAI EKSTREM: min {float(nums.min()):g} / maks {float(nums.max()):g} vs p01-p99 = {info['q']['p01']:g}..{info['q']['p99']:g}")
    elif dec_comma >= 0.9:
        nums = pd.to_numeric(typed.str.replace(",", ".", regex=False), errors="coerce").dropna()
        info["type"], info["pg_type"] = "numeric_comma", "numeric"
        info["min"], info["max"] = nums.min(), nums.max()
        info["warnings"].append("KOMA sebagai pemisah desimal: gunakan REPLACE(kolom, ',', '.')::numeric")
    else:
        share = max(float(typed.str.match(r.pattern, case=False).mean()) for r in DATE_RES)
        if share >= 0.9:
            dayfirst = False
            sl = typed.str.extract(r"^(\d{1,2})[/-](\d{1,2})[/-]\d{2,4}")
            if sl[0].notna().mean() > 0.5:
                a_, b_ = pd.to_numeric(sl[0]), pd.to_numeric(sl[1])
                if (a_ > 12).any() and (b_ > 12).any():
                    info["warnings"].append("Format tanggal campuran dd/mm dan mm/dd")
                elif (a_ > 12).any():
                    dayfirst = True
                    info["warnings"].append("Format dd/mm/yyyy (day-first) terdeteksi; parse dengan format eksplisit")
                elif not (b_ > 12).any():
                    dayfirst = True
                    info["warnings"].append("dd/mm vs mm/dd tidak dapat dibedakan - ASUMSI dd/mm; konfirmasi ke sumber")
            parsed = pd.to_datetime(typed, errors="coerce", utc=True, dayfirst=dayfirst)
            if parsed.notna().mean() >= 0.98:
                has_time = typed.str.contains(r"\d:\d", regex=True).mean() > 0.5
                if has_time and (parsed.dt.hour.eq(0) & parsed.dt.minute.eq(0) & parsed.dt.second.eq(0)).all():
                    has_time = False
                    info["hint"] = "ada komponen jam tetapi selalu 00:00:00 (tanggal saja)"
                info["type"], info["pg_type"] = ("timestamp", "timestamptz") if has_time else ("date", "date")
                info["min"], info["max"] = parsed.min(), parsed.max()
                info["years"] = {int(k): int(v) for k, v in parsed.dt.year.value_counts().sort_index().items()}
                if has_time and typed.str.contains(TZ_RE, regex=True).mean() < 0.9:
                    info["warnings"].append("Zona waktu tidak eksplisit: tetapkan asumsi (UTC atau WIB)")
            else:
                info["warnings"].append("Mirip tanggal tetapi sebagian gagal diparse (format campuran?)")
        elif typed.str.match(WKT_RE, case=False).mean() >= 0.9:
            info["type"], info["pg_type"] = "geometry_wkt", "text"
            info["hint"] = "WKT; jadikan geometry(...,4326) di staging bila PostGIS aktif"
        elif typed.str.startswith('{"type"').mean() >= 0.9:
            info["type"], info["pg_type"] = "geometry_geojson", "text"
        elif set(typed.str.lower().unique()) <= {"true", "false", "t", "f", "yes", "no", "y", "n", "ya", "tidak"}:
            info["type"], info["pg_type"] = "boolean", "boolean"
    if info["type"] == "text":
        lens = nn.str.len()
        info["hint"] = (info["hint"] + "; " if info["hint"] else "") + f"panjang {int(lens.min())}-{int(lens.max())}"
        if 2 <= info["distinct"] <= 20000:
            nz = nn.str.upper().str.replace(r"\s+", " ", regex=True).str.strip().nunique()
            if nz < info["distinct"]:
                info["warnings"].append(f"{info['distinct'] - nz} nilai berbeda hanya karena huruf besar/kecil/spasi")
    ch = coord_hint(name)
    if ch and info["type"] in ("numeric", "numeric_comma") and info["min"] is not None:
        lim = 90 if ch == "lat" else 180
        info["hint"] = "lintang" if ch == "lat" else "bujur"
        info["pg_type"] = "numeric(10,7)"
        if float(info["min"]) < -lim or float(info["max"]) > lim:
            info["warnings"].append(f"Nilai di luar -{lim}..{lim} untuk kolom {info['hint']}")
    if info["type"] in ("integer", "text", "date", "timestamp") and info["nulls"] == 0 and info["distinct"] == len(nn):
        info["candidate_key"] = True
    if info["distinct"] <= 50 and info["type"] in ("text", "boolean", "integer"):
        info["examples"] = [f"{k} ({v})" for k, v in nn.value_counts().head(8).items()]
    else:
        info["examples"] = list(nn.drop_duplicates().head(3))
    for k in ("min", "max"):
        v = info[k]
        if v is None:
            continue
        if hasattr(v, "isoformat"):
            info[k] = v.isoformat()[: (10 if info["type"] == "date" else 19)]
        elif info["type"] in ("numeric", "numeric_comma"):
            info[k] = float(v)
        elif info["type"] == "integer":
            info[k] = int(v)
    return info


# ----------------------------------------------------------------------------- aturan domain, kunci, geo
def num_series(df, col):
    return pd.to_numeric(df[col].astype(str).str.strip().str.replace(",", ".", regex=False), errors="coerce")


def eval_rules(df, rules):
    out = []
    for r in rules or []:
        if "expr" in r:
            a, op, b = r["expr"]
            if a not in df.columns or b not in df.columns:
                continue
            xa, xb = num_series(df, a), num_series(df, b)
            valid = xa.notna() & xb.notna()
            ok = {"<=": xa <= xb, ">=": xa >= xb, "<": xa < xb, ">": xa > xb}[op]
            viol = valid & ~ok
            out.append({"label": r["label"], "target": a, "rule": f"{a} {op} {b}", "n_valid": int(valid.sum()), "n_viol": int(viol.sum()), "examples": []})
            continue
        targets = [c for c in df.columns if (re.search(r["col"], c) if r.get("cols_re") else c == r["col"])]
        for c in targets:
            x = num_series(df, c)
            valid = x.notna()
            lo, hi = r.get("min"), r.get("max")
            bad = pd.Series(False, index=x.index)
            if lo is not None:
                bad |= x < lo
            if hi is not None:
                bad |= x > hi
            bad &= valid
            ex = x[bad].abs().sort_values(ascending=False).head(3)
            ex = [float(x[i]) for i in ex.index]
            rule = f"{lo if lo is not None else '-inf'} <= {c} <= {hi if hi is not None else '+inf'}"
            out.append({"label": r["label"], "target": c, "rule": rule, "n_valid": int(valid.sum()), "n_viol": int(bad.sum()), "examples": ex})
            if r.get("integer"):
                frac = valid & (x % 1 != 0)
                exf = [float(v) for v in x[frac].head(3)]
                out.append({"label": "harus bilangan bulat (hitungan); pecahan = kemungkinan hasil imputasi/alokasi", "target": c, "rule": f"{c} bilangan bulat",
                            "n_valid": int(valid.sum()), "n_viol": int(frac.sum()), "examples": exf})
    return out


def check_keys(df, keys):
    out = []
    for combo in keys or []:
        miss = [k for k in combo if k not in df.columns]
        if miss:
            out.append({"cols": combo, "status": f"kolom tidak ada: {miss}", "dups": None, "nulls": None})
            continue
        sub = df[combo].apply(lambda col: col.map(lambda v: v.strip() if isinstance(v, str) else v))
        nulls = int(sub.isna().any(axis=1).sum())
        dups = int(sub.duplicated().sum())
        out.append({"cols": combo, "status": "UNIK" if dups == 0 and nulls == 0 else "TIDAK UNIK", "dups": dups, "nulls": nulls})
    return out


def find_composite_keys(df, cols, max_rows=100_000, limit_s=20):
    if len(df) == 0 or len(df) > max_rows or any(c["candidate_key"] for c in cols):
        return []
    dist = {c["name"]: c["distinct"] for c in cols}
    cand = [c["name"] for c in cols if c["null_pct"] <= 1.0 and c["distinct"] > 1 and c["type"] not in ("empty", "geometry_wkt", "geometry_geojson")]
    cand = sorted(cand, key=lambda n: -dist[n])[:12]
    if len(cand) < 2:
        return []
    d = df[cand].apply(lambda s: s.map(lambda v: v.strip() if isinstance(v, str) else v))
    found, t0 = [], time.time()
    for k in (2, 3):
        for combo in itertools.combinations(cand, k):
            if time.time() - t0 > limit_s:
                return found
            if any(set(f) <= set(combo) for f in found):
                continue
            if not d.duplicated(subset=list(combo)).any():
                found.append(list(combo))
                if len(found) >= 3:
                    return found
        if found:
            break
    return found


def geo_check(df, cols, bbox, geo=None):
    lat_min, lon_min, lat_max, lon_max = bbox
    out = {}
    latc = lonc = None
    if geo and geo[0] in df.columns and geo[1] in df.columns:
        latc, lonc = geo
    else:
        latc = next((c["name"] for c in cols if c["hint"] == "lintang"), None)
        lonc = next((c["name"] for c in cols if c["hint"] == "bujur"), None)
    if latc and lonc:
        lat, lon = num_series(df, latc), num_series(df, lonc)
        valid = lat.notna() & lon.notna()
        inside = lat.between(lat_min, lat_max) & lon.between(lon_min, lon_max)
        swapped = valid & ~inside & lon.between(lat_min, lat_max) & lat.between(lon_min, lon_max)
        out["point"] = {"lat_col": latc, "lon_col": lonc, "valid": int(valid.sum()), "outside": int((valid & ~inside).sum()), "swapped": int(swapped.sum())}
    wkt = next((c["name"] for c in cols if c["type"] == "geometry_wkt"), None)
    if wkt:
        smp = df[wkt].dropna().astype(str).head(3000)
        xy = smp.str.extract(r"\(\(?\s*(-?\d+\.?\d*)\s+(-?\d+\.?\d*)")
        lon, lat = pd.to_numeric(xy[0], errors="coerce"), pd.to_numeric(xy[1], errors="coerce")
        valid = lat.notna() & lon.notna()
        inside = lat.between(lat_min, lat_max) & lon.between(lon_min, lon_max)
        out["wkt"] = {"col": wkt, "valid": int(valid.sum()), "outside": int((valid & ~inside).sum())}
    return out or None


def osm_voltage_check(df):
    out = []
    if "voltage" in df.columns:
        v = df["voltage"].dropna().astype(str).str.strip()
        n = len(df)
        single = v.str.fullmatch(r"\d+")
        multi = v.str.contains(";")
        other = ~single & ~multi
        out.append(f"voltage: terisi {len(v):,} dari {n:,} ({100 * len(v) / max(n, 1):.0f}%); angka tunggal {int(single.sum()):,}; multi-nilai ';' {int(multi.sum()):,}; format lain {int(other.sum()):,}")
        mv = v.map(lambda s: max([int(x) for x in re.findall(r"\d{4,7}", s)] or [0]))
        out.append(f"voltage maks per gardu: >=150 kV {int((mv >= 150000).sum()):,}; 70-149 kV {int(((mv >= 70000) & (mv < 150000)).sum()):,}; <70 kV {int(((mv > 0) & (mv < 70000)).sum()):,}; tak terbaca {int((mv == 0).sum()):,}")
    if "operator" in df.columns:
        o = df["operator"].dropna().astype(str)
        out.append(f"operator: {o.nunique()} variasi penulisan; teratas: " + ", ".join(f"{k} ({v})" for k, v in o.value_counts().head(4).items()))
    return out


def parse_readme_fields(text):
    out = {}
    for m in re.finditer(r"^\s*[-*]\s*`([A-Za-z0-9_]+)`\s*(?:\(([^)]*)\))?\s*:\s*(.+)$", text, re.M):
        out[m.group(1)] = m.group(3).strip() + (f" [{m.group(2)}]" if m.group(2) else "")
    return out


def apply_definitions(res, defs):
    low = {k.lower(): v for k, v in (defs or {}).items()}
    for c in res["columns"]:
        d = (defs or {}).get(c["name"]) or low.get(c["name"].lower())
        if d:
            c["definition"] = d
            m = re.search(r"\[(float|double|integer|int|boolean|bool)\b", d, re.I)
            if m and m.group(1).lower() in ("float", "double") and c["type"] == "integer" and c["hint"] and c["hint"].startswith("bilangan bulat"):
                c.update(type="numeric", pg_type="numeric", hint="float menurut kamus data (nilai teramati bulat)")


def profile_file(src, item, cfg, bbox):
    path, rel, spec = item["path"], item["rel"], item["spec"]
    t0 = time.time()
    df, total, meta = read_file(path, spec, cfg)
    n = len(df)
    cols = [profile_column(c, df[c], n) for c in df.columns]
    for c in cols:
        if c["name"] in (spec.get("text_cols") or []) and c["type"] in ("integer", "numeric"):
            c.update(type="text", pg_type="text", hint="kode/ID: simpan sebagai text")
    used = set()
    for c in cols:
        c["target_name"] = snake(c["name"], used)
    stem = re.sub(r"\.(csv|tsv|txt|json|geojson|jsonl|parquet|xlsx|xlsm|xls|shp|dbf|gz)$", "", Path(rel.split("!")[-1]).name, flags=re.I)
    res = {
        "source_id": src, "rel": rel, "file_name": rel, "name": ascii_slug(stem, 28) or "data", "table_hint": spec.get("table"),
        "path": str(path), "size_bytes": Path(path).stat().st_size, "sha256": sha256(path), "total_rows": total, "profiled_rows": int(n),
        "n_columns": len(cols), "full_row_duplicates": int(df.duplicated().sum()) if 0 < n <= 1_000_000 else None,
        "meta": meta, "columns": cols, "keys": check_keys(df, spec.get("keys")), "composite_keys": [], "checks": [], "rules": [],
        "geo_check": None, "role": spec.get("role"), "expect_rows": spec.get("expect_rows"), "rows_tol": spec.get("rows_tol", 0),
        "spec_keys": spec.get("keys") or [], "elapsed": 0.0, "from_zip": item.get("from_zip"),
    }
    if not res["keys"]:
        res["composite_keys"] = find_composite_keys(df, cols)
    rules = list(spec.get("rules") or [])
    if spec.get("num_rule"):
        lo, hi = spec["num_rule"]
        skip = {"tahun", spec.get("first_col") or ""}
        for c in cols:
            if c["type"] in ("numeric", "integer") and c["name"] not in skip:
                rules.append(R(c["name"], lo, hi, f"indeks {lo}-{hi}"))
    res["rules"] = eval_rules(df, rules)
    res["geo_check"] = geo_check(df, cols, bbox, spec.get("geo"))
    if spec.get("custom") == "osm_voltage":
        res["checks"] += osm_voltage_check(df)
    res["spec_defs"] = spec.get("defs")
    apply_definitions(res, spec.get("defs"))
    # simpan kolom untuk probe relasi dan uji spasial
    res["_probe"] = {}
    for (psrc, frag), pcols in PROBE_COLS.items():
        if psrc == src and frag in rel.lower():
            for pc in pcols:
                if pc in df.columns:
                    res["_probe"][pc] = df[pc]
    res["_samples"] = build_samples(df)
    if spec.get("role") == "dictionary":
        lc = {c.lower(): c for c in df.columns}
        kcol = lc.get("column_name") or df.columns[0]
        dcol = next((lc[k] for k in ("description", "deskripsi", "definition") if k in lc), None)
        ucol = next((lc[k] for k in ("type_unit", "unit", "type") if k in lc), None)
        gcol = lc.get("group")
        dd = {}
        for _, row in df.iterrows():
            txt = (row[dcol] or "") if dcol else ""
            if ucol and row[ucol]:
                txt += f" [{row[ucol]}]"
            if gcol and row[gcol]:
                txt = f"({row[gcol]}) " + txt
            dd[str(row[kcol]).strip()] = txt.strip()
        res["_dict"] = dd
    res["_pts"] = None
    geo = spec.get("geo")
    if geo and geo[0] in df.columns and geo[1] in df.columns:
        pts = pd.DataFrame({"lat": num_series(df, geo[0]), "lon": num_series(df, geo[1])})
        mag = next((c for c in df.columns if c.lower() == "magnitude"), None)
        if mag:
            pts["mag"] = num_series(df, mag)
        res["_pts"] = pts.dropna(subset=["lat", "lon"])
    res["elapsed"] = round(time.time() - t0, 1)
    return res


# ----------------------------------------------------------------------------- probe relasi
def norm_name(s, level):
    s = unicodedata.normalize("NFKD", str(s)).encode("ascii", "ignore").decode().upper()
    s = re.sub(r"[^A-Z0-9 ]+", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    if re.fullmatch(r"(?:[A-Z] )+[A-Z]", s):
        s = s.replace(" ", "")
    if level == "kab":
        s = re.sub(r"\bKOTA ADMINISTRASI\b|\bKOTA ADM\b|\bKOTA\b", "KOTA", s)
        s = re.sub(r"\bKABUPATEN\b|\bKAB\b", " ", s)
    else:
        s = re.sub(r"\bPROVINSI\b|\bPROV\b", " ", s)
        s = re.sub(r"\bKEP\b", "KEPULAUAN", s)
        s = re.sub(r"\bNANGGROE ACEH DARUSSALAM\b|\bNAD\b", "ACEH", s)
        s = re.sub(r"\bDAERAH ISTIMEWA YOGYAKARTA\b|\bD I YOGYAKARTA\b", "DI YOGYAKARTA", s)
    return re.sub(r"\s+", " ", s).strip()


def find_series(results, ref):
    src, frag, col = ref[0], ref[1].lower(), ref[2]
    for r in results:
        if r["source_id"] == src and frag in r["rel"].lower() and col in r.get("_probe", {}):
            s = r["_probe"][col]
            if len(ref) > 3 and ref[3] == "after2":
                s = s.astype(str).str[2:]
            return s, r["rel"]
    return None, None


def run_probes(results):
    out = []
    for p in PROBES:
        res = {"id": p["id"], "kind": p["kind"], "desc": p["desc"], "ok": False, "lines": [], "flag": None,
               "lsrc": p["left"][0], "rsrc": p["right"][0], "both": p.get("both", False)}
        ls, lf = find_series(results, p["left"])
        rs, rf = find_series(results, p["right"])
        if ls is None or rs is None:
            res["lines"].append("dilewati: salah satu file belum tersedia/terprofil")
            out.append(res)
            continue
        res["ok"] = True
        ls = ls.dropna().astype(str).str.strip()
        rs = rs.dropna().astype(str).str.strip()
        if p["kind"] == "fk":
            L, Rr = set(ls), set(rs)
            inter = L & Rr
            rowcov = float(ls.isin(Rr).mean()) if len(ls) else 0.0
            res["lines"].append(f"kiri: {len(L):,} nilai unik; kanan: {len(Rr):,}; irisan: {len(inter):,}")
            res["lines"].append(f"cakupan baris kiri yang ada di kanan: {100 * rowcov:.1f}%; nilai unik kiri ada di kanan: {100 * len(inter) / max(len(L), 1):.1f}%; unik kanan ada di kiri: {100 * len(inter) / max(len(Rr), 1):.1f}%")
            only_l, only_r = sorted(L - Rr), sorted(Rr - L)
            if only_l:
                res["lines"].append(f"hanya di kiri ({len(only_l)}): {', '.join(only_l[:8])}")
            if only_r:
                res["lines"].append(f"hanya di kanan ({len(only_r)}): {', '.join(only_r[:8])}")
            res["rowcov"], res["n_only_l"], res["n_only_r"] = rowcov, len(only_l), len(only_r)
        elif p["kind"] == "code_name":
            lname = p["left"][3]
            rname = p["right"][3]
            ldf = pd.DataFrame({"c": find_series(results, p["left"])[0], "n": find_series(results, (p["left"][0], p["left"][1], lname))[0]}).dropna()
            rdf = pd.DataFrame({"c": find_series(results, p["right"])[0], "n": find_series(results, (p["right"][0], p["right"][1], rname))[0]}).dropna()
            rmap = {str(c).strip(): norm_name(n, "kab") for c, n in zip(rdf["c"], rdf["n"])}
            ldf["c"] = ldf["c"].astype(str).str.strip()
            has = ldf["c"].isin(rmap)
            ldf["eq"] = [norm_name(n, "kab").replace(" ", "") == rmap.get(c, "~").replace(" ", "") for c, n in zip(ldf["c"], ldf["n"])]
            n = len(ldf)
            res["lines"].append(f"baris dengan kode ada di kanan: {100 * has.mean():.1f}% ({int(has.sum()):,} dari {n:,})")
            eqr = float(ldf.loc[has, "eq"].mean()) if has.any() else 0.0
            res["lines"].append(f"di antara itu, nama SAMA dengan nama pada kode tersebut: {100 * eqr:.1f}%; nama BERBEDA: {100 * (1 - eqr):.1f}% ({int((has & ~ldf['eq']).sum()):,} baris)")
            bad = ldf[has & ~ldf["eq"]].groupby(["c", "n"]).size().sort_values(ascending=False).head(6)
            ex = [f"{c} '{nm}' (BPS: '{rmap[c]}'; {k:,} baris)" for (c, nm), k in bad.items()]
            if ex:
                res["lines"].append("contoh kode sama nama beda: " + " | ".join(ex))
            res["name_consistency"] = eqr
        else:
            lvl = p["level"]
            vc = ls.value_counts()
            ref = {}
            for v in rs.unique():
                ref.setdefault(norm_name(v, lvl), []).append(v)
            ref_ns = {k.replace(" ", ""): k for k in ref}
            matched, unmatched, amb = 0, [], 0
            mrows = 0
            for v, cnt in vc.items():
                k = norm_name(v, lvl)
                if k in ref or k.replace(" ", "") in ref_ns:
                    matched += 1
                    mrows += cnt
                    if k in ref and len(ref[k]) > 1:
                        amb += 1
                else:
                    unmatched.append((v, int(cnt)))
            res["lines"].append(f"nilai unik kiri: {len(vc):,}; cocok ke referensi: {matched:,} ({100 * matched / max(len(vc), 1):.1f}%); cakupan baris: {100 * mrows / max(len(ls), 1):.1f}%; referensi unik: {len(rs.unique()):,} (setelah normalisasi {len(ref):,})")
            if unmatched:
                un = sorted(unmatched, key=lambda x: -x[1])[:10]
                res["lines"].append(f"TIDAK cocok ({len(unmatched)}): " + "; ".join(f"{v} ({c:,})" for v, c in un))
            if amb:
                res["lines"].append(f"{amb} nama kiri cocok ke >1 nilai referensi (ambigu)")
            res["name_rowcov"], res["n_unmatched"] = mrows / max(len(ls), 1), len(unmatched)
        out.append(res)
    return out


# ----------------------------------------------------------------------------- uji spasial (opsional)
def spatial_probe(results, folder_by_src):
    try:
        import numpy as np
        import shapely
        from shapely.geometry import shape
    except ImportError:
        return None, "Lewati uji spasial: pasang shapely (pip install shapely)."
    adm2 = next((i for i in discover_items_cache.get("SRC-11", []) if re.search(r"idn_admin2", i["rel"], re.I)), None)
    if adm2 is None:
        return None, "Lewati uji spasial: file idn_admin2.geojson tidak ditemukan."
    geoms, codes, bad = [], [], []
    for ft in iter_geojson_features(adm2["path"]):
        g = shape(ft["geometry"])
        geoms.append(g)
        code = ft["properties"].get("adm2_pcode")
        codes.append(code)
        if not g.is_valid:
            bad.append(f"{code} ({ft['properties'].get('adm2_name')})")
    tree = shapely.STRtree(geoms)
    rows = []
    for r in results:
        pts = r.get("_pts")
        if pts is None or len(pts) == 0 or r["source_id"] == "SRC-11":
            continue
        subsets = [("semua titik", pts)]
        if "mag" in pts.columns:
            subsets.append(("magnitudo >= 5.0", pts[pts["mag"] >= 5.0]))
        for label, sub in subsets:
            if len(sub) == 0:
                continue
            p = shapely.points(sub["lon"].to_numpy(float), sub["lat"].to_numpy(float))
            hit = len(np.unique(tree.query(p, predicate="within")[0]))
            rows.append({"src": r["source_id"], "file": r["rel"], "subset": label, "n": len(sub), "inside": hit})
    return {"rows": rows, "invalid": bad, "n_poly": len(geoms)}, None


discover_items_cache = {}


# ----------------------------------------------------------------------------- kesiapan
def check_expectations(reg, results):
    names = [c["name"] for r in results for c in r["columns"]]
    out = []
    for label, rx in reg["expect"]:
        hits = sorted({n for n in names if rx.search(n)})
        out.append({"label": label, "found": bool(hits), "columns": hits[:4]})
    return out


def temporal_rows(results):
    rows = []
    for r in results:
        for c in r["columns"]:
            if c["years"]:
                ys = c["years"]
                rows.append({"src": r["source_id"], "file": r["rel"], "col": c["name"], "type": c["type"], "min": c["min"], "max": c["max"],
                             "n": sum(ys.values()), "years": ys})
    return rows


def readiness(src, results, exps, reg, probes, spatial, dups):
    if not results:
        return "MISSING", [f"Belum ada file tabular di folder {src}."]
    reasons, infos, block = [], [], False
    miss = [e["label"] for e in exps if not e["found"]]
    if miss:
        reasons.append("[kolom] Kolom yang diharapkan tidak ditemukan: " + ", ".join(miss))
        if len(miss) * 2 >= len(exps):
            block = True
    for d in dups:
        infos.append(f"(info) [duplikat] {d}")
    for r in results:
        tag = r["rel"]
        if r["full_row_duplicates"] and r["profiled_rows"] and r["full_row_duplicates"] / r["profiled_rows"] >= 0.005:
            reasons.append(f"[duplikat baris] {tag}: {r['full_row_duplicates']:,} baris duplikat penuh ({100 * r['full_row_duplicates'] / r['profiled_rows']:.1f}%); tentukan aturan dedup sebelum memilih kunci.")
        for al in r["meta"].get("alerts", []):
            reasons.append(f"[parser] {tag}: {al}")
        if r["total_rows"] == 0 or r["profiled_rows"] == 0:
            reasons.append(f"[baris] {tag}: 0 baris terbaca.")
            block = True
        if r["expect_rows"] and r["total_rows"] is not None and abs(r["total_rows"] - r["expect_rows"]) > r["rows_tol"]:
            reasons.append(f"[baris] {tag}: {r['total_rows']:,} baris, diharapkan {r['expect_rows']} (±{r['rows_tol']}).")
        for k in r["keys"]:
            if k["status"] != "UNIK":
                if k["dups"] is None:
                    reasons.append(f"[kunci] {tag}: {k['status']}")
                else:
                    reasons.append(f"[kunci] {tag}: kunci ({', '.join(k['cols'])}) TIDAK unik: {k['dups']:,} duplikat, {k['nulls']:,} baris ber-null.")
        for ru in r["rules"]:
            if ru["n_viol"]:
                pct = 100 * ru["n_viol"] / max(ru["n_valid"], 1)
                msg = f"[aturan domain] {tag}: {ru['label']} ({ru['rule']}): {ru['n_viol']:,} pelanggaran ({pct:.2f}%)"
                (reasons if pct >= 1.0 else infos).append(msg if pct >= 1.0 else "(info) " + msg)
        g = r.get("geo_check") or {}
        p = g.get("point")
        if p and p["valid"] and p["outside"] / p["valid"] > 0.01:
            reasons.append(f"[koordinat] {tag}: {p['outside']:,} dari {p['valid']:,} ({p['outside'] / p['valid']:.1%}) di luar bounding box Indonesia kasar.")
        elif p and p["outside"]:
            infos.append(f"(info) [koordinat] {tag}: {p['outside']:,} titik ({p['outside'] / p['valid']:.2%}) di luar bounding box Indonesia kasar.")
        if p and p["swapped"]:
            reasons.append(f"[koordinat] {tag}: {p['swapped']:,} kemungkinan tertukar lintang/bujur.")
        for c in r["columns"]:
            if any(w.startswith("NILAI EKSTREM") for w in c["warnings"]):
                infos.append(f"(info) [ekstrem] {tag}.{c['name']}: " + next(w for w in c["warnings"] if w.startswith("NILAI EKSTREM")))
    if reg.get("claim"):
        yrs = [int(y) for r in results for c in r["columns"] if c["years"] for y in c["years"]]
        if yrs:
            lo, hi = min(yrs), max(yrs)
            clo, chi = reg["claim"]
            if lo > clo or hi < chi:
                reasons.append(f"[rentang waktu] Rentang aktual {lo}-{hi} tidak mencakup rentang yang diklaim proposal ({clo}-{chi}).")
    return ("BLOCKED" if block else ("CHECK" if reasons else "READY")), reasons + infos




# ----------------------------------------------------------------------------- prepare / fetch (dipakai ulang dari v2)
def parse_bbox(txt):
    if not txt:
        return IDN_BBOX
    v = [float(x) for x in txt.split(",")]
    if len(v) != 4:
        sys.exit("--bbox harus 4 angka: lat_min,lon_min,lat_max,lon_max")
    return tuple(v)


def prepare_csv(inp, out, eq, bbox_cols, bbox, names, chunk):
    opener = gzip.open if str(inp).lower().endswith(".gz") else open
    with opener(inp, "rb") as f:
        head = f.read(65536).decode("utf-8-sig", errors="replace")
    try:
        sep = csv.Sniffer().sniff(head, delimiters=",;\t|").delimiter
    except csv.Error:
        sep = ","
    first = head.splitlines()[0] if head.splitlines() else ""
    use_names = names if (names and not re.search(r"(^|[,;\t|])\s*mcc\s*($|[,;\t|])", first, re.I)) else None
    if use_names:
        print("File tanpa header terdeteksi; nama kolom standar OpenCelliD dipakai.")
    reader = pd.read_csv(inp, sep=sep, dtype=str, keep_default_na=False, chunksize=chunk, header=None if use_names else 0,
                         names=use_names[: first.count(sep) + 1] if use_names else None, on_bad_lines="skip",
                         low_memory=False, encoding="utf-8-sig")
    lat_min, lon_min, lat_max, lon_max = bbox
    tin = tout = 0
    firstw = True
    for ch in reader:
        tin += len(ch)
        m = pd.Series(True, index=ch.index)
        for k, v in eq.items():
            if k not in ch.columns:
                sys.exit(f"Kolom '{k}' tidak ada. Kolom tersedia: {list(ch.columns)[:30]}")
            m &= ch[k].str.strip() == v
        if bbox_cols:
            lat = pd.to_numeric(ch[bbox_cols[0]].str.replace(",", ".", regex=False), errors="coerce")
            lon = pd.to_numeric(ch[bbox_cols[1]].str.replace(",", ".", regex=False), errors="coerce")
            m &= lat.between(lat_min, lat_max) & lon.between(lon_min, lon_max)
        sub = ch[m]
        tout += len(sub)
        sub.to_csv(out, mode="w" if firstw else "a", header=firstw, index=False)
        firstw = False
        if tin % (chunk * 10) == 0:
            print(f"  ... {tin:,} baris dibaca, {tout:,} lolos")
    return tin, tout


def prepare_parquet(inp, out, bbox, chunk):
    try:
        import pyarrow as pa
        import pyarrow.parquet as pq
    except ImportError:
        sys.exit("Parquet membutuhkan pyarrow: pip install --user pyarrow")
    lat_min, lon_min, lat_max, lon_max = bbox
    pf = pq.ParquetFile(inp)
    cols = set(pf.schema_arrow.names)
    use_xy = {"tile_x", "tile_y"} <= cols
    if not use_xy and "tile" not in cols:
        sys.exit("File tidak punya kolom tile_x/tile_y maupun tile (WKT); tidak dapat disaring per koordinat.")
    print("Koordinat dari kolom " + ("tile_x/tile_y" if use_xy else "tile (titik awal WKT)"))
    writer, tin, tout = None, 0, 0
    for batch in pf.iter_batches(batch_size=chunk):
        tbl = pa.Table.from_batches([batch])
        df = batch.to_pandas()
        if use_xy:
            lon, lat = pd.to_numeric(df["tile_x"], errors="coerce"), pd.to_numeric(df["tile_y"], errors="coerce")
        else:
            xy = df["tile"].astype(str).str.extract(r"\(\(?\s*(-?\d+\.?\d*)\s+(-?\d+\.?\d*)")
            lon, lat = pd.to_numeric(xy[0], errors="coerce"), pd.to_numeric(xy[1], errors="coerce")
        mask = (lat.between(lat_min, lat_max) & lon.between(lon_min, lon_max)).fillna(False).values
        tin += len(df)
        sub = tbl.filter(pa.array(mask))
        if sub.num_rows:
            if writer is None:
                writer = pq.ParquetWriter(out, sub.schema)
            writer.write_table(sub)
            tout += sub.num_rows
    if writer is None:
        pq.write_table(pa.Table.from_pylist([], schema=pf.schema_arrow), out)
    else:
        writer.close()
    return tin, tout


def cmd_prepare(a):
    inp, out = Path(a.input), Path(a.output)
    if not inp.exists():
        sys.exit(f"File tidak ditemukan: {inp}")
    bbox = parse_bbox(a.bbox)
    eq = {}
    for kv in a.eq or []:
        k, v = kv.split("=", 1)
        eq[k.strip()] = v.strip()
    bbox_cols = a.bbox_cols.split(",") if a.bbox_cols else None
    names = None
    if a.preset == "opencellid":
        eq.setdefault("mcc", "510")
        bbox_cols = bbox_cols or ["lat", "lon"]
        names = OCID_COLS
    elif a.preset == "gppd":
        eq.setdefault("country", "IDN")
    out.parent.mkdir(parents=True, exist_ok=True)
    fmt = guess_format(inp)
    print(f"Menyaring {inp.name} -> {out.name}  (filter: {eq or '-'}; bbox kolom: {bbox_cols or ('tile' if fmt == 'parquet' else '-')})")
    if fmt == "parquet":
        tin, tout = prepare_parquet(inp, out, bbox, a.chunksize)
    else:
        tin, tout = prepare_csv(inp, out, eq, bbox_cols, bbox, names, a.chunksize)
    print(f"Selesai: {tin:,} baris dibaca, {tout:,} baris Indonesia disimpan ({out}).")
    print("Catatan: bounding box bersifat kasar (mencakup sebagian negara tetangga); penyaringan akhir lewat spatial join di Fase 3.")


OVERPASS_QUERIES = {
    "substation": '[out:json][timeout:300];\narea["ISO3166-1"="ID"][admin_level=2]->.idn;\nnwr["power"="substation"](area.idn);\nout tags center;',
    "line": '[out:json][timeout:600];\narea["ISO3166-1"="ID"][admin_level=2]->.idn;\nway["power"="line"](area.idn);\nout tags center;',
}


def cmd_fetch(a):
    what = ["substation", "line"] if a.what == "both" else [a.what]
    outdir = Path(a.out_dir) if a.out_dir else Path(a.root) / "SRC-08"
    outdir.mkdir(parents=True, exist_ok=True)
    for w in what:
        q = OVERPASS_QUERIES[w]
        print(f"Overpass [{w}] -> {a.url}\n{q}\n(bisa memakan beberapa menit; jalankan seperlunya, server publik ber-rate-limit)")
        req = urllib.request.Request(a.url, data=urllib.parse.urlencode({"data": q}).encode(),
                                     headers={"User-Agent": "capstone-profile/" + VERSION})
        last = None
        for attempt in (1, 2, 3):
            try:
                with urllib.request.urlopen(req, timeout=a.timeout) as resp:
                    body = resp.read()
                break
            except Exception as e:  # noqa: BLE001
                last = e
                print(f"  percobaan {attempt} gagal: {type(e).__name__}: {e}")
                time.sleep(10 * attempt)
        else:
            sys.exit(f"Gagal mengunduh [{w}]: {last}")
        obj = json.loads(body.decode("utf-8"))
        stamp = (obj.get("osm3s") or {}).get("timestamp_osm_base", "")[:10].replace("-", "") or datetime.now().strftime("%Y%m%d")
        path = outdir / f"overpass_{w}_{stamp}.json"
        path.write_bytes(body)
        print(f"  tersimpan: {path} ({len(body) / 1e6:.2f} MB, {len(obj.get('elements', [])):,} elemen, snapshot OSM {stamp})")


# ----------------------------------------------------------------------------- keluaran
def build_samples(df):
    if len(df) == 0:
        return []
    picks = list(df.head(4).index)
    nulls = df.isna().sum(axis=1).sort_values(ascending=False)
    picks += [i for i in nulls.head(2).index if i not in picks]
    if len(df) > 20:
        picks += [i for i in df.sample(3, random_state=7).index if i not in picks]
    cols = list(df.columns)[:40]
    return [{"row": int(i) + 1, **{c: df.at[i, c] for c in cols}} for i in picks]


class _Lines:
    def __init__(self):
        self.lines = []

    def write(self, text):
        self.lines += [t for t in text.split("\n") if t != ""]


def years_compact(ys, maxn=40):
    items = sorted(ys.items())
    s = ", ".join(f"{k}:{v:,}" for k, v in items[:maxn])
    return s + (f" ... (+{len(items) - maxn} tahun)" if len(items) > maxn else "")


def to_markdown(res):
    meta = res["meta"]
    total = "tidak dihitung" if res["total_rows"] is None else f"{res['total_rows']:,}"
    part = "" if res["total_rows"] in (None, res["profiled_rows"]) else f" (profil memakai {res['profiled_rows']:,} baris)"
    dup = "-" if res["full_row_duplicates"] is None else f"{res['full_row_duplicates']:,}"
    L = [f"### {res['source_id']} / {res['rel']}" + (f"   [{res['role']}]" if res.get("role") else ""),
         f"- Format: {meta['format']} (reader: {meta['reader']})" + (f" | delimiter {meta['delimiter']}" if meta.get("delimiter") else "")
         + (f" | encoding {meta['encoding']}" if meta.get("encoding") else "") + (f" | sheet {meta['sheet']}" if meta.get("sheet") else "")
         + f" | {res['size_bytes']:,} byte",
         f"- SHA-256: `{res['sha256']}`",
         f"- Baris: {total}{part} | kolom: {res['n_columns']} | baris duplikat penuh: {dup}"]
    for k in res["keys"]:
        L.append(f"- Uji kunci ({', '.join(k['cols'])}): {k['status']}" + ("" if k["dups"] is None else f" ({k['dups']:,} duplikat, {k['nulls']:,} baris ber-null)"))
    if res["composite_keys"]:
        L.append("- Kunci komposit unik (terdeteksi otomatis, bukan keputusan): " + " | ".join("(" + ", ".join(k) + ")" for k in res["composite_keys"]))
    g = meta.get("geo")
    if g:
        bb = g.get("bbox")
        L.append(f"- Geometri: fitur {g.get('n_features', '?'):,}; jenis (sampel) {g['types']}; bbox [xmin,ymin,xmax,ymax] = {[round(x, 4) for x in bb] if bb else '-'}; CRS: {g['crs']}")
    gc = res.get("geo_check") or {}
    if gc.get("point"):
        p = gc["point"]
        L.append(f"- Koordinat ({p['lat_col']}, {p['lon_col']}): {p['valid']:,} valid; {p['outside']:,} di luar bounding box Indonesia kasar; {p['swapped']:,} kemungkinan tertukar")
    if gc.get("wkt"):
        w = gc["wkt"]
        L.append(f"- Geometri WKT ({w['col']}): {w['outside']:,} dari {w['valid']:,} titik awal di luar bounding box Indonesia kasar")
    for ch in res["checks"]:
        L.append(f"- {ch}")
    for note in meta["notes"]:
        L.append(f"- Catatan: {note}")
    for c in res["columns"]:
        if c["years"]:
            L.append(f"- Sebaran per tahun, kolom `{c['name']}` ({c['min']} s.d. {c['max']}): {years_compact(c['years'])}")
    if res["rules"]:
        L += ["", "Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:", "",
              "| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |", "|---|---|---|---|---|---|"]
        for ru in res["rules"]:
            L.append(f"| {md_cell(ru['label'], 40)}: `{md_cell(ru['rule'], 50)}` | {ru['target']} | {ru['n_valid']:,} | {ru['n_viol']:,} | "
                     f"{100 * ru['n_viol'] / max(ru['n_valid'], 1):.2f}% | {md_cell(', '.join(f'{x:g}' for x in ru['examples']), 40)} |")
    L += ["", "| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |",
          "|---|---|---|---|---|---|---|---|---|---|---|---|"]
    for i, c in enumerate(res["columns"][:150], 1):
        notes = list(c["warnings"]) + ([c["hint"]] if c["hint"] else []) + (["KANDIDAT KUNCI"] if c["candidate_key"] else [])
        L.append("| {} | {} | {} | {} | {} | {} | {} | {} | {} | {} | {} | {} |".format(
            i, md_cell(c["name"], 40), c["target_name"], c["type"], c["pg_type"], fmt_pct(c["null_pct"]), f"{c['distinct']:,}",
            md_cell(c["min"], 22), md_cell(c["max"], 22), md_cell("; ".join(map(str, c["examples"])), 70), md_cell(c["definition"], 110),
            md_cell("; ".join(notes), 160)))
    if len(res["columns"]) > 150:
        L.append(f"| ... | {len(res['columns']) - 150} kolom lain tidak ditampilkan | | | | | | | | | | |")
    if res.get("samples"):
        L += ["", "Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):", "", "```csv"]
        cn = [c for c in res["samples"][0].keys() if c != "row"]
        buf = _Lines()
        w = csv.writer(buf, lineterminator="\n")
        w.writerow(["row"] + cn)
        for smp in res["samples"]:
            w.writerow([smp["row"]] + [("" if smp.get(c) is None else str(smp[c])[:70]) for c in cn])
        L += buf.lines
        L.append("```")
    return "\n".join(L) + "\n"


def assign_tables(results):
    used, groups = {}, {}
    for res in results:
        m = re.search(r"(\d+)", res["source_id"])
        nn = m.group(1) if m else "xx"
        base = f"src_{nn}_{res['table_hint'] or res['name']}"[:55].strip("_")
        sig = (base, tuple(c["name"] for c in res["columns"]))
        if res["table_hint"] and base in groups:
            res["table"], res["group_first"] = base, False
            groups[base].append(res)
            continue
        cand, i = base, 2
        while cand in used:
            cand = f"{base[:50]}_{i}"
            i += 1
        used[cand] = sig
        res["table"], res["group_first"] = cand, True
        groups[cand] = [res]
    for res in results:
        res["group_n"] = len(groups[res["table"]])
        res["skip_ddl"] = bool(res.get("role")) or not res["group_first"]


def contract_rows(results):
    rows, counters = [], {}
    for res in results:
        if res["skip_ddl"]:
            continue
        m = re.search(r"(\d+)", res["source_id"])
        sid = m.group(1) if m else res["source_id"]
        dataset = res["rel"] + (f" (+{res['group_n'] - 1} file serupa)" if res["group_n"] > 1 else "")
        derived = set(res["meta"].get("derived", []))
        key_status = {tuple(k["cols"]): k["status"] for k in res["keys"]}
        for c in res["columns"]:
            counters[sid] = counters.get(sid, 0) + 1
            knr = None
            for combo in res["spec_keys"]:
                if c["name"] in combo:
                    st = key_status.get(tuple(combo), "")
                    ok = "terverifikasi unik" if st == "UNIK" else "TIDAK unik pada data - lihat profil"
                    knr = f"BUSINESS KEY; NOT NULL; {ok}" if len(combo) == 1 else f"BAGIAN business key komposit ({'+'.join(combo)}); {ok}"
                    break
            if knr is None:
                knr = ("UNIK (kandidat); NOT NULL" if c["candidate_key"] else ("NOT NULL" if c["nulls"] == 0 else f"NULLABLE ({fmt_pct(c['null_pct'])} null)"))
            if c["name"] in derived:
                knr = "TURUNAN (dibuat saat parsing); " + knr
            rule_txt = []
            for ru in res["rules"]:
                if ru["target"] == c["name"]:
                    rule_txt.append(f"{ru['rule']} ({ru['label']}); pelanggaran pada data: {ru['n_viol']:,} ({100 * ru['n_viol'] / max(ru['n_valid'], 1):.2f}%)")
            t = c["type"]
            if rule_txt:
                vr = "USULAN (konfirmasi pemilik data): " + " | ".join(rule_txt)
            elif t in ("integer", "numeric", "numeric_comma"):
                vr = f"AUTO-DRAFT: nilai teramati [{c['min']}, {c['max']}] - tetapkan batas bisnis"
            elif t in ("date", "timestamp", "epoch_seconds"):
                vr = f"AUTO-DRAFT: dalam [{c['min']}, {c['max']}] dan tidak di masa depan"
            elif t in ("text", "boolean") and 0 < c["distinct"] <= 12:
                vr = "AUTO-DRAFT: IN (" + " | ".join(re.sub(r" \(\d+\)$", "", e) for e in c["examples"]) + ")"
            else:
                vr = "AUTO-DRAFT: tentukan aturan (format/not empty)"
            rows.append({"Contract_ID": f"DC-{sid}-{counters[sid]:03d}", "Source_ID": res["source_id"], "Source_Dataset": dataset,
                         "Source_Field": c["name"], "Source_Type": t, "Target_Dataset": "", "Target_Field": "", "Target_Type": "",
                         "Key_Null_Rule": knr, "Business_Definition": c["definition"] or "", "Classification": "PUBLIC", "Validation_Rule": vr})
    return rows


META_COLS = ["    _batch_id   bigint      NOT NULL,           -- = ops.pipeline_runs.run_id",
             "    _src_id     text        NOT NULL DEFAULT '{src}',",
             "    _src_file   text        NOT NULL,",
             "    _row_no     bigint      NOT NULL,           -- nomor baris pada file sumber",
             "    _loaded_at  timestamptz NOT NULL DEFAULT now(),"]

TYPE_OVERRIDES = {
    "bps_kabkota_code": "text",
    "station_id": "text",
    "province_id": "text",
    "region_id": "text",
    "city_id": "text",
    "mcc": "text",
    "net": "text",
    "area": "text",
    "cell": "text",
    "quadkey": "text",
    "tile_x": "numeric",
    "tile_y": "numeric",
}

STG_GEOM_TYPES = {
    "src_01_bmkg_gempa": "geometry(Point, 4326)",
    "src_03_iklim_stasiun": "geometry(Point, 4326)",
    "src_05_opencellid": "geometry(Point, 4326)",
    "src_06_ookla_tiles": "geometry(Polygon, 4326)",
    "src_07_gppd": "geometry(Point, 4326)",
    "src_08_osm_gardu": "geometry(Point, 4326)",
    "src_11_adm1": "geometry(Geometry, 4326)",
    "src_11_adm2": "geometry(Geometry, 4326)",
}

def ddl_raw(results, schema):
    out = ["-- AUTO-DRAFT dari profile_sources.py v" + VERSION + ". Tinjau sebelum dijalankan.",
           "-- Raw = bentuk asli: semua kolom text. Tipe dibuat di staging.", f"CREATE SCHEMA IF NOT EXISTS {schema};", ""]
    for res in results:
        if res["skip_ddl"]:
            continue
        t = f"{schema}.{res['table']}"
        out.append(f"CREATE TABLE IF NOT EXISTS {t} (")
        out += [m.format(src=res["source_id"]) for m in META_COLS]
        out.append(",\n".join(f"    {c['target_name']} text" for c in res["columns"]) + ",")
        out.append("    PRIMARY KEY (_batch_id, _src_file, _row_no)")
        out.append(");")
        note = f"{res['source_id']} {res['name']}; contoh file {res['rel']}".replace("'", "''")
        out.append(f"COMMENT ON TABLE {t} IS '{note}';")
        for c in res["columns"]:
            out.append("COMMENT ON COLUMN {}.{} IS '{}';".format(t, c["target_name"], f"sumber: {c['name']}".replace("'", "''")))
        out.append("")
    return "\n".join(out)

def ddl_staging(results, schema):
    out = ["-- AUTO-DRAFT dari profile_sources.py v" + VERSION + ". Tipe berdasarkan inferensi data; verifikasi bersama pemilik data.",
           "-- Constraint NOT NULL/CHECK sengaja tidak dipasang: pelanggaran ditangani aturan DQ + karantina (Fase 4).",
           "-- Nama kolom staging = nama kolom raw. Nama KANONIK vault/mart ditetapkan di Data_Contract dan Mapping_Lineage.",
           f"CREATE SCHEMA IF NOT EXISTS {schema};", ""]
    for res in results:
        if res["skip_ddl"]:
            continue
        t = f"{schema}.{res['table']}"
        geom_type = STG_GEOM_TYPES.get(res["table"])
        col_defs = [
            f"    {c['target_name']} {TYPE_OVERRIDES.get(c['target_name'], c['pg_type'])}"
            for c in res["columns"]
        ]
        if geom_type:
            col_defs.append(f"    geom {geom_type}")
        out.append(f"CREATE TABLE IF NOT EXISTS {t} (")
        out += [m.format(src=res["source_id"]) for m in META_COLS]
        out.append(",\n".join(col_defs) + ",")
        out.append("    PRIMARY KEY (_batch_id, _src_file, _row_no)")
        out.append(");")
        if geom_type:
            out.append(f"CREATE INDEX IF NOT EXISTS idx_{schema}_{res['table']}_geom ON {t} USING GIST (geom);")
        for c in res["columns"]:
            parts = [f"sumber: {c['name']}", f"tipe terdeteksi: {c['type']}", f"null {fmt_pct(c['null_pct'])}"]
            if c["hint"]:
                parts.append(c["hint"])
            out.append("COMMENT ON COLUMN {}.{} IS '{}';".format(t, c["target_name"], "; ".join(parts).replace("'", "''")))
        out.append("")
    return "\n".join(out)


def manifest_sql(results):
    def q(v):
        return "NULL" if v is None else "'" + str(v).replace("'", "''") + "'"

    out = ["-- Bukti file sumber -> ops.source_file_manifest. Lengkapi file_url bila kosong dan downloaded_by sebelum dijalankan.", ""]
    for r in results:
        reg = SOURCES.get(r["source_id"], {})
        url = (reg.get("where") or [None])[0]
        rc = "NULL" if r["total_rows"] is None else str(int(r["total_rows"]))
        out.append("INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)\n"
                   f"VALUES ({q(r['source_id'])}, {q(r['rel'])}, {q(url)}, {q(r['sha256'])}, {r['size_bytes']}, {rc}, "
                   f"{q(reg.get('license'))}, '<ISI NAMA ANDA>')\nON CONFLICT DO NOTHING;")
    return "\n".join(out) + "\n"


def probe_md(probes):
    L = ["# Probe relasi antar-sumber", "", "Mengukur seberapa baik kunci dan nama wilayah dapat dihubungkan. Normalisasi nama: huruf besar, tanpa tanda baca, "
         "awalan KAB./KABUPATEN dibuang, KOTA dipertahankan; provinsi memakai alias (KEP.=KEPULAUAN, NAD=ACEH, dst.).", ""]
    for p in probes:
        L.append(f"## {p['id']} - {p['desc']}")
        L += [f"- {x}" for x in p["lines"]]
        L.append("")
    return "\n".join(L) + "\n"


def temporal_md(rows, claims):
    L = ["# Cakupan waktu per sumber", "", "| Sumber | File | Kolom | Awal | Akhir | Baris bertanggal |", "|---|---|---|---|---|---|"]
    for r in rows:
        L.append(f"| {r['src']} | {md_cell(r['file'], 45)} | {r['col']} | {r['min']} | {r['max']} | {r['n']:,} |")
    L += ["", "## Sebaran per tahun (jumlah baris)", ""]
    for r in rows:
        L.append(f"- **{r['src']} {md_cell(r['file'], 40)} / {r['col']}**: {years_compact(r['years'])}")
    if claims:
        L += ["", "## Klaim proposal vs data", ""] + [f"- {c}" for c in claims]
    return "\n".join(L) + "\n"


def spatial_md(sp):
    L = ["# Uji penugasan titik ke poligon ADM2 (SRC-11)", "", f"Poligon ADM2: {sp['n_poly']}. Poligon tidak valid menurut shapely ({len(sp['invalid'])}): "
         f"{', '.join(sp['invalid']) if sp['invalid'] else '-'} (gunakan ST_MakeValid di PostGIS).", "",
         "| Sumber | File | Himpunan | Titik | Di dalam poligon | % | Di luar |", "|---|---|---|---|---|---|---|"]
    for r in sp["rows"]:
        L.append(f"| {r['src']} | {md_cell(r['file'], 40)} | {r['subset']} | {r['n']:,} | {r['inside']:,} | {100 * r['inside'] / r['n']:.1f}% | {r['n'] - r['inside']:,} |")
    L += ["", "Titik di luar poligon bisa berada di laut (gempa), di wilayah tetangga, atau di tepi pantai yang tidak tertutup batas yang disederhanakan."]
    return "\n".join(L) + "\n"


def write_outputs(results, per_source, exps_by, ready_by, probes, spatial, sp_note, out_dir, raw_schema, stg_schema, pack_chars):
    out = Path(out_dir)
    (out / "profiles").mkdir(parents=True, exist_ok=True)
    assign_tables(results)
    seq = {}
    for res in results:
        seq[res["source_id"]] = seq.get(res["source_id"], 0) + 1
        tag = f"{res['source_id']}_{seq[res['source_id']]:02d}_{ascii_slug(res['rel'].split('!')[-1], 45)}"
        (out / "profiles" / f"{tag}_profile.md").write_text(to_markdown(res), encoding="utf-8")
        slim = {k: v for k, v in res.items() if not k.startswith("_") and k != "samples"}
        (out / "profiles" / f"{tag}_profile.json").write_text(json.dumps(slim, ensure_ascii=False, indent=2, default=str), encoding="utf-8")
    rows = contract_rows(results)
    with open(out / "data_contract_draft.csv", "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=CONTRACT_COLS)
        w.writeheader()
        w.writerows(rows)
    (out / "ddl_raw_draft.sql").write_text(ddl_raw(results, raw_schema), encoding="utf-8")
    (out / "ddl_staging_draft.sql").write_text(ddl_staging(results, stg_schema), encoding="utf-8")
    (out / "ops_manifest_inserts.sql").write_text(manifest_sql(results), encoding="utf-8")
    with open(out / "staging_column_map.csv", "w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(["source_id", "file", "table", "source_column", "db_column", "detected_type", "pg_type_suggestion", "null_pct", "distinct", "candidate_key", "definition", "warnings"])
        for r in results:
            for c in r["columns"]:
                w.writerow([r["source_id"], r["rel"], "" if r["skip_ddl"] else r["table"], c["name"], c["target_name"], c["type"], c["pg_type"], f"{c['null_pct']:.1f}",
                            c["distinct"], "Y" if c["candidate_key"] else "", c["definition"] or "", " | ".join(c["warnings"])])
    with open(out / "profile_summary.csv", "w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(["source_id", "file", "reader", "size_bytes", "total_rows", "profiled_rows", "n_columns", "column_warnings", "key_status", "table_raw", "table_staging", "role", "seconds"])
        for r in results:
            ks = "; ".join(f"{'+'.join(k['cols'])}={k['status']}" for k in r["keys"])
            w.writerow([r["source_id"], r["rel"], r["meta"]["reader"], r["size_bytes"], r["total_rows"], r["profiled_rows"], r["n_columns"], sum(len(c["warnings"]) for c in r["columns"]),
                        ks, "" if r["skip_ddl"] else f"{raw_schema}.{r['table']}", "" if r["skip_ddl"] else f"{stg_schema}.{r['table']}", r.get("role") or "", r["elapsed"]])
    trows = temporal_rows(results)
    claims = []
    for sid, reg in SOURCES.items():
        if reg.get("claim") and sid in per_source:
            yrs = [int(y) for r in per_source[sid]["files"] for c in r["columns"] if c["years"] for y in c["years"]]
            if yrs:
                lo, hi = min(yrs), max(yrs)
                claims.append(f"{sid}: proposal menyatakan {reg['claim'][0]}-{reg['claim'][1]}; data aktual {lo}-{hi}" + ("  <-- TIDAK SESUAI" if lo > reg["claim"][0] or hi < reg["claim"][1] else "  (sesuai)"))
    (out / "temporal_coverage.md").write_text(temporal_md(trows, claims), encoding="utf-8")
    (out / "relationship_probe.md").write_text(probe_md(probes), encoding="utf-8")
    (out / "PHASE2_DECISIONS.md").write_text(DECISIONS_TEMPLATE, encoding="utf-8")
    if spatial:
        (out / "spatial_probe.md").write_text(spatial_md(spatial), encoding="utf-8")

    R = ["# Laporan kesiapan sumber (SRC-01..SRC-12)", "", f"Dibuat: {datetime.now():%Y-%m-%d %H:%M} oleh profile_sources.py v{VERSION}", "",
         "| Sumber | Nama | File | Baris (total) | Status |", "|---|---|---|---|---|"]
    for sid, reg in SOURCES.items():
        if sid in ready_by:
            rs = per_source[sid]["files"]
            R.append(f"| {sid} | {reg['name']} | {len(rs)} | {sum(r['total_rows'] or 0 for r in rs):,} | **{ready_by[sid][0]}** |")
    R += ["", "## Temuan per sumber (urut: perlu tindakan, lalu info)", ""]
    for sid in SOURCES:
        if sid in ready_by and ready_by[sid][1]:
            R.append(f"**{sid}** ({ready_by[sid][0]})")
            R += [f"- {x}" for x in ready_by[sid][1]]
            R.append("")
    if claims:
        R += ["## Klaim proposal vs data aktual", ""] + [f"- {c}" for c in claims] + [""]
    if sp_note:
        R += [f"Catatan uji spasial: {sp_note}", ""]
    R.append("Catatan: bounding box Indonesia bersifat kasar (mencakup sebagian negara tetangga); penyaringan akhir memakai spatial join ke SRC-11.")
    (out / "readiness_report.md").write_text("\n".join(R) + "\n", encoding="utf-8")

    sections = []
    for sid, reg in SOURCES.items():
        if sid not in ready_by:
            continue
        status, reasons = ready_by[sid]
        ps = per_source[sid]
        S = [f"## {sid} - {reg['name']}", f"- Sumber: {' | '.join(reg['where'])}", f"- Lisensi: {reg['license']}", f"- Grain: {reg['grain']}",
             f"- Status kesiapan: **{status}**"]
        S += [f"  - {x}" for x in reasons]
        S.append("- Pemeriksaan kolom yang diharapkan: " + "; ".join(f"{e['label']}: " + ("ADA" if e["found"] else "TIDAK ADA") for e in exps_by[sid]))
        if ps["docs"]:
            S.append("- Dokumen pendamping (tidak dimuat sebagai data): " + ", ".join(d["name"] for d in ps["docs"][:8]))
        S.append("")
        S += [to_markdown(r) for r in ps["files"]]
        sections.append("\n".join(S))
    head1 = ["## Ringkasan kesiapan", "", "| Sumber | Status | File | Baris |", "|---|---|---|---|"] + [
        f"| {sid} | {ready_by[sid][0]} | {len(per_source[sid]['files'])} | {sum(r['total_rows'] or 0 for r in per_source[sid]['files']):,} |" for sid in SOURCES if sid in ready_by]
    head1 += ["", "## Cakupan waktu dan klaim proposal", ""] + [f"- {c}" for c in claims]
    head1 += ["", "## Relasi antar-sumber (ringkas; rinci di relationship_probe.md)", ""]
    for p in probes:
        if p["ok"]:
            head1.append(f"- **{p['id']}** {p['desc']}: " + " ; ".join(p["lines"][:3]))
    if spatial:
        head1 += ["", "## Penugasan titik ke poligon ADM2", "", "| Sumber | Himpunan | Titik | Di dalam % |", "|---|---|---|---|"]
        head1 += [f"| {r['src']} {md_cell(r['file'], 30)} | {r['subset']} | {r['n']:,} | {100 * r['inside'] / r['n']:.1f}% |" for r in spatial["rows"]]
        if spatial["invalid"]:
            head1.append(f"\nPoligon ADM2 tidak valid: {', '.join(spatial['invalid'])}")
    parts, cur, size = [], [], 0
    for s in sections:
        if cur and size + len(s) > pack_chars:
            parts.append("\n".join(cur))
            cur, size = [], 0
        cur.append(s)
        size += len(s)
    if cur:
        parts.append("\n".join(cur))
    for old in out.glob("ai_input_pack_part*.md"):
        old.unlink()
    for i, p in enumerate(parts, 1):
        head = [f"# AI INPUT PACK - bagian {i} dari {len(parts)} (profil sumber data capstone SRC-01..SRC-12)", "",
                f"Dibuat oleh profile_sources.py v{VERSION}. Semua angka berasal dari file sumber nyata, bukan asumsi.", "",
                "Cara membaca: 'Tipe terdeteksi' = heuristik dari data; 'Tipe PG (usulan)' hanya usulan staging; 'KANDIDAT KUNCI' = unik dan tidak null (belum tentu business key); "
                "'Aturan domain' = USULAN batas wajar yang diukur pada data (bukan keputusan); 'Definisi' dari kamus resmi bila ada, selain itu dari analisis.", ""]
        if i == 1:
            head += head1 + [""]
        (out / f"ai_input_pack_part{i:02d}.md").write_text("\n".join(head) + "\n" + p, encoding="utf-8")
    return len(rows), len(parts)


# ----------------------------------------------------------------------------- perintah
def readme_text(sid, reg):
    L = [f"{sid} - {reg['name']}", "=" * 60, "", "Ambil dari :"] + [f"  - {w}" for w in reg["where"]]
    L += ["", f"Lisensi    : {reg['license']}", f"Grain      : {reg['grain']}", "",
          "Letakkan file hasil unduhan di folder ini (ZIP boleh; isi yang belum ada sebagai file lepas diekstrak otomatis ke _unzipped/).", ""]
    return "\n".join(L)


def cmd_init(a):
    root = Path(a.root)
    root.mkdir(parents=True, exist_ok=True)
    for sid, reg in SOURCES.items():
        d = root / sid
        d.mkdir(exist_ok=True)
        (d / "README.txt").write_text(readme_text(sid, reg), encoding="utf-8")
    (root / ".gitignore").write_text("# data mentah tidak boleh masuk Git\n*\n!.gitignore\n!overrides.csv\n!*/\n!*/README.txt\n", encoding="utf-8")
    ov = root / "overrides.csv"
    if not ov.exists():
        ov.write_text("source_id,file,sep,sheet,header_row,encoding,max_rows\n", encoding="utf-8")
    dec = Path(a.decisions)
    if not dec.exists():
        dec.write_text(DECISIONS_TEMPLATE, encoding="utf-8")
    print(f"Struktur dibuat di {root}/ dan formulir keputusan {dec}.")


def cmd_decisions(a):
    dec = Path(a.out)
    if dec.exists() and not a.force:
        sys.exit(f"{dec} sudah ada (tambahkan --force untuk menimpa).")
    dec.write_text(DECISIONS_TEMPLATE, encoding="utf-8")
    print(f"Formulir keputusan desain ditulis: {dec}")


def cmd_status(a):
    dirs = find_source_dirs(a.root)
    if not dirs:
        sys.exit(f"Tidak ada folder SRC-xx di '{a.root}'. Gunakan --root untuk menunjuk folder induknya.")
    print(f"{'SRC':7s} {'file':>4s} {'ukuran':>10s}  isi")
    for sid in SOURCES:
        d = dirs.get(sid)
        if d is None:
            print(f"{sid:7s} {0:4d} {0:9.1f}M  FOLDER TIDAK ADA")
            continue
        items, docs, dups = discover(d, sid)
        size = sum(i["path"].stat().st_size for i in items)
        print(f"{sid:7s} {len(items):4d} {size / 1e6:9.1f}M  " + "; ".join(f"{Path(i['rel'].split('!')[-1]).name} ({i['path'].stat().st_size / 1e6:.1f} MB)" for i in items[:3]) + (" ..." if len(items) > 3 else ""))
        for x in dups:
            print(f"{'':7s}      duplikat: {x}")
        for dc in docs[:2]:
            print(f"{'':7s}      dokumen: {dc['name']}")


def load_overrides(root):
    out = {}
    for p in (Path(root) / "overrides.csv", Path("overrides.csv")):
        if p.exists():
            with open(p, newline="", encoding="utf-8-sig") as f:
                for r in csv.DictReader(f):
                    r = {k: (v or "").strip() for k, v in r.items() if k}
                    if r.get("source_id") and r.get("file"):
                        out[(r["source_id"].upper(), r["file"].replace("\\", "/").lower())] = {k: v for k, v in r.items() if v and k not in ("source_id", "file")}
    return out


def find_override(ov, sid, rel):
    base = rel.split("!")[-1]
    return ov.get((sid, rel.lower())) or ov.get((sid, base.lower())) or ov.get((sid, Path(base).name.lower())) or {}


def cmd_profile(a):
    root, out = Path(a.root), Path(a.out)
    dirs = find_source_dirs(root)
    if not dirs:
        sys.exit(f"Tidak ada folder SRC-xx di '{root}'. Gunakan --root untuk menunjuk folder induknya.")
    only = [s.strip().upper() for s in a.only.split(",")] if a.only else list(SOURCES)
    bbox = parse_bbox(a.bbox)
    ov = load_overrides(root)
    results, per_source, exps_by = [], {}, {}
    for sid in SOURCES:
        if sid not in only:
            continue
        d = dirs.get(sid)
        per_source[sid] = {"files": [], "docs": [], "dups": []}
        if d is None:
            exps_by[sid] = check_expectations(SOURCES[sid], [])
            continue
        items, docs, dups = discover(d, sid)
        discover_items_cache[sid] = items
        per_source[sid].update(docs=docs, dups=dups)
        for it in items:
            cfg = {"max_rows": a.max_rows}
            cfg.update(find_override(ov, sid, it["rel"]))
            if SOURCES[sid].get("headerless"):
                cfg.setdefault("headerless_names", SOURCES[sid]["headerless"])
            print(f"> {sid}  {it['rel']}", flush=True)
            try:
                res = profile_file(sid, it, cfg, bbox)
            except SystemExit as e:
                print(f"  ! dilewati: {e}")
                continue
            except MemoryError:
                print("  ! kehabisan memori; naikkan RAM atau turunkan --max-rows")
                continue
            except Exception as e:  # noqa: BLE001
                print(f"  ! gagal diprofil: {type(e).__name__}: {e}")
                continue
            res["samples"] = res.pop("_samples", None) or []
            total = "?" if res["total_rows"] is None else f"{res['total_rows']:,}"
            print(f"  {total} baris, {res['n_columns']} kolom, {sum(len(c['warnings']) for c in res['columns'])} peringatan, {res['elapsed']}s", flush=True)
            results.append(res)
            per_source[sid]["files"].append(res)
        # definisi dari kamus (file) atau README dalam ZIP
        dict_res = next((r for r in per_source[sid]["files"] if r.get("role") == "dictionary" and r.get("_dict")), None)
        for r in per_source[sid]["files"]:
            spec_df = next((it["spec"] for it in items if it["rel"] == r["rel"]), {})
            if spec_df.get("dict_file") and dict_res:
                apply_definitions(r, dict_res["_dict"])
            if spec_df.get("dict_from") == "readme":
                txt = next((dc["text"] for dc in docs if dc.get("text") and "readme" in dc["name"].lower()), None)
                if txt:
                    apply_definitions(r, parse_readme_fields(txt))
        exps_by[sid] = check_expectations(SOURCES[sid], per_source[sid]["files"])
    if not results:
        sys.exit("Tidak ada file yang berhasil diprofil.")
    probes = run_probes(results)
    spatial, sp_note = (None, None)
    if a.spatial:
        spatial, sp_note = spatial_probe(results, dirs)
        if sp_note:
            print(sp_note)
    ready_by = {sid: readiness(sid, per_source[sid]["files"], exps_by[sid], SOURCES[sid], probes, spatial, per_source[sid]["dups"]) for sid in per_source}
    # probe -> alasan kesiapan (sumber kiri)
    for p in probes:
        if not p["ok"]:
            continue
        for lsrc in {p.get("lsrc")} | ({p.get("rsrc")} if p.get("both") else set()):
            if lsrc not in ready_by or ready_by[lsrc][0] == "MISSING":
                continue
            st, rs = ready_by[lsrc]
            flag = None
            if p["kind"] == "code_name" and p.get("name_consistency", 1) < 0.95:
                flag = f"[relasi {p['id']}] {p['desc']}: hanya {100 * p['name_consistency']:.0f}% nama sama pada kode yang sama -> JANGAN pakai kode ini sebagai kunci."
            elif p["kind"] == "fk" and p.get("rowcov", 1) < 0.99:
                flag = f"[relasi {p['id']}] {p['desc']}: cakupan baris {100 * p['rowcov']:.1f}% (hanya-kiri {p['n_only_l']}, hanya-kanan {p['n_only_r']})."
            elif p["kind"] == "names" and p.get("name_rowcov", 1) < 0.99:
                flag = f"[relasi {p['id']}] {p['desc']}: nama cocok pada {100 * p['name_rowcov']:.1f}% baris; {p['n_unmatched']} nama perlu alias/crosswalk."
            if flag:
                ready_by[lsrc] = ("CHECK" if st == "READY" else st, [flag] + rs)
    nrows, nparts = write_outputs(results, per_source, exps_by, ready_by, probes, spatial, sp_note, out, a.raw_schema, a.stg_schema, a.pack_kb * 1000)
    print("\nRINGKASAN KESIAPAN")
    for sid in per_source:
        print(f"  {sid}  {ready_by[sid][0]:8s} {len(per_source[sid]['files'])} file")
    print(f"\nSelesai. Keluaran di {out}/ : {nparts} bagian ai_input_pack, readiness_report.md, relationship_probe.md, temporal_coverage.md, "
          f"data_contract_draft.csv ({nrows} baris), ddl_raw_draft.sql, ddl_staging_draft.sql, ops_manifest_inserts.sql, staging_column_map.csv, profile_summary.csv")


def main():
    ap = argparse.ArgumentParser(description="Profiling SRC-01..SRC-12 untuk Fase 2 (v3).")
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--root", default="data_raw", help="folder induk yang berisi folder SRC-01..SRC-12 (default: data_raw)")
    sub = ap.add_subparsers(dest="cmd")
    p = sub.add_parser("init", parents=[common], help="buat folder kosong + README + formulir keputusan")
    p.add_argument("--decisions", default="PHASE2_DECISIONS.md")
    sub.add_parser("status", parents=[common], help="cek isi folder tiap sumber")
    p = sub.add_parser("decisions", help="tulis formulir keputusan desain (PHASE2_DECISIONS.md)")
    p.add_argument("--out", default="PHASE2_DECISIONS.md")
    p.add_argument("--force", action="store_true")
    p = sub.add_parser("prepare", parents=[common], help="saring file besar ke Indonesia")
    p.add_argument("--in", dest="input", required=True)
    p.add_argument("--out", dest="output", required=True)
    p.add_argument("--preset", choices=["opencellid", "ookla", "gppd"])
    p.add_argument("--eq", action="append", help="KOLOM=NILAI (boleh berulang)")
    p.add_argument("--bbox-cols", help="LATKOL,LONKOL")
    p.add_argument("--bbox", help="lat_min,lon_min,lat_max,lon_max")
    p.add_argument("--chunksize", type=int, default=200_000)
    p = sub.add_parser("fetch-overpass", parents=[common], help="unduh data OSM listrik (SRC-08)")
    p.add_argument("--what", choices=["substation", "line", "both"], default="both")
    p.add_argument("--out-dir", help="default: <root>/SRC-08")
    p.add_argument("--url", default="https://overpass-api.de/api/interpreter")
    p.add_argument("--timeout", type=int, default=900)
    p = sub.add_parser("profile", parents=[common], help="profil semua file")
    p.add_argument("--out", default="profile_out")
    p.add_argument("--only", help="mis. SRC-01,SRC-11")
    p.add_argument("--max-rows", dest="max_rows", type=int, default=DEFAULT_MAX_ROWS)
    p.add_argument("--pack-kb", dest="pack_kb", type=int, default=PACK_CHARS // 1000)
    p.add_argument("--bbox", help="lat_min,lon_min,lat_max,lon_max")
    p.add_argument("--spatial", action="store_true", help="uji penugasan titik ke poligon ADM2 (butuh shapely)")
    p.add_argument("--raw-schema", default="raw")
    p.add_argument("--stg-schema", default="stg")
    a = ap.parse_args()
    {"init": cmd_init, "decisions": cmd_decisions, "status": cmd_status, "prepare": cmd_prepare, "fetch-overpass": cmd_fetch, "profile": cmd_profile}.get(a.cmd, lambda _a: ap.print_help())(a)


if __name__ == "__main__":
    main()
