### SRC-01 / BMKG_Earthquake_Catalog.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 18,974,206 byte
- SHA-256: `113afb060675f8d90e9ec3f4bcc8490a25aead2135a7a3636423a80143cf18c8`
- Baris: 217,807 | kolom: 11 | baris duplikat penuh: 0
- Uji kunci (Event ID): UNIK (0 duplikat, 0 baris ber-null)
- Koordinat (Latitude, Longitude): 217,807 valid; 727 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Catatan: 1 kolom tanpa judul dan kosong seluruhnya dibuang (posisi: 3).
- Sebaran per tahun, kolom `Date` (1998-01-09 s.d. 2024-12-31): 1998:99, 1999:82, 2000:81, 2001:93, 2002:88, 2003:65, 2004:107, 2005:318, 2006:212, 2007:465, 2008:820, 2009:4,209, 2010:6,585, 2011:5,095, 2012:7,394, 2013:4,870, 2014:5,804, 2015:6,351, 2016:7,778, 2017:10,206, 2018:9,166, 2019:21,051, 2020:21,532, 2021:12,071, 2022:29,460, 2023:27,618, 2024:36,187

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| magnitudo wajar: `0 <= Magnitude <= 10` | Magnitude | 217,807 | 0 | 0.00% |  |
| kedalaman wajar (km): `0 <= Depth (km) <= 800` | Depth (km) | 217,807 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | No | no | integer | integer | 0.0% | 217,807 | 1 | 221934 | 1; 2; 3 | Nomor urut baris pada katalog sumber (tidak berurutan penuh; bukan kunci) | KANDIDAT KUNCI |
| 2 | Event ID | event_id | text | text | 0.0% | 217,807 |  |  | BMKG-19980109094543-001; BMKG-19980112080550-001; BMKG-19980118120317… | ID kejadian BMKG berpola BMKG-yyyymmddhhmmss-nnn; kunci bisnis | panjang 23-23; KANDIDAT KUNCI |
| 3 | Date | date | date | date | 0.0% | 7,125 | 1998-01-09 | 2024-12-31 | 09-Jan-1998; 12-Jan-1998; 18-Jan-1998 | Tanggal kejadian (UTC), format dd-Mon-yyyy (bulan bahasa Inggris) |  |
| 4 | Time (UTC) | time_utc | text | text | 0.0% | 79,117 |  |  | 09:45:43; 08:05:50; 12:03:17 | Jam kejadian (UTC) hh:mm:ss | panjang 8-8 |
| 5 | Latitude | latitude | numeric | numeric(10,7) | 0.0% | 1,942 | -14.96 | 7.0 | -5.39; -3.04; -2.65 | Lintang episenter (derajat desimal, WGS84) | lintang |
| 6 | Longitude | longitude | numeric | numeric(10,7) | 0.0% | 4,793 | 94.0 | 142.0 | 126.17; 128.36; 132.13 | Bujur episenter (derajat desimal, WGS84) | bujur |
| 7 | Magnitude | magnitude | numeric | numeric | 0.0% | 74 | 0.2 | 7.9 | 4.1; 4.4; 4.8 | Magnitudo gempa | maks 1 digit desimal |
| 8 | Mag Type | mag_type | text | text | 0.0% | 13 |  |  | - (95455); MLv (60541); M (53244); mb (5980); Mw(mB) (1864); Mw (273)… | Jenis skala magnitudo (MLv, M, mb, Mw, ...); '-' = tidak tercatat | 95,455 nilai berupa token kosong ('-') - jadikan NULL di staging; 1 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 1-7 |
| 9 | Depth (km) | depth_km | integer | integer | 0.0% | 722 | 1 | 798 | 390; 100; 32 | Kedalaman hiposenter (km) |  |
| 10 | Source | source | text | text | 0.0% | 11 |  |  | NC (98979); RC_03 (28890); RC_04 (17252); RC_09 (15754); RC_02 (14998… | Kode jaringan/sumber data (NC, RC_xx) | panjang 2-5 |
| 11 | Source Event ID | source_event_id | text | text | 0.0% | 98,976 |  |  | -; bmg2009aahk; bmg2009aaku | ID kejadian pada sumber asal; '-' = tidak ada | 118,828 nilai berupa token kosong ('-') - jadikan NULL di staging; panjang 1-11 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,No,Event ID,Date,Time (UTC),Latitude,Longitude,Magnitude,Mag Type,Depth (km),Source,Source Event ID
1,1,BMKG-19980109094543-001,09-Jan-1998,09:45:43,-5.39,126.17,4.1,-,390,RC_09,-
2,2,BMKG-19980112080550-001,12-Jan-1998,08:05:50,-3.04,128.36,4.4,-,100,RC_09,-
3,3,BMKG-19980118120317-001,18-Jan-1998,12:03:17,-2.65,132.13,4.8,-,32,RC_09,-
4,4,BMKG-19980129150524-001,29-Jan-1998,15:05:24,6.76,127.28,3.8,mb,33,RC_04,-
22362,23134,BMKG-20120714033115-001,14-Jul-2012,03:31:15,-3.57,128.08,3.0,-,27,RC_09,-
95118,97872,BMKG-20200319050036-001,19-Mar-2020,05:00:36,-1.15,134.30,3.2,-,20,RC_05,-
30263,31419,BMKG-20131209150345-001,09-Dec-2013,15:03:45,-2.72,127.63,2.4,MLv,10,NC,bmg2013ybzw
```
