### SRC-08 / export.geojson   [setara dengan CSV (pilih salah satu untuk ingestion)]
- Format: geojson (reader: geojson) | 1,613,507 byte
- SHA-256: `4d387f18beffbd808c66f18377725f3b67c15a6d730819f5e4fee82085edfb73`
- Baris: 2,821 | kolom: 24 | baris duplikat penuh: 0
- Uji kunci (@id): UNIK (0 duplikat, 0 baris ber-null)
- Geometri: fitur 2,821; jenis (sampel) {'Point': 2821}; bbox [xmin,ymin,xmax,ymax] = [95.3427, -9.7122, 125.4862, 5.5133]; CRS: (tidak dinyatakan; GeoJSON baku = WGS84)
- voltage: terisi 1,098 dari 2,821 (39%); angka tunggal 981; multi-nilai ';' 116; format lain 1
- voltage maks per gardu: >=150 kV 960; 70-149 kV 122; <70 kV 15; tak terbaca 1
- operator: 34 variasi penulisan; teratas: Perusahaan Listrik Negara (1209), PT Perusahaan Listrik Negara (598), PLN (584), Pertamina Hulu Rokan (32)
- Catatan: GeoJSON dibaca streaming: hanya atribut yang diprofil; geometri hanya dilaporkan jenis dan bounding box (dari 600 fitur pertama).
- Catatan: 49 kolom dengan isi < 1% tidak ditampilkan (mis. building:levels, height, type, addr:housenumber, addr:street, phone); kolom tersebut tetap ada di file sumber.

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | @id | id | text | text | 0.0% | 2,821 |  |  | relation/8162884; relation/17905075; relation/18678451 |  | panjang 12-17; KANDIDAT KUNCI |
| 2 | building | building | text | text | 45.3% | 12 |  |  | power_substation (1412); yes (75); service (42); house (4); public (2… |  | panjang 2-16 |
| 3 | operator | operator | text | text | 12.7% | 34 |  |  | Perusahaan Listrik Negara (1209); PT Perusahaan Listrik Negara (598);… |  | 1 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 3-48 |
| 4 | operator:short | operator_short | text | text | 58.1% | 2 |  |  | PLN (1181); EDF (1) |  | panjang 3-3 |
| 5 | operator:wikidata | operator_wikidata | text | text | 58.0% | 2 |  |  | Q4201636 (1183); Q274591 (1) |  | panjang 7-8 |
| 6 | power | power | text | text | 0.0% | 1 |  |  | substation (2821) |  | kolom KONSTAN (selalu 'substation'); panjang 10-10 |
| 7 | @geometry | geometry | text | text | 2.4% | 1 |  |  | center (2753) |  | panjang 6-6 |
| 8 | _feature_id | feature_id | text | text | 0.0% | 2,821 |  |  | relation/8162884; relation/17905075; relation/18678451 |  | panjang 12-17; KANDIDAT KUNCI |
| 9 | _geometry_type | geometry_type | text | text | 0.0% | 1 |  |  | Point (2821) |  | kolom KONSTAN (selalu 'Point'); panjang 5-5 |
| 10 | location | location | text | text | 62.0% | 2 |  |  | outdoor (952); indoor (120) |  | panjang 6-7 |
| 11 | name | name | text | text | 14.1% | 2,356 |  |  | Gardu Induk Tuban PT. PLN (Persero) UIT JBTB; GITET Pedan; Gardu Indu… |  | 4 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 2-71 |
| 12 | substation | substation | text | text | 15.1% | 10 |  |  | distribution (1573); transmission (691); minor_distribution (90); tra… |  | panjang 3-26 |
| 13 | voltage | voltage | text | text | 61.1% | 21 |  |  | 150000 (815); 70000 (95); 150000;20000 (32); 150000;70000 (30); 11500… |  | panjang 3-20 |
| 14 | operator:wikipedia | operator_wikipedia | text | text | 94.6% | 1 |  |  | id:Perusahaan Listrik Negara (153) |  | panjang 28-28 |
| 15 | ref | ref | text | text | 98.7% | 37 |  |  | PLN (2); UNGR (1); BRJ (1); BTRTI (1); PDN (1); PSGRN (1); GLNUK (1);… |  | panjang 2-12 |
| 16 | addr:city | addr_city | text | text | 48.5% | 12 |  |  | DKI Jakarta (1407); Semarang (29); Surabaya (9); Lhokseumawe (1); Cia… |  | panjang 6-20 |
| 17 | source | source | text | text | 47.3% | 13 |  |  | HOT_InAWARESurvey_2017 (1404); HOT_InAWARESurvey_2018 (29); Bing (19)… |  | 2 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 4-38 |
| 18 | access:roof | access_roof | boolean | boolean | 98.5% | 2 |  |  | no (41); yes (2) |  |  |
| 19 | addr:full | addr_full | text | text | 56.4% | 1,109 |  |  | Jalan Sisingamangaraja; Jalan Yos Sudarso No.1; Jalan Plumpang Semper |  | 2 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 7-122 |
| 20 | frequency | frequency | integer | integer | 97.3% | 2 | 50 | 60 | 50 (43); 60 (34) |  |  |
| 21 | gas_insulated | gas_insulated | boolean | boolean | 98.9% | 1 |  |  | yes (30) |  |  |
| 22 | rating | rating | text | text | 89.7% | 63 |  |  | kV; KV; Kilovolt |  | 4 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 1-13 |
| 23 | backup_generator | backup_generator | boolean | boolean | 98.4% | 2 |  |  | no (35); yes (11) |  |  |
| 24 | utility | utility | text | text | 98.7% | 1 |  |  | power (37) |  | panjang 5-5 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,@id,building,operator,operator:short,operator:wikidata,power,@geometry,_feature_id,_geometry_type,location,name,substation,voltage,operator:wikipedia,ref,addr:city,source,access:roof,addr:full,frequency,gas_insulated,rating,backup_generator,utility
1,relation/8162884,yes,Perusahaan Listrik Negara,PLN,Q4201636,substation,center,relation/8162884,Point,,,,,,,,,,,,,,,
2,relation/17905075,,Perusahaan Listrik Negara,PLN,Q4201636,substation,center,relation/17905075,Point,outdoor,Gardu Induk Tuban PT. PLN (Persero) UIT JBTB,transmission,150000,,,,,,,,,,,
3,relation/18678451,,Perusahaan Listrik Negara,PLN,Q4201636,substation,center,relation/18678451,Point,outdoor,GITET Pedan,transmission,500000;150000;20000,id:Perusahaan Listrik Negara,PDN,,,,,,,,,
4,way/48213156,,PLN,,,substation,center,way/48213156,Point,,,,,,,,,,,,,,,
2807,node/11078010994,,,,,substation,,node/11078010994,Point,,,,,,,,,,,,,,,
2808,node/11078010995,,,,,substation,,node/11078010995,Point,,,,,,,,,,,,,,,
2286,way/966209489,,Perusahaan Listrik Negara,PLN,Q4201636,substation,center,way/966209489,Point,outdoor,Gardu Induk Pangeran Karang,distribution,150000,,,,,,,,,,,
2264,way/960747936,,Perusahaan Listrik Negara,PLN,Q4201636,substation,center,way/960747936,Point,outdoor,GITET Deltamas,transmission,500000;150000,id:Perusahaan Listrik Negara,,,,,,,,,,
547,way/494571065,power_substation,PT Perusahaan Listrik Negara,,,substation,center,way/494571065,Point,,Gardu Area Pondok Kopi PB 7,distribution,,,,DKI Jakarta,HOT_InAWARESurvey_2017,,Jalan Gebang Mutiara V,,,,,
```
