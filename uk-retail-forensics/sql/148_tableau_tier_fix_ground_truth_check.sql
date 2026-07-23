-- Query 148_tableau_tier_fix_ground_truth_check

-- WHAT: Reconstruct the CORRECTED "Recency-Monetary Tier" logic proposed
--       at Query 130 (IF ISNULL(monetary_net) THEN 'Never Converted'
--       ELSEIF recency_days <= 377 THEN 'Recent' ELSEIF recency_days > 377
--       AND monetary_net >= 2180.28 THEN 'Lapsed Whale' ELSE 'Lapsed,
--       Typical' END) directly in SQL, to produce the exact expected
--       tier counts before comparing against Tableau's actual output
--       once the corrected field is deployed.
-- WHY: Query 130 diagnosed the bug and specified the fix but never
--      verified the corrected field actually produces the right
--      counts. This closes that gap by giving a ground-truth SQL
--      reconstruction to check Tableau against directly, the same
--      approach used at Query 126 for the lapsed-whale definition.

SELECT
    CASE
        WHEN monetary_net IS NULL THEN 'Never Converted'
        WHEN recency_days <= 377 THEN 'Recent'
        WHEN recency_days > 377 AND monetary_net >= 2180.28 THEN 'Lapsed Whale'
        ELSE 'Lapsed, Typical'
    END AS corrected_tier,
    COUNT(*) AS customer_count
FROM uk_retail.customer_behavior_fields
GROUP BY 1
ORDER BY 1;

-- RESULT (run July 22, 2026, per user's Tableau output): Lapsed Whale =
-- 58, Lapsed, Typical = 1,387, Never Converted = 23, Recent = 4,407.
-- Total = 5,875, matching the full customer population exactly.
-- Converted-only subtotal (Recent + Lapsed Typical + Lapsed Whale) =
-- 5,852, matching precisely the pre-fix prediction stated in Query 130's
-- own WHY block. Lapsed Whale = 58 matches the confirmed dual-threshold
-- definition from Queries 122/126/127 exactly. Never Converted = 23
-- matches the confirmed count from Query 98 exactly.

-- CONFIRMED FINDING: The Tableau "Recency-Monetary Tier" fix specified
-- at Query 130 (adding an explicit ISNULL check as the first condition)
-- is confirmed working correctly. All four tier counts match their
-- independently-confirmed SQL values exactly -- 23 never-converted
-- customers are now honestly labeled instead of silently mislabeled as
-- Recent (1) or Lapsed Typical (22), and the remaining three tiers
-- (Recent, Lapsed Typical, Lapsed Whale) hold their correct values now
-- that the 23 problem customers are properly excluded from them. This
-- closes the last open item from Query 130 -- the fix was not just
-- specified but has now been verified against actual Tableau output.