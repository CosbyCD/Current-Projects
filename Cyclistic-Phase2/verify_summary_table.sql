/*
File: verify_summary_table.sql
Verifies cyclistic_summary table after creation.
Confirms row counts, date range, unique stations, and total rides represented.
Expected: total_rides_represented should match cyclistic_rides row count (5,661,859).
Verified: 2026-06-09
Results: 4,080,487 rows | 2022-01-01 to 2022-12-31 | 1,675 unique stations | 5,661,859 total rides
*/

SELECT
    count() AS total_rows,
    min(ride_date) AS first_date,
    max(ride_date) AS last_date,
    countDistinct(start_station_name) AS unique_stations,
    sum(total_rides) AS total_rides_represented
FROM cyclistic_summary;
