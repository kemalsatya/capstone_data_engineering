### SRC-12 / Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2026.csv
- Format: csv (reader: bps) | 2,599 byte
- SHA-256: `64c20c111add7c5c243e01447256372c9fc9308efecdf360998f1fcaaacf4255`
- Baris: 38 | kolom: 7 | baris duplikat penuh: 0
- Uji kunci (Provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari nama file (2026).
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: 2 baris catatan kaki setelah tabel diabaikan (mis. '1Proyeksi Penduduk Indonesia 2020-2050 Hasil Sensus Penduduk 2020 (Pertengahan tahun/Juni)/ Indonesia Populati').
- Catatan: Header memakai baris 1; data baris 2-40.
- Sebaran per tahun, kolom `tahun` (2026 s.d. 2026): 2026:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| penduduk > 0: `1 <= Jumlah Penduduk (Ribu) <= +inf` | Jumlah Penduduk (Ribu) | 38 | 0 | 0.00% |  |
| persentase 0-100: `0 <= Persentase Penduduk <= 100` | Persentase Penduduk | 38 | 0 | 0.00% |  |
| kepadatan > 0: `1 <= Kepadatan Penduduk per km persegi (Km2) <= +…` | Kepadatan Penduduk per km persegi (Km2) | 38 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Provinsi | provinsi | text | text | 0.0% | 38 |  |  | Aceh (1); Sumatera Utara (1); Sumatera Barat (1); Riau (1); Jambi (1)… | Nama provinsi | panjang 4-25; KANDIDAT KUNCI |
| 2 | Jumlah Penduduk (Ribu) | jumlah_penduduk_ribu | numeric | numeric | 0.0% | 38 | 557.2 | 51163.9 | 5695.9; 15978.6; 5991.6 | Jumlah penduduk (ribu jiwa) | maks 1 digit desimal |
| 3 | Laju Pertumbuhan Penduduk per Tahun | laju_pertumbuhan_penduduk_per_tahun | numeric | numeric | 0.0% | 29 | 0.18 | 3.06 | 1.34; 1.39; 1.31 | Laju pertumbuhan penduduk per tahun (%) | maks 2 digit desimal |
| 4 | Persentase Penduduk | persentase_penduduk | numeric | numeric | 0.0% | 35 | 0.19 | 17.81 | 1.98; 5.56; 2.09 | Distribusi persentase penduduk (%) | maks 2 digit desimal |
| 5 | Kepadatan Penduduk per km persegi (Km2) | kepadatan_penduduk_per_km_persegi_km2 | integer | integer | 0.0% | 37 | 5 | 16129 | 104 (2); 221 (1); 142 (1); 77 (1); 100 (1); 78 (1); 108 (1); 287 (1) | Kepadatan penduduk (jiwa/km2) |  |
| 6 | Rasio Jenis Kelamin Penduduk | rasio_jenis_kelamin_penduduk | numeric | numeric | 0.0% | 33 | 97.7 | 113.5 | 100.9; 100.8; 101.5 | Rasio jenis kelamin (laki-laki per 100 perempuan) | maks 1 digit desimal |
| 7 | tahun | tahun | integer | integer | 0.0% | 1 | 2026 | 2026 | 2026 (38) | Tahun (diturunkan dari nama file) | kolom KONSTAN (selalu '2026'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,Provinsi,Jumlah Penduduk (Ribu),Laju Pertumbuhan Penduduk per Tahun,Persentase Penduduk,Kepadatan Penduduk per km persegi (Km2),Rasio Jenis Kelamin Penduduk,tahun
1,Aceh,5695.9,1.34,1.98,100,100.9,2026
2,Sumatera Utara,15978.6,1.34,5.56,221,100.8,2026
3,Sumatera Barat,5991.6,1.39,2.09,142,101.5,2026
4,Riau,6892.4,1.31,2.4,77,104.1,2026
10,Kepulauan Riau,2243.1,1.45,0.78,275,102.9,2026
22,Kalimantan Selatan,4372.1,1.24,1.52,118,102.1,2026
```
