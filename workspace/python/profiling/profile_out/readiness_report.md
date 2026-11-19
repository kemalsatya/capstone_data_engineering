# Laporan kesiapan sumber (SRC-01..SRC-12)

Dibuat: 2026-11-19 08:23 oleh profile_sources.py v3.0

| Sumber | Nama | File | Baris (total) | Status |
|---|---|---|---|---|
| SRC-01 | BMKG Earthquake Catalog 1998-2024 | 1 | 217,807 | **READY** |
| SRC-02 | Kejadian Bencana BNPB (Kaggle maudiana) | 1 | 28,773 | **CHECK** |
| SRC-03 | Iklim Harian BMKG (Kaggle greegtitan) | 3 | 589,491 | **CHECK** |
| SRC-04 | District-Level Geospatial & Socioeconomic Dataset (514 kab/kota) | 2 | 559 | **CHECK** |
| SRC-05 | OpenCelliD menara seluler MCC 510 | 1 | 66,059 | **READY** |
| SRC-06 | Ookla Open Data fixed tiles 2024 Q4 (Indonesia) | 1 | 229,305 | **READY** |
| SRC-07 | Global Power Plant Database v1.3.0 (WRI) | 1 | 178 | **READY** |
| SRC-08 | OpenStreetMap gardu induk (Overpass Turbo export) | 2 | 5,642 | **READY** |
| SRC-09 | Sebaran PoP ISP (Komdigi) | 1 | 34 | **READY** |
| SRC-10 | Komponen Penyusun Indeks Kualitas Lingkungan Hidup (BPS) | 4 | 152 | **CHECK** |
| SRC-11 | COD-AB Indonesia (OCHA/BPS via HDX) | 7 | 372,905 | **CHECK** |
| SRC-12 | Penduduk, Laju, Kepadatan menurut Provinsi (BPS) | 5 | 186 | **READY** |

## Temuan per sumber (urut: perlu tindakan, lalu info)

**SRC-01** (READY)
- (info) [koordinat] BMKG_Earthquake_Catalog.csv: 727 titik (0.33%) di luar bounding box Indonesia kasar.

**SRC-02** (CHECK)
- [relasi P6] Jika kode sama, apakah nama kab/kota juga sama? (menguji city_id BNPB): hanya 81% nama sama pada kode yang sama -> JANGAN pakai kode ini sebagai kunci.
- [duplikat baris] data_bencana.xlsx: 329 baris duplikat penuh (1.1%); tentukan aturan dedup sebelum memilih kunci.
- [aturan domain] data_bencana.xlsx: harus bilangan bulat (hitungan); pecahan = kemungkinan hasil imputasi/alokasi (death bilangan bulat): 12,729 pelanggaran (44.24%)
- [aturan domain] data_bencana.xlsx: harus bilangan bulat (hitungan); pecahan = kemungkinan hasil imputasi/alokasi (missing_person bilangan bulat): 8,364 pelanggaran (30.24%)
- [aturan domain] data_bencana.xlsx: harus bilangan bulat (hitungan); pecahan = kemungkinan hasil imputasi/alokasi (injured_person bilangan bulat): 12,226 pelanggaran (42.49%)
- [aturan domain] data_bencana.xlsx: harus bilangan bulat (hitungan); pecahan = kemungkinan hasil imputasi/alokasi (flooded_house bilangan bulat): 3,679 pelanggaran (13.30%)
- [rentang waktu] Rentang aktual 2018-2024 tidak mencakup rentang yang diklaim proposal (2010-2025).
- (info) [aturan domain] data_bencana.xlsx: harus bilangan bulat (hitungan); pecahan = kemungkinan hasil imputasi/alokasi (damaged_house bilangan bulat): 1 pelanggaran (0.00%)
- (info) [ekstrem] data_bencana.xlsx.death: NILAI EKSTREM: min 0 / maks 3624 vs p01-p99 = 0..4
- (info) [ekstrem] data_bencana.xlsx.missing_person: NILAI EKSTREM: min 0 / maks 570 vs p01-p99 = 0..0.0569948
- (info) [ekstrem] data_bencana.xlsx.injured_person: NILAI EKSTREM: min 0 / maks 11124 vs p01-p99 = 0..7
- (info) [ekstrem] data_bencana.xlsx.damaged_house: NILAI EKSTREM: min 0 / maks 72194 vs p01-p99 = 0..188.28
- (info) [ekstrem] data_bencana.xlsx.flooded_house: NILAI EKSTREM: min 0 / maks 104114 vs p01-p99 = 0..4577.62
- (info) [ekstrem] data_bencana.xlsx.damaged_facility: NILAI EKSTREM: min 0 / maks 2037 vs p01-p99 = 0..11

