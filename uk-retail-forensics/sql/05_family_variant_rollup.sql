-- Query 05_family_variant_rollup

-- WHAT: Rolls up quantity totals by stock code family (numeric part),
-- showing each individual variant's total quantity alongside the
-- family-wide total via a window function, for every trailing-letter
-- stock code and its associated descriptions.

-- WHY: Building on Query 04's confirmation that trailing-letter codes
-- are genuine product variants with a casing inconsistency problem, this
-- checks what a family-level rollup actually looks like once every
-- description variant (including blank and note-like descriptions) is
-- included — to see what else surfaces before deciding how to clean and
-- aggregate these codes. [Retrofit note: this query was run during an
-- exploratory pass without an original WHAT/WHY comment; this
-- documentation was written afterward, based on the query's actual
-- content and result, not reconstructed from a prior note.]

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

-- RESULT: Confirms two patterns beyond the casing issue already found in
-- Query 04. First, many stock_code + description combinations show a
-- blank description alongside one or more populated descriptions for the
-- same code (e.g. 15044B appears with blank description at qty -27 and
-- with "BLUE PAPER PARASOL" at qty 1672) — these blank-description rows
-- consistently carry negative or otherwise anomalous quantities, distinct
-- from the real product-description rows. Second, many populated
-- "descriptions" are actually informal operator notes rather than
-- product names — "check", "damaged", "missing", "found", "thrown away",
-- "wrong invc", "dotcom sales", "entry error" — each carrying its own
-- quantity adjustment, meaning a single stock_code can have 3-8 distinct
-- "description" rows that are really a mix of the true product name plus
-- several unrelated operational notes. Family-level totals
-- (total_qty_family) go negative for a substantial number of families
-- (e.g. 16065: -2, 17108: -364, 35610: -2,522, 72140: -4,981, 72024:
-- -3,447) — expected at this stage since raw_transactions has not yet
-- had cancellation invoices separated from completed orders.

-- CONFIRMED FINDING: Beyond the casing inconsistency already confirmed
-- in Query 04, the raw stock_code + description grain contains two
-- additional data-quality issues that must be resolved before any
-- reliable variant or family-level quantity rollup: (1) blank
-- descriptions are not random gaps — they cluster with anomalous
-- quantities and need their own resolution path (see Queries 15-16 for
-- the dedicated blank-description investigation), and (2) many non-blank
-- "descriptions" are operator annotations, not product names, and would
-- corrupt any description-based product grouping if treated as real
-- variant labels. Negative family-level totals at this stage are
-- expected and not yet a finding in themselves — they reflect
-- cancellation invoices still mixed into raw_transactions, resolved once
-- clean_transactions is built (Query 38).