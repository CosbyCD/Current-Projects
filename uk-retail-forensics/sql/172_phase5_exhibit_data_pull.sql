-- Query 172_phase5_exhibit_data_pull

-- WHAT: Combines all three Phase 4 headline categories into a single
--       labeled dataset for the Chapter Five exhibit.
-- WHY: One exhibit, three meaningful categories, no gray backdrop.

-- [PROVENANCE NOTE, added during the July 31, 2026 forensic review pass]
-- This file's SQL body was found as an unexpanded placeholder
-- ("[query as previously specified]"), not real SQL, with no separate
-- original recoverable. The query below is a RECONSTRUCTION, built by
-- combining Query 171's exact WHERE logic (Overdue Restock, 3x
-- threshold) with Query 165's seasonal-identification logic (the
-- 93-SKU Nov/Dec-clustering check) to derive the Dead Stock / Seasonal
-- Dormant split. Independently confirmed by running it and diffing the
-- output against the original CSV: exact match on total row count
-- (1,733) and category breakdown (1,532 / 108 / 93). This is now the
-- authoritative version of Query 172.

WITH seasonal_skus AS (
    SELECT DISTINCT om.stock_code
    FROM (
        SELECT
            ft.stock_code,
            EXTRACT(MONTH FROM ft.invoice_date) AS order_month,
            COUNT(DISTINCT ft.invoice_no) AS orders_this_month
        FROM uk_retail.full_transactions ft
        JOIN (
            SELECT stock_code
            FROM uk_retail.stock_behavior_fields
            WHERE recency_days >= 377
              AND frequency_completed IS NOT NULL
              AND frequency_completed <= 3
        ) ds ON ds.stock_code = ft.stock_code
        WHERE ft.invoice_no NOT LIKE 'C%'
        GROUP BY ft.stock_code, EXTRACT(MONTH FROM ft.invoice_date)
    ) om
    JOIN (
        SELECT
            stock_code,
            SUM(orders_this_month) AS total_orders
        FROM (
            SELECT
                ft.stock_code,
                EXTRACT(MONTH FROM ft.invoice_date) AS order_month,
                COUNT(DISTINCT ft.invoice_no) AS orders_this_month
            FROM uk_retail.full_transactions ft
            JOIN (
                SELECT stock_code
                FROM uk_retail.stock_behavior_fields
                WHERE recency_days >= 377
                  AND frequency_completed IS NOT NULL
                  AND frequency_completed <= 3
            ) ds ON ds.stock_code = ft.stock_code
            WHERE ft.invoice_no NOT LIKE 'C%'
            GROUP BY ft.stock_code, EXTRACT(MONTH FROM ft.invoice_date)
        ) sub
        GROUP BY stock_code
    ) t ON t.stock_code = om.stock_code
    WHERE om.orders_this_month = t.total_orders
      AND om.order_month IN (11, 12)
)
SELECT stock_code, recency_days, monetary_net, frequency_completed,
    'Overdue Restock' AS category
FROM uk_retail.stock_behavior_fields
WHERE frequency_completed >= 5
  AND avg_interval_fractional_day IS NOT NULL
  AND recency_days >= 3 * avg_interval_fractional_day

UNION ALL

SELECT stock_code, recency_days, monetary_net, frequency_completed,
    'Dead Stock Candidate' AS category
FROM uk_retail.stock_behavior_fields
WHERE recency_days >= 377
  AND frequency_completed IS NOT NULL
  AND frequency_completed <= 3
  AND stock_code NOT IN (SELECT stock_code FROM seasonal_skus)

UNION ALL

SELECT stock_code, recency_days, monetary_net, frequency_completed,
    'Seasonal Dormant' AS category
FROM uk_retail.stock_behavior_fields
WHERE stock_code IN (SELECT stock_code FROM seasonal_skus);

-- RESULT (verified against pasted CSV): 1,733 rows total -- 1,532
-- Overdue Restock, 108 Dead Stock Candidate, 93 Seasonal Dormant. The
-- Dead Stock / Seasonal split confirms exactly against Query 164/165
-- (108 + 93 = 201). However, Overdue Restock at 1,532 rows (88% of the
-- exhibit) inherits the same over-loose threshold problem flagged at
-- Query 171 -- this pull is NOT ready for the exhibit as-is.

-- CONFIRMED FINDING: category-assignment logic is correct and verified
-- for the two dead-stock-derived categories. Superseded pending Query
-- 162's threshold retightening -- rerun with the corrected Overdue
-- Restock definition before this feeds the actual exhibit.

-- [FLAGGED] This query was run before stock_behavior_fields was
-- rebuilt against the corrected full_transactions. The row COUNTS
-- (1,733 total, 1,532/108/93 split) are structurally SAFE -- every
-- WHERE clause across all three branches uses only recency_days,
-- frequency_completed, avg_interval_fractional_day, and (via
-- seasonal_skus) COUNT(DISTINCT invoice_no) -- all already confirmed
-- unaffected. monetary_net appears only as a displayed column here, not
-- in any filter -- so it needs refreshing for display purposes, but
-- category membership and the row counts are not at risk. This entire
-- pull is superseded regardless once Query 173's retightened threshold
-- replaces the Overdue Restock branch -- lower priority to rerun this
-- exact version than to get 173's actual 572-count confirmed.

-- [CONFIRMED via rerun against the rebuilt stock_behavior_fields] The
-- reconstructed query above ran successfully and reproduced the exact
-- same shape: 1,733 total rows, 1,532/108/93 split, identical to the
-- original CSV. This validates both that the reconstruction is
-- functionally correct and that category membership/row counts were
-- never at risk from the double-counting bug, consistent with the
-- structural reasoning above. monetary_net values within this pull are
-- now current (drawn from the corrected stock_behavior_fields).