-- add_labor_day.sql
-- Cyclistic Phase 2 — Add missing Labor Day record to holidays table
-- The holidays table was originally populated using Google holiday data as the source.
-- Labor Day (September 5, 2022) was not included in the source data and was therefore
-- absent from the table. The gap was discovered on June 25, 2026 when the
-- conversion_arc.sql query returned only two results (Independence Day and Memorial Day)
-- instead of the expected three. Labor Day was added manually to correct the omission.
-- CyberPhase Consulting | Cherrie Cosby | June 25, 2026

INSERT INTO holidays (holiday_name, holiday_date)
VALUES ('Labor Day', '2022-09-05')
