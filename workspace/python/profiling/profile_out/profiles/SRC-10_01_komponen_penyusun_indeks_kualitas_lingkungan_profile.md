### SRC-10 / Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2021.csv
- Format: csv (reader: bps) | 2,038 byte
- SHA-256: `5852fc451eb750b86c48ec6365d5584766d8f3d7719192747bfdeab4069fcaba`
- Baris: 38 | kolom: 8 | baris duplikat penuh: 0
- Uji kunci (provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari baris header 4.
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: Header memakai baris 3, 4; data baris 5-43.
- Sebaran per tahun, kolom `tahun` (2021 s.d. 2021): 2021:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| indeks 0-100: `0 <= Indeks Kualitas Udara <= 100` | Indeks Kualitas Udara | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air <= 100` | Indeks Kualitas Air | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Tutupan Lahan (IKTL) <= 100` | Indeks Kualitas Tutupan Lahan (IKTL) | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Lahan (IKL) <= 100` | Indeks Kualitas Lahan (IKL) | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Ekosistem Gambut (IKEG) <= 1…` | Indeks Kualitas Ekosistem Gambut (IKEG) | 19 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air Laut (IKAL) <= 100` | Indeks Kualitas Air Laut (IKAL) | 34 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | provinsi | provinsi | text | text | 0.0% | 38 |  |  | ACEH (1); SUMATERA UTARA (1); SUMATERA BARAT (1); RIAU (1); JAMBI (1)… | Nama provinsi (HURUF BESAR; 38 provinsi) | panjang 4-20; KANDIDAT KUNCI |
| 2 | Indeks Kualitas Udara | indeks_kualitas_udara | numeric | numeric | 0.0% | 34 | 66.52 | 95.6 | 89.63; 89.55; 90.22 | Komponen IKLH: indeks kualitas udara (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 3 | Indeks Kualitas Air | indeks_kualitas_air | numeric | numeric | 0.0% | 35 | 43.09 | 58.37 | 57.14; 53.72; 52.55 | Komponen IKLH: indeks kualitas air sungai/permukaan (0-100); bukan ukuran ketersediaan air | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 4 | Indeks Kualitas Tutupan Lahan (IKTL) | indeks_kualitas_tutupan_lahan_iktl | numeric | numeric | 0.0% | 33 | 26.25 | 100.0 | 76.63; 48.89; 66.29 | Komponen IKLH: tutupan lahan (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 5 | Indeks Kualitas Lahan (IKL) | indeks_kualitas_lahan_ikl | numeric | numeric | 0.0% | 34 | 26.25 | 100.0 | 76.52; 48.84; 66.24 | Komponen IKLH: kualitas lahan (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 6 | Indeks Kualitas Ekosistem Gambut (IKEG) | indeks_kualitas_ekosistem_gambut_ikeg | numeric | numeric | 0.0% | 19 | 46.27 | 96.97 | 71.45; 46.27; 51.97 | Komponen IKLH: ekosistem gambut (0-100); '-' = provinsi tanpa gambut | 19 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 7 | Indeks Kualitas Air Laut (IKAL) | indeks_kualitas_air_laut_ikal | numeric | numeric | 0.0% | 34 | 70.34 | 87.55 | 76.51; 81.43; 83.75 | Komponen IKLH: air laut (0-100); '-' = tidak ada pengukuran | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 8 | tahun | tahun | integer | integer | 0.0% | 1 | 2021 | 2021 | 2021 (38) | Tahun (diturunkan dari baris header) | kolom KONSTAN (selalu '2021'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,provinsi,Indeks Kualitas Udara,Indeks Kualitas Air,Indeks Kualitas Tutupan Lahan (IKTL),Indeks Kualitas Lahan (IKL),Indeks Kualitas Ekosistem Gambut (IKEG),Indeks Kualitas Air Laut (IKAL),tahun
1,ACEH,89.63,57.14,76.63,76.52,71.45,76.51,2021
2,SUMATERA UTARA,89.55,53.72,48.89,48.84,46.27,81.43,2021
3,SUMATERA BARAT,90.22,52.55,66.29,66.24,51.97,83.75,2021
4,RIAU,90.13,52.25,51.4,50.22,72.21,77.73,2021
10,KEP. RIAU,90.91,55.15,60.48,60.39,63.34,75.68,2021
22,KALIMANTAN SELATAN,89.15,54.75,50.48,50.26,56.47,76.45,2021
```
