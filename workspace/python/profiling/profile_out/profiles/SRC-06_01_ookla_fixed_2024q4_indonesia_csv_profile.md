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
