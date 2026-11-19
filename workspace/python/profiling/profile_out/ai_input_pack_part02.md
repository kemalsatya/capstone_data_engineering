# AI INPUT PACK - bagian 2 dari 3 (profil sumber data capstone SRC-01..SRC-12)

Dibuat oleh profile_sources.py v3.0. Semua angka berasal dari file sumber nyata, bukan asumsi.

Cara membaca: 'Tipe terdeteksi' = heuristik dari data; 'Tipe PG (usulan)' hanya usulan staging; 'KANDIDAT KUNCI' = unik dan tidak null (belum tentu business key); 'Aturan domain' = USULAN batas wajar yang diukur pada data (bukan keputusan); 'Definisi' dari kamus resmi bila ada, selain itu dari analisis.

## SRC-07 - Global Power Plant Database v1.3.0 (WRI)
- Sumber: https://datasets.wri.org/dataset/globalpowerplantdatabase
- Lisensi: CC BY 4.0
- Grain: titik: 1 baris = 1 pembangkit (global; saring country = IDN)
- Status kesiapan: **READY**
  - (info) [duplikat] globalpowerplantdatabasev130.zip:global_power_plant_database.csv identik dengan global_power_plant_database.csv (dilewati)
- Pemeriksaan kolom yang diharapkan: negara: ADA; ID pembangkit: ADA; kapasitas MW: ADA; lintang: ADA; bujur: ADA; bahan bakar: ADA
- Dokumen pendamping (tidak dimuat sebagai data): globalpowerplantdatabasev130.zip:A_Global_Database_of_Power_Plants.pdf, globalpowerplantdatabasev130.zip:Estimating_Power_Plant_Generation_in_the_Global_Power_Plant_Database.pdf, globalpowerplantdatabasev130.zip:README.txt, globalpowerplantdatabasev130.zip:RELEASE_NOTES.txt

