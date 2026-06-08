-- Cyclistic Phase 2 — Validation Queries
-- Run these to verify data loaded correctly after pipeline execution

-- ─────────────────────────────────────────
-- Check all three tables exist
-- ─────────────────────────────────────────
SHOW TABLES;

-- ─────────────────────────────────────────
-- Row counts across all tables
-- ─────────────────────────────────────────
SELECT 'cyclistic_rides' AS table_name, count() AS rows FROM cyclistic_rides
UNION ALL
SELECT 'weather_data', count() FROM weather_data
UNION ALL
SELECT 'holidays', count() FROM holidays;

-- ─────────────────────────────────────────
-- Ride data — full year coverage and member split
-- ─────────────────────────────────────────
SELECT
    toMonth(started_at) AS month,
    count() AS rides,
    countIf(member_casual = 'member') AS members,
    countIf(member_casual = 'casual') AS casuals
FROM cyclistic_rides
GROUP BY month
ORDER BY month;

-- ─────────────────────────────────────────
-- Ride data — date range and total rows
-- ─────────────────────────────────────────
SELECT
    count() AS total_rows,
    min(started_at) AS earliest_ride,
    max(started_at) AS latest_ride
FROM cyclistic_rides;

-- ─────────────────────────────────────────
-- Weather data — date range and key metrics
-- ─────────────────────────────────────────
SELECT
    min(weather_date) AS first_date,
    max(weather_date) AS last_date,
    count() AS total_rows,
    round(avg(temp), 1) AS avg_temp,
    round(max(windgust), 1) AS max_gust,
    round(avg(moonphase), 2) AS avg_moonphase
FROM weather_data;

-- ─────────────────────────────────────────
-- Holidays — full list by date
-- ─────────────────────────────────────────
SELECT
    holiday_date,
    holiday_name
FROM holidays
ORDER BY holiday_date;
