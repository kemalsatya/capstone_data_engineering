# Plan: Reset raw/stg/dq pipeline on PostGIS, generated from profiling drafts

## Context & decisions

The previous raw/stg/dq build (`sql/03..07`, HOP `.hpl` files, `loaders.py`, generated asset scripts) is to be discarded. The new build is driven by `workspace/python/profiling/profile_sources.py`, whose output (`profile_out/ddl_raw_draft.sql`, `ddl_staging_draft.sql`) is the source of truth and may be edited.

Decisions confirmed:
- **PostGIS**: switch the `postgres` service to `postgis/postgis:16-3.4`; store admin boundaries as real `geometry(...,4326)`.
- **Staging engine**: Apache Hop pipelines (no Python staging).
- **Scope of this pass**: `raw` + `stg` + `dq` only. `mart`/`semantic` untouched/later.
- **SRC-11 admin levels**: ingest all of adm0..adm4 (skip `adminlines`/`adminpoints`).

Target flow:
`workspace/data/Sumber Data` → Python ingestion → `raw.*` (all text + lineage) → Hop → `stg.*` (typed + geom) + `dq.quarantine_records` + `dq.quality_issues`.

---

## Step 0 — Safety: backup and wipe

1. `bash scripts/lab.sh backup` (writes `backups/labdata_<ts>.sql`).
2. Stop everything.
3. **Destructive, user-confirmed only**: `bash scripts/lab.sh destroy` (types `DELETE`) to drop `pg_data`. Required because the image changes (`postgres:16` → PostGIS) and init SQL changes.
4. Do not delete `workspace/data/`.

Files to delete as part of the reset:
- `sql/03_raw_sources.sql`, `sql/04_staging_tables.sql`, `sql/05_mart_schema.sql`, `sql/06_mart_etl.sql`, `sql/07_dq_schema_v2.sql`, `sql/clean_staging_and_dq.sql`
- `workspace/hop-project/pipelines/*.hpl` (all, including `[hapus] pl_load_sales.hpl`)
- `workspace/hop-project/workflows/*.hwf` (all, including `[hapus] wf_load_sales.hwf`)
- `workspace/hop-project/generate_stg_hop_assets.py`, `workspace/hop-project/generate_dq_hop_assets.py`
- `workspace/python/ingestion/loaders.py`, `workspace/python/run_ingestion.py` (rewritten, not kept)
- `workspace/python/ingestion/__pycache__/`

Keep:
- `workspace/python/profiling/` (profiler + `profile_out/`)
- `workspace/hop-project/project-config.json`, `environments/`, `metadata/` (connection `lab-postgres`)
- `sql/postgres-init/01-create.sql` (edited), `sql/postgres-init/02-demo.sql` (lab demo, unrelated)
- `workspace/data/`, `local/` docs

---

## Step 1 — Compose + DB scaffolding

### 1a. `compose.yaml`

Change the postgres service only:

```yaml
  postgres:
    image: postgis/postgis:16-3.4
    # keep restart, env, ports, healthcheck, volume, network unchanged
```

Keep `pg_isready` healthcheck (present in the PostGIS image). No other service changes needed. Workbench/CloudBeaver keep using host `postgres`, port `5432`.

### 1b. `sql/postgres-init/01-create.sql`

Add at the top (before table creation):

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dq;
CREATE SCHEMA IF NOT EXISTS ops;
```

Remove the demo `raw.sales_orders` / `stg.sales_orders` / `mart.daily_sales` / `semantic.v_*` objects **only if** you also update `02-demo.sql` and `lab.sh` (`seed`, `reset-demo`, `hop-demo`). Safer default: leave the demo objects as-is, they don't collide with `src_*`.

Add/extend ops tables (required by the drafts' `_batch_id` and by the profiler's manifest output):

```sql
CREATE TABLE IF NOT EXISTS ops.pipeline_runs (
  run_id        bigserial PRIMARY KEY,
  pipeline_name text NOT NULL,
  started_at    timestamptz NOT NULL DEFAULT now(),
  completed_at  timestamptz,
  status        text NOT NULL,
  rows_processed bigint,
  message       text
);

