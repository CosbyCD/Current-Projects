-- Cyclistic Phase 2 — All Table Definitions
-- Created: 2026-06-08

-- ─────────────────────────────────────────
-- Table 1: cyclistic_rides
-- ─────────────────────────────────────────
CREATE TABLE cyclistic_rides
(
    ride_id             String,
    rideable_type       LowCardinality(String),
    started_at          DateTime,
    ended_at            DateTime,
    start_station_name  String,
    start_station_id    String,
    end_station_name    String,
    end_station_id      String,
    start_lat           Float64,
    start_lng           Float64,
    end_lat             Float64,
    end_lng             Float64,
    member_casual       LowCardinality(String),
    ride_duration_min   UInt32,
    ride_date           Date,
    ride_hour           UInt8
)
ENGINE = MergeTree()
ORDER BY (started_at, start_station_id);

-- ─────────────────────────────────────────
-- Table 2: weather_data
-- ─────────────────────────────────────────
CREATE TABLE weather_data
(
    weather_date     Date,
    tempmax          Float32,
    tempmin          Float32,
    temp             Float32,
    feelslike        Float32,
    humidity         Float32,
    precip           Float32,
    precipprob       Float32,
    preciptype       LowCardinality(String),
    snow             Float32,
    snowdepth        Float32,
    windgust         Float32,
    windspeed        Float32,
    windspeedmax     Float32,
    windspeedmean    Float32,
    windspeedmin     Float32,
    winddir          Float32,
    cloudcover       Float32,
    visibility       Float32,
    uvindex          UInt8,
    solarradiation   Float32,
    solarenergy      Float32,
    sunrise          String,
    sunset           String,
    moonphase        Float32,
    moonrise         String,
    moonset          String,
    conditions       LowCardinality(String)
)
ENGINE = MergeTree()
ORDER BY weather_date;

-- ─────────────────────────────────────────
-- Table 3: holidays
-- ─────────────────────────────────────────
CREATE TABLE holidays
(
    holiday_name        String,
    holiday_date        Date
)
ENGINE = MergeTree()
ORDER BY holiday_date;
