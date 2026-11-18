# Ringkasan Data Profiling 12 Sumber Data (`SRC-01` s/d `SRC-12`)

*Dihasilkan secara otomatis pada: 2026-11-15 16:48:09*

## SRC-01

### Berkas: `BMKG_Earthquake_Catalog.csv`
- **Format**: CSV
- **Ukuran**: 18.1 MB
- **Total Baris**: 217,807
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 12
- **Daftar Kolom**: `No, Event ID, , Date, Time (UTC), Latitude, Longitude, Magnitude, Mag Type, Depth (km), Source, Source Event ID`

**Contoh Data (Baris 1)**:
```json
{
  "No": "1",
  "Event ID": "BMKG-19980109094543-001",
  "": "",
  "Date": "09-Jan-1998",
  "Time (UTC)": "09:45:43",
  "Latitude": "-5.39",
  "Longitude": "126.17",
  "Magnitude": "4.1",
  "Mag Type": "-",
  "Depth (km)": "390",
  "Source": "RC_09",
  "Source Event ID": "-"
}
```

---

## SRC-02

### Berkas: `data_bencana.xlsx`
- **Format**: Excel XLSX
- **Ukuran**: 1.58 MB
- **Total Baris**: 28,773
- **Jumlah Kolom**: 12
- **Daftar Kolom**: `city_id, date, disaster_type, city, province, cause, death, missing_person, injured_person, damaged_house, flooded_house, damaged_facility`

**Contoh Data (Baris 1)**:
```json
{
  "city_id": "5310.0",
  "date": "43101.0",
  "disaster_type": "BANJIR",
  "city": "MANGGARAI",
  "province": "NUSA TENGGARA TIMUR",
  "cause": "Tidak diketahui",
  "death": "0.0",
  "missing_person": "0.0",
  "injured_person": "0.0",
  "damaged_house": "1.0",
  "flooded_house": "0.0",
  "damaged_facility": "0.0"
}
```

---

## SRC-03

### Berkas: `climate_data.csv`
- **Format**: CSV
- **Ukuran**: 34.18 MB
- **Total Baris**: 589,265
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 12
- **Daftar Kolom**: `date, Tn, Tx, Tavg, RH_avg, RR, ss, ff_x, ddd_x, ff_avg, ddd_car, station_id`

**Contoh Data (Baris 1)**:
```json
{
  "date": "01-01-2010",
  "Tn": "21.4",
  "Tx": "30.2",
  "Tavg": "27.1",
  "RH_avg": "82.0",
  "RR": "9.0",
  "ss": "0.5",
  "ff_x": "7.0",
  "ddd_x": "90.0",
  "ff_avg": "5.0",
  "ddd_car": "E ",
  "station_id": "96001"
}
```

---

### Berkas: `province_detail.csv`
- **Format**: CSV
- **Ukuran**: 0.0 MB
- **Total Baris**: 34
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 2
- **Daftar Kolom**: `province_id, province_name`

**Contoh Data (Baris 1)**:
```json
{
  "province_id": "1",
  "province_name": "Nanggroe Aceh Darussalam"
}
```

---

### Berkas: `station_detail.csv`
- **Format**: CSV
- **Ukuran**: 0.01 MB
- **Total Baris**: 192
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 7
- **Daftar Kolom**: `station_id, station_name, region_name, latitude, longitude, region_id, province_id`

**Contoh Data (Baris 1)**:
```json
{
  "station_id": "96001",
  "station_name": "Stasiun Meteorologi Maimun Saleh",
  "region_name": "Kota Sabang",
  "latitude": "5.87655",
  "longitude": "95.33785",
  "region_id": "20",
  "province_id": "1"
}
```

---

## SRC-04

### Berkas: `data_dictionary.csv`
- **Format**: CSV
- **Ukuran**: 0.01 MB
- **Total Baris**: 45
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 4
- **Daftar Kolom**: `column_name, type_unit, group, description`

