### SRC-09 / sebaran-point-of-presence-pop-layanan-jasa-internet-service-provider-isp_2026-11-13.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 1,842 byte
- SHA-256: `dc50bd60bee47916822c5c8312e81ebe0eb97b293bd0a312595a4e5ab9985383`
- Baris: 34 | kolom: 4 | baris duplikat penuh: 0
- Uji kunci (Provinsi, Tahun): UNIK (0 duplikat, 0 baris ber-null)
- Sebaran per tahun, kolom `Tahun` (2024 s.d. 2024): 2024:34

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| jumlah >= 0: `0 <= Sebaran PoP ISP <= +inf` | Sebaran PoP ISP | 34 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Provinsi | provinsi | text | text | 0.0% | 34 |  |  | Aceh (1); Bali (1); Banten (1); Bengkulu (1); Gorontalo (1); DKI Jaka… | Nama provinsi (34 provinsi; penamaan sebelum pemekaran Papua) | panjang 4-25; KANDIDAT KUNCI |
| 2 | Sebaran PoP ISP | sebaran_pop_isp | integer | integer | 0.0% | 32 | 3 | 1175 | 13 (2); 23 (2); 205 (1); 45 (1); 17 (1); 489 (1); 49 (1); 362 (1) | Jumlah Point of Presence ISP |  |
| 3 | Tahun | tahun | integer | integer | 0.0% | 1 | 2024 | 2024 | 2024 (34) | Tahun data | kolom KONSTAN (selalu '2024'); tahun |
| 4 | Source | source | text | text | 0.0% | 1 |  |  | https://datahub.komdigi.go.id (34) | URL sumber (konstan) | kolom KONSTAN (selalu 'https://datahub.komdigi.go.id'); panjang 29-29 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,Provinsi,Sebaran PoP ISP,Tahun,Source
1,Aceh,45,2024,https://datahub.komdigi.go.id
2,Bali,205,2024,https://datahub.komdigi.go.id
3,Banten,362,2024,https://datahub.komdigi.go.id
4,Bengkulu,13,2024,https://datahub.komdigi.go.id
21,Nusa Tenggara Barat,96,2024,https://datahub.komdigi.go.id
```
