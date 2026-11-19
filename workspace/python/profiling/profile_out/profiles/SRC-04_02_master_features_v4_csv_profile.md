### SRC-04 / master_features_v4.csv
- Format: csv (reader: csv) | delimiter , | encoding utf-8-sig | 222,578 byte
- SHA-256: `320d1eb62f0e828b03b1ed694943d1d534b36807edc538a566384e4eb201970f`
- Baris: 514 | kolom: 45 | baris duplikat penuh: 0
- Uji kunci (bps_kabkota_code): UNIK (0 duplikat, 0 baris ber-null)

Aturan domain (USULAN; konfirmasi pemilik data) dan hasil pengukuran pada data:

| Aturan | Kolom | Valid | Pelanggaran | % | Contoh pelanggaran |
|---|---|---|---|---|---|
| indeks/persentase 0-100: `0 <= ipm_2023 <= 100` | ipm_2023 | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= ipm_2024 <= 100` | ipm_2024 | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= ppm_2023 <= 100` | ppm_2023 | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= ppm_2024 <= 100` | ppm_2024 | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_tree_cover <= 100` | pct_tree_cover | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_shrubland <= 100` | pct_shrubland | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_grassland <= 100` | pct_grassland | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_cropland <= 100` | pct_cropland | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_built_up <= 100` | pct_built_up | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_bare_sparse_veg <= 100` | pct_bare_sparse_veg | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_snow_ice <= 100` | pct_snow_ice | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_water <= 100` | pct_water | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_wetland <= 100` | pct_wetland | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_mangroves <= 100` | pct_mangroves | 514 | 0 | 0.00% |  |
| indeks/persentase 0-100: `0 <= pct_moss_lichen <= 100` | pct_moss_lichen | 514 | 0 | 0.00% |  |
| penduduk > 0: `1 <= population_2023 <= +inf` | population_2023 | 514 | 0 | 0.00% |  |
| penduduk > 0: `1 <= population_2024 <= +inf` | population_2024 | 514 | 0 | 0.00% |  |

| # | Kolom sumber | Nama db | Tipe terdeteksi | Tipe PG (usulan) | Null % | Distinct | Min | Max | Contoh / teratas | Definisi | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | bps_kabkota_code | bps_kabkota_code | integer | integer | 0.0% | 514 | 1101 | 9708 | 1107; 1112; 1108 | (identifier) Official BPS kode wilayah for the regency, resolved through the boundary-to-BPS crosswalk. [inte… | KANDIDAT KUNCI |
| 2 | kabkota_name | kabkota_name | text | text | 0.0% | 514 |  |  | Aceh Barat; Aceh Barat Daya; Aceh Besar | (identifier) Regency/city name as recorded by BPS (matched_bps_name). [text] | panjang 4-42; KANDIDAT KUNCI |
| 3 | prov_name | prov_name | text | text | 0.0% | 38 |  |  | Jawa Timur (38); Jawa Tengah (35); Sumatera Utara (33); Jawa Barat (2… | (identifier) Province name, BPS naming, 38 distinct values. [text] | panjang 4-20 |
| 4 | shapeName | shapename | text | text | 0.0% | 514 |  |  | Aceh Barat; Aceh Barat Daya; Aceh Besar | (identifier) Regency name as recorded in the geoBoundaries ADM2 boundary layer (join key used before the cros… | panjang 4-26; KANDIDAT KUNCI |
| 5 | crosswalk_match_type | crosswalk_match_type | text | text | 0.0% | 3 |  |  | exact (503); manual_alias (7); fuzzy (4) | (join-quality diagnostic) How this row's shapeName was matched to a BPS record: exact (n=503), manual_alias (… | panjang 5-12 |
| 6 | crosswalk_match_score | crosswalk_match_score | numeric | numeric | 0.0% | 5 | 0.941 | 1.0 | 1.0; 0.952; 0.941 | (join-quality diagnostic) String-similarity score of the match. 1.0 for exact and manual_alias rows; 0.82-1.0… | maks 3 digit desimal |
| 7 | ipm_2023 | ipm_2023 | numeric | numeric | 0.0% | 450 | 35.19 | 88.28 | 72.88; 68.07; 74.53 | (socioeconomic) Human Development Index (IPM), 2023, BPS Web API var_id 413 (new methodology series). [float,… | maks 2 digit desimal |
| 8 | ipm_2024 | ipm_2024 | numeric | numeric | 0.0% | 444 | 36.3 | 88.77 | 73.69; 68.75; 75.13 | (socioeconomic) Human Development Index (IPM), 2024, BPS Web API var_id 413. [float, index 0-100] | maks 2 digit desimal |
| 9 | ppm_2023 | ppm_2023 | numeric | numeric | 0.0% | 455 | 2.27 | 40.01 | 17.86; 15.43; 13.38 | (socioeconomic) Poverty rate (persentase penduduk miskin), 2023, BPS Web API. [float, percent] | maks 2 digit desimal |
| 10 | ppm_2024 | ppm_2024 | numeric | numeric | 0.0% | 450 | 2.23 | 41.42 | 17.6; 15.32; 13.21 | (socioeconomic) Poverty rate, 2024, BPS Web API. [float, percent] | maks 2 digit desimal |
| 11 | population_2023 | population_2023 | integer | integer | 0.0% | 514 | 24013 | 5627021 | 204768; 156990; 422373 | (socioeconomic) Total population, 2023, BPS. [integer, persons] | KANDIDAT KUNCI |
| 12 | population_2024 | population_2024 | integer | integer | 0.0% | 513 | 24527 | 5682303 | 206822; 159187; 428254 | (socioeconomic) Total population, 2024, BPS. [integer, persons] |  |
| 13 | ntl_radiance_mean | ntl_radiance_mean | numeric | numeric | 0.0% | 514 | 0.1467609274544659 | 63.87838706280524 | 0.4590617028527347; 0.3856696161413696; 1.116737214742774 | (nighttime lights) Zonal mean VIIRS Black Marble (VNP46A2) gap-filled, BRDF-corrected nighttime radiance, 202… | maks 16 digit desimal |
| 14 | ntl_no_data | ntl_no_data | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the zonal-statistics pull returned no valid pixels for this district (False for a… | kolom KONSTAN (selalu 'False') |
| 15 | elevation_mean_m | elevation_mean_m | numeric | numeric | 0.0% | 514 | 3.263835879865598 | 3073.3049870709656 | 271.17127320672233; 614.1384461017434; 380.53171516669227 | (terrain) Zonal mean elevation, USGS SRTM, 30 m native resolution. [float, meters] | maks 16 digit desimal |
| 16 | elevation_std_m | elevation_std_m | numeric | numeric | 0.0% | 514 | 2.296272638619348 | 1263.479217830725 | 352.2239422754575; 591.9534034343097; 401.8943383057273 | (terrain) Zonal standard deviation of elevation, USGS SRTM. [float, meters] | maks 16 digit desimal |
| 17 | elevation_no_data | elevation_no_data | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the zonal-statistics pull returned no valid pixels for this district (False for a… | kolom KONSTAN (selalu 'False') |
| 18 | pct_tree_cover | pct_tree_cover | numeric | numeric | 0.0% | 513 | 7.782 | 99.526 | 92.143; 94.274; 78.039 | (land cover) Percent of district area classified as tree cover, ESA WorldCover v200 (2021). [float, percent] | maks 3 digit desimal |
| 19 | pct_shrubland | pct_shrubland | numeric | numeric | 0.0% | 182 | 0.0 | 11.54 | 0.163; 0.083; 0.014 | (land cover) Percent of district area classified as shrubland, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 20 | pct_grassland | pct_grassland | numeric | numeric | 0.0% | 507 | 0.234 | 58.167 | 3.709; 1.007; 13.766 | (land cover) Percent of district area classified as grassland, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 21 | pct_cropland | pct_cropland | numeric | numeric | 0.0% | 460 | 0.0 | 66.239 | 2.05; 3.543; 5.613 | (land cover) Percent of district area classified as cropland, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 22 | pct_built_up | pct_built_up | numeric | numeric | 0.0% | 489 | 0.001 | 91.127 | 0.468; 0.542; 1.519 | (land cover) Percent of district area classified as built-up, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 23 | pct_bare_sparse_veg | pct_bare_sparse_veg | numeric | numeric | 0.0% | 318 | 0.005 | 9.058 | 0.354; 0.123; 0.362 | (land cover) Percent of district area classified as bare / sparse vegetation, ESA WorldCover v200. [float, pe… | maks 3 digit desimal |
| 24 | pct_snow_ice | pct_snow_ice | numeric | numeric | 0.0% | 2 | 0.0 | 0.006 | 0.0; 0.006 | (land cover) Percent of district area classified as snow/ice, ESA WorldCover v200 (near-zero nationally). [fl… | maks 3 digit desimal |
| 25 | pct_water | pct_water | numeric | numeric | 0.0% | 458 | 0.0 | 20.664 | 0.975; 0.386; 0.631 | (land cover) Percent of district area classified as open water, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 26 | pct_wetland | pct_wetland | numeric | numeric | 0.0% | 241 | 0.0 | 17.432 | 0.139; 0.042; 0.057 | (land cover) Percent of district area classified as herbaceous wetland, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 27 | pct_mangroves | pct_mangroves | numeric | numeric | 0.0% | 256 | 0.0 | 29.349 | 0.0; 1.525; 6.584 | (land cover) Percent of district area classified as mangroves, ESA WorldCover v200. [float, percent] | maks 3 digit desimal |
| 28 | pct_moss_lichen | pct_moss_lichen | numeric | numeric | 0.0% | 1 | 0 | 0 | 0.0 (514) | (land cover) Percent of district area classified as moss and lichen, ESA WorldCover v200 (near-zero nationall… | kolom KONSTAN (selalu '0.0'); float menurut kamus data (nilai teramati bulat) |
| 29 | landcover_no_data | landcover_no_data | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the zonal-statistics pull returned no valid pixels for this district (False for a… | kolom KONSTAN (selalu 'False') |
| 30 | tertinggal_status | tertinggal_status | text | text | 0.0% | 3 |  |  | Tidak Tertinggal (484); Tertinggal (18); Sangat Tertinggal (12) | (target label) Official three-level designation: Tidak Tertinggal (n=484), Tertinggal (n=18), Sangat Tertingg… | panjang 10-17 |
| 31 | is_tertinggal | is_tertinggal | boolean | boolean | 0.0% | 2 |  |  | False (484); True (30) | (target label) Collapsed binary form of tertinggal_status. True for Tertinggal or Sangat Tertinggal (n=30 of … |  |
| 32 | allsky_sfc_sw_dwn_mean | allsky_sfc_sw_dwn_mean | numeric | numeric | 0.0% | 399 | 184.838994 | 250.32492 | 205.694922; 203.16794533333336; 207.989166 | (solar) Zonal mean all-sky surface shortwave downward radiation, NASA POWER syn1deg product (S3 Zarr), 2020-2… | maks 14 digit desimal |
| 33 | t2m_mean | t2m_mean | numeric | numeric | 0.0% | 491 | 14.683164774999998 | 28.3389184 | 25.2980834; 23.5082514; 27.2638012 | (weather) Zonal mean 2-meter air temperature, NASA POWER MERRA-2 product, 2020-2024 mean. Range in this relea… | maks 15 digit desimal |
| 34 | ws10m_mean | ws10m_mean | numeric | numeric | 0.0% | 491 | 0.6255823686666667 | 5.628532706 | 1.8616251625; 1.466333539; 3.810699000000001 | (weather) Zonal mean wind speed at 10 m, NASA POWER MERRA-2 product, 2020-2024 mean. Reference field, not use… | maks 16 digit desimal |
| 35 | ws50m_mean | ws50m_mean | numeric | numeric | 0.0% | 491 | 1.4705932044444443 | 6.351232013999999 | 2.569582585; 2.00116681; 4.3220326920000005 | (weather) Zonal mean wind speed at 50 m, NASA POWER MERRA-2 product, 2020-2024 mean. Reference field; r=0.974… | maks 16 digit desimal |
| 36 | rh2m_mean | rh2m_mean | numeric | numeric | 0.0% | 491 | 74.64247156666667 | 91.9281523076923 | 85.18883149999999; 85.93833219999999; 80.9022004 | (weather) Zonal mean relative humidity at 2 m, NASA POWER MERRA-2 product, 2020-2024 mean. [float, percent] | maks 14 digit desimal |
| 37 | prectotcorr_mean | prectotcorr_mean | numeric | numeric | 0.0% | 491 | 2.329777353333333 | 11.796330800000002 | 8.283499905; 9.375501; 7.563599672 | (weather) Zonal mean bias-corrected total precipitation, NASA POWER MERRA-2 product, 2020-2024 mean. [float, … | maks 16 digit desimal |
| 38 | solar_zonal_fallback | solar_zonal_fallback | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the solar zonal statistic used the nearest-centroid fallback instead of the all-t… | kolom KONSTAN (selalu 'False') |
| 39 | weather_zonal_fallback | weather_zonal_fallback | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the weather zonal statistic used the nearest-centroid fallback instead of the all… | kolom KONSTAN (selalu 'False') |
| 40 | wind_speed_100m_mean_ms | wind_speed_100m_mean_ms | numeric | numeric | 0.0% | 514 | 1.6897911647874997 | 5.977737092864706 | 2.099640879274229; 1.7612616022779508; 3.817219275762934 | (wind) Zonal mean wind speed at 100 m hub height, Global Wind Atlas 3.0, 10-year modeled mean, 250 m native r… | maks 16 digit desimal |
| 41 | wind_no_data | wind_no_data | boolean | boolean | 0.0% | 1 |  |  | False (514) | (data-quality flag) True if the zonal-statistics pull returned no valid pixels for this district (False for a… | kolom KONSTAN (selalu 'False') |
| 42 | road_length_km | road_length_km | numeric | numeric | 0.0% | 514 | 46.38606152224517 | 18385.40798988013 | 1992.6254142232588; 1070.0324762205; 4048.846127678659 | (infrastructure) Total road length within the district polygon, OpenStreetMap via Geofabrik regional extracts… | maks 14 digit desimal |
| 43 | road_density_km_per_km2 | road_density_km_per_km2 | numeric | numeric | 0.0% | 514 | 0.0104374189543153 | 32.19126434877429 | 0.7046399365282746; 0.5625751536176635; 1.3849712503682945 | (infrastructure) Road length divided by district area. [float, km per km2] | maks 16 digit desimal |
| 44 | dist_to_primary_trunk_km | dist_to_primary_trunk_km | numeric | numeric | 0.0% | 514 | 8.527396518150707e-05 | 128.39719841732824 | 1.3768692390967618; 8.656106291306767; 0.9014943741573684 | (infrastructure) Distance from the district's geometric polygon centroid to the nearest primary or trunk road… | maks 16 digit desimal |
| 45 | centroid_type | centroid_type | text | text | 0.0% | 1 |  |  | geometric (514) | (infrastructure) Method used to compute the district centroid for dist_to_primary_trunk_km. All 514 rows are … | kolom KONSTAN (selalu 'geometric'); panjang 9-9 |

Contoh baris (4 pertama, 2 dengan null terbanyak, 3 acak):

```csv
row,bps_kabkota_code,kabkota_name,prov_name,shapeName,crosswalk_match_type,crosswalk_match_score,ipm_2023,ipm_2024,ppm_2023,ppm_2024,population_2023,population_2024,ntl_radiance_mean,ntl_no_data,elevation_mean_m,elevation_std_m,elevation_no_data,pct_tree_cover,pct_shrubland,pct_grassland,pct_cropland,pct_built_up,pct_bare_sparse_veg,pct_snow_ice,pct_water,pct_wetland,pct_mangroves,pct_moss_lichen,landcover_no_data,tertinggal_status,is_tertinggal,allsky_sfc_sw_dwn_mean,t2m_mean,ws10m_mean,ws50m_mean,rh2m_mean,prectotcorr_mean,solar_zonal_fallback,weather_zonal_fallback,wind_speed_100m_mean_ms
1,1107,Aceh Barat,Aceh,Aceh Barat,exact,1.0,72.88,73.69,17.86,17.6,204768,206822,0.4590617028527347,False,271.17127320672233,352.2239422754575,False,92.143,0.163,3.709,2.05,0.468,0.354,0.0,0.975,0.139,0.0,0.0,False,Tidak Tertinggal,False,205.694922,25.2980834,1.8616251625,2.569582585,85.18883149999999,8.283499905,False,False,2.099640879274229
2,1112,Aceh Barat Daya,Aceh,Aceh Barat Daya,exact,1.0,68.07,68.75,15.43,15.32,156990,159187,0.3856696161413696,False,614.1384461017434,591.9534034343097,False,94.274,0.083,1.007,3.543,0.542,0.123,0.0,0.386,0.042,0.0,0.0,False,Tidak Tertinggal,False,203.16794533333336,23.5082514,1.466333539,2.00116681,85.93833219999999,9.375501,False,False,1.7612616022779508
3,1108,Aceh Besar,Aceh,Aceh Besar,exact,1.0,74.53,75.13,13.38,13.21,422373,428254,1.116737214742774,False,380.53171516669227,401.8943383057273,False,78.039,0.014,13.766,5.613,1.519,0.362,0.0,0.631,0.057,0.0,0.0,False,Tidak Tertinggal,False,207.989166,27.2638012,3.810699000000001,4.3220326920000005,80.9022004,7.563599672,False,False,3.817219275762934
4,1116,Aceh Jaya,Aceh,Aceh Jaya,exact,1.0,70.88,71.83,12.42,12.25,97638,99200,0.3021480622360339,False,376.3668958230951,400.2287308697739,False,94.847,0.132,3.261,0.674,0.177,0.078,0.0,0.705,0.125,0.0,0.0,False,Tidak Tertinggal,False,206.45967,25.728416433333333,2.591111901666667,3.239082826666667,83.56813883333335,8.086027379999999,False,False,2.4047512456627405
303,5208,Lombok Utara,Nusa Tenggara Barat,Lombok Utara,exact,1.0,66.62,67.24,25.8,23.96,257866,261557,0.6836006463324964,False,552.359846431499,575.272927284865,False,81.008,0.002,8.87,5.685,2.382,0.544,0.0,1.503,0.005,0.0,0.0,False,Tidak Tertinggal,False,231.79666200000003,27.284417500000004,2.53350117,3.14357958,79.4286635,4.538918499999999,False,False,2.635991527519108
116,8206,Halmahera Timur,Maluku Utara,Halmahera Timur,exact,1.0,68.82,69.58,12.47,11.91,96556,98224,0.2790884792531069,False,331.8930129891404,266.3307624642775,False,95.211,0.002,2.861,0.138,0.143,0.14,0.0,0.317,0.003,1.184,0.0,False,Tidak Tertinggal,False,213.6350435,27.463896025,3.1219175775,3.605915715,80.59595855,6.508604309999999,False,False,2.628682345052733
274,3319,Kudus,Jawa Tengah,Kudus,exact,1.0,76.71,77.22,7.24,7.23,874632,883322,6.512126208687308,False,132.62734167776335,231.61679304371725,False,39.404,0.083,6.274,35.245,16.809,0.076,0.0,0.463,1.644,0.0,0.0,False,Tidak Tertinggal,False,210.189168,27.4395838,3.118583675,3.890707129999999,80.56941695,6.5203333400000005,False,False,3.791040535158938
```