**Contoh Data (Baris 1)**:
```json
{
  "column_name": "bps_kabkota_code",
  "type_unit": "integer",
  "group": "identifier",
  "description": "Official BPS kode wilayah for the regency, resolved through the boundary-to-BPS crosswalk."
}
```

---

### Berkas: `master_features_v4.csv`
- **Format**: CSV
- **Ukuran**: 0.21 MB
- **Total Baris**: 514
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 45
- **Daftar Kolom**: `bps_kabkota_code, kabkota_name, prov_name, shapeName, crosswalk_match_type, crosswalk_match_score, ipm_2023, ipm_2024, ppm_2023, ppm_2024, population_2023, population_2024, ntl_radiance_mean, ntl_no_data, elevation_mean_m, elevation_std_m, elevation_no_data, pct_tree_cover, pct_shrubland, pct_grassland, pct_cropland, pct_built_up, pct_bare_sparse_veg, pct_snow_ice, pct_water, pct_wetland, pct_mangroves, pct_moss_lichen, landcover_no_data, tertinggal_status, is_tertinggal, allsky_sfc_sw_dwn_mean, t2m_mean, ws10m_mean, ws50m_mean, rh2m_mean, prectotcorr_mean, solar_zonal_fallback, weather_zonal_fallback, wind_speed_100m_mean_ms, wind_no_data, road_length_km, road_density_km_per_km2, dist_to_primary_trunk_km, centroid_type`

**Contoh Data (Baris 1)**:
```json
{
  "bps_kabkota_code": "1107",
  "kabkota_name": "Aceh Barat",
  "prov_name": "Aceh",
  "shapeName": "Aceh Barat",
  "crosswalk_match_type": "exact",
  "crosswalk_match_score": "1.0",
  "ipm_2023": "72.88",
  "ipm_2024": "73.69",
  "ppm_2023": "17.86",
  "ppm_2024": "17.6",
  "population_2023": "204768",
  "population_2024": "206822",
  "ntl_radiance_mean": "0.4590617028527347",
  "ntl_no_data": "False",
  "elevation_mean_m": "271.17127320672233",
  "elevation_std_m": "352.2239422754575",
  "elevation_no_data": "False",
  "pct_tree_cover": "92.143",
  "pct_shrubland": "0.163",
  "pct_grassland": "3.709",
  "pct_cropland": "2.05",
  "pct_built_up": "0.468",
  "pct_bare_sparse_veg": "0.354",
  "pct_snow_ice": "0.0",
  "pct_water": "0.975",
  "pct_wetland": "0.139",
  "pct_mangroves": "0.0",
  "pct_moss_lichen": "0.0",
  "landcover_no_data": "False",
  "tertinggal_status": "Tidak Tertinggal",
  "is_tertinggal": "False",
  "allsky_sfc_sw_dwn_mean": "205.694922",
  "t2m_mean": "25.2980834",
  "ws10m_mean": "1.8616251625",
  "ws50m_mean": "2.569582585",
  "rh2m_mean": "85.18883149999999",
  "prectotcorr_mean": "8.283499905",
  "solar_zonal_fallback": "False",
  "weather_zonal_fallback": "False",
  "wind_speed_100m_mean_ms": "2.099640879274229",
  "wind_no_data": "False",
  "road_length_km": "1992.6254142232588",
  "road_density_km_per_km2": "0.7046399365282746",
  "dist_to_primary_trunk_km": "1.3768692390967618",
  "centroid_type": "geometric"
}
```

---

## SRC-05

### Berkas: `Cell Towers in Indonesia 510.csv`
- **Format**: CSV
- **Ukuran**: 4.95 MB
- **Total Baris**: 66,059
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 14
- **Daftar Kolom**: `radio, mcc, net, area, cell, unit, lon, lat, range, samples, changeable, created, updated, averageSignal`

