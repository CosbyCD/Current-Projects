-- Query 00b_raw_table_setup

-- ============================================================
-- SETUP: Create raw transactions table
-- WHAT: Creates the table matching the dataset's 8 original
--       columns exactly, no derived fields yet.
-- WHY: Raw data lands here unmodified first; all cleaning and
--      derived fields happen in later steps, never by editing
--      this table's original structure.
-- ============================================================
CREATE TABLE uk_retail.raw_transactions (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(20),
    description VARCHAR(255),
    quantity INTEGER,
    invoice_date TIMESTAMP,
    unit_price NUMERIC(10,2),
    customer_id VARCHAR(20),
    country VARCHAR(100)
);
-- Data loaded via pgAdmin Import/Export Data GUI tool
-- (right-click table → Import/Export Data → CSV, header = yes)
-- Source file: archive.zip (extracted), CC BY 4.0, Chen, D. (2012)

-- RESULT: Table `uk_retail.raw_transactions` created with all 8 original
-- dataset columns, no derived fields. Data loaded successfully via the
-- pgAdmin Import/Export GUI tool from the source CSV (Chen, D., 2012,
-- CC BY 4.0).

-- CONFIRMED FINDING: N/A — infrastructure/setup step, not an analytical
-- finding. Establishes the untouched raw-data landing table that all
-- subsequent cleaning and derived-field work builds on top of, per this
-- project's standing rule that source data is never edited in place.