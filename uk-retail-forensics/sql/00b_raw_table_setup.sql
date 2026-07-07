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
