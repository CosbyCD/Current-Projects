*
File: check_holiday_duplicates.sql
Identifies dates with multiple holiday records that cause fan-out in joins.
*/

SELECT
    holiday_date,
    groupArray(holiday_name) AS holidays
FROM holidays
GROUP BY holiday_date
ORDER BY holiday_date;
