-- ==============================================================================
-- Clean Staging Tables and DQ Quarantine/Issues Tables (Idempotent Reset)
-- ==============================================================================

TRUNCATE TABLE 
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
DELETE FROM dq.quality_issues;
