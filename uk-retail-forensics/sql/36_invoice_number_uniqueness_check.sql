-- ============================================================
-- VERIFICATION: Invoice number uniqueness — before finalizing
--               the duplicate-row deduplication policy
-- WHAT: Checks whether a single invoice_no ever appears with
--       more than one distinct invoice_date, which would mean
--       invoice numbers aren't as strictly unique per-event as
--       the dataset's documentation claims.
-- WHY: Before finalizing "dedupe all exact-match rows" as
--      policy for clean_transactions, testing the core
--      assumption underpinning that decision — that an
--      identical invoice_no, stock_code, quantity, price, and
--      timestamp could only occur once for a genuine event. If
--      invoice numbers turn out to repeat across genuinely
--      different dates/times, that would weaken confidence that
--      exact duplicates are always an artifact rather than
--      occasionally reflecting real, separate fulfillment
--      activity.
-- ============================================================
SELECT invoice_no, COUNT(DISTINCT invoice_date) AS distinct_timestamps
FROM uk_retail.raw_transactions
GROUP BY invoice_no
HAVING COUNT(DISTINCT invoice_date) > 1
ORDER BY distinct_timestamps DESC
LIMIT 20;