# Probe relasi antar-sumber

Mengukur seberapa baik kunci dan nama wilayah dapat dihubungkan. Normalisasi nama: huruf besar, tanpa tanda baca, awalan KAB./KABUPATEN dibuang, KOTA dipertahankan; provinsi memakai alias (KEP.=KEPULAUAN, NAD=ACEH, dst.).

## P1 - Pengamatan harian -> detail stasiun
- kiri: 173 nilai unik; kanan: 192; irisan: 173
- cakupan baris kiri yang ada di kanan: 100.0%; nilai unik kiri ada di kanan: 100.0%; unik kanan ada di kiri: 90.1%
- hanya di kanan (19): 96003, 96004, 96013, 96743, 96859, 97074, 97094, 97116

## P2 - Stasiun -> provinsi (ID internal)
- kiri: 34 nilai unik; kanan: 34; irisan: 34
- cakupan baris kiri yang ada di kanan: 100.0%; nilai unik kiri ada di kanan: 100.0%; unik kanan ada di kiri: 100.0%

## P3 - SRC-08: CSV atribut <-> GeoJSON (ID elemen OSM)
- kiri: 2,821 nilai unik; kanan: 2,821; irisan: 2,821
- cakupan baris kiri yang ada di kanan: 100.0%; nilai unik kiri ada di kanan: 100.0%; unik kanan ada di kiri: 100.0%

## P4 - Kode BPS (SRC-04) <-> pcode ADM2 tanpa awalan ID (SRC-11)
- kiri: 514 nilai unik; kanan: 522; irisan: 488
- cakupan baris kiri yang ada di kanan: 94.9%; nilai unik kiri ada di kanan: 94.9%; unik kanan ada di kiri: 93.5%
- hanya di kiri (26): 9201, 9202, 9203, 9204, 9205, 9271, 9501, 9502
- hanya di kanan (34): 1288, 1388, 1688, 1888, 3288, 3388, 3399, 7188

## P5 - city_id BNPB -> kode BPS (SRC-04)
- kiri: 521 nilai unik; kanan: 514; irisan: 493
- cakupan baris kiri yang ada di kanan: 99.1%; nilai unik kiri ada di kanan: 94.6%; unik kanan ada di kiri: 95.9%
- hanya di kiri (28): 1472, 6407, 6408, 7324, 9108, 9109, 9110, 9114
- hanya di kanan (21): 7412, 9204, 9205, 9408, 9409, 9419, 9420, 9427

## P6 - Jika kode sama, apakah nama kab/kota juga sama? (menguji city_id BNPB)
- baris dengan kode ada di kanan: 99.1% (28,507 dari 28,773)
- di antara itu, nama SAMA dengan nama pada kode tersebut: 80.6%; nama BERBEDA: 19.4% (5,542 baris)
- contoh kode sama nama beda: 1305 'PADANG PARIAMAN' (BPS: 'TANAH DATAR'; 205 baris) | 2101 'BINTAN' (BPS: 'KARIMUN'; 174 baris) | 1106 'ACEH BESAR' (BPS: 'ACEH TENGAH'; 147 baris) | 1101 'ACEH SELATAN' (BPS: 'SIMEULUE'; 106 baris) | 1306 'AGAM' (BPS: 'PADANG PARIAMAN'; 101 baris) | 6503 'NUNUKAN' (BPS: 'TANA TIDUNG'; 98 baris)

## P7 - Nama kab/kota BNPB -> SRC-04
- nilai unik kiri: 538; cocok ke referensi: 525 (97.6%); cakupan baris: 99.4%; referensi unik: 514 (setelah normalisasi 514)
- TIDAK cocok (13): PANGKAJENE KEPULAUAN (36); PASANGKAYU (29); KUTAI KERTANEGARA (25); KOTA MAKASSAR (16); KOTA PADANG SIDEMPUAN (15); SELAYAR (15); TOBA (12); KEPULAUAN SIAU TAGULANDANG BIARO (8); KEPULAUAN TANIMBAR (6); TOBA SAMOSIR (5)

## P8 - Wilayah stasiun -> SRC-04
- nilai unik kiri: 150; cocok ke referensi: 146 (97.3%); cakupan baris: 96.9%; referensi unik: 514 (setelah normalisasi 514)
- TIDAK cocok (4): Kota Makassar (2); Kab Maluku Tenggara Barat (2); Kab. Pontianak (1); Kota Tangerang Selata (1)

## P9 - Nama ADM2 (SRC-11) -> SRC-04
- nilai unik kiri: 519; cocok ke referensi: 508 (97.9%); cakupan baris: 97.3%; referensi unik: 514 (setelah normalisasi 514)
- TIDAK cocok (11): Danau (4); Danau Toba (1); Hutan (1); Kepulauan Seribu (1); Kota Makassar (1); Mahakam Hulu (1); Maluku Tenggara Barat (1); Mamuju Utara (1); Toba Samosir (1); Waduk Cirata (1)

## P10 - Provinsi BNPB -> SRC-04
- nilai unik kiri: 40; cocok ke referensi: 40 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)

## P11 - Provinsi iklim -> SRC-04
- nilai unik kiri: 34; cocok ke referensi: 34 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)

## P12 - Provinsi PoP ISP -> SRC-04
- nilai unik kiri: 34; cocok ke referensi: 34 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)

## P13 - Provinsi IKLH -> SRC-04
- nilai unik kiri: 38; cocok ke referensi: 38 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)

## P14 - Provinsi penduduk -> SRC-04
- nilai unik kiri: 34; cocok ke referensi: 34 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)

## P15 - Provinsi ADM1 (SRC-11) -> SRC-04
- nilai unik kiri: 34; cocok ke referensi: 34 (100.0%); cakupan baris: 100.0%; referensi unik: 38 (setelah normalisasi 38)