CREATE TABLE IF NOT EXISTS ops.source_file_manifest (
  source_id   text NOT NULL,
  file_name   text NOT NULL,
  file_url    text,
  sha256      text,
  bytes       bigint,
  row_count   bigint,
  license     text,
  downloaded_by text,
  registered_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (source_id, file_name)
);
```

`ops.source_file_manifest` is referenced by `profile_out/ops_manifest_inserts.sql`; load it after creation.

### 1c. `scripts/lab.sh`

Add a `db-init` command so generated DDL can be re-applied without wiping the volume:

```bash
db-init)
  for f in 03-raw.sql 04-stg.sql 05-dq.sql; do
    compose exec -T postgres psql -U labuser -d labdata \
      -v ON_ERROR_STOP=1 -f "/docker-entrypoint-initdb.d/$f"
  done
  ;;
```

Update the usage text. Fresh volumes still auto-run everything via `/docker-entrypoint-initdb.d`.

---

## Step 2 — Patch the profiler, then regenerate drafts

File: `workspace/python/profiling/profile_sources.py`

### 2a. Emit geometry (`read_geojson`, ~line 711)

Inside the feature loop, after `r = dict(ft.get("properties") or {})`:

```python
if g:
    r["geom_geojson"] = json.dumps(g, separators=(",", ":"))
