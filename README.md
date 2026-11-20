# Intelijen Lokasi Fasilitas Kritis: Ekspansi Data Center di Indonesia

Produk data *end-to-end* untuk evaluasi kelayakan lokasi pembangunan *data center* di seluruh **514 kabupaten/kota** dan **38 provinsi** di Indonesia dengan mengintegrasikan **12 sumber data publik heterogen** (risiko bencana, klimatologi, geospasial, utilitas kelistrikan, dan konektivitas jaringan) di atas *stack open-source* terkontainerisasi.

---

## Ringkasan Eksekutif & Metrik Utama

| Metrik | Nilai Aktual | Sumber Verifikasi |
| :--- | :--- | :--- |
| **Cakupan Wilayah Kanonik** | **514** Kab/Kota · **38** Provinsi · **7** Koridor Pulau (100% terpetakan) | `mart.fact_site_suitability` |
| **Sumber Data Terintegrasi** | **12** Sumber (`SRC-01` s.d. `SRC-12`) · **29** Berkas Manifest | `ops.source_file_manifest` |
| **Hasil Kelayakan Lokasi** | **469 Eligible** (**91** Tier 1 Prime) · **45 Disqualified (Knock-Out)** | `semantic.v_dc_site_ranking` |
| **Durasi Master Workflow E2E (SLA)** | **9 menit 07 detik** (`547,41 detik`) | `wf_capstone_e2e_master.hwf` |
| **Idempotensi Lintas Lapisan** | **100% PASS** (`0` baris berubah/ganda di **83 tabel / 7 skema**) | `snapshot_before` vs `after` |
| **Data Quality Gate** | **0** Karantina `CRITICAL` · **15.625** Temuan `WARNING` tercatat | `dq.capstone_quality_issues` |
| **UAT Acceptance Criteria** | **6 / 6 PASS** (`UAT-01` s.d. `UAT-06`) | `workspace/sql/uat_verification.sql` |
| **Performa Kueri BI (SLO < 500 ms)** | **0,103 ms** (*Top 15 Ranking*) · **2,741 ms** (*Hazard Trends*) | `EXPLAIN ANALYZE` |

---

## Arsitektur Pipeline End-to-End

Seluruh pemrosesan dirancang berlapis untuk memisahkan data mentah, validasi kualitas, pemodelan historis auditabel (*Data Vault 2.0*), analisis spasial *PostGIS*, dan lapisan analitik siap konsumsi BI (*Star Schema* + *Semantic Views*):

```text
[12 Sumber Data Publik (CSV / XLSX / GeoJSON)]
                     │
                     ▼  Python Ingestion (run_ingestion.py)
        ┌────────────────────────┐
        │   raw.* (15 Tabel)     │  Data mentah persis sumber + ops.source_file_manifest
        └────────────┬───────────┘
                     │  Apache Hop: wf_stg_master.hwf (15 Pipeline .hpl)
                     ▼
   ┌─────────────────────────────────────┐
   │  stg.* (15 Tabel + PostGIS GIST)    │──► dq.quarantine_records (0 CRITICAL)
   │  mdm.* (Crosswalk 514 + 15 Alias)   │──► dq.capstone_quality_issues (15.625 WARNING)
   └─────────────────┬───────────────────┘
                     │  Apache Hop: wf_vault_load.hwf
                     ▼
        ┌────────────────────────┐
        │  vault.* (26 Tabel)    │  Raw Data Vault 2.0: 9 Hub, 3 Admin Link, 14 Satellite
        │  (Insert-Only, MD5 HK) │  Unit baku: kV (gardu) & Mbps (Ookla)
        └────────────┬───────────┘
                     │  Apache Hop: wf_bv_load.hwf (PostGIS ST_Subdivide + Geodesic)
                     ▼
        ┌────────────────────────┐
        │   bv.* (10 Tabel)      │  Business Vault Spasial: 5 Spatial Links & 4 Pillar Sats
        │                        │  Membaca ambang dari ops.scoring_parameters (18 param)
        └────────────┬───────────┘
                     │  Apache Hop: wf_mart_load.hwf
                     ▼
        ┌────────────────────────┐
        │   mart.* (6 Tabel)     │  Star Schema: 4 Dimensi + 2 Tabel Fakta
        └────────────┬───────────┘
                     │  11-semantic.sql + 11b-semantic-bi-enrichment.sql
                     ▼
        ┌────────────────────────┐
        │ semantic.v_dc_* (6)    │──► Apache Superset (4-Tab Interactive Dashboard)
        └────────────────────────┘──► export_evidence.py (Excel 13-Sheet + 13 CSV)
```

