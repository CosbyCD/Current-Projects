-- Query 41_customer_id_transposition_candidates

-- ============================================================
-- FOLLOW-UP: Testing specific digit-transposition candidates
-- WHAT: Checks whether either of two customer_ids that are
--       exactly one digit-transposition away from 13256 --
--       13265 (last two digits swapped: 5<->6) and 13526
--       (middle two digits swapped: 2<->5) -- placed any order
--       close in time to the anomalous invoice (Nov 25, 2011).
-- WHY: Query 40's wider pull surfaced these two as established,
--      active customer_ids (13265: 91 orders; 13526: 54 orders)
--      genuinely one keystroke-transposition away from 13256 --
--      the most specific, testable version of the "wrong
--      customer_id" hypothesis raised back in query 29's
--      follow-up thought. If either ordered around the same
--      date, that would be strong evidence the anomalous row
--      belongs to them, not to a standalone 13256.
-- ============================================================
SELECT customer_id, invoice_no, invoice_date
FROM uk_retail.raw_transactions
WHERE customer_id IN ('13265.0', '13526.0')
AND invoice_date BETWEEN '2011-11-18' AND '2011-12-02'
ORDER BY customer_id, invoice_date;

-- RESULT: Zero rows returned. Neither 13265 nor 13526 placed any order
-- within this ±1-week window around the Nov 25, 2011 anomalous invoice.

-- CONFIRMED FINDING: This rules out the most specific, testable version
-- of the transposition theory directly -- neither plausible candidate
-- was active anywhere near the date of the anomalous row, so there is
-- no timing evidence connecting either of them to invoice 578841.
-- Combined with Query 29 (quantity confirmed as a data entry error, no
-- comparable order exists anywhere in product 84826's two-year history)
-- and Query 40 (order-count alone doesn't distinguish 13256 from a
-- normal single-order customer), this closes the investigation with a
-- deliberately honest, non-tidy conclusion: the quantity is confirmed
-- wrong, but WHO the row actually belongs to remains genuinely
-- unresolved -- the original argument for a customer_id error did not
-- survive a wider test, and the two most plausible specific correction
-- candidates were directly ruled out. The row is excluded from
-- clean_transactions as an unattributable data entry error, not
-- reassigned to any specific guessed customer. This is a case where the
-- investigation reached a genuine dead end on one sub-question (who was
-- this really for) while still fully resolving the question that
-- actually mattered for the clean table (should this row be trusted as
-- written -- no).