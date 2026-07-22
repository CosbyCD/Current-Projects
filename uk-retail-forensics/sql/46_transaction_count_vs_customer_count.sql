-- Query 46_transaction_count_vs_customer_count

-- ============================================================
-- FOLLOW-UP: Transaction row count vs. distinct customer count
-- WHAT: Counts total transaction rows with a non-null customer_id
--       in clean_transactions — NOT distinct customers, all rows.
-- WHY: First attempt at establishing a baseline for the recency
--      field's expected row count. Result (797,884) was
--      immediately recognized as too large to be a customer
--      count — it's counting every transaction row, not unique
--      customers. Corrected version (query 47) uses
--      COUNT(DISTINCT customer_id) instead.
-- ============================================================
SELECT COUNT(*) FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL;

-- RESULT: 797,884 — the total count of individual transaction rows
-- carrying a customer_id, not the number of distinct customers.

-- CONFIRMED FINDING: This result was immediately recognized as too
-- large to represent a customer count -- 797,884 vastly exceeds any
-- plausible customer population for this dataset. The query itself
-- was correct SQL, but answered the wrong question: COUNT(*) counts
-- every matching row (one per transaction line), not COUNT(DISTINCT
-- customer_id) (one per unique customer). Kept and documented as a
-- self-caught mistake rather than silently discarded, consistent with
-- this project's standard for handling this kind of error (see Query
-- 31's handling of the same situation). Superseded immediately by
-- Query 47, which uses the correct COUNT(DISTINCT customer_id)
-- formulation.