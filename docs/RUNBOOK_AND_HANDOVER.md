# Operational Runbook & Handover — DE Capstone Data Center Site Intelligence

Dokumen ini menjadi panduan operasional, pemulihan insiden, tata kelola keamanan, estimasi biaya/sumber daya, serta serah terima (*handover*) produk data **Intelijen Lokasi Fasilitas Kritis untuk Ekspansi Data Center di Indonesia**.

---

## 1. Batas Keamanan (*Security Boundaries*) & Topologi Layanan

Seluruh komponen berjalan terisolasi di dalam jaringan internal Docker (`labnet`) tanpa mengekspos kredensial ke repositori Git:

| Zona / Batas Keamanan | Komponen | Akses / Port | Mekanisme Pengamanan |
| :--- | :--- | :--- | :--- |
| **Zona Host Lokal** | PowerShell CLI, repositori Git, `.env` | Lokal (tidak diekspos publik) | `.env`, `backups/`, dan `compose-resolved.yml` diblokir lewat `.gitignore` (`SECURITY AUDIT 100% PASS`). |
| **Zona Orkestrasi & ETL** | `workbench` (Apache Hop + Python 3) | Webtop `127.0.0.1:3001` | Kredensial DB disuntik lewat variabel lingkungan `${LAB_DB_PASSWORD}`; hak database dibatasi konsep *least privilege* (`etl_runner`). |
| **Zona Data Inti (RDBMS)** | `postgres` (`postgis/postgis:16-3.4`) | Internal `postgres:5432` (host `55432`) | Pemisahan 9 skema (`raw`, `stg`, `dq`, `ops`, `mdm`, `vault`, `bv`, `mart`, `semantic`), `REVOKE ALL FROM PUBLIC`, dan 3 role `NOLOGIN` (`bi_reader`, `dq_steward`, `etl_runner`). |
| **Zona Konsumsi BI & Audit** | `superset` (profil `bi`), `cloudbeaver` | `127.0.0.1:8088`, `127.0.0.1:8978` | Konsumen BI diarahkan hanya ke *semantic/protected views* (`v_dc_site_ranking_protected` dengan masking koordinat 2 desimal & notice *non-commercial*). |

---

## 2. Prosedur Operasional Standar (SOP)

### 2.1 Startup & Health Check
```powershell
# 1. Jalankan layanan inti + BI
docker compose up -d postgres workbench cloudbeaver
docker compose --profile bi up -d superset

# 2. Verifikasi kesehatan layanan
docker compose ps
Invoke-WebRequest -Uri "http://127.0.0.1:8088/health" -UseBasicParsing
```

`up core` mencakup `postgres`, `workbench`, dan `cloudbeaver` (setara `lab.ps1 up core`).

### 2.2 Bootstrap & Clean Rebuild Database (14 Skrip SQL Idempotent)
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\lab.ps1 db-init
```
Urutan eksekusi terkelola: `03-raw.sql` → `04-stg.sql` → `05-dq.sql` → `06-ops-manifest.sql` → `07-mdm-params.sql` → `07b-mdm-aliases.sql` → `07c-fix-papua-prov-codes.sql` → `08-vault.sql` → `09-bv.sql` → `10-mart.sql` → `11-semantic.sql` → `11b-semantic-bi-enrichment.sql` → `12-security-rbac.sql` → `13-ops-observability.sql`.

Idempotensi berlaku untuk DDL (`CREATE ... IF NOT EXISTS`, `ON CONFLICT ... DO UPDATE`, tanpa `DROP TABLE`/`TRUNCATE`). Pada database kosong, `07-mdm-params.sql` menyisipkan **0 baris** karena membaca `stg.src_04_fitur_kabkota` yang belum terisi; crosswalk MDM (38 provinsi, 514 kab/kota, 15 alias) baru terisi setelah staging jalan dan `db-init` dipanggil ulang.

### 2.3 Eksekusi Batch End-to-End & Ekspor Bukti
```powershell
# Jalankan master workflow (estimasi 9 menit 07 detik)
docker compose exec -T -u abc workbench bash -lc 'cd /opt/hop && ./hop-run.sh -j capstone-local -e docker-local -r local -s LAB_DB_PASSWORD=$LAB_DB_PASSWORD -f /config/workspace/hop-project/workflows/wf_capstone_e2e_master.hwf'

# Verifikasi UAT (6/6 PASS) & RBAC (6/6 PASS)
Get-Content workspace\sql\uat_verification.sql -Raw | docker compose exec -T postgres psql -U labuser -d labdata -v ON_ERROR_STOP=1
Get-Content workspace\sql\test_security_rbac.sql -Raw | docker compose exec -T postgres psql -U labuser -d labdata -v ON_ERROR_STOP=1