```

`profile_column` already classifies strings starting with `{"type"` as `geometry_geojson` (line 981), so no type-inference change is needed.

### 2b. Include all admin levels (SRC-11 specs, ~lines 210-220)

Remove the `role="..."` argument from `idn_admin0`, `idn_admin3`, `idn_admin4` entries. Leave `idn_adminlines` and `idn_adminpoints` with `role` (out of scope). This makes `assign_tables()` emit `raw.src_11_adm0` … `raw.src_11_adm4`.

Keep the SRC-08 `export.geojson` entry's `role` (CSV is the chosen representation).

### 2c. Type overrides for codes

Add a small override map near `META_COLS` (~line 1752) and apply it in `ddl_staging()` before writing the type:

```python
TYPE_OVERRIDES = {
    "bps_kabkota_code": "text",
    "station_id": "text",
    "province_id": "text",
    "region_id": "text",
    "city_id": "text",
    "mcc": "text", "net": "text", "area": "text", "cell": "text",
    "tile_x": "numeric", "tile_y": "numeric",
}
```

Reason: codes must not lose formatting; `tile_x/tile_y` are centroids mis-inferred as `double` in the raw draft.

### 2d. PostGIS types in staging DDL (`ddl_staging`, ~line 1779)

After emitting the inferred columns, if a table has a `geometry_geojson` column, append:

```
    geom geometry(Geometry,4326)
```

If a table has a `geometry_wkt` column (SRC-08 CSV), also append `geom geometry(Geometry,4326)`.

Raw stays `geom_geojson text` / `geometry_wkt text` (no geometry type in raw — raw remains text-faithful).

### 2e. Regenerate

```bash
python3 workspace/python/profiling/profile_sources.py profile \
  --root "workspace/data/Sumber Data" --out workspace/python/profiling/profile_out
```

(Use the actual subcommand/flags from `--help`; the existing `profile_out/` shows the intended output set.)

Expected emitted raw tables:
`src_01_bmkg_gempa`, `src_02_bnpb_bencana`, `src_03_iklim_{harian,provinsi,stasiun}`, `src_04_fitur_kabkota`, `src_05_opencellid`, `src_06_ookla_tiles`, `src_07_gppd`, `src_08_osm_gardu`, `src_09_pop_isp`, `src_10_iklh_provinsi`, `src_11_adm0..adm4`, `src_12_penduduk_provinsi` (19 tables).

Verify `ddl_raw_draft.sql` now contains `geom_geojson text` for adm0..adm4 and `CREATE TABLE ... src_11_adm0`.

---

## Step 3 — Commit final DDL

Copy/adapt the regenerated drafts into init scripts (keep the `_batch_id/_src_id/_src_file/_row_no/_loaded_at` meta columns and composite PKs):

- `sql/postgres-init/03-raw.sql` ← `ddl_raw_draft.sql` (all `text`)
- `sql/postgres-init/04-stg.sql` ← `ddl_staging_draft.sql` (typed + `geom geometry(Geometry,4326)`)
- `sql/postgres-init/05-dq.sql` — new, aligned to bigint run ids:

```sql
CREATE SCHEMA IF NOT EXISTS dq;

CREATE TABLE dq.quarantine_records (
  quarantine_id bigserial PRIMARY KEY,
  run_id        bigint NOT NULL REFERENCES ops.pipeline_runs(run_id),
  source_table  text   NOT NULL,
  record_id     text,
  rule_id       text   NOT NULL,
  failed_column text,
  failed_value  text,
  reason        text   NOT NULL,
  payload_raw   jsonb  NOT NULL,
  quarantined_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE dq.quality_issues (
  issue_id      bigserial PRIMARY KEY,
  run_id        bigint NOT NULL REFERENCES ops.pipeline_runs(run_id),
  rule_id       text NOT NULL,
  source_table  text NOT NULL,
  record_id     text,
  severity      text NOT NULL CHECK (severity IN ('CRITICAL','HIGH','WARNING','INFO')),
  reason        text NOT NULL,
  detected_at   timestamptz NOT NULL DEFAULT now()
);
```

Also copy `profile_out/ops_manifest_inserts.sql` → `sql/postgres-init/06-ops-manifest.sql` (after `01-create.sql` created the table).

---

## Step 4 — Python ingestion (raw only)

Rewrite `workspace/python/run_ingestion.py` + `workspace/python/ingestion/loaders.py`.

### 4a. Run tracking (`run_ingestion.py`)

For each source file:
1. `INSERT INTO ops.pipeline_runs(pipeline_name,status) VALUES ('ingest_<table>','RUNNING') RETURNING run_id`
2. Stream rows with `_batch_id=run_id`, `_src_id`, `_src_file`, `_row_no`.
3. `UPDATE ops.pipeline_runs SET status='SUCCESS', completed_at=now(), rows_processed=<n>` (or `FAILED` + `message`).

### 4b. Loader pattern

Keep the existing, working `\copy ... FROM STDIN WITH (FORMAT CSV, ...)` over `docker compose exec -T postgres psql`:
- works without adding Python DB drivers to the Workbench,
- streams 500k+ rows,
- normalizes `NULL_LITERALS` to `\N`.

Add `_row_no` (1-based data row counter) and `run_id` to every yielded row.

### 4c. Readers

- CSV: `csv.reader`/`DictReader` as today.
- XLSX (SRC-02): existing stdlib zip+XML reader.
- BPS multi-year CSVs (SRC-10, SRC-12): one loop over all `*.csv`, derive `tahun`, skip header/footer/`INDONESIA` rows.
- GeoJSON (SRC-11 adm0..adm4): **stream** with a copy of `iter_geojson_features` (do not `json.load`). adm4 is 622 MB / 81,912 features. Emit properties + `geom_geojson`. `_row_no` = feature index.

Target column order must be taken from the raw DDL (business columns + `geom_geojson` where present) — generate the loader column list from `profile_out/staging_column_map.csv` or hardcode per table in one `TABLES` dict.

### 4d. CLI

```
python3 workspace/python/run_ingestion.py --all
python3 workspace/python/run_ingestion.py --src SRC-11
python3 workspace/python/run_ingestion.py --src SRC-01,SRC-02 --skip-loaded
```

`--skip-loaded` = new batch only if the source has no successful run for the current file sha256 (query `ops.pipeline_runs`/`ops.source_file_manifest`). Document that re-running creates a new `_batch_id` (append-only).

---

## Step 5 — Apache Hop staging pipelines

### 5a. Single generator

Replace both old generators with `workspace/hop-project/generate_hop_assets.py` driven by `workspace/hop-project/pipeline_manifest.json` (new, hand-maintained, ~19 entries). Schema:

```json
{
  "sources": [
    {
      "pipeline": "pl_stg_adm0",
      "raw_table": "raw.src_11_adm0",
      "stg_table": "stg.src_11_adm0",
      "key_columns": ["adm0_pcode"],
      "geometry": {"source": "geom_geojson", "srid": 4326},
      "bbox": null,
      "casts": {"area_sqkm": "numeric", "valid_on": "date"},
      "rules": [
        {"id": "AB-GEO-01", "severity": "CRITICAL",
         "valid": "adm0_pcode IS NOT NULL AND TRIM(adm0_pcode) <> ''"}
      ]
    }
  ]
}
```

The generator emits for each entry:
- `pipelines/pl_stg_<name>.hpl`:
  1. `TableInput` — `SELECT` with casts (`CASE WHEN col ~ '^[0-9.]+$' THEN col::numeric ELSE NULL END`), `_batch_id`, `_src_file`, `_row_no`, DQ columns (`run_id`, `source_table`, `record_id`, `dq_rule_id`, `dq_severity`, `dq_failed_column`, `dq_failed_value`, `dq_reason`, `to_jsonb(r.*)::text AS payload_raw`, `is_valid_dq`).
  2. `FilterRows` on `is_valid_dq`.
  3. `TableOutput` → `stg.src_*` (true branch).
  4. `Dummy` → `dq.quarantine_records` + `dq.quality_issues` (false branch), same pattern as the old `pl_stg_earthquakes.hpl`.
- `workflows/wf_stg_master.hwf` — sequential execution of all pipelines.

Keep the old pipeline XML style (Hop 2.x) so files open in the GUI.

### 5b. Geometry loading

For admin tables the staging `geom` column is populated in two reliable steps:
1. Hop loads `geom_geojson` (text) + attributes into `stg.src_11_adm*`.
2. A final `Execute SQL` step (per pipeline) runs:

```sql
UPDATE stg.src_11_adm0
SET geom = ST_SetSRID(ST_GeomFromGeoJSON(geom_geojson), 4326)
WHERE geom IS NULL AND geom_geojson IS NOT NULL;
```

Do the same for `stg.src_08_osm_gardu` using `geometry_wkt` + `ST_GeomFromText(...,4326)`.
Guard with `WHERE` so re-runs are idempotent per batch, or delete by `_batch_id` first.

### 5c. DQ rules

Port the rule set from the old `local/dq_rules.md` (EQ-GEO-01, DS-VAL-01, …, DM-VAL-01). Keep rule IDs/severities; adapt column names to the new snake_case staging names (`date` not `tanggal`, `tile_x/tile_y`, etc.). Add:
- `AB-GEO-02` (new): `geom IS NOT NULL` for adm0..adm4.
- Value rules from the profiler comments (e.g. `area_sqkm > 0`, IKLH `0..100`, `avg_lat_ms 0..1000`).

Regenerate `local/dq_rules.md` from the manifest so it stays in sync.

### 5d. Remove the old asset scripts

Delete `generate_stg_hop_assets.py`, `generate_dq_hop_assets.py`; fix all references in `local/walkthrough.md`, `local/dq_rules.md`, `docs/` if any.

---

## Step 6 — Docs

- `local/walkthrough.md`: rewrite the "Pencapaian" table to the 19 new pipelines, PostGIS note, and `bash scripts/lab.sh db-init`.
- `local/dq_rules.md`: regenerate from `pipeline_manifest.json`.
- Add a short `workspace/hop-project/README.md` note: connection `lab-postgres`, environment `docker-local`, and how to run `wf_stg_master.hwf`.

---

## Verification

1. Compose syntax: `docker compose -f compose.yaml config -q`
2. Fresh init: `bash scripts/lab.sh destroy && bash scripts/lab.sh up core`
3. PostGIS: `docker compose exec -T postgres psql -U labuser -d labdata -c "SELECT postgis_version();"`
4. DDL present:
   ```
   psql -c "\dt raw.*"      # expect 19 src_* tables
   psql -c "\dt stg.*"      # expect 19
   psql -c "\dt dq.*"       # 2 tables
   psql -c "\d stg.src_11_adm2"   # geom geometry(Geometry,4326)
   ```
5. Ingestion: `python3 workspace/python/run_ingestion.py --all`
6. Row-count check against `profile_summary.csv` (allow ±0 except profiled samples):
   | table | expected |
   |---|---|
   | `raw.src_01_bmkg_gempa` | 217,807 |
   | `raw.src_02_bnpb_bencana` | 28,773 |
   | `raw.src_03_iklim_harian` | 589,265 |
   | `raw.src_04_fitur_kabkota` | 514 |
   | `raw.src_05_opencellid` | 66,059 |
   | `raw.src_06_ookla_tiles` | 229,305 |
   | `raw.src_07_gppd` | 178 |
   | `raw.src_08_osm_gardu` | 2,821 |
   | `raw.src_09_pop_isp` | 34 |
   | `raw.src_10_iklh_provinsi` | 8,297 (4 years) |
   | `raw.src_11_adm0..4` | 1 / 34 / 522 / 7,069 / 81,912 |
   | `raw.src_12_penduduk_provinsi` | ~182 (5 years) |
7. Lineage: `SELECT count(DISTINCT _batch_id) FROM raw.src_01_bmkg_gempa;` ≥ 1 and `ops.pipeline_runs` rows match.
8. Hop: `hop-run -j capstone-local -r local -f /config/workspace/hop-project/workflows/wf_stg_master.hwf`
9. Staging: `SELECT count(*) FROM stg.src_11_adm2 WHERE geom IS NULL;` = 0; `SELECT ST_IsValid(geom) ...` spot-check.
10. DQ: `SELECT rule_id, severity, count(*) FROM dq.quality_issues GROUP BY 1,2 ORDER BY 3 DESC;` and compare to `local/dq_rules.md`.
11. Idempotency: run ingestion + workflow twice; confirm only a new `_batch_id` is added and staging has no duplicates beyond batches.

---

## Risks & notes

- **Volume wipe is mandatory** when changing the base image; `docker compose down` alone leaves an incompatible `pg_data`.
- **adm4 is 622 MB / 81,912 polygons.** Use streaming ingestion; expect slow load and large `stg.src_11_adm4`. If it is too heavy, drop adm4 first and keep 0-3.
- **PostGIS architecture**: confirm `postgis/postgis:16-3.4` matches the host arch (amd64/arm64 both published). If not, use `postgis/postgis:16-3.4-alpine`.
- **All-text raw is intentional.** Do not add numeric/boolean types to `raw.*`; casts live in Hop staging.
- **`_batch_id` semantics**: raw and stg are append-only per batch. Add a "latest batch" view or `DELETE FROM stg WHERE _batch_id = $run` before each load if you prefer replace semantics.
- **DQ schema change**: `dq.run_id` moves from `text` to `bigint` FK; update any dashboards/queries expecting text.
- **Demo objects**: leaving `02-demo.sql` intact keeps `lab.sh seed/reset-demo/hop-demo` working; removing them requires editing `lab.sh` in the same change.
- **Profiler sampling**: types are inferred from samples. Re-check `ddl_staging_draft.sql` for `text`-worthy codes after regeneration (see `TYPE_OVERRIDES`).
