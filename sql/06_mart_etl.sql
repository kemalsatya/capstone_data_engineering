-- =============================================================================
-- ETL MART: Populasi Data dari Staging ke Mart
-- Urutan Eksekusi:
--   1. mart.dim_wilayah
--   2. mart.dim_utilitas_energi
--   3. mart.dim_konektivitas_jaringan
--   4. mart.dim_risiko_bencana
--   5. mart.dim_lingkungan_air
--   6. mart.fact_site_suitability (scoring + tiering)
-- =============================================================================

-- ============================================================
-- STEP 1: Populasi mart.dim_wilayah
-- Sumber: stg.regional_features (BPS 514 Kab/Kota)
--         + stg.admin_boundaries (sentroid & poligon GeoJSON)
-- ============================================================
TRUNCATE mart.dim_wilayah CASCADE;

INSERT INTO mart.dim_wilayah (
    bps_code,
    pcode,
    kabkota_name,
    province_name,
    center_lat,
    center_lon,
    area_sqkm,
    geom_geojson,
    population_2024,
    elevation_mean_m
)
SELECT
    r.bps_kabkota_code                    AS bps_code,
    -- Cocokkan pcode dari admin_boundaries (admin_level=2)
    -- Format pcode  = 'ID' + bps_code, misal bps_code=1107 -> pcode='ID1107'
    ab.pcode,
    r.kabkota_name,
    r.province_name,
    COALESCE(ab.center_lat, NULL)         AS center_lat,
    COALESCE(ab.center_lon, NULL)         AS center_lon,
    ab.area_sqkm,
    ab.geom_geojson,
    r.population_2024,
    r.elevation_mean_m
FROM stg.regional_features r
LEFT JOIN stg.admin_boundaries ab
    ON ab.admin_level = 2
    AND ab.pcode = 'ID' || r.bps_kabkota_code
ORDER BY r.bps_kabkota_code;

-- ============================================================
-- STEP 2: Populasi mart.dim_utilitas_energi
-- Sumber: stg.substations, stg.power_plants
-- Jarak dihitung dengan Haversine approximation via PostgreSQL
-- (menggunakan earth_distance / point operator sederhana via derajat ke km)
-- ============================================================
TRUNCATE mart.dim_utilitas_energi CASCADE;

INSERT INTO mart.dim_utilitas_energi (
    bps_code,
    nearest_substation_km,
    substation_count_50km,
    max_voltage_kv,
    total_capacity_mw,
    renewable_capacity_mw,
    renewable_ratio_pct,
    plant_count_100km
)
WITH
-- Hitung jarak (km) antara centroid wilayah dan setiap gardu induk
-- Rumus Haversine dipermudah: 1 derajat lat ≈ 111 km; 1 derajat lon ≈ 111*cos(lat) km
substation_distances AS (
    SELECT
        w.bps_code,
        s.substation_id,
        s.voltage_kv,
        -- Jarak Euclidean dalam km (cukup akurat untuk jarak < 500km di khatulistiwa)
        SQRT(
            POWER((w.center_lat - s.latitude) * 111.0, 2) +
            POWER((w.center_lon - s.longitude) * 111.0 * COS(RADIANS(w.center_lat)), 2)
        ) AS dist_km
    FROM mart.dim_wilayah w
    JOIN stg.substations s ON TRUE
    WHERE w.center_lat IS NOT NULL AND w.center_lon IS NOT NULL
),
-- Statistik gardu per wilayah
sub_stats AS (
    SELECT
        bps_code,
        MIN(dist_km)                          AS nearest_substation_km,
        COUNT(*) FILTER (WHERE dist_km <= 50) AS substation_count_50km,
        MAX(voltage_kv) FILTER (WHERE dist_km = (SELECT MIN(d2.dist_km) FROM substation_distances d2 WHERE d2.bps_code = substation_distances.bps_code)) AS max_voltage_kv
    FROM substation_distances
    GROUP BY bps_code
),
-- Hitung jarak pembangkit ke wilayah
plant_distances AS (
    SELECT
        w.bps_code,
        p.plant_id,
        p.capacity_mw,
        p.is_renewable,
        SQRT(
            POWER((w.center_lat - p.latitude) * 111.0, 2) +
            POWER((w.center_lon - p.longitude) * 111.0 * COS(RADIANS(w.center_lat)), 2)
        ) AS dist_km
    FROM mart.dim_wilayah w
    JOIN stg.power_plants p ON TRUE
    WHERE w.center_lat IS NOT NULL AND w.center_lon IS NOT NULL
),
-- Statistik pembangkit per wilayah (radius 100 km)
plant_stats AS (
    SELECT
        bps_code,
        COALESCE(SUM(capacity_mw) FILTER (WHERE dist_km <= 100), 0)                AS total_capacity_mw,
        COALESCE(SUM(capacity_mw) FILTER (WHERE dist_km <= 100 AND is_renewable), 0) AS renewable_capacity_mw,
        COUNT(*) FILTER (WHERE dist_km <= 100)                                      AS plant_count_100km
    FROM plant_distances
    GROUP BY bps_code
)
SELECT
    w.bps_code,
    ss.nearest_substation_km,
    ss.substation_count_50km,
    ss.max_voltage_kv,
    ps.total_capacity_mw,
    ps.renewable_capacity_mw,
    CASE
        WHEN ps.total_capacity_mw > 0
        THEN ROUND((ps.renewable_capacity_mw / ps.total_capacity_mw * 100.0), 2)
        ELSE 0
    END                                       AS renewable_ratio_pct,
    ps.plant_count_100km
