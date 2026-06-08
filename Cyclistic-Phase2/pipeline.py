"""
Cyclistic Phase 2 — S3 to ClickHouse Ingestion Pipeline
Source: https://divvy-tripdata.s3.amazonaws.com/
Target: ClickHouse Cloud — analytics-pipeline service
Scope:  2022 full year (202201 through 202212)
"""

import io
import zipfile
import requests
import pandas as pd
import clickhouse_connect

# ── Connection ────────────────────────────────────────────────────────────────

HOST     = "fu5itnlxt3.us-west-2.aws.clickhouse.cloud"
PORT     = 8443
USERNAME = "default"
PASSWORD = "your_password_here"   # replace before running — never commit actual password

client = clickhouse_connect.get_client(
    host=HOST,
    port=PORT,
    username=USERNAME,
    password=PASSWORD,
    secure=True
)

# ── Config ────────────────────────────────────────────────────────────────────

BASE_URL = "https://divvy-tripdata.s3.amazonaws.com/"
MONTHS   = [f"2022{str(m).zfill(2)}" for m in range(1, 13)]
TABLE    = "cyclistic_rides"

# ── Helpers ───────────────────────────────────────────────────────────────────

def download_and_extract(month: str) -> pd.DataFrame:
    """Download ZIP from S3, extract CSV, return as DataFrame."""
    url = f"{BASE_URL}{month}-divvy-tripdata.zip"
    print(f"  Downloading {url}...")

    response = requests.get(url, timeout=60)
    response.raise_for_status()

    with zipfile.ZipFile(io.BytesIO(response.content)) as z:
        csv_name = [f for f in z.namelist() if f.endswith(".csv")][0]
        with z.open(csv_name) as f:
            df = pd.read_csv(f, dtype=str)

    print(f"  Extracted {len(df):,} rows")
    return df


def clean_and_enrich(df: pd.DataFrame) -> pd.DataFrame:
    """Parse types, drop nulls, compute derived columns."""

    # Parse datetimes
    df["started_at"] = pd.to_datetime(df["started_at"], format="mixed")
    df["ended_at"]   = pd.to_datetime(df["ended_at"],   format="mixed")

    # Parse coordinates
    df["start_lat"] = pd.to_numeric(df["start_lat"], errors="coerce")
    df["start_lng"] = pd.to_numeric(df["start_lng"], errors="coerce")
    df["end_lat"]   = pd.to_numeric(df["end_lat"],   errors="coerce")
    df["end_lng"]   = pd.to_numeric(df["end_lng"],   errors="coerce")

    # Drop rows with null coordinates — unusable for geospatial work
    before = len(df)
    df = df.dropna(subset=["start_lat", "start_lng", "end_lat", "end_lng"])
    dropped = before - len(df)
    if dropped > 0:
        print(f"  Dropped {dropped:,} rows with null coordinates")

    # Ensure station IDs are strings
    df["start_station_id"] = df["start_station_id"].fillna("").astype(str)
    df["end_station_id"]   = df["end_station_id"].fillna("").astype(str)

    # Fill missing station names
    df["start_station_name"] = df["start_station_name"].fillna("")
    df["end_station_name"]   = df["end_station_name"].fillna("")

    # Derived columns
    df["ride_duration_min"] = (
        (df["ended_at"] - df["started_at"])
        .dt.total_seconds()
        .div(60)
        .clip(lower=0)
        .astype("int32")
    )
    df["ride_date"] = df["started_at"].dt.date
    df["ride_hour"] = df["started_at"].dt.hour.astype("int8")

    return df


def insert_to_clickhouse(df: pd.DataFrame, month: str):
    """Insert cleaned DataFrame into ClickHouse."""

    columns = [
        "ride_id", "rideable_type", "started_at", "ended_at",
        "start_station_name", "start_station_id",
        "end_station_name", "end_station_id",
        "start_lat", "start_lng", "end_lat", "end_lng",
        "member_casual", "ride_duration_min", "ride_date", "ride_hour"
    ]

    client.insert_df(TABLE, df[columns])
    print(f"  Inserted {len(df):,} rows → {TABLE}")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print(f"Starting Cyclistic 2022 pipeline — {len(MONTHS)} months\n")

    total = 0
    for month in MONTHS:
        print(f"[{month}]")
        df = download_and_extract(month)
        df = clean_and_enrich(df)
        insert_to_clickhouse(df, month)
        total += len(df)
        print(f"  Running total: {total:,}\n")

    print(f"Pipeline complete — {total:,} total rows loaded")


if __name__ == "__main__":
    main()
