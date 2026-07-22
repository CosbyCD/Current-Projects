-- Query 78_frequency_completed_rebuild_v3

-- ============================================================
-- CHAPTER TWO, FIELD 2 REBUILD (v3): Frequency — completed orders only
-- WHAT: Re-runs completed-orders-only frequency against
--       clean_transactions after the third amendment (query 74).
-- WHY: The 80,995-unit stock_code 23843 transaction (customer
--       16446) carried a real, distinct invoice number and would
--       have been counted as a completed order in prior versions
--       of this field. Confirming it's no longer counted.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_completed_only
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY frequency_completed_only DESC;

-- RESULT: Top customer 14911 unchanged at 373 -- the third amendment
-- doesn't touch their transaction history, consistent with the
-- amendment being a narrow, single-customer exclusion. 5,852 rows
-- total, matching the second-rebuild population exactly (same 23
-- zero-completed-order customers still absent). Customer 16446
-- confirmed at exactly 1 -- their one remaining legitimate invoice
-- (553573, the scrubbing brush and pastry brush), with the excluded
-- 581483 purchase no longer counted.

-- CONFIRMED FINDING: PASSED. Customer 16446's frequency_completed
-- dropped to exactly 1, confirming the erroneous 80,995-unit invoice
-- is no longer counted as a real completed order. This is checked
-- directly at the individual-customer level, not inferred from the
-- aggregate alone. See Query 79 for the matching all-orders rebuild,
-- which the log indicates also returns 1 for this customer --
-- resolving their cancellation_gap to exactly 0.