FROM mart.dim_wilayah w
LEFT JOIN sub_stats ss USING (bps_code)
LEFT JOIN plant_stats ps USING (bps_code);

-- ============================================================
-- STEP 3: Populasi mart.dim_konektivitas_jaringan
-- Sumber: stg.ookla_broadband (2024 Q4), stg.cell_towers, stg.isp_points_of_presence
-- ============================================================
TRUNCATE mart.dim_konektivitas_jaringan CASCADE;

INSERT INTO mart.dim_konektivitas_jaringan (
    bps_code,
    avg_download_mbps,
    avg_upload_mbps,
    avg_latency_ms,
    broadband_tile_count,
    bts_count_30km,
    isp_pop_count
)
WITH
-- Rata-rata Ookla per wilayah (tile yang masuk dalam bounding box wilayah via admin_boundaries)
-- Fallback: tile yang centroidnya dalam radius 30km dari centroid wilayah
ookla_stats AS (
    SELECT
        w.bps_code,
        ROUND(AVG(o.avg_download_mbps)::numeric, 2) AS avg_download_mbps,
        ROUND(AVG(o.avg_upload_mbps)::numeric, 2)   AS avg_upload_mbps,
        ROUND(AVG(o.avg_latency_ms)::numeric, 2)    AS avg_latency_ms,
        COUNT(*)                                     AS broadband_tile_count
    FROM mart.dim_wilayah w
    JOIN stg.ookla_broadband o ON
        -- Filter data 2024 Q4 (terbaru), fallback ke seluruh 2024 jika Q4 kosong
        o.year_val = 2024
        -- Tile dalam radius 30km dari centroid wilayah (approximation)
        AND SQRT(
            POWER((w.center_lat - o.tile_center_lat) * 111.0, 2) +
            POWER((w.center_lon - o.tile_center_lon) * 111.0 * COS(RADIANS(w.center_lat)), 2)
        ) <= 30
    WHERE w.center_lat IS NOT NULL
    GROUP BY w.bps_code
),
-- Jumlah BTS dalam radius 30km dari centroid wilayah
bts_stats AS (
    SELECT
        w.bps_code,
        COUNT(t.tower_id) AS bts_count_30km
    FROM mart.dim_wilayah w
    JOIN stg.cell_towers t ON
        SQRT(
            POWER((w.center_lat - t.latitude) * 111.0, 2) +
            POWER((w.center_lon - t.longitude) * 111.0 * COS(RADIANS(w.center_lat)), 2)
        ) <= 30
    WHERE w.center_lat IS NOT NULL
    GROUP BY w.bps_code
),
-- PoP ISP per provinsi (level provinsi, bukan kabupaten)
isp_stats AS (
    SELECT
        w.bps_code,
        COALESCE(SUM(i.pop_count), 0) AS isp_pop_count
    FROM mart.dim_wilayah w
    LEFT JOIN stg.isp_points_of_presence i
        ON TRIM(LOWER(w.province_name)) = TRIM(LOWER(i.province_name))
        AND i.year_val = (SELECT MAX(year_val) FROM stg.isp_points_of_presence)
    GROUP BY w.bps_code
)
SELECT
    w.bps_code,
    os.avg_download_mbps,
    os.avg_upload_mbps,
    os.avg_latency_ms,
    COALESCE(os.broadband_tile_count, 0) AS broadband_tile_count,
    COALESCE(bs.bts_count_30km, 0)       AS bts_count_30km,
    COALESCE(is2.isp_pop_count, 0)       AS isp_pop_count