**Contoh Data (Baris 1)**:
```json
{
  "radio": "LTE",
  "mcc": "510",
  "net": "11",
  "area": "41004",
  "cell": "104990981",
  "unit": "0",
  "lon": "106.8322",
  "lat": "-6.1869",
  "range": "7988",
  "samples": "50",
  "changeable": "1",
  "created": "1446551984",
  "updated": "1747378621",
  "averageSignal": "0"
}
```

---

## SRC-06

### Berkas: `ookla_fixed_2024q4_indonesia.csv`
- **Format**: CSV
- **Ukuran**: 66.8 MB
- **Total Baris**: 229,305
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 16
- **Daftar Kolom**: `quadkey, tile, tile_x, tile_y, avg_d_kbps, avg_u_kbps, avg_lat_ms, avg_lat_down_ms, avg_lat_up_ms, tests, devices, quarter, type, year, lon, lat`

**Contoh Data (Baris 1)**:
```json
{
  "quadkey": "1322203332110310",
  "tile": "POLYGON((95.218505859375 5.94389957942559, 95.2239990234375 5.94389957942559, 95.2239990234375 5.938435920783, 95.218505859375 5.938435920783, 95.218505859375 5.94389957942559))",
  "tile_x": "95.22130000000001",
  "tile_y": "5.9412",
  "avg_d_kbps": "18472",
  "avg_u_kbps": "7791",
  "avg_lat_ms": "68",
  "avg_lat_down_ms": "180",
  "avg_lat_up_ms": "732",
  "tests": "1",
  "devices": "1",
  "quarter": "4",
  "type": "fixed",
  "year": "2024",
  "lon": "95.218505859375",
  "lat": "5.94389957942559"
}
```

---

## SRC-07

### Berkas: `global_power_plant_database.csv`
- **Format**: CSV
- **Ukuran**: 11.42 MB
- **Total Baris**: 34,936
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 36
- **Daftar Kolom**: `country, country_long, name, gppd_idnr, capacity_mw, latitude, longitude, primary_fuel, other_fuel1, other_fuel2, other_fuel3, commissioning_year, owner, source, url, geolocation_source, wepp_id, year_of_capacity_data, generation_gwh_2013, generation_gwh_2014, generation_gwh_2015, generation_gwh_2016, generation_gwh_2017, generation_gwh_2018, generation_gwh_2019, generation_data_source, estimated_generation_gwh_2013, estimated_generation_gwh_2014, estimated_generation_gwh_2015, estimated_generation_gwh_2016, estimated_generation_gwh_2017, estimated_generation_note_2013, estimated_generation_note_2014, estimated_generation_note_2015, estimated_generation_note_2016, estimated_generation_note_2017`

**Contoh Data (Baris 1)**:
```json
{
  "country": "AFG",
  "country_long": "Afghanistan",
  "name": "Kajaki Hydroelectric Power Plant Afghanistan",
  "gppd_idnr": "GEODB0040538",
  "capacity_mw": "33.0",
  "latitude": "32.3220",
  "longitude": "65.1190",
  "primary_fuel": "Hydro",
  "other_fuel1": "",
  "other_fuel2": "",
  "other_fuel3": "",
  "commissioning_year": "",
  "owner": "",
  "source": "GEODB",
  "url": "http://globalenergyobservatory.org",
  "geolocation_source": "GEODB",
  "wepp_id": "1009793",
  "year_of_capacity_data": "2017",
  "generation_gwh_2013": "",
  "generation_gwh_2014": "",
  "generation_gwh_2015": "",
  "generation_gwh_2016": "",
  "generation_gwh_2017": "",
  "generation_gwh_2018": "",
  "generation_gwh_2019": "",
  "generation_data_source": "",
  "estimated_generation_gwh_2013": "123.77",
  "estimated_generation_gwh_2014": "162.90",
  "estimated_generation_gwh_2015": "97.39",
  "estimated_generation_gwh_2016": "137.76",
  "estimated_generation_gwh_2017": "119.50",
  "estimated_generation_note_2013": "HYDRO-V1",
  "estimated_generation_note_2014": "HYDRO-V1",
  "estimated_generation_note_2015": "HYDRO-V1",
  "estimated_generation_note_2016": "HYDRO-V1",
  "estimated_generation_note_2017": "HYDRO-V1"
}
```

