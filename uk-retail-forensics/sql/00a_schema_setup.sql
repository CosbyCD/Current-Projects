-- Query 00a_schema_setup

-- ============================================================
-- SETUP: Create dedicated schema
-- WHAT: Creates a schema separate from the existing Cyclistic
--       tables in public, to keep UK Retail work isolated.
-- WHY: Clean separation between projects on the same server.
-- ============================================================
-- Created via pgAdmin GUI: right-click Schemas → Create → Schema
-- Schema name: uk_retail, owner: postgres

-- RESULT: No queryable output — this step was performed via the pgAdmin
-- GUI (right-click Schemas → Create → Schema), not as an executable SQL
-- statement. Schema `uk_retail` created successfully.

-- CONFIRMED FINDING: N/A — infrastructure/setup step, not an analytical
-- finding. Establishes the isolated schema container for all subsequent
-- UK Retail II work, separate from the existing Cyclistic project tables.