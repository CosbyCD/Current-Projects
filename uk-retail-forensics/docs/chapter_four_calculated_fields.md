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

## Status

**Built and verified:** all six calculated fields above, dashboard layout (Funnel Tier Overview, Frequency Spike Overview, plus Nov 2010 Cohort and Never Converted breakdowns), and mark-click (Select) URL actions wiring each `Recency-Monetary Tier` value to its corresponding 3D exhibit — confirmed working end-to-end on the live dashboard.

**Not yet built:** the Current/Historical page structure, and an equivalent drill-down wiring for `Frequency Spike Tier` (currently only `Recency-Monetary Tier` has exhibit routing).

---

*This document follows the same standing rules as the SQL investigation log: nothing is deleted, only appended to; any future revision of a field above gets a notation here citing the query or reasoning that prompted the change, not a silent edit.*