---

### Berkas: `globalpowerplantdatabasev130.zip`
- **Format**: ZIP Archive
- **Ukuran**: 3.99 MB
---

## SRC-08

### Berkas: `Gardu Induk dan Elektrik.csv`
- **Format**: CSV
- **Ukuran**: 0.68 MB
- **Total Baris**: 2,821
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 75
- **Daftar Kolom**: `﻿id, @id, M:hazard_prone, access:roof, addr:city, addr:country, addr:full, addr:housenumber, addr:postcode, addr:street, addr:subdistrict, alt_name, amenity, backup_generator, barrier, building, building:condition, building:levels, building:material, building:roof, building:structure, building:use, building:walls, cables, capacity, check_date, description, design, designation, fixme, frequency, gas_insulated, generator:source, height, landuse, layer, leisure, location, man_made, name, name:en, name:id, name:ms, not:operator:wikidata, note, office, official_name, opening_date, opening_hours, operator, operator:short, operator:wikidata, operator:wikipedia, phone, power, power_supply, public_service_provider:type_idn, rating, ref, roof:levels, roof:material, roof:orientation, roof:shape, shelter_type, short_name, source, start_date, substation, type, utility, voltage, @geometry, longitude, latitude, geometry_wkt`

**Contoh Data (Baris 1)**:
```json
{
  "﻿id": "relation/8162884",
  "@id": "relation/8162884",
  "M:hazard_prone": "",
  "access:roof": "",
  "addr:city": "",
  "addr:country": "",
  "addr:full": "",
  "addr:housenumber": "",
  "addr:postcode": "",
  "addr:street": "",
  "addr:subdistrict": "",
  "alt_name": "",
  "amenity": "",
  "backup_generator": "",
  "barrier": "",
  "building": "yes",
  "building:condition": "",
  "building:levels": "1",
  "building:material": "",
  "building:roof": "",
  "building:structure": "",
  "building:use": "",
  "building:walls": "",
  "cables": "",
  "capacity": "",
  "check_date": "",
  "description": "",
  "design": "",
  "designation": "",
  "fixme": "",
  "frequency": "",
  "gas_insulated": "",
  "generator:source": "",
  "height": "4",
  "landuse": "",
  "layer": "",
  "leisure": "",
  "location": "",
  "man_made": "",
  "name": "",
  "name:en": "",
  "name:id": "",
  "name:ms": "",
  "not:operator:wikidata": "",
  "note": "",
  "office": "",
  "official_name": "",
  "opening_date": "",
  "opening_hours": "",
  "operator": "Perusahaan Listrik Negara",
  "operator:short": "PLN",
  "operator:wikidata": "Q4201636",
  "operator:wikipedia": "",
  "phone": "",
  "power": "substation",
  "power_supply": "",
  "public_service_provider:type_idn": "",
  "rating": "",
  "ref": "",
  "roof:levels": "",
  "roof:material": "",
  "roof:orientation": "",
  "roof:shape": "",
  "shelter_type": "",
  "short_name": "",
  "source": "",
  "start_date": "",
  "substation": "",
  "type": "multipolygon",
  "utility": "",
  "voltage": "",
  "@geometry": "center",
  "longitude": "108.9800899",
  "latitude": "0.9116867",
  "geometry_wkt": "POINT (108.98009 0.911687)"
}
```

---

### Berkas: `export.geojson`
- **Format**: GeoJSON
- **Ukuran**: 1.54 MB
- **Tipe Geometri**: Unknown
- **Contoh Kolom Properti**: `note`

---

## SRC-09

