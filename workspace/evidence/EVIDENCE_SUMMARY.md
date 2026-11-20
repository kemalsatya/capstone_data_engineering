# Evidence Summary — DE Capstone Indonesia Data Center Site Intelligence

*Diekspor otomatis dari PostgreSQL `labdata` pada 2026-11-20 15:23:06*

## 1. Executive KPI & Benchmark Operasional

| metric | value | source_ref |
| --- | --- | --- |
| Total Kab/Kota Dinilai | 514 | mart.fact_site_suitability |
| Total Provinsi Kanonik | 38 | mart.dim_provinsi |
| Koridor Pulau/Region | 7 | semantic.v_dc_site_ranking |
| Wilayah Eligible (Bebas Knock-Out) | 469 | mart.fact_site_suitability |
| Wilayah Disqualified (Knock-Out) | 45 | mart.fact_site_suitability |
|   - Pemicu Knock-Out Seismik (M>=6.5, <=30km, r<=25km) | 22 | mart.fact_site_suitability |
|   - Pemicu Knock-Out Banjir (>50 kejadian) | 26 | mart.fact_site_suitability |
| Tier 1 - Prime (Skor >= 65) | 91 | mart.fact_site_suitability |
| Tier 2 - Recommended (55 - 64.99) | 198 | mart.fact_site_suitability |
| Tier 3 - Moderate (45 - 54.99) | 98 | mart.fact_site_suitability |
| Tier 4 - Low Suitability (< 45) | 82 | mart.fact_site_suitability |
| Rata-rata Skor Komposit (Eligible) | 56.00 | mart.fact_site_suitability |
| Skor Tertinggi Nasional (Eligible) | 79.32 | mart.fact_site_suitability |
| Total Sumber Data Terintegrasi | 12 | semantic.v_dc_dq_governance |
| Total Berkas Manifest Terdaftar | 29 | semantic.v_dc_dq_governance |
| Total Baris Karantina Kritis (CRITICAL) | 0 | dq.quarantine_records |
| Total Temuan Peringatan DQ (WARNING) | 15625 | dq.capstone_quality_issues |
| Durasi E2E Master Workflow (SLA) | 09m 07s (547.41 detik) | wf_capstone_e2e_master.hwf (Tahap 6B) |
| Idempotency Lintas 7 Skema (83 Tabel) | 100% PASS (0 baris berubah/ganda) | snapshot_before vs snapshot_after |
| Performa SLO Query BI Top 15 / Hazard Trends | 0.103 ms / 2.741 ms (Target < 500 ms) | uat_verification_output.txt |

## 2. Hasil Verifikasi UAT (Acceptance Criteria)

| test_id | status | deskripsi | bukti_aktual |
| --- | --- | --- | --- |
| UAT-01 | PASS | Cakupan 514 Kab/Kota & 38 Provinsi di Star Schema | 514 kab/kota, 38 provinsi |
| UAT-02 | PASS | 0 NULL pada Skor Komposit, 4 Pilar, Region Pulau, & PoP ISP | Baris bermasalah: 0 |
| UAT-03 | PASS | Total Bobot 4 Pilar = 1.00 & Akurasi Formula Composite Score (tol <= 0.03) | Sum bobot=1.00, deviasi >0.03=0 |
| UAT-04 | PASS | Konsistensi Aturan Knock-Out (Disqualified tidak masuk national_rank_eligible) | Total KO=45, Eligible=469 |
| UAT-05 | PASS | Validitas Geometri PostGIS 100% (0 Invalid Geom di mart.dim_wilayah) | Invalid/NULL geom: 0 |
| UAT-06 | PASS | Kelengkapan Governance 12 Sumber Data (SRC-01..SRC-12) & 0 Karantina Kritis | Sumber=12, Karantina=0, Warning=15625 |

## 3. Tata Kelola & Kualitas 12 Sumber Data

