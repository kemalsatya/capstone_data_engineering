# Paket Mini-Sample Tersanitasi (DE Capstone)

Folder ini menyediakan cuplikan data tersanitasi dari seluruh **15 tabel `raw.*`** (12 sumber data `SRC-01` s.d. `SRC-12`) berukuran ringan untuk keperluan inspeksi struktur skema dan uji reproduksibilitas reviewer tanpa harus mengunduh 1,8 GB dataset mentah.

## Catatan Sanitasi & Lisensi
- Kolom `_src_file` disanitasi menjadi `SAMPLE_<table>.csv` (tidak mengandung path direktori lokal).
- Geometri poligon resolusi tinggi pada `src_11_adm1` dan `src_11_adm2` disederhanakan menggunakan `ST_Envelope` PostGIS agar ukuran berkas ringan namun tetap berformat GeoJSON valid.
- Tidak mengandung kredensial, data LABFIK non-sintetis, atau PII pribadi.
- Sampel `SRC-06` (Ookla) tetap tunduk pada lisensi **CC BY-NC-SA 4.0 (Non-Commercial)**.

## Daftar Berkas Sampel

| Tabel Raw | Nama Berkas | Jumlah Baris | Ukuran (KB) |
| :--- | :--- | ---: | ---: |
| `raw.src_01_bmkg_gempa` | `raw_csv/sample_src_01_bmkg_gempa.csv` | 100 | 15.22 |
| `raw.src_02_bnpb_bencana` | `raw_csv/sample_src_02_bnpb_bencana.csv` | 100 | 16.41 |
| `raw.src_03_iklim_harian` | `raw_csv/sample_src_03_iklim_harian.csv` | 100 | 13.55 |
| `raw.src_03_iklim_provinsi` | `raw_csv/sample_src_03_iklim_provinsi.csv` | 34 | 3.26 |
| `raw.src_03_iklim_stasiun` | `raw_csv/sample_src_03_iklim_stasiun.csv` | 50 | 7.77 |
| `raw.src_04_fitur_kabkota` | `raw_csv/sample_src_04_fitur_kabkota.csv` | 50 | 25.55 |
| `raw.src_05_opencellid` | `raw_csv/sample_src_05_opencellid.csv` | 100 | 15.14 |
| `raw.src_06_ookla_tiles` | `raw_csv/sample_src_06_ookla_tiles.csv` | 100 | 36.71 |
| `raw.src_07_gppd` | `raw_csv/sample_src_07_gppd.csv` | 50 | 16.78 |
| `raw.src_08_osm_gardu` | `raw_csv/sample_src_08_osm_gardu.csv` | 100 | 30.62 |
| `raw.src_09_pop_isp` | `raw_csv/sample_src_09_pop_isp.csv` | 34 | 4.21 |
| `raw.src_10_iklh_provinsi` | `raw_csv/sample_src_10_iklh_provinsi.csv` | 50 | 6.50 |
| `raw.src_11_adm1` | `raw_csv/sample_src_11_adm1.csv` | 10 | 3.44 |
| `raw.src_11_adm2` | `raw_csv/sample_src_11_adm2.csv` | 25 | 8.66 |
| `raw.src_12_penduduk_provinsi` | `raw_csv/sample_src_12_penduduk_provinsi.csv` | 50 | 6.40 |

**Total ukuran paket sampel:** `210.22 KB` (`0.205 MB`).
