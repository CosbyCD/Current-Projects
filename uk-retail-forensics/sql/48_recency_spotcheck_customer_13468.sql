-- Query 48_recency_spotcheck_customer_13468

-- ============================================================
-- VERIFICATION: Recency field — individual spot-check
-- WHAT: Pulls customer 13468's actual transaction dates directly
--       to confirm the recency field's date math on a real,
--       individual case rather than trusting the aggregate alone.
-- WHY: Query 45 showed customer 13468 with recency_days = 1.
--      Confirming that's correct by checking their real last
--      order date against the dataset's max date (2011-12-09).
-- ============================================================
SELECT invoice_date FROM uk_retail.clean_transactions
WHERE customer_id = '13468'
ORDER BY invoice_date DESC
LIMIT 3;

-- RESULT: All three of the most recent rows for customer 13468 share
-- the identical timestamp "2011-12-08 10:39:00" -- multiple line items
-- from the same order/invoice, not a data anomaly. This confirms their
-- most recent transaction is 2011-12-08, one day before the dataset's
-- max date (2011-12-09), correctly yielding recency_days = 1.

-- CONFIRMED FINDING: PASSED. Query 45's recency field is verified
-- correct at the individual-customer level, not just trusted from the
-- aggregate query alone. This is the same customer already used as a
-- consistency cross-check when Query 45 was retrofitted earlier in
-- this project's documentation pass, and it's independently confirmed
-- again here at the row level -- the date math (dataset max date minus
-- each customer's own max invoice_date) is producing correct results.