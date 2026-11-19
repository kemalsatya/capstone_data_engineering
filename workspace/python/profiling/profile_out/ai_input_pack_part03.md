# AI INPUT PACK - bagian 3 dari 3 (profil sumber data capstone SRC-01..SRC-12)

Dibuat oleh profile_sources.py v3.0. Semua angka berasal dari file sumber nyata, bukan asumsi.

Cara membaca: 'Tipe terdeteksi' = heuristik dari data; 'Tipe PG (usulan)' hanya usulan staging; 'KANDIDAT KUNCI' = unik dan tidak null (belum tentu business key); 'Aturan domain' = USULAN batas wajar yang diukur pada data (bukan keputusan); 'Definisi' dari kamus resmi bila ada, selain itu dari analisis.

## SRC-11 - COD-AB Indonesia (OCHA/BPS via HDX)
- Sumber: https://data.humdata.org/dataset/cod-ab-idn
- Lisensi: CC BY-IGO (atribusi OCHA/BPS)
- Grain: poligon batas wilayah ADM0..ADM4 + garis + titik
- Status kesiapan: **CHECK**
  - [relasi P9] Nama ADM2 (SRC-11) -> SRC-04: nama cocok pada 97.3% baris; 11 nama perlu alias/crosswalk.
  - [relasi P4] Kode BPS (SRC-04) <-> pcode ADM2 tanpa awalan ID (SRC-11): cakupan baris 94.9% (hanya-kiri 26, hanya-kanan 34).
  - [duplikat baris] idn_adminlines.geojson: 19,995 baris duplikat penuh (100.0%); tentukan aturan dedup sebelum memilih kunci.
  - (info) [ekstrem] idn_admin4.geojson.area_sqkm: NILAI EKSTREM: min 6.029e-05 / maks 3363.81 vs p01-p99 = 0.200695..280.156
  - (info) [ekstrem] idn_adminpoints.geojson.area_sqkm: NILAI EKSTREM: min 6.029e-05 / maks 1.89108e+06 vs p01-p99 = 0.246809..2697.88
- Pemeriksaan kolom yang diharapkan: kode ADM2: ADA; nama ADM2: ADA; kode ADM1: ADA

### SRC-11 / idn_admin0.geojson   [di luar cakupan model (batas negara)]
- Format: geojson (reader: geojson) | 96,427,785 byte
- SHA-256: `f28232ab0d0161f46b58e2ca93c61732658459067f92bef7a721fce2a1b03b83`
- Baris: 1 | kolom: 19 | baris duplikat penuh: 0
- Uji kunci (adm0_pcode): UNIK (0 duplikat, 0 baris ber-null)
- Geometri: fitur 1; jenis (sampel) {'MultiPolygon': 1}; bbox [xmin,ymin,xmax,ymax] = [95.0108, -11.0076, 141.0194, 6.0769]; CRS: urn:ogc:def:crs:OGC:1.3:CRS84
- Koordinat (center_lat, center_lon): 1 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Catatan: GeoJSON dibaca streaming: hanya atribut yang diprofil; geometri hanya dilaporkan jenis dan bounding box (dari 1 fitur pertama).
- Sebaran per tahun, kolom `valid_on` (2020-04-01 s.d. 2020-04-01): 2020:1

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | iso2 | iso2 | text | text | 0.0% | 1 |  |  | ID (1) |  | kolom KONSTAN (selalu 'ID'); panjang 2-2; KANDIDAT KUNCI |
| 2 | iso3 | iso3 | text | text | 0.0% | 1 |  |  | IDN (1) |  | kolom KONSTAN (selalu 'IDN'); panjang 3-3; KANDIDAT KUNCI |
| 3 | adm0_name | adm0_name | text | text | 0.0% | 1 |  |  | Indonesia (1) |  | kolom KONSTAN (selalu 'Indonesia'); panjang 9-9; KANDIDAT KUNCI |
| 4 | adm0_name1 | adm0_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 5 | adm0_name2 | adm0_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 6 | adm0_name3 | adm0_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 7 | adm0_pcode | adm0_pcode | text | text | 0.0% | 1 |  |  | ID (1) |  | kolom KONSTAN (selalu 'ID'); panjang 2-2; KANDIDAT KUNCI |
| 8 | valid_on | valid_on | date | date | 0.0% | 1 | 2020-04-01 | 2020-04-01 | 2020-04-01 |  | kolom KONSTAN (selalu '2020-04-01'); KANDIDAT KUNCI |
| 9 | valid_to | valid_to | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 10 | version | version | text | text | 0.0% | 1 |  |  | v01 (1) |  | kolom KONSTAN (selalu 'v01'); panjang 3-3; KANDIDAT KUNCI |
| 11 | area_sqkm | area_sqkm | numeric | numeric | 0.0% | 1 | 1891077.03118032 | 1891077.03118032 | 1891077.03118032 |  | kolom KONSTAN (selalu '1891077.03118032'); maks 8 digit desimal |
| 12 | lang | lang | text | text | 0.0% | 1 |  |  | en (1) |  | kolom KONSTAN (selalu 'en'); panjang 2-2; KANDIDAT KUNCI |
| 13 | lang1 | lang1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 14 | lang2 | lang2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 15 | lang3 | lang3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 16 | adm0_ref_name | adm0_ref_name | text | text | 0.0% | 1 |  |  | Indonesia (1) |  | kolom KONSTAN (selalu 'Indonesia'); panjang 9-9; KANDIDAT KUNCI |
| 17 | center_lat | center_lat | numeric | numeric(10,7) | 0.0% | 1 | 0.11511615 | 0.11511615 | 0.11511615 |  | kolom KONSTAN (selalu '0.11511615'); lintang |
| 18 | center_lon | center_lon | numeric | numeric(10,7) | 0.0% | 1 | 113.31613885 | 113.31613885 | 113.31613885 |  | kolom KONSTAN (selalu '113.31613885'); bujur |
| 19 | _geometry_type | geometry_type | text | text | 0.0% | 1 |  |  | MultiPolygon (1) |  | kolom KONSTAN (selalu 'MultiPolygon'); panjang 12-12; KANDIDAT KUNCI |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,iso2,iso3,adm0_name,adm0_name1,adm0_name2,adm0_name3,adm0_pcode,valid_on,valid_to,version,area_sqkm,lang,lang1,lang2,lang3,adm0_ref_name,center_lat,center_lon,_geometry_type
1,ID,IDN,Indonesia,,,,ID,2020-04-01,,v01,1891077.03118032,en,,,,Indonesia,0.11511615,113.31613885,MultiPolygon
```

### SRC-11 / idn_admin1.geojson
- Format: geojson (reader: geojson) | 103,908,112 byte
- SHA-256: `7809c678b9f1596736cf74116beb9deecd5c1ced99b0ceb205347af1f3501e46`
- Baris: 34 | kolom: 22 | baris duplikat penuh: 0
- Uji kunci (adm1_pcode): UNIK (0 duplikat, 0 baris ber-null)
- Geometri: fitur 34; jenis (sampel) {'MultiPolygon': 34}; bbox [xmin,ymin,xmax,ymax] = [95.0108, -11.0076, 141.0194, 6.0769]; CRS: urn:ogc:def:crs:OGC:1.3:CRS84
- Koordinat (center_lat, center_lon): 34 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Catatan: GeoJSON dibaca streaming: hanya atribut yang diprofil; geometri hanya dilaporkan jenis dan bounding box (dari 34 fitur pertama).
- Sebaran per tahun, kolom `valid_on` (2020-04-01 s.d. 2020-04-01): 2020:34

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| luas > 0: `0.0001 <= area_sqkm <= +inf` | area_sqkm | 34 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | adm1_name | adm1_name | text | text | 0.0% | 34 |  |  | Aceh (1); Bali (1); Banten (1); Bengkulu (1); Daerah Istimewa Yogyaka… |  | panjang 4-26; KANDIDAT KUNCI |
| 2 | adm1_name1 | adm1_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 3 | adm1_name2 | adm1_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 4 | adm1_name3 | adm1_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 5 | adm1_pcode | adm1_pcode | text | text | 0.0% | 34 |  |  | ID11 (1); ID51 (1); ID36 (1); ID17 (1); ID34 (1); ID31 (1); ID75 (1);… |  | panjang 4-4; KANDIDAT KUNCI |
| 6 | adm0_name | adm0_name | text | text | 0.0% | 1 |  |  | Indonesia (34) |  | kolom KONSTAN (selalu 'Indonesia'); panjang 9-9 |
| 7 | adm0_name1 | adm0_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 8 | adm0_name2 | adm0_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 9 | adm0_name3 | adm0_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 10 | adm0_pcode | adm0_pcode | text | text | 0.0% | 1 |  |  | ID (34) |  | kolom KONSTAN (selalu 'ID'); panjang 2-2 |
| 11 | valid_on | valid_on | date | date | 0.0% | 1 | 2020-04-01 | 2020-04-01 | 2020-04-01 |  | kolom KONSTAN (selalu '2020-04-01') |
| 12 | valid_to | valid_to | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 13 | area_sqkm | area_sqkm | numeric | numeric | 0.0% | 34 | 653.87470419 | 314033.03777158 | 56778.56250085; 5587.80831016; 9357.11774109 |  | maks 8 digit desimal |
| 14 | version | version | text | text | 0.0% | 1 |  |  | v01 (34) |  | kolom KONSTAN (selalu 'v01'); panjang 3-3 |
| 15 | lang | lang | text | text | 0.0% | 1 |  |  | en (34) |  | kolom KONSTAN (selalu 'en'); panjang 2-2 |
| 16 | lang1 | lang1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 17 | lang2 | lang2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 18 | lang3 | lang3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 19 | adm1_ref_name | adm1_ref_name | text | text | 0.0% | 34 |  |  | Aceh (1); Bali (1); Banten (1); Bengkulu (1); Daerah Istimewa Yogyaka… |  | panjang 4-26; KANDIDAT KUNCI |
| 20 | center_lat | center_lat | numeric | numeric(10,7) | 0.0% | 34 | -8.5949149 | 3.9299642 | 3.91056155; -8.4553126; -6.43769535 |  | lintang |
| 21 | center_lon | center_lon | numeric | numeric(10,7) | 0.0% | 34 | 97.149714 | 139.36979696 | 97.149714; 115.27069877; 106.13333543 |  | bujur |
| 22 | _geometry_type | geometry_type | text | text | 0.0% | 1 |  |  | MultiPolygon (34) |  | kolom KONSTAN (selalu 'MultiPolygon'); panjang 12-12 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,adm1_name,adm1_name1,adm1_name2,adm1_name3,adm1_pcode,adm0_name,adm0_name1,adm0_name2,adm0_name3,adm0_pcode,valid_on,valid_to,area_sqkm,version,lang,lang1,lang2,lang3,adm1_ref_name,center_lat,center_lon,_geometry_type
1,Aceh,,,,ID11,Indonesia,,,,ID,2020-04-01,,56778.56250085,v01,en,,,,Aceh,3.91056155,97.149714,MultiPolygon
2,Bali,,,,ID51,Indonesia,,,,ID,2020-04-01,,5587.80831016,v01,en,,,,Bali,-8.4553126,115.27069877,MultiPolygon
3,Banten,,,,ID36,Indonesia,,,,ID,2020-04-01,,9357.11774109,v01,en,,,,Banten,-6.43769535,106.13333543,MultiPolygon
4,Bengkulu,,,,ID17,Indonesia,,,,ID,2020-04-01,,20026.36522406,v01,en,,,,Bengkulu,-3.6020366,102.47267131,MultiPolygon
21,Maluku Utara,,,,ID82,Indonesia,,,,ID,2020-04-01,,31508.24482424,v01,en,,,,Maluku Utara,-1.83165955,124.82958689,MultiPolygon
```