### Stack Teknologi
* **Containerization & CLI:** Docker Compose (`compose.yaml`), PowerShell wrapper (`scripts/lab.ps1`)
* **Database & Spatial Engine:** PostgreSQL 16 + PostGIS 3.4 (`postgis/postgis:16-3.4`)
* **Orchestration & ETL:** Apache Hop (`workbench` container) + Python 3 (`psycopg2`, `openpyxl`)
* **BI & Observability:** Apache Superset (profil `bi`, port `8088`), CloudBeaver (port `8978`)

---

## Katalog 12 Sumber Data (`SRC-01` s.d. `SRC-12`)

Detail lengkap atribusi dan tautan sumber tercatat di [`LICENSES_AND_SOURCES.md`](LICENSES_AND_SOURCES.md) serta `ops.source_file_manifest`.

| Source ID | Domain & Sumber | Baris Manifest | Pilar Terkait | Lisensi |
| :---: | :--- | ---: | :--- | :--- |
| `SRC-01` | Katalog Gempa Bumi BMKG | 217.807 | Safety | CC BY 4.0 (BMKG) |
| `SRC-02` | Kejadian Bencana Historis BNPB (2010–2025) | 28.773 | Safety | Data Publik BNPB / Kaggle |
| `SRC-03` | Klimatologi Harian & Stasiun BMKG (3 berkas) | 589.491 | Environment | Data Publik BMKG / Kaggle |
| `SRC-04` | Fitur Master Kab/Kota (BPS, NASA POWER, Elevasi, Jalan) | 559 | Master & Environment | CC BY 4.0 |
| `SRC-05` | Menara Seluler Indonesia (OpenCelliD MCC 510) | 66.059 | Network | CC BY-SA 4.0 |
| `SRC-06` | Performa Fixed Broadband Ookla (2024 Q4) | 229.305 | Network | CC BY-NC-SA 4.0 |
| `SRC-07` | Global Power Plant Database (WRI) | 178 | Power | CC BY 4.0 |
| `SRC-08` | Gardu Induk & Transmisi Listrik (OpenStreetMap) | 5.642 | Power | ODbL (OSM) |
| `SRC-09` | Sebaran Point of Presence (PoP) ISP per Provinsi | 34 | Network | Data Publik Komdigi |
| `SRC-10` | Indeks Kualitas Lingkungan Hidup (IKLH) Provinsi (4 berkas) | 152 | Environment | Data Publik BPS |
| `SRC-11` | Batas Administrasi Indonesia COD-AB ADM0–ADM4 (7 berkas) | 372.905 | Spasial (PostGIS) | CC BY-IGO (OCHA/BPS) |
| `SRC-12` | Kependudukan & Kepadatan Provinsi (5 berkas) | 186 | Konteks Demografi | Data Publik BPS |

---

## Metodologi Scoring 4 Pilar & Aturan Knock-Out

Seluruh bobot dan ambang batas dibaca secara dinamis dari `ops.scoring_parameters` (tanpa nilai *hard-coded*):

