-- Query 134_never_converted_full_range_sample

-- WHAT: Pulls a systematic sample of the converted population (every Nth
-- customer by customer_id, N chosen to yield ~600 rows) spanning the FULL
-- recency_days range (0-738+), rather than an ORDER BY that truncates to one
-- end of the distribution. Combined with all 23 never-converted customers
-- (unsampled), to correctly show where the never-converted group sits
-- relative to the totality of the population, not just a biased slice of it.

-- WHY: The Query 133 pull, ordered by recency_days ascending, was pasted into
-- chat and truncated at 977 rows -- but because of the ORDER BY, all 977
-- rows fell between recency_days 0 and 14. The 23 never-converted customers
-- sit at recency_days 371-738, entirely outside that range. The resulting
-- exhibit understated the population's spread and made the never-converted
-- cluster look isolated in empty space for the wrong reason -- not because
-- it's genuinely sparse out there, but because the backdrop never reached
-- that far. This query fixes the sampling method itself: systematic sampling
-- by customer_id (not sorted by the axis being plotted) guarantees coverage
-- across the full recency range regardless of where a paste gets cut off.

WITH customer_span AS (
    SELECT
        customer_id,
        MIN(invoice_date) AS first_transaction_date,
        COUNT(DISTINCT invoice_no) AS attempt_count
    FROM uk_retail.clean_transactions
    GROUP BY customer_id
),
numbered AS (
    SELECT
        cbf.customer_id,
        cbf.recency_days,
        cs.first_transaction_date,
        cs.attempt_count,
        CASE WHEN cbf.monetary_net IS NULL THEN TRUE ELSE FALSE END AS is_never_converted,
        ROW_NUMBER() OVER (ORDER BY cbf.customer_id) AS rn
    FROM uk_retail.customer_behavior_fields cbf
    JOIN customer_span cs ON cs.customer_id = cbf.customer_id
)
SELECT customer_id, recency_days, first_transaction_date, attempt_count, is_never_converted
FROM numbered
WHERE is_never_converted = TRUE
   OR rn % 9 = 0   -- systematic sample of converted customers, ~650 rows, spans full customer_id range
ORDER BY is_never_converted DESC, recency_days;

-- RESULT (Query 134): 650 rows returned. Systematic sample (every 9th
-- customer by customer_id) plus all 23 never-converted customers.
-- recency_days range confirmed: 0 to 737, spanning the full population
-- (vs. the flawed Query 133 pull, which was accidentally truncated to
-- recency_days 0-14 only). Distribution across 100-day buckets:

--   0-99 days:    304 customers
--   100-199 days:  69 customers
--   200-299 days:  51 customers
--   300-399 days:  57 customers
--   400-499 days:  76 customers
--   500-599 days:  41 customers
--   600-699 days:  36 customers
--   700-737 days:  16 customers

-- CONFIRMED FINDING: The systematic sampling method (ordering by customer_id
-- rather than by the axis being plotted) successfully corrected the Query 133
-- truncation bias. The sample's heavy concentration at low recency (304 of
-- 650 rows, 47%, under 100 days) is a genuine feature of the population --
-- most customers in this dataset are recently active -- not a sampling
-- artifact, since the sample spans the full range and the shape is
-- consistent with what a random draw from a recency-skewed population
-- should look like. This sample was used to rebuild never_converted_isolated_3d.html
-- as the corrected full-population backdrop, replacing the biased version
-- (preserved as never_converted_signal_check_partial_sample.html).

-- [CORRECTION — verified July 22, 2026: the RESULT block states "650
-- rows returned." The query actually returns 673 rows — 650
-- systematically-sampled converted customers PLUS the 23 never-converted
-- customers pulled in by the OR clause, which the original write-up
-- omitted from its own row count and bucket table. The 650-row figure
-- describes only the sampled-converted subset. Max recency in the full
-- 673-row result is 738, not 737.]