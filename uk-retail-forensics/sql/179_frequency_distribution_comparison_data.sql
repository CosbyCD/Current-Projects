-- Query 179_frequency_distribution_comparison_data

-- WHAT: Pulls frequency_completed for both full populations side by
--       side -- customer_behavior_fields and stock_behavior_fields --
--       labeled by source, for a direct visual distribution comparison
--       confirming Query 178's statistical finding (comparable right-
--       skew: 2.08x customer, 2.36x stock).
-- WHY: A chart is the natural way to SHOW the skew comparison Query
--      178 already PROVED numerically -- visual confirmation of an
--      already-tested finding, not a substitute for the SQL check
--      that came first, consistent with this project's standard.

SELECT 'Customer' AS population, frequency_completed
FROM uk_retail.customer_behavior_fields
WHERE frequency_completed IS NOT NULL

UNION ALL

SELECT 'Stock (SKU)' AS population, frequency_completed
FROM uk_retail.stock_behavior_fields
WHERE frequency_completed IS NOT NULL;