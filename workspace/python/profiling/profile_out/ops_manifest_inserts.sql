-- Bukti file sumber -> ops.source_file_manifest. Lengkapi file_url bila kosong dan downloaded_by sebelum dijalankan.

INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-01', 'BMKG_Earthquake_Catalog.csv', 'https://data.mendeley.com/datasets/zmzywny59b/1', '113afb060675f8d90e9ec3f4bcc8490a25aead2135a7a3636423a80143cf18c8', 18974206, 217807, 'CC BY 4.0 (atribusi BMKG)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-02', 'data_bencana.xlsx', 'https://www.kaggle.com/datasets/maudiana/indonesia-natural-disaster-dataset-bnpb-records', 'd1823abb4081a3c3ca9b578506e5aa9f62b7e116bdf8ad87bb09d8a48cb50918', 1661845, 28773, 'lihat panel License di halaman Kaggle (data asal BNPB)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-03', 'climate_data.csv', 'https://www.kaggle.com/datasets/greegtitan/indonesia-climate', '27d07d8b92824d4619bbb835d4f5464e4d57971735d2df1890ab6e3ffa7f5f9b', 35844405, 589265, 'lihat panel License di halaman Kaggle (atribusi BMKG)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-03', 'province_detail.csv', 'https://www.kaggle.com/datasets/greegtitan/indonesia-climate', '54b4f3b291ba1809a50c2f6b6d05d70e70fc5bc1803c292a76d8f12541b1f8b8', 614, 34, 'lihat panel License di halaman Kaggle (atribusi BMKG)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-03', 'station_detail.csv', 'https://www.kaggle.com/datasets/greegtitan/indonesia-climate', '63e96ad743ebad6328628de0d4ff289678a78fdb3d88c6067fe5345dcb6d6d6c', 14985, 192, 'lihat panel License di halaman Kaggle (atribusi BMKG)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-04', 'data_dictionary.csv', 'https://data.mendeley.com/datasets/xxx26vkpsb/1', '39c8a1b4b1d981ad4802c24699365d88366dd2ff0cb7ac4369017d6b42e49bbc', 6442, 45, 'CC BY 4.0', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-04', 'master_features_v4.csv', 'https://data.mendeley.com/datasets/xxx26vkpsb/1', '320d1eb62f0e828b03b1ed694943d1d534b36807edc538a566384e4eb201970f', 222578, 514, 'CC BY 4.0', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-05', 'Cell Towers in Indonesia 510.csv', 'https://opencellid.org', '1318b1445759e2301a4c706b7421475442e47e6766c87b7203841e14c50a1e4e', 5189809, 66059, 'CC BY-SA 4.0 (atribusi OpenCelliD)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-06', 'ookla_fixed_2024q4_indonesia.csv', 'https://ookla-open-data.s3.amazonaws.com/parquet/performance/type=fixed/year=2024/quarter=4/', 'ba287a289176479346c35099a145ebd27fddeae13d982ddbb301087bdb4e8bb8', 70046037, 229305, 'CC BY-NC-SA 4.0 (non-komersial, atribusi Ookla)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-07', 'global_power_plant_database.csv', 'https://datasets.wri.org/dataset/globalpowerplantdatabase', '4b1f93e0fd93664f18684d9b05d0a52ed9658c6a8cf0d21ff2520791379ba7fc', 11973385, 178, 'CC BY 4.0', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-08', 'Gardu Induk dan Elektrik.csv', 'https://overpass-turbo.eu', '53c62cea0e1694a068625cb23a268863a365014764e213e709e4f6e9cfb226dc', 716359, 2821, 'ODbL (atribusi (c) OpenStreetMap contributors)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-08', 'export.geojson', 'https://overpass-turbo.eu', '4d387f18beffbd808c66f18377725f3b67c15a6d730819f5e4fee82085edfb73', 1613507, 2821, 'ODbL (atribusi (c) OpenStreetMap contributors)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-09', 'sebaran-point-of-presence-pop-layanan-jasa-internet-service-provider-isp_2026-11-13.csv', 'https://datahub.komdigi.go.id/public/detail-data/173', 'dc50bd60bee47916822c5c8312e81ebe0eb97b293bd0a312595a4e5ab9985383', 1842, 34, 'Data publik (atribusi Komdigi)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-10', 'Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2021.csv', 'https://www.bps.go.id', '5852fc451eb750b86c48ec6365d5584766d8f3d7719192747bfdeab4069fcaba', 2038, 38, 'Data publik BPS (atribusi BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-10', 'Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2022.csv', 'https://www.bps.go.id', 'bc105c9ddf344f82b6c7cbf7e4ed24c1d2a576fb22848f4522ed22a1c0d3b780', 2031, 38, 'Data publik BPS (atribusi BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-10', 'Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2023.csv', 'https://www.bps.go.id', '06ca43745149cedea0ade1f5e2b2f2605ba07cc2433960436d26229bec73f47d', 2120, 38, 'Data publik BPS (atribusi BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-10', 'Komponen Penyusun Indeks Kualitas Lingkungan Hidup Menurut Provinsi, 2024.csv', 'https://www.bps.go.id', '820554f61013936b432f91caebed34b9ae574ba3c74c8d3cb54a75a6002649df', 2108, 38, 'Data publik BPS (atribusi BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-11', 'idn_admin0.geojson', 'https://data.humdata.org/dataset/cod-ab-idn', 'f28232ab0d0161f46b58e2ca93c61732658459067f92bef7a721fce2a1b03b83', 96427785, 1, 'CC BY-IGO (atribusi OCHA/BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-11', 'idn_admin1.geojson', 'https://data.humdata.org/dataset/cod-ab-idn', '7809c678b9f1596736cf74116beb9deecd5c1ced99b0ceb205347af1f3501e46', 103908112, 34, 'CC BY-IGO (atribusi OCHA/BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-11', 'idn_admin2.geojson', 'https://data.humdata.org/dataset/cod-ab-idn', '15c1c0b449c5be5bd639c3fd39febf188842d026ddf448f7194799835d6f59ca', 149707552, 522, 'CC BY-IGO (atribusi OCHA/BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-11', 'idn_admin3.geojson', 'https://data.humdata.org/dataset/cod-ab-idn', '803ade4feaab704116ff9aaf6fc003a45e8d72293283ed13a50eccd8513ddf75', 286457798, 7069, 'CC BY-IGO (atribusi OCHA/BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-11', 'idn_admin4.geojson', 'https://data.humdata.org/dataset/cod-ab-idn', 'dd41f6a40dc9f07cfa4ed6aefca260ba13ce1e0b1b20ce485de2d74f04d91599', 651940706, 81912, 'CC BY-IGO (atribusi OCHA/BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-11', 'idn_adminlines.geojson', 'https://data.humdata.org/dataset/cod-ab-idn', 'be7ae0fdff02a12ff612aaf758742b3a11c60ba53e455ec6227f522e2d7a5bce', 399899482, 252741, 'CC BY-IGO (atribusi OCHA/BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-11', 'idn_adminpoints.geojson', 'https://data.humdata.org/dataset/cod-ab-idn', '4880f9f9b62e17c9b0a6170ce69a2b7bd9a04d5867dedd5544a7dfd48920e813', 24946052, 30626, 'CC BY-IGO (atribusi OCHA/BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-12', 'Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2022.csv', 'https://www.bps.go.id', 'f0e9540cff81f7f6f7360f65b36f1b721a69edfe753a3e7e8bad58c10ae33044', 2831, 34, 'Data publik BPS (atribusi BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-12', 'Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2023.csv', 'https://www.bps.go.id', '7a45da04a5a7c7ea24efff8dca66e5ef16d84847d8da3dcfbcd4674f6220bffe', 2385, 38, 'Data publik BPS (atribusi BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-12', 'Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2024.csv', 'https://www.bps.go.id', 'f6294041e6e0b29a45192319bb40228502a5c9e52876b850a92ca61e68721aba', 2706, 38, 'Data publik BPS (atribusi BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-12', 'Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2025.csv', 'https://www.bps.go.id', '3479478f44296af8fdb8549344f90b89e169b424b20a27605c224efa6c8ecf12', 2633, 38, 'Data publik BPS (atribusi BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
INSERT INTO ops.source_file_manifest (source_id, file_name, file_url, sha256, bytes, row_count, license, downloaded_by)
VALUES ('SRC-12', 'Penduduk, Laju Pertumbuhan Penduduk, Distribusi Persentase Penduduk, Kepadatan Penduduk, Rasio Jenis Kelamin Penduduk Menurut Provinsi, 2026.csv', 'https://www.bps.go.id', '64c20c111add7c5c243e01447256372c9fc9308efecdf360998f1fcaaacf4255', 2599, 38, 'Data publik BPS (atribusi BPS)', 'Kelompok DE Capstone')
ON CONFLICT DO NOTHING;
