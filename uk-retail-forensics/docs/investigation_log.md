# UK Online Retail II — Investigation Log

**Purpose:** This document tracks the meta-narrative of this investigation — the order things were looked at, what was found, and what each finding inspired next. Individual `.sql` files in `/sql/` document *what* each query does and *why* it was run in isolation. This document connects them into a single readable story: the chain of custody for the reasoning itself, not just the data.

---

## Introduction — Why This Project Exists

This project is built around a question, not just a dataset: **if you take data seriously enough to examine it from every angle, does turning it — literally, spatially, in three dimensions — reveal something a flat table or a standard 2D chart cannot?**

Standard analysis, including everything I've built up to this point, is fundamentally two-dimensional: a bar chart, a scatter plot, a dashboard tile. Even when a report has many charts, each one is still a flat plane — X against Y, one relationship at a time. That approach has real limits. In a 2D scatter plot, one data point can sit directly behind another and effectively disappear — occluded, invisible, even though it's right there in the data. What's hidden isn't actionable.

The idea driving this project is closer to how I actually picture data in my head: not as a table, but as a cube, where every data point occupies real space, positioned by its own values, and where rotating that cube changes which two dimensions you're looking at head-on. A relationship invisible from one angle — because a third variable is collapsed out of view — can snap into focus the moment you turn the structure and look at it from another plane entirely.

This isn't a new interest. In the 1980s, I took criminal justice coursework with an eye toward law enforcement. I didn't stay in that field, but the core discipline never left: chain of custody, documentation precise enough that someone else could follow the exact same path and arrive at the same conclusion, and — the part that matters most — reporting what the evidence actually says, regardless of whether the answer is convenient. That last piece is non-negotiable in this work the same way it would be in any investigation. I pull the data out, and I tell you what it says. Not what's flattering, not what confirms an assumption someone walked in with — what's actually there. Every data quality finding documented in this log, including the ones that complicated the analysis rather than simplifying it, follows that same rule.

That discipline found its way into how I think about data structure a few years later. I built my first dimensional workbook in 1995, at Minh Foods, structuring national institutional sales data in an OLAP-style layout years before drag-and-drop dashboards existed as a category — because a flat spreadsheet couldn't hold the relationships I needed to see at once. The instinct to think in dimensions rather than rows and columns has been consistent since then. What's changed isn't the instinct — it's that the tools have finally caught up to it. What used to require custom-built structures and nested macros can now be prompted into an interactive, rotatable, browser-based visualization directly. This project is a test of whether that gap has genuinely closed.

This isn't an entirely new idea in the abstract — commercial platforms (Virtualitics, FineVis, and others) already sell 3D visualization tools built specifically for this kind of exploration, and academic and enterprise use of 3D scatter plots for cluster analysis goes back years. What's different about this project is the approach: building this capability directly, from raw derived data, using AI-assisted development as the bridge between having an idea and having a working tool — without a dedicated platform, a data visualization team, or a purchased license. That combination — an individual analyst, prompting their way to a capability that used to require real programming investment or a commercial product, and testing it rigorously rather than just demonstrating it — is the actual experiment.

The UK Online Retail II dataset was chosen deliberately *because* it's unremarkable. This isn't a novel or exotic dataset chosen to make a discovery inevitable — it's a plain, heavily-studied one, chosen specifically so that if the 3D rotation approach does surface something meaningful, the finding is credible precisely because it came from ordinary data, not a dataset engineered to make the method look good.

