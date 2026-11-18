#!/usr/bin/env python3
"""
Generates DQ Logging Pipelines for Apache Hop:
Checks data quality rules from raw sources and inserts violations into dq.quality_issues.
Also updates Master Workflow to include these DQ pipelines.
"""

from pathlib import Path

BASE_DIR = Path("/home/kemal/projects_ub/data_engineering/capstone_data_engineering/workspace/hop-project")
PIPELINES_DIR = BASE_DIR / "pipelines"
WORKFLOWS_DIR = BASE_DIR / "workflows"

PIPELINES_DIR.mkdir(parents=True, exist_ok=True)
WORKFLOWS_DIR.mkdir(parents=True, exist_ok=True)

def create_dq_pipeline_xml(name, description, sql_query, commit_size=1000):
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
    <created_date>2026/11/18 00:00:00.000</created_date>
    <modified_user>-</modified_user>
    <modified_date>2026/11/18 00:00:00.000</modified_date>
  </info>
  <notepads />
  <transform>
    <name>Extract DQ Violations</name>
    <type>TableInput</type>
    <description>Detects data quality issues from raw source</description>
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
    <sql>{sql_query}</sql>
    <variables_active>N</variables_active>
    <attributes />
    <GUI>
      <xloc>160</xloc>
      <yloc>128</yloc>
    </GUI>
  </transform>
  <transform>
    <name>Load to dq.quality_issues</name>
    <type>TableOutput</type>
    <description>Logs detected anomalies into audit table</description>
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
      <field><column_name>rule_id</column_name><stream_name>rule_id</stream_name></field>
      <field><column_name>severity</column_name><stream_name>severity</stream_name></field>
      <field><column_name>reason</column_name><stream_name>reason</stream_name></field>
      <field><column_name>table_name</column_name><stream_name>table_name</stream_name></field>
      <field><column_name>record_id</column_name><stream_name>record_id</stream_name></field>
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
      <xloc>520</xloc>
      <yloc>128</yloc>
    </GUI>
  </transform>
  <order>
    <hop>
      <from>Extract DQ Violations</from>
      <to>Load to dq.quality_issues</to>
      <enabled>Y</enabled>
    </hop>
  </order>
  <attributes />
</pipeline>"""
    return xml

DQ_PIPELINES = [
    {
        "name": "pl_dq_src01_earthquakes",
        "description": "Log DQ anomalies for BMKG Earthquake Catalog",
        "sql": """SELECT 
    'DQ-GEO-01' AS rule_id,
    'CRITICAL' AS severity,
    'Koordinat di luar wilayah Indonesia (Lat: ' || COALESCE(latitude::text, 'null') || ', Lon: ' || COALESCE(longitude::text, 'null') || ')' AS reason,
    'raw.src01_earthquake_catalog' AS table_name,
    event_id AS record_id
FROM raw.src01_earthquake_catalog
WHERE latitude NOT BETWEEN -11.0 AND 6.0 
   OR longitude NOT BETWEEN 95.0 AND 141.0;"""
    },
    {
        "name": "pl_dq_src06_ookla",
        "description": "Log DQ anomalies for Ookla Speed & Latency",
        "sql": """SELECT 
    'DQ-NET-01' AS rule_id,
    'WARNING' AS severity,
    'Latensi internet tidak wajar atau negatif: ' || COALESCE(avg_lat_ms::text, 'null') || ' ms' AS reason,
    'raw.src06_ookla_fixed_broadband' AS table_name,
    quadkey AS record_id
FROM raw.src06_ookla_fixed_broadband
WHERE avg_lat_ms <= 0 OR avg_lat_ms > 1000;"""
    },
    {
        "name": "pl_dq_src07_power_plants",
        "description": "Log DQ anomalies for Power Plants (Global dataset filter)",
        "sql": """SELECT 
    'DQ-GEO-01' AS rule_id,
    'CRITICAL' AS severity,
    'Pembangkit listrik bukan wilayah Indonesia (Country: ' || COALESCE(country, 'null') || ')' AS reason,
    'raw.src07_power_plants' AS table_name,
    gppd_idnr AS record_id
FROM raw.src07_power_plants
WHERE country != 'IDN' OR latitude NOT BETWEEN -11.0 AND 6.0 OR longitude NOT BETWEEN 95.0 AND 141.0;"""
    }
]

for p in DQ_PIPELINES:
    file_path = PIPELINES_DIR / f"{p['name']}.hpl"
    xml_content = create_dq_pipeline_xml(
        name=p["name"],
        description=p["description"],
        sql_query=p["sql"]
    )
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(xml_content)
    print(f"Generated DQ Pipeline: {file_path.name}")

# Now build the full workflow:
# 1. Start
# 2. Run all DQ Pipelines (log violations to dq.quality_issues)
# 3. Run all STG Pipelines (load clean data to stg.*)
# 4. Success

STG_PIPELINE_NAMES = [
    "pl_stg_earthquakes",
    "pl_stg_disasters",
    "pl_stg_power_plants",
    "pl_stg_substations",
    "pl_stg_water_quality",
    "pl_stg_regional_features",
    "pl_stg_demographics",
    "pl_stg_isp_pop",
    "pl_stg_admin_boundaries",
    "pl_stg_cell_towers",
    "pl_stg_ookla_broadband"
]

ALL_PIPELINES = [p["name"] for p in DQ_PIPELINES] + STG_PIPELINE_NAMES

workflow_xml = """<workflow>
  <name>wf_stg_master</name>
  <name_sync_with_filename>Y</name_sync_with_filename>
  <description>Master Workflow: Runs DQ Audits and Staging ETL Pipelines sequentially</description>
  <extended_description />
  <workflow_version>2.0</workflow_version>
  <workflow_status>0</workflow_status>
  <created_user>-</created_user>
  <created_date>2026/11/18 00:00:00.000</created_date>
  <modified_user>-</modified_user>
  <modified_date>2026/11/18 00:00:00.000</modified_date>
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
"""

hops_xml = ""
prev_action = "Start"

for i, p_name in enumerate(ALL_PIPELINES):
    act_name = f"{p_name}.hpl"
    x_pos = 200 + (i * 120)
    workflow_xml += f"""    <action>
      <name>{act_name}</name>
      <description />
      <type>PIPELINE</type>
      <attributes />
      <filename>${{PROJECT_HOME}}/pipelines/{p_name}.hpl</filename>
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
      <xloc>{200 + (len(ALL_PIPELINES) * 120)}</xloc>
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
print(f"Updated Hop Master Workflow: {wf_file.name}")
