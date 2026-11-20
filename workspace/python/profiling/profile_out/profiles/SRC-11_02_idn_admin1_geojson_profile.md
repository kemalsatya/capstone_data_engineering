### SRC-11 / idn_admin1.geojson
- Format: geojson (reader: geojson) | 103,908,112 byte
- SHA-256: `7809c678b9f1596736cf74116beb9deecd5c1ced99b0ceb205347af1f3501e46`
- Baris: 34 | kolom: 23 | baris duplikat penuh: 0
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
| 22 | geom_geojson | geom_geojson | geometry_geojson | text | 0.0% | 34 |  |  | {"type":"MultiPolygon","coordinates":[[[[95.43560110000016,5.65650319… |  |  |
| 23 | _geometry_type | geometry_type | text | text | 0.0% | 1 |  |  | MultiPolygon (34) |  | kolom KONSTAN (selalu 'MultiPolygon'); panjang 12-12 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,adm1_name,adm1_name1,adm1_name2,adm1_name3,adm1_pcode,adm0_name,adm0_name1,adm0_name2,adm0_name3,adm0_pcode,valid_on,valid_to,area_sqkm,version,lang,lang1,lang2,lang3,adm1_ref_name,center_lat,center_lon,geom_geojson,_geometry_type
1,Aceh,,,,ID11,Indonesia,,,,ID,2020-04-01,,56778.56250085,v01,en,,,,Aceh,3.91056155,97.149714,"{""type"":""MultiPolygon"",""coordinates"":[[[[95.43560110000016,5.656503199",MultiPolygon
2,Bali,,,,ID51,Indonesia,,,,ID,2020-04-01,,5587.80831016,v01,en,,,,Bali,-8.4553126,115.27069877,"{""type"":""MultiPolygon"",""coordinates"":[[[[115.18527630000006,-8.0614671",MultiPolygon
3,Banten,,,,ID36,Indonesia,,,,ID,2020-04-01,,9357.11774109,v01,en,,,,Banten,-6.43769535,106.13333543,"{""type"":""MultiPolygon"",""coordinates"":[[[[106.0419687000001,-5.87866509",MultiPolygon
4,Bengkulu,,,,ID17,Indonesia,,,,ID,2020-04-01,,20026.36522406,v01,en,,,,Bengkulu,-3.6020366,102.47267131,"{""type"":""MultiPolygon"",""coordinates"":[[[[101.2933214000002,-2.28412629",MultiPolygon
21,Maluku Utara,,,,ID82,Indonesia,,,,ID,2020-04-01,,31508.24482424,v01,en,,,,Maluku Utara,-1.83165955,124.82958689,"{""type"":""MultiPolygon"",""coordinates"":[[[[127.95755880000002,2.22099530",MultiPolygon
```
