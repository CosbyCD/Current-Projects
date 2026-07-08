SELECT
    numeric_part,
    stock_code,
    description,
    SUM(quantity) AS total_qty_variant,
    SUM(SUM(quantity)) OVER (PARTITION BY numeric_part) AS total_qty_family
FROM (
    SELECT
        stock_code,
        description,
        quantity,
        CAST(SUBSTRING(UPPER(stock_code) FROM '^[0-9]+') AS INTEGER) AS numeric_part
    FROM uk_retail.raw_transactions
    WHERE stock_code ~ '^[0-9]+[A-Za-z]+$'
) sub
GROUP BY numeric_part, stock_code, description
ORDER BY numeric_part, stock_code;