FROM mart.dim_wilayah w
LEFT JOIN ookla_stats os USING (bps_code)
LEFT JOIN bts_stats   bs USING (bps_code)
LEFT JOIN isp_stats   is2 USING (bps_code);

-- ============================================================
-- STEP 4: Populasi mart.dim_risiko_bencana
-- Sumber: stg.earthquakes, stg.disasters
-- + Knock-out criteria (Opsi A):
--   KO-1: Ada gempa M >= 6.5 & depth <= 30km dalam radius 25km, 10 tahun terakhir
--   KO-2: Banjir berulang > 50 kali dalam 5 tahun terakhir (2019-2024)
-- ============================================================
TRUNCATE mart.dim_risiko_bencana CASCADE;

INSERT INTO mart.dim_risiko_bencana (
    bps_code,
    eq_count_26yr,
    eq_significant_26yr,
    eq_max_magnitude_26yr,
    eq_shallow_severe_26yr,
    eq_count_10yr,
    eq_significant_10yr,
    eq_max_magnitude_10yr,
    eq_shallow_severe_10yr,
    flood_count_5yr,
    landslide_count_5yr,
    extreme_weather_count_5yr,
    total_disaster_count,
    is_knocked_out,
    knockout_reason
)
WITH
-- Statistik gempa per wilayah (window 26 tahun)
eq_26yr AS (
    SELECT
        w.bps_code,
        COUNT(e.earthquake_id)                                      AS eq_count_26yr,
        COUNT(e.earthquake_id) FILTER (WHERE e.is_significant)      AS eq_significant_26yr,
        MAX(e.magnitude)                                            AS eq_max_magnitude_26yr,
        COUNT(e.earthquake_id) FILTER (
            WHERE e.magnitude >= 6.5 AND e.depth_km <= 30
            AND SQRT(
                POWER((w.center_lat - e.latitude) * 111.0, 2) +
                POWER((w.center_lon - e.longitude) * 111.0 * COS(RADIANS(w.center_lat)), 2)
            ) <= 25
        )                                                           AS eq_shallow_severe_26yr
    FROM mart.dim_wilayah w
    JOIN stg.earthquakes e ON
        e.event_timestamp >= '1998-01-01'
        AND SQRT(
            POWER((w.center_lat - e.latitude) * 111.0, 2) +
            POWER((w.center_lon - e.longitude) * 111.0 * COS(RADIANS(w.center_lat)), 2)
        ) <= 200  -- radius 200km untuk konteks regional
    WHERE w.center_lat IS NOT NULL
    GROUP BY w.bps_code
),
-- Statistik gempa (window 10 tahun)
eq_10yr AS (
    SELECT
        w.bps_code,
        COUNT(e.earthquake_id)                                      AS eq_count_10yr,
        COUNT(e.earthquake_id) FILTER (WHERE e.is_significant)      AS eq_significant_10yr,
        MAX(e.magnitude)                                            AS eq_max_magnitude_10yr,
        COUNT(e.earthquake_id) FILTER (
            WHERE e.magnitude >= 6.5 AND e.depth_km <= 30
            AND SQRT(
                POWER((w.center_lat - e.latitude) * 111.0, 2) +
                POWER((w.center_lon - e.longitude) * 111.0 * COS(RADIANS(w.center_lat)), 2)
            ) <= 25
        )                                                           AS eq_shallow_severe_10yr
    FROM mart.dim_wilayah w
    JOIN stg.earthquakes e ON
        e.event_timestamp >= '2014-01-01'
        AND SQRT(
            POWER((w.center_lat - e.latitude) * 111.0, 2) +
            POWER((w.center_lon - e.longitude) * 111.0 * COS(RADIANS(w.center_lat)), 2)
        ) <= 200
    WHERE w.center_lat IS NOT NULL
    GROUP BY w.bps_code
),
-- Statistik bencana hidrometeorologi per wilayah (cocokkan via city_name)
disaster_stats AS (
    SELECT
        w.bps_code,
        COUNT(*) FILTER (
            WHERE d.disaster_type = 'BANJIR'
            AND d.event_date >= CURRENT_DATE - INTERVAL '5 years'
        )                                                           AS flood_count_5yr,
        COUNT(*) FILTER (
            WHERE d.disaster_type = 'TANAH LONGSOR'
            AND d.event_date >= CURRENT_DATE - INTERVAL '5 years'
        )                                                           AS landslide_count_5yr,
        COUNT(*) FILTER (
            WHERE d.disaster_type = 'CUACA EKSTREM'
            AND d.event_date >= CURRENT_DATE - INTERVAL '5 years'
        )                                                           AS extreme_weather_count_5yr,
        COUNT(*)                                                    AS total_disaster_count
    FROM mart.dim_wilayah w
    -- Cocokkan nama kabupaten (fuzzy, karena disaster hanya ada city_name & province_name)
    LEFT JOIN stg.disasters d
        ON TRIM(LOWER(w.kabkota_name)) = TRIM(LOWER(d.city_name))
        OR (
            -- Fallback: jika nama tidak cocok persis, gunakan provinsi saja untuk bencana
            TRIM(LOWER(w.province_name)) = TRIM(LOWER(d.province_name))
            AND d.city_name IS NULL
        )
    GROUP BY w.bps_code
)
SELECT
    w.bps_code,
    COALESCE(e26.eq_count_26yr, 0)                   AS eq_count_26yr,
    COALESCE(e26.eq_significant_26yr, 0)             AS eq_significant_26yr,
    e26.eq_max_magnitude_26yr,
    COALESCE(e26.eq_shallow_severe_26yr, 0)          AS eq_shallow_severe_26yr,
    COALESCE(e10.eq_count_10yr, 0)                   AS eq_count_10yr,
    COALESCE(e10.eq_significant_10yr, 0)             AS eq_significant_10yr,
    e10.eq_max_magnitude_10yr,
    COALESCE(e10.eq_shallow_severe_10yr, 0)          AS eq_shallow_severe_10yr,
    COALESCE(ds.flood_count_5yr, 0)                  AS flood_count_5yr,
    COALESCE(ds.landslide_count_5yr, 0)              AS landslide_count_5yr,
    COALESCE(ds.extreme_weather_count_5yr, 0)        AS extreme_weather_count_5yr,
    COALESCE(ds.total_disaster_count, 0)             AS total_disaster_count,
    -- === KNOCK-OUT FILTER (Opsi A) ===
    CASE
        WHEN COALESCE(e10.eq_shallow_severe_10yr, 0) >= 1 THEN TRUE  -- KO-1: Gempa parah
        WHEN COALESCE(ds.flood_count_5yr, 0) > 50            THEN TRUE  -- KO-2: Banjir berulang
        ELSE FALSE
    END                                               AS is_knocked_out,
    CASE
        WHEN COALESCE(e10.eq_shallow_severe_10yr, 0) >= 1
            THEN 'Riwayat gempa M≥6.5 kedalaman dangkal (≤30km) dalam radius 25km, 10 tahun terakhir'
        WHEN COALESCE(ds.flood_count_5yr, 0) > 50
            THEN 'Riwayat banjir berulang >50 kejadian dalam 5 tahun terakhir'
        ELSE NULL
    END                                               AS knockout_reason
