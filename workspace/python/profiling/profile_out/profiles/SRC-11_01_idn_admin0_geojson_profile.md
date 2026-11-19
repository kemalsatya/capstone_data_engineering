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
