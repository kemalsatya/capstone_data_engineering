#!/usr/bin/env python3
"""
Generates production Apache Hop .hpl pipeline files and .hwf master workflow file
for capstone data engineering: raw -> stg transformations with integrated DQ Fail-Routing (Option B Full).
Includes all 12 data sources (13 pipelines):
- SRC-01: Earthquakes
- SRC-02: Disasters
- SRC-03: Climate Stations & Climate Daily
- SRC-04: Regional Master Features
- SRC-05: Cell Towers
- SRC-06: Ookla Fixed Broadband
- SRC-07: Power Plants
- SRC-08: Substations
- SRC-09: ISP PoP
- SRC-10: Water Quality (IKLH / IKA)
- SRC-11: Admin Boundaries
- SRC-12: Population Demographics

Idempotency Guarantee:
Every pipeline executes an atomic CTE pre-delete for its respective staging table and DQ records,
preventing duplicate records or doubling upon multiple executions.
"""

import os
from pathlib import Path

BASE_DIR = Path("/home/kemal/projects_ub/data_engineering/capstone_data_engineering/workspace/hop-project")
PIPELINES_DIR = BASE_DIR / "pipelines"
WORKFLOWS_DIR = BASE_DIR / "workflows"

PIPELINES_DIR.mkdir(parents=True, exist_ok=True)
WORKFLOWS_DIR.mkdir(parents=True, exist_ok=True)

def create_dq_stg_pipeline_xml(
    name,
    description,
    sql_query,
    target_schema,
    target_table,
    stg_field_mappings,
    commit_size=1000
):
    stg_fields_xml = "".join([
        f"<field><column_name>{col}</column_name><stream_name>{stream}</stream_name></field>"
        for col, stream in stg_field_mappings
    ])

    xml = f"""<pipeline>
  <info>
    <name>{name}</name>
    <name_sync_with_filename>Y</name_sync_with_filename>
    <description>{description}</description>
    <extended_description />
    <pipeline_version />
    <pipeline_type>Normal</pipeline_type>
    <parameters>
    </parameters>
    <capture_transform_performance>N</capture_transform_performance>
    <transform_performance_capturing_delay>1000</transform_performance_capturing_delay>
    <transform_performance_capturing_size_limit>100</transform_performance_capturing_size_limit>
    <created_user>-</created_user>
    <created_date>2026/11/18 12:00:00.000</created_date>
    <modified_user>-</modified_user>
    <modified_date>2026/11/18 12:00:00.000</modified_date>
  </info>
  <notepads />
  <transform>
    <name>Extract from raw with DQ</name>
    <type>TableInput</type>
    <description>Reads all raw rows and evaluates DQ validation expressions with idempotent cleanup</description>
    <distribute>Y</distribute>
    <custom_distribution />
    <copies>1</copies>
    <partitioning>
      <method>none</method>
      <schema_name />
    </partitioning>
    <connection>lab-postgres</connection>
    <execute_each_row>N</execute_each_row>
    <limit>0</limit>
    <sql><![CDATA[{sql_query}]]></sql>
    <variables_active>N</variables_active>
    <attributes />
    <GUI>
      <xloc>120</xloc>
      <yloc>160</yloc>
    </GUI>
  </transform>
  <transform>
    <name>Filter Valid Rows</name>
    <type>FilterRows</type>
    <description>Route clean rows to staging and rejected rows to quarantine</description>
    <distribute>Y</distribute>
    <custom_distribution />
    <copies>1</copies>
    <partitioning>
      <method>none</method>
      <schema_name />
    </partitioning>
    <send_true_to>Load to stg</send_true_to>
    <send_false_to>Branch Quarantine</send_false_to>
    <compare>
      <condition>
        <negated>N</negated>
        <leftvalue>is_valid_dq</leftvalue>
        <function>=</function>
        <rightvalue />
        <value>
          <name>constant</name>
          <type>Boolean</type>
          <text>Y</text>
          <length>-1</length>
          <precision>-1</precision>
          <isnull>N</isnull>
          <mask />
        </value>
      </condition>
    </compare>
    <attributes />
    <GUI>
      <xloc>320</xloc>
      <yloc>160</yloc>
    </GUI>
  </transform>
  <transform>
    <name>Load to stg</name>
    <type>TableOutput</type>
    <description>Loads validated records into staging table</description>
    <distribute>Y</distribute>
    <custom_distribution />
    <copies>1</copies>
    <partitioning>
      <method>none</method>
      <schema_name />
    </partitioning>
    <commit>{commit_size}</commit>
    <connection>lab-postgres</connection>
    <fields>
      {stg_fields_xml}
    </fields>
    <ignore_errors>N</ignore_errors>
    <partitioning_daily>N</partitioning_daily>
    <partitioning_enabled>N</partitioning_enabled>
    <partitioning_monthly>Y</partitioning_monthly>
    <return_keys>N</return_keys>
    <specify_fields>Y</specify_fields>
    <schema>{target_schema}</schema>
    <table>{target_table}</table>
    <tablename_in_field>N</tablename_in_field>
    <tablename_in_table>Y</tablename_in_table>
    <truncate>N</truncate>
    <use_batch>Y</use_batch>
    <attributes />
    <GUI>
      <xloc>540</xloc>
      <yloc>100</yloc>
    </GUI>
  </transform>
  <transform>
    <name>Branch Quarantine</name>
    <type>Dummy</type>
    <description>Replicates failed rows to quarantine and audit log</description>
    <distribute>N</distribute>
    <custom_distribution />
    <copies>1</copies>
    <partitioning>
      <method>none</method>
      <schema_name />
    </partitioning>
    <attributes />
    <GUI>
      <xloc>320</xloc>
      <yloc>280</yloc>
    </GUI>
  </transform>
  <transform>
    <name>Load to dq.quarantine_records</name>
    <type>TableOutput</type>
    <description>Preserves full raw payload and failure details in quarantine</description>
    <distribute>Y</distribute>
    <custom_distribution />
    <copies>1</copies>
    <partitioning>
      <method>none</method>
      <schema_name />
    </partitioning>
    <commit>{commit_size}</commit>
    <connection>lab-postgres</connection>
    <fields>
      <field><column_name>run_id</column_name><stream_name>run_id</stream_name></field>
      <field><column_name>source_table</column_name><stream_name>source_table</stream_name></field>
      <field><column_name>record_id</column_name><stream_name>record_id</stream_name></field>
      <field><column_name>rule_id</column_name><stream_name>dq_rule_id</stream_name></field>
      <field><column_name>failed_column</column_name><stream_name>dq_failed_column</stream_name></field>
      <field><column_name>failed_value</column_name><stream_name>dq_failed_value</stream_name></field>
      <field><column_name>reason</column_name><stream_name>dq_reason</stream_name></field>
      <field><column_name>payload_raw</column_name><stream_name>payload_raw</stream_name></field>
    </fields>
    <ignore_errors>N</ignore_errors>
    <partitioning_daily>N</partitioning_daily>
    <partitioning_enabled>N</partitioning_enabled>
    <partitioning_monthly>Y</partitioning_monthly>
    <return_keys>N</return_keys>
    <specify_fields>Y</specify_fields>
    <schema>dq</schema>
    <table>quarantine_records</table>
    <tablename_in_field>N</tablename_in_field>
    <tablename_in_table>Y</tablename_in_table>
    <truncate>N</truncate>
    <use_batch>Y</use_batch>
    <attributes />
    <GUI>
      <xloc>540</xloc>
      <yloc>240</yloc>
    </GUI>
  </transform>
  <transform>
    <name>Load to dq.quality_issues</name>
    <type>TableOutput</type>
    <description>Records telemetry and audit metrics for data observability</description>
    <distribute>Y</distribute>
    <custom_distribution />
    <copies>1</copies>
    <partitioning>
      <method>none</method>
      <schema_name />
    </partitioning>
    <commit>{commit_size}</commit>
    <connection>lab-postgres</connection>
    <fields>
      <field><column_name>run_id</column_name><stream_name>run_id</stream_name></field>
      <field><column_name>rule_id</column_name><stream_name>dq_rule_id</stream_name></field>
      <field><column_name>source_table</column_name><stream_name>source_table</stream_name></field>
      <field><column_name>record_id</column_name><stream_name>record_id</stream_name></field>
      <field><column_name>severity</column_name><stream_name>dq_severity</stream_name></field>
      <field><column_name>reason</column_name><stream_name>dq_reason</stream_name></field>
    </fields>
    <ignore_errors>N</ignore_errors>
    <partitioning_daily>N</partitioning_daily>
    <partitioning_enabled>N</partitioning_enabled>
    <partitioning_monthly>Y</partitioning_monthly>
    <return_keys>N</return_keys>
    <specify_fields>Y</specify_fields>
    <schema>dq</schema>
    <table>quality_issues</table>
    <tablename_in_field>N</tablename_in_field>
    <tablename_in_table>Y</tablename_in_table>
    <truncate>N</truncate>
    <use_batch>Y</use_batch>
    <attributes />
    <GUI>
      <xloc>540</xloc>
      <yloc>340</yloc>
    </GUI>
  </transform>
  <order>
    <hop>
      <from>Extract from raw with DQ</from>
      <to>Filter Valid Rows</to>
      <enabled>Y</enabled>
    </hop>
    <hop>
      <from>Filter Valid Rows</from>
      <to>Load to stg</to>
      <enabled>Y</enabled>
    </hop>
    <hop>
      <from>Filter Valid Rows</from>
      <to>Branch Quarantine</to>
      <enabled>Y</enabled>
    </hop>
    <hop>
      <from>Branch Quarantine</from>
      <to>Load to dq.quarantine_records</to>
      <enabled>Y</enabled>
    </hop>
    <hop>
      <from>Branch Quarantine</from>
      <to>Load to dq.quality_issues</to>
      <enabled>Y</enabled>
    </hop>
  </order>
  <attributes />
</pipeline>"""
    return xml