FROM mart.dim_wilayah w
LEFT JOIN eq_26yr e26 USING (bps_code)
LEFT JOIN eq_10yr e10 USING (bps_code)
LEFT JOIN disaster_stats ds USING (bps_code);

-- ============================================================
-- STEP 5: Populasi mart.dim_lingkungan_air
-- Sumber: stg.water_quality_index (provinsi), stg.regional_features
-- ============================================================
TRUNCATE mart.dim_lingkungan_air CASCADE;

INSERT INTO mart.dim_lingkungan_air (
    bps_code,
    water_quality_index,
    water_quality_year,
    water_quality_category,
    temp_ambient_mean_c,
    humidity_ambient_pct,
    rainfall_mean_mm,
    elevation_mean_m,
    pct_built_up,
    tertinggal_status
)
SELECT
    w.bps_code,
    wq.water_quality_index,
    wq.year_val                        AS water_quality_year,
    -- Kategorisasi IKA (standar KLHK: Baik >= 70, Cukup 50-69, Kurang 25-49, Buruk < 25)
    CASE
        WHEN wq.water_quality_index >= 70 THEN 'Baik'
        WHEN wq.water_quality_index >= 50 THEN 'Cukup'
        WHEN wq.water_quality_index >= 25 THEN 'Kurang'
        WHEN wq.water_quality_index IS NOT NULL THEN 'Buruk'
        ELSE NULL
    END                                AS water_quality_category,
    r.temp_ambient_mean_c,
    r.humidity_ambient_mean_pct        AS humidity_ambient_pct,
    r.rainfall_ambient_mean_mm         AS rainfall_mean_mm,
    r.elevation_mean_m,
    r.pct_built_up,
    r.tertinggal_status