# Regenerasi Evidence Workbook & Metadata Governance
docker compose exec -T -u abc workbench python3 /config/workspace/scripts/export_evidence.py
docker compose exec -T -u abc workbench python3 /config/workspace/scripts/generate_metadata_governance.py
```

`wf_capstone_e2e_master.hwf` merangkai 5 workflow lain: `wf_stg_master` → `wf_vault_bv_master` (yang memanggil `wf_vault_load` lalu `wf_bv_load`) → `wf_mart_load`. Total ada 6 berkas `.hwf` di `workspace/hop-project/workflows/`.

### 2.4 Backup & Shutdown Aman
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\lab.ps1 backup
docker compose --profile bi down
```

---

## 3. Matriks SLI / SLO & Pemantauan (*Observability*)

Seluruh metrik dicatat di `ops.etl_run_log`, `ops.pipeline_checkpoint`, dan `ops.sli_slo_targets`:

| SLO ID | Indikator (SLI) | Target SLO | Hasil Observasi Aktual | Status |
| :---: | :--- | :--- | :--- | :---: |
| `SLO-01` | Durasi Batch Master Workflow E2E | <= 900 detik (15 menit) | **547,41 detik** (9m 07d) | `MEETS_SLO` |
| `SLO-02` | Latensi Kueri BI Top 15 Ranking | <= 500 ms | **0,103 ms** | `MEETS_SLO` |
| `SLO-03` | Latensi Kueri BI Hazard Trends | <= 500 ms | **2,741 ms** | `MEETS_SLO` |
| `SLO-04` | Idempotensi 83 Tabel / 7 Skema | 0 baris berubah/ganda | **0 baris berubah** | `MEETS_SLO` |
| `SLO-05` | Cakupan Wilayah & Validitas PostGIS | 100% (514/514) | **100% (514/514)** | `MEETS_SLO` |
| `SLO-06` | Recovery Time Objective (RTO) Mart | <= 60 detik | **7,81 detik** (Hop 4,885 dtk) | `MEETS_SLO` |

**Kueri Pemantauan Harian (Role `dq_steward`):**
```sql
SELECT run_id, job_name, run_mode, status, duration_sec, rows_out, rows_rejected, error_message
FROM semantic.v_dc_ops_observability
LIMIT 10;
```

---

## 4. Penanganan Insiden, *Retry*, & *Backfill*

| Skenario Insiden | Gejala / Deteksi | Prosedur Pemulihan (*Retry / Backfill*) | Bukti Uji Aktual |
| :--- | :--- | :--- | :--- |
| **1. Kegagalan Tulis Mart (`wf_mart_load.hwf`)** | `exit_code != 0`, `result=[false]`, `rows_out=0` di `ops.etl_run_log` | (a) Periksa pesan error di log Hop & `pg_stat_activity`. (b) Hilangkan penyebab *lock/fault*. (c) Jalankan ulang `wf_mart_load.hwf` (idempotent penuh) dan verifikasi `COUNT(*) = 514` + `uat_verification.sql`. | `RUN-20261125160755-FAIL` → `REC` (`failure_recovery_output.txt`), RTO **7,81 dtk**, `514/514` pulih. |
| **2. Lonjakan Karantina `CRITICAL` (`dq.quarantine_records`)** | `rows_rejected > 0` pada salah satu pipeline `pl_stg_*` | (a) Audit `rule_id`, `failed_column`, dan `payload_raw` di `dq.quarantine_records`. (b) Perbaiki berkas sumber atau aturan sanitasi. (c) Bersihkan batch bermasalah di `raw.*`, muat ulang, lalu jalankan `wf_stg_master.hwf`. | `RUN-202611251641*-NEGDQ` (`negative_dq_test_output.txt`): 2 `CRITICAL` ditahan, 0 bocor, pulih `178/178`. |
| **3. Perubahan Bobot / Ambang Scoring (*Backfill* Mart)** | Permintaan simulasi/revisi bobot oleh *Business Owner* | (a) Simpan backup `ops.scoring_parameters`. (b) Perbarui nilai bobot (pastikan jumlah bobot 4 pilar = `1,00`). (c) Jalankan `wf_mart_load.hwf` (atau `wf_bv_load.hwf` jika mengubah ambang radius/KO). (d) Jalankan `UAT-03` dan *snapshot comparison*. | `change_impact_output.txt`: simulasi *Green DC* + rollback `0` deviasi. |
| **4. Error Izin Audit Log Hop GUI (`./audit/...`)** | `FileNotFoundException` saat membuka `capstone-local` di Hop GUI | Jalankan `mkdir -p /opt/hop/audit/hop-gui/project /config/.hop/audit/hop-gui/project && chown -R abc:abc /opt/hop/audit /config/.hop` atau jalankan `export HOP_AUDIT_FOLDER=/config/.hop/audit && hop-gui`. | Terverifikasi pada kontainer `workbench`. |