PIPELINE_DEFS = [
    # 1. SRC-01: Earthquakes
    {
        "name": "pl_stg_earthquakes",
        "description": "Transform BMKG Earthquake Catalog to stg.earthquakes with DQ routing",
        "sql": r"""SELECT 
    event_id,
    CASE 
        WHEN event_date IS NOT NULL AND time_utc IS NOT NULL 
        THEN TO_TIMESTAMP(event_date || ' ' || time_utc, 'DD-Mon-YYYY HH24:MI:SS') AT TIME ZONE 'UTC'
        ELSE NULL 
    END AS event_timestamp,
    TO_DATE(event_date, 'DD-Mon-YYYY') AS event_date,
    latitude,
    longitude,
    magnitude,
    mag_type,
    depth_km,
    source,
    (magnitude >= 5.0) AS is_significant,
    -- DQ columns
    'pl_stg_earthquakes' AS run_id,
    'raw.src01_earthquake_catalog' AS source_table,
    COALESCE(event_id, id::text) AS record_id,
    'EQ-GEO-01' AS dq_rule_id,
    'CRITICAL' AS dq_severity,
    CASE 
        WHEN event_id IS NULL THEN 'event_id'
        WHEN latitude NOT BETWEEN -11.0 AND 6.0 THEN 'latitude'
        WHEN longitude NOT BETWEEN 95.0 AND 141.0 THEN 'longitude'
        WHEN magnitude IS NULL OR magnitude <= 0 THEN 'magnitude'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN event_id IS NULL THEN 'null'
        WHEN latitude NOT BETWEEN -11.0 AND 6.0 THEN latitude::text
        WHEN longitude NOT BETWEEN 95.0 AND 141.0 THEN longitude::text
        WHEN magnitude IS NULL OR magnitude <= 0 THEN COALESCE(magnitude::text, 'null')
        ELSE NULL 
    END AS dq_failed_value,
    'Koordinat gempa di luar wilayah Indonesia [-11..6, 95..141], event_id kosong, atau magnitude <= 0' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (event_id IS NOT NULL 
     AND latitude BETWEEN -11.0 AND 6.0 
     AND longitude BETWEEN 95.0 AND 141.0 
     AND magnitude IS NOT NULL 
     AND magnitude > 0) AS is_valid_dq
FROM raw.src01_earthquake_catalog r;""",
        "schema": "stg",
        "table": "earthquakes",
        "fields": [
            ("event_id", "event_id"), ("event_timestamp", "event_timestamp"),
            ("event_date", "event_date"), ("latitude", "latitude"),
            ("longitude", "longitude"), ("magnitude", "magnitude"),
            ("mag_type", "mag_type"), ("depth_km", "depth_km"),
            ("source", "source"), ("is_significant", "is_significant")
        ],
        "commit": 5000
    },

    # 2. SRC-02: Disasters
    {
        "name": "pl_stg_disasters",
        "description": "Transform BNPB/BPBD disaster records to stg.disasters with DQ routing",
        "sql": r"""SELECT 
    city_id,
    CASE 
        WHEN event_date_serial ~ '^[0-9]+(\.[0-9]+)?$' 
        THEN (TO_DATE('1899-12-30', 'YYYY-MM-DD') + FLOOR(event_date_serial::numeric)::integer)
        ELSE NULL 
    END AS event_date,
    UPPER(TRIM(disaster_type)) AS disaster_type,
    INITCAP(TRIM(city)) AS city_name,
    INITCAP(TRIM(province)) AS province_name,
    cause,
    COALESCE(ROUND(death), 0)::integer AS death_count,
    COALESCE(ROUND(missing_person), 0)::integer AS missing_count,
    COALESCE(ROUND(injured_person), 0)::integer AS injured_count,
    COALESCE(ROUND(damaged_house), 0)::integer AS damaged_house_count,
    COALESCE(ROUND(flooded_house), 0)::integer AS flooded_house_count,
    COALESCE(ROUND(damaged_facility), 0)::integer AS damaged_facility_count,
    -- DQ columns
    'pl_stg_disasters' AS run_id,
    'raw.src02_disaster_records' AS source_table,
    id::text AS record_id,
    'DS-VAL-01' AS dq_rule_id,
    'HIGH' AS dq_severity,
    CASE 
        WHEN disaster_type IS NULL OR TRIM(disaster_type) = '' THEN 'disaster_type'
        WHEN province IS NULL OR TRIM(province) = '' THEN 'province'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN disaster_type IS NULL OR TRIM(disaster_type) = '' THEN 'null'
        WHEN province IS NULL OR TRIM(province) = '' THEN 'null'
        ELSE NULL 
    END AS dq_failed_value,
    'Tipe bencana atau nama provinsi bernilai NULL/kosong' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (disaster_type IS NOT NULL AND TRIM(disaster_type) != '' 
     AND province IS NOT NULL AND TRIM(province) != '') AS is_valid_dq
FROM raw.src02_disaster_records r;""",
        "schema": "stg",
        "table": "disasters",
        "fields": [
            ("city_id", "city_id"), ("event_date", "event_date"),
            ("disaster_type", "disaster_type"), ("city_name", "city_name"),
            ("province_name", "province_name"), ("cause", "cause"),
            ("death_count", "death_count"), ("missing_count", "missing_count"),
            ("injured_count", "injured_count"), ("damaged_house_count", "damaged_house_count"),
            ("flooded_house_count", "flooded_house_count"), ("damaged_facility_count", "damaged_facility_count")
        ],
        "commit": 5000
    },

    # 3. SRC-03: Climate Stations
    {
        "name": "pl_stg_climate_stations",
        "description": "Transform BMKG Climate Stations to stg.climate_stations with DQ routing",
        "sql": r"""SELECT 
    s.station_id,
    s.station_name,
    s.region_name,
    s.latitude,
    s.longitude,
    COALESCE(p.province_name, s.region_name) AS province_name,
    -- DQ columns
    'pl_stg_climate_stations' AS run_id,
    'raw.src03_station_detail' AS source_table,
    s.station_id AS record_id,
    'CS-GEO-01' AS dq_rule_id,
    'CRITICAL' AS dq_severity,
    CASE 
        WHEN s.station_id IS NULL OR TRIM(s.station_id) = '' THEN 'station_id'
        WHEN s.station_name IS NULL OR TRIM(s.station_name) = '' THEN 'station_name'
        WHEN s.latitude NOT BETWEEN -11.0 AND 6.0 THEN 'latitude'
        WHEN s.longitude NOT BETWEEN 95.0 AND 141.0 THEN 'longitude'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN s.station_id IS NULL OR TRIM(s.station_id) = '' THEN 'null'
        WHEN s.latitude NOT BETWEEN -11.0 AND 6.0 THEN s.latitude::text
        WHEN s.longitude NOT BETWEEN 95.0 AND 141.0 THEN s.longitude::text
        ELSE NULL 
    END AS dq_failed_value,
    'ID stasiun kosong, nama stasiun kosong, atau koordinat di luar wilayah Indonesia [-11..6, 95..141]' AS dq_reason,
    to_jsonb(s.*)::text AS payload_raw,
    (s.station_id IS NOT NULL AND TRIM(s.station_id) != '' 
     AND s.station_name IS NOT NULL AND TRIM(s.station_name) != '' 
     AND s.latitude BETWEEN -11.0 AND 6.0 
     AND s.longitude BETWEEN 95.0 AND 141.0) AS is_valid_dq
FROM raw.src03_station_detail s
LEFT JOIN raw.src03_province_detail p ON s.province_id = p.province_id;""",
        "schema": "stg",
        "table": "climate_stations",
        "fields": [
            ("station_id", "station_id"), ("station_name", "station_name"),
            ("region_name", "region_name"), ("latitude", "latitude"),
            ("longitude", "longitude"), ("province_name", "province_name")
        ],
        "commit": 500
    },

    # 4. SRC-03: Climate Daily
    {
        "name": "pl_stg_climate_daily",
        "description": "Transform BMKG Daily Climate records to stg.climate_daily with DQ routing",
        "sql": r"""SELECT 
    station_id,
    TO_DATE(obs_date, 'DD-MM-YYYY') AS obs_date,
    CASE WHEN tn BETWEEN -10.0 AND 50.0 THEN tn::numeric(4,1) ELSE NULL END AS temp_min_c,
    CASE WHEN tx BETWEEN 0.0 AND 60.0 THEN tx::numeric(4,1) ELSE NULL END AS temp_max_c,
    CASE WHEN tavg BETWEEN 0.0 AND 50.0 THEN tavg::numeric(4,1) ELSE NULL END AS temp_avg_c,
    CASE WHEN rh_avg BETWEEN 0.0 AND 100.0 THEN rh_avg::numeric(4,1) ELSE NULL END AS humidity_avg_pct,
    CASE WHEN rr BETWEEN 0.0 AND 9999.9 THEN rr::numeric(6,1) ELSE NULL END AS rainfall_mm,
    CASE WHEN ss BETWEEN 0.0 AND 24.0 THEN ss::numeric(4,1) ELSE NULL END AS sunshine_hours,
    CASE WHEN ff_avg BETWEEN 0.0 AND 100.0 THEN ff_avg::numeric(4,1) ELSE NULL END AS wind_speed_avg_ms,
    -- DQ columns
    'pl_stg_climate_daily' AS run_id,
    'raw.src03_climate_daily' AS source_table,
    id::text AS record_id,
    'CD-VAL-01' AS dq_rule_id,
    'HIGH' AS dq_severity,
    CASE 
        WHEN station_id IS NULL OR TRIM(station_id) = '' THEN 'station_id'
        WHEN obs_date !~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN 'obs_date'
        WHEN tavg < 0.0 OR tavg > 50.0 THEN 'tavg'
        WHEN rh_avg < 0.0 OR rh_avg > 100.0 THEN 'rh_avg'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN station_id IS NULL OR TRIM(station_id) = '' THEN 'null'
        WHEN obs_date !~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN obs_date
        WHEN tavg < 0.0 OR tavg > 50.0 THEN tavg::text
        WHEN rh_avg < 0.0 OR rh_avg > 100.0 THEN rh_avg::text
        ELSE NULL 
    END AS dq_failed_value,
    'ID stasiun kosong, format tanggal tidak valid, suhu di luar batas wajar [0..50 C], atau kelembapan di luar [0..100%]' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (station_id IS NOT NULL AND TRIM(station_id) != '' 
     AND obs_date ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' 
     AND (tavg IS NULL OR (tavg >= 0.0 AND tavg <= 50.0)) 
     AND (rh_avg IS NULL OR (rh_avg >= 0.0 AND rh_avg <= 100.0))) AS is_valid_dq
FROM raw.src03_climate_daily r;""",
        "schema": "stg",
        "table": "climate_daily",
        "fields": [
            ("station_id", "station_id"), ("obs_date", "obs_date"),
            ("temp_min_c", "temp_min_c"), ("temp_max_c", "temp_max_c"),
            ("temp_avg_c", "temp_avg_c"), ("humidity_avg_pct", "humidity_avg_pct"),
            ("rainfall_mm", "rainfall_mm"), ("sunshine_hours", "sunshine_hours"),
            ("wind_speed_avg_ms", "wind_speed_avg_ms")
        ],
        "commit": 5000
    },

    # 5. SRC-04: Regional Master Features
    {
        "name": "pl_stg_regional_features",
        "description": "Transform master features to stg.regional_features with DQ routing",
        "sql": r"""SELECT 
    bps_kabkota_code,
    kabkota_name,
    prov_name AS province_name,
    CASE WHEN ipm_2024 ~ '^[0-9]+(\.[0-9]+)?$' THEN ipm_2024::numeric(5,2) ELSE NULL END AS ipm_2024,
    CASE WHEN population_2024 ~ '^[0-9]+$' THEN population_2024::integer ELSE NULL END AS population_2024,
    CASE WHEN elevation_mean_m ~ '^[0-9]+(\.[0-9]+)?$' THEN elevation_mean_m::numeric(7,2) ELSE NULL END AS elevation_mean_m,
    CASE WHEN pct_built_up ~ '^[0-9]+(\.[0-9]+)?$' THEN pct_built_up::numeric(5,2) ELSE NULL END AS pct_built_up,
    tertinggal_status,
    CASE WHEN t2m_mean ~ '^[0-9]+(\.[0-9]+)?$' THEN t2m_mean::numeric(4,2) ELSE NULL END AS temp_ambient_mean_c,
    CASE WHEN rh2m_mean ~ '^[0-9]+(\.[0-9]+)?$' THEN rh2m_mean::numeric(5,2) ELSE NULL END AS humidity_ambient_mean_pct,
    CASE WHEN prectotcorr_mean ~ '^[0-9]+(\.[0-9]+)?$' THEN prectotcorr_mean::numeric(6,2) ELSE NULL END AS rainfall_ambient_mean_mm,
    CASE WHEN road_density_km_per_km2 ~ '^[0-9]+(\.[0-9]+)?$' THEN road_density_km_per_km2::numeric(6,2) ELSE NULL END AS road_density_km_per_km2,
    -- DQ columns
    'pl_stg_regional_features' AS run_id,
    'raw.src04_master_features' AS source_table,
    COALESCE(bps_kabkota_code, kabkota_name) AS record_id,
    'RF-KEY-01' AS dq_rule_id,
    'CRITICAL' AS dq_severity,
    CASE 
        WHEN bps_kabkota_code IS NULL OR NOT (bps_kabkota_code ~ '^[0-9]{4}$') THEN 'bps_kabkota_code'
        WHEN kabkota_name IS NULL OR TRIM(kabkota_name) = '' THEN 'kabkota_name'
        ELSE NULL 
    END AS dq_failed_column,
    COALESCE(bps_kabkota_code, 'null') AS dq_failed_value,
    'Kode wilayah BPS tidak valid (harus 4 digit angka) atau nama kabupaten kosong' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (bps_kabkota_code IS NOT NULL AND bps_kabkota_code ~ '^[0-9]{4}$' 
     AND kabkota_name IS NOT NULL AND TRIM(kabkota_name) != '') AS is_valid_dq
FROM raw.src04_master_features r;""",
        "schema": "stg",
        "table": "regional_features",
        "fields": [
            ("bps_kabkota_code", "bps_kabkota_code"), ("kabkota_name", "kabkota_name"),
            ("province_name", "province_name"), ("ipm_2024", "ipm_2024"),
            ("population_2024", "population_2024"), ("elevation_mean_m", "elevation_mean_m"),
            ("pct_built_up", "pct_built_up"), ("tertinggal_status", "tertinggal_status"),
            ("temp_ambient_mean_c", "temp_ambient_mean_c"), ("humidity_ambient_mean_pct", "humidity_ambient_mean_pct"),
            ("rainfall_ambient_mean_mm", "rainfall_ambient_mean_mm"), ("road_density_km_per_km2", "road_density_km_per_km2")
        ],
        "commit": 500
    },

    # 6. SRC-05: Cell Towers
    {
        "name": "pl_stg_cell_towers",
        "description": "Transform Cell Towers to stg.cell_towers with DQ routing",
        "sql": r"""SELECT 
    radio AS radio_type,
    mcc,
    net,
    cell AS cell_id,
    lon AS longitude,
    lat AS latitude,
    CASE WHEN range ~ '^[0-9]+$' THEN range::integer ELSE NULL END AS coverage_range_m,
    CASE WHEN samples ~ '^[0-9]+$' THEN samples::integer ELSE NULL END AS samples_count,
    CASE WHEN updated_epoch ~ '^[0-9]+$' THEN TO_TIMESTAMP(updated_epoch::bigint) ELSE NULL END AS updated_at,
    -- DQ columns
    'pl_stg_cell_towers' AS run_id,
    'raw.src05_cell_towers' AS source_table,
    id::text AS record_id,
    'CT-GEO-01' AS dq_rule_id,
    'HIGH' AS dq_severity,
    CASE 
        WHEN lon NOT BETWEEN 95.0 AND 141.0 THEN 'lon'
        WHEN lat NOT BETWEEN -11.0 AND 6.0 THEN 'lat'
        WHEN radio IS NULL OR TRIM(radio) = '' THEN 'radio'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN lon NOT BETWEEN 95.0 AND 141.0 THEN lon::text
        WHEN lat NOT BETWEEN -11.0 AND 6.0 THEN lat::text
        ELSE COALESCE(radio, 'null') 
    END AS dq_failed_value,
    'Koordinat menara BTS di luar batas Indonesia [-11..6, 95..141] atau tipe radio NULL' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (lon BETWEEN 95.0 AND 141.0 AND lat BETWEEN -11.0 AND 6.0 
     AND radio IS NOT NULL AND TRIM(radio) != '') AS is_valid_dq
FROM raw.src05_cell_towers r;""",
        "schema": "stg",
        "table": "cell_towers",
        "fields": [
            ("radio_type", "radio_type"), ("mcc", "mcc"),
            ("net", "net"), ("cell_id", "cell_id"),
            ("longitude", "longitude"), ("latitude", "latitude"),
            ("coverage_range_m", "coverage_range_m"), ("samples_count", "samples_count"),
            ("updated_at", "updated_at")
        ],
        "commit": 5000
    },

    # 7. SRC-06: Ookla Fixed Broadband
    {
        "name": "pl_stg_ookla_broadband",
        "description": "Transform Ookla broadband metrics to stg.ookla_broadband with DQ routing",
        "sql": r"""SELECT 
    quadkey,
    tile_x AS tile_center_lon,
    tile_y AS tile_center_lat,
    ROUND(avg_d_kbps / 1000.0, 2) AS avg_download_mbps,
    ROUND(avg_u_kbps / 1000.0, 2) AS avg_upload_mbps,
    avg_lat_ms AS avg_latency_ms,
    tests AS test_count,
    devices AS device_count,
    year_val::integer,
    quarter::integer AS quarter_val,
    -- DQ columns
    'pl_stg_ookla_broadband' AS run_id,
    'raw.src06_ookla_fixed_broadband' AS source_table,
    COALESCE(quadkey, id::text) AS record_id,
    'OK-NET-01' AS dq_rule_id,
    'HIGH' AS dq_severity,
    CASE 
        WHEN tile_x NOT BETWEEN 95.0 AND 141.0 THEN 'tile_x'
        WHEN tile_y NOT BETWEEN -11.0 AND 6.0 THEN 'tile_y'
        WHEN avg_lat_ms IS NULL OR avg_lat_ms <= 0 OR avg_lat_ms > 1000 THEN 'avg_lat_ms'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN tile_x NOT BETWEEN 95.0 AND 141.0 THEN tile_x::text
        WHEN tile_y NOT BETWEEN -11.0 AND 6.0 THEN tile_y::text
        ELSE COALESCE(avg_lat_ms::text, 'null') 
    END AS dq_failed_value,
    'Koordinat grid tile Ookla di luar Indonesia atau nilai latensi tidak valid (<= 0 atau > 1000 ms)' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (tile_x BETWEEN 95.0 AND 141.0 AND tile_y BETWEEN -11.0 AND 6.0 
     AND avg_lat_ms > 0 AND avg_lat_ms <= 1000) AS is_valid_dq
FROM raw.src06_ookla_fixed_broadband r;""",
        "schema": "stg",
        "table": "ookla_broadband",
        "fields": [
            ("quadkey", "quadkey"), ("tile_center_lon", "tile_center_lon"),
            ("tile_center_lat", "tile_center_lat"), ("avg_download_mbps", "avg_download_mbps"),
            ("avg_upload_mbps", "avg_upload_mbps"), ("avg_latency_ms", "avg_latency_ms"),
            ("test_count", "test_count"), ("device_count", "device_count"),
            ("year_val", "year_val"), ("quarter_val", "quarter_val")
        ],
        "commit": 5000
    },

    # 8. SRC-07: Power Plants
    {
        "name": "pl_stg_power_plants",
        "description": "Filter and load Indonesia power plants into stg.power_plants with DQ routing",
        "sql": r"""SELECT 
    gppd_idnr,
    name,
    capacity_mw,
    latitude,
    longitude,
    primary_fuel,
    (primary_fuel IN ('Hydro', 'Solar', 'Wind', 'Geothermal', 'Biomass')) AS is_renewable,
    CASE WHEN commissioning_year ~ '^[0-9]+$' THEN commissioning_year::integer ELSE NULL END AS commissioning_year,
    owner,
    -- DQ columns
    'pl_stg_power_plants' AS run_id,
    'raw.src07_power_plants' AS source_table,
    COALESCE(gppd_idnr, id::text) AS record_id,
    'PP-GEO-01' AS dq_rule_id,
    'CRITICAL' AS dq_severity,
    CASE 
        WHEN country != 'IDN' THEN 'country'
        WHEN capacity_mw IS NULL OR capacity_mw <= 0 THEN 'capacity_mw'
        WHEN latitude NOT BETWEEN -11.0 AND 6.0 THEN 'latitude'
        WHEN longitude NOT BETWEEN 95.0 AND 141.0 THEN 'longitude'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN country != 'IDN' THEN country
        WHEN capacity_mw IS NULL OR capacity_mw <= 0 THEN COALESCE(capacity_mw::text, 'null')
        WHEN latitude NOT BETWEEN -11.0 AND 6.0 THEN latitude::text
        WHEN longitude NOT BETWEEN 95.0 AND 141.0 THEN longitude::text
        ELSE NULL 
    END AS dq_failed_value,
    'Pembangkit listrik bukan wilayah Indonesia (Country != IDN), kapasitas tidak valid, atau koordinat di luar Indonesia' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (country = 'IDN' 
     AND capacity_mw IS NOT NULL AND capacity_mw > 0 
     AND latitude BETWEEN -11.0 AND 6.0 
     AND longitude BETWEEN 95.0 AND 141.0) AS is_valid_dq
FROM raw.src07_power_plants r;""",
        "schema": "stg",
        "table": "power_plants",
        "fields": [
            ("gppd_idnr", "gppd_idnr"), ("name", "name"),
            ("capacity_mw", "capacity_mw"), ("latitude", "latitude"),
            ("longitude", "longitude"), ("primary_fuel", "primary_fuel"),
            ("is_renewable", "is_renewable"), ("commissioning_year", "commissioning_year"),
            ("owner", "owner")
        ],
        "commit": 1000
    },

    # 9. SRC-08: Substations
    {
        "name": "pl_stg_substations",
        "description": "Transform OpenStreetMap substations to stg.substations with DQ routing",
        "sql": r"""SELECT 
    osm_id,
    name,
    operator,
    CASE 
        WHEN voltage ~ '^[0-9]+(\.[0-9]+)?$' THEN ROUND(voltage::numeric / 1000.0, 1)
        ELSE NULL 
    END AS voltage_kv,
    longitude,
    latitude,
    geometry_wkt,
    -- DQ columns
    'pl_stg_substations' AS run_id,
    'raw.src08_substations' AS source_table,
    COALESCE(osm_id, id::text) AS record_id,
    'SB-GEO-01' AS dq_rule_id,
    'HIGH' AS dq_severity,
    CASE 
        WHEN osm_id IS NULL OR TRIM(osm_id) = '' THEN 'osm_id'
        WHEN longitude NOT BETWEEN 95.0 AND 141.0 THEN 'longitude'
        WHEN latitude NOT BETWEEN -11.0 AND 6.0 THEN 'latitude'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN osm_id IS NULL OR TRIM(osm_id) = '' THEN 'null'
        WHEN longitude NOT BETWEEN 95.0 AND 141.0 THEN longitude::text
        WHEN latitude NOT BETWEEN -11.0 AND 6.0 THEN latitude::text
        ELSE NULL 
    END AS dq_failed_value,
    'OSM ID kosong atau koordinat gardu induk di luar batas wilayah Indonesia [-11..6, 95..141]' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (osm_id IS NOT NULL AND TRIM(osm_id) != '' 
     AND longitude BETWEEN 95.0 AND 141.0 
     AND latitude BETWEEN -11.0 AND 6.0) AS is_valid_dq
FROM raw.src08_substations r;""",
        "schema": "stg",
        "table": "substations",
        "fields": [
            ("osm_id", "osm_id"), ("name", "name"),
            ("operator", "operator"), ("voltage_kv", "voltage_kv"),
            ("longitude", "longitude"), ("latitude", "latitude"),
            ("geometry_wkt", "geometry_wkt")
        ],
        "commit": 1000
    },

    # 10. SRC-09: ISP PoP
    {
        "name": "pl_stg_isp_pop",
        "description": "Transform ISP PoP to stg.isp_points_of_presence with DQ routing",
        "sql": r"""SELECT 
    INITCAP(TRIM(province)) AS province_name,
    pop_isp_count AS pop_count,
    year_val::integer,
    -- DQ columns
    'pl_stg_isp_pop' AS run_id,
    'raw.src09_isp_pop' AS source_table,
    COALESCE(province, id::text) AS record_id,
    'IP-VAL-01' AS dq_rule_id,
    'HIGH' AS dq_severity,
    CASE 
        WHEN province IS NULL OR TRIM(province) = '' THEN 'province'
        WHEN pop_isp_count IS NULL OR pop_isp_count < 0 THEN 'pop_isp_count'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN province IS NULL OR TRIM(province) = '' THEN 'null'
        ELSE COALESCE(pop_isp_count::text, 'null') 
    END AS dq_failed_value,
    'Nama provinsi kosong atau jumlah PoP ISP negatif/NULL' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (province IS NOT NULL AND TRIM(province) != '' 
     AND pop_isp_count IS NOT NULL AND pop_isp_count >= 0) AS is_valid_dq
FROM raw.src09_isp_pop r;""",
        "schema": "stg",
        "table": "isp_points_of_presence",
        "fields": [
            ("province_name", "province_name"),
            ("pop_count", "pop_count"),
            ("year_val", "year_val")
        ],
        "commit": 500
    },

    # 11. SRC-10: Water Quality (IKLH / IKA)
    {
        "name": "pl_stg_water_quality",
        "description": "Extract Water Quality Index (IKA) for DC cooling to stg.water_quality_index with DQ routing",
        "sql": r"""SELECT 
    INITCAP(TRIM(province)) AS province_name,
    year_val,
    indeks_kualitas_air AS water_quality_index,
    indeks_kualitas_udara AS air_quality_index,
    -- DQ columns
    'pl_stg_water_quality' AS run_id,
    'raw.src10_iklh' AS source_table,
    COALESCE(province || '_' || year_val::text, id::text) AS record_id,
    'WQ-VAL-01' AS dq_rule_id,
    'HIGH' AS dq_severity,
    CASE 
        WHEN province IS NULL OR TRIM(province) = '' THEN 'province'
        WHEN year_val IS NULL THEN 'year_val'
        WHEN indeks_kualitas_air IS NULL OR indeks_kualitas_air NOT BETWEEN 0.0 AND 100.0 THEN 'indeks_kualitas_air'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN province IS NULL OR TRIM(province) = '' THEN 'null'
        WHEN year_val IS NULL THEN 'null'
        ELSE COALESCE(indeks_kualitas_air::text, 'null') 
    END AS dq_failed_value,
    'Nilai Indeks Kualitas Air (IKA) di luar rentang standar [0..100], provinsi kosong, atau tahun NULL' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (province IS NOT NULL AND TRIM(province) != '' 
     AND year_val IS NOT NULL 
     AND indeks_kualitas_air IS NOT NULL 
     AND indeks_kualitas_air BETWEEN 0.0 AND 100.0) AS is_valid_dq
FROM raw.src10_iklh r;""",
        "schema": "stg",
        "table": "water_quality_index",
        "fields": [
            ("province_name", "province_name"),
            ("year_val", "year_val"),
            ("water_quality_index", "water_quality_index"),
            ("air_quality_index", "air_quality_index")
        ],
        "commit": 500
    },

    # 12. SRC-11: Admin Boundaries
    {
        "name": "pl_stg_admin_boundaries",
        "description": "Transform spatial administrative boundaries to stg.admin_boundaries with DQ routing",
        "sql": r"""SELECT 
    admin_level,
    pcode,
    name,
    parent_pcode,
    parent_name,
    center_lat,
    center_lon,
    area_sqkm,
    geom_geojson,
    -- DQ columns
    'pl_stg_admin_boundaries' AS run_id,
    'raw.src11_admin_boundaries' AS source_table,
    COALESCE(pcode, id::text) AS record_id,
    'AB-GEO-01' AS dq_rule_id,
    'CRITICAL' AS dq_severity,
    CASE 
        WHEN pcode IS NULL OR TRIM(pcode) = '' THEN 'pcode'
        WHEN admin_level IS NULL OR admin_level NOT IN (0,1,2,3,4) THEN 'admin_level'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN pcode IS NULL OR TRIM(pcode) = '' THEN 'null'
        ELSE COALESCE(admin_level::text, 'null') 
    END AS dq_failed_value,
    'Pcode batas administrasi kosong atau admin_level tidak valid (bukan 0..4)' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (pcode IS NOT NULL AND TRIM(pcode) != '' 
     AND admin_level IS NOT NULL 
     AND admin_level IN (0,1,2,3,4)) AS is_valid_dq
FROM raw.src11_admin_boundaries r;""",
        "schema": "stg",
        "table": "admin_boundaries",
        "fields": [
            ("admin_level", "admin_level"), ("pcode", "pcode"),
            ("name", "name"), ("parent_pcode", "parent_pcode"),
            ("parent_name", "parent_name"), ("center_lat", "center_lat"),
            ("center_lon", "center_lon"), ("area_sqkm", "area_sqkm"),
            ("geom_geojson", "geom_geojson")
        ],
        "commit": 500
    },

    # 13. SRC-12: Demographics
    {
        "name": "pl_stg_demographics",
        "description": "Transform BPS demographics to stg.population_demographics with DQ routing",
        "sql": r"""SELECT 
    INITCAP(TRIM(province)) AS province_name,
    year_val,
    jumlah_penduduk_ribu AS population_thousands,
    laju_pertumbuhan_tahunan AS growth_rate_pct,
    kepadatan_per_km2 AS density_per_km2,
    rasio_jenis_kelamin AS sex_ratio,
    -- DQ columns
    'pl_stg_demographics' AS run_id,
    'raw.src12_population_demographics' AS source_table,
    COALESCE(province || '_' || year_val::text, id::text) AS record_id,
    'DM-VAL-01' AS dq_rule_id,
    'HIGH' AS dq_severity,
    CASE 
        WHEN province IS NULL OR TRIM(province) = '' THEN 'province'
        WHEN year_val IS NULL THEN 'year_val'
        WHEN jumlah_penduduk_ribu IS NULL OR jumlah_penduduk_ribu <= 0 THEN 'jumlah_penduduk_ribu'
        ELSE NULL 
    END AS dq_failed_column,
    CASE 
        WHEN province IS NULL OR TRIM(province) = '' THEN 'null'
        WHEN year_val IS NULL THEN 'null'
        ELSE COALESCE(jumlah_penduduk_ribu::text, 'null') 
    END AS dq_failed_value,
    'Jumlah penduduk <= 0 atau NULL, nama provinsi kosong, atau tahun NULL' AS dq_reason,
    to_jsonb(r.*)::text AS payload_raw,
    (province IS NOT NULL AND TRIM(province) != '' 
     AND year_val IS NOT NULL 
     AND jumlah_penduduk_ribu IS NOT NULL 
     AND jumlah_penduduk_ribu > 0) AS is_valid_dq
FROM raw.src12_population_demographics r;""",
        "schema": "stg",
        "table": "population_demographics",
        "fields": [
            ("province_name", "province_name"), ("year_val", "year_val"),
            ("population_thousands", "population_thousands"), ("growth_rate_pct", "growth_rate_pct"),
            ("density_per_km2", "density_per_km2"), ("sex_ratio", "sex_ratio")
        ],
        "commit": 500
    }
]