The six customer behavior fields being derived in this project — extracted entirely from the 8 raw columns already present, no external enrichment — are the inputs to that eventual 3D structure. Everything documented below, all of the data-quality investigation, the chain-of-custody discipline, the careful validation before trusting any number — exists to make sure that when those six fields do get placed into a rotatable structure, whatever the rotation reveals (or doesn't) is trustworthy. A finding built on unvalidated data isn't a finding; it's noise wearing a nicer visualization.

There's a broader question sitting behind this specific project, too, worth naming honestly: the volume of data being collected across every industry right now is enormous, and growing faster than the tools and habits most organizations use to actually explore it are keeping pace with. Most of that data gets summarized, reported on, and left at that — a flat, static answer to a flat, static question. This project is a small, deliberately rigorous test of one alternative: whether AI-assisted development has quietly put a genuinely new exploratory capability within reach of an individual analyst, not just a well-funded platform team — and if so, whether that capability actually earns a place in the analytical toolkit, or turns out to be a novelty that looks impressive and adds nothing. I don't know the answer yet. That's the point of testing it.

---

## Phase 0 — Environment Setup

**00a / 00b** — Created a dedicated `uk_retail` schema, separate from the existing Cyclistic tables in `public`. Built `raw_transactions` matching the dataset's 8 original columns exactly, no derived fields. Loaded the source CSV via pgAdmin's Import/Export GUI. This table is treated as permanent, untouched source of truth — nothing is ever deleted from it directly.

## Phase 1 — Initial Validation

**01** — Confirmed row count (1,067,371) and date range (Dec 1, 2009 – Dec 9, 2011) matched the documented dataset. This was the first checkpoint: if the import hadn't landed correctly, everything after this point would be built on bad data.

## Phase 2 — Stock Code Investigation

**02** — While scrolling the raw data directly (not querying for anything specific yet — just looking), noticed some stock codes had trailing letters (e.g. `85123A`). Pulled every numeric+letter stock code, sorted by numeric part ascending and trailing letter ascending, to see the pattern clearly. This surfaced two things at once: some letters looked like genuine product variants (colors/styles), and — sitting right next to each other in the sort — some looked like the same code with inconsistent letter casing (`15056bl` next to `15056BL`).

**03** — Spot-checked the `15056BL` / `15056bl` pair directly. Confirmed matching description ("EDWARDIAN PARASOL BLACK") and overlapping price history — same product, entered with inconsistent casing, not two different products.

**04** — Query 03 confirmed one example. This checked the full extent of the casing issue across the entire dataset — found the complete list of stock codes with more than one casing variant, to know the true scope before deciding to normalize.

**05** — Separately, confirmed that trailing letters that are *not* casing duplicates (e.g. `15044A/B/C/D`) are genuine product variants — different colorways of the same base item. Built a two-tier rollup showing individual variant quantities alongside the total for the whole product family. This established that "product diversity" as a derived field could be measured at two levels: distinct product families vs. distinct SKUs/variants.

## Phase 3 — The Negative Quantity / Blank Description Thread

**06** — While reviewing the 15044 family from query 05, spotted a `-27` quantity row on `15044B` with no description. Pulled the full transaction history for that stock code to see it in context. Found two very different anomalies sitting in the same product's history: a genuine cancellation (invoice `C554905` — properly 'C'-prefixed, populated description, real price, valid customer_id) right alongside a different kind of row (invoice `556012` — no 'C' prefix, blank description, `$0.00` price, no customer_id). The contrast between these two rows, visible side by side, became the model for what to look for dataset-wide.

**07** — Checked whether the `556012`-style pattern (negative quantity + blank description) was an isolated incident or widespread. Found 2,689 matching rows across the full dataset.

**08** — Tested whether those 2,689 rows were simply mislabeled cancellations — i.e., whether they overlapped with the documented 'C'-prefix flag. Result: zero overlap. None of the 2,689 rows are C-prefixed. This confirmed a genuinely separate, undocumented category of negative-quantity transaction.

**09** — Tested whether the 2,689 rows overlapped with the already-known missing-CustomerID group (243,007 rows / 22.8% of the dataset, found during general column auditing). Result: full overlap — all 2,689 rows have no customer_id. This meant the finding, while real, does not threaten any customer-level derived field, since these rows were already excluded by the CustomerID rule.

**10** — Checked whether the 2,689-row pattern concentrated on specific products or spread broadly. Found it spread across many different stock codes (max 4 occurrences on any single code), suggesting a systemic data-entry or export issue rather than a product-specific quirk.

## Phase 4 — Return Rate Methodology

**11** — Built return rate at the **order level**: proportion of a customer's distinct orders that were cancellations.

**12** — Built return rate at the **line-item level**: proportion of a customer's individual line items that were cancellations. Built as a second, deliberately separate approach — a single cancelled item in a 10-line order shows very differently depending on which level you measure at.

**13** — Combined both into one comparison query, with a gap column, sorted by largest divergence — surfacing which customers' return behavior looks meaningfully different depending on measurement level. Decision on which method (or both) to use in the final derived field is still open, pending manual review of a few high-gap customers.

## Phase 5 — Full Column Completeness Audit

**14** — Before building the clean working table, ran a full sweep of all 8 raw columns checking for NULL/blank values in one pass. Result: only two columns had gaps — `customer_id` (243,007, matching the earlier finding) and `description` (4,382). The description gap was *larger* than the 2,689 already characterized in Phase 3 — meaning **1,693 blank-description rows exist that have not yet been investigated.** This is the open thread heading into Phase 6.

## Phase 6 — Systematic Data Cleaning Audit

Before building the clean working table, committed to reviewing every column systematically rather than continuing to work reactively off whatever surfaced next. Five open threads were identified from the Phase 5 completeness audit and general review: the leftover 1,693 blank-description rows, exact duplicate rows, non-numeric stock codes, zero/low unit_price rows broadly, and country field placeholder values.

**15 / 16** — Isolated and characterized the 1,693 blank-description rows left unexplained after Phase 3 (which accounted for 2,689 of the 4,382 total). Found a completely distinct signature: all 1,693 rows have positive quantity, zero unit_price, and no customer_id — the opposite quantity sign from the Phase 3 pattern. Only 37 of the 1,693 are tied to recognizable non-product administrative codes (POST, DOT, C2, TEST002, gift_0001_XX, DCGS-prefixed codes); the remaining 1,656 are ordinary numeric product codes. Row-level review showed many of these entries clustered in tight timestamp bursts — dozens of different stock codes logged within the same minute — consistent with batch-entered stock movements or inventory adjustments rather than individual customer sales. Conclusion: this is a second, separate undocumented category, distinct from the Phase 3 pattern, that reads as internal stock management activity rather than customer transactions.

**17 / 18** — Investigated whether exact duplicate rows exist in the dataset, prompted by three identical duplicate lines spotted incidentally in query 06's parasol pull (invoices 536525, 537405, 537434). A dataset-wide check for fully identical rows (matching on every column) found this to be far more widespread than the initial three-invoice observation suggested: **32,907 duplicate groups, 34,335 excess rows** — some individual rows repeated as many as 20 times. This represents roughly 3.2% of the entire 1,067,371-row dataset. This is the most significant Phase 6 finding to date, since duplicate rows directly inflate monetary value, frequency, and product diversity for any customer they touch, without being visually obvious in an aggregate view.

**External verification check** — After completing the above findings independently, searched for other published analyses of this same dataset to see whether these patterns had been documented elsewhere. Confirmed rather than contradicted: one independent analysis of this dataset found the identical duplicate-row phenomenon and traced a likely mechanism — not all line items on a duplicated invoice necessarily share the exact same timestamp, meaning some real duplicates may not be caught by an exact-match query if the timestamp differs by even a second. This is a testable refinement to pursue before finalizing a deduplication rule. A separate independent analysis of the same dataset found non-product administrative stock codes requiring removal (1,795 rows, using a broader inclusion definition than the 37 identified here), reinforcing that the non-numeric stock code cleanup step (Phase 6, thread 3, not yet completed) is a known, expected part of working with this dataset. A third source, an academic paper using this dataset, reports 5,243 unique products and 5,942 unique customers dataset-wide — a useful external checkpoint to compare against once the clean table's distinct counts are calculated.

A note on how this comparison was used: the external sources didn't direct the next investigative step or introduce a new finding to chase. They functioned the way comparing notes after the fact does — the 37-row count came from an independently-run query, scoped narrowly to the 1,693 blank-description subset, before any external source was consulted. Only in comparing that number against the 1,795 figure from another analysis did the scope mismatch become visible: theirs was a dataset-wide count, ours was subset-scoped. That gap is what prompted extending the original thread to its full, comparable scope (query 19) — not adopting a new thread borrowed from someone else's work. The underlying question (how many non-product administrative codes exist) was already part of this investigation's plan before any external comparison was made.

**19** — Ran the full dataset-wide non-numeric stock code check (thread 3), extending the earlier subset-scoped 37-row finding to the complete dataset per the scope-gap noted above. Initial result: 6,092 rows across 61 distinct non-standard codes (POST, DOT, M, C2, BANK CHARGES, ADJUST, AMAZONFEE, DCGS-prefixed codes, gift_0001_XX series, TEST001/002, and others).

**20** — Investigated one entry in the query 19 results, `"47503J "` (with a trailing space), to confirm whether it was a genuine administrative code or a false positive. Confirmed false positive: `47503J` (no trailing space) already exists as a normal product — "SET/3 FLORAL GARDEN TOOLS IN BAG," 80 occurrences — the spaced version is a data entry error on an existing product, not an administrative code. True non-numeric administrative code count: 6,092 − 1 = 6,091. This same query also surfaced an unplanned finding: two rows on stock_code 47503H had literal placeholder text ("check", "found") in the description field instead of a real product description.

**21 / 22** — Investigated the placeholder-text finding from query 20 dataset-wide. Found 327 rows with description values matching a set of likely placeholder/note terms ("check," "found," "?," "missing," "lost," and case variants) — a real, substantial pattern, not an isolated incident. Characterization confirmed all 327 rows share zero unit_price and no customer_id (the same signature as the Phase 3 and Phase 6 Thread 1 findings), with quantity split between negative (241) and positive (86).

**23** — Confirmed zero overlap between the 327 placeholder-description rows and the 4,382 blank-description rows already characterized in Phases 3 and 6 thread 1. This makes the 327 a genuinely fourth, distinct category.

**Synthesis — a unified phenomenon, not three coincidences.** Comparing all three findings side by side revealed they share a common signature despite surfacing independently, at different points in the investigation, through different queries:

| Group | Rows | Description | Quantity |
|---|---|---|---|
| Phase 3 | 2,689 | Blank | Always negative |
| Phase 6 Thread 1 | 1,693 | Blank | Always positive |
| Phase 6 Thread 3 | 327 | Placeholder text ("check", "found", "?", "missing", "lost") | Mixed (241 negative, 86 positive) |

All three groups share zero unit_price and no customer_id universally, with zero overlap between any pair of groups. Combined, these 4,709 rows appear to represent a single underlying phenomenon — internal stock corrections, adjustments, and manual reconciliation activity — rather than three unrelated data quality issues. The variation between groups (blank vs. placeholder-text description, positive vs. negative quantity) likely reflects different internal events: a write-off, a restock, a manual note left during a physical inventory check.

**24 — Decision: preserve as a standalone tagged table, not just exclude.** Rather than simply filtering these 4,709 rows out when building the clean customer-transaction table, they are being pulled into their own permanent table (`uk_retail.excluded_rows`), tagged by which thread identified each row. Two reasons: first, this keeps `clean_transactions` correctly scoped to real customer activity without losing the underlying evidence. Second, and more significant — this excluded set is itself a characterizable artifact worth analyzing on its own terms. The pattern across all 4,709 rows (zero price, no customer attribution, blank or note-like descriptions, concentrated in tight timestamp bursts as observed in Phase 6 thread 1) is consistent with manual, free-text data entry during stock reconciliation, rather than a structured, constrained input process. A practical recommendation follows directly from this: if the source system relies on free-text entry (typing a value in) rather than constrained input (a dropdown or point-and-click selection from a defined list), that is precisely where this kind of error — blank fields, inconsistent placeholder notes, missing structured data — tends to originate. This finding could serve a real operational purpose beyond this project: illustrating concretely, from real transaction data, why input controls matter and what happens downstream when they're absent — a tangible example for training or process-improvement conversations, not just an abstract argument for "cleaner data entry."

**Remaining Phase 6 threads, not yet investigated:**
4. Zero/unusually low unit_price rows, broadly across the dataset (separate from the zero-price rows already captured within the excluded_rows table)
5. Country field placeholder values

---

*This document is updated as each new phase of investigation is completed. Individual query documentation lives in `/sql/`; this file is the narrative connecting them.*
