### SRC-08 / Gardu Induk dan Elektrik.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 716,359 byte
- SHA-256: `53c62cea0e1694a068625cb23a268863a365014764e213e709e4f6e9cfb226dc`
- Baris: 2,821 | kolom: 75 | baris duplikat penuh: 0
- Uji kunci (id): UNIK (0 duplikat, 0 baris ber-null)
- Koordinat (latitude, longitude): 2,821 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Geometri WKT (geometry_wkt): 0 dari 2,821 titik awal di luar bounding box Indonesia kasar
- voltage: terisi 1,098 dari 2,821 (39%); angka tunggal 981; multi-nilai ';' 116; format lain 1
- voltage maks per gardu: >=150 kV 960; 70-149 kV 122; <70 kV 15; tak terbaca 1
- operator: 34 variasi penulisan; teratas: Perusahaan Listrik Negara (1209), PT Perusahaan Listrik Negara (598), PLN (584), Pertamina Hulu Rokan (32)
- Sebaran per tahun, kolom `check_date` (2026-08-08 s.d. 2026-08-08): 2026:1

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | id | id | text | text | 0.0% | 2,821 |  |  | relation/8162884; relation/17905075; relation/18678451 | ID elemen OSM (tipe/id) | panjang 12-17; KANDIDAT KUNCI |
| 2 | @id | id_2 | text | text | 0.0% | 2,821 |  |  | relation/8162884; relation/17905075; relation/18678451 | ID elemen OSM (tipe/id) | panjang 12-17; KANDIDAT KUNCI |
| 3 | M:hazard_prone | m_hazard_prone | boolean | boolean | 99.9% | 1 |  |  | no (2) |  |  |
| 4 | access:roof | access_roof | boolean | boolean | 98.5% | 2 |  |  | no (41); yes (2) |  |  |
| 5 | addr:city | addr_city | text | text | 48.5% | 12 |  |  | DKI Jakarta (1407); Semarang (29); Surabaya (9); Lhokseumawe (1); Cia… |  | panjang 6-20 |
| 6 | addr:country | addr_country | text | text | 100.0% | 1 |  |  | ID (1) |  | panjang 2-2 |
| 7 | addr:full | addr_full | text | text | 56.4% | 1,109 |  |  | Jalan Sisingamangaraja; Jalan Yos Sudarso No.1; Jalan Plumpang Semper |  | 2 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 7-122 |
| 8 | addr:housenumber | addr_housenumber | integer | integer | 99.9% | 3 | 1 | 102 | 102 (1); 29 (1); 1 (1) |  |  |
| 9 | addr:postcode | addr_postcode | integer | integer | 99.8% | 5 | 11460 | 57772 | 57772 (1); 24353 (1); 46211 (1); 25217 (1); 11460 (1) |  |  |
| 10 | addr:street | addr_street | text | text | 99.7% | 9 |  |  | Jalan Letda. Sucipto (1); Jl. Perigi II (1); Jalan Rumah Sakit (1); J… |  | panjang 9-29 |
| 11 | addr:subdistrict | addr_subdistrict | text | text | 100.0% | 1 |  |  | Ciamis (1) |  | panjang 6-6 |
| 12 | alt_name | alt_name | text | text | 99.4% | 16 |  |  | Transformator (1); Gardu Induk Tegangan Ekstra Tinggi Mandirancan (1)… |  | panjang 9-98 |
| 13 | amenity | amenity | text | text | 100.0% | 1 |  |  | playground (1) |  | panjang 10-10 |
| 14 | backup_generator | backup_generator | boolean | boolean | 98.4% | 2 |  |  | no (35); yes (11) |  |  |
| 15 | barrier | barrier | text | text | 99.1% | 3 |  |  | fence (19); wall (4); yes (2) |  | panjang 3-5 |
| 16 | building | building | text | text | 45.3% | 12 |  |  | power_substation (1412); yes (75); service (42); house (4); industria… |  | panjang 2-16 |
| 17 | building:condition | building_condition | text | text | 99.6% | 3 |  |  | good (7); poor (2); Baik (1) |  | panjang 4-4 |
| 18 | building:levels | building_levels | integer | integer | 99.5% | 3 | 1 | 3 | 1 (12); 3 (1); 2 (1) |  |  |
| 19 | building:material | building_material | text | text | 100.0% | 1 |  |  | brick (1) |  | panjang 5-5 |
| 20 | building:roof | building_roof | text | text | 100.0% | 1 |  |  | concrete (1) |  | panjang 8-8 |
| 21 | building:structure | building_structure | text | text | 100.0% | 1 |  |  | unreinforced_masonry (1) |  | panjang 20-20 |
| 22 | building:use | building_use | text | text | 100.0% | 1 |  |  | education (1) |  | panjang 9-9 |
| 23 | building:walls | building_walls | text | text | 100.0% | 1 |  |  | brick (1) |  | panjang 5-5 |
| 24 | cables | cables | integer | integer | 99.9% | 2 | 2 | 6 | 6 (1); 2 (1) |  |  |
| 25 | capacity | capacity | text | text | 100.0% | 1 |  |  | 20 kv (1) |  | panjang 5-5 |
| 26 | check_date | check_date | date | date | 100.0% | 1 | 2026-08-08 | 2026-08-08 | 2026-08-08 |  |  |
| 27 | description | description | text | text | 99.9% | 2 |  |  | Restaurant (1); Public Park (1) |  | panjang 10-11 |
| 28 | design | design | text | text | 100.0% | 1 |  |  | three-level (1) |  | panjang 11-11 |
| 29 | designation | designation | text | text | 99.9% | 3 |  |  | tower GSM (1); Gardu Induk PLN Pendem (1); GI Hittu (1) |  | panjang 8-22 |
| 30 | fixme | fixme | text | text | 99.6% | 7 |  |  | name,operator,frequency,voltage (3); name,operator,voltage,frequency … |  | panjang 6-31 |
| 31 | frequency | frequency | integer | integer | 97.3% | 2 | 50 | 60 | 50 (43); 60 (34) |  |  |
| 32 | gas_insulated | gas_insulated | boolean | boolean | 98.9% | 1 |  |  | yes (30) |  |  |
| 33 | generator:source | generator_source | text | text | 100.0% | 1 |  |  | solar (1) |  | panjang 5-5 |
| 34 | height | height | integer | integer | 99.8% | 4 | 3 | 9 | 3 (2); 4 (1); 6 (1); 9 (1) |  |  |
| 35 | landuse | landuse | text | text | 99.9% | 1 |  |  | industrial (3) |  | panjang 10-10 |
| 36 | layer | layer | integer | integer | 99.9% | 2 | -1 | 1 | 1 (1); -1 (1) |  |  |
| 37 | leisure | leisure | text | text | 100.0% | 1 |  |  | park (1) |  | panjang 4-4 |
| 38 | location | location | text | text | 62.0% | 2 |  |  | outdoor (952); indoor (120) |  | panjang 6-7 |
| 39 | man_made | man_made | text | text | 100.0% | 1 |  |  | works (1) |  | panjang 5-5 |
| 40 | name | name | text | text | 14.1% | 2,356 |  |  | Gardu Induk Tuban PT. PLN (Persero) UIT JBTB; GITET Pedan; Gardu Indu… | Nama gardu | 4 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 2-71 |
| 41 | name:en | name_en | text | text | 99.9% | 2 |  |  | Trisakti Substation (1); Bangkanai Substation (1) |  | panjang 19-20 |
| 42 | name:id | name_id | text | text | 99.9% | 3 |  |  | Gardu Induk Mariana (1); Gardu Induk Dumai (1); Travo KT 137 Gardu Be… |  | panjang 17-24 |
| 43 | name:ms | name_ms | text | text | 100.0% | 1 |  |  | Travo KT 137 Gardu Beton (1) |  | panjang 24-24 |
| 44 | not:operator:wikidata | not_operator_wikidata | text | text | 99.9% | 1 |  |  | Q4201636 (4) |  | panjang 8-8 |
| 45 | note | note | text | text | 99.9% | 3 |  |  | 20.000 Volt (1); Dusun 2; RT 17 (1); Public Park (1) |  | panjang 11-14 |
| 46 | office | office | text | text | 99.9% | 2 |  |  | public_service_provider (1); company (1) |  | panjang 7-23 |
| 47 | official_name | official_name | text | text | 99.8% | 5 |  |  | Gardu Induk 150 kV dan 70 kV Sengkaling (1); Gardu Induk Tegangan Eks… |  | panjang 39-48 |
| 48 | opening_date | opening_date | integer | integer | 100.0% | 1 | 2026 | 2026 | 2026 (1) |  |  |
| 49 | opening_hours | opening_hours | text | text | 99.9% | 2 |  |  | Mo-Su 09:00-18:00 (1); 24/7 (1) |  | panjang 4-17 |
| 50 | operator | operator | text | text | 12.7% | 34 |  |  | Perusahaan Listrik Negara (1209); PT Perusahaan Listrik Negara (598);… | Operator (variasi penulisan PLN) | 1 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 3-48 |
| 51 | operator:short | operator_short | text | text | 58.1% | 2 |  |  | PLN (1181); EDF (1) |  | panjang 3-3 |
| 52 | operator:wikidata | operator_wikidata | text | text | 58.0% | 2 |  |  | Q4201636 (1183); Q274591 (1) |  | panjang 7-8 |
| 53 | operator:wikipedia | operator_wikipedia | text | text | 94.6% | 1 |  |  | id:Perusahaan Listrik Negara (153) |  | panjang 28-28 |
| 54 | phone | phone | text | text | 99.9% | 2 |  |  | +62 356 322101 (1); +62 265 772690 (1) |  | panjang 14-14 |
| 55 | power | power | text | text | 0.0% | 1 |  |  | substation (2821) | Tag power (selalu substation pada ekspor ini) | kolom KONSTAN (selalu 'substation'); panjang 10-10 |
| 56 | power_supply | power_supply | text | text | 100.0% | 1 |  |  | 120 MVA (1) |  | panjang 7-7 |
| 57 | public_service_provider:type_idn | public_service_provider_type_idn | text | text | 100.0% | 1 |  |  | pln (1) |  | panjang 3-3 |
| 58 | rating | rating | text | text | 89.7% | 63 |  |  | kV; KV; Kilovolt |  | 4 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 1-13 |
| 59 | ref | ref | text | text | 98.7% | 37 |  |  | PLN (2); PDN (1); UNGR (1); BRJ (1); BTRTI (1); PSGRN (1); GLNUK (1);… |  | panjang 2-12 |
| 60 | roof:levels | roof_levels | integer | integer | 99.9% | 1 | 1 | 1 | 1 (2) |  |  |
| 61 | roof:material | roof_material | text | text | 99.9% | 1 |  |  | roof_tiles (2) |  | panjang 10-10 |
| 62 | roof:orientation | roof_orientation | text | text | 99.9% | 1 |  |  | along (2) |  | panjang 5-5 |
| 63 | roof:shape | roof_shape | text | text | 99.8% | 2 |  |  | flat (3); gabled (2) |  | panjang 4-6 |
| 64 | shelter_type | shelter_type | text | text | 100.0% | 1 |  |  | building (1) |  | panjang 8-8 |
| 65 | short_name | short_name | text | text | 99.4% | 18 |  |  | GITET Pedan (1); GI Kayutangi (1); GI Barikin (1); GI Tanjung (1); GI… |  | panjang 7-28 |
| 66 | source | source | text | text | 47.3% | 13 |  |  | HOT_InAWARESurvey_2017 (1404); HOT_InAWARESurvey_2018 (29); Bing (19)… |  | 2 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 4-38 |
| 67 | start_date | start_date | integer | integer | 100.0% | 1 | 2022 | 2022 | 2022 (1) |  |  |
| 68 | substation | substation | text | text | 15.1% | 10 |  |  | distribution (1573); transmission (691); minor_distribution (90); tra… | Jenis gardu (transmission, distribution, minor_distribution, ...) | panjang 3-26 |
| 69 | type | type | text | text | 99.9% | 1 |  |  | multipolygon (3) |  | panjang 12-12 |
| 70 | utility | utility | text | text | 98.7% | 1 |  |  | power (37) |  | panjang 5-5 |
| 71 | voltage | voltage | text | text | 61.1% | 21 |  |  | 150000 (815); 70000 (95); 150000;20000 (32); 150000;70000 (30); 11500… | Tegangan dalam volt; dapat multi-nilai dipisah ';' | panjang 3-20 |
| 72 | @geometry | geometry | text | text | 2.4% | 1 |  |  | center (2753) |  | panjang 6-6 |
| 73 | longitude | longitude | numeric | numeric(10,7) | 0.0% | 2,821 | 95.3426542 | 140.7903099 | 108.9800899; 112.0349575; 110.7100882 | Bujur titik pusat | bujur |
| 74 | latitude | latitude | numeric | numeric(10,7) | 0.0% | 2,821 | -10.2384623 | 5.6412332 | 0.9116867; -6.8885034; -7.6773354 | Lintang titik pusat | lintang |
| 75 | geometry_wkt | geometry_wkt | geometry_wkt | text | 0.0% | 2,821 |  |  | POINT (108.98009 0.911687); POINT (112.034958 -6.888503); POINT (110.… | Geometri titik pusat (WKT) | WKT; jadikan geometry(...,4326) di staging bila PostGIS aktif |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,id,@id,M:hazard_prone,access:roof,addr:city,addr:country,addr:full,addr:housenumber,addr:postcode,addr:street,addr:subdistrict,alt_name,amenity,backup_generator,barrier,building,building:condition,building:levels,building:material,building:roof,building:structure,building:use,building:walls,cables,capacity,check_date,description,design,designation,fixme,frequency,gas_insulated,generator:source,height,landuse,layer,leisure,location,man_made,name
1,relation/8162884,relation/8162884,,,,,,,,,,,,,,yes,,1,,,,,,,,,,,,,,,,4,,,,,,
2,relation/17905075,relation/17905075,,,,,,102,,Jalan Letda. Sucipto,,,,,,,,,,,,,,,,,,,,,,,,,,,,outdoor,,Gardu Induk Tuban PT. PLN (Persero) UIT JBTB
3,relation/18678451,relation/18678451,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,outdoor,,GITET Pedan
4,way/48213156,way/48213156,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
2793,node/6486002803,node/6486002803,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
2759,node/1897670417,node/1897670417,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
2286,way/966209489,way/966209489,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,outdoor,,Gardu Induk Pangeran Karang
2264,way/960747936,way/960747936,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,outdoor,,GITET Deltamas
547,way/494571065,way/494571065,,,DKI Jakarta,,Jalan Gebang Mutiara V,,,,,,,,,power_substation,,,,,,,,,,,,,,,,,,,,,,,,Gardu Area Pondok Kopi PB 7
```
