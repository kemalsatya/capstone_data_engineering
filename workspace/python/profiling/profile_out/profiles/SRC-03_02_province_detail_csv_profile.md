### SRC-03 / province_detail.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 614 byte
- SHA-256: `54b4f3b291ba1809a50c2f6b6d05d70e70fc5bc1803c292a76d8f12541b1f8b8`
- Baris: 34 | kolom: 2 | baris duplikat penuh: 0
- Uji kunci (province_id): UNIK (0 duplikat, 0 baris ber-null)

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | province_id | province_id | integer | integer | 0.0% | 34 | 1 | 34 | 1 (1); 2 (1); 3 (1); 4 (1); 5 (1); 6 (1); 7 (1); 8 (1) | ID provinsi internal dataset (1..34) | KANDIDAT KUNCI |
| 2 | province_name | province_name | text | text | 0.0% | 34 |  |  | Nanggroe Aceh Darussalam (1); Sumatera Utara (1); Sumatera Barat (1);… | Nama provinsi (penamaan lama, 34 provinsi) | panjang 4-24; KANDIDAT KUNCI |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,province_id,province_name
1,1,Nanggroe Aceh Darussalam
2,2,Sumatera Utara
3,3,Sumatera Barat
4,4,Riau
21,21,Kalimantan Tengah
```
