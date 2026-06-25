-- july_casual_rides_weather.sql
-- Cyclistic Phase 2 — July 2022 daily casual ridership with precipitation and temperature
-- Used to calculate flooding day spike percentage (July 23, 2022)
-- July 23: 17,798 casual rides, 1.148" precip — 106% above comparable wet days, 35% above dry day average
-- CyberPhase Consulting | Cherrie Cosby | June 25, 2026

SELECT 
    c.ride_date,
    SUM(CASE WHEN member_casual = 'casual' THEN total_rides END) as casual_rides,
    w.precip,
    w.temp
FROM cyclistic_summary_v2 c
LEFT JOIN weather_data w ON c.ride_date = w.weather_date
WHERE toMonth(c.ride_date) = 7
GROUP BY c.ride_date, w.precip, w.temp
ORDER BY c.ride_date
