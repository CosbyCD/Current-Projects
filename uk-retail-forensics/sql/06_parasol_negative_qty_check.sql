-- Query 06_parasol_negative_qty_check

-- ============================================================
-- FINDING: Negative quantity with blank description — spot check
-- WHAT: Pulls full transaction history for stock_code 15044B
--       to directly compare a genuine cancellation (invoice
--       C554905) against the anomalous negative-quantity row
--       (invoice 556012) sitting in the same product's history.
-- WHY: Original query filtered by an incorrect customer_id
--      and returned nothing. Pulling the full stock code
--      history instead reveals both patterns side by side:
--      the real cancellation has a 'C' prefix, populated
--      description, real price, and valid customer_id; the
--      anomalous row has none of those.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE stock_code = '15044B'
ORDER BY invoice_date;

-- RESULT: Full transaction history for 15044B ("BLUE PAPER PARASOL")
-- confirms two structurally distinct row types. The genuine cancellation
-- (invoice C554905, 2011-05-27) carries the standard "C" invoice prefix,
-- a populated description matching every normal order row, a real unit
-- price (£2.95), a valid customer_id (14191.0), and quantity -1 —
-- consistent with a customer returning exactly one unit they'd bought.
-- The anomalous row (invoice 556012, no "C" prefix, 2011-06-08) has a
-- blank description, unit_price of £0.00, no customer_id at all, and
-- quantity -27 — none of the markers of a real customer cancellation.
-- Separately noted: three invoice numbers (536525, 537405, 537434) each
-- appear as exact duplicate rows (same invoice, same stock code,
-- quantity, price, customer, and timestamp, listed twice) — a distinct
-- data-quality issue from the negative-quantity question this query was
-- built to answer.

-- CONFIRMED FINDING: Confirms the hypothesis exactly. Genuine
-- cancellations are structurally identifiable by the "C" invoice prefix,
-- a populated description, a real price, and a valid customer_id. The
-- anomalous negative-quantity row (556012) lacks every one of those
-- markers — no "C" prefix, blank description, £0.00 price, no
-- customer_id — confirming it is not a real cancellation but a separate
-- category of data-quality issue (a stock/inventory adjustment entered
-- through the same table, not a customer transaction). This structural
-- signature — blank description + zero price + missing customer_id +
-- no "C" prefix — becomes the basis for identifying and excluding this
-- entire category of row in later cleaning steps (see Queries 07-10).
-- Also surfaced, as a secondary finding: exact duplicate invoice rows
-- (three found here alone: 536525, 537405, 537434) exist in the raw
-- table — a separate issue from negative quantities, tracked and
-- resolved in Queries 17-18.