1. **Power (`35%`):** Jarak ke gardu induk tegangan tinggi `>= 150 kV` (40%), jumlah gardu `>= 150 kV` dalam radius `25 km` (30%), kapasitas pembangkit MW dalam radius `50 km` (20%), dan porsi energi terbarukan (10%).
2. **Safety (`25%`):** Invers paparan gempa signifikan `M >= 5,0` dalam radius `25 km` periode 2014–2024 (45%), invers kejadian banjir historis BNPB (35%), dan invers kejadian longsor/bencana lainnya (20%).
3. **Network (`25%`):** Kecepatan unduh *test-weighted* Ookla Mbps (35%), invers latensi Ookla ms (25%), kepadatan menara seluler per `100 km²` (25%), dan jumlah PoP ISP provinsi dengan *parent fallback* untuk 4 provinsi pemekaran Papua (15%).
4. **Environment (`15%`):** Efisiensi suhu lingkungan (40%), rata-rata skor IKLH provinsi (30%), kesesuaian elevasi 50–800 mdpl (15%), dan invers kelembapan udara (15%).
5. **Aturan Disqualified (`Knock-Out`):** Wilayah otomatis ditandai `Disqualified (Knock-Out)` dan dikeluarkan dari peringkat *eligible* jika memiliki minimal 1 gempa dangkal destruktif (`M >= 6,5`, kedalaman `<= 30 km`, radius `<= 25 km`) **atau** lebih dari `50` kejadian banjir historis BNPB.

---

## Ringkasan Hasil Empiris Utama

### Distribusi Suitability Tier (514 Kabupaten/Kota)

| Suitability Tier | Jumlah Wilayah | Skor Min | Rata-rata Skor | Skor Maks |
| :--- | ---: | ---: | ---: | ---: |
| **Tier 1 - Prime (`>= 65`)** | 91 | 65,11 | 69,10 | 79,32 |
| **Tier 2 - Recommended (`55 – 64,99`)** | 198 | 55,06 | 60,12 | 64,93 |
| **Tier 3 - Moderate (`45 – 54,99`)** | 98 | 45,81 | 51,53 | 54,86 |
| **Tier 4 - Low Suitability (`< 45`)** | 82 | 26,85 | 36,84 | 43,73 |
| **Disqualified (Knock-Out)** | 45 | 32,49 | 57,11 | 73,24 |

### Temuan Kunci per Pertanyaan Analitis (Q1 – Q3)
* **Q1 — Top 5 Lokasi Eligible Nasional:** **Kota Jakarta Pusat (79,32)**, **Kota Tangerang Selatan (78,55)**, **Kota Surabaya (77,97)**, **Kota Cimahi (77,95)**, dan **Kota Bandung (77,63)**. Koridor Cimahi–Bandung–Purwakarta menonjol pada kombinasi daya listrik kuat dan efisiensi termal dataran tinggi (*Environment* 56–62).
* **Q2 — Top Kandidat Ekspansi & DRC Luar Pulau Jawa:** **Kota Denpasar (70,67; *Network* 82,98)**, **Pakpak Bharat (70,30; *Safety* 89,53)**, **Gowa (68,87; *Power* 71,84)**, **Kota Makassar (68,85)**, **Kota Batam (68,45; *Safety* 92,21)**, dan **Kota Balikpapan (68,41; *Network* 77,94)**.
* **Q3 — Audit Trade-Off Infrastruktur vs Risiko (45 Wilayah Knock-Out):** Terdiri dari **22** pemicu seismik dan **26** pemicu banjir (3 tumpang tindih). Koridor industri berinfrastruktur tinggi seperti **Kota Jakarta Timur (73,24; 52 banjir)**, **Kab. Bekasi (71,04; 59 banjir)**, **Pasuruan (68,48; 56 banjir)**, **Karawang (68,46; 71 banjir)**, dan **Kota Semarang (66,61; 60 banjir)** otomatis tertahan oleh `FLOOD_KO_GT_50_EVENTS`, menegaskan perlunya mitigasi hidrologi tingkat tapak (*site-level engineering*) sebelum investasi.

---

## Struktur Repositori

