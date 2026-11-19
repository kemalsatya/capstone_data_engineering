### SRC-12 / Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2023.csv
- Format: csv (reader: bps) | 2,385 byte
- SHA-256: `7a45da04a5a7c7ea24efff8dca66e5ef16d84847d8da3dcfbcd4674f6220bffe`
- Baris: 38 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (Provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari nama file (2023).
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: 2 baris catatan kaki setelah tabel diabaikan (mis. '1 Hasil Proyeksi Penduduk Indonesia 2020-2050 Hasil Sensus Penduduk 2020 (Pertengahan tahun/Juni)/Indonesia Po').
- Catatan: Header memakai baris 1; data baris 2-40.
- Sebaran per tahun, kolom `tahun` (2023 s.d. 2023): 2023:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| penduduk > 0: `1 <= Jumlah Penduduk (Ribu) <= +inf` | Jumlah Penduduk (Ribu) | 34 | 0 | 0.00% |  |
| persentase 0-100: `0 <= Persentase Penduduk <= 100` | Persentase Penduduk | 34 | 0 | 0.00% |  |
| kepadatan > 0: `1 <= Kepadatan Penduduk per km persegi (Km2) <= +…` | Kepadatan Penduduk per km persegi (Km2) | 34 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Provinsi | provinsi | text | text | 0.0% | 38 |  |  | Aceh (1); Sumatera Utara (1); Sumatera Barat (1); Riau (1); Jambi (1)… | Nama provinsi | panjang 4-25; KANDIDAT KUNCI |
| 2 | Jumlah Penduduk (Ribu) | jumlah_penduduk_ribu | numeric | numeric | 0.0% | 35 | 730.0 | 49860.3 | 5482.5; 15386.6; 5757.2 | Jumlah penduduk (ribu jiwa) | 4 nilai berupa token kosong ('...') - jadikan NULL di staging; maks 1 digit desimal |
| 3 | Laju Pertumbuhan Penduduk per Tahun | laju_pertumbuhan_penduduk_per_tahun | numeric | numeric | 0.0% | 30 | 0.38 | 1.69 | 1.41; 1.43; 1.45 | Laju pertumbuhan penduduk per tahun (%) | 4 nilai berupa token kosong ('...') - jadikan NULL di staging; maks 2 digit desimal |
| 4 | Persentase Penduduk | persentase_penduduk | numeric | numeric | 0.0% | 34 | 0.26 | 17.89 | 1.97; 5.52; 2.07 | Distribusi persentase penduduk (%) | 4 nilai berupa token kosong ('...') - jadikan NULL di staging; maks 2 digit desimal |
| 5 | Kepadatan Penduduk per km persegi (Km2) | kepadatan_penduduk_per_km_persegi_km2 | integer | integer | 0.0% | 34 | 10 | 16146 | ... (4); 101 (2); 96 (1); 212 (1); 137 (1); 74 (1); 75 (1); 104 (1) | Kepadatan penduduk (jiwa/km2) | 4 nilai berupa token kosong ('...') - jadikan NULL di staging |
| 6 | Rasio Jenis Kelamin Penduduk | rasio_jenis_kelamin_penduduk | numeric | numeric | 0.0% | 29 | 98.0 | 112.9 | 100.9; 100.7; 101.5 | Rasio jenis kelamin (laki-laki per 100 perempuan) | 4 nilai berupa token kosong ('...') - jadikan NULL di staging; maks 1 digit desimal |
| 7 | tahun | tahun | integer | integer | 0.0% | 1 | 2023 | 2023 | 2023 (38) | Tahun (diturunkan dari nama file) | kolom KONSTAN (selalu '2023'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,Provinsi,Jumlah Penduduk (Ribu),Laju Pertumbuhan Penduduk per Tahun,Persentase Penduduk,Kepadatan Penduduk per km persegi (Km2),Rasio Jenis Kelamin Penduduk,tahun
1,Aceh,5482.5,1.41,1.97,96,100.9,2023
2,Sumatera Utara,15386.6,1.43,5.52,212,100.7,2023
3,Sumatera Barat,5757.2,1.45,2.07,137,101.5,2023
4,Riau,6642.9,1.4,2.38,74,104.6,2023
10,Kepulauan Riau,2152.6,1.53,0.77,260,103.6,2023
22,Kalimantan Selatan,4222.3,1.31,1.52,114,102.4,2023
```
