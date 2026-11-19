### SRC-10 / Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2023.csv
- Format: csv (reader: bps) | 2,120 byte
- SHA-256: `06ca43745149cedea0ade1f5e2b2f2605ba07cc2433960436d26229bec73f47d`
- Baris: 38 | kolom: 8 | baris duplikat penuh: 0
- Uji kunci (provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari baris header 4.
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: Header memakai baris 3, 4; data baris 5-43.
- Sebaran per tahun, kolom `tahun` (2023 s.d. 2023): 2023:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| indeks 0-100: `0 <= Indeks Kualitas Udara <= 100` | Indeks Kualitas Udara | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air <= 100` | Indeks Kualitas Air | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Tutupan Lahan (IKTL) <= 100` | Indeks Kualitas Tutupan Lahan (IKTL) | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Lahan (IKL) <= 100` | Indeks Kualitas Lahan (IKL) | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Ekosistem Gambut (IKEG) <= 1…` | Indeks Kualitas Ekosistem Gambut (IKEG) | 23 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air Laut (IKAL) <= 100` | Indeks Kualitas Air Laut (IKAL) | 36 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | provinsi | provinsi | text | text | 0.0% | 38 |  |  | ACEH (1); SUMATERA UTARA (1); SUMATERA BARAT (1); RIAU (1); JAMBI (1)… | Nama provinsi (HURUF BESAR; 38 provinsi) | panjang 4-20; KANDIDAT KUNCI |
| 2 | Indeks Kualitas Udara | indeks_kualitas_udara | numeric | numeric | 0.0% | 37 | 66.67 | 97.68 | 90.94; 90.9; 90.53 | Komponen IKLH: indeks kualitas udara (0-100) | maks 2 digit desimal |
| 3 | Indeks Kualitas Air | indeks_kualitas_air | numeric | numeric | 0.0% | 38 | 40.28 | 64.67 | 61.3; 60.27; 57.05 | Komponen IKLH: indeks kualitas air sungai/permukaan (0-100); bukan ukuran ketersediaan air | maks 2 digit desimal |
| 4 | Indeks Kualitas Tutupan Lahan (IKTL) | indeks_kualitas_tutupan_lahan_iktl | numeric | numeric | 0.0% | 34 | 27.17 | 100.0 | 76.52; 49.78; 66.95 | Komponen IKLH: tutupan lahan (0-100) | maks 2 digit desimal |
| 5 | Indeks Kualitas Lahan (IKL) | indeks_kualitas_lahan_ikl | numeric | numeric | 0.0% | 36 | 27.17 | 100.0 | 76.51; 49.77; 68.98 | Komponen IKLH: kualitas lahan (0-100) | maks 2 digit desimal |
| 6 | Indeks Kualitas Ekosistem Gambut (IKEG) | indeks_kualitas_ekosistem_gambut_ikeg | numeric | numeric | 0.0% | 24 | 41.43 | 97.49 | 69.53; 42.38; 44.09 | Komponen IKLH: ekosistem gambut (0-100); '-' = provinsi tanpa gambut | 15 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 7 | Indeks Kualitas Air Laut (IKAL) | indeks_kualitas_air_laut_ikal | numeric | numeric | 0.0% | 37 | 68.56 | 86.83 | 86.75; 68.56; 86.19 | Komponen IKLH: air laut (0-100); '-' = tidak ada pengukuran | 2 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 8 | tahun | tahun | integer | integer | 0.0% | 1 | 2023 | 2023 | 2023 (38) | Tahun (diturunkan dari baris header) | kolom KONSTAN (selalu '2023'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,provinsi,Indeks Kualitas Udara,Indeks Kualitas Air,Indeks Kualitas Tutupan Lahan (IKTL),Indeks Kualitas Lahan (IKL),Indeks Kualitas Ekosistem Gambut (IKEG),Indeks Kualitas Air Laut (IKAL),tahun
1,ACEH,90.94,61.3,76.52,76.51,69.53,86.75,2023
2,SUMATERA UTARA,90.9,60.27,49.78,49.77,42.38,68.56,2023
3,SUMATERA BARAT,90.53,57.05,66.95,68.98,44.09,86.19,2023
4,RIAU,90.89,50.84,51.27,51.59,66.19,74.39,2023
10,KEP. RIAU,90.13,54.93,66.02,66.97,63.7,81.81,2023
22,KALIMANTAN SELATAN,92.85,55.64,52.05,52.08,49.19,79.94,2023
```
