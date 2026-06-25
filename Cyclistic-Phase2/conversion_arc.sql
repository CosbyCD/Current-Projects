-- conversion_arc.sql
-- Cyclistic Phase 2 — Memorial Day, Independence Day, Labor Day conversion rates
-- Establishes the seasonal conversion arc: season opener, peak, season closer
-- Confirms volume is the wrong metric for conversion targeting
-- Results: Independence Day 60.75% | Labor Day 53.62% | Memorial Day 41.19%
-- Note: Labor Day (2022-09-05) was added to holidays table manually on June 25, 2026
-- CyberPhase Consulting | Cherrie Cosby | June 25, 2026

SELECT 
    h.holiday_name,
    SUM(CASE WHEN c.member_casual = 'casual' THEN c.total_rides END) as casual_rides,
    SUM(c.total_rides) as total_rides,
    ROUND(SUM(CASE WHEN c.member_casual = 'casual' THEN c.total_rides END) / SUM(c.total_rides) * 100, 2) as conversion_rate
FROM cyclistic_summary_v2 c
LEFT JOIN holidays h ON c.ride_date = h.holiday_date
WHERE h.holiday_name IN ('Memorial Day', 'Independence Day', 'Labor Day')
GROUP BY h.holiday_name
ORDER BY conversion_rate DESC
