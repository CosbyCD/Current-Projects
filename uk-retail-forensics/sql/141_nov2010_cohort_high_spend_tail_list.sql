-- Query 141_nov2010_cohort_high_spend_tail_list

-- WHAT: Pull the full customer list for the Nov 2010 cohort's £5,000+
--       monetary_gross bucket (10 customers, per Query 117), with
--       recency, frequency, gross, and net, to identify who the
--       remaining 9 uncharacterized customers are (customer 16754
--       already characterized at Query 121).
-- WHY: Query 117 established the bucket count (10 customers) but never
--      listed the individual customer_ids. Query 121 later
--      characterized one of them (16754) as a byproduct of tracing the
--      350-399 bucket's monetary spike, but the other 9 were never
--      identified, let alone characterized. This pulls the actual list
--      so each can be individually traced the same way queries 111,
--      119, 137-140 did for the cancelled-bulk-order signature group.

SELECT
    customer_id,
    recency_days,
    frequency_completed,
    monetary_gross,
    monetary_net,
    cancellation_count
FROM uk_retail.customer_behavior_fields
WHERE recency_days BETWEEN 350 AND 424
  AND monetary_gross >= 5000
ORDER BY monetary_gross DESC;

-- RESULT (verified against pasted CSV): only 7 customers returned, NOT
-- the 10 stated at Query 117 -- 16754, 13564, 14134, 13206, 15369,
-- 12835, 14249. Customer 16754 confirmed matching Query 121's figures
-- exactly. Customer 13564 confirmed matching its appearance in Query
-- 121's raw bucket pull exactly (recency 353, freq 36, gross 15880.22,
-- net 15613.10, cancel 13). Cross-checking the 3-customer gap against
-- the known 23 never-converted customer list identifies the exact
-- cause: customers 16995 (recency 371), 13353 (388), and 17755 (423)
-- all fall within the 350-424 cohort range and all have NULL
-- monetary_gross. Query 117's original CASE statement had no explicit
-- NULL handling -- "WHEN monetary_gross < 5000" evaluates to NULL (not
-- TRUE) for a NULL input, so all three fell through to the catch-all
-- ELSE '£5,000+' branch, the same class of NULL-fallthrough bug
-- independently diagnosed for Tableau at Query 130.

-- CONFIRMED FINDING: Query 117's reported "10 customers, 1.6%" in the
-- £5,000+ bucket is WRONG -- the true count of genuine high-spend
-- customers in this cohort is 7, not 10. Three of the ten were
-- never-converted customers with zero real spend, miscategorized as the
-- cohort's top spenders by a CASE statement with no NULL branch. This
-- requires an append-only revision notation on Query 117's own
-- write-up: the corrected bucket breakdown removes 3 customers from
-- £5,000+ (10 -> 7) and, since those 3 were never counted anywhere else
-- in Query 117's five buckets either (they simply vanished from the
-- 618-customer total into a bucket where they don't belong), the
-- cohort's true monetary-known population is 615 (618 minus these 3),
-- not 618. This also means the £5,000+ percentage figure (1.6%) and the
-- corrected 24.3% figure for £1,000+ (from this retrofit's earlier
-- Query 117 correction) both need re-deriving against a 615-customer
-- base, not 618, for full accuracy.