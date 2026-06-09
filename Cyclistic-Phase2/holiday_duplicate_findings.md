# Holiday Duplicate Finding — Join Fan-Out Investigation

## Issue Discovered
After creating cyclistic_summary, total_rides_represented (5,710,894) exceeded
raw cyclistic_rides row count (5,661,859) by 49,035 rows.

## Root Cause
LEFT JOIN on holidays table created duplicate rows on dates with multiple
holiday records. The holidays table stores multi-event days as separate rows,
which caused a fan-out — each ride on those dates was counted once per holiday.

## Affected Dates
| Date | Holidays | Records |
|---|---|---|
| 2022-06-09 | Taste of Chicago, Chicago Blues Festival | 2 |
| 2022-06-10 | Taste of Chicago, Chicago Blues Festival | 2 |

All other 53 holiday records are single entries on unique dates.

## Detection Query
```sql
SELECT
    holiday_date,
    count() AS records
FROM holidays
GROUP BY holiday_date
HAVING records > 1
ORDER BY holiday_date;
```

## Full Holiday Date Map Query
```sql
SELECT
    holiday_date,
    groupArray(holiday_name) AS holidays
FROM holidays
GROUP BY holiday_date
ORDER BY holiday_date;
```

## Resolution
Pre-collapsed holidays subquery using arrayStringConcat(groupArray(holiday_name))
before joining — overlapping events on the same date become a single
comma-separated string instead of multiple rows.
See create_summary_table.sql for corrected implementation.
