-- Query 181_nov2010_cohort_exhibit_data_pull

-- WHAT: Pulls customer-level recency, frequency, monetary, first-purchase-date,
--       and last-order-date data for the confirmed 618-customer Nov 2010
--       Cohort (Query 100: recency_days BETWEEN 350 AND 424), alongside ALL
--       non-cohort customers tagged with a sequential row number (ordered by
--       customer_id). The row number lets exhibit-build filtering derive two
--       different comparison sample densities from this single pull, rather
--       than running the query twice: a dense population-context backdrop
--       (e.g. every 4th non-cohort customer, ~1,314 points) for the general
--       isolated view, and a peer-scale 1:1 comparison sample (e.g. every
--       9th, ~584 points) for a deeper-dive variant -- same sampling
--       approach as Query 134's Never Converted comparison trace, applied
--       at two densities.
-- WHY:  Building five planned 3D exhibits for the Nov 2010 Cohort (lifecycle,
--       isolated-against-population at two comparison densities,
--       first-purchase-date spread, and last-order-timing deep dive) requires
--       one row per customer rather than the aggregate/bucketed summaries
--       already produced (Queries 114, 117, 141). Pulling the full non-cohort
--       population once with a row number, instead of pre-filtering to a
--       fixed modulus in SQL, keeps the density decision at the exhibit-build
--       stage where it can be adjusted without re-querying the database.
--
-- NOTE: First-purchase-date originally targeted uk_retail.full_transactions
--       using a had_customer_id boolean flag, but that table has no
--       customer_id column at all (confirmed via schema check: invoice_no,
--       invoice_date, stock_code, description, quantity, unit_price,
--       country, had_customer_id only -- 8 columns). Corrected to pull from
--       uk_retail.raw_transactions instead, which carries customer_id
--       directly alongside invoice_no and invoice_date.
--
-- NOTE 2: First-purchase-date returned NULL for all 5,875 rows on first run.
--       Root cause: uk_retail.raw_transactions.customer_id carries a
--       trailing ".0" float-import artifact (e.g. "13085.0", length 7)
--       while uk_retail.customer_behavior_fields.customer_id does not (e.g.
--       "12346", length 5) -- both are varchar/text, so the join produced no
--       type error, just zero silent matches. Fixed using SPLIT_PART on '.'
--       to strip the suffix -- NOT RTRIM(customer_id, '.0'), which trims a
--       *character set* rather than a literal suffix and would corrupt any
--       customer_id genuinely ending in 0 (e.g. "13080.0" would wrongly
--       become "1308" instead of "13080"). Caught and corrected before this
--       query was run against the live database.
--
-- NOTE 3: Confirmed on live run that first_purchase_date for the Nov 2010
--       Cohort spans a wide range (2009-12-01 to 2010-12-21), not a narrow
--       Oct-Dec 2010 window as the cohort's name might suggest. The cohort
--       is defined by recency_days (last order timing), not first purchase
--       date -- some members joined over a year before their defining
--       "last order" window. Added last_order_date (MAX(invoice_date)) to
--       this pull to support a corrected "deeper dive" exhibit built around
--       actual last-order calendar timing, which is what genuinely defines
--       this cohort, alongside a separate exhibit showing the first-purchase
--       spread itself as a finding in its own right.
--
-- NOTE 4: last_order_date returned an implausibly wide spread on first run
--       against raw_transactions (2010-02-25 to 2011-07-18 -- over 500 days,
--       when a 350-424-day recency band should cluster last-order dates in
--       a ~75-day window). Root cause: this query joined against
--       raw_transactions, the untouched, pre-cleaning source table -- but
--       per the investigation log (Query 100), recency_days was actually
--       calculated against uk_retail.clean_transactions (MAX(invoice_date)),
--       which has deduplication, excluded-row removal, and customer_id
--       decimal-stripping already applied and verified (Query 38, confirmed
--       zero leftover ".0" artifacts in Query 43). raw_transactions still
--       contains the ~34,335 duplicate rows and ~4,709 excluded rows that
--       were deliberately removed before recency was ever computed, which
--       explains the inflated date range. Corrected to join against
--       clean_transactions instead, matching Query 100's original,
--       already-confirmed source of truth (180/307/131 across Oct/Nov/Dec
--       2010, summing to 618). Since clean_transactions.customer_id is
--       already stripped of the trailing ".0" artifact, the SPLIT_PART
--       fix from Note 2 is no longer needed for this join.

