-- ============================================================
-- VERIFICATION: Recency field — individual spot-check
-- WHAT: Pulls customer 13468's actual transaction dates directly
--       to confirm the recency field's date math on a real,
--       individual case rather than trusting the aggregate alone.
-- WHY: Query 45 showed customer 13468 with recency_days = 1.
--      Confirming that's correct by checking their real last
--      order date against the dataset's max date (2011-12-09).
-- RESULT: Confirmed. Customer 13468's most recent transaction
--      is 2011-12-08 10:39:00 — one day before the dataset max
--      date, correctly yielding recency_days = 1.
-- ============================================================
SELECT invoice_date FROM uk_retail.clean_transactions
WHERE customer_id = '13468'
ORDER BY invoice_date DESC
LIMIT 3;