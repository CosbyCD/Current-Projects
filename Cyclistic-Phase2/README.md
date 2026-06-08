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

## Data Source

- **Provider:** Divvy / City of Chicago
- **Bucket:** https://divvy-tripdata.s3.amazonaws.com/
- **Scope:** 2022 full year — 12 monthly files
- **Format:** ZIP → CSV
- **Approximate volume:** 5–6 million rows

---

## ClickHouse Service

- **Service:** analytics-pipeline
- **Host:** fu5itnlxt3.us-west-2.aws.clickhouse.cloud
- **Port:** 8443
- **Username:** default
- **Database:** default

---

## Schema Decisions

| Column | Type | Reasoning |
|---|---|---|
| ride_id | String | Alphanumeric identifier |
| rideable_type | LowCardinality(String) | ~3 distinct values — encodes as integer internally |
| started_at | DateTime | Parsed from M/D/YYYY H:MM source format |
| ended_at | DateTime | Same |
| start_station_name | String | Variable text |
| start_station_id | String | Mixed numeric/alphanumeric in source e.g. RP-007 |
| end_station_name | String | Variable text |
| end_station_id | String | Same mixed ID reasoning |
| start_lat / start_lng | Float64 | 10+ decimal places in source — Float32 would truncate |
| end_lat / end_lng | Float64 | Same |
| member_casual | LowCardinality(String) | 2 distinct values |
| ride_duration_min | UInt32 | Derived — computed at insert time |
| ride_date | Date | Derived — extracted from started_at |
| ride_hour | UInt8 | Derived — extracted from started_at |

**Why Float64 not Point type:** Tableau requires coordinate pairs as separate fields. Storing as float pairs avoids extraction overhead while still enabling ClickHouse native geo functions via geoDistance(start_lng, start_lat, end_lng, end_lat).

**Why ORDER BY (started_at, start_station_id):** Most analytical queries filter on time first, then location. This physical sort order enables ClickHouse sparse indexing to skip irrelevant time ranges before touching coordinate data.

---

## Deliverable

Animated geospatial visualization of rider behavior and temporal patterns across time and geography — built in Tableau using ClickHouse as the analytical backend.

---

## Files

| File | Description |
|---|---|
| README.md | This document |
| schema.sql | CREATE TABLE statement with comments |
| pipeline.py | Python ingestion script — S3 to ClickHouse |