### SRC-07 / global_power_plant_database.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 11,973,385 byte
- SHA-256: `4b1f93e0fd93664f18684d9b05d0a52ed9658c6a8cf0d21ff2520791379ba7fc`
- Baris: 178 | kolom: 36 | baris duplikat penuh: 0
- Uji kunci (gppd_idnr): UNIK (0 duplikat, 0 baris ber-null)
- Koordinat (latitude, longitude): 178 valid; 0 di luar bounding box Indonesia kasar; 0 kemungkinan tertukar
- Catatan: Disaring country = IDN: 34,936 -> 178 baris (sisanya di luar cakupan proyek).
- Sebaran per tahun, kolom `commissioning_year` (1998 s.d. 2017): 1998:1, 1999:1, 2006:1, 2009:1, 2011:2, 2012:2, 2014:1, 2015:5, 2016:3, 2017:3

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| kapasitas 1-20000 MW: `1 <= capacity_mw <= 20000` | capacity_mw | 178 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | country | country | text | text | 0.0% | 1 |  |  | IDN (178) | 3 character country code corresponding to the ISO 3166-1 alpha-3 specification [5] [text] | kolom KONSTAN (selalu 'IDN'); panjang 3-3 |
| 2 | country_long | country_long | text | text | 0.0% | 1 |  |  | Indonesia (178) | longer form of the country designation [text] | kolom KONSTAN (selalu 'Indonesia'); panjang 9-9 |
| 3 | name | name | text | text | 0.0% | 178 |  |  | Amamapare Port power station; Ampenan; Amurang power station | name or title of the power plant, generally in Romanized form [text] | panjang 4-41; KANDIDAT KUNCI |
| 4 | gppd_idnr | gppd_idnr | text | text | 0.0% | 178 |  |  | WRI1075798; WRI1000736; WRI1075799 | 10 or 12 character identifier for the power plant [text] | panjang 10-10; KANDIDAT KUNCI |
| 5 | capacity_mw | capacity_mw | numeric | numeric | 0.0% | 127 | 1.0 | 5355.0 | 195.0; 56.284; 60.0 | electrical generating capacity in megawatts [number] | maks 3 digit desimal |
| 6 | latitude | latitude | numeric | numeric(10,7) | 0.0% | 132 | -10.1667 | 4.1196 | -4.8278; -8.5667; 1.1825 | geolocation in decimal degrees; WGS84 (EPSG:4326) [number] | lintang |
| 7 | longitude | longitude | numeric | numeric(10,7) | 0.0% | 131 | 96.1972 | 136.8391 | 136.8391; 116.0667; 124.4806 | geolocation in decimal degrees; WGS84 (EPSG:4326) [number] | bujur |
| 8 | primary_fuel | primary_fuel | text | text | 0.0% | 5 |  |  | Coal (70); Hydro (41); Gas (41); Oil (16); Geothermal (10) | energy source used in primary electricity generation or export [text] | panjang 3-10 |
| 9 | other_fuel1 | other_fuel1 | empty | text | 100.0% | 0 |  |  |  | energy source used in electricity generation or export [text] | Kolom kosong seluruhnya. |
| 10 | other_fuel2 | other_fuel2 | empty | text | 100.0% | 0 |  |  |  | energy source used in electricity generation or export [text] | Kolom kosong seluruhnya. |
| 11 | other_fuel3 | other_fuel3 | empty | text | 100.0% | 0 |  |  |  | energy source used in electricity generation or export [text] | Kolom kosong seluruhnya. |
| 12 | commissioning_year | commissioning_year | integer | integer | 88.8% | 10 | 1998 | 2017 | 2015.0 (5); 2017.0 (3); 2016.0 (3); 2012.0 (2); 2011.0 (2); 1998.0 (1… | year of plant operation, weighted by unit-capacity when data is available [number] | tahun |
| 13 | owner | owner | text | text | 0.0% | 96 |  |  | PT Puncakjaya Power; PLN - West Nusa Tenggara Regional Unit/NTB; PLN | majority shareholder of the power plant, generally in Romanized form [text] | 1 nilai berbeda hanya karena huruf besar/kecil/spasi; panjang 3-111 |
| 14 | source | source | text | text | 0.0% | 2 |  |  | Indonesia Power Generation (158); GCPT (20) | entity reporting the data; could be an organization, report, or document, generally in Romanized form [text] | panjang 4-26 |
| 15 | url | url | text | text | 0.0% | 2 |  |  | https://repit.wordpress.com/ (158); https://endcoal.org/global-coal-p… | web document corresponding to the `source` field [text] | panjang 28-46 |
| 16 | geolocation_source | geolocation_source | text | text | 0.0% | 4 |  |  | CARMA (88); WRI (40); GEODB (30); GCPT (20) | attribution for geolocation information [text] | panjang 3-5 |
| 17 | wepp_id | wepp_id | integer | integer | 34.3% | 88 | 1010414 | 1102412 | 1026032; 1076093; 1026035 | a reference to a unique plant identifier in the widely-used PLATTS-WEPP database. [text] |  |
| 18 | year_of_capacity_data | year_of_capacity_data | empty | text | 100.0% | 0 |  |  |  | year the capacity information was reported [number] | Kolom kosong seluruhnya. |
| 19 | generation_gwh_2013 | generation_gwh_2013 | empty | text | 100.0% | 0 |  |  |  | electricity generation in gigawatt-hours reported for the year 2013 [number] | Kolom kosong seluruhnya. |
| 20 | generation_gwh_2014 | generation_gwh_2014 | empty | text | 100.0% | 0 |  |  |  | electricity generation in gigawatt-hours reported for the year 2014 [number] | Kolom kosong seluruhnya. |
| 21 | generation_gwh_2015 | generation_gwh_2015 | empty | text | 100.0% | 0 |  |  |  | electricity generation in gigawatt-hours reported for the year 2015 [number] | Kolom kosong seluruhnya. |
| 22 | generation_gwh_2016 | generation_gwh_2016 | empty | text | 100.0% | 0 |  |  |  | electricity generation in gigawatt-hours reported for the year 2016 [number] | Kolom kosong seluruhnya. |
| 23 | generation_gwh_2017 | generation_gwh_2017 | empty | text | 100.0% | 0 |  |  |  | electricity generation in gigawatt-hours reported for the year 2017 [number] | Kolom kosong seluruhnya. |
| 24 | generation_gwh_2018 | generation_gwh_2018 | empty | text | 100.0% | 0 |  |  |  | electricity generation in gigawatt-hours reported for the year 2018 [number] | Kolom kosong seluruhnya. |
| 25 | generation_gwh_2019 | generation_gwh_2019 | empty | text | 100.0% | 0 |  |  |  | electricity generation in gigawatt-hours reported for the year 2019 [number] | Kolom kosong seluruhnya. |
| 26 | generation_data_source | generation_data_source | empty | text | 100.0% | 0 |  |  |  | attribution for the reported generation information [text] | Kolom kosong seluruhnya. |
| 27 | estimated_generation_gwh_2013 | estimated_generation_gwh_2013 | numeric | numeric | 77.0% | 40 | 2.83 | 3426.09 | 614.23; 423.60; 338.09 | estimated electricity generation in gigawatt-hours for the year 2013 (see [2]) [number] | maks 2 digit desimal |
| 28 | estimated_generation_gwh_2014 | estimated_generation_gwh_2014 | numeric | numeric | 77.0% | 41 | 2.23 | 2354.32 | 443.82; 334.58; 252.07 | estimated electricity generation in gigawatt-hours for the year 2014 (see [2]) [number] | maks 2 digit desimal |
| 29 | estimated_generation_gwh_2015 | estimated_generation_gwh_2015 | numeric | numeric | 77.0% | 41 | 2.96 | 3099.69 | 523.30; 350.67; 306.96 | estimated electricity generation in gigawatt-hours for the year 2015 (see [2]) [number] | maks 2 digit desimal |
| 30 | estimated_generation_gwh_2016 | estimated_generation_gwh_2016 | numeric | numeric | 77.0% | 41 | 3.02 | 3272.44 | 555.94; 415.34; 344.30 | estimated electricity generation in gigawatt-hours for the year 2016 (see [2]) [number] | maks 2 digit desimal |
| 31 | estimated_generation_gwh_2017 | estimated_generation_gwh_2017 | numeric | numeric | 5.6% | 139 | 3.01 | 29141.78 | 1061.18; 101.59; 326.51 | estimated electricity generation in gigawatt-hours for the year 2017 (see [2]) [number] | maks 2 digit desimal |
| 32 | estimated_generation_note_2013 | estimated_generation_note_2013 | text | text | 0.0% | 2 |  |  | NO-ESTIMATION (137); HYDRO-V1 (41) | label of the model/method used to estimate generation for the year 2013 (see section on this field below) [te… | panjang 8-13 |
| 33 | estimated_generation_note_2014 | estimated_generation_note_2014 | text | text | 0.0% | 2 |  |  | NO-ESTIMATION (137); HYDRO-V1 (41) | label of the model/method used to estimate generation for the year 2014 (see section on this field below) [te… | panjang 8-13 |
| 34 | estimated_generation_note_2015 | estimated_generation_note_2015 | text | text | 0.0% | 2 |  |  | NO-ESTIMATION (137); HYDRO-V1 (41) | label of the model/method used to estimate generation for the year 2015 (see section on this field below) [te… | panjang 8-13 |
| 35 | estimated_generation_note_2016 | estimated_generation_note_2016 | text | text | 0.0% | 2 |  |  | NO-ESTIMATION (137); HYDRO-V1 (41) | label of the model/method used to estimate generation for the year 2016 (see section on this field below) [te… | panjang 8-13 |
| 36 | estimated_generation_note_2017 | estimated_generation_note_2017 | text | text | 0.0% | 3 |  |  | CAPACITY-FACTOR-V1 (127); HYDRO-V1 (41); NO-ESTIMATION (10) | label of the model/method used to estimate generation for the year 2017 (see section on this field below) [te… | panjang 8-18 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,country,country_long,name,gppd_idnr,capacity_mw,latitude,longitude,primary_fuel,other_fuel1,other_fuel2,other_fuel3,commissioning_year,owner,source,url,geolocation_source,wepp_id,year_of_capacity_data,generation_gwh_2013,generation_gwh_2014,generation_gwh_2015,generation_gwh_2016,generation_gwh_2017,generation_gwh_2018,generation_gwh_2019,generation_data_source,estimated_generation_gwh_2013,estimated_generation_gwh_2014,estimated_generation_gwh_2015,estimated_generation_gwh_2016,estimated_generation_gwh_2017,estimated_generation_note_2013,estimated_generation_note_2014,estimated_generation_note_2015,estimated_generation_note_2016,estimated_generation_note_2017
1,IDN,Indonesia,Amamapare Port power station,WRI1075798,195.0,-4.8278,136.8391,Coal,,,,1998.0,PT Puncakjaya Power,GCPT,https://endcoal.org/global-coal-plant-tracker/,GCPT,,,,,,,,,,,,,,,1061.18,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,CAPACITY-FACTOR-V1
2,IDN,Indonesia,Ampenan,WRI1000736,56.284,-8.5667,116.0667,Oil,,,,,PLN - West Nusa Tenggara Regional Unit/NTB,Indonesia Power Generation,https://repit.wordpress.com/,CARMA,1026032,,,,,,,,,,,,,,101.59,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,CAPACITY-FACTOR-V1
3,IDN,Indonesia,Amurang power station,WRI1075799,60.0,1.1825,124.4806,Coal,,,,2012.0,PLN,GCPT,https://endcoal.org/global-coal-plant-tracker/,GCPT,,,,,,,,,,,,,,,326.51,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,CAPACITY-FACTOR-V1
4,IDN,Indonesia,Asahan I,WRI1000737,180.0,2.5113,99.2590,Hydro,,,,,PT Bajradaya Sentranusa (China Huadian Corporation 70% + PJB 26.5%+Nus,Indonesia Power Generation,https://repit.wordpress.com/,WRI,1076093,,,,,,,,,,614.23,443.82,523.30,555.94,592.43,HYDRO-V1,HYDRO-V1,HYDRO-V1,HYDRO-V1,HYDRO-V1
18,IDN,Indonesia,Darajat 1,WRI1000750,55.0,-7.2173,107.7394,Geothermal,,,,,PLN – Indonesia Power,Indonesia Power Generation,https://repit.wordpress.com/,WRI,,,,,,,,,,,,,,,,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION
19,IDN,Indonesia,Darajat 2  3,WRI1000751,215.0,-7.2173,107.7394,Geothermal,,,,,PT. Chevron Geothermal Darajat  Ltd,Indonesia Power Generation,https://repit.wordpress.com/,WRI,,,,,,,,,,,,,,,,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION
148,IDN,Indonesia,Perawang Mill power station,WRI1075814,755.0,0.6893,101.6191,Coal,,,,2009.0,PT Indah Kiat Pulp & Paper,GCPT,https://endcoal.org/global-coal-plant-tracker/,GCPT,,,,,,,,,,,,,,,4108.69,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,CAPACITY-FACTOR-V1
37,IDN,Indonesia,Kracak/saguling,WRI1000776,18.9,-6.9039,107.6186,Hydro,,,,,PLN - PT. Indonesia Power,Indonesia Power Generation,https://repit.wordpress.com/,CARMA,1026135,,,,,,,,,,69.59,64.51,62.95,74.85,64.25,HYDRO-V1,HYDRO-V1,HYDRO-V1,HYDRO-V1,HYDRO-V1
168,IDN,Indonesia,Tanjung Awar-Awar power station,WRI1075817,700.0,-6.8105,111.9955,Coal,,,,2012.0,PT PLN Persero,GCPT,https://endcoal.org/global-coal-plant-tracker/,GCPT,,,,,,,,,,,,,,,3809.38,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,NO-ESTIMATION,CAPACITY-FACTOR-V1
```

## SRC-08 - OpenStreetMap gardu induk (Overpass Turbo export)
- Sumber: https://overpass-turbo.eu
- Lisensi: ODbL (atribusi (c) OpenStreetMap contributors)
- Grain: titik pusat: 1 elemen OSM (node/way/relation) bertag power=substation
- Status kesiapan: **READY**
- Pemeriksaan kolom yang diharapkan: id elemen: ADA; tag power: ADA; tag voltage: ADA; operator: ADA

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
| 2 | building | building | text | text | 45.3% | 12 |  |  | power_substation (1412); yes (75); service (42); house (4); industria… |  | panjang 2-16 |
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
| 15 | ref | ref | text | text | 98.7% | 37 |  |  | PLN (2); PDN (1); UNGR (1); BRJ (1); BTRTI (1); PSGRN (1); GLNUK (1);… |  | panjang 2-12 |
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
2793,node/6486002803,,,,,substation,,node/6486002803,Point,,,,,,,,,,,,,,,
2790,node/5304523192,,,,,substation,,node/5304523192,Point,,,,,,,,,,,,,,,
2286,way/966209489,,Perusahaan Listrik Negara,PLN,Q4201636,substation,center,way/966209489,Point,outdoor,Gardu Induk Pangeran Karang,distribution,150000,,,,,,,,,,,
2264,way/960747936,,Perusahaan Listrik Negara,PLN,Q4201636,substation,center,way/960747936,Point,outdoor,GITET Deltamas,transmission,500000;150000,id:Perusahaan Listrik Negara,,,,,,,,,,
547,way/494571065,power_substation,PT Perusahaan Listrik Negara,,,substation,center,way/494571065,Point,,Gardu Area Pondok Kopi PB 7,distribution,,,,DKI Jakarta,HOT_InAWARESurvey_2017,,Jalan Gebang Mutiara V,,,,,
```

## SRC-09 - Sebaran PoP ISP (Komdigi)
- Sumber: https://datahub.komdigi.go.id/public/detail-data/173
- Lisensi: Data publik (atribusi Komdigi)
- Grain: provinsi x tahun
- Status kesiapan: **READY**
- Pemeriksaan kolom yang diharapkan: provinsi: ADA; jumlah PoP: ADA; tahun: ADA

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
| 2 | Sebaran PoP ISP | sebaran_pop_isp | integer | integer | 0.0% | 32 | 3 | 1175 | 13 (2); 23 (2); 45 (1); 205 (1); 362 (1); 17 (1); 489 (1); 49 (1) | Jumlah Point of Presence ISP |  |
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

## SRC-10 - Komponen Penyusun Indeks Kualitas Lingkungan Hidup (BPS)
- Sumber: https://www.bps.go.id
- Lisensi: Data publik BPS (atribusi BPS)
- Grain: provinsi x tahun (satu file per tahun; komponen sebagai kolom)
- Status kesiapan: **CHECK**
  - [rentang waktu] Rentang aktual 2021-2024 tidak mencakup rentang yang diklaim proposal (2019-2024).
- Pemeriksaan kolom yang diharapkan: provinsi: ADA; tahun: ADA; indeks kualitas air: ADA

### SRC-10 / Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2021.csv
- Format: csv (reader: bps) | 2,038 byte
- SHA-256: `5852fc451eb750b86c48ec6365d5584766d8f3d7719192747bfdeab4069fcaba`
- Baris: 38 | kolom: 8 | baris duplikat penuh: 0
- Uji kunci (provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari baris header 4.
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: Header memakai baris 3, 4; data baris 5-43.
- Sebaran per tahun, kolom `tahun` (2021 s.d. 2021): 2021:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| indeks 0-100: `0 <= Indeks Kualitas Udara <= 100` | Indeks Kualitas Udara | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air <= 100` | Indeks Kualitas Air | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Tutupan Lahan (IKTL) <= 100` | Indeks Kualitas Tutupan Lahan (IKTL) | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Lahan (IKL) <= 100` | Indeks Kualitas Lahan (IKL) | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Ekosistem Gambut (IKEG) <= 1…` | Indeks Kualitas Ekosistem Gambut (IKEG) | 19 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air Laut (IKAL) <= 100` | Indeks Kualitas Air Laut (IKAL) | 34 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | provinsi | provinsi | text | text | 0.0% | 38 |  |  | ACEH (1); SUMATERA UTARA (1); SUMATERA BARAT (1); RIAU (1); JAMBI (1)… | Nama provinsi (HURUF BESAR; 38 provinsi) | panjang 4-20; KANDIDAT KUNCI |
| 2 | Indeks Kualitas Udara | indeks_kualitas_udara | numeric | numeric | 0.0% | 34 | 66.52 | 95.6 | 89.63; 89.55; 90.22 | Komponen IKLH: indeks kualitas udara (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 3 | Indeks Kualitas Air | indeks_kualitas_air | numeric | numeric | 0.0% | 35 | 43.09 | 58.37 | 57.14; 53.72; 52.55 | Komponen IKLH: indeks kualitas air sungai/permukaan (0-100); bukan ukuran ketersediaan air | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 4 | Indeks Kualitas Tutupan Lahan (IKTL) | indeks_kualitas_tutupan_lahan_iktl | numeric | numeric | 0.0% | 33 | 26.25 | 100.0 | 76.63; 48.89; 66.29 | Komponen IKLH: tutupan lahan (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 5 | Indeks Kualitas Lahan (IKL) | indeks_kualitas_lahan_ikl | numeric | numeric | 0.0% | 34 | 26.25 | 100.0 | 76.52; 48.84; 66.24 | Komponen IKLH: kualitas lahan (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 6 | Indeks Kualitas Ekosistem Gambut (IKEG) | indeks_kualitas_ekosistem_gambut_ikeg | numeric | numeric | 0.0% | 19 | 46.27 | 96.97 | 71.45; 46.27; 51.97 | Komponen IKLH: ekosistem gambut (0-100); '-' = provinsi tanpa gambut | 19 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 7 | Indeks Kualitas Air Laut (IKAL) | indeks_kualitas_air_laut_ikal | numeric | numeric | 0.0% | 34 | 70.34 | 87.55 | 76.51; 81.43; 83.75 | Komponen IKLH: air laut (0-100); '-' = tidak ada pengukuran | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 8 | tahun | tahun | integer | integer | 0.0% | 1 | 2021 | 2021 | 2021 (38) | Tahun (diturunkan dari baris header) | kolom KONSTAN (selalu '2021'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,provinsi,Indeks Kualitas Udara,Indeks Kualitas Air,Indeks Kualitas Tutupan Lahan (IKTL),Indeks Kualitas Lahan (IKL),Indeks Kualitas Ekosistem Gambut (IKEG),Indeks Kualitas Air Laut (IKAL),tahun
1,ACEH,89.63,57.14,76.63,76.52,71.45,76.51,2021
2,SUMATERA UTARA,89.55,53.72,48.89,48.84,46.27,81.43,2021
3,SUMATERA BARAT,90.22,52.55,66.29,66.24,51.97,83.75,2021
4,RIAU,90.13,52.25,51.4,50.22,72.21,77.73,2021
10,KEP. RIAU,90.91,55.15,60.48,60.39,63.34,75.68,2021
22,KALIMANTAN SELATAN,89.15,54.75,50.48,50.26,56.47,76.45,2021
```

### SRC-10 / Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2022.csv
- Format: csv (reader: bps) | 2,031 byte
- SHA-256: `bc105c9ddf344f82b6c7cbf7e4ed24c1d2a576fb22848f4522ed22a1c0d3b780`
- Baris: 38 | kolom: 8 | baris duplikat penuh: 0
- Uji kunci (provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari baris header 4.
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: Header memakai baris 3, 4; data baris 5-43.
- Sebaran per tahun, kolom `tahun` (2022 s.d. 2022): 2022:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| indeks 0-100: `0 <= Indeks Kualitas Udara <= 100` | Indeks Kualitas Udara | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air <= 100` | Indeks Kualitas Air | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Tutupan Lahan (IKTL) <= 100` | Indeks Kualitas Tutupan Lahan (IKTL) | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Lahan (IKL) <= 100` | Indeks Kualitas Lahan (IKL) | 34 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Ekosistem Gambut (IKEG) <= 1…` | Indeks Kualitas Ekosistem Gambut (IKEG) | 19 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air Laut (IKAL) <= 100` | Indeks Kualitas Air Laut (IKAL) | 34 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | provinsi | provinsi | text | text | 0.0% | 38 |  |  | ACEH (1); SUMATERA UTARA (1); SUMATERA BARAT (1); RIAU (1); JAMBI (1)… | Nama provinsi (HURUF BESAR; 38 provinsi) | panjang 4-20; KANDIDAT KUNCI |
| 2 | Indeks Kualitas Udara | indeks_kualitas_udara | numeric | numeric | 0.0% | 35 | 68.06 | 95.79 | 90.62; 89.69; 90.65 | Komponen IKLH: indeks kualitas udara (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 3 | Indeks Kualitas Air | indeks_kualitas_air | numeric | numeric | 0.0% | 35 | 39.31 | 62.0 | 60.41; 61.2; 55.64 | Komponen IKLH: indeks kualitas air sungai/permukaan (0-100); bukan ukuran ketersediaan air | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 4 | Indeks Kualitas Tutupan Lahan (IKTL) | indeks_kualitas_tutupan_lahan_iktl | numeric | numeric | 0.0% | 33 | 27.07 | 100.0 | 76.33; 48.9; 66.27 | Komponen IKLH: tutupan lahan (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 5 | Indeks Kualitas Lahan (IKL) | indeks_kualitas_lahan_ikl | numeric | numeric | 0.0% | 33 | 27.07 | 100.0 | 76.24; 48.69; 64.01 | Komponen IKLH: kualitas lahan (0-100) | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 6 | Indeks Kualitas Ekosistem Gambut (IKEG) | indeks_kualitas_ekosistem_gambut_ikeg | numeric | numeric | 0.0% | 20 | 42.35 | 96.87 | 71.15; 42.35; 46.64 | Komponen IKLH: ekosistem gambut (0-100); '-' = provinsi tanpa gambut | 19 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 7 | Indeks Kualitas Air Laut (IKAL) | indeks_kualitas_air_laut_ikal | numeric | numeric | 0.0% | 34 | 63.3 | 89.48 | 89.2; 85.19; 88.32 | Komponen IKLH: air laut (0-100); '-' = tidak ada pengukuran | 4 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 8 | tahun | tahun | integer | integer | 0.0% | 1 | 2022 | 2022 | 2022 (38) | Tahun (diturunkan dari baris header) | kolom KONSTAN (selalu '2022'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,provinsi,Indeks Kualitas Udara,Indeks Kualitas Air,Indeks Kualitas Tutupan Lahan (IKTL),Indeks Kualitas Lahan (IKL),Indeks Kualitas Ekosistem Gambut (IKEG),Indeks Kualitas Air Laut (IKAL),tahun
1,ACEH,90.62,60.41,76.33,76.24,71.15,89.2,2022
2,SUMATERA UTARA,89.69,61.2,48.9,48.69,42.35,85.19,2022
3,SUMATERA BARAT,90.65,55.64,66.27,64.01,46.64,88.32,2022
4,RIAU,90.69,53.88,51.4,50,66.54,83.95,2022
10,KEP. RIAU,90.27,56.79,59.15,58.29,63.58,85.56,2022
22,KALIMANTAN SELATAN,89.52,54.63,50.82,50.52,49.63,84.42,2022
```

### SRC-10 / Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2023.csv
- Format: csv (reader: bps) | 2,120 byte
- SHA-256: `06ca43745149cedea0ade1f5e2b2f2605ba07cc2433960436d26229bec73f47d`
- Baris: 38 | kolom: 8 | baris duplikat penuh: 0
- Uji kunci (provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari baris header 4.
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: Header memakai baris 3, 4; data baris 5-43.
- Sebaran per tahun, kolom `tahun` (2023 s.d. 2023): 2023:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| indeks 0-100: `0 <= Indeks Kualitas Udara <= 100` | Indeks Kualitas Udara | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air <= 100` | Indeks Kualitas Air | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Tutupan Lahan (IKTL) <= 100` | Indeks Kualitas Tutupan Lahan (IKTL) | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Lahan (IKL) <= 100` | Indeks Kualitas Lahan (IKL) | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Ekosistem Gambut (IKEG) <= 1…` | Indeks Kualitas Ekosistem Gambut (IKEG) | 23 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air Laut (IKAL) <= 100` | Indeks Kualitas Air Laut (IKAL) | 36 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | provinsi | provinsi | text | text | 0.0% | 38 |  |  | ACEH (1); SUMATERA UTARA (1); SUMATERA BARAT (1); RIAU (1); JAMBI (1)… | Nama provinsi (HURUF BESAR; 38 provinsi) | panjang 4-20; KANDIDAT KUNCI |
| 2 | Indeks Kualitas Udara | indeks_kualitas_udara | numeric | numeric | 0.0% | 37 | 66.67 | 97.68 | 90.94; 90.9; 90.53 | Komponen IKLH: indeks kualitas udara (0-100) | maks 2 digit desimal |
| 3 | Indeks Kualitas Air | indeks_kualitas_air | numeric | numeric | 0.0% | 38 | 40.28 | 64.67 | 61.3; 60.27; 57.05 | Komponen IKLH: indeks kualitas air sungai/permukaan (0-100); bukan ukuran ketersediaan air | maks 2 digit desimal |
| 4 | Indeks Kualitas Tutupan Lahan (IKTL) | indeks_kualitas_tutupan_lahan_iktl | numeric | numeric | 0.0% | 34 | 27.17 | 100.0 | 76.52; 49.78; 66.95 | Komponen IKLH: tutupan lahan (0-100) | maks 2 digit desimal |
| 5 | Indeks Kualitas Lahan (IKL) | indeks_kualitas_lahan_ikl | numeric | numeric | 0.0% | 36 | 27.17 | 100.0 | 76.51; 49.77; 68.98 | Komponen IKLH: kualitas lahan (0-100) | maks 2 digit desimal |
| 6 | Indeks Kualitas Ekosistem Gambut (IKEG) | indeks_kualitas_ekosistem_gambut_ikeg | numeric | numeric | 0.0% | 24 | 41.43 | 97.49 | 69.53; 42.38; 44.09 | Komponen IKLH: ekosistem gambut (0-100); '-' = provinsi tanpa gambut | 15 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 7 | Indeks Kualitas Air Laut (IKAL) | indeks_kualitas_air_laut_ikal | numeric | numeric | 0.0% | 37 | 68.56 | 86.83 | 86.75; 68.56; 86.19 | Komponen IKLH: air laut (0-100); '-' = tidak ada pengukuran | 2 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 8 | tahun | tahun | integer | integer | 0.0% | 1 | 2023 | 2023 | 2023 (38) | Tahun (diturunkan dari baris header) | kolom KONSTAN (selalu '2023'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,provinsi,Indeks Kualitas Udara,Indeks Kualitas Air,Indeks Kualitas Tutupan Lahan (IKTL),Indeks Kualitas Lahan (IKL),Indeks Kualitas Ekosistem Gambut (IKEG),Indeks Kualitas Air Laut (IKAL),tahun
1,ACEH,90.94,61.3,76.52,76.51,69.53,86.75,2023
2,SUMATERA UTARA,90.9,60.27,49.78,49.77,42.38,68.56,2023
3,SUMATERA BARAT,90.53,57.05,66.95,68.98,44.09,86.19,2023
4,RIAU,90.89,50.84,51.27,51.59,66.19,74.39,2023
10,KEP. RIAU,90.13,54.93,66.02,66.97,63.7,81.81,2023
22,KALIMANTAN SELATAN,92.85,55.64,52.05,52.08,49.19,79.94,2023
```

### SRC-10 / Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2024.csv
- Format: csv (reader: bps) | 2,108 byte
- SHA-256: `820554f61013936b432f91caebed34b9ae574ba3c74c8d3cb54a75a6002649df`
- Baris: 38 | kolom: 8 | baris duplikat penuh: 0
- Uji kunci (provinsi, tahun): UNIK (0 duplikat, 0 baris ber-null)
- Catatan: Kolom tahun diturunkan dari baris header 4.
- Catatan: 1 baris total nasional (INDONESIA) dilewati; bukan data wilayah.
- Catatan: Header memakai baris 3, 4; data baris 5-43.
- Sebaran per tahun, kolom `tahun` (2024 s.d. 2024): 2024:38

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| indeks 0-100: `0 <= Indeks Kualitas Udara <= 100` | Indeks Kualitas Udara | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air <= 100` | Indeks Kualitas Air | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Tutupan Lahan (IKTL) <= 100` | Indeks Kualitas Tutupan Lahan (IKTL) | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Lahan (IKL) <= 100` | Indeks Kualitas Lahan (IKL) | 38 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Ekosistem Gambut (IKEG) <= 1…` | Indeks Kualitas Ekosistem Gambut (IKEG) | 23 | 0 | 0.00% |  |
| indeks 0-100: `0 <= Indeks Kualitas Air Laut (IKAL) <= 100` | Indeks Kualitas Air Laut (IKAL) | 37 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | provinsi | provinsi | text | text | 0.0% | 38 |  |  | ACEH (1); SUMATERA UTARA (1); SUMATERA BARAT (1); RIAU (1); JAMBI (1)… | Nama provinsi (HURUF BESAR; 38 provinsi) | panjang 4-20; KANDIDAT KUNCI |
| 2 | Indeks Kualitas Udara | indeks_kualitas_udara | numeric | numeric | 0.0% | 37 | 69.84 | 96.41 | 92.81; 92.26; 92.27 | Komponen IKLH: indeks kualitas udara (0-100) | maks 2 digit desimal |
| 3 | Indeks Kualitas Air | indeks_kualitas_air | numeric | numeric | 0.0% | 37 | 41.22 | 65.32 | 63.25; 61.09; 53.16 | Komponen IKLH: indeks kualitas air sungai/permukaan (0-100); bukan ukuran ketersediaan air | maks 2 digit desimal |
| 4 | Indeks Kualitas Tutupan Lahan (IKTL) | indeks_kualitas_tutupan_lahan_iktl | numeric | numeric | 0.0% | 34 | 27.49 | 100.0 | 76.65; 50.26; 66.5 | Komponen IKLH: tutupan lahan (0-100) | maks 2 digit desimal |
| 5 | Indeks Kualitas Lahan (IKL) | indeks_kualitas_lahan_ikl | numeric | numeric | 0.0% | 34 | 27.49 | 100.0 | 76.66; 50.26; 66.63 | Komponen IKLH: kualitas lahan (0-100) | maks 2 digit desimal |
| 6 | Indeks Kualitas Ekosistem Gambut (IKEG) | indeks_kualitas_ekosistem_gambut_ikeg | numeric | numeric | 0.0% | 24 | 42.41 | 97.96 | 71.37; 42.41; 45.81 | Komponen IKLH: ekosistem gambut (0-100); '-' = provinsi tanpa gambut | 15 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 7 | Indeks Kualitas Air Laut (IKAL) | indeks_kualitas_air_laut_ikal | numeric | numeric | 0.0% | 38 | 70.82 | 88.34 | 83.24; 70.82; 84.18 | Komponen IKLH: air laut (0-100); '-' = tidak ada pengukuran | 1 nilai berupa token kosong ('-') - jadikan NULL di staging; maks 2 digit desimal |
| 8 | tahun | tahun | integer | integer | 0.0% | 1 | 2024 | 2024 | 2024 (38) | Tahun (diturunkan dari baris header) | kolom KONSTAN (selalu '2024'); tahun |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,provinsi,Indeks Kualitas Udara,Indeks Kualitas Air,Indeks Kualitas Tutupan Lahan (IKTL),Indeks Kualitas Lahan (IKL),Indeks Kualitas Ekosistem Gambut (IKEG),Indeks Kualitas Air Laut (IKAL),tahun
1,ACEH,92.81,63.25,76.65,76.66,71.37,83.24,2024
2,SUMATERA UTARA,92.26,61.09,50.26,50.26,42.41,70.82,2024
3,SUMATERA BARAT,92.27,53.16,66.5,66.63,45.81,84.18,2024
4,RIAU,89.66,52.69,51.29,51.25,66.65,77.47,2024
10,KEP. RIAU,92.12,53.98,66.18,66.18,63.77,85.53,2024
22,KALIMANTAN SELATAN,96.41,56.08,52.2,52,44.54,84.27,2024
```
