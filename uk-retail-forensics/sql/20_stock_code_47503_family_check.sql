-- ============================================================
-- FINDING: 47503 family — trailing space false positive, and
--          placeholder text in description ("check", "found")
-- WHAT: Pulls every variant of the 47503 stock code family to
--       verify whether "47503J " (with trailing space) found
--       in query 19 is a genuine administrative code or a data
--       entry error on an existing product.
-- WHY: Query 19's non-numeric stock code regex caught
--      "47503J " due to a trailing space, inflating the true
--      count. Confirmed: 47503J already exists as a normal
--      product ("SET/3 FLORAL GARDEN TOOLS IN BAG", 80
--      occurrences) — the spaced version is the same product
--      with a stray whitespace character, not a real
--      administrative code. Also surfaced a new finding: two
--      rows on 47503H have literal placeholder text ("check",
--      "found") in the description field instead of a real
--      product description — a pattern not yet characterized.
-- ============================================================
SELECT stock_code, description, COUNT(*)
FROM uk_retail.raw_transactions
WHERE stock_code LIKE '47503%'
GROUP BY stock_code, description;