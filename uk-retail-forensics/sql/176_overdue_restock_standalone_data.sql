-- Query 176_overdue_restock_standalone_data

-- WHAT: Standalone data pull for a dedicated Overdue Restock deep-dive
--       exhibit (the third option from the earlier chart-split
--       decision, previously described but not built). Uses
--       overdue_multiple -- how many multiples of the SKU's own normal
--       restocking rhythm it's currently dormant for -- as an axis
--       directly, in place of recency_days. This is the literal number
--       that defines the category (Query 173's threshold), giving
--       purchasing a direct urgency ranking rather than raw days,
--       which isn't independently meaningful without knowing the SKU's
--       own normal rhythm.
-- WHY: The combined exhibit (Query 174) already shows this population
--      spreading naturally across recency/monetary/frequency -- it
--      doesn't have the flat-stripe collapse problem that justified
--      splitting Dead Stock from Seasonal Dormant. A standalone version
--      repeating the same three axes would add scale but not new
--      information. Swapping in overdue_multiple surfaces something
--      the combined view can't: direct urgency ranking, cross-
--      referenced against value and proven historical demand.

SELECT
    stock_code,
    ROUND((recency_days / NULLIF(avg_interval_fractional_day, 0))::NUMERIC, 1) AS overdue_multiple,
    monetary_net,
    frequency_completed,
    recency_days
FROM uk_retail.stock_behavior_fields
WHERE frequency_completed >= 5
  AND avg_interval_fractional_day IS NOT NULL
  AND recency_days >= 8 * avg_interval_fractional_day
  AND monetary_net >= 1000
ORDER BY overdue_multiple DESC;