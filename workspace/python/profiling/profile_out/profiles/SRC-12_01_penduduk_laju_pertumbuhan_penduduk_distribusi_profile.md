### SRC-12 / Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2022.csv
- Format: csv (reader: bps) | 2,831 byte
- SHA-256: `f0e9540cff81f7f6f7360f65b36f1b721a69edfe753a3e7e8bad58c10ae33044`
- Baris: 34 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (Provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari nama file (2022).
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: 6 baris catatan kaki setelah tabel diabaikan (mis. '1 Hasil Sensus Penduduk (SP) 2020 (September)/The Result of Population Census 2020 (September) ').
- Catatan: Header memakai baris 1; data baris 2-36.
- Sebaran per tahun, kolom `tahun` (2022 s.d. 2022): 2022:34

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| penduduk > 0: `1 <= Jumlah Penduduk (Ribu) <= +inf` | Jumlah Penduduk (Ribu) | 34 | 0 | 0.00% |  |
| persentase 0-100: `0 <= Persentase Penduduk <= 100` | Persentase Penduduk | 34 | 0 | 0.00% |  |
| kepadatan > 0: `1 <= Kepadatan Penduduk per km persegi (Km2) <= +…` | Kepadatan Penduduk per km persegi (Km2) | 34 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Provinsi | provinsi | text | text | 0.0% | 34 |  |  | Aceh (1); Sumatera Utara (1); Sumatera Barat (1); Riau (1); Jambi (1)… | Nama provinsi | panjang 4-25; KANDIDAT KUNCI |
| 2 | Jumlah Penduduk (Ribu) | jumlah_penduduk_ribu | numeric | numeric | 0.0% | 34 | 727.8 | 49405.8 | 5407.9; 15115.2; 5640.6 | Jumlah penduduk (ribu jiwa) | maks 1 digit desimal |
| 3 | Laju Pertumbuhan Penduduk per Tahun | laju_pertumbuhan_penduduk_per_tahun | numeric | numeric | 0.0% | 29 | 0.64 | 3.15 | 1.43; 1.21; 1.09 | Laju pertumbuhan penduduk per tahun (%) | maks 2 digit desimal |
| 4 | Persentase Penduduk | persentase_penduduk | numeric | numeric | 0.0% | 31 | 0.26 | 17.92 | 1.96; 5.48; 2.05 | Distribusi persentase penduduk (%) | maks 2 digit desimal |
| 5 | Kepadatan Penduduk per km persegi (Km2) | kepadatan_penduduk_per_km_persegi_km2 | integer | integer | 0.0% | 33 | 10 | 16158 | 74 (2); 95 (1); 209 (1); 134 (1); 100 (1); 102 (1); 273 (1); 90 (1) | Kepadatan penduduk (jiwa/km2) |  |
| 6 | Rasio Jenis Kelamin Penduduk | rasio_jenis_kelamin_penduduk | numeric | numeric | 0.0% | 30 | 98.0 | 113.5 | 100.9; 100.7; 101.5 | Rasio jenis kelamin (laki-laki per 100 perempuan) | maks 1 digit desimal |
| 7 | tahun | tahun | integer | integer | 0.0% | 1 | 2022 | 2022 | 2022 (34) | Tahun (diturunkan dari nama file) | kolom KONSTAN (selalu '2022'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,Provinsi,Jumlah Penduduk (Ribu),Laju Pertumbuhan Penduduk per Tahun,Persentase Penduduk,Kepadatan Penduduk per km persegi (Km2),Rasio Jenis Kelamin Penduduk,tahun
1,Aceh,5407.9,1.43,1.96,95,100.9,2022
2,Sumatera Utara,15115.2,1.21,5.48,209,100.7,2022
3,Sumatera Barat,5640.6,1.09,2.05,134,101.5,2022
4,Riau,6614.4,1.95,2.4,74,104.7,2022
21,Kalimantan Tengah,2741.1,1.51,0.99,18,107.6,2022
```
