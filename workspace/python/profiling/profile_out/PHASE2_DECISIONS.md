# PHASE2_DECISIONS.md  (isi lalu kirim bersama ai_input_pack_part*.md)
Beri tanda [x] pada pilihan dan isi kolom bergaris bawah. Jika setuju dengan rekomendasi, cukup tulis "ikuti rekomendasi".

## D1 Grain fakta utama
[ ] Periodic snapshot: 1 baris = 1 kab/kota x assessment_year (rekomendasi)   [ ] lainnya: ______
assessment_year: ____   jendela bahaya per jenis (isi sesuai cakupan data nyata di temporal_coverage.md):
 gempa (SRC-01): ____ s.d. ____   banjir/longsor (SRC-02): ____ s.d. ____   iklim (SRC-03): ____ s.d. ____
## D2 Definisi paparan gempa (lihat spatial_probe di pack: titik-dalam-poligon hanya menangkap sebagian kecil gempa)
[ ] Radius jarak dari wilayah (rekomendasi), radius: ____ km    [ ] Titik-dalam-poligon
## D3 Kunci wilayah kanonik
[ ] Kode BPS 4 digit dari SRC-04 (514 wilayah, 38 provinsi)   [ ] pcode ADM2 SRC-11 (522 poligon, 34 provinsi, batas 2020)   [ ] lainnya: ______
Aturan crosswalk: SRC-11 pcode = 'ID' + kode BPS (lihat relationship_probe). Pemekaran Papua (26 kab) dipetakan ke: ______
SRC-02 city_id BUKAN kode BPS: [ ] cocokkan dengan nama+provinsi (rekomendasi)   Poligon non-wilayah (Danau/Waduk/Hutan) di SRC-11: [ ] dikeluarkan
## D4 Pola Data Vault
Penugasan spasial (titik -> wilayah) di business vault (bv_): [ ] setuju   Pengamatan harian sebagai satelit dengan obs_date: [ ] setuju
## D5 Model dimensional
[ ] fact_site_assessment + fact_kejadian_bencana (opsional) + dim_wilayah, dim_waktu, dim_jenis_bencana (rekomendasi)   [ ] lainnya: ______
## D6 KPI, ambang, bobot (tabel parameter, bukan hard-code)
KPI-01 rumus: ______   ambang status 'Tinggi': ______
KPI-02 rumus: ______   sumber suhu/iklim: [ ] SRC-04 (t2m_mean, 514 wilayah)  [ ] SRC-03 (stasiun, s.d. 2020)  [ ] keduanya
KPI-03 bobot: keamanan __% utilitas __% iklim __%   level ranking: [ ] kab/kota  [ ] provinsi
Parameter: tegangan minimum gardu = ___ kV; radius gardu = ___ km; radius menara = ___ km; magnitudo minimum bahaya = ___
## D7 Database target
Database: ______   Image PostGIS (tag persis): ______   hasil SELECT postgis_version(): ______
## D8 Kebijakan raw
[ ] Raw append-only dengan _batch_id; staging reload per batch; vault insert-only (rekomendasi)
## D9 Konvensi
snake_case; hash key char(32)=md5; timestamptz UTC; SRID 4326; unit baku kV, MW, km, Mbps: [ ] setuju   perubahan: ______
## D10 Strategi muat per sumber (FULL / INCREMENTAL / SNAPSHOT)
SRC-01 ____ SRC-02 ____ SRC-03 ____ SRC-04 ____ SRC-05 ____ SRC-06 ____ SRC-07 ____ SRC-08 ____ SRC-09 ____ SRC-10 ____ SRC-11 ____ SRC-12 ____
## D11 Nilai pecahan pada kolom korban/kerusakan SRC-02 (death, missing_person, injured_person, flooded_house; lihat readiness_report)
[ ] simpan apa adanya sebagai numeric dan beri catatan 'bukan hitungan asli' (rekomendasi)  [ ] bulatkan  [ ] jangan pakai kolom ini di KPI   Alasan/konfirmasi pemilik data: ______
## D12 Baris duplikat penuh SRC-02 (lihat readiness_report)
[ ] hapus duplikat di staging (rekomendasi)  [ ] pertahankan   Kunci surrogate: [ ] hash seluruh kolom + nomor urut duplikat
## D13 Jendela bahaya dan klaim proposal (lihat temporal_coverage.md)
Banjir/longsor/bencana lain memakai rentang data aktual SRC-02: ____ s.d. ____ ; proposal diperbarui: [ ] ya   Gempa (SRC-01) jendela: ____ s.d. ____ (cakupan deteksi tidak merata antar tahun; tetapkan ambang magnitudo)
## D14 Sumber suhu/iklim dan cakupan stasiun (SRC-03 berakhir 2020, hanya sebagian kab/kota punya stasiun)
[ ] SRC-04 sebagai sumber utama (514 wilayah, rata-rata 2020-2024), SRC-03 untuk validasi/detail stasiun   [ ] SRC-03 utama   [ ] lainnya: ______
## Catatan lain / pertanyaan untuk AI
______