### SRC-11 / idn_admin2.geojson
- Format: geojson (reader: geojson) | 149,707,552 byte
- SHA-256: `15c1c0b449c5be5bd639c3fd39febf188842d026ddf448f7194799835d6f59ca`
- Baris: 522 | kolom: 27 | baris duplikat penuh: 0
- Uji kunci (adm2_pcode): UNIK (0 duplikat, 0 baris ber-null)
- Geometri: fitur 522; jenis (sampel) {'Polygon': 274, 'MultiPolygon': 248}; bbox [xmin,ymin,xmax,ymax] = [95.0108, -11.0076, 141.0194, 6.0769]; CRS: urn:ogc:def:crs:OGC:1.3:CRS84
- Koordinat (center_lat, center_lon): 522 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Catatan: GeoJSON dibaca streaming: hanya atribut yang diprofil; geometri hanya dilaporkan jenis dan bounding box (dari 522 fitur pertama).
- Sebaran per tahun, kolom `valid_on` (2020-04-01 s.d. 2020-04-01): 2020:522

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| luas > 0: `0.0001 <= area_sqkm <= +inf` | area_sqkm | 522 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | adm2_name | adm2_name | text | text | 0.0% | 519 |  |  | Aceh Barat; Aceh Barat Daya; Aceh Besar | Nama kab/kota (awalan Kota; 4 poligon bernama Danau, waduk, hutan) | panjang 4-26 |
| 2 | adm2_name1 | adm2_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 3 | adm2_name2 | adm2_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 4 | adm2_name3 | adm2_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 5 | adm2_pcode | adm2_pcode | text | text | 0.0% | 522 |  |  | ID1107; ID1112; ID1108 | Kode kab/kota OCHA: 'ID' + kode BPS 4 digit (mis. ID1107) | panjang 6-6; KANDIDAT KUNCI |
| 6 | adm1_name | adm1_name | text | text | 0.0% | 34 |  |  | Jawa Timur (38); Jawa Tengah (37); Sumatera Utara (34); Papua (29); J… |  | panjang 4-26 |
| 7 | adm1_name1 | adm1_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 8 | adm1_name2 | adm1_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 9 | adm1_name3 | adm1_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 10 | adm1_pcode | adm1_pcode | text | text | 0.0% | 34 |  |  | ID35 (38); ID33 (37); ID12 (34); ID94 (29); ID32 (28); ID73 (24); ID1… | Kode provinsi OCHA (ID + kode BPS 2 digit) | panjang 4-4 |
| 11 | adm0_name | adm0_name | text | text | 0.0% | 1 |  |  | Indonesia (522) |  | kolom KONSTAN (selalu 'Indonesia'); panjang 9-9 |
| 12 | adm0_name1 | adm0_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 13 | adm0_name2 | adm0_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 14 | adm0_name3 | adm0_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 15 | adm0_pcode | adm0_pcode | text | text | 0.0% | 1 |  |  | ID (522) |  | kolom KONSTAN (selalu 'ID'); panjang 2-2 |
| 16 | valid_on | valid_on | date | date | 0.0% | 1 | 2020-04-01 | 2020-04-01 | 2020-04-01 | Tanggal berlaku batas wilayah | kolom KONSTAN (selalu '2020-04-01') |
| 17 | valid_to | valid_to | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 18 | area_sqkm | area_sqkm | numeric | numeric | 0.0% | 522 | 10.78310453 | 44014.03200064 | 2810.08034723; 1893.15343909; 2897.32665547 | Luas poligon (km2) | maks 8 digit desimal |
| 19 | version | version | text | text | 0.0% | 1 |  |  | v01 (522) |  | kolom KONSTAN (selalu 'v01'); panjang 3-3 |
| 20 | lang | lang | text | text | 0.0% | 1 |  |  | en (522) |  | kolom KONSTAN (selalu 'en'); panjang 2-2 |
| 21 | lang1 | lang1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 22 | lang2 | lang2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 23 | lang3 | lang3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 24 | adm2_ref_name | adm2_ref_name | text | text | 0.0% | 519 |  |  | Aceh Barat; Aceh Barat Daya; Aceh Besar |  | panjang 4-26 |
| 25 | center_lat | center_lat | numeric | numeric(10,7) | 0.0% | 522 | -10.686985 | 5.83949875 | 4.4522484; 3.83582325; 5.3545992 |  | lintang |
| 26 | center_lon | center_lon | numeric | numeric(10,7) | 0.0% | 522 | 95.33093506 | 140.81141547 | 96.20150419; 96.84792396; 95.49617027 |  | bujur |
| 27 | _geometry_type | geometry_type | text | text | 0.0% | 2 |  |  | Polygon (274); MultiPolygon (248) |  | panjang 7-12 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,adm2_name,adm2_name1,adm2_name2,adm2_name3,adm2_pcode,adm1_name,adm1_name1,adm1_name2,adm1_name3,adm1_pcode,adm0_name,adm0_name1,adm0_name2,adm0_name3,adm0_pcode,valid_on,valid_to,area_sqkm,version,lang,lang1,lang2,lang3,adm2_ref_name,center_lat,center_lon,_geometry_type
1,Aceh Barat,,,,ID1107,Aceh,,,,ID11,Indonesia,,,,ID,2020-04-01,,2810.08034723,v01,en,,,,Aceh Barat,4.4522484,96.20150419,Polygon
2,Aceh Barat Daya,,,,ID1112,Aceh,,,,ID11,Indonesia,,,,ID,2020-04-01,,1893.15343909,v01,en,,,,Aceh Barat Daya,3.83582325,96.84792396,MultiPolygon
3,Aceh Besar,,,,ID1108,Aceh,,,,ID11,Indonesia,,,,ID,2020-04-01,,2897.32665547,v01,en,,,,Aceh Besar,5.3545992,95.49617027,MultiPolygon
4,Aceh Jaya,,,,ID1116,Aceh,,,,ID11,Indonesia,,,,ID,2020-04-01,,3878.16324023,v01,en,,,,Aceh Jaya,4.81059705,95.69887344,MultiPolygon
521,Yahukimo,,,,ID9416,Papua,,,,ID94,Indonesia,,,,ID,2020-04-01,,14614.75145649,v01,en,,,,Yahukimo,-4.38563325,139.40729215,Polygon
518,Way Kanan,,,,ID1807,Lampung,,,,ID18,Indonesia,,,,ID,2020-04-01,,3650.97164878,v01,en,,,,Way Kanan,-4.57303435,104.51563599,Polygon
355,Muara Enim,,,,ID1603,Sumatera Selatan,,,,ID16,Indonesia,,,,ID,2020-04-01,,6751.48193861,v01,en,,,,Muara Enim,-3.84692495,103.95226769,MultiPolygon
```

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

### SRC-11 / idn_admin4.geojson   [di luar cakupan model (desa; sangat besar)]
- Format: geojson (reader: geojson) | 651,940,706 byte
- SHA-256: `dd41f6a40dc9f07cfa4ed6aefca260ba13ce1e0b1b20ce485de2d74f04d91599`
- Baris: 81,912 (profil memakai 20,000 baris) | kolom: 37 | baris duplikat penuh: 0
- Uji kunci (adm4_pcode): UNIK (0 duplikat, 0 baris ber-null)
- Geometri: fitur 81,912; jenis (sampel) {'Polygon': 19336, 'MultiPolygon': 664}; bbox [xmin,ymin,xmax,ymax] = [95.8748, -9.7304, 141.0, 5.3836]; CRS: urn:ogc:def:crs:OGC:1.3:CRS84
- Koordinat (center_lat, center_lon): 20,000 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Catatan: GeoJSON dibaca streaming: hanya atribut yang diprofil; geometri hanya dilaporkan jenis dan bounding box (dari 600 fitur pertama).
- Catatan: File besar (81,912 fitur): atribut diprofil dari 20,000 fitur pertama.
- Sebaran per tahun, kolom `valid_on` (2020-04-01 s.d. 2020-04-01): 2020:20,000

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | adm4_name | adm4_name | text | text | 0.0% | 15,141 |  |  | 1 Ilir; 1 Ulu; 10 Ilir |  | panjang 2-36 |
| 2 | adm4_name1 | adm4_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 3 | adm4_name2 | adm4_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 4 | adm4_name3 | adm4_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 5 | adm4_pcode | adm4_pcode | text | text | 0.0% | 20,000 |  |  | ID1671060006; ID1671020008; ID1671062001 |  | panjang 12-12; KANDIDAT KUNCI |
| 6 | adm3_name | adm3_name | text | text | 0.0% | 5,717 |  |  | Ilir Timur II; Seberang Ulu I; Ilir Timur III |  | panjang 2-31 |
| 7 | adm3_name1 | adm3_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 8 | adm3_name2 | adm3_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 9 | adm3_name3 | adm3_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 10 | adm3_pcode | adm3_pcode | text | text | 0.0% | 6,023 |  |  | ID1671060; ID1671020; ID1671062 |  | panjang 9-9 |
| 11 | adm2_name | adm2_name | text | text | 0.0% | 512 |  |  | Kota Palembang; Kolaka; Maros |  | panjang 4-26 |
| 12 | adm2_name1 | adm2_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 13 | adm2_name2 | adm2_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 14 | adm2_name3 | adm2_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 15 | adm2_pcode | adm2_pcode | text | text | 0.0% | 515 |  |  | ID1671; ID7404; ID7308 |  | panjang 6-6 |
| 16 | adm1_name | adm1_name | text | text | 0.0% | 34 |  |  | Jawa Tengah (2049); Jawa Timur (2040); Jawa Barat (2032); Aceh (1999)… |  | panjang 4-26 |
| 17 | adm1_name1 | adm1_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 18 | adm1_name2 | adm1_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 19 | adm1_name3 | adm1_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 20 | adm1_pcode | adm1_pcode | text | text | 0.0% | 34 |  |  | ID33 (2049); ID35 (2040); ID32 (2032); ID11 (1999); ID12 (1306); ID94… |  | panjang 4-4 |
| 21 | adm0_name | adm0_name | text | text | 0.0% | 1 |  |  | Indonesia (20000) |  | kolom KONSTAN (selalu 'Indonesia'); panjang 9-9 |
| 22 | adm0_name1 | adm0_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 23 | adm0_name2 | adm0_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 24 | adm0_name3 | adm0_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 25 | adm0_pcode | adm0_pcode | text | text | 0.0% | 1 |  |  | ID (20000) |  | kolom KONSTAN (selalu 'ID'); panjang 2-2 |
| 26 | valid_on | valid_on | date | date | 0.0% | 1 | 2020-04-01 | 2020-04-01 | 2020-04-01 |  | kolom KONSTAN (selalu '2020-04-01') |
| 27 | valid_to | valid_to | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 28 | area_sqkm | area_sqkm | numeric | numeric | 0.0% | 20,000 | 6.029e-05 | 3363.80521563 | 2.0806389; 0.20872376; 0.1560234 |  | NILAI EKSTREM: min 6.029e-05 / maks 3363.81 vs p01-p99 = 0.200695..280.156; maks 8 digit desimal |
| 29 | version | version | text | text | 0.0% | 1 |  |  | v01 (20000) |  | kolom KONSTAN (selalu 'v01'); panjang 3-3 |
| 30 | lang | lang | text | text | 0.0% | 1 |  |  | en (20000) |  | kolom KONSTAN (selalu 'en'); panjang 2-2 |
| 31 | lang1 | lang1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 32 | lang2 | lang2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 33 | lang3 | lang3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 34 | adm4_ref_name | adm4_ref_name | text | text | 0.0% | 15,141 |  |  | 1 Ilir; 1 Ulu; 10 Ilir |  | panjang 2-36 |
| 35 | center_lat | center_lat | numeric | numeric(10,7) | 0.0% | 19,977 | -10.9056992 | 5.8770176 | -2.9809785; -3.01267; -2.98375105 |  | lintang |
| 36 | center_lon | center_lon | numeric | numeric(10,7) | 0.0% | 20,000 | 95.06098582 | 140.98793434 | 104.81521076; 104.75141721; 104.77007568 |  | bujur |
| 37 | _geometry_type | geometry_type | text | text | 0.0% | 2 |  |  | Polygon (19336); MultiPolygon (664) |  | panjang 7-12 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,adm4_name,adm4_name1,adm4_name2,adm4_name3,adm4_pcode,adm3_name,adm3_name1,adm3_name2,adm3_name3,adm3_pcode,adm2_name,adm2_name1,adm2_name2,adm2_name3,adm2_pcode,adm1_name,adm1_name1,adm1_name2,adm1_name3,adm1_pcode,adm0_name,adm0_name1,adm0_name2,adm0_name3,adm0_pcode,valid_on,valid_to,area_sqkm,version,lang,lang1,lang2,lang3,adm4_ref_name,center_lat,center_lon,_geometry_type
1,1 Ilir,,,,ID1671060006,Ilir Timur II,,,,ID1671060,Kota Palembang,,,,ID1671,Sumatera Selatan,,,,ID16,Indonesia,,,,ID,2020-04-01,,2.0806389,v01,en,,,,1 Ilir,-2.9809785,104.81521076,Polygon
2,1 Ulu,,,,ID1671020008,Seberang Ulu I,,,,ID1671020,Kota Palembang,,,,ID1671,Sumatera Selatan,,,,ID16,Indonesia,,,,ID,2020-04-01,,0.20872376,v01,en,,,,1 Ulu,-3.01267,104.75141721,Polygon
3,10 Ilir,,,,ID1671062001,Ilir Timur III,,,,ID1671062,Kota Palembang,,,,ID1671,Sumatera Selatan,,,,ID16,Indonesia,,,,ID,2020-04-01,,0.1560234,v01,en,,,,10 Ilir,-2.98375105,104.77007568,Polygon
4,11 Ilir,,,,ID1671062002,Ilir Timur III,,,,ID1671062,Kota Palembang,,,,ID1671,Sumatera Selatan,,,,ID16,Indonesia,,,,ID,2020-04-01,,0.07683293,v01,en,,,,11 Ilir,-2.98080535,104.76843798,Polygon
14357,Danau,,,,ID1888888888,Danau,,,,ID1888888,Danau,,,,ID1888,Lampung,,,,ID18,Indonesia,,,,ID,2020-04-01,,28.90618466,v01,en,,,,Danau,-4.9217293,103.88338146,Polygon
3440,Balah Aia,,,,ID1306060001,VII Koto Sungai Sariak,,,,ID1306060,Padang Pariaman,,,,ID1306,Sumatera Barat,,,,ID13,Indonesia,,,,ID,2020-04-01,,5.14281188,v01,en,,,,Balah Aia,-0.6127712,100.19126077,MultiPolygon
12154,Cibanteng,,,,ID3203230008,Sukaresmi,,,,ID3203230,Cianjur,,,,ID3203,Jawa Barat,,,,ID32,Indonesia,,,,ID,2020-04-01,,11.80310722,v01,en,,,,Cibanteng,-6.68431745,107.08315362,Polygon
```

