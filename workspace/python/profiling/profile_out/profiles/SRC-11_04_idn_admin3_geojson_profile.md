### SRC-11 / idn_admin3.geojson   [di luar cakupan model (kecamatan)]
- Format: geojson (reader: geojson) | 286,457,798 byte
- SHA-256: `803ade4feaab704116ff9aaf6fc003a45e8d72293283ed13a50eccd8513ddf75`
- Baris: 7,069 | kolom: 32 | baris duplikat penuh: 0
- Uji kunci (adm3_pcode): UNIK (0 duplikat, 0 baris ber-null)
- Geometri: fitur 7,069; jenis (sampel) {'Polygon': 6003, 'MultiPolygon': 1066}; bbox [xmin,ymin,xmax,ymax] = [95.2997, -10.3663, 141.0, 5.6224]; CRS: urn:ogc:def:crs:OGC:1.3:CRS84
- Koordinat (center_lat, center_lon): 7,069 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Catatan: GeoJSON dibaca streaming: hanya atribut yang diprofil; geometri hanya dilaporkan jenis dan bounding box (dari 600 fitur pertama).
- Sebaran per tahun, kolom `valid_on` (2020-04-01 s.d. 2020-04-01): 2020:7,069

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | adm3_name | adm3_name | text | text | 0.0% | 6,679 |  |  | 2 X 11 Enam Lingkung; 2 X 11 Kayu Tanam; Abab |  | panjang 2-31 |
| 2 | adm3_name1 | adm3_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 3 | adm3_name2 | adm3_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 4 | adm3_name3 | adm3_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 5 | adm3_pcode | adm3_pcode | text | text | 0.0% | 7,069 |  |  | ID1306050; ID1306052; ID1612030 |  | panjang 9-9; KANDIDAT KUNCI |
| 6 | adm2_name | adm2_name | text | text | 0.0% | 519 |  |  | Padang Pariaman; Penukal Abab Lematang Ilir; Karang Asem |  | panjang 4-26 |
| 7 | adm2_name1 | adm2_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 8 | adm2_name2 | adm2_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 9 | adm2_name3 | adm2_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 10 | adm2_pcode | adm2_pcode | text | text | 0.0% | 522 |  |  | ID1306; ID1612; ID5107 |  | panjang 6-6 |
| 11 | adm1_name | adm1_name | text | text | 0.0% | 34 |  |  | Jawa Timur (667); Jawa Barat (630); Jawa Tengah (577); Sumatera Utara… |  | panjang 4-26 |
| 12 | adm1_name1 | adm1_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 13 | adm1_name2 | adm1_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 14 | adm1_name3 | adm1_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 15 | adm1_pcode | adm1_pcode | text | text | 0.0% | 34 |  |  | ID35 (667); ID32 (630); ID33 (577); ID12 (450); ID94 (424); ID73 (309… |  | panjang 4-4 |
| 16 | adm0_name | adm0_name | text | text | 0.0% | 1 |  |  | Indonesia (7069) |  | kolom KONSTAN (selalu 'Indonesia'); panjang 9-9 |
| 17 | adm0_name1 | adm0_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 18 | adm0_name2 | adm0_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 19 | adm0_name3 | adm0_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 20 | adm0_pcode | adm0_pcode | text | text | 0.0% | 1 |  |  | ID (7069) |  | kolom KONSTAN (selalu 'ID'); panjang 2-2 |
| 21 | valid_on | valid_on | date | date | 0.0% | 1 | 2020-04-01 | 2020-04-01 | 2020-04-01 |  | kolom KONSTAN (selalu '2020-04-01') |
| 22 | valid_to | valid_to | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 23 | area_sqkm | area_sqkm | numeric | numeric | 0.0% | 7,069 | 0.14728103 | 11923.27349437 | 38.25011368; 208.32756415; 302.80279847 |  | maks 8 digit desimal |
| 24 | version | version | text | text | 0.0% | 1 |  |  | v01 (7069) |  | kolom KONSTAN (selalu 'v01'); panjang 3-3 |
| 25 | lang | lang | text | text | 0.0% | 1 |  |  | en (7069) |  | kolom KONSTAN (selalu 'en'); panjang 2-2 |
| 26 | lang1 | lang1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 27 | lang2 | lang2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 28 | lang3 | lang3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 29 | adm3_ref_name | adm3_ref_name | text | text | 0.0% | 6,679 |  |  | 2 X 11 Enam Lingkung; 2 X 11 Kayu Tanam; Abab |  | panjang 2-31 |
| 30 | center_lat | center_lat | numeric | numeric(10,7) | 0.0% | 7,065 | -10.8615408 | 5.8603246 | -0.5885974; -0.56565185; -3.15411835 |  | lintang |
| 31 | center_lon | center_lon | numeric | numeric(10,7) | 0.0% | 7,069 | 95.07785979 | 140.94571789 | 100.28305783; 100.3551213; 104.15780077 |  | bujur |
| 32 | _geometry_type | geometry_type | text | text | 0.0% | 2 |  |  | Polygon (6003); MultiPolygon (1066) |  | panjang 7-12 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,adm3_name,adm3_name1,adm3_name2,adm3_name3,adm3_pcode,adm2_name,adm2_name1,adm2_name2,adm2_name3,adm2_pcode,adm1_name,adm1_name1,adm1_name2,adm1_name3,adm1_pcode,adm0_name,adm0_name1,adm0_name2,adm0_name3,adm0_pcode,valid_on,valid_to,area_sqkm,version,lang,lang1,lang2,lang3,adm3_ref_name,center_lat,center_lon,_geometry_type
1,2 X 11 Enam Lingkung,,,,ID1306050,Padang Pariaman,,,,ID1306,Sumatera Barat,,,,ID13,Indonesia,,,,ID,2020-04-01,,38.25011368,v01,en,,,,2 X 11 Enam Lingkung,-0.5885974,100.28305783,Polygon
2,2 X 11 Kayu Tanam,,,,ID1306052,Padang Pariaman,,,,ID1306,Sumatera Barat,,,,ID13,Indonesia,,,,ID,2020-04-01,,208.32756415,v01,en,,,,2 X 11 Kayu Tanam,-0.56565185,100.3551213,Polygon
3,Abab,,,,ID1612030,Penukal Abab Lematang Ilir,,,,ID1612,Sumatera Selatan,,,,ID16,Indonesia,,,,ID,2020-04-01,,302.80279847,v01,en,,,,Abab,-3.15411835,104.15780077,Polygon
4,Abang,,,,ID5107050,Karang Asem,,,,ID5107,Bali,,,,ID51,Indonesia,,,,ID,2020-04-01,,131.08867112,v01,en,,,,Abang,-8.36322765,115.63349952,Polygon
3533,Matan Hilir Utara,,,,ID6106070,Ketapang,,,,ID6106,Kalimantan Barat,,,,ID61,Indonesia,,,,ID,2020-04-01,,889.99860688,v01,en,,,,Matan Hilir Utara,-1.48149885,110.1841257,MultiPolygon
808,Binong,,,,ID3213170,Subang,,,,ID3213,Jawa Barat,,,,ID32,Indonesia,,,,ID,2020-04-01,,53.95567514,v01,en,,,,Binong,-6.4008356,107.80230836,Polygon
3303,Madang Suku III,,,,ID1609041,Ogan Komering Ulu Timur,,,,ID1609,Sumatera Selatan,,,,ID16,Indonesia,,,,ID,2020-04-01,,227.42527213,v01,en,,,,Madang Suku III,-4.09996535,104.36570933,Polygon
```
