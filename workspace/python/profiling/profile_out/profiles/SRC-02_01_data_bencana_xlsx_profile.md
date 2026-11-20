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