```text
.
├── compose.yaml                              # Orkestrasi Docker (PostGIS, Hop Workbench, CloudBeaver, Superset)
├── .env.example                              # Template variabel lingkungan (jangan commit .env asli)
├── LICENSES_AND_SOURCES.md                   # Dokumentasi lisensi & atribusi 12 sumber data
├── scripts/
│   ├── lab.ps1                               # Wrapper CLI Windows (up, db-init, backup, status)
│   └── lab.sh                                # Wrapper CLI Linux/macOS
├── sql/postgres-init/
│   ├── 01-create.sql .. 06-ops-manifest.sql  # Skema dasar raw, stg, dq, dan ops manifest
│   ├── 07-mdm-params.sql                     # 18 parameter scoring & crosswalk 514 kab/kota
│   ├── 07b-mdm-aliases.sql                   # Kamus 15 alias BNPB/BMKG & fungsi resolusi wilayah
│   ├── 07c-fix-papua-prov-codes.sql          # Penyelarasan kode BPS pemekaran Papua (91-97)
│   ├── 08-vault.sql                          # DDL Raw Data Vault 2.0 (26 tabel)
│   ├── 09-bv.sql                             # DDL Business Vault Spasial PostGIS (10 tabel)
│   ├── 10-mart.sql                           # DDL Star Schema (6 tabel capstone)
│   ├── 11-semantic.sql                       # Semantic Views dasar untuk BI
│   └── 11b-semantic-bi-enrichment.sql        # Pengayaan region_pulau & 6 view semantic.v_dc_*
└── workspace/
    ├── hop-project/
    │   ├── pipelines/                        # 15 pipeline pl_stg_src_*.hpl (Staging + DQ Gate)
    │   ├── workflows/                        # wf_stg_master, wf_vault_load, wf_bv_load, wf_mart_load, wf_capstone_e2e_master
    │   └── sql/                              # Loader idempotent: load_vault.sql, load_bv.sql, load_mart.sql
    ├── python/
    │   ├── profiling/                        # Skrip & output profiling 12 sumber data (Fase 2)
    │   └── run_ingestion.py                  # Loader raw.* dari berkas sumber lokal
    ├── scripts/
    │   └── export_evidence.py                # Ekspor otomatis 13 sheet Excel, 13 CSV, & EVIDENCE_SUMMARY.md
    ├── sql/
    │   ├── uat_verification.sql              # Suite uji UAT-01..UAT-06 & EXPLAIN ANALYZE SLO BI
    │   └── uat_verification_output.txt       # Log bukti eksekusi UAT (6/6 PASS)
    ├── evidence/
    │   ├── DE_Capstone_Evidence_Workbook.xlsx # Workbook bukti empiris lengkap (13 sheet)
    │   ├── EVIDENCE_SUMMARY.md               # Ringkasan tabel bukti siap salin
    │   └── csv/                              # 13 file CSV hasil ekspor langsung PostgreSQL
    └── superset-exports/
        └── dashboard_dc_site_intelligence.zip # Backup ekspor dashboard 4 tab Apache Superset
```

---

## Panduan Menjalankan Ulang (*Reproducibility*)

### Prasyarat
* Docker Desktop (WSL2 backend di Windows) dengan alokasi RAM minimal 8 GB.
* File dataset mentah 12 sumber (`SRC-01` s.d. `SRC-12`) tidak disertakan di Git karena melewati batas ukuran 100 MB GitHub (khususnya `SRC-11` GeoJSON sebesar 1,63 GB). Unduh sesuai daftar di `LICENSES_AND_SOURCES.md` dan letakkan di folder data lokal sebelum menjalankan ingesti *raw*.

### 1. Clone Repositori & Siapkan `.env`
```powershell
git clone [https://github.com/kemalsatya/capstone_data_engineering.git](https://github.com/kemalsatya/capstone_data_engineering.git)
cd capstone_data_engineering
Copy-Item .env.example .env
# Edit .env dan isi LAB_DB_PASSWORD, SUPERSET_SECRET_KEY, serta SUPERSET_ADMIN_PASSWORD
```

### 2. Jalankan Infrastruktur Inti & Inisialisasi Database (`db-init`)
```powershell
docker compose up -d postgres workbench cloudbeaver
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\lab.ps1 db-init
```
Perintah `db-init` mengeksekusi seluruh **12 skrip DDL (`03` s.d. `11b`)** secara berurutan dan *idempotent*.