FROM mart.dim_wilayah w
-- Cocokkan IKA via nama provinsi (IKA hanya tersedia di level provinsi)
LEFT JOIN LATERAL (
    SELECT water_quality_index, year_val
    FROM stg.water_quality_index
    WHERE TRIM(LOWER(province_name)) = TRIM(LOWER(w.province_name))
    ORDER BY year_val DESC
    LIMIT 1
) wq ON TRUE
-- Ambil data suhu/kelembapan dari regional_features
LEFT JOIN stg.regional_features r ON r.bps_kabkota_code = w.bps_code;

-- ============================================================
-- STEP 6: Hitung Skor & Populasi mart.fact_site_suitability
-- Metode: Min-Max Normalization per kolom metrik -> Skor 0-100
-- Bobot Standar: Power 35%, Safety 25%, Network 25%, Environment 15%
-- ============================================================
TRUNCATE mart.fact_site_suitability CASCADE;

INSERT INTO mart.fact_site_suitability (
    bps_code,
    is_knocked_out,
    knockout_reason,
    score_power,
    score_safety,
    score_network,
    score_environment,
    final_score,
    suitability_tier
)
WITH
-- Rentang min/max untuk normalisasi (hanya dari wilayah yang TIDAK di-knock-out)
-- Ini memastikan wilayah baik mendapat skor relatif antar sesama yang lolos
ranges AS (
    SELECT
        -- Power metrics
        MIN(e.nearest_substation_km)   AS min_sub_km,
        MAX(e.nearest_substation_km)   AS max_sub_km,
        MIN(e.total_capacity_mw)       AS min_cap_mw,
        MAX(e.total_capacity_mw)       AS max_cap_mw,
        MIN(e.substation_count_50km)   AS min_sub_count,
        MAX(e.substation_count_50km)   AS max_sub_count,
        -- Network metrics
        MIN(k.avg_download_mbps)       AS min_dl,
        MAX(k.avg_download_mbps)       AS max_dl,
        MIN(k.avg_latency_ms)          AS min_lat,
        MAX(k.avg_latency_ms)          AS max_lat,
        MIN(k.bts_count_30km)          AS min_bts,
        MAX(k.bts_count_30km)          AS max_bts,
        -- Safety metrics (inverted: lebih sedikit kejadian = lebih aman = skor lebih tinggi)
        MIN(r.eq_significant_10yr)     AS min_eq10,
        MAX(r.eq_significant_10yr)     AS max_eq10,
        MIN(r.flood_count_5yr)         AS min_flood,
        MAX(r.flood_count_5yr)         AS max_flood,
        -- Environment metrics
        MIN(l.water_quality_index)     AS min_wqi,
        MAX(l.water_quality_index)     AS max_wqi,
        MIN(l.temp_ambient_mean_c)     AS min_temp,
        MAX(l.temp_ambient_mean_c)     AS max_temp
    FROM mart.dim_wilayah w
    JOIN mart.dim_utilitas_energi e       USING (bps_code)
    JOIN mart.dim_konektivitas_jaringan k USING (bps_code)
    JOIN mart.dim_risiko_bencana r        USING (bps_code)
    JOIN mart.dim_lingkungan_air l        USING (bps_code)
    WHERE r.is_knocked_out = FALSE   -- hanya wilayah lolos knock-out
),
-- Fungsi helper: normalisasi 0-100 (helper via CASE di SQL)
scored AS (
    SELECT
        w.bps_code,
        r.is_knocked_out,
        r.knockout_reason,
        -- ===== SKOR POWER (35%) =====
        -- Sub-komponen:
        --   a. Jarak ke gardu (makin dekat = makin baik -> INVERTED)   bobot 50%
        --   b. Total kapasitas MW dalam 100km (makin besar = makin baik) bobot 30%
        --   c. Jumlah gardu dalam 50km (makin banyak = makin baik)      bobot 20%
        CASE WHEN r.is_knocked_out THEN NULL ELSE
            ROUND(GREATEST(0, LEAST(100,
                0.50 * (
                    CASE
                        WHEN rng.max_sub_km = rng.min_sub_km THEN 50
                        ELSE (1.0 - (e.nearest_substation_km - rng.min_sub_km) /
                              NULLIF(rng.max_sub_km - rng.min_sub_km, 0)) * 100
                    END
                ) +
                0.30 * (
                    CASE
                        WHEN rng.max_cap_mw = rng.min_cap_mw THEN 50
                        ELSE ((e.total_capacity_mw - rng.min_cap_mw) /
                              NULLIF(rng.max_cap_mw - rng.min_cap_mw, 0)) * 100
                    END
                ) +
                0.20 * (
                    CASE
                        WHEN rng.max_sub_count = rng.min_sub_count THEN 50
                        ELSE ((e.substation_count_50km - rng.min_sub_count) /
                              NULLIF(rng.max_sub_count - rng.min_sub_count, 0)) * 100
                    END
                )
            ))::numeric, 2)
        END AS score_power,

        -- ===== SKOR SAFETY (25%) =====
        -- Sub-komponen (semua inverted: lebih sedikit bencana = skor lebih tinggi):
        --   a. Jumlah gempa signifikan 10 tahun terakhir   bobot 50%
        --   b. Jumlah banjir 5 tahun terakhir             bobot 30%
        --   c. Jumlah tanah longsor 5 tahun terakhir      bobot 20%
        CASE WHEN r.is_knocked_out THEN NULL ELSE
            ROUND(GREATEST(0, LEAST(100,
                0.50 * (
                    CASE
                        WHEN rng.max_eq10 = rng.min_eq10 THEN 100
                        ELSE (1.0 - (r.eq_significant_10yr - rng.min_eq10) /
                              NULLIF(rng.max_eq10 - rng.min_eq10, 0)) * 100
                    END
                ) +
                0.30 * (
                    CASE
                        WHEN rng.max_flood = rng.min_flood THEN 100
                        ELSE (1.0 - (r.flood_count_5yr - rng.min_flood) /
                              NULLIF(rng.max_flood - rng.min_flood, 0)) * 100
                    END
                ) +
                0.20 * 100  -- Placeholder: landslide belum dinormalisasi (semua sama untuk wilayah lolos)
            ))::numeric, 2)
        END AS score_safety,

        -- ===== SKOR NETWORK (25%) =====
        -- Sub-komponen:
        --   a. Download speed rata-rata 2024          bobot 40%
        --   b. Latency rata-rata 2024 (INVERTED)      bobot 35%
        --   c. Jumlah BTS dalam 30km                 bobot 25%
        CASE WHEN r.is_knocked_out THEN NULL ELSE
            ROUND(GREATEST(0, LEAST(100,
                0.40 * (
                    CASE
                        WHEN rng.max_dl = rng.min_dl OR k.avg_download_mbps IS NULL THEN 50
                        ELSE ((k.avg_download_mbps - rng.min_dl) /
                              NULLIF(rng.max_dl - rng.min_dl, 0)) * 100
                    END
                ) +
                0.35 * (
                    CASE
                        WHEN rng.max_lat = rng.min_lat OR k.avg_latency_ms IS NULL THEN 50
                        ELSE (1.0 - (k.avg_latency_ms - rng.min_lat) /
                              NULLIF(rng.max_lat - rng.min_lat, 0)) * 100
                    END
                ) +
                0.25 * (
                    CASE
                        WHEN rng.max_bts = rng.min_bts THEN 50
                        ELSE ((k.bts_count_30km - rng.min_bts) /
                              NULLIF(rng.max_bts - rng.min_bts, 0)) * 100
                    END
                )
            ))::numeric, 2)
        END AS score_network,

        -- ===== SKOR ENVIRONMENT (15%) =====
        -- Sub-komponen:
        --   a. Indeks Kualitas Air (IKA KLHK)         bobot 50%
        --   b. Suhu ambien (INVERTED: makin sejuk = lebih baik untuk PUE) bobot 30%
        --   c. Elevasi (lebih tinggi = lebih aman banjir)  bobot 20%
        CASE WHEN r.is_knocked_out THEN NULL ELSE
            ROUND(GREATEST(0, LEAST(100,
                0.50 * (
                    CASE
                        WHEN rng.max_wqi = rng.min_wqi OR l.water_quality_index IS NULL THEN 50
                        ELSE ((l.water_quality_index - rng.min_wqi) /
                              NULLIF(rng.max_wqi - rng.min_wqi, 0)) * 100
                    END
                ) +
                0.30 * (
                    CASE
                        WHEN rng.max_temp = rng.min_temp OR l.temp_ambient_mean_c IS NULL THEN 50
                        ELSE (1.0 - (l.temp_ambient_mean_c - rng.min_temp) /
                              NULLIF(rng.max_temp - rng.min_temp, 0)) * 100
                    END
                ) +
                0.20 * (
                    CASE
                        WHEN w.elevation_mean_m IS NULL THEN 50
                        WHEN w.elevation_mean_m >= 500 THEN 100  -- Sangat tinggi
                        WHEN w.elevation_mean_m >= 100 THEN 70   -- Dataran tinggi sedang
                        WHEN w.elevation_mean_m >= 10  THEN 50   -- Dataran rendah aman
                        ELSE 20                                   -- Di bawah 10m: risiko banjir
                    END
                )
            ))::numeric, 2)
        END AS score_environment

    FROM mart.dim_wilayah w
    JOIN mart.dim_risiko_bencana r        USING (bps_code)
    JOIN mart.dim_utilitas_energi e       USING (bps_code)
    JOIN mart.dim_konektivitas_jaringan k USING (bps_code)
    JOIN mart.dim_lingkungan_air l        USING (bps_code)
    CROSS JOIN ranges rng
)
SELECT
    bps_code,
    is_knocked_out,
    knockout_reason,
    score_power,
    score_safety,
    score_network,
    score_environment,
    -- Skor akhir tertimbang: Power 35% + Safety 25% + Network 25% + Env 15%
    CASE WHEN is_knocked_out THEN NULL
        ELSE ROUND(
            (0.35 * COALESCE(score_power, 50)       +
             0.25 * COALESCE(score_safety, 50)      +
             0.25 * COALESCE(score_network, 50)     +
             0.15 * COALESCE(score_environment, 50))::numeric,
        2)
    END AS final_score,
    -- Tiering
    CASE
        WHEN is_knocked_out THEN 'Tidak Direkomendasikan'
        WHEN ROUND(
            (0.35 * COALESCE(score_power, 50)       +
             0.25 * COALESCE(score_safety, 50)      +
             0.25 * COALESCE(score_network, 50)     +
             0.15 * COALESCE(score_environment, 50))::numeric, 2) >= 70
            THEN 'Tier 1: Sangat Layak'
        WHEN ROUND(
            (0.35 * COALESCE(score_power, 50)       +
             0.25 * COALESCE(score_safety, 50)      +
             0.25 * COALESCE(score_network, 50)     +
             0.15 * COALESCE(score_environment, 50))::numeric, 2) >= 45
            THEN 'Tier 2: Layak Bersyarat'
        ELSE 'Tier 3: Tidak Disarankan'
    END AS suitability_tier
FROM scored;
