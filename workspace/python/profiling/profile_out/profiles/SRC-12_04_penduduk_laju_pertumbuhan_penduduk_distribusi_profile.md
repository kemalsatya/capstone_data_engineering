### SRC-12 / Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2025.csv
- Format: csv (reader: bps) | 2,633 byte
- SHA-256: `3479478f44296af8fdb8549344f90b89e169b424b20a27605c224efa6c8ecf12`
- Baris: 38 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (Provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari nama file (2025).
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: 5 baris catatan kaki setelah tabel diabaikan (mis. '1Hasil Proyeksi Penduduk Indonesia 2020-2050 Hasil Sensus Penduduk 2020 (Pertengahan tahun/Juni)/ Indonesia Po').
- Catatan: Header memakai baris 1; data baris 2-40.
- Sebaran per tahun, kolom `tahun` (2025 s.d. 2025): 2025:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| penduduk > 0: `1 <= Jumlah Penduduk (Ribu) <= +inf` | Jumlah Penduduk (Ribu) | 38 | 0 | 0.00% |  |
| persentase 0-100: `0 <= Persentase Penduduk <= 100` | Persentase Penduduk | 38 | 0 | 0.00% |  |
| kepadatan > 0: `1 <= Kepadatan Penduduk per km persegi (Km2) <= +…` | Kepadatan Penduduk per km persegi (Km2) | 38 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Provinsi | provinsi | text | text | 0.0% | 38 |  |  | Aceh (1); Sumatera Utara (1); Sumatera Barat (1); Riau (1); Jambi (1)… | Nama provinsi | panjang 4-25; KANDIDAT KUNCI |
| 2 | Jumlah Penduduk (Ribu) | jumlah_penduduk_ribu | numeric | numeric | 0.0% | 38 | 549.7 | 50759.0 | 5626; 15785.8; 5914.3 | Jumlah penduduk (ribu jiwa) | maks 1 digit desimal |
| 3 | Laju Pertumbuhan Penduduk per Tahun | laju_pertumbuhan_penduduk_per_tahun | numeric | numeric | 0.0% | 32 | 0.23 | 2.67 | 1.37; 1.41; 1.34 | Laju pertumbuhan penduduk per tahun (%) | maks 2 digit desimal |
| 4 | Persentase Penduduk | persentase_penduduk | numeric | numeric | 0.0% | 36 | 0.19 | 17.85 | 1.98; 5.55; 2.08 | Distribusi persentase penduduk (%) | maks 2 digit desimal |
| 5 | Kepadatan Penduduk per km persegi (Km2) | kepadatan_penduduk_per_km_persegi_km2 | integer | integer | 0.0% | 37 | 5 | 16155 | 103 (2); 218 (1); 140 (1); 76 (1); 99 (1); 77 (1); 106 (1); 284 (1) | Kepadatan penduduk (jiwa/km2) |  |
| 6 | Rasio Jenis Kelamin Penduduk | rasio_jenis_kelamin_penduduk | numeric | numeric | 0.0% | 32 | 97.8 | 114.0 | 100.9; 100.8; 101.5 | Rasio jenis kelamin (laki-laki per 100 perempuan) | maks 1 digit desimal |
| 7 | tahun | tahun | integer | integer | 0.0% | 1 | 2025 | 2025 | 2025 (38) | Tahun (diturunkan dari nama file) | kolom KONSTAN (selalu '2025'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,Provinsi,Jumlah Penduduk (Ribu),Laju Pertumbuhan Penduduk per Tahun,Persentase Penduduk,Kepadatan Penduduk per km persegi (Km2),Rasio Jenis Kelamin Penduduk,tahun
1,Aceh,5626,1.37,1.98,99,100.9,2025
2,Sumatera Utara,15785.8,1.37,5.55,218,100.8,2025
3,Sumatera Barat,5914.3,1.41,2.08,140,101.5,2025
4,Riau,6811.2,1.34,2.39,76,104.3,2025
10,Kepulauan Riau,2213.5,1.48,0.78,268,103.1,2025
22,Kalimantan Selatan,4323.3,1.26,1.52,116,102.2,2025
```
