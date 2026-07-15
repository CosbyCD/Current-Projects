-- ============================================================
-- VERIFICATION: Final customer_behavior_fields table — spot-check
-- WHAT: Pulls customer 13468's full row from the assembled
--       final table, to confirm every field matches the values
--       already independently verified across this chapter.
-- WHY: Customer 13468 was already spot-checked individually for
--      recency (query 48: recency_days = 1). Confirming the
--      same value carries through correctly in the final
--      joined table, rather than assuming the join logic
--      preserved every component correctly.
-- ============================================================
SELECT * FROM uk_retail.customer_behavior_fields
WHERE customer_id = '13468';