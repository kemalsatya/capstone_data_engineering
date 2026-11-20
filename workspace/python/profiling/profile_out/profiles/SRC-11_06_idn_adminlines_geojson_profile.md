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
