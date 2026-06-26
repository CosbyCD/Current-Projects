-- river_corridor_convergence.sql
-- Cyclistic Phase 2 — Monthly ride counts at the Chicago River corridor
-- Defines river corridor as lat 41.88-41.90, lng -87.64 to -87.62
-- Used to quantify member vs casual geographic convergence by month
-- Key finding: July shows tightest convergence — 53,288 casual vs 57,951 member
-- Gap of fewer than 5,000 rides — closest the two groups get all year
-- Supports river corridor as highest-value conversion moment in the dataset
-- CyberPhase Consulting | Cherrie Cosby | June 25, 2026

SELECT 
    ride_month,
    member_casual,
    SUM(total_rides) as total_rides
FROM cyclistic_summary_v2
WHERE avg_start_lat BETWEEN 41.88 AND 41.90
AND avg_start_lng BETWEEN -87.64 AND -87.62
GROUP BY ride_month, member_casual
ORDER BY ride_month, member_casual
