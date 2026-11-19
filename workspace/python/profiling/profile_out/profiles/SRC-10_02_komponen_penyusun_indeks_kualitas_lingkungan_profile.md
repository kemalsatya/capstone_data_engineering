### SRC-10 / Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2022.csv
- Format: csv (reader: bps) | 2,031 byte
- SHA-256: `bc105c9ddf344f82b6c7cbf7e4ed24c1d2a576fb22848f4522ed22a1c0d3b780`
- Baris: 38 | kolom: 8 | baris duplikat penuh: 0
- Uji kunci (provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari baris header 4.
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: Header memakai baris 3, 4; data baris 5-43.
- Sebaran per tahun, kolom `tahun` (2022 s.d. 2022): 2022:38

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
| 2 | Indeks Kualitas Udara | indeks_kualitas_udara | numeric | numeric | 0.0% | 35 | 68.06 | 95.79 | 90.62; 89.69; 90.65 | Komponen IKLH: indeks kualitas udara (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 3 | Indeks Kualitas Air | indeks_kualitas_air | numeric | numeric | 0.0% | 35 | 39.31 | 62.0 | 60.41; 61.2; 55.64 | Komponen IKLH: indeks kualitas air sungai/permukaan (0-100); bukan ukuran ketersediaan air | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 4 | Indeks Kualitas Tutupan Lahan (IKTL) | indeks_kualitas_tutupan_lahan_iktl | numeric | numeric | 0.0% | 33 | 27.07 | 100.0 | 76.33; 48.9; 66.27 | Komponen IKLH: tutupan lahan (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 5 | Indeks Kualitas Lahan (IKL) | indeks_kualitas_lahan_ikl | numeric | numeric | 0.0% | 33 | 27.07 | 100.0 | 76.24; 48.69; 64.01 | Komponen IKLH: kualitas lahan (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 6 | Indeks Kualitas Ekosistem Gambut (IKEG) | indeks_kualitas_ekosistem_gambut_ikeg | numeric | numeric | 0.0% | 20 | 42.35 | 96.87 | 71.15; 42.35; 46.64 | Komponen IKLH: ekosistem gambut (0-100); '-' = provinsi tanpa gambut | 19 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 7 | Indeks Kualitas Air Laut (IKAL) | indeks_kualitas_air_laut_ikal | numeric | numeric | 0.0% | 34 | 63.3 | 89.48 | 89.2; 85.19; 88.32 | Komponen IKLH: air laut (0-100); '-' = tidak ada pengukuran | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 8 | tahun | tahun | integer | integer | 0.0% | 1 | 2022 | 2022 | 2022 (38) | Tahun (diturunkan dari baris header) | kolom KONSTAN (selalu '2022'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,provinsi,Indeks Kualitas Udara,Indeks Kualitas Air,Indeks Kualitas Tutupan Lahan (IKTL),Indeks Kualitas Lahan (IKL),Indeks Kualitas Ekosistem Gambut (IKEG),Indeks Kualitas Air Laut (IKAL),tahun
1,ACEH,90.62,60.41,76.33,76.24,71.15,89.2,2022
2,SUMATERA UTARA,89.69,61.2,48.9,48.69,42.35,85.19,2022
3,SUMATERA BARAT,90.65,55.64,66.27,64.01,46.64,88.32,2022
4,RIAU,90.69,53.88,51.4,50,66.54,83.95,2022
10,KEP. RIAU,90.27,56.79,59.15,58.29,63.58,85.56,2022
22,KALIMANTAN SELATAN,89.52,54.63,50.82,50.52,49.63,84.42,2022
```
