-- Query 76_recency_rebuild_v3

-- ============================================================
-- CHAPTER TWO, FIELD 1 REBUILD (v3): Recency
-- WHAT: Re-runs the recency field against clean_transactions
--       after the third amendment (query 74), which excluded
--       the 80,995-unit stock_code 23843 outlier.
-- WHY: Query 74 invalidated the row-level correctness of every
--      field built against the prior table version. Recency is
--      unlikely to be affected (it only cares about a
--      customer's single most recent transaction date), but
--      this must be confirmed, not assumed.
-- ============================================================
SELECT
    customer_id,
    MAX(invoice_date) AS last_order_date,
    EXTRACT(DAY FROM (SELECT MAX(invoice_date) FROM uk_retail.clean_transactions) - MAX(invoice_date))::INT AS recency_days
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY recency_days;

-- RESULT: Customer 13468 confirmed unchanged: last_order_date
-- 2011-12-08 10:39:00, recency_days = 1, identical to Query 45 and
-- Query 61. 5,875 rows total -- customer count held steady at the
-- second-amendment figure, confirming customer 16446 was not fully
-- removed (they retained other legitimate transactions, per Query
-- 71). Multiple customers still show recency_days = 0 with
-- last_order_date on 2011-12-09 (e.g. 17581, 12:21:00), confirming
-- the dataset's maximum date did not shift despite excluding customer
-- 16446's transaction, which was also dated 2011-12-09 -- other
-- legitimate transactions that same day keep the reference point
-- unchanged.

-- CONFIRMED FINDING: PASSED. Recency is confirmed unaffected in
-- substance by the third amendment -- a specific concern (whether
-- removing a transaction on the dataset's final day could have
-- shifted the reference date itself) was checked directly rather than
-- assumed, and confirmed not to be the case. Customer count holding
-- at 5,875 (not dropping further) is itself informative: it confirms
-- customer 16446 remains a real, retained customer with genuine
-- purchase history, distinct from the 66 customers whose entire
-- history was administrative noise and who were fully removed in the
-- second amendment. Field 1 (Recency) is now finalized against the
-- fully-reconciled clean_transactions table.