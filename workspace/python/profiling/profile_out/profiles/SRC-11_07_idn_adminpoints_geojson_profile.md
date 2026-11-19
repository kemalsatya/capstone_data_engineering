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
