-- ============================================================
-- FOLLOW-UP: Nearby customer_id check — transposition/inversion
-- WHAT: Checks order counts for every customer_id numerically
--       close to 13256 (range 13246–13266), to see whether
--       13256 behaves like a normal customer compared to its
--       neighbors.
-- WHY: Query 29 confirmed the 12,540-unit row as a data entry
--      error on the quantity/price side. This checks the
--      customer_id side of the same row — specifically whether
--      13256 might be a transposed, inverted, or off-by-one
--      digit error by comparing its order volume against real,
--      established customers nearby in the ID sequence. This
--      comparison is what prompted looking at customer 13256's
--      full history directly next (query 31).
-- ============================================================
SELECT customer_id, COUNT(*) AS order_count
FROM uk_retail.raw_transactions
WHERE TRIM(customer_id) != ''
AND customer_id::NUMERIC BETWEEN 13246 AND 13266
GROUP BY customer_id
ORDER BY customer_id;