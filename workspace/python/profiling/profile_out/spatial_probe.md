# Uji penugasan titik ke poligon ADM2 (SRC-11)

Poligon ADM2: 522. Poligon tidak valid menurut shapely (3): ID3305 (Kebumen), ID1708 (Kepahiang), ID1407 (Rokan Hulu) (gunakan ST_MakeValid di PostGIS).

| Sumber | File | Himpunan | Titik | Di dalam poligon | % | Di luar |
|---|---|---|---|---|---|---|
| SRC-01 | BMKG_Earthquake_Catalog.csv | semua titik | 217,807 | 70,935 | 32.6% | 146,872 |
| SRC-01 | BMKG_Earthquake_Catalog.csv | magnitudo >= 5.0 | 4,777 | 864 | 18.1% | 3,913 |
| SRC-03 | station_detail.csv | semua titik | 192 | 189 | 98.4% | 3 |
| SRC-05 | Cell Towers in Indonesia 510.csv | semua titik | 66,059 | 65,296 | 98.8% | 763 |
| SRC-06 | ookla_fixed_2024q4_indonesia.csv | semua titik | 229,305 | 189,907 | 82.8% | 39,398 |
| SRC-07 | global_power_plant_database.csv | semua titik | 178 | 173 | 97.2% | 5 |
| SRC-08 | Gardu Induk dan Elektrik.csv | semua titik | 2,821 | 2,816 | 99.8% | 5 |

Titik di luar poligon bisa berada di laut (gempa), di wilayah tetangga, atau di tepi pantai yang tidak tertutup batas yang disederhanakan.
