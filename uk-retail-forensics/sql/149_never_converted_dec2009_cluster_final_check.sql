-- Query 149_never_converted_dec2009_cluster_final_check

-- WHAT: Re-derive the Dec 1-22, 2009 clustering figure for the 23
--       never-converted customers directly and cleanly, as a single
--       authoritative reference point -- independent of queries
--       131/132's original (miscounted) narrative.
-- WHY: Query 131 originally stated 15/23 (65%); corrected during this
--      retrofit to 14/23 (60.9%) after customer 13749 was found
--      miscounted into the wrong group. Query 132 repeated the
--      uncorrected 65% figure since it cited 131 directly. Before
--      declaring this fully closed, this establishes one clean,
--      re-derived reference count to check any other document
--      (exhibit captions, Chapter Four narrative, presentation notes)
--      against.

SELECT
    CASE
        WHEN cbf.monetary_net IS NULL AND cs.first_transaction_date BETWEEN '2009-12-01' AND '2009-12-22 23:59:59'
        THEN 'Dec 1-22, 2009 cluster'
        WHEN cbf.monetary_net IS NULL
        THEN 'Scattered (outside cluster)'
    END AS grouping,
    COUNT(*) AS customer_count
FROM uk_retail.customer_behavior_fields cbf
JOIN (
    SELECT customer_id, MIN(invoice_date) AS first_transaction_date
    FROM uk_retail.clean_transactions
    GROUP BY customer_id
) cs ON cs.customer_id = cbf.customer_id
WHERE cbf.monetary_net IS NULL
GROUP BY 1;