# Cyclistic Bike-Share — Phase 2 Geospatial Pipeline
**Status:** In Development &nbsp;|&nbsp; **Tools:** ClickHouse · Python · SQL · Tableau &nbsp;|&nbsp; **Related:** [Cyclistic Phase 1](https://github.com/CosbyCD/Data-Analytics-Portfolio/tree/main/Cyclistic)

---

## Overview

Phase 1 of the Cyclistic analysis — published on RPubs — surfaced geospatial questions that R alone could not resolve. The introduction of third-party temporal data — holidays and weather patterns — revealed patterns at the intersection of time, geography, and rider behavior that demand a different infrastructure to answer visually.

Phase 2 builds that infrastructure.

---

## Pipeline Architecture

```
S3 (divvy-tripdata) → Python ingestion script → ClickHouse → Tableau
```

Raw monthly CSV data is downloaded from the Divvy public S3 bucket, cleaned and enriched with derived columns, and inserted into ClickHouse Cloud. Tableau connects to ClickHouse via the MySQL protocol interface to power an animated geospatial visualization of rider behavior across time and geography.

---

## Data Sources

### Ride Data
- **Provider:** Divvy / City of Chicago
- **Bucket:** https://divvy-tripdata.s3.amazonaws.com/
- **Scope:** 2022 full year — 12 monthly files
- **Format:** ZIP → CSV
- **Rows loaded:** 5,661,859

### Weather Data
- **Provider:** Visual Crossing Weather
- **Location:** Chicago, Illinois
- **Date range:** 2022-01-01 to 2022-12-31
- **Granularity:** Daily
- **Rows loaded:** 365
- **Note:** CSV export had column misalignment — resolved by mapping columns by raw position index. See `weather_data_notes.md` for full details.

### Holiday Data
- **Source:** US federal holidays, multicultural observances, and Chicago-specific events compiled from Phase 1 research
- **Rows loaded:** 55 records covering single and multi-day events
- **Note:** Labor Day (2022-09-05) was absent from the original Google holiday source data. Discovered on June 25, 2026 when conversion arc analysis returned only two results instead of three. Added manually via `add_labor_day.sql`.

---

## ClickHouse Service

| Field | Value |
|---|---|
| Service | analytics-pipeline |
| Host | fu5itnlxt3.us-west-2.aws.clickhouse.cloud |
| Port (native) | 8443 |
| Port (MySQL interface) | 9004 |
| Username | default |
| Database | default |

**Tableau connection:** MySQL ODBC connector with SSL (Let's Encrypt PEM certificate) via port 9004.

---

## Tables

### cyclistic_rides
Raw ingestion table. 5,661,859 rows.

| Column | Type | Notes |
|---|---|---|
| ride_id | String | Alphanumeric identifier |
| rideable_type | LowCardinality(String) | ~3 distinct values |
| started_at | DateTime | Parsed from source format |
| ended_at | DateTime | Same |
| start_station_name | String | |
| start_station_id | String | Mixed numeric/alphanumeric e.g. RP-007 |
| end_station_name | String | |
| end_station_id | String | Same mixed ID reasoning |
| start_lat / start_lng | Float64 | 10+ decimal places — Float32 would truncate |
| end_lat / end_lng | Float64 | Same |
| member_casual | LowCardinality(String) | 2 distinct values |
| ride_duration_min | UInt32 | Derived at insert time |
| ride_date | Date | Derived at insert time |
| ride_hour | UInt8 | Derived at insert time |

`ORDER BY (started_at, start_station_id)`

---

### cyclistic_summary_v2
Primary analysis table. Aggregated to station-level by date, hour, and rider type. 4,730,341 rows. This is the table Tableau connects to directly.

| Column | Type | Notes |
|---|---|---|
| ride_date | Date | Date of ride |
| ride_month | UInt8 | Month number (1-12) |
| day_of_week | UInt8 | Day number |
| day_name | String | Day name |
| ride_hour | UInt8 | Hour of ride (0-23) |
| start_station_name | String | Origin station |
| end_station_name | String | Destination station |
| member_casual | LowCardinality(String) | Member or casual rider |
| rideable_type | LowCardinality(String) | Bike type |
| avg_start_lat | Float64 | Origin latitude |
| avg_start_lng | Float64 | Origin longitude |
| avg_end_lat | Float64 | Destination latitude |
| avg_end_lng | Float64 | Destination longitude |
| total_rides | UInt64 | Total rides |
| avg_duration_min | Float64 | Average ride duration in minutes |

`ORDER BY (ride_date, ride_hour, start_station_name, member_casual)`

---

### weather_data
Daily weather from Visual Crossing. 365 rows. Joined to `cyclistic_summary_v2` on `ride_date = weather_date`.

| Column | Type | Notes |
|---|---|---|
| weather_date | Date | Join key to ride data |
| tempmax / tempmin / temp | Float32 | Daily temperature range |
| feelslike | Float32 | Perceived temperature |
| humidity | Float32 | |
| precip | Float32 | Precipitation amount |
| precipprob | Float32 | Precipitation probability |
| preciptype | LowCardinality(String) | rain, snow, etc. |
| snow / snowdepth | Float32 | |
| windgust | Float32 | Peak gust — critical for Chicago lakefront |
| windspeed | Float32 | Average speed |
| windspeedmax / windspeedmean / windspeedmin | Float32 | Speed range |
| winddir | Float32 | Direction in degrees — lake vs inland winds |
| cloudcover | Float32 | |
| visibility | Float32 | |
| uvindex | UInt8 | Affects outdoor behavior decisions |
| solarradiation / solarenergy | Float32 | Perceived warmth on cold days |
| sunrise / sunset | String | Light window — affects ride timing |
| moonphase | Float32 | 0.0 to 1.0 scale |
| moonrise / moonset | String | Lunar visibility — lakefront behavior |
| conditions | LowCardinality(String) | Text description |

`ORDER BY weather_date`

---

### holidays
Chicago-specific holiday and event calendar. Joined to `cyclistic_summary_v2` on `ride_date = holiday_date`.

| Column | Type | Notes |
|---|---|---|
| holiday_name | String | Federal, cultural, and Chicago-specific events |
| holiday_date | Date | Join key — multi-day events have one row per day |

`ORDER BY holiday_date`

---

## Key Design Decisions

**Float64 for coordinates** — source data has 10+ decimal places. Float32 truncates and introduces spatial drift unacceptable for geospatial visualization.

**Float pairs not Point type** — Tableau requires coordinate pairs as separate fields. `geoDistance(start_lng, start_lat, end_lng, end_lat)` provides native geo functions without type conversion overhead.

**Wind columns retained in full** — Chicago is the Windy City. Gust strength, sustained speed, speed range, and direction all independently affect rider behavior, particularly on lakefront routes exposed to lake winds.

**Lunar and solar columns retained** — Chicago lakefront riders respond to light conditions. Sunrise/sunset defines the usable ride window. Moon phase and visibility affect evening casual rides.

**cyclistic_summary_v2 as primary analysis table** — aggregating from the raw 5.6M row rides table to station-level summary reduces query overhead for Tableau without losing the geographic or temporal granularity required for animated geospatial visualization.

---

## Key Findings

### Weather Influence
- **Temperature** is the primary ridership driver. Peak ridership occurs at 70-75°F, driven by casual surge. Members ride consistently across temperature ranges; casuals are highly weather-sensitive.
- **Precipitation** suppresses casual ridership faster and more severely than member ridership. Members ride through rain. Casuals don't. Behavioral confirmation of commuter vs leisure split.
- **Wind** has minimal effect. Chicago riders — both member and casual — ride in sustained winds of 30+ mph. Wind is not a primary suppressor.
- **Flooding outlier — July 23, 2022:** Severe weather and flooding across Chicago. 1.148" precipitation. Casual ridership: 17,798 — 106% above comparable high-precipitation days and 35% above the July dry-day average. No holiday. No scheduled event. When roads flooded and cars stopped moving, riders turned to bikes. Emergency mobility infrastructure, not leisure. Business implication: on weather emergency days, a city partnership could unlock bikes for free public use — emergency mobility for residents, infrastructure resilience for the city, and a B2G revenue stream for Cyclistic.

### Conversion Arc — Volume Is the Wrong Metric
Independence Day ranks 12th in total ridership volume but 1st in casual conversion rate. The three season-marker holidays tell the real story:

| Holiday | Casual Rides | Total Rides | Conversion Rate |
|---|---|---|---|
| Independence Day | 13,659 | 22,484 | 60.75% |
| Labor Day | 11,238 | 20,960 | 53.62% |
| Memorial Day | 6,732 | 16,343 | 41.19% |

Marketing resources allocated by volume will miss the highest-yield conversion moments entirely.

---

## Query Files

| File | Purpose |
|---|---|
| `create_tables.sql` | Schema definitions for all three source tables |
| `create_summary_table.sql` | Creates `cyclistic_summary_v2` from `cyclistic_rides` |
| `create_detail_view.sql` | Detail view joining all three tables |
| `check_holiday_duplicates.sql` | Validates holiday join fan-out bug fix |
| `summary_query_validation.sql` | Row count and field validation for summary table |
| `validation_queries.sql` | General data validation queries |
| `verify_detail_table.sql` | Verifies detail table integrity |
| `verify_summary_table.sql` | Verifies summary table integrity |
| `july_casual_rides_weather.sql` | July 2022 daily casual ridership with weather — used for flooding day spike analysis |
| `conversion_arc.sql` | Memorial Day, Independence Day, Labor Day conversion rates |
| `add_labor_day.sql` | Adds Labor Day to holidays table — missing from original Google source data |

---

*CyberPhase Consulting — Cherrie Cosby*
*github.com/CosbyCD/Data-Analytics-Portfolio*
*Last updated: June 25, 2026*
