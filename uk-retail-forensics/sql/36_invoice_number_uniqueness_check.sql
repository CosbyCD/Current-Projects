-- Query 36_invoice_number_uniqueness_check

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

-- RESULT: 20 invoice numbers returned (query capped at LIMIT 20; true
-- total count of affected invoices not yet established), every one
-- showing exactly 2 distinct timestamps -- no invoice in this sample
-- spans 3 or more. This confirms the assumption underlying the
-- "dedupe all exact-match rows" policy is not universally safe on its
-- face: invoice numbers CAN legitimately repeat across two different
-- timestamps, meaning invoice_no alone is not a strict per-event unique
-- key. Three of these invoice numbers (494166, 499967, 500353) were
-- pulled in full row-level detail in Query 37 to determine what's
-- actually happening on them before drawing a final conclusion.

-- CONFIRMED FINDING: Invoice numbers are confirmed to NOT be strictly
-- one-timestamp-per-invoice across the dataset -- at least 20 invoice
-- numbers (likely more, since this query was capped at LIMIT 20) show
-- exactly 2 distinct invoice_date values each. This does not, on its
-- own, invalidate the exact-duplicate deduplication policy from Queries
-- 17-18 -- that policy requires a match across invoice_no, stock_code,
-- description, quantity, unit_price, customer_id, AND invoice_date
-- simultaneously, so a single invoice legitimately spanning two
-- timestamps would not trigger it unless the exact same stock_code also
-- repeated at both timestamps. Whether that's what's actually happening
-- needed direct row-level verification -- see Query 37, which confirmed
-- these are large multi-line orders (up to 190+ distinct stock codes on
-- one invoice) where manual data entry spanned more than sixty seconds,
-- causing the timestamp to roll forward mid-invoice, with every line
-- carrying a different stock_code. This confirms the dedupe-all policy
-- remains safe: large orders spanning multiple timestamps and true
-- exact-duplicate rows are unrelated phenomena that don't interfere
-- with each other.