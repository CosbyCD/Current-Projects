/*
File: create_summary_table.sql
Creates the hourly station-level summary table for Tableau animated visualization.
Joins cyclistic_rides with weather_data and holidays.
Aggregates to one row per station per hour per day per member type.
Includes derived time fields: month, day_of_week for Tableau filtering.
Holiday duplicates on same date collapsed to comma-separated string.
Fix: ClickHouse returns 1970-01-01 not NULL for unmatched LEFT JOIN Date columns.
*/

DROP TABLE IF EXISTS cyclistic_summary;

CREATE TABLE cyclistic_summary
ENGINE = MergeTree()
ORDER BY (ride_date, ride_hour, start_station_name, member_casual)
AS
SELECT
    r.ride_date,
    toMonth(r.ride_date)                    AS ride_month,
    toDayOfWeek(r.ride_date)                AS day_of_week,
    dateName('weekday', r.ride_date)        AS day_name,
    r.ride_hour,
    r.start_station_name,
    r.start_lat,
    r.start_lng,
    r.member_casual,
    count()                                 AS total_rides,
    round(avg(r.ride_duration_min), 2)      AS avg_duration_min,
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
    if(h.holiday_date <> toDate('1970-01-01'), 1, 0)             AS is_holiday,
    if(h.holiday_date <> toDate('1970-01-01'), h.holiday_names, '') AS holiday_name
FROM cyclistic_rides r
LEFT JOIN weather_data w ON r.ride_date = w.weather_date
LEFT JOIN (
    SELECT
        holiday_date,
        arrayStringConcat(groupArray(holiday_name), ', ') AS holiday_names
    FROM holidays
    GROUP BY holiday_date
) h ON r.ride_date = h.holiday_date
GROUP BY
    r.ride_date,
    r.ride_hour,
    r.start_station_name,
    r.start_lat,
    r.start_lng,
    r.member_casual,
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
    w.conditions,
    h.holiday_date,
    h.holiday_names
ORDER BY
    r.ride_date,
    r.ride_hour,
    r.start_station_name;