-- NOTE 5: last_order_date still didn't exactly match Query 100's confirmed
--       180/307/131 Oct/Nov/Dec 2010 split after the clean_transactions fix
--       (got 193/305/114, plus 3 stray dates outside that window). Root
--       cause: this query's order_dates CTE excluded cancellations
--       (invoice_no NOT LIKE 'C%'), computing each customer's last
--       *completed* order rather than their last transaction of any kind.
--       Per the investigation log, Query 45 (the original Field 1/Recency
--       build) describes recency_days as "days since each customer's most
--       recent order" / "most recent transaction" with no completed-only
--       filter, and Field 2 (Frequency) is the one field that explicitly
--       built both cancellation-inclusive and cancellation-exclusive forks
--       as a documented methodology decision -- Field 1 has no such fork,
--       meaning recency_days counts cancellations as activity. A customer
--       whose true last transaction was a December cancellation would have
--       last_order_date wrongly pulled back to an earlier completed order
--       (or excluded from the Oct-Dec window entirely) under the old filter.
--       Fixed by removing the invoice_no NOT LIKE 'C%' condition entirely
--       from order_dates, matching Field 1's original all-transactions
--       definition.

WITH order_dates AS (
    SELECT
        customer_id,
        MIN(invoice_date) AS first_purchase_date,
        MAX(invoice_date) AS last_order_date
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
cohort AS (
    SELECT customer_id
    FROM uk_retail.customer_behavior_fields
    WHERE recency_days BETWEEN 350 AND 424
),
non_cohort_numbered AS (
    SELECT
        customer_id,
        ROW_NUMBER() OVER (ORDER BY customer_id) AS rn
    FROM uk_retail.customer_behavior_fields
    WHERE customer_id NOT IN (SELECT customer_id FROM cohort)
)
SELECT
    cbf.customer_id,
    cbf.recency_days,
    cbf.frequency_completed,
    cbf.monetary_net,
    od.first_purchase_date,
    od.last_order_date,
    CASE
        WHEN c.customer_id IS NOT NULL THEN 'Nov 2010 Cohort'
        ELSE 'Non-Cohort'
    END AS population,
    ncn.rn AS non_cohort_row_number
FROM uk_retail.customer_behavior_fields cbf
LEFT JOIN order_dates od ON od.customer_id = cbf.customer_id
LEFT JOIN cohort c ON c.customer_id = cbf.customer_id
LEFT JOIN non_cohort_numbered ncn ON ncn.customer_id = cbf.customer_id
ORDER BY population, cbf.recency_days;

-- RESULT: 5,875 total rows (618 Nov 2010 Cohort / 5,257 Non-Cohort), exact
--       match to the established population. first_purchase_date and
--       last_order_date fully populated for all 618 cohort customers (zero
--       nulls, down from 3 on the pre-Note-5 run). last_order_date for the
--       cohort splits 180 / 307 / 131 across October / November / December
--       2010 -- an exact match to Query 100's already-confirmed result, with
--       zero customers falling outside that three-month window. Non-cohort
--       row-number modulus filtering produces 1,314 (mod-4, dense backdrop)
--       and 584 (mod-9, peer-scale) comparison sample sizes as designed.

-- CONFIRMED FINDING: This pull reproduces Query 100's confirmed 618-customer,
--       180/307/131 Oct/Nov/Dec 2010 cohort exactly, extending it with
--       first_purchase_date and two comparison-sample densities for five
--       planned 3D exhibits. Getting here required three sequential
--       corrections (Notes 2, 4, and 5), each one only identifiable because
--       an earlier field in this same project was built with an explicit,
--       documented methodological fork: Field 2 (Frequency, Chapter Two)
--       tested both a cancellation-inclusive and cancellation-exclusive
--       definition side by side, rather than picking one silently. That
--       precedent is what made Note 5's fix legible -- comparing Field 1's
--       (Recency's) actual build language against Field 2's explicit fork
--       made it possible to identify that recency_days counts cancellations
--       as activity, rather than guessing. Without that earlier
--       fork-and-document discipline, this query's cancellation-filter bug
--       would have had no clear reference point to check against, and the
--       193/305/114 near-miss result could easily have been accepted as
--       "close enough" instead of being caught and traced to its exact root
--       cause. This is the same principle behind this project's standing
--       "build both sides of a fork" rule (established with Return Rate in
--       Chapter One, repeated for Frequency, Overdue Multiple's whole-day/
--       fractional-day fork, and here) -- forks aren't just methodological
--       thoroughness for its own sake, they leave behind the exact evidence
--       trail needed to catch downstream mistakes that would otherwise be
--       invisible.