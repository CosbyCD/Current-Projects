# Chapter Four — Tableau Calculated Fields

Documentation of every calculated field built in Tableau Desktop Professional for the Chapter Four dashboard, following the same discipline as the SQL investigation: each field states what it does, why it's built that way, its exact formula, and the verification check used to confirm it works correctly before being trusted in the dashboard. Per this project's standing rule, nothing is treated as working correctly on the strength of "it looks right" — every field below was checked against a known number from the SQL investigation before being accepted.

**Data source:** live PostgreSQL connection, `uk_retail.customer_behavior_fields`, connected via Tableau Desktop Professional (10-day trial).

**Verification history:** every field below was verified twice, independently. First at build time (documented in each field's Verification section), and a second time via a full clean rebuild from a blank sheet with no filters carried over from prior checks — done specifically to rule out cross-contamination from leftover filters (an issue that caused a false 58-vs-59 discrepancy scare mid-build; see Field 4). Both passes agree exactly on every field.

---

## Field 1: Spend (Net)

**WHAT:** Wraps the raw `Monetary Net` field in its own named calculated field.

**WHY:** Per this project's standing decision (Query 118), `monetary_net` — not `monetary_gross` — is the primary spend metric for Chapter Four, since gross materially overstates real customer value for at least 7 identified customers due to cancelled bulk orders. Building this as its own calculated field, rather than using the raw `Monetary Net` column directly throughout the dashboard, means a future gross/net toggle only requires editing this one formula rather than rebuilding every chart that references spend.

**Formula:**
```
[Monetary Net]
```

**Verification:** Filtered to Customer Id = 12346, confirmed the value returns **£169.36** (not the £77,352.96 gross figure established as a cancelled-order artifact in Query 111).

**Result:** ✅ Passed — £169.36 confirmed. Re-verified via clean rebuild.

---

## Field 2: Nov 2010 Cohort Flag

**WHAT:** Flags customers belonging to the confirmed 618-customer November 2010 seasonal stocking cohort.

**WHY:** Encodes the cohort boundary established in Query 100 (`recency_days BETWEEN 350 AND 424`) as a reusable dimension for filtering, coloring, and drill-down targeting throughout the dashboard.

**Formula:**
```
IF [Recency Days] >= 350 AND [Recency Days] <= 424 THEN "Nov 2010 Cohort" ELSE "Other" END
```

**Verification:** Filtered to "Nov 2010 Cohort" only, counted distinct Customer Id.

**Result:** ✅ Passed — **618** customers, matching Query 100 exactly. Re-verified via clean rebuild: 618 Nov 2010 Cohort / 5,257 Other (5,875 total).

---

## Field 3: Never Converted Flag

**WHAT:** Flags the 23 cancellation-only customers who never completed a purchase.

**WHY:** Encodes the Query 98 definition (`frequency_completed IS NULL AND monetary_gross IS NULL`) so these customers can be consistently excluded from or highlighted within spend-based dashboard views.

**Formula:**
```
IF ISNULL([Frequency Completed]) AND ISNULL([Monetary Gross]) THEN "Never Converted" ELSE "Converted" END
```

**Verification:** Filtered to "Never Converted" only, counted distinct Customer Id.

**Result:** ✅ Passed — **23** customers, matching Query 98 exactly. Re-verified via clean rebuild: 23 Never Converted / 5,852 Converted (5,875 total).

---

## Field 4: Recency-Monetary Tier (Rev. Q105/106/122)

**WHAT:** Four-way tier classifying customers as "Never Converted," "Recent," "Lapsed, Typical," or "Lapsed Whale" — encoding the revised funnel finding (average spend declines with recency, but a real population of high-value dormant customers exists) rather than Chapter Three's original absolute claim.

**WHY:** A simple recency cutoff alone would misrepresent the finding. This field requires two conditions to correctly separate the typical-customer pattern from the confirmed exception population, plus an explicit null check so customers with no spend data are labeled honestly rather than silently miscategorized. Field name cites the queries that established both the finding (105/106) and the corrected thresholds (122), per this project's citation standard.

**Threshold history (see investigation log for full account):**
- Recency threshold: originally guessed at 400 days; corrected to **377 days** via Query 123 (the actual boundary of the most-lapsed recency quartile).
- Monetary threshold: originally guessed at £5,000; corrected to **£2,180.28** via Query 122 (the actual boundary of the confirmed lapsed-whale population).
- A discrepancy between the NTILE-based population count (59, Queries 106/115) and this field's fixed-threshold count (58) was investigated in Queries 124–127 and traced to non-deterministic tie-breaking in PostgreSQL's `NTILE` function. The 58-count fixed-threshold definition was adopted as the standard for this field — see Query 127's Confirmed Finding for the full account.

**Formula (original, three-way):**
```
IF [Recency Days] <= 377 THEN "Recent"
ELSEIF [Recency Days] > 377 AND ROUND([Spend (Net)], 2) >= 2180.28 THEN "Lapsed Whale"
ELSE "Lapsed, Typical"
END
```

**Verification (original):** Filtered to "Lapsed Whale" only, counted distinct Customer Id.

**Result (original):** ✅ Passed — **58** customers, matching the corrected fixed-threshold definition (Query 126) after the NTILE non-determinism was identified and resolved (Query 127). Does not match the original NTILE-based 59-count from Queries 106/115 — this is expected and documented, not an error. Re-verified via clean rebuild: 58 Lapsed Whale / 1,409 Lapsed, Typical / 4,408 Recent (5,875 total).

**[REVISION — corrected by Query 130 (never_converted_tier_leakage_check), run July 19, 2026]**

Building a dedicated 3D exhibit for "Lapsed, Typical" surfaced a 22-customer count mismatch (1,387 expected vs. 1,409 shown). Query 130 confirmed the cause: `Spend (Net)` is NULL for the 23 never-converted customers (Query 98), and Tableau's `ELSEIF` silently evaluates a NULL comparison as false rather than erroring — so all 23 were falling through to "Recent" (1 customer) or "Lapsed, Typical" (22 customers) undetected, with no indication anything was wrong.

**Corrected formula:**
```
IF ISNULL([Spend (Net)]) THEN "Never Converted"
ELSEIF [Recency Days] <= 377 THEN "Recent"
ELSEIF [Recency Days] > 377 AND ROUND([Spend (Net)], 2) >= 2180.28 THEN "Lapsed Whale"
ELSE "Lapsed, Typical"
END
```

**Verification (post-fix):** Full four-way breakdown, no filter.

**Result (post-fix):** ✅ Passed — **23 Never Converted / 4,407 Recent / 1,387 Lapsed, Typical / 58 Lapsed Whale**, summing correctly to 5,875. The Lapsed Whale count (58) was unaffected by this bug, since none of the 23 never-converted customers could ever satisfy the whale threshold — the leakage was confined to the Recent/Lapsed-Typical boundary.

---

## Field 6: Exhibit URL (Funnel Tier)

**WHAT:** Routes each of the four `Recency-Monetary Tier` values to its corresponding drill-down exhibit filename, for use in the Chapter Four dashboard's "Go to URL" mark-click action.

**WHY:** The dashboard's URL action needs a field that resolves to an actual filename at click-time. Built after an initial mapping mistake (the "Lapsed Whale" drill-down was first pointed at the 2D `gutcheck_105_121_funnel_lockstep_review.html` verification summary instead of a genuine 3D exhibit — caught on first test click and corrected). Three dedicated exhibits (`lapsed_whale_isolated_3d.html`, `lapsed_typical_isolated_3d.html`, `recent_isolated_3d.html`) were built from the corrected tier populations to fulfill the original Chapter Four design intent of purpose-built 3D deep-dives rather than reused general charts.

**Formula:**
```
IF ISNULL([Spend (Net)]) THEN "uk_retail_rfm_3d_log.html"
ELSEIF [Recency-Monetary Tier (Rev. Q105/106/122)] = "Lapsed Whale"
THEN "lapsed_whale_isolated_3d.html"
ELSEIF [Recency-Monetary Tier (Rev. Q105/106/122)] = "Lapsed, Typical"
THEN "lapsed_typical_isolated_3d.html"
ELSE "uk_retail_rfm_3d_log.html"
END
```

**Verification:** `Recency-Monetary Tier` and `Exhibit URL (Funnel Tier)` placed side by side on Rows, no filter — confirmed all four tiers resolve to the correct filename:
- Never Converted → `uk_retail_rfm_3d_log.html`
- Recent → `uk_retail_rfm_3d_log.html`
- Lapsed, Typical → `lapsed_typical_isolated_3d.html`
- Lapsed Whale → `lapsed_whale_isolated_3d.html`

**Result:** ✅ Passed. Live end-to-end test on the actual dashboard confirmed clicking each bar opens the correct exhibit in a new browser tab.

**Note on Never Converted and Recent sharing a target:** both currently route to the general RFM cube as a reasonable default. A dedicated exhibit for the 23-customer Never Converted group was judged unnecessary given its small size — open for reconsideration, see investigation log Open Items.

**[REVISION — appended following Field 7's build, run July 23, 2026]**

Field 7 (`Exhibit URL (Frequency Spike)`) followed the same design precedent noted here: "Below Top Decile" customers route to the general RFM cube (`uk_retail_rfm_3d_log.html`) rather than a dedicated exhibit, no dedicated build was made for that group. Worth noting the cases aren't fully equivalent in scale: Never Converted is a 23-customer edge case (0.4% of the population), while Below Top Decile is the majority group (roughly 90% of customers, the complement of the 586-customer top decile) — so the "small size, dedicated exhibit judged unnecessary" reasoning applies more directly to Never Converted than it does to Below Top Decile, where the general RFM cube functioning as the default view is closer to its original intended role than a special case. Both open items — Never Converted and Below Top Decile — remain unresolved and are grouped here for whenever exhibit-routing is revisited, per investigation log Open Items.

---

## Field 5: Frequency Spike Tier (Rev. Q108/128)

**WHAT:** Two-way tier flagging customers in the top spending decile, where Query 108 found order frequency spikes sharply.

**WHY:** Chapter Three's original chart-rotation estimate placed the frequency spike in the "top ~15-20%" of spenders. Query 108 revised this to the top decile specifically (90th+ percentile). This field encodes that corrected boundary.

**Threshold:** £5,224.45 net spend (90th percentile), computed via `PERCENTILE_CONT` in Query 128 rather than `NTILE`, specifically to avoid repeating the tie-breaking non-determinism issue found in Query 127. This value is analogous to but not identical with Query 108's original `monetary_gross`-based decile threshold, since it uses `monetary_net` per this project's standing gross-to-net metric decision.

**Formula:**
```
IF ROUND([Spend (Net)], 2) >= 5224.45 THEN "Top Decile (Spike Zone)" ELSE "Below Top Decile" END
```

**Verification:** Filtered to "Top Decile (Spike Zone)" only, counted distinct Customer Id.

**Result:** ✅ Passed — **586** customers, matching Query 128 exactly (10.0% of the ~5,852-customer population, as expected for a 90th-percentile cutoff). Re-verified via clean rebuild.

**Bonus cross-check:** Filtering further to a crosstab against `Recency-Monetary Tier` showed the 586 top-decile spenders split as 15 "Lapsed Whale" + 571 "Recent," with **zero** in "Lapsed, Typical" — confirming the two fields' definitions interact exactly as their thresholds predict (a top-decile spender's net spend of £5,224.45+ always clears the £2,180.28 whale threshold, so "Lapsed, Typical" is mathematically impossible for this group). This exact 15/571 split reproduced identically on the clean-rebuild verification pass.

---

## Field 7: Exhibit URL (Frequency Spike)

**WHAT:** Routes each of the two `Frequency Spike Tier` values to its corresponding drill-down exhibit filename, for use in the "Frequency Spike Overview" sheet's mark-click (Select) URL action.

**WHY:** Same purpose as Field 6, applied to the Frequency Spike Tier chart: the dashboard's URL action needs a field that resolves to an actual filename at click-time. A dedicated 3D exhibit (`frequency_spike_tier_isolated_3d.html`, Query 180, 586 customers matching Query 128 exactly) was built for the "Top Decile (Spike Zone)" population; customers below the top decile route to the general RFM cube as a reasonable default, consistent with the precedent set in Field 6.

**Formula:**
```
IF [Frequency Spike Tier (Rev. Q108/128)] = "Top Decile (Spike Zone)"
THEN "frequency_spike_tier_isolated_3d.html"
ELSE "uk_retail_rfm_3d_log.html"
END
```

**Verification:** `Frequency Spike Tier` and `Exhibit URL (Frequency Spike)` placed side by side on Rows, no filter — confirmed both tiers resolve to the correct filename:
- Below Top Decile → `uk_retail_rfm_3d_log.html`
- Top Decile (Spike Zone) → `frequency_spike_tier_isolated_3d.html`

**Result:** ✅ Passed. Live end-to-end test on the actual dashboard confirmed clicking the "Top Decile (Spike Zone)" bar opens the correct exhibit.

**Build note:** The field itself was valid from first build and required no formula correction. The URL action built on top of it initially failed silently — the URL box contained this field's placeholder concatenated with a leftover `Exhibit URL (Funnel Tier)` placeholder plus duplicate copies of itself, from editing an existing action rather than building a new one. This produced an invalid, non-resolving URL string (click registered, nothing visibly happened — indistinguishable from a missing/broken action from the user's side). Resolved by clearing the URL action's URL box entirely and rebuilding from a single clean placeholder, rather than attempting to selectively remove the extras in place. See Tableau gotcha #4 in the project handoff.