### Berkas: `sebaran-point-of-presence-pop-layanan-jasa-internet-service-provider-isp_2026-11-13.csv`
- **Format**: CSV
- **Ukuran**: 0.0 MB
- **Total Baris**: 34
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 4
- **Daftar Kolom**: `﻿Provinsi, Sebaran PoP ISP, Tahun, Source`

**Contoh Data (Baris 1)**:
```json
{
  "﻿Provinsi": "Aceh",
  "Sebaran PoP ISP": "45",
  "Tahun": "2024",
  "Source": "https://datahub.komdigi.go.id"
}
```

---

## SRC-10

### Berkas: `Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2021.csv`
- **Format**: CSV
- **Ukuran**: 0.0 MB
- **Total Baris**: 42
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 7
- **Daftar Kolom**: `﻿38 Provinsi, , , , , , `

**Contoh Data (Baris 1)**:
```json
{
  "﻿38 Provinsi": "",
  "": ""
}
```

---

### Berkas: `Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2022.csv`
- **Format**: CSV
- **Ukuran**: 0.0 MB
- **Total Baris**: 42
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 7
- **Daftar Kolom**: `﻿38 Provinsi, , , , , , `

**Contoh Data (Baris 1)**:
```json
{
  "﻿38 Provinsi": "",
  "": ""
}
```

---

### Berkas: `Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2023.csv`
- **Format**: CSV
- **Ukuran**: 0.0 MB
- **Total Baris**: 42
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 7
- **Daftar Kolom**: `﻿38 Provinsi, , , , , , `

**Contoh Data (Baris 1)**:
```json
{
  "﻿38 Provinsi": "",
  "": ""
}
```

---

### Berkas: `Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2024.csv`
- **Format**: CSV
- **Ukuran**: 0.0 MB
- **Total Baris**: 42
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 7
- **Daftar Kolom**: `﻿38 Provinsi, , , , , , `

**Contoh Data (Baris 1)**:
```json
{
  "﻿38 Provinsi": "",
  "": ""
}
```

---

## SRC-11

### Berkas: `idn_admin0.geojson`
- **Format**: GeoJSON
- **Ukuran**: 91.96 MB
- **Tipe Geometri**: Unknown
- **Contoh Kolom Properti**: `note`

---

### Berkas: `idn_admin1.geojson`
- **Format**: GeoJSON
- **Ukuran**: 99.09 MB
- **Tipe Geometri**: Unknown
- **Contoh Kolom Properti**: `note`

---

### Berkas: `idn_admin2.geojson`
- **Format**: GeoJSON
- **Ukuran**: 142.77 MB
- **Tipe Geometri**: Unknown
- **Contoh Kolom Properti**: `note`

---

### Berkas: `idn_admin3.geojson`
- **Format**: GeoJSON
- **Ukuran**: 273.19 MB
- **Tipe Geometri**: Unknown
- **Contoh Kolom Properti**: `note`

---

### Berkas: `idn_admin4.geojson`
- **Format**: GeoJSON
- **Ukuran**: 621.74 MB
- **Tipe Geometri**: Unknown
- **Contoh Kolom Properti**: `note`

---

### Berkas: `idn_adminlines.geojson`
- **Format**: GeoJSON
- **Ukuran**: 381.37 MB
- **Tipe Geometri**: Unknown
- **Contoh Kolom Properti**: `note`

---

### Berkas: `idn_adminpoints.geojson`
- **Format**: GeoJSON
- **Ukuran**: 23.79 MB
- **Tipe Geometri**: Unknown
- **Contoh Kolom Properti**: `note`

---

## SRC-12

### Berkas: `Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2022.csv`
- **Format**: CSV
- **Ukuran**: 0.0 MB
- **Total Baris**: 42
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 6
- **Daftar Kolom**: `﻿Provinsi, Jumlah Penduduk (Ribu), Laju Pertumbuhan Penduduk per Tahun, Persentase Penduduk, Kepadatan Penduduk per km persegi (Km2), Rasio Jenis Kelamin Penduduk`

