-- Query 71_investigate_16446_remaining_rows

-- ============================================================
-- FOLLOW-UP: Customer 16446 — why 4 rows remain post-amendment
-- WHAT: Pulls the 4 remaining rows for customer 16446 directly,
--       to see what they are now that administrative codes have
--       been excluded.
-- WHY: Query 70 showed 16446 still has 4 rows post-amendment,
--       unlike 12918, 14802, 15802, and 13290. Re-examining the
--       original query 56 data shows 16446 was mischaracterized
--       earlier as part of the "exact-doubling" anomaly group —
--       their numbers ($168,472.50 gross / -$6.10 net) show
--       near-total cancellation, not the exact negative-mirror
--       pattern the other four customers showed. This checks
--       what's actually driving their numbers now.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, invoice_date
FROM uk_retail.clean_transactions
WHERE customer_id = '16446'
ORDER BY invoice_date;

-- RESULT: Four rows total. Two small, ordinary purchases on
-- 2011-05-18 (a scrubbing brush and a pastry brush, $1.65 and $1.25).
-- Then, on 2011-12-09: invoice 581483 purchases 80,995 units of
-- "PAPER CRAFT , LITTLE BIRDIE" (stock_code 23843) at £2.08 each, and
-- invoice C581484 cancels the exact same quantity twelve minutes
-- later (09:15:00 to 09:27:00). Arithmetic confirmed exactly against
-- both prior fields: gross (completed-only, Query 67) = $1.65 + $1.25
-- + (80,995 x $2.08) = $168,472.50 precisely; net (all rows, Query 69)
-- = the same sum plus the full cancellation = $2.90 precisely -- the
-- massive purchase and its exact-match cancellation net to zero,
-- leaving only the two small legitimate purchases as this customer's
-- real net value.

-- CONFIRMED FINDING: Customer 16446's entire anomaly is explained by
-- one extreme single transaction: 80,995 units of a single product,
-- purchased and self-cancelled twelve minutes later, accounting for
-- $168,469.60 of their $168,472.50 gross total. This is structurally
-- similar to the 12,540-unit outlier already investigated in Chapter
-- One (Query 29), but distinct in one respect: here the customer
-- cancelled it themselves almost immediately, rather than the
-- quantity sitting unexplained in isolation. Still requires the same
-- scrutiny applied to that earlier outlier before trusting it: see
-- Query 72 for the product's typical order size, to determine whether
-- 80,995 units is a plausible bulk order or another data entry error
-- warranting exclusion.