---

## Field 8: Overdue Multiple

**WHAT:** Ratio of a SKU's current recency (days since last sale) to its own historical average order interval, expressed as a multiple (e.g., "18.4x" means the SKU is 18.4 times overdue relative to its normal restocking rhythm).

**WHY:** Raw recency days alone can't signal urgency on its own — a SKU that normally sells every 3 days being silent for 30 days is a very different signal than one that normally sells every 60 days being silent for 30 days. This field normalizes recency against each SKU's own historical rhythm, matching Query 174's `avg_interval_fractional_day` fork (not the whole-day fork) per this project's standing methodological-fork rule.

**Formula:**
```
[Recency Days] / [Avg Interval Fractional Day]
```

**Verification:** Not independently verified against a fixed known value (it's a continuous ratio, not a count) — instead verified indirectly through Field 9's population count matching Query 174 exactly (see below).

**Result:** ✅ Field created correctly on first attempt at the fractional-day fork; an earlier draft mistakenly used `Avg Interval Whole Day` and was corrected before the category field was built on top of it.

---

## Field 9: Inventory Signal Category (Q174)

**WHAT:** Flags each SKU as belonging to the "Overdue Restock" population, per Query 174's retightened definition (8x overdue multiple, £1,000 net value floor — superseding Query 172's too-loose 3x threshold).