---

## 5. Kebijakan Retensi, Penghapusan, & Hak Akses RBAC

* **Role `bi_reader`:** *Read-only* terbatas pada 6 view `semantic.v_dc_*` (termasuk 2 *protected views*). Teruji ditolak (`permission denied`) pada `raw`, `ops`, dan `mart` (`SEC-01` s.d. `SEC-04` PASS).
* **Role `dq_steward`:** *Read-only* pada `dq`, `ops`, `mdm`, dan `semantic`. Teruji ditolak `DELETE` pada tabel DQ (`SEC-05` PASS).
* **Role `etl_runner`:** Hak DML pada `raw` s.d. `mart`, tanpa hak DDL `CREATE/DROP` (`SEC-06` PASS).
* **Siklus Hidup Data (`ops.data_classification_policy`):** `raw`/`stg` retensi **90 hari**, `dq` **180 hari**, `ops`/`mart`/`semantic` **365 hari**, dan `mdm`/`vault`/`bv` **730 hari**.

---

## 6. Baseline Sumber Daya & Analisis *Trade-Off* Biaya

| Dimensi | Implementasi Saat Ini (Lokal Docker) | Alternatif Setara *Managed Cloud* (Estimasi Proporsional) |
| :--- | :--- | :--- |
| **Infrastruktur** | Laptop lokal Windows 11 + WSL2 Docker Desktop (alokasi 8 GB RAM, 4–8 vCPU) | Managed PostgreSQL/PostGIS (2 vCPU, 8 GB RAM, 50 GB SSD) + 1 VM ETL/BI (2 vCPU, 8 GB RAM) |
| **Estimasi Biaya Bulanan** | **Rp 0** biaya langganan *cloud* (memanfaatkan perangkat tim & 100% *open-source*) | Sekitar **USD 90 – 160 / bulan** (~Rp 1,4 – 2,5 juta/bulan) tergantung penyedia & jam nyala VM |
| **Kinerja Terukur** | Batch E2E **9m 07d**; kueri BI **0,10–2,74 ms**; backup SQL **1,92 GB** | Setara atau sedikit lebih cepat pada I/O SSD *cloud*, namun memerlukan biaya *egress* & manajemen jaringan |
| **Trade-Off & Rekomendasi** | **Optimal untuk proyek akademik & *batch screening* kuartalan** (data BMKG/BNPB/Ookla diperbarui bulanan–kuartalan). Tidak mendukung *high availability* 24/7. | Migrasi ke *cloud* baru proporsional apabila produk dipakai secara bersamaan oleh puluhan analis eksternal atau membutuhkan jadwal *refresh* otomatis tanpa ketergantungan laptop lokal. |

---

## 7. Batasan Sistem, Status *Sign-Off*, & Transparansi (*Integrity Disclosure*)

* **Status Operasional (Jujur, Tanpa *Overclaiming*):** Sistem ini berjalan dalam mode **batch/snapshot lokal terkontainerisasi**. Proyek ini **tidak mengklaim** status produksi komersial, *real-time CDC*, *exactly-once streaming*, maupun *high availability (HA)*.
* **Status *Sign-Off* Konsumen:** **`SIMULASI AKADEMIK`** — validasi penerimaan persona ekspansi (Q1–Q3) dan 6 skenario UAT + 6 uji RBAC + 2 uji *negative/recovery* dilakukan secara mandiri oleh tim dengan kriteria terukur, belum melalui *sign-off* korporasi eksternal.
* **Keterbatasan Utama & *Roadmap*:**
  1. Granularitas level kabupaten/kota (514 wilayah) untuk *macro screening*; fase lanjutan memerlukan peta genangan & sesar mikro level persil (InaRISK/BIG).
  2. Data gardu OSM (`SRC-08`) tidak memuat kapasitas tersisa (MVA) atau SAIDI/SAIFI PLN; fase lanjutan mengintegrasikan data RUPTL PLN.
  3. Pembatasan lisensi non-komersial pada `SRC-06` (Ookla `CC BY-NC-SA 4.0`); penggunaan komersial memerlukan lisensi berbayar Ookla Enterprise atau penggantian sumber APJII/IIX.
* **Pengungkapan Bantuan AI & Verifikasi Mandiri:** Tim menggunakan bantuan AI secara transparan untuk membantu perancangan draf skrip SQL/Python, perbaikan *troubleshooting* Docker/Hop, serta penataan struktur dokumentasi; seluruh kode, hasil eksekusi terminal, kueri SQL, uji UAT/RBAC/karantina, dan angka empiris telah dijalankan, diverifikasi langsung terhadap PostgreSQL `labdata`, serta dipahami oleh anggota tim untuk dipertanggungjawabkan pada *defense* individual.