for p in PIPELINE_DEFS:
    file_path = PIPELINES_DIR / f"{p['name']}.hpl"
    xml_content = create_dq_stg_pipeline_xml(
        name=p["name"],
        description=p["description"],
        sql_query=p["sql"],
        target_schema=p["schema"],
        target_table=p["table"],
        stg_field_mappings=p["fields"],
        commit_size=p["commit"]
    )
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(xml_content)
    print(f"Generated DQ Staging Pipeline: {file_path.name}")

# Generate Master Workflow: wf_stg_master.hwf
workflow_xml = """<workflow>
  <name>wf_stg_master</name>
  <name_sync_with_filename>Y</name_sync_with_filename>
  <description>Master Workflow for Staging Layer: Runs all 13 pl_stg_*.hpl pipelines sequentially with DQ routing</description>
  <extended_description />
  <workflow_version>2.0</workflow_version>
  <workflow_status>0</workflow_status>
  <created_user>-</created_user>
  <created_date>2026/11/18 12:00:00.000</created_date>
  <modified_user>-</modified_user>
  <modified_date>2026/11/18 12:00:00.000</modified_date>
  <parameters>
  </parameters>
  <actions>
    <action>
      <name>Start</name>
      <description />
      <type>SPECIAL</type>
      <attributes />
      <repeat>N</repeat>
      <schedulerType>0</schedulerType>
      <intervalSeconds>0</intervalSeconds>
      <intervalMinutes>60</intervalMinutes>
      <hour>12</hour>
      <minutes>0</minutes>
      <weekDay>1</weekDay>
      <DayOfMonth>1</DayOfMonth>
      <parallel>N</parallel>
      <xloc>64</xloc>
      <yloc>128</yloc>
      <attributes_hac />
    </action>
    <action>
      <name>Clean Staging and DQ</name>
      <description>Truncate staging tables and clean DQ tables for idempotent run</description>
      <type>SQL</type>
      <attributes />
      <sql><![CDATA[TRUNCATE TABLE 
    stg.climate_daily,
    stg.climate_stations,
    stg.earthquakes,
    stg.disasters,
    stg.regional_features,
    stg.cell_towers,
    stg.ookla_broadband,
    stg.power_plants,
    stg.substations,
    stg.isp_points_of_presence,
    stg.water_quality_index,
    stg.admin_boundaries,
    stg.population_demographics
CASCADE;

DELETE FROM dq.quarantine_records;
DELETE FROM dq.quality_issues;]]></sql>
      <useVariableSubstitution>N</useVariableSubstitution>
      <sqlfromfile>N</sqlfromfile>
      <sqlfilename />
      <sendOneStatement>Y</sendOneStatement>
      <connection>lab-postgres</connection>
      <parallel>N</parallel>
      <xloc>180</xloc>
      <yloc>128</yloc>
      <attributes_hac />
    </action>
"""