**WHY:** The Chapter Five Overdue Restock worksheet needs a filterable field that isolates exactly the 572-SKU population confirmed in Query 174, rather than showing all 4,734 SKUs in `stock_behavior_fields`. Query 174's Dead Stock Candidate / Seasonal Dormant split requires `full_transactions` (invoice-month data via the `seasonal_skus` subquery) and is deferred to a follow-up field once that worksheet is built; this field currently collapses both into a single "Dead Stock / Seasonal Dormant" bucket, since only Overdue Restock isolation was needed for this worksheet.

**Formula:**
```
IF [Frequency Completed] >= 5
   AND NOT ISNULL([Avg Interval Fractional Day])
   AND [Recency Days] >= 8 * [Avg Interval Fractional Day]
   AND [Monetary Net] >= 1000
THEN "Overdue Restock"
ELSEIF [Recency Days] >= 377 AND [Frequency Completed] <= 3
THEN "Dead Stock / Seasonal Dormant"
END
```

**Verification:** Filtered to "Overdue Restock" only, counted marks with Stock Code on Detail.

**Result:** ✅ Passed — **572** SKUs, matching Query 174 exactly (confirmed against the `174_phase5_exhibit_data_pull_v2.csv` source data: 572 Overdue Restock / 108 Dead Stock Candidate / 93 Seasonal Dormant / 773 total).

