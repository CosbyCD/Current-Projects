# Cyclistic Bike-Share — Phase 2 Geospatial Pipeline

**Status:** In Development
**Tools:** ClickHouse · Python · SQL · Tableau
**Related:** [Cyclistic Phase 1](https://github.com/CosbyCD/Data-Analytics-Portfolio/tree/main/Cyclistic)

---

## Overview

Phase 1 of the Cyclistic analysis — published on RPubs — surfaced geospatial questions that R alone could not resolve. The introduction of third-party temporal data — holidays and weather patterns — revealed patterns at the intersection of time, geography, and rider behavior that demand a different infrastructure to answer visually.

Phase 2 builds that infrastructure.

---

## Pipeline Architecture

S3 (divvy-tripdata) → Python ingestion script → ClickHouse → Tableau

Raw monthly CSV data is downloaded from the Divvy public S3 bucket, cleaned and enriched with derived columns, and inserted into ClickHouse Cloud. Tableau connects directly to ClickHouse to power an animated geospatial visualization of rider behavior across time and geography.

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
- **Note:** CSV export had column misalignment — resolved by mapping columns
  by raw position index. See weather_data_notes.md for full details.

### Holiday Data
- **Source:** US federal holidays, multicultural observances, and
  Chicago-specific events compiled from Phase 1 research
- **Rows loaded:** 55 records covering single and multi-day events

---

## ClickHouse Service

- **Service:** analytics-pipeline
- **Host:** fu5itnlxt3.us-west-2.aws.clickhouse.cloud
- **Port:** 8443
- **Username:** default
- **Database:** default

---

## Tables

### cyclistic_rides
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

ORDER BY (started_at, start_station_id)

### weather_data
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

ORDER BY weather_date

### holidays
| Column | Type | Notes |
|---|---|---|
| holiday_name | String | Federal, cultural, and Chicago-specific events |
| holiday_date | Date | Join key — multi-day events have one row per day |

ORDER BY holiday_date

---

## Key Design Decisions

**Float64 for coordinates** — source data has 10+ decimal places. Float32 truncates and introduces spatial drift unacceptable for geospatial visualization.

**Float pairs not Point type** — Tableau requires coordinate pairs as separate fields. geoDistance(start_lng, start_lat, end_lng, end_lat) provides native geo functions without type conversion overhead.

**Wind columns retained in full** — Chicago is the Windy City. Gust strength, sustained speed, speed range, and direction all independently affect rider behavior, particularly on lakefront routes exposed to lake winds.

**Lunar and solar columns retained** — Chicago lakefront riders respond to light conditions. Sunrise/sunset defines the usable ride window. Moon phase and visibility affect evening casual rides
