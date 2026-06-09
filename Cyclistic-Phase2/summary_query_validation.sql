/*
File: summary_query_validation.sql
Validates the hourly station-level summary query before permanent table creation.
Joins cyclistic_rides with weather_data and holidays.
Aggregates to one row per station per hour per day per member type.
LIMIT 100 — validation only, not final output.
*/

SELECT
    r.ride_date,
    r.ride_hour,
    r.start_station_name,
    r.start_lat,
    r.start_lng,
    r.member_casual,
    count() AS total_rides,
    avg(r.ride_duration_min) AS avg_duration_min,
    -- Weather context
    w.temp,
    w.feelslike,
    w.windspeed,
    w.windgust,
    w.winddir,
    w.precipprob,
    w.preciptype,
    w.snow,
    w.uvindex,
    w.sunrise,
    w.sunset,
    w.moonphase,
    w.conditions AS weather_conditions,
    -- Holiday context
    if(h.holiday_date IS NOT NULL, 1, 0) AS is_holiday,
    if(h.holiday_date IS NOT NULL, h.holiday_name, '') AS holiday_name
FROM cyclistic_rides r
LEFT JOIN weather_data w ON r.ride_date = w.weather_date
LEFT JOIN holidays h ON r.ride_date = h.holiday_date
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
    w.sunrise,
    w.sunset,
    w.moonphase,
    w.conditions,
    h.holiday_date,
    h.holiday_name
ORDER BY
    r.ride_date,
    r.ride_hour,
    r.start_station_name
LIMIT 100;