---

## Field 10: Exhibit URL (Overdue Restock)

**WHAT:** Resolves to the drill-down exhibit filename for the Overdue Restock worksheet's mark-click (Select) URL action.

**WHY:** Unlike Fields 6 and 7, this worksheet is single-population (already filtered to Overdue Restock only via Field 9) rather than branching across multiple tier values, so no IF/THEN routing logic is needed — every mark on the sheet points to the same exhibit.

**Formula:**
```
"overdue_restock_standalone_3d.html"
```

**Verification:** Live end-to-end test on the actual dashboard confirmed clicking any mark opens the correct exhibit in a new browser tab.

**Result:** ✅ Passed.

**Build note — corrected assumption on URL Target:** During setup, "inline Web Page object" was raised as a possible target based on an earlier architecture note, but this was never the original design intent and was not adopted. The confirmed, working, and intended pattern — matching Fields 6 and 7 exactly — is **"New Browser Tab."** This is a deliberate design choice, not a fallback: opening in a full new tab gives the person a full page to explore the rotatable 3D exhibit (drag, zoom, pan) rather than a cramped inline panel competing for space with the rest of the dashboard.

**Build note — DNS resolution error:** Initial testing hit a "This site can't be reached" / `DNS_PROBE_FINISHED_NXDOMAIN` browser error. Root cause: the URL box contained only the bare field placeholder (`<Exhibit URL (Overdue Restock)>`) with no base path in front of it, so the browser tried to resolve the resulting filename as a hostname rather than a relative path. Fixed by prepending the same GitHub Pages base path used in the working Funnel Tier/Frequency Spike actions, e.g. `https://cosbycd.github.io/Current-Projects/uk-retail-forensics/3dplots/<Exhibit URL (Overdue Restock)>`. This is a distinct failure mode from Tableau gotcha #4 (concatenated/duplicated field placeholders) — worth logging separately as a new gotcha in the project handoff: a bare filename with no base path produces the same "click does nothing/goes nowhere useful" symptom as a broken action, but the cause and fix are different (missing prefix, not duplicated placeholders).