| source_id | file_count | manifest_rows | total_size_mb | license | quarantined_rows | critical_issues | high_issues | warning_issues | total_dq_issues |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SRC-01 | 1 | 217807 | 18.1 | CC BY 4.0 (atribusi BMKG) | 0 | 0 | 0 | 0 | 0 |
| SRC-02 | 1 | 28773 | 1.58 | lihat panel License di halaman Kaggle (data asal BNPB) | 0 | 0 | 0 | 13236 | 13236 |
| SRC-03 | 3 | 589491 | 34.2 | lihat panel License di halaman Kaggle (atribusi BMKG) | 0 | 0 | 0 | 662 | 662 |
| SRC-04 | 2 | 559 | 0.22 | CC BY 4.0 | 0 | 0 | 0 | 0 | 0 |
| SRC-05 | 1 | 66059 | 4.95 | CC BY-SA 4.0 (atribusi OpenCelliD) | 0 | 0 | 0 | 0 | 0 |
| SRC-06 | 1 | 229305 | 66.8 | CC BY-NC-SA 4.0 (non-komersial, atribusi Ookla) | 0 | 0 | 0 | 0 | 0 |
| SRC-07 | 1 | 178 | 11.42 | CC BY 4.0 | 0 | 0 | 0 | 0 | 0 |
| SRC-08 | 2 | 5642 | 2.22 | ODbL (atribusi (c) OpenStreetMap contributors) | 0 | 0 | 0 | 1723 | 1723 |
| SRC-09 | 1 | 34 | 0.0 | Data publik (atribusi Komdigi) | 0 | 0 | 0 | 0 | 0 |
| SRC-10 | 4 | 152 | 0.01 | Data publik BPS (atribusi BPS) | 0 | 0 | 0 | 0 | 0 |
| SRC-11 | 7 | 372905 | 1633.92 | CC BY-IGO (atribusi OCHA/BPS) | 0 | 0 | 0 | 0 | 0 |
| SRC-12 | 5 | 186 | 0.01 | Data publik BPS (atribusi BPS) | 0 | 0 | 0 | 4 | 4 |

## 4. Top 15 Rekomendasi Lokasi Data Center Nasional (Eligible)

| national_rank_eligible | region_pulau | prov_name | kabkota_name | bps_kabkota_code | composite_score | power_score | safety_score | network_score | environment_score | suitability_tier |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Jawa | DKI Jakarta | Kota Jakarta Pusat | 3173 | 79.32 | 85.52 | 84.29 | 93.65 | 32.7 | Tier 1 - Prime |
| 2 | Jawa | Banten | Kota Tangerang Selatan | 3674 | 78.55 | 87.16 | 73.58 | 90.56 | 46.72 | Tier 1 - Prime |
| 3 | Jawa | Jawa Timur | Kota Surabaya | 3578 | 77.97 | 79.77 | 90.63 | 86.1 | 39.12 | Tier 1 - Prime |
| 4 | Jawa | Jawa Barat | Kota Cimahi | 3277 | 77.95 | 84.12 | 71.8 | 84.9 | 62.24 | Tier 1 - Prime |
| 5 | Jawa | Jawa Barat | Kota Bandung | 3273 | 77.63 | 84.9 | 66.6 | 87.72 | 62.24 | Tier 1 - Prime |
| 6 | Jawa | Banten | Kota Tangerang | 3671 | 77.3 | 86.33 | 79.95 | 84.9 | 39.16 | Tier 1 - Prime |
| 7 | Jawa | Jawa Barat | Kota Depok | 3276 | 77.23 | 86.71 | 66.74 | 89.23 | 52.58 | Tier 1 - Prime |
| 8 | Jawa | Jawa Timur | Kota Mojokerto | 3576 | 75.97 | 71.36 | 98.13 | 78.47 | 45.63 | Tier 1 - Prime |
| 9 | Jawa | DKI Jakarta | Kota Jakarta Barat | 3174 | 75.87 | 86.23 | 73.11 | 90.29 | 32.29 | Tier 1 - Prime |
| 10 | Jawa | Jawa Barat | Purwakarta | 3214 | 75.77 | 89.3 | 65.74 | 78.28 | 56.76 | Tier 1 - Prime |
| 11 | Jawa | DKI Jakarta | Kota Jakarta Utara | 3175 | 75.69 | 85.91 | 76.61 | 87.08 | 31.35 | Tier 1 - Prime |
| 12 | Jawa | Banten | Tangerang | 3603 | 74.74 | 87.94 | 72.16 | 79.33 | 40.61 | Tier 1 - Prime |
| 13 | Jawa | Jawa Barat | Kota Bekasi | 3275 | 74.73 | 86.88 | 63.29 | 87.19 | 44.67 | Tier 1 - Prime |
| 14 | Jawa | DKI Jakarta | Kota Jakarta Selatan | 3171 | 74.55 | 86.91 | 58.87 | 92.58 | 41.81 | Tier 1 - Prime |
| 15 | Jawa | Jawa Timur | Kota Blitar | 3572 | 73.38 | 62.9 | 93.79 | 78.68 | 54.95 | Tier 1 - Prime |

## 5. Top 10 Kandidat Ekspansi Luar Pulau Jawa (Eligible)

