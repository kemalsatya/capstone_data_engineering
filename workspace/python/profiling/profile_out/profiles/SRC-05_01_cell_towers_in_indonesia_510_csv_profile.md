### SRC-05 / Cell Towers in Indonesia 510.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 5,189,809 byte
- SHA-256: `1318b1445759e2301a4c706b7421475442e47e6766c87b7203841e14c50a1e4e`
- Baris: 66,059 | kolom: 14 | baris duplikat penuh: 0
- Uji kunci (radio, net, area, cell): UNIK (0 duplikat, 0 baris ber-null)
- Koordinat (lat, lon): 66,059 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Sebaran per tahun, kolom `created` (2015-03-12T07:51:33 s.d. 2026-11-10T19:50:47): 2015:30, 2016:614, 2017:476, 2018:180, 2019:129, 2020:18, 2021:74, 2022:609, 2023:439, 2024:845, 2025:27,676, 2026:34,969
- Sebaran per tahun, kolom `updated` (2025-05-11T08:35:25 s.d. 2026-11-10T19:50:47): 2025:24,268, 2026:41,791

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| radius > 0 m: `1 <= range <= 100000` | range | 66,059 | 0 | 0.00% |  |
| sampel >= 1: `1 <= samples <= +inf` | samples | 66,059 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | radio | radio | text | text | 0.0% | 4 |  |  | LTE (61862); GSM (2331); UMTS (1863); NR (3) | Teknologi radio (GSM, UMTS, LTE, NR) | panjang 2-4 |
| 2 | mcc | mcc | integer | integer | 0.0% | 1 | 510 | 510 | 510 (66059) | Mobile Country Code (510 = Indonesia) | kolom KONSTAN (selalu '510') |
| 3 | net | net | integer | integer | 0.0% | 8 | 1 | 89 | 10 (31226); 1 (17492); 11 (13808); 89 (1676); 9 (1284); 21 (549); 22 … | Mobile Network Code (operator) |  |
| 4 | area | area | integer | integer | 0.0% | 1,462 | 447 | 65272 | 41004; 41003; 51005 | Location/Tracking Area Code |  |
| 5 | cell | cell | integer | integer | 0.0% | 63,770 | 1 | 268277260 | 104990981; 104991237; 104975110 | Cell ID |  |
| 6 | unit | unit | integer | integer | 0.0% | 2 | -1 | 0 | -1 (59445); 0 (6614) | PSC/PCI (-1 = tidak ada) |  |
| 7 | lon | lon | numeric | numeric(10,7) | 0.0% | 27,876 | 95.3638 | 140.7077 | 106.8322; 106.829; 106.8381 | Bujur perkiraan sel | bujur |
| 8 | lat | lat | numeric | numeric(10,7) | 0.0% | 20,981 | -10.893 | 5.5869 | -6.1869; -6.188; -6.1823 | Lintang perkiraan sel | lintang |
| 9 | range | range | integer | integer | 0.0% | 2,914 | 500 | 30714 | 7988; 768; 9950 | Radius perkiraan cakupan (meter) |  |
| 10 | samples | samples | integer | integer | 0.0% | 51 | 1 | 51 | 50; 45; 46 | Jumlah pengukuran yang membentuk posisi |  |
| 11 | changeable | changeable | integer | integer | 0.0% | 1 | 1 | 1 | 1 (66059) | 1 = posisi hasil perhitungan, 0 = posisi dari sumber langsung | kolom KONSTAN (selalu '1') |
| 12 | created | created | epoch_seconds | timestamptz | 0.0% | 53,486 | 2015-03-12T07:51:33 | 2026-11-10T19:50:47 | 1446551984; 1447313858; 1447418083 | Waktu data pertama dibuat (epoch detik) | epoch detik; to_timestamp(kolom) |
| 13 | updated | updated | epoch_seconds | timestamptz | 0.0% | 16,611 | 2025-05-11T08:35:25 | 2026-11-10T19:50:47 | 1747378621; 1747387201; 1747988701 | Waktu data terakhir diperbarui (epoch detik) | epoch detik; to_timestamp(kolom) |
| 14 | averageSignal | averagesignal | integer | integer | 0.0% | 1 | 0 | 0 | 0 (66059) | Rata-rata kekuatan sinyal (0 = tidak ada) | kolom KONSTAN (selalu '0') |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,radio,mcc,net,area,cell,unit,lon,lat,range,samples,changeable,created,updated,averageSignal
1,LTE,510,11,41004,104990981,0,106.8322,-6.1869,7988,50,1,1446551984,1747378621,0
2,LTE,510,11,41004,104991237,0,106.829,-6.188,768,50,1,1446551984,1747387201,0
3,LTE,510,11,41004,104975110,0,106.8381,-6.1823,9950,50,1,1446551984,1747988701,0
4,LTE,510,11,41004,104991236,0,106.8303,-6.187,3152,45,1,1446551984,1754484241,0
27670,LTE,510,11,61602,156232722,-1,115.1532,-8.8189,1000,13,1,1761820937,1761841504,0
37148,LTE,510,1,43210,103631381,-1,108.224,-6.7048,1000,7,1,1775020014,1775063349,0
27501,LTE,510,10,1237,111390987,-1,106.7245,-6.3181,1000,1,1,1761584471,1761584471,0
```
