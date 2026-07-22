-- Query 92_return_rate_line_item_level_v2

-- ============================================================
-- CHAPTER TWO, FIELD 6: Return Rate — line-item-level (rebuild)
-- WHAT: Recalculates line-item-level return rate per customer
--       against clean_transactions, following the methodology
--       established in Chapter One (query 12).
-- WHY: Second of the two return rate measures being rebuilt
--      against the clean table, completing the both-sides
--      comparison already established in Chapter One.
-- ============================================================
SELECT
    customer_id,
    COUNT(*) FILTER (WHERE invoice_no LIKE 'C%') AS cancelled_line_items,
    COUNT(*) AS total_line_items,
    ROUND(100.0 * COUNT(*) FILTER (WHERE invoice_no LIKE 'C%') / COUNT(*), 1) AS line_item_return_rate_pct
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY line_item_return_rate_pct DESC;

-- RESULT: 5,875 rows, matching Query 91's full population exactly.
-- Sorted descending, the top of the list again shows low-volume
-- customers at 100% (e.g. customer 16995 with 1 cancelled of 1 total
-- line item) -- the same small-n dominance pattern present in the
-- order-level version, now confirmed to also affect the line-item-
-- level measure.

-- CONFIRMED FINDING: Line-item-level return rate is successfully
-- rebuilt against the fully reconciled clean_transactions table,
-- matching Query 91's population exactly (same 5,875 customers, same
-- underlying source). This completes the rebuild of the sixth and
-- final core derived customer behavior field. Both return-rate
-- measures are now built against the clean table; see the next query
-- for the direct comparison, mirroring the Chapter One approach
-- (order-level vs. line-item-level rates diverge based on order
-- composition, not just cancellation frequency).