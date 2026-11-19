### SRC-10 / Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2024.csv
- Format: csv (reader: bps) | 2,108 byte
- SHA-256: `820554f61013936b432f91caebed34b9ae574ba3c74c8d3cb54a75a6002649df`
- Baris: 38 | kolom: 8 | baris duplikat penuh: 0
- Uji kunci (provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari baris header 4.
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: Header memakai baris 3, 4; data baris 5-43.
- Sebaran per tahun, kolom `tahun` (2024 s.d. 2024): 2024:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| indeks 0-100: `0 <= Indeks Kualitas Udara <= 100` | Indeks Kualitas Udara | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air <= 100` | Indeks Kualitas Air | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Tutupan Lahan (IKTL) <= 100` | Indeks Kualitas Tutupan Lahan (IKTL) | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Lahan (IKL) <= 100` | Indeks Kualitas Lahan (IKL) | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Ekosistem Gambut (IKEG) <= 1…` | Indeks Kualitas Ekosistem Gambut (IKEG) | 23 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air Laut (IKAL) <= 100` | Indeks Kualitas Air Laut (IKAL) | 37 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | provinsi | provinsi | text | text | 0.0% | 38 |  |  | ACEH (1); SUMATERA UTARA (1); SUMATERA BARAT (1); RIAU (1); JAMBI (1)… | Nama provinsi (HURUF BESAR; 38 provinsi) | panjang 4-20; KANDIDAT KUNCI |
| 2 | Indeks Kualitas Udara | indeks_kualitas_udara | numeric | numeric | 0.0% | 37 | 69.84 | 96.41 | 92.81; 92.26; 92.27 | Komponen IKLH: indeks kualitas udara (0-100) | maks 2 digit desimal |
| 3 | Indeks Kualitas Air | indeks_kualitas_air | numeric | numeric | 0.0% | 37 | 41.22 | 65.32 | 63.25; 61.09; 53.16 | Komponen IKLH: indeks kualitas air sungai/permukaan (0-100); bukan ukuran ketersediaan air | maks 2 digit desimal |
| 4 | Indeks Kualitas Tutupan Lahan (IKTL) | indeks_kualitas_tutupan_lahan_iktl | numeric | numeric | 0.0% | 34 | 27.49 | 100.0 | 76.65; 50.26; 66.5 | Komponen IKLH: tutupan lahan (0-100) | maks 2 digit desimal |
| 5 | Indeks Kualitas Lahan (IKL) | indeks_kualitas_lahan_ikl | numeric | numeric | 0.0% | 34 | 27.49 | 100.0 | 76.66; 50.26; 66.63 | Komponen IKLH: kualitas lahan (0-100) | maks 2 digit desimal |
| 6 | Indeks Kualitas Ekosistem Gambut (IKEG) | indeks_kualitas_ekosistem_gambut_ikeg | numeric | numeric | 0.0% | 24 | 42.41 | 97.96 | 71.37; 42.41; 45.81 | Komponen IKLH: ekosistem gambut (0-100); '-' = provinsi tanpa gambut | 15 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 7 | Indeks Kualitas Air Laut (IKAL) | indeks_kualitas_air_laut_ikal | numeric | numeric | 0.0% | 38 | 70.82 | 88.34 | 83.24; 70.82; 84.18 | Komponen IKLH: air laut (0-100); '-' = tidak ada pengukuran | 1 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 8 | tahun | tahun | integer | integer | 0.0% | 1 | 2024 | 2024 | 2024 (38) | Tahun (diturunkan dari baris header) | kolom KONSTAN (selalu '2024'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,provinsi,Indeks Kualitas Udara,Indeks Kualitas Air,Indeks Kualitas Tutupan Lahan (IKTL),Indeks Kualitas Lahan (IKL),Indeks Kualitas Ekosistem Gambut (IKEG),Indeks Kualitas Air Laut (IKAL),tahun
1,ACEH,92.81,63.25,76.65,76.66,71.37,83.24,2024
2,SUMATERA UTARA,92.26,61.09,50.26,50.26,42.41,70.82,2024
3,SUMATERA BARAT,92.27,53.16,66.5,66.63,45.81,84.18,2024
4,RIAU,89.66,52.69,51.29,51.25,66.65,77.47,2024
10,KEP. RIAU,92.12,53.98,66.18,66.18,63.77,85.53,2024
22,KALIMANTAN SELATAN,96.41,56.08,52.2,52,44.54,84.27,2024
```
