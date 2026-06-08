-- Cyclistic Phase 2 — ClickHouse Schema
-- Database: default
-- Service: analytics-pipeline
-- Created: 2026-06-08

-- Drop and recreate if needed during development
-- DROP TABLE IF EXISTS cyclistic_rides;

CREATE TABLE cyclistic_rides
(
    -- Source columns
    ride_id             String,                  -- Alphanumeric unique identifier
    rideable_type       LowCardinality(String),  -- ~3 values: electric_bike, classic_bike, docked_bike
    started_at          DateTime,                -- Parsed from M/D/YYYY H:MM source format
    ended_at            DateTime,                -- Same
    start_station_name  String,
    start_station_id    String,                  -- String not Int — source has mixed IDs e.g. RP-007
    end_station_name    String,
    end_station_id      String,                  -- Same mixed ID reasoning
    start_lat           Float64,                 -- Float64 not Float32 — source has 10+ decimal places
    start_lng           Float64,
    end_lat             Float64,
    end_lng             Float64,
    member_casual       LowCardinality(String),  -- 2 values: member, casual

    -- Derived columns — computed at insert time in pipeline.py
    ride_duration_min   UInt32,                  -- (ended_at - started_at) in minutes
    ride_date           Date,                    -- Date portion of started_at
    ride_hour           UInt8                    -- Hour portion of started_at (0-23)
)
ENGINE = MergeTree()
ORDER BY (started_at, start_station_id);
-- ORDER BY reasoning: queries filter on time first, then location.
-- Sparse indexing skips irrelevant time ranges before touching coordinate data.
