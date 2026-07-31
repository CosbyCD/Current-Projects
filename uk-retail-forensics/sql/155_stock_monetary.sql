-- Query 155_stock_monetary

-- WHAT: Third field of stock_behavior_fields: monetary_gross (revenue
--       from completed orders only) and monetary_net (revenue across
--       all orders, cancellations included), per stock_code. Mirrors
--       the customer-side both-forks precedent (Query 54-58) exactly.
-- WHY: Cancellations matter for true SKU-level revenue the same way
--      they mattered for customer spend (the gross-vs-net discovery,
--      queries 111-121) -- a SKU with a large cancelled bulk order
--      would show inflated gross revenue the same way customer 12346
--      did. Both versions built and compared per the standing
--      both-forks rule.

SELECT
    a.stock_code,
    a.monetary_gross,
    b.monetary_net
FROM (
    SELECT stock_code, ROUND(SUM(quantity*unit_price)::NUMERIC,2) AS monetary_gross
    FROM uk_retail.full_transactions
    WHERE invoice_no NOT LIKE 'C%'
    GROUP BY stock_code
) a
JOIN (
    SELECT stock_code, ROUND(SUM(quantity*unit_price)::NUMERIC,2) AS monetary_net
    FROM uk_retail.full_transactions
    GROUP BY stock_code
) b
ON a.stock_code = b.stock_code
ORDER BY a.stock_code;

-- RESULT (verified against pasted CSV): 4,721 rows, matching Query 154's
-- SKU population exactly (confirmed identical stock_code sets). Top
-- gross/net gap outlier: stock_code 23166 ("MEDIUM CERAMIC TOP STORAGE
-- JAR"), gap £77,479.64 -- this is the same stock code from customer
-- 12346's cancelled bulk order (Query 111): 74,215 units x £1.04 =
-- £77,183.60, matching all but ~£296 of the total gap, which is
-- attributable to a small number of separate, unrelated cancellations
-- of the same item by other customers. Remaining top outliers (22423,
-- 85123A, 71477, 21108, 79323W, 21843, 84078A, 23113, 48185) range
-- £4,600-£16,500 in gap -- none yet individually traced.

-- CONFIRMED FINDING: Stock-side monetary is built and verified. The
-- top outlier directly cross-confirms a Chapter Three finding
-- (customer 12346's cancelled bulk order) from an independent angle --
-- strong evidence the stock-side framework is internally consistent
-- with the customer-side one, not just separately correct. The
-- remaining 9 outliers are not individually characterized here,
-- consistent with this sprint's deliberately narrow scope -- available
-- as candidates for Phase 4's headline finding if useful, not chased
-- exhaustively the way Query 118's customer-side signature was.

-- [FLAGGED] This query was run against full_transactions before the
-- double-counting bug (confirmed and fixed at Queries 151b/151c/151d)
-- was corrected. Unlike Queries 153 (MAX) and 154 (COUNT DISTINCT),
-- this field is NOT expected to be duplicate-insensitive:
-- SUM(quantity*unit_price) adds every row's value, so any SKU appearing
-- in the 228,297 duplicated unattributed rows would have its
-- monetary_gross and/or monetary_net inflated by roughly double that
-- portion of its revenue. The internal consistency check above (the
-- 23166/customer-12346 cross-confirmation) still holds regardless --
-- that cancelled bulk order was placed by an attributed customer, not
-- an unattributed transaction, so it isn't affected by this bug. But
-- the absolute monetary_gross/monetary_net figures for SKUs with
-- unattributed activity are not yet trusted. NOT reasoned safe --
-- requires an actual rerun against the corrected full_transactions and
-- a full diff, the same way Queries 153 and 154 were confirmed, before
-- this RESULT can be treated as final.

-- [REVISION -- confirmed via rerun and full diff against corrected
-- full_transactions] The RESULT and CONFIRMED FINDING blocks above are
-- superseded. Rerunning this exact query against the corrected table
-- (post Query 151d) and diffing both outputs directly found 4,184 of
-- 4,721 SKUs (89%) with different monetary_gross and/or monetary_net
-- values -- real, substantial impact, confirming this field was NOT
-- duplicate-insensitive as flagged. All differences point one direction
-- (buggy-table figures higher), consistent with inflation from
-- double-counted unattributed rows, not random noise.
--
-- Corrected RESULT: 23166 remains the top outlier, gap unchanged at
-- exactly £77,479.64 (£81,700.92 gross - £4,221.28 net, both lower than
-- originally reported but the gap itself identical) -- confirming the
-- customer-12346 cross-verification was never actually at risk, since
-- that cancelled bulk order came from an attributed customer, not an
-- unattributed transaction. The remaining top-9 outlier list is
-- UNCHANGED in identity and rank order (22423, 85123A, 71477, 21108,
-- 79323W, 21843, 84078A, 23113, 48185), with corrected gap values now
-- £4,678.68-£16,545.30 (previously reported as £4,600-£16,500 -- the
-- range itself barely moved). The underlying pattern was real and
-- survives the correction; only the precise absolute figures needed
-- restating.
--
-- CONFIRMED FINDING (superseding the version above): Stock-side
-- monetary is now built and verified against the corrected
-- full_transactions. The 23166/customer-12346 cross-confirmation holds
-- exactly. The top-9 remaining outlier SKUs are confirmed stable
-- through the bug fix, both in identity and approximate magnitude --
-- this field's qualitative findings were never actually compromised,
-- only its absolute dollar figures, which are now corrected. Any prior
-- reference to this query's RESULT block (before this revision) should
-- be treated as citing the buggy, pre-correction figures.