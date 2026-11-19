### SRC-03 / station_detail.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 14,985 byte
- SHA-256: `63e96ad743ebad6328628de0d4ff289678a78fdb3d88c6067fe5345dcb6d6d6c`
- Baris: 192 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (station_id): UNIK (0 duplikat, 0 baris ber-null)
- Koordinat (latitude, longitude): 192 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | station_id | station_id | integer | integer | 0.0% | 192 | 96001 | 97980 | 96001; 96003; 96004 | ID stasiun BMKG | KANDIDAT KUNCI |
| 2 | station_name | station_name | text | text | 0.0% | 192 |  |  | Stasiun Meteorologi Maimun Saleh; Balai Besar Meteorologi Klimatologi… | Nama stasiun | 4 nilai punya spasi di awal/akhir (perlu TRIM); panjang 22-62; KANDIDAT KUNCI |
| 3 | region_name | region_name | text | text | 0.0% | 150 |  |  | Kota Sabang; Kab. Badung; Kota Makassar | Nama kab/kota lokasi stasiun (berawalan Kab./Kota) | panjang 9-25 |
| 4 | latitude | latitude | numeric | numeric(10,7) | 0.0% | 187 | -10.76662 | 5.87655 | 5.87655; -8.7381; -5.14283 | Lintang stasiun | lintang |
| 5 | longitude | longitude | numeric | numeric(10,7) | 0.0% | 188 | 95.296 | 140.72 | 95.33785; 115.1786; 119.45227 | Bujur stasiun | bujur |
| 6 | region_id | region_id | integer | integer | 0.0% | 150 | 1 | 507 | 20; 272; 412 | ID wilayah internal dataset (bukan kode BPS) |  |
| 7 | province_id | province_id | integer | integer | 0.0% | 34 | 1 | 34 | 32 (15); 19 (13); 15 (11); 30 (11); 2 (10); 20 (8); 1 (7); 26 (7) | ID provinsi internal dataset (FK ke province_detail; bukan kode BPS) |  |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,station_id,station_name,region_name,latitude,longitude,region_id,province_id
1,96001,Stasiun Meteorologi Maimun Saleh,Kota Sabang,5.87655,95.33785,20,1
2,96003,Balai Besar Meteorologi Klimatologi  dan Geofisika Wilayah III,Kab. Badung,-8.7381,115.1786,272,17
3,96004,Balai Besar Meteorologi Klimatologi dan Geofisika Wilayah IV,Kota Makassar,-5.14283,119.45227,412,26
4,96009,Stasiun Meteorologi Malikussaleh,Kab. Aceh Utara,5.22869,96.94749,8,1
23,96107,Stasiun Klimatologi Riau,Kab. Kampar,0.407,101.217,76,4
159,97500,Stasiun Pemantau Atmosfer Global Puncak Vihara Klademak,Kota Sorong,-0.981,131.301,497,33
47,96293,Stasiun Meteorologi Maritim Panjang,Kota Bandar Lampung,-5.4721,105.321,136,8
```
