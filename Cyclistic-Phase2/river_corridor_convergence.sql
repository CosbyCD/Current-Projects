-- river_corridor_convergence.sql
-- Cyclistic Phase 2 — Monthly ride counts at the Chicago River corridor
--
-- Purpose: Quantify the geographic convergence of member and casual riders
-- at the Chicago River corridor across all 12 months of 2022.
--
-- Background: The Ride Origins animated map and River Corridor Detail sheet
-- in the Tableau storyboard show a visible geographic overlap between member
-- and casual riders at the Chicago River fork in summer months. This query
-- was written to put a number behind that visual finding and identify the
-- specific month of maximum convergence.
--
-- Method: River corridor defined by bounding box coordinates —
-- latitude 41.88 to 41.90, longitude -87.64 to -87.62 — capturing
-- the river fork area and surrounding station cluster.
--
-- Key finding: July is the month of maximum convergence.
-- Casual riders: 53,288 | Member riders: 57,951 | Gap: 4,663
-- The two groups are within 5,000 rides of each other — the closest
-- they get at any point in the year, in the same geographic space.
--
-- Storyboard application: Supports the river corridor as the single
-- highest-value conversion moment in the dataset. Maximum casual density,
-- maximum member presence, minimum gap between the two groups.
--
-- Note: June shows second-highest convergence and strongest visual overlap
-- on the animated map. July has the tighter numerical gap.
-- Both months support the river corridor conversion recommendation.
--
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
