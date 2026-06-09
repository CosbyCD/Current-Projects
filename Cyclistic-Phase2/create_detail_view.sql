/*
File: create_detail_view.sql
Creates the ride-level detail view for drill-down analysis in Tableau.
One row per ride — no aggregation.
Joins cyclistic_rides with weather_data and holidays.
Holiday duplicates collapsed to comma-separated string.
Fix: ClickHouse returns 1970-01-01 not NULL for unmatched LEFT JOIN Date columns.
Companion to cyclistic_summary (aggregated overview table).
*/

DROP TABLE IF EXISTS cyclistic_detail;

CREATE TABLE cyclistic_detail
ENGINE = MergeTree()
ORDER BY (started_at, start_station_id)
AS
SELECT
    r.ride_id,
    r.rideable_type,
    r.member_casual,
    r.started_at,
    r.ended_at,
    r.ride_date,
    toMonth(r.ride_date)                    AS ride_month,
    toDayOfWeek(r.ride_date)                AS day_of_week,
    dateName('weekday', r.ride_date)        AS day_name,
    r.ride_hour,
    r.ride_duration_min,
    r.start_station_name,
    r.start_station_id,
    r.end_station_name,
    r.end_station_id,
    r.start_lat,
    r.start_lng,
    r.end_lat,
    r.end_lng,
    w.temp,
    w.feelslike,
    w.windspeed,
    w.windgust,
    w.winddir,
    w.precipprob,
    w.preciptype,
    w.snow,
    w.uvindex,
    w.solarradiation,
    w.sunrise,
    w.sunset,
    w.moonphase,
    w.conditions                            AS weather_conditions,
    if(h.holiday_date <> toDate('1970-01-01'), 1, 0)               AS is_holiday,
    if(h.holiday_date <> toDate('1970-01-01'), h.holiday_names, '') AS holiday_name
FROM cyclistic_rides r
LEFT JOIN weather_data w ON r.ride_date = w.weather_date
LEFT JOIN (
    SELECT
        holiday_date,
        arrayStringConcat(groupArray(holiday_name), ', ') AS holiday_names
    FROM holidays
    GROUP BY holiday_date
) h ON r.ride_date = h.holiday_date;

-- Verify table creation
SELECT
    count() AS total_rows,
    min(started_at) AS earliest_ride,
    max(started_at) AS latest_ride,
    countIf(is_holiday = 1) AS holiday_rides,
    countIf(is_holiday = 0) AS non_holiday_rides,
    countIf(member_casual = 'member') AS member_rides,
    countIf(member_casual = 'casual') AS casual_rides
FROM cyclistic_detail;