### 3. Ingesti Raw & Eksekusi Master Workflow Apache Hop
Setelah data mentah tersedia di volume proyek:
```powershell
# 1. Muat 15 tabel raw.* dari berkas sumber lokal
docker compose exec -T -u abc workbench python3 /config/workspace/python/run_ingestion.py

# 2. Jalankan Staging & DQ agar tabel stg.src_04 dan stg.src_11_adm2 terisi untuk populasi MDM
docker compose exec -T -u abc workbench bash -lc 'cd /opt/hop && ./hop-run.sh -j capstone-local -e docker-local -r local -s LAB_DB_PASSWORD=$LAB_DB_PASSWORD -f /config/workspace/hop-project/workflows/wf_stg_master.hwf'

# 3. Populasi ulang crosswalk MDM (514 wilayah, 15 alias, dan penyelarasan kode Papua)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\lab.ps1 db-init

# 4. Jalankan Master Workflow End-to-End (Staging+DQ -> Raw Vault -> Business Vault -> Star Schema Mart)
docker compose exec -T -u abc workbench bash -lc 'cd /opt/hop && ./hop-run.sh -j capstone-local -e docker-local -r local -s LAB_DB_PASSWORD=$LAB_DB_PASSWORD -f /config/workspace/hop-project/workflows/wf_capstone_e2e_master.hwf'
```

### 4. Verifikasi UAT & Regenerasi Evidence Workbook
```powershell
# Jalankan 6 skenario UAT & uji performa SLO kueri BI
Get-Content workspace\sql\uat_verification.sql -Raw | docker compose exec -T postgres psql -U labuser -d labdata -v ON_ERROR_STOP=1

# Ekspor ulang 13 sheet Excel, 13 CSV, dan EVIDENCE_SUMMARY.md
docker compose exec -T -u abc workbench python3 /config/workspace/scripts/export_evidence.py
```

### 5. Aktifkan Apache Superset & Impor Dashboard 4 Tab
```powershell
docker compose --profile bi up -d --build superset
Invoke-WebRequest -Uri "[http://127.0.0.1:8088/health](http://127.0.0.1:8088/health)" -UseBasicParsing
```
1. Buka `http://127.0.0.1:8088` dan login dengan `admin` serta `SUPERSET_ADMIN_PASSWORD` dari `.env`.
2. Pastikan koneksi PostgreSQL mengarah ke `postgresql+psycopg2://labuser:<LAB_DB_PASSWORD>@postgres:5432/labdata`.
3. Buka menu **Dashboards → Import Dashboard**, lalu unggah file `workspace/superset-exports/dashboard_dc_site_intelligence.zip` untuk memulihkan seluruh 4 tab:
   * **Tab 1 — Executive Site Intelligence:** KPI nasional, peta sebaran *deck.gl*, proporsi tier, dan Top 15 *Eligible*.
   * **Tab 2 — Pillar Trade-Off & Province Benchmark:** *Bubble chart* Power vs Safety, profil 4 pilar per pulau, *radar chart* Top 5, dan *benchmark* 38 provinsi.
   * **Tab 3 — Hazard Trends & Knock-Out Audit:** Tren bencana BNPB 2010–2025 dan audit 45 wilayah *Disqualified*.
   * **Tab 4 — Data Governance & Scoring Transparency:** Katalog 12 sumber & lisensi, distribusi 15.625 *warning* DQ, dan tabel 18 parameter aktif.

---

## Keputusan Arsitektur (ADR)

| ADR | Keputusan Utama |
| :---: | :--- |
| **ADR-001** | Stack *open-source* terkontainerisasi (Docker Compose) dengan pemisahan profil `bi` untuk efisiensi RAM lokal. |
| **ADR-002** | Gerbang Data Quality dua tingkat (`CRITICAL` karantina vs `WARNING` tercatat) serta pemisahan BBox gempa lepas pantai dan daratan. |
| **ADR-003** | Pemodelan berlapis **Raw Data Vault 2.0** (*insert-only*, MD5 hash key) terpisah dari **Business Vault Spasial** (`bv.*`). |
| **ADR-004** | **Star Schema** (`mart.*`) dan **6 Semantic Views** (`semantic.v_dc_*`) untuk menjamin performa kueri BI sub-detik. |
| **ADR-005** | Optimasi *spatial join* PostGIS memakai `ST_Subdivide(geom, 256)` (35.882 sub-poligon GIST) + *two-stage geodesic filter*. |
| **ADR-006** | Scoring terparameterisasi via `ops.scoring_parameters` serta crosswalk & *parent fallback* 4 provinsi pemekaran Papua (`BPS 2023+` ↔ `COD-AB 2020`). |