### SRC-11 / idn_adminlines.geojson   [di luar cakupan model (garis batas)]
- Format: geojson (reader: geojson) | 399,899,482 byte
- SHA-256: `be7ae0fdff02a12ff612aaf758742b3a11c60ba53e455ec6227f522e2d7a5bce`
- Baris: 252,741 (profil memakai 20,000 baris) | kolom: 8 | baris duplikat penuh: 19,995
- Geometri: fitur 252,741; jenis (sampel) {'LineString': 20000}; bbox [xmin,ymin,xmax,ymax] = [104.298, -6.1686, 105.818, -5.5783]; CRS: urn:ogc:def:crs:OGC:1.3:CRS84
- Catatan: GeoJSON dibaca streaming: hanya atribut yang diprofil; geometri hanya dilaporkan jenis dan bounding box (dari 600 fitur pertama).
- Catatan: File besar (252,741 fitur): atribut diprofil dari 20,000 fitur pertama.
- Sebaran per tahun, kolom `valid_on` (2020-04-01 s.d. 2020-04-01): 2020:20,000

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | adm_level | adm_level | integer | integer | 0.0% | 5 | 1 | 99 | 4 (11836); 3 (5590); 2 (1629); 99 (637); 1 (308) |  |  |
| 2 | name | name | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 3 | valid_on | valid_on | date | date | 0.0% | 1 | 2020-04-01 | 2020-04-01 | 2020-04-01 |  | kolom KONSTAN (selalu '2020-04-01') |
| 4 | valid_to | valid_to | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 5 | version | version | text | text | 0.0% | 1 |  |  | v01 (20000) |  | kolom KONSTAN (selalu 'v01'); panjang 3-3 |
| 6 | right_pcod | right_pcod | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 7 | left_pcod | left_pcod | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 8 | _geometry_type | geometry_type | text | text | 0.0% | 1 |  |  | LineString (20000) |  | kolom KONSTAN (selalu 'LineString'); panjang 10-10 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,adm_level,name,valid_on,valid_to,version,right_pcod,left_pcod,_geometry_type
1,99,,2020-04-01,,v01,,,LineString
2,99,,2020-04-01,,v01,,,LineString
3,99,,2020-04-01,,v01,,,LineString
4,99,,2020-04-01,,v01,,,LineString
14357,3,,2020-04-01,,v01,,,LineString
3440,4,,2020-04-01,,v01,,,LineString
12154,3,,2020-04-01,,v01,,,LineString
```

### SRC-11 / idn_adminpoints.geojson   [di luar cakupan model (titik pusat semua level)]
- Format: geojson (reader: geojson) | 24,946,052 byte
- SHA-256: `4880f9f9b62e17c9b0a6170ce69a2b7bd9a04d5867dedd5544a7dfd48920e813`
- Baris: 30,626 | kolom: 38 | baris duplikat penuh: 0
- Kunci komposit unik (terdeteksi otomatis, bukan keputusan): (area_sqkm, admin_level) | (x_coord, admin_level)
- Geometri: fitur 30,626; jenis (sampel) {'Point': 30626}; bbox [xmin,ymin,xmax,ymax] = [95.3309, -10.687, 140.8114, 5.8395]; CRS: urn:ogc:def:crs:OGC:1.3:CRS84
- Koordinat (y_coord, x_coord): 30,626 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Catatan: GeoJSON dibaca streaming: hanya atribut yang diprofil; geometri hanya dilaporkan jenis dan bounding box (dari 600 fitur pertama).
- Sebaran per tahun, kolom `valid_on` (2020-04-01 s.d. 2020-04-01): 2020:30,626

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | admin_level | admin_level | integer | integer | 0.0% | 5 | 0 | 4 | 4 (23000); 3 (7069); 2 (522); 1 (34); 0 (1) |  |  |
| 2 | name | name | text | text | 0.0% | 23,479 |  |  | Indonesia; Aceh; Bali |  | panjang 2-36 |
| 3 | name1 | name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 4 | name2 | name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 5 | name3 | name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 6 | adm0_pcode | adm0_pcode | text | text | 0.0% | 1 |  |  | ID (30626) |  | kolom KONSTAN (selalu 'ID'); panjang 2-2 |
| 7 | adm0_name | adm0_name | text | text | 0.0% | 1 |  |  | Indonesia (30626) |  | kolom KONSTAN (selalu 'Indonesia'); panjang 9-9 |
| 8 | valid_on | valid_on | date | date | 0.0% | 1 | 2020-04-01 | 2020-04-01 | 2020-04-01 |  | kolom KONSTAN (selalu '2020-04-01') |
| 9 | valid_to | valid_to | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 10 | area_sqkm | area_sqkm | numeric | numeric | 0.0% | 30,589 | 6.029e-05 | 1891077.03118032 | 1891077.03118032; 56778.56250085; 5587.80831016 |  | NILAI EKSTREM: min 6.029e-05 / maks 1.89108e+06 vs p01-p99 = 0.246809..2697.88; maks 8 digit desimal |
| 11 | version | version | text | text | 0.0% | 1 |  |  | v01 (30626) |  | kolom KONSTAN (selalu 'v01'); panjang 3-3 |
| 12 | lang | lang | text | text | 0.0% | 1 |  |  | en (30626) |  | kolom KONSTAN (selalu 'en'); panjang 2-2 |
| 13 | lang1 | lang1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 14 | lang2 | lang2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 15 | lang3 | lang3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 16 | y_coord | y_coord | numeric | numeric | 0.0% | 30,480 | -10.9056992 | 5.89393475 | 0.11511615; 3.91056155; -8.4553126 |  | maks 8 digit desimal |
| 17 | x_coord | x_coord | numeric | numeric | 0.0% | 30,551 | 95.06098582 | 140.98793434 | 113.31613885; 97.149714; 115.27069877 |  | maks 8 digit desimal |
| 18 | adm1_pcode | adm1_pcode | text | text | 0.0% | 34 |  |  | ID35 (3082); ID33 (2986); ID32 (2959); ID11 (2506); ID12 (2359); ID94… |  | panjang 4-4 |
| 19 | adm1_name | adm1_name | text | text | 0.0% | 34 |  |  | Jawa Timur (3082); Jawa Tengah (2986); Jawa Barat (2959); Aceh (2506)… |  | panjang 4-26 |
| 20 | adm1_name1 | adm1_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 21 | adm1_name2 | adm1_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 22 | adm1_name3 | adm1_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 23 | adm2_pcode | adm2_pcode | text | text | 0.1% | 522 |  |  | ID1107; ID1112; ID1108 |  | panjang 6-6 |
| 24 | adm2_name | adm2_name | text | text | 0.1% | 519 |  |  | Aceh Barat; Aceh Barat Daya; Aceh Besar |  | panjang 4-26 |
| 25 | adm2_name1 | adm2_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 26 | adm2_name2 | adm2_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 27 | adm2_name3 | adm2_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 28 | adm3_pcode | adm3_pcode | text | text | 1.8% | 7,069 |  |  | ID1306050; ID1306052; ID1612030 |  | panjang 9-9 |
| 29 | adm3_name | adm3_name | text | text | 1.8% | 6,679 |  |  | 2 X 11 Enam Lingkung; 2 X 11 Kayu Tanam; Abab |  | panjang 2-31 |
| 30 | adm3_name1 | adm3_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 31 | adm3_name2 | adm3_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 32 | adm3_name3 | adm3_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 33 | adm4_pcode | adm4_pcode | text | text | 24.9% | 23,000 |  |  | ID1671060006; ID1671020008; ID1671062001 |  | panjang 12-12 |
| 34 | adm4_name | adm4_name | text | text | 24.9% | 17,386 |  |  | 1 Ilir; 1 Ulu; 10 Ilir |  | panjang 2-36 |
| 35 | adm4_name1 | adm4_name1 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 36 | adm4_name2 | adm4_name2 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 37 | adm4_name3 | adm4_name3 | empty | text | 100.0% | 0 |  |  |  |  | Kolom kosong seluruhnya. |
| 38 | _geometry_type | geometry_type | text | text | 0.0% | 1 |  |  | Point (30626) |  | kolom KONSTAN (selalu 'Point'); panjang 5-5 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,admin_level,name,name1,name2,name3,adm0_pcode,adm0_name,valid_on,valid_to,area_sqkm,version,lang,lang1,lang2,lang3,y_coord,x_coord,adm1_pcode,adm1_name,adm1_name1,adm1_name2,adm1_name3,adm2_pcode,adm2_name,adm2_name1,adm2_name2,adm2_name3,adm3_pcode,adm3_name,adm3_name1,adm3_name2,adm3_name3,adm4_pcode,adm4_name,adm4_name1,adm4_name2,adm4_name3,_geometry_type
1,0,Indonesia,,,,ID,Indonesia,2020-04-01,,1891077.03118032,v01,en,,,,0.11511615,113.31613885,,,,,,,,,,,,,,,,,,,,,Point
2,1,Aceh,,,,ID,Indonesia,2020-04-01,,56778.56250085,v01,en,,,,3.91056155,97.149714,ID11,Aceh,,,,,,,,,,,,,,,,,,,Point
3,1,Bali,,,,ID,Indonesia,2020-04-01,,5587.80831016,v01,en,,,,-8.4553126,115.27069877,ID51,Bali,,,,,,,,,,,,,,,,,,,Point
4,1,Banten,,,,ID,Indonesia,2020-04-01,,9357.11774109,v01,en,,,,-6.43769535,106.13333543,ID36,Banten,,,,,,,,,,,,,,,,,,,Point
20898,4,Cipenjo,,,,ID,Indonesia,2020-04-01,,4.24275948,v01,en,,,,-6.388825,106.9932842,ID32,Jawa Barat,,,,ID3201,Bogor,,,,ID3201180,Cileungsi,,,,ID3201180021,Cipenjo,,,,Point
24182,4,Fataatu Timur,,,,ID,Indonesia,2020-04-01,,4.2273064,v01,en,,,,-8.58600155,121.74612142,ID53,Nusa Tenggara Timur,,,,ID5311,Ende,,,,ID5311071,Wewaria,,,,ID5311071010,Fataatu Timur,,,,Point
20944,4,Cipinang Muara,,,,ID,Indonesia,2020-04-01,,2.6434725,v01,en,,,,-6.226515,106.88837035,ID31,Dki Jakarta,,,,ID3172,Kota Jakarta Timur,,,,ID3172060,Jatinegara,,,,ID3172060004,Cipinang Muara,,,,Point
```