---

## Status

**Built and verified:** all six calculated fields above, dashboard layout (Funnel Tier Overview, Frequency Spike Overview, plus Nov 2010 Cohort and Never Converted breakdowns), and mark-click (Select) URL actions wiring each `Recency-Monetary Tier` value to its corresponding 3D exhibit — confirmed working end-to-end on the live dashboard.

**Not yet built:** the Current/Historical page structure, and an equivalent drill-down wiring for `Frequency Spike Tier` (currently only `Recency-Monetary Tier` has exhibit routing).

**[REVISION — Status section, corrected following Field 7's build, run July 23, 2026]**

The Status section above states "equivalent drill-down wiring for `Frequency Spike Tier`" as **Not yet built**. This is now superseded: Field 7 (`Exhibit URL (Frequency Spike)`) and its mark-click URL action are built, verified, and confirmed working end-to-end on the live dashboard. Frequency Spike Tier now has drill-down routing matching Recency-Monetary Tier's existing pattern. Remaining "Not yet built" item is unchanged: the Current/Historical page structure.

**[REVISION — Status section, corrected following Fields 8–10's build (Overdue Restock), run July 24, 2026]**

Chapter Five's `stock_behavior_fields` data source is now connected (via a Tableau relationship to `full_transactions`, not a join). Fields 8 (`Overdue Multiple`), 9 (`Inventory Signal Category (Q174)`), and 10 (`Exhibit URL (Overdue Restock)`) are built, verified against Query 174's 572-SKU population, and confirmed working end-to-end — an "Overdue Restock Overview" worksheet with a mark-click URL action to `overdue_restock_standalone_3d.html`, opening in a new browser tab. Remaining Chapter Five work: Dead Stock Candidate / Seasonal Dormant worksheet and exhibit routing (requires extending Field 9's category logic with the `seasonal_skus` subquery against `full_transactions`), Inventory Signal Overview combined dashboard, and the Cohort & Edge-Case Deep Dive dashboards.

---

## Field 11: Total Orders per SKU

**WHAT:** Count of distinct, non-cancelled invoices per Stock Code, using a FIXED-level-of-detail calculation against `full_transactions`.

**WHY:** First building block for porting Query 174's `seasonal_skus` subquery logic into Tableau — needed as the denominator for determining whether 100% of a SKU's orders fell within November/December.

**Formula:**
```
{ FIXED [Stock Code (Full Transactions)] : COUNTD(
    IF LEFT([Invoice No], 1) <> "C" THEN [Invoice No] END
) }
```

**Verification:** Filtered to Stock Code `84925E` (a known Dead Stock Candidate, `frequency_completed = 3` per the Q174 CSV pull), confirmed the field returns **3**, matching the CSV exactly.

**Result:** ✅ Passed.

---

## Field 12: Nov Dec Orders per SKU

**WHAT:** Same as Field 11, but restricted to invoices whose Invoice Date falls in November or December.

**WHY:** Numerator for the Seasonal Dormant test — needed to compare against Field 11's total.

**Formula:**
```
{ FIXED [Stock Code (Full Transactions)] : COUNTD(
    IF LEFT([Invoice No], 1) <> "C"
       AND MONTH([Invoice Date]) IN (11, 12)
    THEN [Invoice No] END
) }
```

**Verification:** Two-sided check against known CSV categories:
- Stock Code `84925E` (Dead Stock Candidate, Total Orders = 3): returned **2** — correctly less than Total, since not all orders were seasonal.
- Stock Code `16215` (Seasonal Dormant, Total Orders = 3): returned **3** — correctly equal to Total, since all orders were seasonal.

**Result:** ✅ Passed, both directions.

---

## Field 13: Is Seasonal Dormant

**WHAT:** Boolean flag, true only when 100% of a SKU's orders fell in November or December.

**WHY:** Direct Tableau translation of Query 174's `seasonal_skus` CTE condition (`om.orders_this_month = t.total_orders AND om.order_month IN (11, 12)`).

**Formula:**
```
[Nov Dec Orders per SKU] = [Total Orders per SKU]
```

**Verification:** Same two SKUs as Field 12 — `84925E` returned **False**, `16215` returned **True**, both matching their known CSV category.

**Result:** ✅ Passed.

---

## Field 14: Inventory Signal Category (Q174, Full Split)

**WHAT:** Three-way version of Field 9, now correctly splitting the collapsed "Dead Stock / Seasonal Dormant" bucket into its two true categories.

**WHY:** Field 9 deferred this split because it required `full_transactions` invoice-month data, which wasn't yet wired at the time. Built as a **duplicate** of Field 9 rather than an in-place edit, per this project's standing rule to rebuild fresh rather than risk stale/concatenated logic (same reasoning as Tableau gotcha #4 for URL actions).

**Formula:**
```
IF [Frequency Completed] >= 5
   AND NOT ISNULL([Avg Interval Fractional Day])
   AND [Recency Days] >= 8 * [Avg Interval Fractional Day]
   AND [Monetary Net] >= 1000
THEN "Overdue Restock"
ELSEIF [Recency Days] >= 377 AND [Frequency Completed] <= 3 AND [Is Seasonal Dormant]
THEN "Seasonal Dormant"
ELSEIF [Recency Days] >= 377 AND [Frequency Completed] <= 3
THEN "Dead Stock Candidate"
END
```

**Verification:** Full breakdown, no filter, Stock Code counted distinct per category.

**Result:** ✅ Passed — **572 Overdue Restock / 108 Dead Stock Candidate / 93 Seasonal Dormant / 3,961 Null**, matching Query 174's confirmed populations exactly (572/108/93, 773 total categorized).

**Note:** Field 9 (the collapsed-bucket version) is left in place, unedited, per the append-only/nothing-deleted standing rule — Field 14 supersedes it for any view needing the full three-way split, but Field 9 remains valid for contexts where only the Overdue Restock/Not-Overdue-Restock distinction matters.

---

## Field 15: Exhibit URL (Dead Stock Seasonal)

**WHAT:** Resolves to the drill-down exhibit filename for the Dead Stock/Seasonal Dormant worksheet's mark-click (Select) URL action.

**WHY:** Same single-population pattern as Field 10 — both categories in this worksheet share one combined Plotly exhibit (`dead_stock_seasonal_deepdive_3d.html`), so no branching logic is needed.

**Formula:**
```
"dead_stock_seasonal_deepdive_3d.html"
```

**Verification:** Live end-to-end test on the actual dashboard confirmed clicking a mark opens the correct exhibit in a new browser tab.

**Result:** ✅ Passed.

---

## Status

**[REVISION — Status section, corrected following Fields 11–15's build (Dead Stock/Seasonal Dormant), run July 25, 2026]**

The prior revision listed "Dead Stock Candidate / Seasonal Dormant worksheet and exhibit routing" as remaining work. This is now superseded: Fields 11–14 correctly port Query 174's `seasonal_skus` subquery logic into Tableau (verified against known True/False cases and the full 572/108/93 population split), and Field 15 provides exhibit routing. The "Dead Stock Seasonal Overview" worksheet is built — color-split by category (Dead Stock Candidate vs. Seasonal Dormant), tooltip configured, mark-click URL action confirmed working end-to-end to `dead_stock_seasonal_deepdive_3d.html` in a new browser tab. Remaining Chapter Five work: Inventory Signal Overview (combined dashboard showing all three categories together), plus the Cohort & Edge-Case Deep Dive dashboards carried over from Chapter Four.

---

## Fields 16–22: Exhibit URL (Nov 2010 Cohort) — PROPOSED, NOT YET BUILT OR VERIFIED

**⚠️ Status note:** Unlike every field above, Fields 16–21 have **not** been built in Tableau, click-tested, or checked against a known population count. This section is a draft of the calculated-field formulas following the same pattern as Fields 10 and 15, prepared ahead of the actual Nov 2010 Cohort Tableau wiring so the build has a starting point. Per this document's own standing rule, none of these should be treated as working until each is built, verified against `chapter_four_calculated_fields.md`'s usual bar (a known number, not "it looks right"), and confirmed with a live end-to-end click test — the same discipline applied to every field above.

**Design decision confirmed (July 26, 2026):** one worksheet per segmentation/exhibit (matching the simple constant-string pattern used in Fields 10 and 15), grouped together by data segmentation type in the dashboard layout — not a single combined overview with branching URL logic. Each cohort segmentation's bar chart functions as its own "expandable deep dive": since every 3D exhibit already contains all of that segmentation's categories as legend-toggleable traces, every bar/mark in a given worksheet correctly routes to the same single exhibit filename regardless of which bar was clicked. The drafted fields below already match this confirmed design and do not need to be reworked — only built and verified in Tableau.

**Fork exception (per this project's standing "build both forks" rule):** where a segmentation has two genuinely different built variants rather than one chosen version, both get their own worksheet — not just the one that was ultimately preferred. Acquisition Month is the one case in this cohort set with a real fork (bucketed 4-band vs. full 13-month gradient, both built and compared earlier in this project), so it gets two worksheets/fields below instead of one. The other five segmentations (Lifecycle, Isolated, Frequency Buckets, High-Value Tail, Last-Order Timing) each have a single built version, so no fork split applies to them.

**Filename confirmed (July 26, 2026):** `nov_2010_cohort_deepdive_3d.html` was directly uploaded and inspected — confirmed as the "Isolated — Deep Dive" exhibit (615-customer cohort against a 580-customer peer-scale comparison sample, same recency/frequency/monetary axes as the other Isolated exhibit).

**[REVISION — Isolated Deep Dive dropped from Tableau wiring plan, decided July 26, 2026]** Immediately after confirming the filename above, the design decision itself made this exhibit's dedicated worksheet unnecessary: since every segmentation worksheet now functions as its own "expandable deep dive" (per the confirmed design decision above — the 3D exhibit already contains all categories as legend-toggleable traces), a separate standalone "Isolated Deep Dive" worksheet/field routing to a peer-scale comparison view is redundant. The Isolated (General) exhibit alone covers this segmentation. `nov_2010_cohort_deepdive_3d.html` remains a valid, built exhibit file — it simply isn't being wired into this Tableau dashboard. Total Nov 2010 Cohort worksheets/fields for Tableau: 6 segmentations (Lifecycle, Isolated, Frequency Buckets, High-Value Tail, Acquisition Month × 2 forks, Last-Order Timing) across 7 fields, not 7 segmentations/8 fields as previously drafted.

**[REVISION — correction to the note directly above, same day]** The reasoning above ("Isolated Deep Dive dropped, file unused") was incorrect on one point: `nov_2010_cohort_deepdive_3d.html` was not left unused — it was **renamed to `nov_2010_cohort_isolated_3d.html`**, superseding the file that previously held that name (the dense-1,308-customer-backdrop version). So the single "Isolated" exhibit now wired into the Tableau plan is the **peer-scale 580-customer comparison version** (what this document had been calling "Deep Dive"), not the dense-backdrop version. The dense-backdrop version no longer exists under either filename. Field 17's population description below is corrected accordingly.

**Formula pattern (draft, one per exhibit — same shape as Field 10):**
```
"nov_2010_cohort_lifecycle_3d.html"
```

Repeated per exhibit, filtered by the existing `Nov 2010 Cohort Flag` (Field 2) on each worksheet:

| Draft field name | Formula | Target exhibit |
|---|---|---|
| Exhibit URL (Nov 2010 Cohort — Lifecycle) | `"nov_2010_cohort_lifecycle_3d.html"` | Lifecycle (tenure × frequency × monetary) |
| Exhibit URL (Nov 2010 Cohort — Isolated) | `"nov_2010_cohort_isolated_3d.html"` | Isolated (615-customer cohort vs. 580-customer peer-scale comparison sample — formerly the "Deep Dive" file, renamed) |
| Exhibit URL (Nov 2010 Cohort — Frequency Buckets) | `"nov_2010_cohort_frequency_buckets_3d.html"` | Frequency Buckets (1 / 2–5 / 6–15 / 16+) |
| Exhibit URL (Nov 2010 Cohort — High-Value Tail) | `"nov_2010_cohort_high_value_tail_3d.html"` | High-Value Tail (≥£5,000 net) |
| Exhibit URL (Nov 2010 Cohort — Acquisition Month, Bucketed) | `"nov_2010_cohort_acquisition_month_3d.html"` | Acquisition Month, bucketed fork (4-band: Pre-Oct/Oct/Nov/Dec 2010) — see revision note below on filename |
| Exhibit URL (Nov 2010 Cohort — Acquisition Month, Gradient) | `"nov_2010_cohort_acquisition_month_3d_gradient.html"` | Acquisition Month, gradient fork (13-month continuous scale) |

**[REVISION — filename correction, same day]** The Bucketed field above originally routed to `nov_2010_cohort_acquisition_month_3d_bucketed.html`. That file is superseded — it's an earlier-named duplicate of the same chart, and the officially live exhibit (with the caption, legend, and verified 305/123/153/34 counts) is the unsuffixed `nov_2010_cohort_acquisition_month_3d.html`. Corrected above; if `_bucketed.html` still exists as a file, treat it as a leftover duplicate, not a second valid exhibit.
| Exhibit URL (Nov 2010 Cohort — Last-Order Timing) | `"nov_2010_cohort_last_order_deepdive_3d.html"` | Last-Order-Timing Deep Dive (Oct/Nov/Dec 2010) |

**Verification:** Not yet performed. When built, follow Field 10's pattern exactly — live end-to-end test per worksheet confirming the mark-click action opens the correct exhibit in a new browser tab, using the confirmed GitHub Pages base-path prefix (see Field 10's build note on the DNS resolution gotcha — do not use a bare field placeholder).

**Result:** Not yet built. This section should be revised in place — not silently edited — once each field is actually built and verified, per this document's standing rule.

---

*This document follows the same standing rules as the SQL investigation log: nothing is deleted, only appended to; any future revision of a field above gets a notation here citing the query or reasoning that prompted the change, not a silent edit.*


