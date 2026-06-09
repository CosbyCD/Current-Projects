/*
File: verify_detail_table.sql
Verifies cyclistic_detail table after creation.
Confirms row counts match raw cyclistic_rides (5,661,859).
*/

SELECT
    count() AS total_rows,
    min(started_at) AS earliest_ride,
    max(started_at) AS latest_ride,
    countIf(is_holiday = 1) AS holiday_rides,
    countIf(member_casual = 'member') AS member_rides,
    countIf(member_casual = 'casual') AS casual_rides
FROM cyclistic_detail;
