# Weather Data — Source, Validation, and Column Mapping Notes

## Source
Provider: Visual Crossing Weather
URL: https://www.visualcrossing.com/weather/weather-data-services
Location: Chicago, Illinois
Date Range: 2022-01-01 to 2022-12-31
Granularity: Daily
Units: US (°F, miles)
Retrieved: 2026-06-08

## Export Issue and Resolution
Visual Crossing exported 40 header columns but only 34 data columns per row.
Several optional columns (severerisk, lightningrisk, hailrisk, hailsize,
hailprobability, lightningdensity, o3, aqius) were selected in the UI
but returned empty — causing pandas to misalign all subsequent columns
when reading by header name.

Resolution: read CSV without header interpretation, mapped columns by
raw position index after inspecting raw[0] values directly.

## Final Column Position Map
Position 1  → datetime
Position 2  → tempmax
Position 3  → tempmin
Position 4  → temp
Position 5  → feelslike
Position 6  → humidity
Position 7  → precip
Position 8  → precipprob
Position 9  → preciptype
Position 10 → snow
Position 11 → snowdepth
Position 13 → windspeed
Position 18 → cloudcover
Position 19 → visibility
Position 20 → uvindex
Position 23 → sunrise
Position 24 → sunset
Position 25 → moonphase
Position 26 → moonrise
Position 27 → moonset
Position 30 → conditions

## Validation
- 365 rows confirmed — full year, no missing dates
- Sunrise/sunset times confirmed correct format (2022-01-01T07:19:06)
- Moon phase confirmed as decimal (0.0 to 1.0 scale)
- Conditions text confirmed accurate (Snow, Rain, Partially cloudy etc.)
- All temperature, precipitation, and wind columns verified against
  sample rows before loading into ClickHouse

## Column Rationale
Kept: tempmax, tempmin, temp, feelslike, humidity, precip, precipprob,
preciptype, snow, snowdepth, windspeed, cloudcover, visibility, uvindex,
sunrise, sunset, moonphase, moonrise, moonset, conditions

Excluded: windgust, windspeedmax, windspeedmean, windspeedmin, winddir,
sealevelpressure, solarradiation, solarenergy, severerisk, lightningrisk,
hailrisk, o3, aqius, description, icon, stations, source

UV Index retained — affects outdoor behavior decisions.
Sunrise/sunset/moonphase/moonrise/moonset retained — Chicago lakefront
riders demonstrably respond to light conditions and lunar cycles.