| rank_luar_jawa | rank_nasional | region_pulau | prov_name | kabkota_name | composite_score | power_score | safety_score | network_score | environment_score | suitability_tier |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 22 | Bali & Nusa Tenggara | Bali | Kota Denpasar | 70.67 | 67.07 | 78.29 | 82.98 | 45.82 | Tier 1 - Prime |
| 2 | 24 | Sumatera | Sumatera Utara | Pakpak Bharat | 70.3 | 69.71 | 89.53 | 56.0 | 63.43 | Tier 1 - Prime |
| 3 | 31 | Sulawesi | Sulawesi Selatan | Gowa | 68.87 | 71.84 | 72.32 | 70.99 | 52.63 | Tier 1 - Prime |
| 4 | 32 | Sulawesi | Sulawesi Selatan | Kota Makasar | 68.85 | 68.37 | 78.89 | 76.76 | 40.03 | Tier 1 - Prime |
| 5 | 34 | Bali & Nusa Tenggara | Bali | Klungkung | 68.8 | 64.38 | 81.25 | 73.84 | 49.96 | Tier 1 - Prime |
| 6 | 35 | Bali & Nusa Tenggara | Bali | Gianyar | 68.75 | 69.92 | 68.63 | 76.69 | 52.99 | Tier 1 - Prime |
| 7 | 36 | Sumatera | Sumatera Utara | Kota Pematang Siantar | 68.74 | 71.8 | 75.75 | 63.94 | 57.89 | Tier 1 - Prime |
| 8 | 39 | Sumatera | Kepulauan Riau | Kota Batam | 68.45 | 66.37 | 92.21 | 64.03 | 41.08 | Tier 1 - Prime |
| 9 | 40 | Kalimantan | Kalimantan Timur | Kota Balikpapan | 68.41 | 65.79 | 75.73 | 77.94 | 46.46 | Tier 1 - Prime |
| 10 | 42 | Sulawesi | Sulawesi Selatan | Toraja Utara | 68.3 | 68.33 | 79.99 | 59.79 | 62.93 | Tier 1 - Prime |

## 6. Sampel 10 Wilayah Disqualified (Knock-Out) Skor Infrastruktur Tertinggi

| region_pulau | prov_name | kabkota_name | bps_kabkota_code | composite_score | power_score | safety_score | network_score | environment_score | ko_seismic_flag | ko_flood_flag | eq_count_ko_events_25km | eq_max_magnitude_25km | bnpb_flood_events | bnpb_total_events | knockout_reasons |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Jawa | DKI Jakarta | Kota Jakarta Timur | 3172 | 73.24 | 86.5 | 59.06 | 88.54 | 40.4 | False | True | 0 | 5.0 | 52 | 68 | FLOOD_KO_GT_50_EVENTS |
| Jawa | Jawa Barat | Bekasi | 3216 | 71.04 | 88.14 | 55.87 | 80.33 | 40.96 | False | True | 0 | 5.0 | 59 | 99 | FLOOD_KO_GT_50_EVENTS |
| Jawa | Jawa Timur | Pasuruan | 3514 | 68.48 | 77.65 | 63.37 | 70.0 | 53.04 | False | True | 0 |  | 56 | 98 | FLOOD_KO_GT_50_EVENTS |
| Jawa | Jawa Barat | Karawang | 3215 | 68.46 | 85.37 | 52.09 | 75.76 | 44.11 | False | True | 0 | 5.5 | 71 | 177 | FLOOD_KO_GT_50_EVENTS |
| Jawa | Jawa Tengah | Kota Semarang | 3374 | 66.61 | 72.89 | 50.45 | 83.1 | 51.4 | False | True | 0 | 5.7 | 60 | 353 | FLOOD_KO_GT_50_EVENTS |
| Jawa | Jawa Timur | Bangkalan | 3526 | 66.36 | 78.64 | 64.49 | 62.48 | 47.26 | True | False | 1 | 7.0 | 14 | 23 | SEISMIC_KO_M6.5_SHALLOW_25KM |
| Jawa | Jawa Barat | Bandung | 3204 | 66.02 | 85.61 | 36.97 | 74.67 | 54.31 | False | True | 0 | 6.1 | 122 | 343 | FLOOD_KO_GT_50_EVENTS |
| Jawa | Jawa Timur | Gresik | 3525 | 64.94 | 80.16 | 47.63 | 73.51 | 43.96 | False | True | 0 | 5.2 | 67 | 84 | FLOOD_KO_GT_50_EVENTS |
| Jawa | Jawa Barat | Bogor | 3201 | 64.41 | 91.83 | 20.77 | 77.37 | 51.57 | False | True | 0 | 6.0 | 208 | 1871 | FLOOD_KO_GT_50_EVENTS |
| Jawa | Jawa Tengah | Kendal | 3324 | 64.29 | 75.63 | 50.21 | 70.22 | 51.4 | True | False | 1 | 7.9 | 44 | 181 | SEISMIC_KO_M6.5_SHALLOW_25KM |
