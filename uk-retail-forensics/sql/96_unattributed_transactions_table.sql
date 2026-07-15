-- ============================================================
-- RESOLUTION: The no-customer-ID open question from query 35
-- WHAT: Builds uk_retail.unattributed_transactions as a copy of
--       every row in clean_transactions where customer_id IS
--       NULL (243,007 rows). clean_transactions itself is left
--       completely unchanged — this is a copy for reference and
--       future examination, not a removal.
-- WHY: Query 35's review (item 4) flagged this as an open
--      decision that was never formally resolved in writing,
--      even though every customer-level field query has
--      functionally excluded these rows all along via
--      WHERE customer_id IS NOT NULL. These rows are not
--      errors — unlike excluded_rows, nothing here has been
--      identified as a data entry mistake. They are legitimate
--      transactions missing a customer identifier (a common
--      real-world pattern: guest checkouts, anonymous sales).
--      Consistent with this project's standing rule — never
--      delete, always segregate and preserve — they are copied
--      into their own dedicated table for future examination
--      rather than silently filtered out with no record.
-- ============================================================
DROP TABLE IF EXISTS uk_retail.unattributed_transactions;

CREATE TABLE uk_retail.unattributed_transactions AS
SELECT * FROM uk_retail.clean_transactions
WHERE customer_id IS NULL;