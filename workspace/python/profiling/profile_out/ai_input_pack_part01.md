# AI INPUT PACK - bagian 1 dari 3 (profil sumber data capstone SRC-01..SRC-12)

Dibuat oleh profile_sources.py v3.0. Semua angka berasal dari file sumber nyata, bukan asumsi.

Cara membaca: 'Tipe terdeteksi' = heuristik dari data; 'Tipe PG (usulan)' hanya usulan staging; 'KANDIDAT KUNCI' = unik dan tidak null (belum tentu business key); 'Aturan domain' = USULAN batas wajar yang diukur pada data (bukan keputusan); 'Definisi' dari kamus resmi bila ada, selain itu dari analisis.

## Ringkasan kesiapan

| Sumber | Status | File | Baris |
|---|---|---|---|
| SRC-01 | READY | 1 | 217,807 |
| SRC-02 | CHECK | 1 | 28,773 |
| SRC-03 | CHECK | 3 | 589,491 |
| SRC-04 | CHECK | 2 | 559 |
| SRC-05 | READY | 1 | 66,059 |
| SRC-06 | READY | 1 | 229,305 |
| SRC-07 | READY | 1 | 178 |
| SRC-08 | READY | 2 | 5,642 |
| SRC-09 | READY | 1 | 34 |
| SRC-10 | CHECK | 4 | 152 |
| SRC-11 | CHECK | 7 | 372,905 |
| SRC-12 | READY | 5 | 186 |

## Cakupan waktu dan klaim proposal

- SRC-01: proposal menyatakan 1998-2024; data aktual 1998-2024  (sesuai)
- SRC-02: proposal menyatakan 2010-2025; data aktual 2018-2024  <-- TIDAK SESUAI
- SRC-10: proposal menyatakan 2019-2024; data aktual 2021-2024  <-- TIDAK SESUAI

## Relasi antar-sumber (ringkas; rinci di relationship_probe.md)

- **P1** Pengamatan harian -> detail stasiun: kiri: 173 nilai unik; kanan: 192; irisan: 173 ; cakupan baris kiri yang ada di kanan: 100.0%; nilai unik kiri ada di kanan: 100.0%; unik kanan ada di kiri: 90.1% ; hanya di kanan (19): 96003, 96004, 96013, 96743, 96859, 97074, 97094, 97116
- **P2** Stasiun -> provinsi (ID internal): kiri: 34 nilai unik; kanan: 34; irisan: 34 ; cakupan baris kiri yang ada di kanan: 100.0%; nilai unik kiri ada di kanan: 100.0%; unik kanan ada di kiri: 100.0%
- **P3** SRC-08: CSV atribut <-> GeoJSON (ID elemen OSM): kiri: 2,821 nilai unik; kanan: 2,821; irisan: 2,821 ; cakupan baris kiri yang ada di kanan: 100.0%; nilai unik kiri ada di kanan: 100.0%; unik kanan ada di kiri: 100.0%
- **P4** Kode BPS (SRC-04) <-> pcode ADM2 tanpa awalan ID (SRC-11): kiri: 514 nilai unik; kanan: 522; irisan: 488 ; cakupan baris kiri yang ada di kanan: 94.9%; nilai unik kiri ada di kanan: 94.9%; unik kanan ada di kiri: 93.5% ; hanya di kiri (26): 9201, 9202, 9203, 9204, 9205, 9271, 9501, 9502
- **P5** city_id BNPB -> kode BPS (SRC-04): kiri: 521 nilai unik; kanan: 514; irisan: 493 ; cakupan baris kiri yang ada di kanan: 99.1%; nilai unik kiri ada di kanan: 94.6%; unik kanan ada di kiri: 95.9% ; hanya di kiri (28): 1472, 6407, 6408, 7324, 9108, 9109, 9110, 9114
- **P6** Jika kode sama, apakah nama kab/kota juga sama? (menguji city_id BNPB): baris dengan kode ada di kanan: 99.1% (28,507 dari 28,773) ; di antara itu, nama SAMA dengan nama pada kode tersebut: 80.6%; nama BERBEDA: 19.4% (5,542 baris) ; contoh kode sama nama beda: 1305 'PADANG PARIAMAN' (BPS: 'TANAH DATAR'; 205 baris) | 2101 'BINTAN' (BPS: 'KARIMUN'; 174 baris) | 1106 'ACEH BESAR' (BPS: 'ACEH TENGAH'; 147 baris) | 1101 'ACEH SELATAN' (BPS: 'SIMEULUE'; 106 baris) | 1306 'AGAM' (BPS: 'PADANG PARIAMAN'; 101 baris) | 6503 'NUNUKAN' (BPS: 'TANA TIDUNG'; 98 baris)
- **P7** Nama kab/kota BNPB -> SRC-04: nilai unik kiri: 538; cocok ke referensi: 525 (97.6%); cakupan baris: 99.4%; referensi unik: 514 (setelah normalisasi 514) ; TIDAK cocok (13): PANGKAJENE KEPULAUAN (36); PASANGKAYU (29); KUTAI KERTANEGARA (25); KOTA MAKASSAR (16); SELAYAR (15); KOTA PADANG SIDEMPUAN (15); TOBA (12); KEPULAUAN SIAU TAGULANDANG BIARO (8); KEPULAUAN TANIMBAR (6); TOBA SAMOSIR (5)
- **P8** Wilayah stasiun -> SRC-04: nilai unik kiri: 150; cocok ke referensi: 146 (97.3%); cakupan baris: 96.9%; referensi unik: 514 (setelah normalisasi 514) ; TIDAK cocok (4): Kota Makassar (2); Kab Maluku Tenggara Barat (2); Kab. Pontianak (1); Kota Tangerang Selata (1)
- **P9** Nama ADM2 (SRC-11) -> SRC-04: nilai unik kiri: 519; cocok ke referensi: 508 (97.9%); cakupan baris: 97.3%; referensi unik: 514 (setelah normalisasi 514) ; TIDAK cocok (11): Danau (4); Mamuju Utara (1); Maluku Tenggara Barat (1); Mahakam Hulu (1); Wadung Kedungombo (1); Waduk Cirata (1); Toba Samosir (1); Danau Toba (1); Hutan (1); Kota Makassar (1)
- **P10** Provinsi BNPB -> SRC-04: nilai unik kiri: 40; cocok ke referensi: 40 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)
- **P11** Provinsi iklim -> SRC-04: nilai unik kiri: 34; cocok ke referensi: 34 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)
- **P12** Provinsi PoP ISP -> SRC-04: nilai unik kiri: 34; cocok ke referensi: 34 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)
- **P13** Provinsi IKLH -> SRC-04: nilai unik kiri: 38; cocok ke referensi: 38 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)
- **P14** Provinsi penduduk -> SRC-04: nilai unik kiri: 34; cocok ke referensi: 34 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)
- **P15** Provinsi ADM1 (SRC-11) -> SRC-04: nilai unik kiri: 34; cocok ke referensi: 34 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)

## SRC-01 - BMKG Earthquake Catalog 1998-2024
- Sumber: https://data.mendeley.com/datasets/zmzywny59b/1
- Lisensi: CC BY 4.0 (atribusi BMKG)
- Grain: titik: 1 baris = 1 kejadian gempa
- Status kesiapan: **READY**
  - (info) [koordinat] BMKG_Earthquake_Catalog.csv: 727 titik (0.33%) di luar bounding box Indonesia kasar.
- Pemeriksaan kolom yang diharapkan: ID kejadian: ADA; tanggal: ADA; lintang: ADA; bujur: ADA; magnitudo: ADA; kedalaman: ADA