## SRC-12 - Penduduk, Laju, Kepadatan menurut Provinsi (BPS)
- Sumber: https://www.bps.go.id
- Lisensi: Data publik BPS (atribusi BPS)
- Grain: provinsi x tahun (satu file per tahun)
- Status kesiapan: **READY**
- Pemeriksaan kolom yang diharapkan: provinsi: ADA; tahun: ADA; penduduk: ADA; kepadatan: ADA

### SRC-12 / Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2022.csv
- Format: csv (reader: bps) | 2,831 byte
- SHA-256: `f0e9540cff81f7f6f7360f65b36f1b721a69edfe753a3e7e8bad58c10ae33044`
- Baris: 34 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (Provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari nama file (2022).
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: 6 baris catatan kaki setelah tabel diabaikan (mis. '1 Hasil Sensus Penduduk (SP) 2020 (September)/The Result of Population Census 2020 (September) ').
- Catatan: Header memakai baris 1; data baris 2-36.
- Sebaran per tahun, kolom `tahun` (2022 s.d. 2022): 2022:34

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| penduduk > 0: `1 <= Jumlah Penduduk (Ribu) <= +inf` | Jumlah Penduduk (Ribu) | 34 | 0 | 0.00% |  |
| persentase 0-100: `0 <= Persentase Penduduk <= 100` | Persentase Penduduk | 34 | 0 | 0.00% |  |
| kepadatan > 0: `1 <= Kepadatan Penduduk per km persegi (Km2) <= +…` | Kepadatan Penduduk per km persegi (Km2) | 34 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Provinsi | provinsi | text | text | 0.0% | 34 |  |  | Aceh (1); Sumatera Utara (1); Sumatera Barat (1); Riau (1); Jambi (1)… | Nama provinsi | panjang 4-25; KANDIDAT KUNCI |
| 2 | Jumlah Penduduk (Ribu) | jumlah_penduduk_ribu | numeric | numeric | 0.0% | 34 | 727.8 | 49405.8 | 5407.9; 15115.2; 5640.6 | Jumlah penduduk (ribu jiwa) | maks 1 digit desimal |
| 3 | Laju Pertumbuhan Penduduk per Tahun | laju_pertumbuhan_penduduk_per_tahun | numeric | numeric | 0.0% | 29 | 0.64 | 3.15 | 1.43; 1.21; 1.09 | Laju pertumbuhan penduduk per tahun (%) | maks 2 digit desimal |
| 4 | Persentase Penduduk | persentase_penduduk | numeric | numeric | 0.0% | 31 | 0.26 | 17.92 | 1.96; 5.48; 2.05 | Distribusi persentase penduduk (%) | maks 2 digit desimal |
| 5 | Kepadatan Penduduk per km persegi (Km2) | kepadatan_penduduk_per_km_persegi_km2 | integer | integer | 0.0% | 33 | 10 | 16158 | 74 (2); 95 (1); 209 (1); 134 (1); 100 (1); 102 (1); 273 (1); 90 (1) | Kepadatan penduduk (jiwa/km2) |  |
| 6 | Rasio Jenis Kelamin Penduduk | rasio_jenis_kelamin_penduduk | numeric | numeric | 0.0% | 30 | 98.0 | 113.5 | 100.9; 100.7; 101.5 | Rasio jenis kelamin (laki-laki per 100 perempuan) | maks 1 digit desimal |
| 7 | tahun | tahun | integer | integer | 0.0% | 1 | 2022 | 2022 | 2022 (34) | Tahun (diturunkan dari nama file) | kolom KONSTAN (selalu '2022'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,Provinsi,Jumlah Penduduk (Ribu),Laju Pertumbuhan Penduduk per Tahun,Persentase Penduduk,Kepadatan Penduduk per km persegi (Km2),Rasio Jenis Kelamin Penduduk,tahun
1,Aceh,5407.9,1.43,1.96,95,100.9,2022
2,Sumatera Utara,15115.2,1.21,5.48,209,100.7,2022
3,Sumatera Barat,5640.6,1.09,2.05,134,101.5,2022
4,Riau,6614.4,1.95,2.4,74,104.7,2022
21,Kalimantan Tengah,2741.1,1.51,0.99,18,107.6,2022
```

### SRC-12 / Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2023.csv
- Format: csv (reader: bps) | 2,385 byte
- SHA-256: `7a45da04a5a7c7ea24efff8dca66e5ef16d84847d8da3dcfbcd4674f6220bffe`
- Baris: 38 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (Provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari nama file (2023).
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: 2 baris catatan kaki setelah tabel diabaikan (mis. '1 Hasil Proyeksi Penduduk Indonesia 2020-2050 Hasil Sensus Penduduk 2020 (Pertengahan tahun/Juni)/Indonesia Po').
- Catatan: Header memakai baris 1; data baris 2-40.
- Sebaran per tahun, kolom `tahun` (2023 s.d. 2023): 2023:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| penduduk > 0: `1 <= Jumlah Penduduk (Ribu) <= +inf` | Jumlah Penduduk (Ribu) | 34 | 0 | 0.00% |  |
| persentase 0-100: `0 <= Persentase Penduduk <= 100` | Persentase Penduduk | 34 | 0 | 0.00% |  |
| kepadatan > 0: `1 <= Kepadatan Penduduk per km persegi (Km2) <= +…` | Kepadatan Penduduk per km persegi (Km2) | 34 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Provinsi | provinsi | text | text | 0.0% | 38 |  |  | Aceh (1); Sumatera Utara (1); Sumatera Barat (1); Riau (1); Jambi (1)… | Nama provinsi | panjang 4-25; KANDIDAT KUNCI |
| 2 | Jumlah Penduduk (Ribu) | jumlah_penduduk_ribu | numeric | numeric | 0.0% | 35 | 730.0 | 49860.3 | 5482.5; 15386.6; 5757.2 | Jumlah penduduk (ribu jiwa) | 4 nilai berupa token kosong ('...') - jadikan NULL di staging; maks 1 digit desimal |
| 3 | Laju Pertumbuhan Penduduk per Tahun | laju_pertumbuhan_penduduk_per_tahun | numeric | numeric | 0.0% | 30 | 0.38 | 1.69 | 1.41; 1.43; 1.45 | Laju pertumbuhan penduduk per tahun (%) | 4 nilai berupa token kosong ('...') - jadikan NULL di staging; maks 2 digit desimal |
| 4 | Persentase Penduduk | persentase_penduduk | numeric | numeric | 0.0% | 34 | 0.26 | 17.89 | 1.97; 5.52; 2.07 | Distribusi persentase penduduk (%) | 4 nilai berupa token kosong ('...') - jadikan NULL di staging; maks 2 digit desimal |
| 5 | Kepadatan Penduduk per km persegi (Km2) | kepadatan_penduduk_per_km_persegi_km2 | integer | integer | 0.0% | 34 | 10 | 16146 | ... (4); 101 (2); 96 (1); 212 (1); 137 (1); 74 (1); 75 (1); 104 (1) | Kepadatan penduduk (jiwa/km2) | 4 nilai berupa token kosong ('...') - jadikan NULL di staging |
| 6 | Rasio Jenis Kelamin Penduduk | rasio_jenis_kelamin_penduduk | numeric | numeric | 0.0% | 29 | 98.0 | 112.9 | 100.9; 100.7; 101.5 | Rasio jenis kelamin (laki-laki per 100 perempuan) | 4 nilai berupa token kosong ('...') - jadikan NULL di staging; maks 1 digit desimal |
| 7 | tahun | tahun | integer | integer | 0.0% | 1 | 2023 | 2023 | 2023 (38) | Tahun (diturunkan dari nama file) | kolom KONSTAN (selalu '2023'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,Provinsi,Jumlah Penduduk (Ribu),Laju Pertumbuhan Penduduk per Tahun,Persentase Penduduk,Kepadatan Penduduk per km persegi (Km2),Rasio Jenis Kelamin Penduduk,tahun
1,Aceh,5482.5,1.41,1.97,96,100.9,2023
2,Sumatera Utara,15386.6,1.43,5.52,212,100.7,2023
3,Sumatera Barat,5757.2,1.45,2.07,137,101.5,2023
4,Riau,6642.9,1.4,2.38,74,104.6,2023
10,Kepulauan Riau,2152.6,1.53,0.77,260,103.6,2023
22,Kalimantan Selatan,4222.3,1.31,1.52,114,102.4,2023
```

### SRC-12 / Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2024.csv
- Format: csv (reader: bps) | 2,706 byte
- SHA-256: `f6294041e6e0b29a45192319bb40228502a5c9e52876b850a92ca61e68721aba`
- Baris: 38 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (Provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari nama file (2024).
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: 3 baris catatan kaki setelah tabel diabaikan (mis. '1 Hasil Proyeksi Penduduk Indonesia 2020-2050 Hasil Sensus Penduduk 2020 (Pertengahan tahun/Juni)/Indonesia Po').
- Catatan: Header memakai baris 1; data baris 2-40.
- Sebaran per tahun, kolom `tahun` (2024 s.d. 2024): 2024:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| penduduk > 0: `1 <= Jumlah Penduduk (Ribu) <= +inf` | Jumlah Penduduk (Ribu) | 38 | 0 | 0.00% |  |
| persentase 0-100: `0 <= Persentase Penduduk <= 100` | Persentase Penduduk | 38 | 0 | 0.00% |  |
| kepadatan > 0: `1 <= Kepadatan Penduduk per km persegi (Km2) <= +…` | Kepadatan Penduduk per km persegi (Km2) | 38 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Provinsi | provinsi | text | text | 0.0% | 38 |  |  | Aceh (1); Sumatera Utara (1); Sumatera Barat (1); Riau (1); Jambi (1)… | Nama provinsi | panjang 4-25; KANDIDAT KUNCI |
| 2 | Jumlah Penduduk (Ribu) | jumlah_penduduk_ribu | numeric | numeric | 0.0% | 38 | 542.1 | 50345.2 | 5554.8; 15588.5; 5836.2 | Jumlah penduduk (ribu jiwa) | maks 1 digit desimal |
| 3 | Laju Pertumbuhan Penduduk per Tahun | laju_pertumbuhan_penduduk_per_tahun | numeric | numeric | 0.0% | 31 | 0.31 | 1.93 | 1.39; 1.4; 1.43 | Laju pertumbuhan penduduk per tahun (%) | maks 2 digit desimal |
| 4 | Persentase Penduduk | persentase_penduduk | numeric | numeric | 0.0% | 37 | 0.19 | 17.88 | 1.97; 5.54; 2.07 | Distribusi persentase penduduk (%) | maks 2 digit desimal |
| 5 | Kepadatan Penduduk per km persegi (Km2) | kepadatan_penduduk_per_km_persegi_km2 | integer | integer | 0.0% | 37 | 5 | 16165 | 102 (2); 98 (1); 215 (1); 139 (1); 75 (1); 76 (1); 105 (1); 281 (1) | Kepadatan penduduk (jiwa/km2) |  |
| 6 | Rasio Jenis Kelamin Penduduk | rasio_jenis_kelamin_penduduk | numeric | numeric | 0.0% | 32 | 97.9 | 114.5 | 100.9; 100.8; 101.5 | Rasio jenis kelamin (laki-laki per 100 perempuan) | maks 1 digit desimal |
| 7 | tahun | tahun | integer | integer | 0.0% | 1 | 2024 | 2024 | 2024 (38) | Tahun (diturunkan dari nama file) | kolom KONSTAN (selalu '2024'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,Provinsi,Jumlah Penduduk (Ribu),Laju Pertumbuhan Penduduk per Tahun,Persentase Penduduk,Kepadatan Penduduk per km persegi (Km2),Rasio Jenis Kelamin Penduduk,tahun
1,Aceh,5554.8,1.39,1.97,98,100.9,2024
2,Sumatera Utara,15588.5,1.4,5.54,215,100.8,2024
3,Sumatera Barat,5836.2,1.43,2.07,139,101.5,2024
4,Riau,6728.1,1.37,2.39,75,104.4,2024
10,Kepulauan Riau,2183.3,1.5,0.78,264,103.3,2024
22,Kalimantan Selatan,4273.4,1.29,1.52,115,102.3,2024
```

### SRC-12 / Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2025.csv
- Format: csv (reader: bps) | 2,633 byte
- SHA-256: `3479478f44296af8fdb8549344f90b89e169b424b20a27605c224efa6c8ecf12`
- Baris: 38 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (Provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari nama file (2025).
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: 5 baris catatan kaki setelah tabel diabaikan (mis. '1Hasil Proyeksi Penduduk Indonesia 2020-2050 Hasil Sensus Penduduk 2020 (Pertengahan tahun/Juni)/ Indonesia Po').
- Catatan: Header memakai baris 1; data baris 2-40.
- Sebaran per tahun, kolom `tahun` (2025 s.d. 2025): 2025:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| penduduk > 0: `1 <= Jumlah Penduduk (Ribu) <= +inf` | Jumlah Penduduk (Ribu) | 38 | 0 | 0.00% |  |
| persentase 0-100: `0 <= Persentase Penduduk <= 100` | Persentase Penduduk | 38 | 0 | 0.00% |  |
| kepadatan > 0: `1 <= Kepadatan Penduduk per km persegi (Km2) <= +…` | Kepadatan Penduduk per km persegi (Km2) | 38 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Provinsi | provinsi | text | text | 0.0% | 38 |  |  | Aceh (1); Sumatera Utara (1); Sumatera Barat (1); Riau (1); Jambi (1)… | Nama provinsi | panjang 4-25; KANDIDAT KUNCI |
| 2 | Jumlah Penduduk (Ribu) | jumlah_penduduk_ribu | numeric | numeric | 0.0% | 38 | 549.7 | 50759.0 | 5626; 15785.8; 5914.3 | Jumlah penduduk (ribu jiwa) | maks 1 digit desimal |
| 3 | Laju Pertumbuhan Penduduk per Tahun | laju_pertumbuhan_penduduk_per_tahun | numeric | numeric | 0.0% | 32 | 0.23 | 2.67 | 1.37; 1.41; 1.34 | Laju pertumbuhan penduduk per tahun (%) | maks 2 digit desimal |
| 4 | Persentase Penduduk | persentase_penduduk | numeric | numeric | 0.0% | 36 | 0.19 | 17.85 | 1.98; 5.55; 2.08 | Distribusi persentase penduduk (%) | maks 2 digit desimal |
| 5 | Kepadatan Penduduk per km persegi (Km2) | kepadatan_penduduk_per_km_persegi_km2 | integer | integer | 0.0% | 37 | 5 | 16155 | 103 (2); 99 (1); 218 (1); 140 (1); 76 (1); 77 (1); 106 (1); 284 (1) | Kepadatan penduduk (jiwa/km2) |  |
| 6 | Rasio Jenis Kelamin Penduduk | rasio_jenis_kelamin_penduduk | numeric | numeric | 0.0% | 32 | 97.8 | 114.0 | 100.9; 100.8; 101.5 | Rasio jenis kelamin (laki-laki per 100 perempuan) | maks 1 digit desimal |
| 7 | tahun | tahun | integer | integer | 0.0% | 1 | 2025 | 2025 | 2025 (38) | Tahun (diturunkan dari nama file) | kolom KONSTAN (selalu '2025'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,Provinsi,Jumlah Penduduk (Ribu),Laju Pertumbuhan Penduduk per Tahun,Persentase Penduduk,Kepadatan Penduduk per km persegi (Km2),Rasio Jenis Kelamin Penduduk,tahun
1,Aceh,5626,1.37,1.98,99,100.9,2025
2,Sumatera Utara,15785.8,1.37,5.55,218,100.8,2025
3,Sumatera Barat,5914.3,1.41,2.08,140,101.5,2025
4,Riau,6811.2,1.34,2.39,76,104.3,2025
10,Kepulauan Riau,2213.5,1.48,0.78,268,103.1,2025
22,Kalimantan Selatan,4323.3,1.26,1.52,116,102.2,2025
```

### SRC-12 / Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2026.csv
- Format: csv (reader: bps) | 2,599 byte
- SHA-256: `64c20c111add7c5c243e01447256372c9fc9308efecdf360998f1fcaaacf4255`
- Baris: 38 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (Provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari nama file (2026).
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: 2 baris catatan kaki setelah tabel diabaikan (mis. '1Proyeksi Penduduk Indonesia 2020-2050 Hasil Sensus Penduduk 2020 (Pertengahan tahun/Juni)/ Indonesia Populati').
- Catatan: Header memakai baris 1; data baris 2-40.
- Sebaran per tahun, kolom `tahun` (2026 s.d. 2026): 2026:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| penduduk > 0: `1 <= Jumlah Penduduk (Ribu) <= +inf` | Jumlah Penduduk (Ribu) | 38 | 0 | 0.00% |  |
| persentase 0-100: `0 <= Persentase Penduduk <= 100` | Persentase Penduduk | 38 | 0 | 0.00% |  |
| kepadatan > 0: `1 <= Kepadatan Penduduk per km persegi (Km2) <= +…` | Kepadatan Penduduk per km persegi (Km2) | 38 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Provinsi | provinsi | text | text | 0.0% | 38 |  |  | Aceh (1); Sumatera Utara (1); Sumatera Barat (1); Riau (1); Jambi (1)… | Nama provinsi | panjang 4-25; KANDIDAT KUNCI |
| 2 | Jumlah Penduduk (Ribu) | jumlah_penduduk_ribu | numeric | numeric | 0.0% | 38 | 557.2 | 51163.9 | 5695.9; 15978.6; 5991.6 | Jumlah penduduk (ribu jiwa) | maks 1 digit desimal |
| 3 | Laju Pertumbuhan Penduduk per Tahun | laju_pertumbuhan_penduduk_per_tahun | numeric | numeric | 0.0% | 29 | 0.18 | 3.06 | 1.34; 1.39; 1.31 | Laju pertumbuhan penduduk per tahun (%) | maks 2 digit desimal |
| 4 | Persentase Penduduk | persentase_penduduk | numeric | numeric | 0.0% | 35 | 0.19 | 17.81 | 1.98; 5.56; 2.09 | Distribusi persentase penduduk (%) | maks 2 digit desimal |
| 5 | Kepadatan Penduduk per km persegi (Km2) | kepadatan_penduduk_per_km_persegi_km2 | integer | integer | 0.0% | 37 | 5 | 16129 | 104 (2); 100 (1); 221 (1); 142 (1); 77 (1); 78 (1); 108 (1); 287 (1) | Kepadatan penduduk (jiwa/km2) |  |
| 6 | Rasio Jenis Kelamin Penduduk | rasio_jenis_kelamin_penduduk | numeric | numeric | 0.0% | 33 | 97.7 | 113.5 | 100.9; 100.8; 101.5 | Rasio jenis kelamin (laki-laki per 100 perempuan) | maks 1 digit desimal |
| 7 | tahun | tahun | integer | integer | 0.0% | 1 | 2026 | 2026 | 2026 (38) | Tahun (diturunkan dari nama file) | kolom KONSTAN (selalu '2026'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,Provinsi,Jumlah Penduduk (Ribu),Laju Pertumbuhan Penduduk per Tahun,Persentase Penduduk,Kepadatan Penduduk per km persegi (Km2),Rasio Jenis Kelamin Penduduk,tahun
1,Aceh,5695.9,1.34,1.98,100,100.9,2026
2,Sumatera Utara,15978.6,1.34,5.56,221,100.8,2026
3,Sumatera Barat,5991.6,1.39,2.09,142,101.5,2026
4,Riau,6892.4,1.31,2.4,77,104.1,2026
10,Kepulauan Riau,2243.1,1.45,0.78,275,102.9,2026
22,Kalimantan Selatan,4372.1,1.24,1.52,118,102.1,2026
```
