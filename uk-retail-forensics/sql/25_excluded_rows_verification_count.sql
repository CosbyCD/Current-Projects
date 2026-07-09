SELECT exclusion_reason, COUNT(*)
FROM uk_retail.excluded_rows
GROUP BY exclusion_reason
ORDER BY COUNT(*) DESC;