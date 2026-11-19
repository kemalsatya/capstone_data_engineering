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
54341,15-12-2017,22.0,31.2,,,,,,,,,96077
54168,09-05-2017,23.0,30.7,,,,,,,,,96077
111416,02-11-2017,19.0,29.3,23.4,85.0,12.9,7.0,5.0,200.0,2.0,N ,96207
95867,06-06-2017,24.0,,26.8,87.0,0.0,8.4,3.0,220.0,0.0,N ,96171
29880,03-02-2017,,,26.1,88.0,0.0,8.1,5.0,340.0,2.0,N ,96035
```