### SRC-01 / BMKG_Earthquake_Catalog.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 18,974,206 byte
- SHA-256: `113afb060675f8d90e9ec3f4bcc8490a25aead2135a7a3636423a80143cf18c8`
- Baris: 217,807 | kolom: 11 | baris duplikat penuh: 0
- Uji kunci (Event ID): UNIK (0 duplikat, 0 baris ber-null)
- Koordinat (Latitude, Longitude): 217,807 valid; 727 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Catatan: 1 kolom tanpa judul dan kosong seluruhnya dibuang (posisi: 3).
- Sebaran per tahun, kolom `Date` (1998-01-09 s.d. 2024-12-31): 1998:99, 1999:82, 2000:81, 2001:93, 2002:88, 2003:65, 2004:107, 2005:318, 2006:212, 2007:465, 2008:820, 2009:4,209, 2010:6,585, 2011:5,095, 2012:7,394, 2013:4,870, 2014:5,804, 2015:6,351, 2016:7,778, 2017:10,206, 2018:9,166, 2019:21,051, 2020:21,532, 2021:12,071, 2022:29,460, 2023:27,618, 2024:36,187

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| magnitudo wajar: `0 <= Magnitude <= 10` | Magnitude | 217,807 | 0 | 0.00% |  |
| kedalaman wajar (km): `0 <= Depth (km) <= 800` | Depth (km) | 217,807 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | No | no | integer | integer | 0.0% | 217,807 | 1 | 221934 | 1; 2; 3 | Nomor urut baris pada katalog sumber (tidak berurutan penuh; bukan kunci) | KANDIDAT KUNCI |
| 2 | Event ID | event_id | text | text | 0.0% | 217,807 |  |  | BMKG-19980109094543-001; BMKG-19980112080550-001; BMKG-19980118120317… | ID kejadian BMKG berpola BMKG-yyyymmddhhmmss-nnn; kunci bisnis | panjang 23-23; KANDIDAT KUNCI |
| 3 | Date | date | date | date | 0.0% | 7,125 | 1998-01-09 | 2024-12-31 | 09-Jan-1998; 12-Jan-1998; 18-Jan-1998 | Tanggal kejadian (UTC), format dd-Mon-yyyy (bulan bahasa Inggris) |  |
| 4 | Time (UTC) | time_utc | text | text | 0.0% | 79,117 |  |  | 09:45:43; 08:05:50; 12:03:17 | Jam kejadian (UTC) hh:mm:ss | panjang 8-8 |
| 5 | Latitude | latitude | numeric | numeric(10,7) | 0.0% | 1,942 | -14.96 | 7.0 | -5.39; -3.04; -2.65 | Lintang episenter (derajat desimal, WGS84) | lintang |
| 6 | Longitude | longitude | numeric | numeric(10,7) | 0.0% | 4,793 | 94.0 | 142.0 | 126.17; 128.36; 132.13 | Bujur episenter (derajat desimal, WGS84) | bujur |
| 7 | Magnitude | magnitude | numeric | numeric | 0.0% | 74 | 0.2 | 7.9 | 4.1; 4.4; 4.8 | Magnitudo gempa | maks 1 digit desimal |
| 8 | Mag Type | mag_type | text | text | 0.0% | 13 |  |  | - (95455); MLv (60541); M (53244); mb (5980); Mw(mB) (1864); Mw (273)… | Jenis skala magnitudo (MLv, M, mb, Mw, ...); '-' = tidak tercatat | 95,455 nilai berupa token kosong ('-') - jadikan NULL di staging; 1 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 1-7 |
| 9 | Depth (km) | depth_km | integer | integer | 0.0% | 722 | 1 | 798 | 390; 100; 32 | Kedalaman hiposenter (km) |  |
| 10 | Source | source | text | text | 0.0% | 11 |  |  | NC (98979); RC_03 (28890); RC_04 (17252); RC_09 (15754); RC_02 (14998… | Kode jaringan/sumber data (NC, RC_xx) | panjang 2-5 |
| 11 | Source Event ID | source_event_id | text | text | 0.0% | 98,976 |  |  | -; bmg2009aahk; bmg2009aaku | ID kejadian pada sumber asal; '-' = tidak ada | 118,828 nilai berupa token kosong ('-') - jadikan NULL di staging; panjang 1-11 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,No,Event ID,Date,Time (UTC),Latitude,Longitude,Magnitude,Mag Type,Depth (km),Source,Source Event ID
1,1,BMKG-19980109094543-001,09-Jan-1998,09:45:43,-5.39,126.17,4.1,-,390,RC_09,-
2,2,BMKG-19980112080550-001,12-Jan-1998,08:05:50,-3.04,128.36,4.4,-,100,RC_09,-
3,3,BMKG-19980118120317-001,18-Jan-1998,12:03:17,-2.65,132.13,4.8,-,32,RC_09,-
4,4,BMKG-19980129150524-001,29-Jan-1998,15:05:24,6.76,127.28,3.8,mb,33,RC_04,-
22362,23134,BMKG-20120714033115-001,14-Jul-2012,03:31:15,-3.57,128.08,3.0,-,27,RC_09,-
95118,97872,BMKG-20200319050036-001,19-Mar-2020,05:00:36,-1.15,134.30,3.2,-,20,RC_05,-
30263,31419,BMKG-20131209150345-001,09-Dec-2013,15:03:45,-2.72,127.63,2.4,MLv,10,NC,bmg2013ybzw
```

## SRC-02 - Kejadian Bencana BNPB (Kaggle maudiana)
- Sumber: https://www.kaggle.com/datasets/maudiana/indonesia-natural-disaster-dataset-bnpb-records
- Lisensi: lihat panel License di halaman Kaggle (data asal BNPB)
- Grain: kejadian: 1 baris = 1 kejadian bencana per kab/kota per hari
- Status kesiapan: **CHECK**
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
- Pemeriksaan kolom yang diharapkan: tanggal: ADA; kabupaten/kota: ADA; provinsi: ADA; jenis bencana: ADA; korban: ADA

### SRC-02 / data_bencana.xlsx
- Format: xlsx (reader: xlsx) | sheet Sheet1 | 1,661,845 byte
- SHA-256: `d1823abb4081a3c3ca9b578506e5aa9f62b7e116bdf8ad87bb09d8a48cb50918`
- Baris: 28,773 | kolom: 12 | baris duplikat penuh: 329
- Catatan: Sheet tersedia: Sheet1
- Sebaran per tahun, kolom `date` (2018-01-01 s.d. 2024-05-21): 2018:3,522, 2019:3,874, 2020:4,949, 2021:6,235, 2022:3,724, 2023:5,615, 2024:854

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| tidak boleh negatif: `0 <= death <= +inf` | death | 28,772 | 0 | 0.00% |  |
| harus bilangan bulat (hitungan); pecaha…: `death bilangan bulat` | death | 28,772 | 12,729 | 44.24% | 0.0327553, 0.222073, 0.0346821 |
| tidak boleh negatif: `0 <= missing_person <= +inf` | missing_person | 27,659 | 0 | 0.00% |  |
| harus bilangan bulat (hitungan); pecaha…: `missing_person bilangan bulat` | missing_person | 27,659 | 8,364 | 30.24% | 0.00129562, 0.0209945, 0.0544407 |
| tidak boleh negatif: `0 <= injured_person <= +inf` | injured_person | 28,773 | 0 | 0.00% |  |
| harus bilangan bulat (hitungan); pecaha…: `injured_person bilangan bulat` | injured_person | 28,773 | 12,226 | 42.49% | 0.239527, 0.424833, 1.7233 |
| tidak boleh negatif: `0 <= damaged_house <= +inf` | damaged_house | 28,773 | 0 | 0.00% |  |
| harus bilangan bulat (hitungan); pecaha…: `damaged_house bilangan bulat` | damaged_house | 28,773 | 1 | 0.00% | 24.2767 |
| tidak boleh negatif: `0 <= flooded_house <= +inf` | flooded_house | 27,659 | 0 | 0.00% |  |
| harus bilangan bulat (hitungan); pecaha…: `flooded_house bilangan bulat` | flooded_house | 27,659 | 3,679 | 13.30% | 0.0035947, 0.0035947, 0.0035947 |
| tidak boleh negatif: `0 <= damaged_facility <= +inf` | damaged_facility | 28,773 | 0 | 0.00% |  |
| harus bilangan bulat (hitungan); pecaha…: `damaged_facility bilangan bulat` | damaged_facility | 28,773 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | city_id | city_id | integer | integer | 0.0% | 521 | 1101 | 9671 | 5310; 6311; 5103 | Kode kab/kota versi dataset BNPB. PERINGATAN: bukan kode BPS (tidak konsisten dengan nama kota pada sebagian … |  |
| 2 | date | date | date | date | 0.0% | 2,316 | 2018-01-01 | 2024-05-21 | 2018-01-01 00:00:00; 2018-01-02 00:00:00; 2018-01-03 00:00:00 | Tanggal kejadian bencana | ada komponen jam tetapi selalu 00:00:00 (tanggal saja) |
| 3 | disaster_type | disaster_type | text | text | 0.0% | 13 |  |  | BANJIR (8605); CUACA EKSTREM (7268); TANAH LONGSOR (5585); KEBAKARAN … | Jenis bencana | panjang 6-27 |
| 4 | city | city | text | text | 0.0% | 538 |  |  | MANGGARAI; BALANGAN; BADUNG | Nama kabupaten/kota (huruf besar; awalan KOTA dipertahankan) | 7 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 4-32 |
| 5 | province | province | text | text | 0.0% | 40 |  |  | JAWA BARAT (6159); JAWA TENGAH (4500); JAWA TIMUR (2388); ACEH (1548)… | Nama provinsi (variasi penulisan) | panjang 4-26 |
| 6 | cause | cause | text | text | 0.0% | 9,359 |  |  | Tidak diketahui; • Kemarau panjang; Akibat hujan dengan intensitas ti… | Penyebab kejadian | 375 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 5-32766 |
| 7 | death | death | numeric | numeric | 0.0% | 53 | 0.0 | 3624.0 | 0; 2; 1 | Jumlah korban meninggal | NILAI EKSTREM: min 0 / maks 3624 vs p01-p99 = 0..4; maks 17 digit desimal |
| 8 | missing_person | missing_person | numeric | numeric | 3.9% | 21 | 0.0 | 570.0 | 0; 1; 6 | Jumlah korban hilang | NILAI EKSTREM: min 0 / maks 570 vs p01-p99 = 0..0.0569948; maks 18 digit desimal |
| 9 | injured_person | injured_person | numeric | numeric | 0.0% | 86 | 0.0 | 11124.0 | 0; 1; 2 | Jumlah korban luka | NILAI EKSTREM: min 0 / maks 11124 vs p01-p99 = 0..7; maks 17 digit desimal |
| 10 | damaged_house | damaged_house | numeric | numeric | 0.0% | 423 | 0.0 | 72194.0 | 1; 0; 30 | Jumlah rumah rusak | NILAI EKSTREM: min 0 / maks 72194 vs p01-p99 = 0..188.28; maks 14 digit desimal |
| 11 | flooded_house | flooded_house | numeric | numeric | 3.9% | 1,660 | 0.0 | 104114.0 | 0; 25; 3 | Jumlah rumah terendam | NILAI EKSTREM: min 0 / maks 104114 vs p01-p99 = 0..4577.62; maks 18 digit desimal |
| 12 | damaged_facility | damaged_facility | integer | integer | 0.0% | 116 | 0 | 2037 | 0; 1; 4 | Jumlah fasilitas rusak | NILAI EKSTREM: min 0 / maks 2037 vs p01-p99 = 0..11 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,city_id,date,disaster_type,city,province,cause,death,missing_person,injured_person,damaged_house,flooded_house,damaged_facility
1,5310,2018-01-01 00:00:00,BANJIR,MANGGARAI,NUSA TENGGARA TIMUR,Tidak diketahui,0,0,0,1,0,0
2,6311,2018-01-01 00:00:00,BANJIR,BALANGAN,KALIMANTAN SELATAN,Tidak diketahui,0,0,0,0,25,0
3,5103,2018-01-01 00:00:00,BANJIR,BADUNG,BALI,Tidak diketahui,0,0,0,0,3,0
4,5106,2018-01-01 00:00:00,TANAH LONGSOR,BANGLI,BALI,Tidak diketahui,0,0,0,1,0,0
22080,3508,2022-12-04 00:00:00,LETUSAN GUNUNG API,LUMAJANG,JAWA TIMUR,● Awan Panas Guguran (APG) dari PPGA Gunung Semeru di Pos Gunung Sawur,,,10,0,,3
20336,1901,2022-05-26 00:00:00,PUTING BELIUNG,BANGKA,KEPULAUAN BANGKA BELITUNG,Dipicu oleh intensitas curah hujan yang cukup tinggi disertai angin ke,1.133333333333333,,1.883720930232558,2,,0
22858,7206,2023-02-02 00:00:00,BANJIR,MOROWALI,SULAWESI TENGAH,Curah Hujan yang tinggi,0.2576139670223084,0.05444069143651897,1.723295230587308,15,164,0
10231,7201,2020-06-23 00:00:00,BANJIR,BANGGAI,SULAWESI TENGAH,Intensitas hujan yang tinggi,0,0,0,0,194,1
9698,3201,2020-05-01 00:00:00,TANAH LONGSOR,BOGOR,JAWA BARAT,• Akibat hujan dengan intensitas tinggi,0,0,0,0,0,1
```

## SRC-03 - Iklim Harian BMKG (Kaggle greegtitan)
- Sumber: https://www.kaggle.com/datasets/greegtitan/indonesia-climate
- Lisensi: lihat panel License di halaman Kaggle (atribusi BMKG)
- Grain: stasiun-hari + tabel detail stasiun/provinsi
- Status kesiapan: **CHECK**
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
- Pemeriksaan kolom yang diharapkan: tanggal: ADA; stasiun: ADA; suhu rata-rata: ADA; curah hujan: ADA; kelembaban: ADA

### SRC-03 / climate_data.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 35,844,405 byte
- SHA-256: `27d07d8b92824d4619bbb835d4f5464e4d57971735d2df1890ab6e3ffa7f5f9b`
- Baris: 589,265 | kolom: 12 | baris duplikat penuh: 0
- Uji kunci (station_id, date): UNIK (0 duplikat, 0 baris ber-null)
- Sebaran per tahun, kolom `date` (2010-01-01 s.d. 2020-12-31): 2010:55,922, 2011:56,689, 2012:52,766, 2013:39,094, 2014:52,224, 2015:48,067, 2016:55,598, 2017:56,203, 2018:58,332, 2019:58,096, 2020:56,274

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| suhu harian wajar (derajat C): `0 <= Tn <= 45` | Tn | 565,882 | 2 | 0.00% | 246, 92 |
| suhu harian wajar (derajat C): `0 <= Tx <= 45` | Tx | 551,529 | 15 | 0.00% | 334, 330, 321.8 |
| suhu harian wajar (derajat C): `0 <= Tavg <= 45` | Tavg | 544,160 | 2 | 0.00% | 141.6, 141.5 |
| kelembapan 0-100 %: `0 <= RH_avg <= 100` | RH_avg | 541,083 | 7 | 0.00% | 7520, 5045, 2555 |
| curah hujan harian wajar (mm): `0 <= RR <= 500` | RR | 463,881 | 11 | 0.00% | 1965.5, 1460.5, 1442 |
| penyinaran 0-24 jam: `0 <= ss <= 24` | ss | 545,544 | 21 | 0.00% | 705, 303, 103 |
| kecepatan angin wajar (m/s): `0 <= ff_x <= 60` | ff_x | 579,051 | 51 | 0.01% | 185, 185, 185 |
| kecepatan angin wajar (m/s): `0 <= ff_avg <= 60` | ff_avg | 579,138 | 12 | 0.00% | 160, 118, 118 |
| arah angin 0-360 derajat: `0 <= ddd_x <= 360` | ddd_x | 576,137 | 541 | 0.09% | 931, 888, 888 |
| Tn <= Tx: `Tn <= Tx` | Tn | 533,523 | 530 | 0.10% |  |
| Tn <= Tavg: `Tn <= Tavg` | Tn | 524,801 | 1,155 | 0.22% |  |
| Tavg <= Tx: `Tavg <= Tx` | Tavg | 520,966 | 808 | 0.16% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | date | date | date | date | 0.0% | 4,018 | 2010-01-01 | 2020-12-31 | 01-01-2010; 02-01-2010; 03-01-2010 | Tanggal pengamatan (dd-mm-yyyy) | Format dd/mm/yyyy (day-first) terdeteksi; parse dengan format eksplisit |
| 2 | Tn | tn | numeric | numeric | 4.0% | 218 | 0.0 | 246.0 | 21.4; 21.0; 20.2 | Suhu minimum harian (derajat C) | NILAI EKSTREM: min 0 / maks 246 vs p01-p99 = 15..27; maks 1 digit desimal |
| 3 | Tx | tx | numeric | numeric | 6.4% | 254 | 0.0 | 334.0 | 30.2; 29.6; 26.8 | Suhu maksimum harian (derajat C) | NILAI EKSTREM: min 0 / maks 334 vs p01-p99 = 24.8..35.6; maks 1 digit desimal |
| 4 | Tavg | tavg | numeric | numeric | 7.7% | 202 | 0.0 | 141.6 | 27.1; 25.7; 24.5 | Suhu rata-rata harian (derajat C) | NILAI EKSTREM: min 0 / maks 141.6 vs p01-p99 = 19.7..30.1; maks 1 digit desimal |
| 5 | RH_avg | rh_avg | integer | integer | 8.2% | 81 | 24 | 7520 | 82.0; 95.0; 98.0 | Kelembapan relatif rata-rata (%) | NILAI EKSTREM: min 24 / maks 7520 vs p01-p99 = 63..96; bilangan bulat yang ditulis dengan '.0' |
| 6 | RR | rr | numeric | numeric | 21.3% | 1,734 | -1.0 | 1965.5 | 9.0; 24.0; 63.0 | Curah hujan harian (mm) | NILAI EKSTREM: min -1 / maks 1965.5 vs p01-p99 = 0..82.2; maks 1 digit desimal |
| 7 | ss | ss | numeric | numeric | 7.4% | 188 | 0.0 | 705.0 | 0.5; 0.2; 0.0 | Lama penyinaran matahari (jam) | NILAI EKSTREM: min 0 / maks 705 vs p01-p99 = 0..10.8; maks 1 digit desimal |
| 8 | ff_x | ff_x | integer | integer | 1.7% | 70 | 0 | 185 | 7.0; 6.0; 5.0 | Kecepatan angin maksimum (m/s) | NILAI EKSTREM: min 0 / maks 185 vs p01-p99 = 0..12; bilangan bulat yang ditulis dengan '.0' |
| 9 | ddd_x | ddd_x | integer | integer | 2.2% | 373 | 0 | 931 | 90.0; 225.0; 45.0 | Arah angin saat kecepatan maksimum (derajat) | bilangan bulat yang ditulis dengan '.0' |
| 10 | ff_avg | ff_avg | integer | integer | 1.7% | 57 | 0 | 160 | 5.0; 4.0; 3.0 | Kecepatan angin rata-rata (m/s) | NILAI EKSTREM: min 0 / maks 160 vs p01-p99 = 0..6; bilangan bulat yang ditulis dengan '.0' |
| 11 | ddd_car | ddd_car | text | text | 2.3% | 9 |  |  | N (196415); E (68585); W (60164); C (55370); S (51584); SE (50551); N… | Arah angin terbanyak (kardinal) | 432,118 nilai punya spasi di awal/akhir (perlu TRIM); panjang 1-2 |
| 12 | station_id | station_id | integer | integer | 0.0% | 173 | 96001 | 97980 | 96001; 96009; 96011 | ID stasiun BMKG (FK ke station_detail) |  |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,date,Tn,Tx,Tavg,RH_avg,RR,ss,ff_x,ddd_x,ff_avg,ddd_car,station_id
1,01-01-2010,21.4,30.2,27.1,82.0,9.0,0.5,7.0,90.0,5.0,E ,96001
2,02-01-2010,21.0,29.6,25.7,95.0,24.0,0.2,6.0,90.0,4.0,E ,96001
3,03-01-2010,20.2,26.8,24.5,98.0,63.0,0.0,5.0,90.0,4.0,E ,96001
4,04-01-2010,21.0,29.2,25.8,90.0,0.0,0.1,4.0,225.0,3.0,SW,96001
54374,20-02-2018,23.0,33.4,,,,,,,,,96077
53472,13-04-2015,23.0,33.1,,,,,,,,,96077
111416,02-11-2017,19.0,29.3,23.4,85.0,12.9,7.0,5.0,200.0,2.0,N ,96207
95867,06-06-2017,24.0,,26.8,87.0,0.0,8.4,3.0,220.0,0.0,N ,96171
29880,03-02-2017,,,26.1,88.0,0.0,8.1,5.0,340.0,2.0,N ,96035
```

### SRC-03 / province_detail.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 614 byte
- SHA-256: `54b4f3b291ba1809a50c2f6b6d05d70e70fc5bc1803c292a76d8f12541b1f8b8`
- Baris: 34 | kolom: 2 | baris duplikat penuh: 0
- Uji kunci (province_id): UNIK (0 duplikat, 0 baris ber-null)

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | province_id | province_id | integer | integer | 0.0% | 34 | 1 | 34 | 1 (1); 2 (1); 3 (1); 4 (1); 5 (1); 6 (1); 7 (1); 8 (1) | ID provinsi internal dataset (1..34) | KANDIDAT KUNCI |
| 2 | province_name | province_name | text | text | 0.0% | 34 |  |  | Nanggroe Aceh Darussalam (1); Sumatera Utara (1); Sumatera Barat (1);… | Nama provinsi (penamaan lama, 34 provinsi) | panjang 4-24; KANDIDAT KUNCI |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,province_id,province_name
1,1,Nanggroe Aceh Darussalam
2,2,Sumatera Utara
3,3,Sumatera Barat
4,4,Riau
21,21,Kalimantan Tengah
```

### SRC-03 / station_detail.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 14,985 byte
- SHA-256: `63e96ad743ebad6328628de0d4ff289678a78fdb3d88c6067fe5345dcb6d6d6c`
- Baris: 192 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (station_id): UNIK (0 duplikat, 0 baris ber-null)
- Koordinat (latitude, longitude): 192 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | station_id | station_id | integer | integer | 0.0% | 192 | 96001 | 97980 | 96001; 96003; 96004 | ID stasiun BMKG | KANDIDAT KUNCI |
| 2 | station_name | station_name | text | text | 0.0% | 192 |  |  | Stasiun Meteorologi Maimun Saleh; Balai Besar Meteorologi Klimatologi… | Nama stasiun | 4 nilai punya spasi di awal/akhir (perlu TRIM); panjang 22-62; KANDIDAT KUNCI |
| 3 | region_name | region_name | text | text | 0.0% | 150 |  |  | Kota Sabang; Kab. Badung; Kota Makassar | Nama kab/kota lokasi stasiun (berawalan Kab./Kota) | panjang 9-25 |
| 4 | latitude | latitude | numeric | numeric(10,7) | 0.0% | 187 | -10.76662 | 5.87655 | 5.87655; -8.7381; -5.14283 | Lintang stasiun | lintang |
| 5 | longitude | longitude | numeric | numeric(10,7) | 0.0% | 188 | 95.296 | 140.72 | 95.33785; 115.1786; 119.45227 | Bujur stasiun | bujur |
| 6 | region_id | region_id | integer | integer | 0.0% | 150 | 1 | 507 | 20; 272; 412 | ID wilayah internal dataset (bukan kode BPS) |  |
| 7 | province_id | province_id | integer | integer | 0.0% | 34 | 1 | 34 | 32 (15); 19 (13); 30 (11); 15 (11); 2 (10); 20 (8); 26 (7); 1 (7) | ID provinsi internal dataset (FK ke province_detail; bukan kode BPS) |  |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,station_id,station_name,region_name,latitude,longitude,region_id,province_id
1,96001,Stasiun Meteorologi Maimun Saleh,Kota Sabang,5.87655,95.33785,20,1
2,96003,Balai Besar Meteorologi Klimatologi  dan Geofisika Wilayah III,Kab. Badung,-8.7381,115.1786,272,17
3,96004,Balai Besar Meteorologi Klimatologi dan Geofisika Wilayah IV,Kota Makassar,-5.14283,119.45227,412,26
4,96009,Stasiun Meteorologi Malikussaleh,Kab. Aceh Utara,5.22869,96.94749,8,1
23,96107,Stasiun Klimatologi Riau,Kab. Kampar,0.407,101.217,76,4
159,97500,Stasiun Pemantau Atmosfer Global Puncak Vihara Klademak,Kota Sorong,-0.981,131.301,497,33
47,96293,Stasiun Meteorologi Maritim Panjang,Kota Bandar Lampung,-5.4721,105.321,136,8
```

## SRC-04 - District-Level Geospatial & Socioeconomic Dataset (514 kab/kota)
- Sumber: https://data.mendeley.com/datasets/xxx26vkpsb/1
- Lisensi: CC BY 4.0
- Grain: kabupaten/kota: 1 baris = 1 wilayah (514)
- Status kesiapan: **CHECK**
  - [relasi P4] Kode BPS (SRC-04) <-> pcode ADM2 tanpa awalan ID (SRC-11): cakupan baris 94.9% (hanya-kiri 26, hanya-kanan 34).
- Pemeriksaan kolom yang diharapkan: kode BPS: ADA; nama wilayah: ADA; provinsi: ADA; elevasi: ADA

### SRC-04 / data_dictionary.csv   [dictionary]
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 6,442 byte
- SHA-256: `39c8a1b4b1d981ad4802c24699365d88366dd2ff0cb7ac4369017d6b42e49bbc`
- Baris: 45 | kolom: 4 | baris duplikat penuh: 0
- Uji kunci (column_name): UNIK (0 duplikat, 0 baris ber-null)

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | column_name | column_name | text | text | 0.0% | 45 |  |  | bps_kabkota_code (1); kabkota_name (1); prov_name (1); shapeName (1);… |  | panjang 8-24; KANDIDAT KUNCI |
| 2 | type_unit | type_unit | text | text | 0.0% | 16 |  |  | float, percent (14); boolean (7); categorical (3); text (3); float, m… |  | panjang 4-41 |
| 3 | group | group_col | text | text | 0.0% | 12 |  |  | land cover (11); socioeconomic (6); data-quality flag (6); weather (5… |  | panjang 4-23 |
| 4 | description | description | text | text | 0.0% | 43 |  |  | True if the zonal-statistics pull returned no valid pixels for this d… |  | panjang 28-323 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,column_name,type_unit,group,description
1,bps_kabkota_code,integer,identifier,"Official BPS kode wilayah for the regency, resolved through the bounda"
2,kabkota_name,text,identifier,Regency/city name as recorded by BPS (matched_bps_name).
3,prov_name,text,identifier,"Province name, BPS naming, 38 distinct values."
4,shapeName,text,identifier,Regency name as recorded in the geoBoundaries ADM2 boundary layer (joi
21,pct_cropland,"float, percent",land cover,"Percent of district area classified as cropland, ESA WorldCover v200."
19,pct_shrubland,"float, percent",land cover,"Percent of district area classified as shrubland, ESA WorldCover v200."
14,ntl_no_data,boolean,data-quality flag,True if the zonal-statistics pull returned no valid pixels for this di
```

### SRC-04 / master_features_v4.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 222,578 byte
- SHA-256: `320d1eb62f0e828b03b1ed694943d1d534b36807edc538a566384e4eb201970f`
- Baris: 514 | kolom: 45 | baris duplikat penuh: 0
- Uji kunci (bps_kabkota_code): UNIK (0 duplikat, 0 baris ber-null)

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| indeks/persentase 0-100: `0 <= ipm_2023 <= 100` | ipm_2023 | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= ipm_2024 <= 100` | ipm_2024 | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= ppm_2023 <= 100` | ppm_2023 | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= ppm_2024 <= 100` | ppm_2024 | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_tree_cover <= 100` | pct_tree_cover | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_shrubland <= 100` | pct_shrubland | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_grassland <= 100` | pct_grassland | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_cropland <= 100` | pct_cropland | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_built_up <= 100` | pct_built_up | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_bare_sparse_veg <= 100` | pct_bare_sparse_veg | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_snow_ice <= 100` | pct_snow_ice | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_water <= 100` | pct_water | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_wetland <= 100` | pct_wetland | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_mangroves <= 100` | pct_mangroves | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_moss_lichen <= 100` | pct_moss_lichen | 514 | 0 | 0.00% |  |
| penduduk > 0: `1 <= population_2023 <= +inf` | population_2023 | 514 | 0 | 0.00% |  |
| penduduk > 0: `1 <= population_2024 <= +inf` | population_2024 | 514 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | bps_kabkota_code | bps_kabkota_code | integer | integer | 0.0% | 514 | 1101 | 9708 | 1107; 1112; 1108 | (identifier) Official BPS kode wilayah for the regency, resolved through the boundary-to-BPS crosswalk. [inte… | KANDIDAT KUNCI |
| 2 | kabkota_name | kabkota_name | text | text | 0.0% | 514 |  |  | Aceh Barat; Aceh Barat Daya; Aceh Besar | (identifier) Regency/city name as recorded by BPS (matched_bps_name). [text] | panjang 4-42; KANDIDAT KUNCI |
| 3 | prov_name | prov_name | text | text | 0.0% | 38 |  |  | Jawa Timur (38); Jawa Tengah (35); Sumatera Utara (33); Jawa Barat (2… | (identifier) Province name, BPS naming, 38 distinct values. [text] | panjang 4-20 |
| 4 | shapeName | shapename | text | text | 0.0% | 514 |  |  | Aceh Barat; Aceh Barat Daya; Aceh Besar | (identifier) Regency name as recorded in the geoBoundaries ADM2 boundary layer (join key used before the cros… | panjang 4-26; KANDIDAT KUNCI |
| 5 | crosswalk_match_type | crosswalk_match_type | text | text | 0.0% | 3 |  |  | exact (503); manual_alias (7); fuzzy (4) | (join-quality diagnostic) How this row's shapeName was matched to a BPS record: exact (n=503), manual_alias (… | panjang 5-12 |
| 6 | crosswalk_match_score | crosswalk_match_score | numeric | numeric | 0.0% | 5 | 0.941 | 1.0 | 1.0; 0.952; 0.941 | (join-quality diagnostic) String-similarity score of the match. 1.0 for exact and manual_alias rows; 0.82-1.0… | maks 3 digit desimal |
| 7 | ipm_2023 | ipm_2023 | numeric | numeric | 0.0% | 450 | 35.19 | 88.28 | 72.88; 68.07; 74.53 | (socioeconomic) Human Development Index (IPM), 2023, BPS Web API var_id 413 (new methodology series). [float,… | maks 2 digit desimal |
| 8 | ipm_2024 | ipm_2024 | numeric | numeric | 0.0% | 444 | 36.3 | 88.77 | 73.69; 68.75; 75.13 | (socioeconomic) Human Development Index (IPM), 2024, BPS Web API var_id 413. [float, index 0-100] | maks 2 digit desimal |
| 9 | ppm_2023 | ppm_2023 | numeric | numeric | 0.0% | 455 | 2.27 | 40.01 | 17.86; 15.43; 13.38 | (socioeconomic) Poverty rate (persentase penduduk miskin), 2023, BPS Web API. [float, percent] | maks 2 digit desimal |
| 10 | ppm_2024 | ppm_2024 | numeric | numeric | 0.0% | 450 | 2.23 | 41.42 | 17.6; 15.32; 13.21 | (socioeconomic) Poverty rate, 2024, BPS Web API. [float, percent] | maks 2 digit desimal |
| 11 | population_2023 | population_2023 | integer | integer | 0.0% | 514 | 24013 | 5627021 | 204768; 156990; 422373 | (socioeconomic) Total population, 2023, BPS. [integer, persons] | KANDIDAT KUNCI |
| 12 | population_2024 | population_2024 | integer | integer | 0.0% | 513 | 24527 | 5682303 | 206822; 159187; 428254 | (socioeconomic) Total population, 2024, BPS. [integer, persons] |  |
| 13 | ntl_radiance_mean | ntl_radiance_mean | numeric | numeric | 0.0% | 514 | 0.1467609274544659 | 63.87838706280524 | 0.4590617028527347; 0.3856696161413696; 1.116737214742774 | (nighttime lights) Zonal mean VIIRS Black Marble (VNP46A2) gap-filled, BRDF-corrected nighttime radiance, 202… | maks 16 digit desimal |
| 14 | ntl_no_data | ntl_no_data | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the zonal-statistics pull returned no valid pixels for this district (False for a… | kolom KONSTAN (selalu 'False') |
| 15 | elevation_mean_m | elevation_mean_m | numeric | numeric | 0.0% | 514 | 3.263835879865598 | 3073.3049870709656 | 271.17127320672233; 614.1384461017434; 380.53171516669227 | (terrain) Zonal mean elevation, USGS SRTM, 30 m native resolution. [float, meters] | maks 16 digit desimal |
| 16 | elevation_std_m | elevation_std_m | numeric | numeric | 0.0% | 514 | 2.296272638619348 | 1263.479217830725 | 352.2239422754575; 591.9534034343097; 401.8943383057273 | (terrain) Zonal standard deviation of elevation, USGS SRTM. [float, meters] | maks 16 digit desimal |
| 17 | elevation_no_data | elevation_no_data | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the zonal-statistics pull returned no valid pixels for this district (False for a… | kolom KONSTAN (selalu 'False') |
| 18 | pct_tree_cover | pct_tree_cover | numeric | numeric | 0.0% | 513 | 7.782 | 99.526 | 92.143; 94.274; 78.039 | (land cover) Percent of district area classified as tree cover, ESA WorldCover v200 (2021). [float, percent] | maks 3 digit desimal |
| 19 | pct_shrubland | pct_shrubland | numeric | numeric | 0.0% | 182 | 0.0 | 11.54 | 0.163; 0.083; 0.014 | (land cover) Percent of district area classified as shrubland, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 20 | pct_grassland | pct_grassland | numeric | numeric | 0.0% | 507 | 0.234 | 58.167 | 3.709; 1.007; 13.766 | (land cover) Percent of district area classified as grassland, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 21 | pct_cropland | pct_cropland | numeric | numeric | 0.0% | 460 | 0.0 | 66.239 | 2.05; 3.543; 5.613 | (land cover) Percent of district area classified as cropland, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 22 | pct_built_up | pct_built_up | numeric | numeric | 0.0% | 489 | 0.001 | 91.127 | 0.468; 0.542; 1.519 | (land cover) Percent of district area classified as built-up, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 23 | pct_bare_sparse_veg | pct_bare_sparse_veg | numeric | numeric | 0.0% | 318 | 0.005 | 9.058 | 0.354; 0.123; 0.362 | (land cover) Percent of district area classified as bare / sparse vegetation, ESA WorldCover v200. [float, pe… | maks 3 digit desimal |
| 24 | pct_snow_ice | pct_snow_ice | numeric | numeric | 0.0% | 2 | 0.0 | 0.006 | 0.0; 0.006 | (land cover) Percent of district area classified as snow/ice, ESA WorldCover v200 (near-zero nationally). [fl… | maks 3 digit desimal |
| 25 | pct_water | pct_water | numeric | numeric | 0.0% | 458 | 0.0 | 20.664 | 0.975; 0.386; 0.631 | (land cover) Percent of district area classified as open water, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 26 | pct_wetland | pct_wetland | numeric | numeric | 0.0% | 241 | 0.0 | 17.432 | 0.139; 0.042; 0.057 | (land cover) Percent of district area classified as herbaceous wetland, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 27 | pct_mangroves | pct_mangroves | numeric | numeric | 0.0% | 256 | 0.0 | 29.349 | 0.0; 1.525; 6.584 | (land cover) Percent of district area classified as mangroves, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 28 | pct_moss_lichen | pct_moss_lichen | numeric | numeric | 0.0% | 1 | 0 | 0 | 0.0 (514) | (land cover) Percent of district area classified as moss and lichen, ESA WorldCover v200 (near-zero nationall… | kolom KONSTAN (selalu '0.0'); float menurut kamus data (nilai teramati bulat) |
| 29 | landcover_no_data | landcover_no_data | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the zonal-statistics pull returned no valid pixels for this district (False for a… | kolom KONSTAN (selalu 'False') |
| 30 | tertinggal_status | tertinggal_status | text | text | 0.0% | 3 |  |  | Tidak Tertinggal (484); Tertinggal (18); Sangat Tertinggal (12) | (target label) Official three-level designation: Tidak Tertinggal (n=484), Tertinggal (n=18), Sangat Tertingg… | panjang 10-17 |
| 31 | is_tertinggal | is_tertinggal | boolean | boolean | 0.0% | 2 |  |  | False (484); True (30) | (target label) Collapsed binary form of tertinggal_status. True for Tertinggal or Sangat Tertinggal (n=30 of … |  |
| 32 | allsky_sfc_sw_dwn_mean | allsky_sfc_sw_dwn_mean | numeric | numeric | 0.0% | 399 | 184.838994 | 250.32492 | 205.694922; 203.16794533333336; 207.989166 | (solar) Zonal mean all-sky surface shortwave downward radiation, NASA POWER syn1deg product (S3 Zarr), 2020-2… | maks 14 digit desimal |
| 33 | t2m_mean | t2m_mean | numeric | numeric | 0.0% | 491 | 14.683164774999998 | 28.3389184 | 25.2980834; 23.5082514; 27.2638012 | (weather) Zonal mean 2-meter air temperature, NASA POWER MERRA-2 product, 2020-2024 mean. Range in this relea… | maks 15 digit desimal |
| 34 | ws10m_mean | ws10m_mean | numeric | numeric | 0.0% | 491 | 0.6255823686666667 | 5.628532706 | 1.8616251625; 1.466333539; 3.810699000000001 | (weather) Zonal mean wind speed at 10 m, NASA POWER MERRA-2 product, 2020-2024 mean. Reference field, not use… | maks 16 digit desimal |
| 35 | ws50m_mean | ws50m_mean | numeric | numeric | 0.0% | 491 | 1.4705932044444443 | 6.351232013999999 | 2.569582585; 2.00116681; 4.3220326920000005 | (weather) Zonal mean wind speed at 50 m, NASA POWER MERRA-2 product, 2020-2024 mean. Reference field; r=0.974… | maks 16 digit desimal |
| 36 | rh2m_mean | rh2m_mean | numeric | numeric | 0.0% | 491 | 74.64247156666667 | 91.9281523076923 | 85.18883149999999; 85.93833219999999; 80.9022004 | (weather) Zonal mean relative humidity at 2 m, NASA POWER MERRA-2 product, 2020-2024 mean. [float, percent] | maks 14 digit desimal |
| 37 | prectotcorr_mean | prectotcorr_mean | numeric | numeric | 0.0% | 491 | 2.329777353333333 | 11.796330800000002 | 8.283499905; 9.375501; 7.563599672 | (weather) Zonal mean bias-corrected total precipitation, NASA POWER MERRA-2 product, 2020-2024 mean. [float, … | maks 16 digit desimal |
| 38 | solar_zonal_fallback | solar_zonal_fallback | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the solar zonal statistic used the nearest-centroid fallback instead of the all-t… | kolom KONSTAN (selalu 'False') |
| 39 | weather_zonal_fallback | weather_zonal_fallback | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the weather zonal statistic used the nearest-centroid fallback instead of the all… | kolom KONSTAN (selalu 'False') |
| 40 | wind_speed_100m_mean_ms | wind_speed_100m_mean_ms | numeric | numeric | 0.0% | 514 | 1.6897911647874997 | 5.977737092864706 | 2.099640879274229; 1.7612616022779508; 3.817219275762934 | (wind) Zonal mean wind speed at 100 m hub height, Global Wind Atlas 3.0, 10-year modeled mean, 250 m native r… | maks 16 digit desimal |
| 41 | wind_no_data | wind_no_data | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the zonal-statistics pull returned no valid pixels for this district (False for a… | kolom KONSTAN (selalu 'False') |
| 42 | road_length_km | road_length_km | numeric | numeric | 0.0% | 514 | 46.38606152224517 | 18385.40798988013 | 1992.6254142232588; 1070.0324762205; 4048.846127678659 | (infrastructure) Total road length within the district polygon, OpenStreetMap via Geofabrik regional extracts… | maks 14 digit desimal |
| 43 | road_density_km_per_km2 | road_density_km_per_km2 | numeric | numeric | 0.0% | 514 | 0.0104374189543153 | 32.19126434877429 | 0.7046399365282746; 0.5625751536176635; 1.3849712503682945 | (infrastructure) Road length divided by district area. [float, km per km2] | maks 16 digit desimal |
| 44 | dist_to_primary_trunk_km | dist_to_primary_trunk_km | numeric | numeric | 0.0% | 514 | 8.527396518150707e-05 | 128.39719841732824 | 1.3768692390967618; 8.656106291306767; 0.9014943741573684 | (infrastructure) Distance from the district's geometric polygon centroid to the nearest primary or trunk road… | maks 16 digit desimal |
| 45 | centroid_type | centroid_type | text | text | 0.0% | 1 |  |  | geometric (514) | (infrastructure) Method used to compute the district centroid for dist_to_primary_trunk_km. All 514 rows are … | kolom KONSTAN (selalu 'geometric'); panjang 9-9 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,bps_kabkota_code,kabkota_name,prov_name,shapeName,crosswalk_match_type,crosswalk_match_score,ipm_2023,ipm_2024,ppm_2023,ppm_2024,population_2023,population_2024,ntl_radiance_mean,ntl_no_data,elevation_mean_m,elevation_std_m,elevation_no_data,pct_tree_cover,pct_shrubland,pct_grassland,pct_cropland,pct_built_up,pct_bare_sparse_veg,pct_snow_ice,pct_water,pct_wetland,pct_mangroves,pct_moss_lichen,landcover_no_data,tertinggal_status,is_tertinggal,allsky_sfc_sw_dwn_mean,t2m_mean,ws10m_mean,ws50m_mean,rh2m_mean,prectotcorr_mean,solar_zonal_fallback,weather_zonal_fallback,wind_speed_100m_mean_ms
1,1107,Aceh Barat,Aceh,Aceh Barat,exact,1.0,72.88,73.69,17.86,17.6,204768,206822,0.4590617028527347,False,271.17127320672233,352.2239422754575,False,92.143,0.163,3.709,2.05,0.468,0.354,0.0,0.975,0.139,0.0,0.0,False,Tidak Tertinggal,False,205.694922,25.2980834,1.8616251625,2.569582585,85.18883149999999,8.283499905,False,False,2.099640879274229
2,1112,Aceh Barat Daya,Aceh,Aceh Barat Daya,exact,1.0,68.07,68.75,15.43,15.32,156990,159187,0.3856696161413696,False,614.1384461017434,591.9534034343097,False,94.274,0.083,1.007,3.543,0.542,0.123,0.0,0.386,0.042,0.0,0.0,False,Tidak Tertinggal,False,203.16794533333336,23.5082514,1.466333539,2.00116681,85.93833219999999,9.375501,False,False,1.7612616022779508
3,1108,Aceh Besar,Aceh,Aceh Besar,exact,1.0,74.53,75.13,13.38,13.21,422373,428254,1.116737214742774,False,380.53171516669227,401.8943383057273,False,78.039,0.014,13.766,5.613,1.519,0.362,0.0,0.631,0.057,0.0,0.0,False,Tidak Tertinggal,False,207.989166,27.2638012,3.810699000000001,4.3220326920000005,80.9022004,7.563599672,False,False,3.817219275762934
4,1116,Aceh Jaya,Aceh,Aceh Jaya,exact,1.0,70.88,71.83,12.42,12.25,97638,99200,0.3021480622360339,False,376.3668958230951,400.2287308697739,False,94.847,0.132,3.261,0.674,0.177,0.078,0.0,0.705,0.125,0.0,0.0,False,Tidak Tertinggal,False,206.45967,25.728416433333333,2.591111901666667,3.239082826666667,83.56813883333335,8.086027379999999,False,False,2.4047512456627405
303,5208,Lombok Utara,Nusa Tenggara Barat,Lombok Utara,exact,1.0,66.62,67.24,25.8,23.96,257866,261557,0.6836006463324964,False,552.359846431499,575.272927284865,False,81.008,0.002,8.87,5.685,2.382,0.544,0.0,1.503,0.005,0.0,0.0,False,Tidak Tertinggal,False,231.79666200000003,27.284417500000004,2.53350117,3.14357958,79.4286635,4.538918499999999,False,False,2.635991527519108
116,8206,Halmahera Timur,Maluku Utara,Halmahera Timur,exact,1.0,68.82,69.58,12.47,11.91,96556,98224,0.2790884792531069,False,331.8930129891404,266.3307624642775,False,95.211,0.002,2.861,0.138,0.143,0.14,0.0,0.317,0.003,1.184,0.0,False,Tidak Tertinggal,False,213.6350435,27.463896025,3.1219175775,3.605915715,80.59595855,6.508604309999999,False,False,2.628682345052733
274,3319,Kudus,Jawa Tengah,Kudus,exact,1.0,76.71,77.22,7.24,7.23,874632,883322,6.512126208687308,False,132.62734167776335,231.61679304371725,False,39.404,0.083,6.274,35.245,16.809,0.076,0.0,0.463,1.644,0.0,0.0,False,Tidak Tertinggal,False,210.189168,27.4395838,3.118583675,3.890707129999999,80.56941695,6.5203333400000005,False,False,3.791040535158938
```

## SRC-05 - OpenCelliD menara seluler MCC 510
- Sumber: https://opencellid.org
- Lisensi: CC BY-SA 4.0 (atribusi OpenCelliD)
- Grain: titik: 1 baris = 1 sel (radio, net, area, cell)
- Status kesiapan: **READY**
- Pemeriksaan kolom yang diharapkan: radio: ADA; mcc: ADA; net: ADA; area: ADA; cell: ADA; bujur: ADA; lintang: ADA

### SRC-05 / Cell Towers in Indonesia 510.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 5,189,809 byte
- SHA-256: `1318b1445759e2301a4c706b7421475442e47e6766c87b7203841e14c50a1e4e`
- Baris: 66,059 | kolom: 14 | baris duplikat penuh: 0
- Uji kunci (radio, net, area, cell): UNIK (0 duplikat, 0 baris ber-null)
- Koordinat (lat, lon): 66,059 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Sebaran per tahun, kolom `created` (2015-03-12T07:51:33 s.d. 2026-11-10T19:50:47): 2015:30, 2016:614, 2017:476, 2018:180, 2019:129, 2020:18, 2021:74, 2022:609, 2023:439, 2024:845, 2025:27,676, 2026:34,969
- Sebaran per tahun, kolom `updated` (2025-05-11T08:35:25 s.d. 2026-11-10T19:50:47): 2025:24,268, 2026:41,791

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| radius > 0 m: `1 <= range <= 100000` | range | 66,059 | 0 | 0.00% |  |
| sampel >= 1: `1 <= samples <= +inf` | samples | 66,059 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | radio | radio | text | text | 0.0% | 4 |  |  | LTE (61862); GSM (2331); UMTS (1863); NR (3) | Teknologi radio (GSM, UMTS, LTE, NR) | panjang 2-4 |
| 2 | mcc | mcc | integer | integer | 0.0% | 1 | 510 | 510 | 510 (66059) | Mobile Country Code (510 = Indonesia) | kolom KONSTAN (selalu '510') |
| 3 | net | net | integer | integer | 0.0% | 8 | 1 | 89 | 10 (31226); 1 (17492); 11 (13808); 89 (1676); 9 (1284); 21 (549); 22 … | Mobile Network Code (operator) |  |
| 4 | area | area | integer | integer | 0.0% | 1,462 | 447 | 65272 | 41004; 41003; 51005 | Location/Tracking Area Code |  |
| 5 | cell | cell | integer | integer | 0.0% | 63,770 | 1 | 268277260 | 104990981; 104991237; 104975110 | Cell ID |  |
| 6 | unit | unit | integer | integer | 0.0% | 2 | -1 | 0 | -1 (59445); 0 (6614) | PSC/PCI (-1 = tidak ada) |  |
| 7 | lon | lon | numeric | numeric(10,7) | 0.0% | 27,876 | 95.3638 | 140.7077 | 106.8322; 106.829; 106.8381 | Bujur perkiraan sel | bujur |
| 8 | lat | lat | numeric | numeric(10,7) | 0.0% | 20,981 | -10.893 | 5.5869 | -6.1869; -6.188; -6.1823 | Lintang perkiraan sel | lintang |
| 9 | range | range | integer | integer | 0.0% | 2,914 | 500 | 30714 | 7988; 768; 9950 | Radius perkiraan cakupan (meter) |  |
| 10 | samples | samples | integer | integer | 0.0% | 51 | 1 | 51 | 50; 45; 46 | Jumlah pengukuran yang membentuk posisi |  |
| 11 | changeable | changeable | integer | integer | 0.0% | 1 | 1 | 1 | 1 (66059) | 1 = posisi hasil perhitungan, 0 = posisi dari sumber langsung | kolom KONSTAN (selalu '1') |
| 12 | created | created | epoch_seconds | timestamptz | 0.0% | 53,486 | 2015-03-12T07:51:33 | 2026-11-10T19:50:47 | 1446551984; 1447313858; 1447418083 | Waktu data pertama dibuat (epoch detik) | epoch detik; to_timestamp(kolom) |
| 13 | updated | updated | epoch_seconds | timestamptz | 0.0% | 16,611 | 2025-05-11T08:35:25 | 2026-11-10T19:50:47 | 1747378621; 1747387201; 1747988701 | Waktu data terakhir diperbarui (epoch detik) | epoch detik; to_timestamp(kolom) |
| 14 | averageSignal | averagesignal | integer | integer | 0.0% | 1 | 0 | 0 | 0 (66059) | Rata-rata kekuatan sinyal (0 = tidak ada) | kolom KONSTAN (selalu '0') |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,radio,mcc,net,area,cell,unit,lon,lat,range,samples,changeable,created,updated,averageSignal
1,LTE,510,11,41004,104990981,0,106.8322,-6.1869,7988,50,1,1446551984,1747378621,0
2,LTE,510,11,41004,104991237,0,106.829,-6.188,768,50,1,1446551984,1747387201,0
3,LTE,510,11,41004,104975110,0,106.8381,-6.1823,9950,50,1,1446551984,1747988701,0
4,LTE,510,11,41004,104991236,0,106.8303,-6.187,3152,45,1,1446551984,1754484241,0
27670,LTE,510,11,61602,156232722,-1,115.1532,-8.8189,1000,13,1,1761820937,1761841504,0
37148,LTE,510,1,43210,103631381,-1,108.224,-6.7048,1000,7,1,1775020014,1775063349,0
27501,LTE,510,10,1237,111390987,-1,106.7245,-6.3181,1000,1,1,1761584471,1761584471,0
```

## SRC-06 - Ookla Open Data fixed tiles 2024 Q4 (Indonesia)
- Sumber: https://ookla-open-data.s3.amazonaws.com/parquet/performance/type=fixed/year=2024/quarter=4/
- Lisensi: CC BY-NC-SA 4.0 (non-komersial, atribusi Ookla)
- Grain: tile geografis zoom 16 per kuartal (quadkey)
- Status kesiapan: **READY**
  - (info) [ekstrem] ookla_fixed_2024q4_indonesia.csv.avg_lat_ms: NILAI EKSTREM: min 0 / maks 1924 vs p01-p99 = 2..125
  - (info) [ekstrem] ookla_fixed_2024q4_indonesia.csv.tests: NILAI EKSTREM: min 1 / maks 7284 vs p01-p99 = 1..294
  - (info) [ekstrem] ookla_fixed_2024q4_indonesia.csv.devices: NILAI EKSTREM: min 1 / maks 1207 vs p01-p99 = 1..85
- Pemeriksaan kolom yang diharapkan: quadkey: ADA; tile (WKT): ADA; kecepatan unduh: ADA; latensi: ADA; jumlah tes: ADA

### SRC-06 / ookla_fixed_2024q4_indonesia.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 70,046,037 byte
- SHA-256: `ba287a289176479346c35099a145ebd27fddeae13d982ddbb301087bdb4e8bb8`
- Baris: 229,305 | kolom: 16 | baris duplikat penuh: 0
- Uji kunci (quadkey): UNIK (0 duplikat, 0 baris ber-null)
- Koordinat (tile_y, tile_x): 229,305 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Geometri WKT (tile): 0 dari 3,000 titik awal di luar bounding box Indonesia kasar
- Sebaran per tahun, kolom `year` (2024 s.d. 2024): 2024:229,305

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| kecepatan > 0: `1 <= avg_d_kbps <= +inf` | avg_d_kbps | 229,305 | 0 | 0.00% |  |
| kecepatan > 0: `1 <= avg_u_kbps <= +inf` | avg_u_kbps | 229,305 | 0 | 0.00% |  |
| jumlah >= 1: `1 <= tests <= +inf` | tests | 229,305 | 0 | 0.00% |  |
| jumlah >= 1: `1 <= devices <= +inf` | devices | 229,305 | 0 | 0.00% |  |
| latensi >= 0: `0 <= avg_lat_ms <= +inf` | avg_lat_ms | 229,305 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | quadkey | quadkey | text | text | 0.0% | 229,305 | 1322203332110310 | 3110032002211031 | 1322203332110310; 1322203332112331; 1322203332113221 | ID tile (quadkey zoom 16); WAJIB text | ID numerik 16 digit - simpan sebagai text (hindari kehilangan presisi); panjang 16-16; KANDIDAT KUNCI |
| 2 | tile | tile | geometry_wkt | text | 0.0% | 229,305 |  |  | POLYGON((95.218505859375 5.94389957942559, 95.2239990234375 5.9438995… | Poligon tile (WKT, WGS84) | WKT; jadikan geometry(...,4326) di staging bila PostGIS aktif |
| 3 | tile_x | tile_x | numeric | numeric | 0.0% | 6,835 | 95.2213 | 141.0013 | 95.22130000000001; 95.22670000000001; 95.2377 | Bujur centroid tile | maks 14 digit desimal |
| 4 | tile_y | tile_y | numeric | numeric | 0.0% | 2,913 | -10.9385 | 5.995800000000001 | 5.9412; 5.8865; 5.8811 | Lintang centroid tile | maks 18 digit desimal |
| 5 | avg_d_kbps | avg_d_kbps | integer | integer | 0.0% | 97,221 | 6 | 1065596 | 18472; 248239; 6331 | Rata-rata kecepatan unduh (kbps) |  |
| 6 | avg_u_kbps | avg_u_kbps | integer | integer | 0.0% | 78,614 | 1 | 964945 | 7791; 16439; 1072 | Rata-rata kecepatan unggah (kbps) |  |
| 7 | avg_lat_ms | avg_lat_ms | integer | integer | 0.0% | 608 | 0 | 1924 | 68; 207; 5 | Rata-rata latensi (ms) | NILAI EKSTREM: min 0 / maks 1924 vs p01-p99 = 2..125 |
| 8 | avg_lat_down_ms | avg_lat_down_ms | integer | integer | 0.7% | 3,766 | 2 | 9721 | 180; 477; 715 | Latensi saat unduh (ms) |  |
| 9 | avg_lat_up_ms | avg_lat_up_ms | integer | integer | 0.6% | 5,160 | 2 | 9971 | 732; 465; 4851 | Latensi saat unggah (ms) |  |
| 10 | tests | tests | integer | integer | 0.0% | 938 | 1 | 7284 | 1; 3; 2 | Jumlah pengujian | NILAI EKSTREM: min 1 / maks 7284 vs p01-p99 = 1..294 |
| 11 | devices | devices | integer | integer | 0.0% | 346 | 1 | 1207 | 1; 3; 2 | Jumlah perangkat unik | NILAI EKSTREM: min 1 / maks 1207 vs p01-p99 = 1..85 |
| 12 | quarter | quarter | integer | integer | 0.0% | 1 | 4 | 4 | 4 (229305) | Kuartal | kolom KONSTAN (selalu '4') |
| 13 | type | type | text | text | 0.0% | 1 |  |  | fixed (229305) | Jenis layanan (fixed) | kolom KONSTAN (selalu 'fixed'); panjang 5-5 |
| 14 | year | year | integer | integer | 0.0% | 1 | 2024 | 2024 | 2024 (229305) | Tahun | kolom KONSTAN (selalu '2024'); tahun |
| 15 | lon | lon | numeric | numeric(10,7) | 0.0% | 6,835 | 95.218505859375 | 140.99853515625 | 95.218505859375; 95.2239990234375; 95.2349853515625 | Bujur sudut barat laut tile | bujur |
| 16 | lat | lat | numeric | numeric(10,7) | 0.0% | 2,913 | -10.935798432254 | 5.99853317432933 | 5.94389957942559; 5.88926056013393; 5.88379636175571 | Lintang sudut barat laut tile | lintang |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,quadkey,tile,tile_x,tile_y,avg_d_kbps,avg_u_kbps,avg_lat_ms,avg_lat_down_ms,avg_lat_up_ms,tests,devices,quarter,type,year,lon,lat
1,1322203332110310,"POLYGON((95.218505859375 5.94389957942559, 95.2239990234375 5.94389957",95.22130000000001,5.9412,18472,7791,68,180,732,1,1,4,fixed,2024,95.218505859375,5.94389957942559
2,1322203332112331,"POLYGON((95.2239990234375 5.88926056013393, 95.2294921875 5.8892605601",95.22670000000001,5.8865,248239,16439,207,477,465,1,1,4,fixed,2024,95.2239990234375,5.88926056013393
3,1322203332113221,"POLYGON((95.2349853515625 5.88926056013393, 95.240478515625 5.88926056",95.2377,5.8865,6331,1072,5,715,4851,1,1,4,fixed,2024,95.2349853515625,5.88926056013393
4,1322203332113230,"POLYGON((95.240478515625 5.88926056013393, 95.2459716796875 5.88926056",95.2432,5.8865,21170,6679,11,707,894,3,3,4,fixed,2024,95.240478515625,5.88926056013393
174496,3100131331223030,"POLYGON((112.203369140625 -8.02659484248956, 112.208862304688 -8.02659",112.20610000000002,-8.029300000000001,9920,3971,8,,,2,1,4,fixed,2024,112.203369140625,-8.02659484248956
194660,3101013032330000,"POLYGON((121.904296875 -4.12728532324537, 121.909790039062 -4.12728532",121.90700000000001,-4.13,42913,16765,15,,,11,1,4,fixed,2024,121.904296875,-4.12728532324537
111014,3100130123313223,"POLYGON((108.945922851562 -6.92097374155414, 108.951416015625 -6.92097",108.94869999999999,-6.923699999999999,9525,2135,13,223,126,1,1,4,fixed,2024,108.945922851562,-6.92097374155414
49668,1323220113221002,"POLYGON((115.0048828125 4.99792208960985, 115.010375976562 4.997922089",115.0076,4.9952,334010,190639,4,252,88,27,10,4,fixed,2024,115.0048828125,4.99792208960985
125835,3100130313301303,"POLYGON((109.583129882812 -7.56399200553307, 109.588623046875 -7.56399",109.5859,-7.5667,36260,37021,9,161,893,1,1,4,fixed,2024,109.583129882812,-7.56399200553307
```