**Contoh Data (Baris 1)**:
```json
{
  "﻿Provinsi": "Aceh",
  "Jumlah Penduduk (Ribu)": "5407.9",
  "Laju Pertumbuhan Penduduk per Tahun": "1.43",
  "Persentase Penduduk": "1.96",
  "Kepadatan Penduduk per km persegi (Km2)": "95",
  "Rasio Jenis Kelamin Penduduk": "100.9"
}
```

---

### Berkas: `Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2023.csv`
- **Format**: CSV
- **Ukuran**: 0.0 MB
- **Total Baris**: 42
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 6
- **Daftar Kolom**: `﻿Provinsi, Jumlah Penduduk (Ribu), Laju Pertumbuhan Penduduk per Tahun, Persentase Penduduk, Kepadatan Penduduk per km persegi (Km2), Rasio Jenis Kelamin Penduduk`

**Contoh Data (Baris 1)**:
```json
{
  "﻿Provinsi": "Aceh",
  "Jumlah Penduduk (Ribu)": "5482.5",
  "Laju Pertumbuhan Penduduk per Tahun": "1.41",
  "Persentase Penduduk": "1.97",
  "Kepadatan Penduduk per km persegi (Km2)": "96",
  "Rasio Jenis Kelamin Penduduk": "100.9"
}
```

---

### Berkas: `Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2024.csv`
- **Format**: CSV
- **Ukuran**: 0.0 MB
- **Total Baris**: 43
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 6
- **Daftar Kolom**: `﻿Provinsi, Jumlah Penduduk (Ribu), Laju Pertumbuhan Penduduk per Tahun, Persentase Penduduk, Kepadatan Penduduk per km persegi (Km2), Rasio Jenis Kelamin Penduduk`

**Contoh Data (Baris 1)**:
```json
{
  "﻿Provinsi": "Aceh",
  "Jumlah Penduduk (Ribu)": "5554.8",
  "Laju Pertumbuhan Penduduk per Tahun": "1.39",
  "Persentase Penduduk": "1.97",
  "Kepadatan Penduduk per km persegi (Km2)": "98",
  "Rasio Jenis Kelamin Penduduk": "100.9"
}
```

---

### Berkas: `Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2025.csv`
- **Format**: CSV
- **Ukuran**: 0.0 MB
- **Total Baris**: 45
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 6
- **Daftar Kolom**: `﻿Provinsi, Jumlah Penduduk (Ribu), Laju Pertumbuhan Penduduk per Tahun, Persentase Penduduk, Kepadatan Penduduk per km persegi (Km2), Rasio Jenis Kelamin Penduduk`

**Contoh Data (Baris 1)**:
```json
{
  "﻿Provinsi": "Aceh",
  "Jumlah Penduduk (Ribu)": "5626",
  "Laju Pertumbuhan Penduduk per Tahun": "1.37",
  "Persentase Penduduk": "1.98",
  "Kepadatan Penduduk per km persegi (Km2)": "99",
  "Rasio Jenis Kelamin Penduduk": "100.9"
}
```

---

### Berkas: `Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2026.csv`
- **Format**: CSV
- **Ukuran**: 0.0 MB
- **Total Baris**: 42
- **Delimiter**: `','`
- **Encoding**: utf-8
- **Jumlah Kolom**: 6
- **Daftar Kolom**: `﻿Provinsi, Jumlah Penduduk (Ribu), Laju Pertumbuhan Penduduk per Tahun, Persentase Penduduk, Kepadatan Penduduk per km persegi (Km2), Rasio Jenis Kelamin Penduduk`

**Contoh Data (Baris 1)**:
```json
{
  "﻿Provinsi": "Aceh",
  "Jumlah Penduduk (Ribu)": "5695.9",
  "Laju Pertumbuhan Penduduk per Tahun": "1.34",
  "Persentase Penduduk": "1.98",
  "Kepadatan Penduduk per km persegi (Km2)": "100",
  "Rasio Jenis Kelamin Penduduk": "100.9"
}
```

---

