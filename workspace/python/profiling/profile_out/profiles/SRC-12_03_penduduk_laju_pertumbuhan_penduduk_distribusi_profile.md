### SRC-12 / Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2024.csv
- Format: csv (reader: bps) | 2,706 byte
- SHA-256: `f6294041e6e0b29a45192319bb40228502a5c9e52876b850a92ca61e68721aba`
- Baris: 38 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (Provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari nama file (2024).
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: 3 baris catatan kaki setelah tabel diabaikan (mis. '1 Hasil Proyeksi Penduduk Indonesia 2020-2050 Hasil Sensus Penduduk 2020 (Pertengahan tahun/Juni)/Indonesia Po').
- Catatan: Header memakai baris 1; data baris 2-40.
- Sebaran per tahun, kolom `tahun` (2024 s.d. 2024): 2024:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| penduduk > 0: `1 <= Jumlah Penduduk (Ribu) <= +inf` | Jumlah Penduduk (Ribu) | 38 | 0 | 0.00% |  |
| persentase 0-100: `0 <= Persentase Penduduk <= 100` | Persentase Penduduk | 38 | 0 | 0.00% |  |
| kepadatan > 0: `1 <= Kepadatan Penduduk per km persegi (Km2) <= +…` | Kepadatan Penduduk per km persegi (Km2) | 38 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Provinsi | provinsi | text | text | 0.0% | 38 |  |  | Aceh (1); Sumatera Utara (1); Sumatera Barat (1); Riau (1); Jambi (1)… | Nama provinsi | panjang 4-25; KANDIDAT KUNCI |
| 2 | Jumlah Penduduk (Ribu) | jumlah_penduduk_ribu | numeric | numeric | 0.0% | 38 | 542.1 | 50345.2 | 5554.8; 15588.5; 5836.2 | Jumlah penduduk (ribu jiwa) | maks 1 digit desimal |
| 3 | Laju Pertumbuhan Penduduk per Tahun | laju_pertumbuhan_penduduk_per_tahun | numeric | numeric | 0.0% | 31 | 0.31 | 1.93 | 1.39; 1.4; 1.43 | Laju pertumbuhan penduduk per tahun (%) | maks 2 digit desimal |
| 4 | Persentase Penduduk | persentase_penduduk | numeric | numeric | 0.0% | 37 | 0.19 | 17.88 | 1.97; 5.54; 2.07 | Distribusi persentase penduduk (%) | maks 2 digit desimal |
| 5 | Kepadatan Penduduk per km persegi (Km2) | kepadatan_penduduk_per_km_persegi_km2 | integer | integer | 0.0% | 37 | 5 | 16165 | 102 (2); 215 (1); 139 (1); 75 (1); 98 (1); 76 (1); 105 (1); 281 (1) | Kepadatan penduduk (jiwa/km2) |  |
| 6 | Rasio Jenis Kelamin Penduduk | rasio_jenis_kelamin_penduduk | numeric | numeric | 0.0% | 32 | 97.9 | 114.5 | 100.9; 100.8; 101.5 | Rasio jenis kelamin (laki-laki per 100 perempuan) | maks 1 digit desimal |
| 7 | tahun | tahun | integer | integer | 0.0% | 1 | 2024 | 2024 | 2024 (38) | Tahun (diturunkan dari nama file) | kolom KONSTAN (selalu '2024'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,Provinsi,Jumlah Penduduk (Ribu),Laju Pertumbuhan Penduduk per Tahun,Persentase Penduduk,Kepadatan Penduduk per km persegi (Km2),Rasio Jenis Kelamin Penduduk,tahun
1,Aceh,5554.8,1.39,1.97,98,100.9,2024
2,Sumatera Utara,15588.5,1.4,5.54,215,100.8,2024
3,Sumatera Barat,5836.2,1.43,2.07,139,101.5,2024
4,Riau,6728.1,1.37,2.39,75,104.4,2024
10,Kepulauan Riau,2183.3,1.5,0.78,264,103.3,2024
22,Kalimantan Selatan,4273.4,1.29,1.52,115,102.3,2024
```