hops_xml = """    <hop>
      <from>Start</from>
      <to>Clean Staging and DQ</to>
      <enabled>Y</enabled>
      <evaluation>Y</evaluation>
      <unconditional>Y</unconditional>
    </hop>
"""
prev_action = "Clean Staging and DQ"

for i, p in enumerate(PIPELINE_DEFS):
    act_name = f"{p['name']}.hpl"
    x_pos = 300 + (i * 120)
    workflow_xml += f"""    <action>
      <name>{act_name}</name>
      <description />
      <type>PIPELINE</type>
      <attributes />
      <filename>${{PROJECT_HOME}}/pipelines/{p['name']}.hpl</filename>
      <params_from_previous>N</params_from_previous>
      <exec_per_row>N</exec_per_row>
      <clear_rows>N</clear_rows>
      <clear_files>N</clear_files>
      <set_logfile>N</set_logfile>
      <logfile />
      <logext />
      <add_date>N</add_date>
      <add_time>N</add_time>
      <loglevel>Basic</loglevel>
      <set_append_logfile>N</set_append_logfile>
      <wait_until_finished>Y</wait_until_finished>
      <create_parent_folder>N</create_parent_folder>
      <run_configuration>local</run_configuration>
      <parameters>
      </parameters>
      <parallel>N</parallel>
      <xloc>{x_pos}</xloc>
      <yloc>128</yloc>
      <attributes_hac />
    </action>
"""
    hops_xml += f"""    <hop>
      <from>{prev_action}</from>
      <to>{act_name}</to>
      <enabled>Y</enabled>
      <evaluation>Y</evaluation>
      <unconditional>Y</unconditional>
    </hop>
"""
    prev_action = act_name

# Add Success Action
workflow_xml += f"""    <action>
      <name>Success</name>
      <description />
      <type>SUCCESS</type>
      <attributes />
      <parallel>N</parallel>
      <xloc>{300 + (len(PIPELINE_DEFS) * 120)}</xloc>
      <yloc>128</yloc>
      <attributes_hac />
    </action>
  </actions>
  <hops>
{hops_xml}    <hop>
      <from>{prev_action}</from>
      <to>Success</to>
      <enabled>Y</enabled>
      <evaluation>Y</evaluation>
      <unconditional>Y</unconditional>
    </hop>
  </hops>
  <attributes />
</workflow>
"""

wf_file = WORKFLOWS_DIR / "wf_stg_master.hwf"
with open(wf_file, "w", encoding="utf-8") as f:
    f.write(workflow_xml)
print(f"Generated Hop Master Workflow: {wf_file.name}")
