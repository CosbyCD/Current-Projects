-- Query 30_nearby_customer_ids_check

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

-- RESULT: Order counts across the 13246-13266 range vary widely (from 1
-- up to 1,920), confirming that a wide range of order-count magnitudes
-- are all independently legitimate within this ID neighborhood -- 13263
-- alone has 1,920 orders, and several others (13246 at 385, 13259 at
-- 324, 13266 at 327) are also high-volume, established customers.
-- Customer 13256 sits at exactly 1 order (the flagged row itself),
-- which is the minimum in this range but not uniquely so -- it shares
-- that distinction with no other customer in this specific 21-ID
-- window, though single-order customers are not inherently unusual
-- elsewhere in the dataset. No numerically adjacent customer_id (e.g.
-- 13255, 13257 -- candidates for a transposition of the last two
-- digits) shows a pattern that would explain 13256's single anomalous
-- row as a misplaced entry belonging to a neighboring account -- none
-- of the nearby IDs have an order history suggestively "missing" the
-- 12,540-unit transaction or otherwise showing signs of a swapped
-- entry.

-- CONFIRMED FINDING: This check does not find evidence of a
-- transposition, inversion, or off-by-one digit error explaining
-- customer_id 13256's single anomalous row -- no neighboring customer_id
-- shows a pattern consistent with "this is where the row actually
-- belongs." Combined with Query 29's finding, this narrows the likely
-- cause: the anomaly is probably confined to the quantity and/or price
-- fields on this one row (a genuine numeric entry error, e.g. a
-- misplaced decimal or a phantom unit count), rather than the
-- customer_id itself being wrong. This comparison directly motivated
-- pulling customer 13256's full history in isolation (Query 31) to
-- confirm there's nothing else on this account that changes the
-- picture, since the ID-neighborhood approach alone cannot rule out
-- every possible explanation -- it only rules out the specific
-- transposition/inversion hypothesis this query was built to test.