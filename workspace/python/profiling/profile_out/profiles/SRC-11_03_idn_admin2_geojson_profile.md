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