**SRC-03** (CHECK)
- [relasi P8] Wilayah stasiun -> SRC-04: nama cocok pada 96.9% baris; 4 nama perlu alias/crosswalk.
- (info) [aturan domain] climate_data.csv: suhu harian wajar (derajat C) (0 <= Tn <= 45): 2 pelanggaran (0.00%)
- (info) [aturan domain] climate_data.csv: suhu harian wajar (derajat C) (0 <= Tx <= 45): 15 pelanggaran (0.00%)
- (info) [aturan domain] climate_data.csv: suhu harian wajar (derajat C) (0 <= Tavg <= 45): 2 pelanggaran (0.00%)
- (info) [aturan domain] climate_data.csv: kelembapan 0-100 % (0 <= RH_avg <= 100): 7 pelanggaran (0.00%)
- (info) [aturan domain] climate_data.csv: curah hujan harian wajar (mm) (0 <= RR <= 500): 11 pelanggaran (0.00%)
- (info) [aturan domain] climate_data.csv: penyinaran 0-24 jam (0 <= ss <= 24): 21 pelanggaran (0.00%)
- (info) [aturan domain] climate_data.csv: kecepatan angin wajar (m/s) (0 <= ff_x <= 60): 51 pelanggaran (0.01%)
- (info) [aturan domain] climate_data.csv: kecepatan angin wajar (m/s) (0 <= ff_avg <= 60): 12 pelanggaran (0.00%)
- (info) [aturan domain] climate_data.csv: arah angin 0-360 derajat (0 <= ddd_x <= 360): 541 pelanggaran (0.09%)
- (info) [aturan domain] climate_data.csv: Tn <= Tx (Tn <= Tx): 530 pelanggaran (0.10%)
- (info) [aturan domain] climate_data.csv: Tn <= Tavg (Tn <= Tavg): 1,155 pelanggaran (0.22%)
- (info) [aturan domain] climate_data.csv: Tavg <= Tx (Tavg <= Tx): 808 pelanggaran (0.16%)
- (info) [ekstrem] climate_data.csv.Tn: NILAI EKSTREM: min 0 / maks 246 vs p01-p99 = 15..27
- (info) [ekstrem] climate_data.csv.Tx: NILAI EKSTREM: min 0 / maks 334 vs p01-p99 = 24.8..35.6
- (info) [ekstrem] climate_data.csv.Tavg: NILAI EKSTREM: min 0 / maks 141.6 vs p01-p99 = 19.7..30.1
- (info) [ekstrem] climate_data.csv.RH_avg: NILAI EKSTREM: min 24 / maks 7520 vs p01-p99 = 63..96
- (info) [ekstrem] climate_data.csv.RR: NILAI EKSTREM: min -1 / maks 1965.5 vs p01-p99 = 0..82.2
- (info) [ekstrem] climate_data.csv.ss: NILAI EKSTREM: min 0 / maks 705 vs p01-p99 = 0..10.8
- (info) [ekstrem] climate_data.csv.ff_x: NILAI EKSTREM: min 0 / maks 185 vs p01-p99 = 0..12
- (info) [ekstrem] climate_data.csv.ff_avg: NILAI EKSTREM: min 0 / maks 160 vs p01-p99 = 0..6

**SRC-04** (CHECK)
- [relasi P4] Kode BPS (SRC-04) <-> pcode ADM2 tanpa awalan ID (SRC-11): cakupan baris 94.9% (hanya-kiri 26, hanya-kanan 34).

**SRC-06** (READY)
- (info) [ekstrem] ookla_fixed_2024q4_indonesia.csv.avg_lat_ms: NILAI EKSTREM: min 0 / maks 1924 vs p01-p99 = 2..125
- (info) [ekstrem] ookla_fixed_2024q4_indonesia.csv.tests: NILAI EKSTREM: min 1 / maks 7284 vs p01-p99 = 1..294
- (info) [ekstrem] ookla_fixed_2024q4_indonesia.csv.devices: NILAI EKSTREM: min 1 / maks 1207 vs p01-p99 = 1..85

**SRC-07** (READY)
- (info) [duplikat] globalpowerplantdatabasev130.zip:global_power_plant_database.csv identik dengan global_power_plant_database.csv (dilewati)

**SRC-10** (CHECK)
- [rentang waktu] Rentang aktual 2021-2024 tidak mencakup rentang yang diklaim proposal (2019-2024).

**SRC-11** (CHECK)
- [relasi P9] Nama ADM2 (SRC-11) -> SRC-04: nama cocok pada 97.3% baris; 11 nama perlu alias/crosswalk.
- [relasi P4] Kode BPS (SRC-04) <-> pcode ADM2 tanpa awalan ID (SRC-11): cakupan baris 94.9% (hanya-kiri 26, hanya-kanan 34).
- [duplikat baris] idn_adminlines.geojson: 19,995 baris duplikat penuh (100.0%); tentukan aturan dedup sebelum memilih kunci.
- (info) [ekstrem] idn_admin4.geojson.area_sqkm: NILAI EKSTREM: min 6.029e-05 / maks 3363.81 vs p01-p99 = 0.200695..280.156
- (info) [ekstrem] idn_adminpoints.geojson.area_sqkm: NILAI EKSTREM: min 6.029e-05 / maks 1.89108e+06 vs p01-p99 = 0.246809..2697.88

## Klaim proposal vs data aktual

- SRC-01: proposal menyatakan 1998-2024; data aktual 1998-2024  (sesuai)
- SRC-02: proposal menyatakan 2010-2025; data aktual 2018-2024  <-- TIDAK SESUAI
- SRC-10: proposal menyatakan 2019-2024; data aktual 2021-2024  <-- TIDAK SESUAI

Catatan: bounding box Indonesia bersifat kasar (mencakup sebagian negara tetangga); penyaringan akhir memakai spatial join ke SRC-11.
