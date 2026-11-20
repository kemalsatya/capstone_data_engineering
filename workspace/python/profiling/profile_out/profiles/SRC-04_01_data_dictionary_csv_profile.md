### SRC-04 / data_dictionary.csv   [dictionary]
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 6,442 byte
- SHA-256: `39c8a1b4b1d981ad4802c24699365d88366dd2ff0cb7ac4369017d6b42e49bbc`
- Baris: 45 | kolom: 4 | baris duplikat penuh: 0
- Uji kunci (column_name): UNIK (0 duplikat, 0 baris ber-null)

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | column_name | column_name | text | text | 0.0% | 45 |  |  | bps_kabkota_code (1); kabkota_name (1); prov_name (1); shapeName (1);… |  | panjang 8-24; KANDIDAT KUNCI |
| 2 | type_unit | type_unit | text | text | 0.0% | 16 |  |  | float, percent (14); boolean (7); categorical (3); text (3); float, m… |  | panjang 4-41 |
| 3 | group | group_col | text | text | 0.0% | 12 |  |  | land cover (11); socioeconomic (6); data-quality flag (6); weather (5… |  | panjang 4-23 |
| 4 | description | description | text | text | 0.0% | 43 |  |  | True if the zonal-statistics pull returned no valid pixels for this d… |  | panjang 28-323 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,column_name,type_unit,group,description
1,bps_kabkota_code,integer,identifier,"Official BPS kode wilayah for the regency, resolved through the bounda"
2,kabkota_name,text,identifier,Regency/city name as recorded by BPS (matched_bps_name).
3,prov_name,text,identifier,"Province name, BPS naming, 38 distinct values."
4,shapeName,text,identifier,Regency name as recorded in the geoBoundaries ADM2 boundary layer (joi
21,pct_cropland,"float, percent",land cover,"Percent of district area classified as cropland, ESA WorldCover v200."
19,pct_shrubland,"float, percent",land cover,"Percent of district area classified as shrubland, ESA WorldCover v200."
14,ntl_no_data,boolean,data-quality flag,True if the zonal-statistics pull returned no valid pixels for this di
```
