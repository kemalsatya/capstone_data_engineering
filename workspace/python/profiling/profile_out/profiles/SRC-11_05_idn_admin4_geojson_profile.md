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
