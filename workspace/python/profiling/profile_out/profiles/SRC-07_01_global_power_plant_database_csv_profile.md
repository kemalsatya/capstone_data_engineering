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
