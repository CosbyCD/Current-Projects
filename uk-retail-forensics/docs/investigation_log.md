# UK Online Retail II — Investigation Log

**Short on time? Prefer to see it rather than read it? [Explore the live 3D exhibit gallery →](https://cosbycd.github.io/Current-Projects/uk-retail-forensics/3dplots/)** — every exhibit links back to the specific query that confirmed it.

**Purpose:** This document tracks the meta-narrative of this investigation — the order things were looked at, what was found, and what each finding inspired next. Individual `.sql` files in `/sql/` document *what* each query does and *why* it was run in isolation. This document connects them into a single readable story: the chain of custody for the reasoning itself, not just the data.

---

## Introduction — Why This Project Exists

This project is built around a question, not just a dataset: **if you take data seriously enough to examine it from every angle, does turning it — literally, spatially, in three dimensions — reveal something a flat table or a standard 2D chart cannot?** Standard analysis is fundamentally two-dimensional — a bar chart, a scatter plot, one relationship at a time. That has a real limit: in a 2D scatter plot, one data point can sit directly behind another and effectively disappear. The idea driving this project is closer to how data actually gets pictured in my head — not as a table, but as a cube, where every point occupies real space and rotating the structure changes which two dimensions are facing you. A relationship invisible from one angle can snap into focus the moment you turn and look from another. Rotation is the core mechanic tested here, but it isn't the only interactive tool this project puts to work — hover detail and, eventually, click-through drill-down get tested too, each asked to earn its place on its own merits rather than assumed useful because it's new.

This isn't a new interest, and it isn't a new idea in the abstract either. Commercial platforms (Virtualitics, FineVis, and others) already sell 3D visualization tools built for exactly this kind of exploration. What's different about this project is the approach: building the capability directly, from raw derived data, using AI-assisted development as the bridge between having an idea and having a working tool — without a dedicated platform, a data visualization team, or a purchased license. An individual analyst, prompting their way to a capability that used to require real programming investment, and testing it rigorously rather than just demonstrating it — that's the actual experiment.

The discipline behind this project has two roots. Criminal justice coursework, early in my career, is where chain of custody first took hold as a working habit: documentation precise enough that someone else could follow the exact same path and arrive at the same conclusion, and reporting what the evidence actually says regardless of whether the answer is convenient. Paralegal training, later, formalized that instinct into an actual method — evidentiary record-keeping, nothing destroyed only segregated, every step documented in order. Both show up directly in this project's standing rules: nothing gets deleted, every revision gets a notation citing what changed it and why, and every finding is checked before it's trusted. Alongside that, decades of building structured data systems before dashboards were a category — dimensional spreadsheets in the era before drag-and-drop BI tools existed, documented for the person who wasn't in the room and still had to keep the thing running — is where the instinct to think in dimensions, not flat tables, comes from. What's changed isn't the instinct; it's that the tools have finally caught up to it. A printed formula sheet then, a WHAT/WHY comment block on every query now.

The UK Online Retail II dataset was chosen deliberately *because* it's unremarkable — a plain, heavily-studied dataset, chosen specifically so that if the 3D rotation approach does surface something meaningful, the finding is credible precisely because it came from ordinary data, not one engineered to make the method look good. The six customer behavior fields being derived in this project — extracted entirely from the 8 raw columns already present, no external enrichment — are the eventual inputs to that 3D structure. Everything documented below exists to make sure that when those fields do get placed into a rotatable structure, whatever the rotation reveals is trustworthy. A finding built on unvalidated data isn't a finding; it's noise wearing a nicer visualization.

There's a broader question behind this specific project too: the volume of data being collected across every industry right now is growing faster than the tools and habits most organizations use to actually explore it. This project is a small, deliberately rigorous test of one alternative — whether AI-assisted development has put a genuinely new exploratory capability within reach of an individual analyst, and whether that capability earns a place in the analytical toolkit or turns out to be a novelty that adds nothing. I don't know the answer yet. That's the point of testing it.

One more thing worth stating plainly, since it's easy to misread a fast timeline as a rushed one: **I didn't just use AI to go faster. I used it to run more verification passes than I'd have had time for solo, so the speed and the rigor came from the same decision, not opposite ends of a tradeoff.** Every discrepancy this project has surfaced — a mismatched customer count, a candidate finding that didn't hold up under a SQL check — is documented in the chapter it occurred in, not quietly smoothed over. That paper trail is the actual proof of the claim: not that the work went fast, but that it went fast *and* stayed defensible, because neither one was sacrificed for the other.

---

## Project Roadmap — Chapters and Sections

This investigation is structured as a book, not a flat list of steps. **Chapter One** is everything documented in this file: setup, investigation, discovery, and the construction of a fully clean, reconciled working table. It has its own beginning (query 00a), its own rising complexity (the data cleaning threads, especially the duplicate-row discovery and the outlier investigation), and its own resolution (`clean_transactions`, verified and trustworthy). The "Phase 1" through "Phase 7" labels used throughout the detailed sections below are the sections *within* Chapter One, not separate top-level stages of the overall project.

**Chapter One (complete): Loading, Investigation, and the Clean Table.**
- [Phase 1: Environment Setup and Initial Validation](#phase-1--environment-setup-and-initial-validation) (schema, raw table, row count and date range confirmation)
- [Phase 2: Stock Code Investigation](#phase-2--stock-code-investigation)
- [Phase 3: The Negative Quantity / Blank Description Thread](#phase-3--the-negative-quantity--blank-description-thread)
- [Phase 4: Return Rate Methodology](#phase-4--return-rate-methodology)
- [Phase 5: Full Column Completeness Audit](#phase-5--full-column-completeness-audit)
- [Phase 6: Systematic Data Cleaning Audit](#phase-6--systematic-data-cleaning-audit) (five threads: blank/placeholder descriptions, duplicate rows, non-numeric stock codes, zero-price rows, country placeholders)
- [Phase 7: Building the Clean Working Table](#phase-7--building-the-clean-working-table) (`clean_transactions`, fully reconciled)

`raw_transactions` remains fully untouched throughout Chapter One; every transformation applied to reach `clean_transactions` is traceable to a specific documented finding below.

**Verification/Audit Pass (bridge between Chapter One and Chapter Two).** Before Chapter Two begins, a dedicated audit pass will confirm the integrity of everything produced in Chapter One, rather than assuming it's correct because it was documented along the way. This exists specifically to catch a broken assumption or a mismatched file now, while the full reasoning trail is fresh and the scope is still contained — rather than discovering an error deep into Chapter Two and having to unwind work built on top of it. The audit covers: file integrity (every `.sql` file opens and matches its documented purpose), numbering integrity (no gaps, no accidental duplicates, no leftover ordering mistakes), query-to-output pairing (every file has its matching result, apart from the four documented exceptions — queries 24, 38, 41, and 43 — which either build tables directly or returned a zero-row result with no exportable data grid), re-execution of the load-bearing queries underpinning `clean_transactions` to confirm they still produce identical results from a fresh session, and a direct row-level spot-check of `clean_transactions` itself, rather than relying on the row-count reconciliation alone as proof.

**[Jump ahead to Chapter Two →](#chapter-two-deriving-the-six-customer-behavior-fields)** — skip the full Chapter One detail below and go straight to what's next.

**Chapter Two (complete): Deriving the Six Customer Behavior Fields.** Builds recency, frequency, monetary value, order-to-order interval, product diversity, and return rate directly from `clean_transactions` — the six fields that feed the eventual 3D visualization. Includes two full field-rebuild passes triggered by contamination found mid-chapter (administrative stock codes; a single 80,995-unit data-entry error), and resolves the standing question of how to handle the 228,297 no-customer-ID rows. Closes with `uk_retail.customer_behavior_fields` (5,875 customers, eleven derived columns), fully verified.

**Chapter Three (complete, closed July 16, 2026): 3D Visualization.** Tests this project's founding question directly against the full customer population — does rotating a 3D structure surface relationships a flat table or 2D chart cannot? Surfaces and (in the verification pass immediately following) confirms or revises three headline findings: the recency-monetary funnel, the frequency-monetary lockstep, and the 618-customer Nov 2010 Cohort. Includes a dedicated Method Honesty Assessment establishing this project's standing rule — a visual flags a candidate, only SQL confirms it.

**Chapter Four (complete — confirmed by Ree, July 30, 2026): Tableau Dashboard and 3D Drill-Down Exhibits.** Translates Chapter Three's confirmed findings into a Tableau dashboard with mark-click URL actions, each routing to a purpose-built 3D Plotly exhibit. Surfaces and resolves the NTILE non-determinism discovery, builds the Funnel Tier and Never Converted exhibit lineups, and carries the retroactive header/verification-format retrofit for queries 1–106. *[Roadmap entry originally read "(in progress)," target July 26, 2026 — superseded per standing rule, not silently edited.]*

**Chapter Five (complete): MRP/Inventory Signal Sprint.** Extends the project's method — SQL-confirmed findings, purpose-built 3D drill-downs — to a second business function: warehousing and purchasing. Builds `stock_behavior_fields` (4,734 SKUs, six dimensions mirroring Chapter Two's customer-side structure) directly from `full_transactions`, and confirms three headline inventory signals: 513 Overdue Restock candidates, 93 Seasonal Dormant SKUs, and 108 genuine Dead Stock candidates. A forensic review pass (July 31, 2026) found and fixed a real double-counting bug in `full_transactions`; 93 and 108 were confirmed unaffected, 513 corrects the originally reported 572. See "Chapter Five: MRP/Inventory Signal Sprint," below.

---

## Query Index — Phase to File Map

All SQL files live in a single flat `/sql/` folder, numbered in the true chronological order the investigation happened — not grouped into subfolders by phase, since several findings triggered tangents that crossed phase boundaries (e.g., query 06 in Phase 3 led directly to the duplicate-row discovery that became Phase 6). This table exists to give phase-level navigation without splitting that numbering apart.

| Query Range | Phase | What's In It |
|---|---|---|
| 00a – 01 | Phase 1 | Schema/table setup, row count and date range validation |
| 02 – 05 | Phase 2 | Stock code investigation: trailing letters, casing duplicates, family/variant rollup |
| 06 – 13 | Phase 3 & 4 | Negative quantity / blank description thread; return rate methodology (order vs. line-item) |
| 14 | Phase 5 | Full column completeness audit |
| 15 – 18 | Phase 6, Thread 1 & 2 | The remaining 1,693 blank-description rows; exact duplicate rows discovery |
| 19 – 23 | Phase 6, Thread 3 | Non-numeric stock codes; the 47503 false positive; placeholder text in description; three-way synthesis |
| 24 – 25 | Phase 6 | Building and verifying the tagged `excluded_rows` table |
| 26 – 32 | Phase 6, Thread 4 | Zero/low unit_price investigation; the 12,540-quantity outlier; customer_id trailing decimal discovery |
| 33 – 34 | Phase 6, Thread 5 | Country field placeholder values |
| 36 – 41 | Phase 7 | Invoice-uniqueness stress test; `clean_transactions` build; row-count reconciliation; outlier revisit |
| 42 – 44 | Audit Pass | Chapter One spot-checks: stock code casing, customer_id formatting, country normalization |
| 45 – 53 | Chapter Two | Fields 1–2 (Recency, Frequency) original builds |
| 54 – 60 | Chapter Two | Field 3 (Monetary); administrative stock code discovery; `clean_transactions` amendment #2 |
| 61 – 84 | Chapter Two | Fields 1–3 rebuilt and re-verified post-amendment, including the 80,995-unit outlier thread |
| 85 – 90 | Chapter Two | Field 4 (Interval, whole-day vs. fractional-day fork); Field 5 (Product Diversity) |
| 91 – 95 | Chapter Two | Field 6 (Return Rate rebuild); final field assembly into `customer_behavior_fields` |
| 96 – 97 | Chapter Two | `unattributed_transactions`; resolving the no-customer-ID row question |
| 98 – 99 | Chapter Three | RFM export for visualization; log-scaled 3D chart build |
| 100 – 101 | Chapter Three | 618-customer November 2010 cohort investigation |
| 102 | Chapter Three | Customer 17961 order history |
| 103 – 104 | Chapter Three | Correlation heatmap; wave/spray cube exploration |
| 105 – 110 | Verification Pass | Recency-monetary funnel and frequency-monetary lockstep confirmed via SQL; outlier overlap check |
| 111 – 119 | Verification Pass | Gross-vs-net discovery; cancelled-order artifacts; Nov 2010 cohort monetary profile |
| 120 – 121 | Verification Pass | Veer-off observation closed; 350-399 day monetary spike closed |
| 122 – 128 | Chapter Four | NTILE non-determinism found, diagnosed, and resolved; percentile-based frequency spike threshold |
| 129 – 130 | Chapter Four | Dedicated 3D exhibit data pulls; never-converted tier leakage discovered and fixed |
| 131 – 136 | Chapter Four | Never Converted exhibit lineup (four variants); attempt-count tenure-cohort confirmation |
| 151 – 180 | Chapter Five | `stock_behavior_fields` build (151-161); full_transactions double-counting bug found, traced, fixed (151b/151c/151d); Overdue Restock threshold retightening (162, 171, 173); Dead Stock/Seasonal Dormant safeguard (163-165); 47503J side investigation (166-170); cross-population skew comparison (177-179) |

*Query 181 is a much later, out-of-sequence addition — the Nov 2010 Cohort exhibit data pull, built July 25, 2026 during active Chapter Four/Five Tableau exhibit work. It sits well outside this table's original 00a–136 range and is documented in place under "Revisiting Query 101," above, rather than given its own table row.*

---

## Phase 1 — Environment Setup and Initial Validation

**Project start date: July 6, 2026** — the UK Online Retail II dataset was downloaded from Kaggle on this date. Everything documented in this log, from initial data inspection through Chapter Three's close on July 16, follows from this download.

**00a / 00b** — Created a dedicated `uk_retail` schema in PostgreSQL. Built `raw_transactions` matching the dataset's 8 original columns exactly, no derived fields. Loaded the source CSV via pgAdmin's Import/Export GUI. This table is treated as permanent, untouched source of truth — nothing is ever deleted from it directly.

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

**24** — Built `uk_retail.excluded_rows` as a permanent table using the CASE-tagged logic above. Note: query 24 has no matching file in `/output/`, unlike every other query in this project — it is a `CREATE TABLE AS` statement that builds a table directly in the database rather than returning a result set to export. This is an intentional, documented exception to the query/output pairing convention used throughout this project.

**25** — Verification count confirming the excluded_rows table built correctly: 2,689 + 1,693 + 327 = 4,709 rows total, exactly matching the combined count from the three source findings, with no discrepancy.

**Decision: preserve as a standalone tagged table, not just exclude.** Rather than simply filtering these 4,709 rows out when building the clean customer-transaction table, they are being pulled into their own permanent table (`uk_retail.excluded_rows`), tagged by which thread identified each row. Two reasons: first, this keeps `clean_transactions` correctly scoped to real customer activity without losing the underlying evidence. Second, and more significant — this excluded set is itself a characterizable artifact worth analyzing on its own terms. The pattern across all 4,709 rows (zero price, no customer attribution, blank or note-like descriptions, concentrated in tight timestamp bursts as observed in Phase 6 thread 1) is consistent with manual, free-text data entry during stock reconciliation, rather than a structured, constrained input process. A practical recommendation follows directly from this: if the source system relies on free-text entry (typing a value in) rather than constrained input (a dropdown or point-and-click selection from a defined list), that is precisely where this kind of error — blank fields, inconsistent placeholder notes, missing structured data — tends to originate. This finding could serve a real operational purpose beyond this project: illustrating concretely, from real transaction data, why input controls matter and what happens downstream when they're absent — a tangible example for training or process-improvement conversations, not just an abstract argument for "cleaner data entry."

### Phase 6, Thread 4 — Zero and Low Unit Price Rows

**26** — Ran a broad check of unit_price values under 50p across the full dataset, excluding anything already tagged in `excluded_rows`. Result: 75,359 rows total in this range — but the overwhelming majority (73,468) fall between 10p and 49p, which is not treated as a data quality issue. This is a gift-ware retailer; small items (ribbon, gift tags, craft supplies) legitimately cost under 50 pence. Low price alone is not evidence of error. The genuinely notable group is the 1,511 rows priced at exactly zero.

**27** — Characterized the 1,511 zero-price rows outside excluded_rows. All 1,511 have a real (non-blank) description. Of those, only 89 have a customer_id attached — the remainder (1,422) are unattributed, following the same no-customer pattern as the rows already captured in excluded_rows, and can reasonably be treated the same way going forward. The 89 rows with both a real description and a real customer_id are the only ones in this thread that would directly touch a customer's derived fields, so they warranted direct row-level review rather than aggregate treatment.

**28** — Pulled and reviewed all 89 rows directly. Found two distinct sub-populations, not one uniform pattern:

- **Legitimate free/promotional items (majority)** — real products (e.g., "REGENCY CAKESTAND 3 TIER," "CHRISTMAS PUDDING TRINKET POT," "6 RIBBONS EMPIRE"), attached to real customer IDs, with normal-looking quantities, recorded at £0.00. This reads as intentional — samples, replacements, or goodwill items — not a pricing error.
- **Administrative codes with an attached customer_id (minority)** — the same non-product codes already characterized in Thread 3 (`PADS`, `M`/"Manual", `TEST001`, `BANK CHARGES`) reappear here, but unlike their other appearances in the dataset, these specific instances carry a real customer_id. This revises an earlier working assumption — that administrative/non-product codes are always unattributed — which does not hold universally.

Two additional findings surfaced during this row-level review, incidental to the main thread:
- **A duplicate row** (invoice 537197, stock code 22841, "ROUND CAKE TIN VINTAGE GREEN") appears twice, identically — consistent with, and further confirming, the exact-duplicate-row pattern already found in queries 17–18.
- **An outlier requiring direct verification**: invoice 578841, stock code 84826 ("ASSTD DESIGN 3D PAPER STICKERS"), quantity 12,540, price £0.00, customer 13256. A quantity of this size at zero price is either a legitimate large-scale promotional giveaway or a serious data entry error (e.g., a misplaced decimal or phantom quantity) and needs individual confirmation before being trusted in any downstream calculation.

**Conclusion for Thread 4:** unlike Threads 1–3, this group does not resolve into a single clean "exclude" or "keep" decision. It is a mixed population: legitimate promotional transactions (arguably valid to keep, since they represent real customer engagement even at no cost), attributed administrative entries (should likely be excluded, consistent with Thread 3's treatment), one confirmed duplicate (already covered by the duplicate-row remediation), and one high-quantity outlier requiring individual verification before any rule is applied.

**29** — Pulled the full transaction history for stock_code 84826 to verify the 12,540-quantity outlier in context. Confirmed as a genuine data entry error, not a legitimate transaction: every other order for this product across the entire two-year dataset ranges from 1 to 120 units (typically 1 or 60), making the 12,540-unit row on invoice 578841 more than 100 times larger than the largest normal order and roughly 200 times the typical order size. Combined with the £0.00 price and this being the only appearance of customer 13256 for this product, this reads as a misplaced decimal or phantom quantity entry rather than a real bulk transaction. This same pull also surfaced several additional exact-duplicate rows on this product (invoices 490926, 491622, 494625, 496431 ×5, 536620, 539472, 572103, 575337) — further confirming evidence for the Thread 2 duplicate-row finding (queries 17–18), now observed on a fifth distinct product.

**Thread 4 — Final Conclusion:** the 89 zero-price/customer-attributed rows resolve into four distinct handling categories rather than one uniform rule:
1. **Legitimate free/promotional items** (majority) — keep as-is; real customer engagement at no cost
2. **Attributed administrative codes** (PADS, M/Manual, TEST001, BANK CHARGES) — exclude, consistent with Thread 3's treatment of these same codes elsewhere
3. **Exact duplicate rows** — already covered by the general duplicate-row remediation (Thread 2)
4. **The single 12,540-quantity outlier** (invoice 578841) — confirmed data entry error; exclude via its own explicit, individually-documented exclusion rule rather than folding into the existing three-category `excluded_rows` CASE logic, since it does not share the defining traits of any of those groups

**Follow-up thought on the outlier:** before finalizing the exclusion rule, worth checking whether customer_id 13256 is a real, otherwise-normal customer with one bad row (isolated error), or whether 13256 has no other history at all in the dataset — which would suggest the customer_id itself may also be part of the data entry error, not just the quantity. Also checking for numerically nearby customer_ids (transposed or off-by-one digits) that might reveal the row's true intended attribution. Queries 30 and 31 pursue this.

**30** — Checked order counts for customer_ids numerically near 13256 (13246–13266) to see whether 13256 behaves like a normal customer, and specifically whether it might reflect a transposed or off-by-one digit error. Every neighboring customer_id has a real, substantial order history — ranging from single digits up to 1,920 orders for customer 13263. Customer 13256, by contrast, has exactly **one** order total. This comparison is what prompted looking at customer 13256's full history directly next.

**31** — Ran the direct full-history query for customer_id 13256, searching `customer_id = '13256'` first. Returned 0 rows — not an error, but no matching row found. This was unexpected given query 30 showed 13256 should have exactly one order. Re-examined the raw data from query 29's pull and noticed customer_id had displayed as `"13256.0"` with a trailing decimal. Re-ran the query searching `customer_id = '13256.0'` instead, which returned the expected single row — the 12,540-unit anomaly — confirming query 30's finding directly.

A genuine customer having only one transaction in a two-year dataset isn't impossible on its own, but combined with every other red flag on that row (impossible quantity, zero price, no comparable order in the product's entire history), this strongly suggests the row is corrupted end to end — not a real customer's one unusual purchase, but a fabricated or mistyped entry across multiple fields at once, not just the quantity.

This process also raised a new, unplanned question: customer_id is stored as VARCHAR, and this one value carries a trailing ".0" float-formatting artifact from import. If this is inconsistent across the dataset — some customer_id values with the decimal, some without — the same real customer could silently appear as two different values (e.g., '13256' and '13256.0') in different rows, splitting their transaction history in half without any error or warning. This would directly corrupt the six derived customer-level fields if not caught before the clean table is built. Query 32 checks the full scope of this.

**A note on method:** this outlier wasn't resolved by looking at one field in isolation. It was found by checking quantity against the product's typical order size, then price, then the customer's own order history, then that customer's position relative to numerically neighboring customers — rotating through different fields and comparison angles until the full shape of the anomaly became clear. This is the same instinct behind the eventual 3D visualization work on this project: no single flat view told the whole story; each new angle either confirmed or complicated the picture, and the anomaly only became fully legible after several rotations through the data.

**32** — Checked whether the trailing ".0" formatting found on customer_id 13256 is consistent across the entire dataset or only affects some rows. Result: all 824,364 rows with a populated customer_id carry the trailing decimal — zero exceptions. This confirms the formatting is a consistent, dataset-wide artifact from import rather than an inconsistency that risks silently splitting a customer's history across two differently-formatted ID values. It also confirms something useful in passing: 824,364 is the total row count with a populated customer_id, which lines up with expectations (1,067,371 total rows − 243,007 missing customer_id = 824,364 — an exact match), serving as a good internal consistency check on its own, independently reconfirming the original Phase 3 CustomerID finding.

**Practical rule going forward:** any query comparing or displaying customer_id must consistently account for the trailing ".0" — either always stripping it or always including it, but never mixing the two, which is exactly the mistake made accidentally in query 31. This should be standardized once when building the clean table, rather than re-discovered on a query-by-query basis.

### Phase 6, Thread 5 — Country Field Placeholder Values

**33** — Checked the country field for placeholder or non-country values, the last open thread from the Phase 5 completeness audit. The audit had already confirmed zero true blank/NULL values in country, but a populated field can still contain a placeholder rather than genuine geographic data — the same distinction already found in description (Thread 3's "check"/"found" placeholder text). Result: a clean, short list of 43 distinct values. The overwhelming majority are genuine countries or recognized abbreviations (United Kingdom, EIRE, Germany, RSA, USA, etc.). Two values stood out as non-specific: **"Unspecified"** (756 rows) and **"European Community"** (61 rows). This is a notably clean field compared to every other Phase 6 thread — only 817 of 1,067,371 rows (0.08%) are ambiguous.

**Decision and reasoning — combine, don't collapse or discard.** "Unspecified" and "European Community" are not identical in meaning: "Unspecified" is a true placeholder carrying no information at all, while "European Community" is imprecise but not meaningless — it indicates the order came from somewhere within the EU, just not a specific member state. Simply discarding both, or silently merging them into an existing country, would lose real information. Simply keeping them as two separate small categories seemed unnecessarily granular for two values that share the same underlying trait: neither identifies one specific country.

The resolution: combine both into a single clearly-labeled category, "Unspecified-European Community" (817 rows total), kept as its own tracked group rather than excluded from the dataset entirely. The reasoning for keeping it as a visible category, not discarding it: the *volume* of non-specific country data, compared against genuine country-level data, could itself be a meaningful signal once the six derived fields are placed into the eventual nodal visualization — a cluster or concentration of "Unspecified-European Community" rows in a particular time period or customer segment might point to a data entry gap, a specific sales channel, or a process issue worth investigating further, rather than being noise to simply remove.

**34** — Verification query confirming the combined "Unspecified-European Community" category totals 817 rows (756 + 61), matching expectations exactly, before this normalization logic is incorporated into the clean table build.

**Phase 6 status: all five threads investigated and resolved.** The clean table build (next phase) will incorporate: exclusion of the 4,709 rows in `excluded_rows` (Threads 1–3), exclusion of the confirmed 12,540-quantity outlier (Thread 4), standardized handling of the customer_id trailing decimal, deduplication of the 34,335 excess duplicate rows (Thread 2), stock code case normalization (Phase 2), and the country field normalization (Thread 5).

---

## Phase 7 — Building the Clean Working Table

**35 (draft)** — Drafted the first version of `uk_retail.clean_transactions`, intended to fold every Phase 2 and Phase 6 finding into one traceable build query. Before running it, reviewed the query line by line against the standard set throughout this project — verify before trusting, applied here to the query itself, not just the data. This review surfaced five issues:

1. The `excluded_rows` join initially matched only on invoice_no, stock_code, and invoice_date — too loose, since it could exclude a legitimate row that happened to share those three values with an excluded one. Corrected to match on every column.
2. The outlier exclusion (`invoice_no != '578841'`) was written to remove the entire invoice, when only one line item (stock_code 84826) on that invoice was ever confirmed as a data entry error. The rest of that invoice was never checked and should not have been assumed bad. Corrected to exclude only the specific row.
3. The customer_id decimal-stripping logic (`REPLACE(customer_id, '.0', '')`) was not anchored to the end of the string, risking an unintended match elsewhere in the value. Corrected to a regex anchored specifically to a trailing ".0".
4. Whether to keep or exclude the 243,007 rows with no customer_id from `clean_transactions` was flagged as still undecided.
5. The blanket policy of deduplicating every exact-match row (queries 17-18, 34,335 rows) had never been explicitly confirmed as final — only raised as an open question earlier in the log.

**Both sides of the deduplication question, argued out before deciding:**

*For treating every exact duplicate as an artifact (dedupe all):* for a row to be a genuine, separate real-world event rather than an error, a customer would need to place two fully independent orders — same product, same quantity, same price, same invoice number, same minute-level timestamp. Invoice numbers are documented as unique per transaction in this dataset; two real orders would not share one. External confirmation (the R/Spark analysis found during the earlier verification check) diagnosed the same pattern as a system/export artifact, not customer behavior.

*Against blanket deduping:* a real retail scenario exists where this could be legitimate — a warehouse or fulfillment system splitting one large order into multiple physical shipments, each logged identically for tracking purposes. Collapsing that would understate real quantity/monetary value. This hasn't been confirmed to happen in this dataset, but hasn't been ruled out either. `SELECT DISTINCT` is also a blunt instrument — it cannot distinguish "definitely an error" from "possibly legitimate," it simply collapses everything that matches.

**Where this left the decision:** evidence leaned toward "artifact," but rested on an unverified assumption — that invoice numbers are genuinely unique per real-world event, as the dataset's documentation claims. Consistent with this project's standing rule (verify before trusting), that assumption itself needed to be tested before finalizing policy, rather than accepted on the strength of documentation alone.

**Note on file numbering:** no `35_*.sql` file exists in `/sql/`, and this is intentional, not a gap to be filled. Query 35 was the first draft of the build query discussed above, containing the five issues caught on review — it was never executed, since resolving issue 5 (confirming the deduplication policy) required the invoice-uniqueness stress test below (queries 36–37) before a corrected build query could be finalized. The draft is fully documented in prose above rather than preserved as a runnable file, since running it would have meant knowingly executing a query with known defects.

**36** — Tested the core assumption directly: checked whether any invoice_no appears with more than one distinct invoice_date, which would mean invoice numbers are not as strictly unique as documented and would weaken confidence that exact duplicates are always an artifact. Result: not empty. At least 20 invoice numbers span more than one distinct timestamp, directly contradicting the assumption that one invoice always ties to exactly one moment in time.

**37** — Pulled full line-item detail for three of the flagged invoices (494166, 499967, 500353) to see directly what was happening, rather than treating the query 36 result as conclusive on its own. Found the explanation immediately: these are large, multi-line orders — invoice 494166 alone spans 190+ distinct stock codes. Entering that many line items took more than sixty seconds, so the recorded timestamp rolled forward mid-invoice (e.g., most lines at 09:47:00, the tail end at 09:48:00). The same pattern held on the other two invoices checked.

**Resolution of the deduplication policy question.** This result actually confirms the dedupe-all policy, for a more precise reason than originally assumed. The exact-duplicate check requires invoice_no, stock_code, description, quantity, unit_price, customer_id, AND invoice_date to all match simultaneously. Every line on a large multi-line order has a different stock_code by definition — such orders would never trigger the exact-duplicate detection regardless of any timestamp drift within them. The two phenomena are unrelated: invoice numbers can legitimately span multiple timestamps because large orders take time to enter, but a genuine exact duplicate requires every field to match at once, which a real, distinct line item within a growing order never would. The original "verify before trusting" instinct was correct to test the assumption — the assumption about invoice-to-timestamp uniqueness turned out to be false, but the underlying dedup policy survives the stress test intact because it was never actually resting on that assumption being true.

**Final policy: dedupe all exact-match rows**, confirmed via direct verification rather than accepted on the strength of dataset documentation or external analysis alone.

**38** — Built `uk_retail.clean_transactions` from `raw_transactions`, folding in every finding from Phase 2 and Phase 6 as a single traceable transformation: deduplication of the 34,335 excess duplicate rows (policy confirmed via queries 36–37), removal of the 4,709 `excluded_rows` entries matched on every column, removal of the single confirmed bad line item from the 12,540-quantity outlier (not the whole invoice), stock code case normalization, customer_id trailing-decimal stripping combined with converting the resulting empty string to a true NULL (finally closing the original day-one pending cleanup item that had been superseded when the "never modify raw_transactions directly" rule was adopted), and the country field normalization from Thread 5. Note: like query 24, query 38 has no matching file in `/output/` — it is a `CREATE TABLE AS` statement that builds a table directly rather than returning an exportable result set. Result: 1,028,437 rows.

**39** — Before trusting the new table, checked the actual row count against a naive subtraction estimate (1,067,371 total − 34,335 duplicates − 4,709 excluded − 1 outlier = 1,028,326 expected). The actual result (1,028,437) was 111 rows higher than expected — worth explaining before accepting the table, per this project's standing rule to verify rather than assume a discrepancy is harmless. Checked whether `excluded_rows` itself contained any exact-duplicate entries: confirmed yes — 4,709 total rows in `excluded_rows`, but only 4,598 *distinct* rows. The `deduplicated` CTE in query 38 collapsed those 111 internal duplicate pairs down to one copy each before the exclusion step ran, meaning fewer rows were actually available to exclude than the raw `excluded_rows` count suggested. This fully and exactly accounts for the discrepancy (4,709 − 4,598 = 111). The duplicate-row problem (Thread 2) and the internal-stock-activity problem (Threads 1–3) turned out to be slightly entangled in a way not explicitly tested before this point, and the build handled the overlap correctly without needing a special case. `clean_transactions` at 1,028,437 rows is fully reconciled and confirmed trustworthy.

**A loose thread revisited.** Re-reading this document during a break surfaced a real gap left open from the Thread 4 outlier investigation (queries 29–31): the neighbor comparison in query 30 only checked a narrow, purely sequential window (13246–13266) around customer_id 13256 — which would catch a simple left/right digit slip, but would miss other realistic typing errors, since a keypad-style slip doesn't have to land immediately adjacent in numeric sequence.

**40** — Re-ran the same neighbor comparison with a much wider range (13226–13866). Result: the original conclusion did not hold up. "Exactly 1 order" turned out to be common across this wider range — at least fifteen other customer_ids in the expanded window also show exactly 1 order. The earlier finding (that 13256's single order made it stand out) was only true because the narrow window checked in query 30 happened not to include any of those other single-order customers. Worth stating plainly: a finding that looked solid under a narrow test did not survive a wider one, and the earlier conclusion needed to be revised rather than defended.

**41** — The wider pull did surface a real, more specific lead: two established, active customer_ids exist that are exactly one digit-transposition away from 13256 — **13265** (91 orders) and **13526** (54 orders) — far more plausible candidates for "the row's true intended customer" than order-count comparison alone could show. Checked whether either placed an order close in time to the anomalous invoice (Nov 25, 2011). Result: zero rows — neither candidate ordered anything in that window, ruling out the most specific, testable version of the transposition theory.

**Final resolution on the 12,540-quantity/customer-13256 outlier.** Taken across queries 29–41: the quantity is confirmed as a data entry error — no comparable order exists anywhere in that product's two-year history. Whether the customer_id is also an error remains genuinely unresolved: the original argument for that did not survive a wider test, and the two most plausible specific correction candidates were ruled out directly. The row is excluded from `clean_transactions` as originally decided (Thread 4), but the honest documentation is that it is being excluded as an **unattributable data entry error**, not reassigned to any specific guessed customer. This is a case where the investigation reached a genuine dead end on one sub-question (who was this really for) while still fully resolving the question that actually mattered for the clean table (should this row be trusted as-is — no).

---

## Verification/Audit Pass — Chapter One Closed

Before Chapter Two begins, a dedicated audit pass was run to confirm the integrity of everything produced in Chapter One, rather than assuming it was correct because it was documented along the way. All five planned checks were completed, in order, with results recorded below.

**1. File integrity.** Every `.sql` file in `/sql/` was listed and cross-checked against the full expected sequence (00a through 41). All files present and correctly named. One filename typo caught and corrected (`38_build_clean_transactions..sql` → `38_build_clean_transactions.sql`, a stray double period).

**2. Numbering integrity.** The full sequence 00a through 41 was checked for duplicates, unexplained gaps, and leftover ordering mistakes. Four gaps exist, all intentional and documented: query 24 (builds `excluded_rows` table directly, no exportable result), query 35 (superseded first draft of the `clean_transactions` build, never executed — see the note on file numbering in Phase 7), query 38 (builds `clean_transactions` table directly, no exportable result), and query 41 (zero-row result, documented in the query file's own comment block). No duplicate numbers found; the original 30/31 reversal caught earlier in the project was confirmed corrected in both `/sql/` and `/output/`.

**3. Query-to-output pairing.** Every `.sql` file was checked for a matching `.csv` in `/output/`. Confirmed complete, apart from four documented exceptions — queries 24, 38, 41, and 43 — each either building a table directly or returning a zero-row result with no exportable data grid, with the reason recorded in the query file itself in every case.

**4. Re-execution of load-bearing queries.** `uk_retail.clean_transactions` was dropped and rebuilt from a clean session, re-running query 38 exactly as saved. The rebuild reproduced the identical row count — 1,028,437 rows — confirming the build is fully reproducible and not dependent on any leftover session state or prior partial runs.

**5. Row-level spot-checks.** Rather than relying on the row-count reconciliation alone as proof, three direct checks were run against `clean_transactions` itself:
- **42** — Stock code casing: confirmed only the normalized uppercase form (`15056BL`) exists; no lowercase or mixed-case variants remain. Passed.
- **43** — Customer_id formatting: confirmed zero rows retain the trailing ".0" artifact or an empty string. Passed.
- **44** — Country normalization: confirmed only the merged `Unspecified-European Community` label exists; neither raw "Unspecified" nor "European Community" survived independently. Passed.

**All five audit steps passed.** `clean_transactions` (1,028,437 rows) is confirmed sound, reproducible, and accurate at both the aggregate and row level. Chapter One — loading, investigation, and the construction of a fully clean, reconciled working table — is formally closed.

---

## Chapter Two: Deriving the Six Customer Behavior Fields

With the verification/audit pass complete and `clean_transactions` confirmed sound, Chapter Two begins — building out the six customer behavior fields (recency, frequency, monetary value, order-to-order interval, product diversity, return rate) that are the actual extraction thesis of this project: information already present in each line item, hidden in plain sight across the eight raw columns, waiting to be pulled out rather than sourced from anywhere external. This chapter produces the direct inputs to the fully rotatable, interactive 3D visualization built in Chapter Three.

Return rate (field 6) was already investigated methodologically in Chapter One (queries 11–13, order-level vs. line-item-level), but that work was built against `raw_transactions` before `clean_transactions` existed. It will be recalculated at the end of this chapter against the clean table, applying the same methodology decision rather than repeating the investigation.

### Field 1: Recency

**45** — Built the recency field: days since each customer's most recent order, calculated against `clean_transactions`. Reference point is fixed as the dataset's own most recent transaction date (Dec 9, 2011), not today's real-world date, since this is a historical dataset and recency needs a stable reference point within its own window to be meaningful — confirmed explicitly before running. Result formatted as a clean integer (`EXTRACT(DAY FROM ...)`) rather than a verbose interval, correcting an initial draft that returned full interval strings like "14 days 21:45:00."

**46** — First attempt at establishing a baseline row count for verification: `COUNT(*)` on all transaction rows with a customer_id. Result (797,884) was immediately recognized as too large to be a customer count — it counts every transaction line, not unique customers. Kept and documented as a corrected mistake rather than discarded, consistent with this project's standard (see query 31's handling of the same situation).

**47** — Corrected version using `COUNT(DISTINCT customer_id)`. Result: **5,941** distinct customers. Notably close to the 5,942 unique customers reported in an independent academic analysis of the full raw dataset (found during earlier verification research) — off by exactly one, consistent with and directly explained by the data-quality work done in Chapter One (the unattributable customer 13256 outlier being the clearest single contributor).

**48** — Individual spot-check: pulled customer 13468's actual transaction history directly rather than trusting the aggregate alone. Confirmed their most recent transaction is 2011-12-08, correctly yielding `recency_days = 1` against the Dec 9 dataset maximum.

**49** — Row-count reconciliation: re-ran query 45's grouping logic without the date math and counted the result. Returned exactly **5,941**, matching query 47's distinct customer count precisely.

**Field 1 status: complete and fully verified.** Two independent verification methods (aggregate row-count reconciliation and individual row-level spot-check) both confirm the field is accurate, with no customers dropped or duplicated.

### Field 2: Frequency

**Open question resolved before building.** Should cancelled orders (invoice_no starting with 'C') count toward a customer's frequency? Rather than choosing one definition, both were built and compared directly — consistent with this project's standing practice of testing both sides of a genuine methodology question (established with return rate in Chapter One).

**50** — Built frequency counting only completed orders (`invoice_no NOT LIKE 'C%'`). Top customer: 14911 with 398 completed orders.

**51** — Built frequency counting all distinct orders, including cancellations. Same top customer: 14911, now at 510 — a gap of 112.

**52** — Joined both versions with a `cancellation_gap` column to see the difference systematically across all 5,941 customers, rather than eyeballing two separate lists. The gap was not trivial or evenly spread — the top customer's 112-order gap means over a fifth of their apparent order volume was actually cancelled, and dozens of other customers showed double-digit gaps.

**Decision: track both, discard neither.** Given the gap proved real and behaviorally meaningful rather than noise, both components are kept as permanent, separately tracked parts of the customer profile — the same principle already established with `excluded_rows` in Chapter One: investigated signal doesn't get thrown away just because it complicates a single-number field. `frequency_completed` reflects genuine completed purchase behavior; `cancellation_count` is its own behavioral signal — a customer who cancels frequently is meaningfully different from one who rarely does, even at identical completed-purchase volume, and this distinction may matter directly once these fields are placed into the eventual 3D visualization.

**Why this project consistently builds both sides of a fork rather than one.** This isn't a one-off decision made for frequency specifically — it's a standing operating principle applied throughout this project, rooted in professional habits that predate it. Whoever receives an answer will eventually ask about the side that wasn't given; having it ready the first time costs a small amount of extra effort up front and avoids a second, slower round trip later. The same instinct also means noticing and addressing a need before it's been explicitly asked for, not only answering the question as narrowly posed. From this point forward in the document, any fork in methodology is treated this way by default: both sides built, both sides compared, and the decision about what to keep made from the comparison rather than assumed in advance.

**53** — Final field query, relabeling and reordering query 52's logic as the official field structure: `frequency_completed` and `cancellation_count`, one row per customer (5,941 rows), ordered by customer_id for lookup.

**Field 2 status: complete.** Two-component field, both halves independently derived and cross-validated against the same underlying order data.

### Field 3: Monetary Value

Following the same both-sides practice established with return rate and frequency.

**54** — Built monetary value counting only completed (non-cancelled) purchase lines: `monetary_gross`. Top customer: 18102 at $580,987.04.

**55** — Built monetary value across all transaction lines, including cancellations (which carry negative quantity and therefore reduce the total naturally): `monetary_net`. Same top customer, now $570,380.61 — roughly $10,600 lower, consistent with expected cancellation drag.

**56** — Joined both versions with a `cancelled_value` gap column. This surfaced something well beyond ordinary cancellation drag: several customers showed a `monetary_net` that was the **exact negative mirror** of their `monetary_gross` — e.g., customer 12918 at $10,953.50 gross and precisely **−$10,953.50** net, meaning their cancelled value ($21,907.00) was exactly double their purchases. This exact-doubling pattern repeated across multiple customers (16446, 12918, 14802, 15802, 13290) — too precise to be coincidental cancellation behavior.

**Critical discovery: an unresolved gap from Chapter One.** Investigated directly rather than assumed.

**57** — Pulled customer 12918's full transaction history. Found the cause immediately: three rows, all with stock_code `M` ("Manual"), two minutes apart — a manual charge, cancelled, followed immediately by a second identical manual charge, also cancelled. All three are administrative entries, not real purchases. Stock_code `M` is one of the non-numeric administrative codes fully investigated in Chapter One, Thread 3 (queries 19–23) — but that investigation characterized the *pattern*, it never actually built an exclusion rule for these codes into `clean_transactions` itself.

**58** — Checked the scope directly: does `clean_transactions` still contain administrative stock codes at all? Result: **yes, extensively**. POST (2,079 rows, $110,430.41), DOT (1,423 rows, $309,844.10), M (1,392 rows, −$83,311.28), AMAZONFEE (36 rows, −$221,520.50), BANK CHARGES, C2, and dozens of others — all still present in the table that was declared complete and independently verified at the end of Chapter One. Combined, these represent hundreds of thousands of dollars in non-product administrative activity sitting inside what was supposed to be a clean, purchase-only dataset.

**Why this matters beyond monetary value:** these administrative rows carry real invoice numbers and, in cases like customer 12918, real customer_id attribution — meaning this gap doesn't only corrupt monetary value. Frequency (Field 2) is very likely also affected, since a "Manual" entry with its own invoice number would have been counted as a real order in both the completed and all-orders frequency counts.

**Decision: amend `clean_transactions` at the source, not patch each field individually.** Rather than adding a workaround exclusion to monetary value alone, the clean table itself is being rebuilt with one additional rule — excluding any row where stock_code doesn't match the standard numeric/numeric-plus-letter product code pattern — so every field built from this point forward, and every field already built, draws from a single, genuinely complete clean table.

**59** — Rebuilt `clean_transactions` from scratch (query 38's logic plus the new stock-code filter). This is the second amendment to the clean table since Chapter One's formal closure, and it invalidates the row-level correctness of Fields 1 and 2 as previously built — both need to be re-run and re-verified against the amended table before Field 3 can be finalized. Note: like queries 24 and 38 before it, query 59 has no matching file in `/output/` — it is a `DROP TABLE` + `CREATE TABLE AS` statement that builds the table directly rather than returning an exportable result set. Result: 1,022,519 rows (down from 1,028,437 pre-amendment, a reduction of 5,918 rows).

**60** — Verified zero administrative stock codes remain in the amended table (`stock_code !~ '^[0-9]+[A-Za-z]*$'` returns 0 rows). Amendment confirmed complete and correctly applied.

**Field 3 status: paused pending table amendment.** Fields 1 (Recency) and 2 (Frequency) must be rebuilt and re-verified against the amended `clean_transactions` before any field in this chapter can be considered final.

**What the next three sections are doing, and why.** Discovering the administrative-code gap partway through Field 3 raised an uncomfortable but necessary question: if this leaked through Chapter One's supposedly complete, independently-verified table, what else built on top of it might be wrong? Rather than patching Field 3 alone and hoping Fields 1 and 2 were unaffected, every field already built is being re-run from scratch against the corrected table and re-verified with the same rigor as the first time — not re-checked by assumption, but by rerunning the actual queries and confirming the actual numbers. The following three sections walk through that rebuild field by field, in order, noting exactly what changed and why for each one.

### Field 1 Rebuild: Recency (post-amendment)

**61** — Re-ran the recency field (originally query 45) against the amended `clean_transactions`. Spot-checked customer 13468 directly: unchanged, still showing 2011-12-08 as last order date and `recency_days = 1`, identical to the pre-amendment result — a good early sign the field itself wasn't structurally affected by the administrative-code contamination.

**62** — Re-ran the distinct customer count to confirm the row-count baseline still matched. Result: **5,875**, down from the pre-amendment **5,941** — a real change of 66 fewer customers, not a discrepancy to wave away.

**63** — Investigated directly rather than assuming the drop was expected. Pulled all customer_ids whose administrative-code rows in `raw_transactions` existed but who no longer appear anywhere in the amended `clean_transactions`. Confirmed exactly **66 customers**, and every one of them has *only* administrative-code activity (POST, DOT, M, BANK CHARGES, etc.) in their entire transaction history — no genuine product purchases at all. Their removal is correct, not an error: these were never real purchasing customers, they existed in the dataset only because of postage charges, manual corrections, bank fees, or similar non-product activity. Worth noting for completeness: not every one of the 66 had a negative total (e.g., customer 17846 at +$2,033.10) — some represent positive-dollar administrative credits/adjustments rather than only cancellations — but the underlying conclusion holds regardless of sign: none of the 66 were real customers.

**Field 1 status: rebuilt, re-verified, and finalized against the amended table.** Customer count revised from 5,941 to 5,875, with the exact difference identified and explained at the individual customer level, not just accepted as a plausible-sounding number.

### Field 2 Rebuild: Frequency (post-amendment)

**64** — Re-ran completed-orders-only frequency against the amended table. Top customer 14911 dropped from 398 to **373** completed orders — 25 of the original count were administrative entries, not real orders.

**65** — Re-ran all-distinct-orders frequency against the amended table. Same customer dropped from 510 to **466** — a reduction of 44.

**66** — Rebuilt the comparison. Customer 14911's cancellation gap is now 466 − 373 = **93**, down from the original 112. The 19-order difference (112 vs. 93) confirms that roughly a sixth of that customer's originally-measured "cancellations" were actually administrative invoice activity incorrectly counted as customer order behavior — exactly the contamination this rebuild was meant to catch and remove.

**Field 2 status: rebuilt and re-verified against the amended table.** `frequency_completed` and `cancellation_count` now reflect genuine customer behavior only, with administrative activity fully excluded from both components.

### Field 3 Rebuild: Monetary Value (post-amendment)

**67** — Re-ran monetary_gross against the amended table. Top customer unchanged (18102, $580,987.04, identical to pre-amendment — this customer's gross purchases apparently included no administrative-code contamination). Other totals shifted downward across the board as administrative activity was removed.

**68** — Rather than assuming customer 12918's absence from query 67's result list was sufficient proof, directly confirmed it: queried `clean_transactions` for any row at all belonging to customer 12918. Result: **0 rows** — fully and directly confirmed absent, consistent with query 63's finding that their entire transaction history was administrative activity (the three "Manual" entries that caused the original exact-doubling anomaly).

**69** — Re-ran monetary_net against the amended table. Top customer unchanged (18102, $578,408.64, close to the rebuilt gross figure — the small remaining gap now reflects genuine cancellation activity, not administrative contamination).

**70** — Checked whether the other four customers from the original exact-doubling finding (16446, 14802, 15802, 13290) were also now fully absent, the way 12918 was confirmed absent in query 68. Result: three were absent as expected, but **customer 16446 still had 4 remaining rows** — an unexpected result worth stopping on rather than dismissing.

**A correction to the record.** Re-examining query 56's original data showed 16446 had been mischaracterized: their numbers ($168,472.50 gross / −$6.10 net) reflect near-total cancellation of a large purchase history, not the exact negative-mirror pattern the other four customers showed. Grouping 16446 with the true exact-doubling cases in the earlier writeup was an error, now corrected here.

**71** — Pulled all 4 of 16446's remaining rows directly. Found something significant: one single transaction — 80,995 units of "PAPER CRAFT, LITTLE BIRDIE" (stock_code 23843) at £2.08, purchased and self-cancelled twelve minutes later — accounts for nearly the customer's entire gross total ($168,469.60 of $168,472.50).

**72** — Checked this product's typical order size for comparison, the same way the original 12,540-unit outlier was verified in Chapter One. Result: only 2 rows exist for this stock code in the entire `clean_transactions` table — the purchase and its own cancellation. No other order of any size exists to compare against.

**73** — Checked the untouched `raw_transactions` table directly, in case cleaning steps had removed other legitimate instances of this product. Result: identical — only these same 2 rows exist anywhere in the original 1,067,371-row dataset. This product was never ordered by anyone else, ever.

**Conclusion: a third, previously-undetected gap.** This is a confirmed data entry error — a stock code appearing for the first and only time in the dataset's history, at a quantity roughly 674 times larger than any other single order seen in this project, self-cancelled twelve minutes later, on December 9, 2011 (the dataset's final recorded day). It passes every exclusion rule built so far (real stock code, real customer, properly 'C'-prefixed cancellation), which is why it survived two prior table amendments undetected. Because the purchase and cancellation are equal and opposite, it does not distort `monetary_net` — but it does inflate `monetary_gross` and both frequency counts, since it carries a genuine invoice number. Decision: exclude it from `clean_transactions` regardless of its negligible net effect, on the same principle applied throughout this project — a confirmed data entry error doesn't get kept just because it happens to cancel itself out; the row is factually wrong and shouldn't be trusted in any downstream calculation, and it will also be logged as its own tracked issue for the eventual data-quality findings summary, the same way prior confirmed errors have been.

**74** — Amended `clean_transactions` a third time, adding one specific exclusion for stock_code 23843 (both the 80,995-unit purchase and its cancellation) on top of every rule already in place. Like queries 24, 38, and 59 before it, this is a `DROP TABLE` + `CREATE TABLE AS` statement with no matching file in `/output/`. This amendment invalidates the row-level correctness of Fields 1, 2, and 3 as rebuilt against the second amendment — all three require one more rebuild pass before Chapter Two can proceed to Field 4.

**75** — Verified the third amendment applied correctly: zero rows remain for stock_code 23843, and the row count dropped by exactly 2 (the purchase and its cancellation), matching expectations precisely.

**A note on why these fields are built one at a time, not all six together.** Both the administrative-code contamination (queries 56-58) and the 16446 outlier (queries 70-73) were caught specifically because each field was built, compared against itself two ways, sorted by the gap, and actually looked at before moving to the next field — not because of anything inherent to SQL that requires this. If all six fields had been built together in one wide query from the start, that comparison-and-sort mechanism could technically still exist, but a table with a dozen-plus columns per customer is far harder to scan by eye, and there's real pressure to treat "the query ran without an error" as "done," skipping the manual review that actually found these gaps. Answering six questions simultaneously makes it easy to get lost in the aggregate; answering one question at a time, on its own smaller result set, keeps the anomaly small enough and isolated enough to actually notice. The errors in this chapter weren't caught by clever SQL — they were caught by deliberately narrowing focus to one field, looking at it directly, and only then moving forward.

### Third Rebuild Pass: Fields 1, 2, and 3 (post-third-amendment)

With `clean_transactions` amended a third time, every field already built needed to be re-run and re-verified once more — the same full discipline applied after the second amendment, not skipped just because this gap was smaller in scope.

**Field 1 (Recency), rebuilt.** Query 76 re-ran the recency field against the third-amendment table. A specific concern was checked directly rather than assumed: since customer 16446's excluded transaction was dated 2011-12-09 (the dataset's final recorded day), it was worth confirming the dataset's maximum date itself hadn't shifted. It hadn't — multiple other customers had later transactions that same day. Query 77 confirmed the distinct customer count held steady at 5,875, matching the second-amendment figure exactly, since customer 16446 retained other legitimate transactions and wasn't fully removed from the table the way the 66 administrative-only customers were.

**Field 2 (Frequency), rebuilt.** Queries 78 and 79 re-ran completed-only and all-orders frequency against the third-amendment table. Customer 16446 was spot-checked directly in both: `frequency_completed` dropped to exactly **1** (their one remaining legitimate invoice, 553573), and `frequency_all_orders` also came back at **1**, confirming their `cancellation_gap` is now correctly **0** — fully resolved from whatever inflated figure included the erroneous invoice pair. Query 80 rebuilt the full comparison and confirmed no other customer's numbers were affected by this amendment; the sorted-by-gap list matched the second-rebuild result exactly at every position above 16446.

**Field 3 (Monetary Value), rebuilt.** Query 81 rebuilt `monetary_gross`; query 82 spot-checked customer 16446 directly and confirmed their gross value dropped to **$2.90** — the combined value of their two legitimate items, down from the original $168,472.50 that was almost entirely the erroneous 80,995-unit transaction. Query 83 rebuilt `monetary_net`; query 84 confirmed customer 16446's net value was **also $2.90**, essentially unchanged from before this amendment. This was the expected and predicted outcome: because the erroneous purchase and its cancellation exactly offset each other (+£168,469.60 and −£168,469.60), removing both together could only ever affect `monetary_gross` and frequency, never `monetary_net` — confirmed directly rather than left as an assumption.

**Third rebuild pass status: complete.** All three fields (Recency, Frequency, Monetary Value) have now been built, broken, diagnosed, and rebuilt twice over the course of this chapter — once for the administrative-code gap, once for the isolated 80,995-unit outlier — with every claim about what changed and why verified against actual query results rather than inferred. `clean_transactions`, and every field derived from it, is now considered fully reconciled heading into Field 4.

### Field 4: Order-to-Order Interval

**85** — Built the interval field as average days between a customer's consecutive completed orders, using `EXTRACT(DAY FROM ...)` to measure whole-day gaps, consistent with the day-based convention used in recency. Only meaningful for customers with 2 or more completed orders; single-order customers do not appear in this result. Cross-checked against Field 2: `orders_used_in_calc` values matched `frequency_completed` minus one for every customer checked, confirming the interval logic is drawing from the same underlying order data as frequency.

**A related but separate question raised during this field's construction:** whether cancelled orders should count toward interval spacing, and — a distinct question from a stakeholder's perspective — whether customers who cancel an order tend to return afterward at all. The second question is a retention question, not an interval-spacing question, and was built and tracked separately rather than folded into Field 4.

**86** — Built as its own standalone check: for every customer with at least one cancellation, whether they placed a completed order after their most recent cancellation date. Result: **1,741 customers (71.3%) returned and ordered again after cancelling; 702 (28.7%) never returned.** Tracked as a distinct finding, not part of any of the six core fields.

**A methodological fork: whole-day vs. fractional-day interval measurement.** Spot-checking customer 18139 (query 87's whole-day result showed `avg = 0.0` despite having 6 completed orders) confirmed real elapsed time between their orders — hours apart within a day, and roughly 17 hours overnight — that the whole-day calculation rounds down to zero. Rather than choosing one measurement standard, both were built and are tracked side by side, consistent with the standing practice established across this chapter (return rate, frequency, monetary value): when a genuine measurement choice exists, build both sides and let the comparison inform the field rather than settling on one definition in advance.

**87** — Whole-day interval (the original query 85 logic, renumbered to sit alongside its fractional counterpart). Matches the day-based convention used elsewhere in this project; understates spacing for customers whose orders cluster within 24-hour windows.

**88** — Fractional-day interval, using `EXTRACT(EPOCH FROM ...)` divided by 86,400 seconds to preserve sub-day precision. Customer 18139 now reads as 0.17 days instead of 0.0, correctly distinguishing tightly-clustered same-day orders from the smallest possible gaps. Row counts matched query 87 exactly across every customer checked, confirming both versions are built from identical underlying order data and differ only in measurement precision.

**Field 4 status: complete, two-component field.** `avg_interval_whole_day` and `avg_interval_fractional_day` are both tracked as permanent parts of the customer profile, alongside the separately-tracked cancellation-return finding (query 86).

### Field 5: Product Diversity

Following the same both-sides practice, using the two-tier structure identified in Chapter One (Phase 2, query 05): stock codes can represent a specific variant (e.g., 15056BL) or roll up to a base product family (e.g., 15056, covering all colorways of that item).

**89** — Built variant-level diversity: distinct stock codes purchased per customer, using completed orders only. Top customer: 14911 at 2,546 distinct variants.

**90** — Built family-level diversity: distinct product families purchased per customer, stripping trailing letters from stock codes to roll variants up to their base item. Same customer: 2,348 distinct families. Checked across the top three customers (14911, 12748, 17841): family counts were lower than variant counts in every case, consistent with multiple variants collapsing into shared families.

**Field 5 status: complete, two-component field.** `distinct_variants_purchased` and `distinct_families_purchased` are both tracked as permanent parts of the customer profile.

### Field 6: Return Rate (rebuild)

Recalculated against `clean_transactions`, applying the order-level and line-item-level methodology already established and compared in Chapter One (queries 11–13), which had been built against `raw_transactions` before the clean table existed.

**91** — Order-level return rate rebuilt: cancelled orders divided by total orders, per customer.

**92** — Line-item-level return rate rebuilt: cancelled line items divided by total line items, per customer.

**93** — Joined both measures with a gap column, same comparison pattern used for frequency and monetary value. The gap was positive (order-level higher than line-item-level) for nearly every customer — a pattern consistent with cancelling a small number of whole orders that each represent only a small fraction of total line items across a customer's full order history. Two customers showed the reverse pattern: customer 15369 (8.3% order-level vs. 40.4% line-item-level) and customer 15461 (33.3% vs. 60.0%), where cancelled activity concentrated as a high proportion of items within a small number of orders rather than spreading across many separate cancelled orders.

**Field 6 status: complete, two-component field.** `order_return_rate_pct` and `line_item_return_rate_pct` are both tracked as permanent parts of the customer profile, completing the rebuild of all six derived customer behavior fields against the fully reconciled `clean_transactions` table.

### Final Field Assembly

**94** — Joined all six fields (recency, frequency, monetary value, order-to-order interval, product diversity, return rate — eleven component columns in total, since four of the six fields are two-part) into one permanent table, `uk_retail.customer_behavior_fields`, one row per customer. Like queries 24, 38, 59, and 74 before it, this is a `DROP TABLE` + `CREATE TABLE AS` statement with no matching file in `/output/`. Row count: 5,875, matching the established distinct customer count exactly.

**95** — Spot-checked customer 13468's full row against every value already independently verified earlier in this chapter: recency (1 day, matching query 48), frequency (72 completed, 14 cancelled), monetary value ($12,793.28 gross, $12,518.01 net), both interval measures (9.9 whole-day, 10.35 fractional-day), both diversity measures (290 variants, 278 families), and both return rate measures (16.3% order-level, 2.9% line-item-level). Every value matched exactly.

**Chapter Two status: core deliverable complete.** `uk_retail.customer_behavior_fields` — 5,875 customers, eleven derived columns across six behavioral dimensions — is built, verified at the individual customer level, and ready to serve as the direct input for the eventual 3D visualization.

### Resolving an Open Question from Chapter One: The No-Customer-ID Rows

Query 35's review (item 4, Phase 7) flagged an undecided question: whether to keep or exclude the 243,007 rows with no customer_id from `clean_transactions`. That question was never formally resolved in writing at the time — every customer-level field built since has functionally excluded these rows via `WHERE customer_id IS NOT NULL`, but that was an operational default carried forward, not a documented decision.

Deliberately deferred to this point in Chapter Two rather than resolved back in Chapter One: `clean_transactions` needed to be fully reconciled first. Two further rounds of contamination were found and removed after Chapter One's formal close — the administrative stock codes (queries 56-60) and the isolated 80,995-unit outlier (queries 70-75). Segregating and investigating the no-customer-ID rows before those amendments would have meant working from a table that still had unrelated noise mixed into it. With `clean_transactions` now fully reconciled through three amendments, this question can finally be resolved against a trustworthy base rather than one that would have needed revisiting anyway.

**96** — Built `uk_retail.unattributed_transactions` as a copy of every row in `clean_transactions` where `customer_id IS NULL`. `clean_transactions` itself is left completely unchanged — this is a copy for reference and future examination, not a removal, consistent with this project's standing rule established with `excluded_rows`: never delete, always segregate and preserve. Unlike `excluded_rows`, nothing here has been identified as a data entry error — these are legitimate transactions missing a customer identifier, a common real-world pattern (guest checkouts, anonymous sales), not evidence of a mistake. Result: 228,297 rows via the `CREATE TABLE AS` statement itself.

**97** — `97_unattributed_transactions_reconciliation.sql`. Directly re-confirms the no-customer-ID row count against `clean_transactions` itself (`SELECT COUNT(*) WHERE customer_id IS NULL`), independent of query 96's `CREATE TABLE AS` result, before accepting 228,297 as final — consistent with this project's standing rule of not trusting a table-build result without an independent check.

**Result: 228,297 — confirmed, matching query 96 exactly.** This is not the originally reported 243,007 figure. The gap (243,007 − 228,297 = 14,710) is fully explainable: the 243,007 figure was established in Phase 5 (query 14), against `raw_transactions`, before deduplication and any of the three subsequent `clean_transactions` amendments. Some portion of the original no-customer-ID rows were themselves exact duplicates, administrative-code rows, or otherwise excluded during cleaning — removed from `clean_transactions` for those separate, already-documented reasons before ever reaching this segregation step, and therefore no longer present to copy. The 14,710-row difference is not a new error; it reflects rows already accounted for elsewhere in this project's cleaning history.

---

## Chapter Three — 3D Visualization

With `uk_retail.customer_behavior_fields` built and verified in Chapter Two, this chapter tests the project's founding question directly: does a fully rotatable, interactive 3D structure — turnable on any axis to view from every side, top, and bottom, plus hover detail and (in Chapter Four) drill-down — surface relationships that a flat table or a standard 2D chart cannot? Built in-browser using Plotly.js, against the full 5,852-customer dataset (the 23 never-converted, cancellation-only customers held out — see Chapter Two's `unattributed`/NULL handling for the same logic applied here).

### Building the 3D Structure

**98** — Exported `98_rfm_export_for_visualization.csv`: customer_id, recency_days, frequency_completed, monetary_gross for all 5,875 customers from `customer_behavior_fields`. Of these, 23 carry NULL frequency/monetary values — customers whose entire order history consists of cancellations, with no completed orders to aggregate. Held out of the 3D plot rather than dropped, consistent with this project's standing rule of documenting rather than erasing inconvenient data; flagged as a legitimate "never-converted" customer category for future investigation, not junk data. 5,852 customers plotted.

**Chart build.** Recency, frequency_completed, and monetary_gross (the classic RFM triad) selected as the first X/Y/Z test from eleven available derived fields, chosen for immediate interpretability over an arbitrary combination. Initial linear-scale build was visually dominated by 3-4 extreme outliers, flattening the remaining ~5,848 customers into an undifferentiated mass — diagnosed as a power-law distribution problem (monetary_gross ranges from £2.90 to £580,987.04). Rebuilt with log10 scaling applied to the Z-axis and color mapping only; real £ values preserved in axis labels, colorbar, and hover tooltips. Confirmed valid: monetary_gross has no zero or negative values, so no floor-value workaround was needed.

**Findings surfaced from rotating the log-scaled chart:**
- **Recency–monetary funnel:** no customer with recency past ~300-400 days ever reaches high monetary value. High spend and recent activity travel together; there is no population of "lapsed whales." *[Revised by Query 105 (recency_monetary_funnel_fixed_bucket_check) and Query 106 (recency_monetary_funnel_quartile_crosstab), run July 18, 2026 to confirm this chart-rotation finding in SQL for the first time. The absolute claim did not hold — MAX monetary_gross does not funnel with recency at all; erratic spikes appear at every recency range (e.g. £77,352.96 at 300-349 days, £34,023.26 at 600-649 days), and 61 of 1,463 top-monetary-quartile customers also sit in the most-lapsed recency quartile. Revised statement: average customer spend declines steadily as recency increases, but a small, real population of high-value dormant customers ("lapsed whales") exists at every recency level. The funnel governs the typical customer; it does not govern the tail. See "Post-Chapter-Three Verification Pass" below for the full investigation, including a further revision of the £77,352.96 figure itself in Query 111, and resolution of the £65,500.07 figure in Query 121.]*
- **Frequency–monetary lockstep:** rotating toward the frequency axis showed the same pattern — high frequency is almost entirely confined to low recency. Three variables telling one story rather than three independent stories; worth stating directly as a finding rather than treating all three as equally independent signals for this dataset. *[Revised by Query 107 (frequency_recency_lockstep_fixed_bucket_check), run July 18, 2026. The general lockstep pattern held — AVG frequency_completed declines steadily with recency in the same shape as the monetary funnel. No change to this statement; see the frequency-spike boundary revision below for the related but distinct claim that was corrected.]*
- **Veer-off observation:** at certain rotation angles, clusters that appear unified from one view visibly split into separate groups when rotated — points that read as one cluster from a flat projection resolve into distinct behavioral groups from another angle. *Attribution note: this observation was made by direct, first-person visual inspection while manually rotating the rendered chart. Claude does not have the ability to see rendered visual output and did not independently verify this observation — it is documented here as my direct observation, not a joint finding.* *[CLOSED by Query 120, cross-referenced against Query 111 — the same customer (12346), found via two independent paths. See "Closing the Veer-Off Observation," below, for the full account.]*
- A second chart variant (Option 2: customers sorted by monetary_gross ascending along X, frequency and recency plotted as a connected line rather than independent points) confirmed the frequency-monetary lockstep from a different angle: frequency stays low and flat across most of the monetary-sorted range, then spikes sharply only in the top ~15-20% of customers by spend. *[Revised by Query 108 (frequency_monetary_lockstep_decile_crosstab), run July 18, 2026, built specifically to test this "top 15-20%" estimate against real percentile boundaries. Revised statement: AVG frequency climbs gradually through monetary deciles 1-9, then jumps sharply in decile 10 (90th+ percentile) — 26.84 vs. decile 9's 10.26, a 2.6x jump. The spike is concentrated in the top decile specifically, not the broader top 15-20% the chart rotation suggested.]*

**Methodology framing statement (adopted for this chapter):** *"A static chart shows you my answer. A rotatable one lets you find your own question."* Interactivity transfers interpretive control from analyst to stakeholder — a viewer can search for the pattern relevant to their own context rather than being shown only the analyst's chosen angle. This project uses three distinct interactive mechanisms, each earning its place differently: **full 360° rotation** (viewable from any axis — top, bottom, and all sides) surfaced the recency-monetary funnel, the frequency-monetary lockstep, and the veer-off observation; **hover detail** surfaced the customer 17961 anomaly; and **drill-down** (Chapter Four) is the planned mechanism for letting a stakeholder move from a summary view to the specific customer or cohort behind it. Full rotation matters specifically because a 2D scatter plot can hide one point directly behind another — turning the structure is what lets a hidden relationship come into view.

### Method Honesty Assessment

A deliberate pause was taken to evaluate the technique against a specific test case rather than ride momentum on the funnel/lockstep findings alone. **Conclusion, to be preserved as-is:** the recency-monetary funnel and frequency-monetary lockstep are genuine findings that a single 2D chart would likely require prior suspicion to go looking for — real value in hypothesis generation and stakeholder communication. The customer 17961 anomaly (below), by contrast, would have been found faster and more reliably by a simple SQL ratio query (`monetary_gross / frequency_completed`, sorted ascending) — the 3D chart did not outperform the boring method here, it just arrived by a different, less efficient path. **Honest framing for this chapter:** the visualization is a strong hypothesis-generation and communication tool, not a replacement for standard outlier detection (z-scores, IQR, ratio queries). The rigorous methodology is: visualization suggests where to look, SQL/stats confirm what's actually there. Both halves are represented below for every finding in this chapter — none are accepted from the chart alone.

**Public prior-art check (web search conducted):** 3D RFM scatter plots using this general approach are an established, published technique, including at least one other public case independently applying log-normalization to frequency for the same skew reason encountered here. Tableau + Plotly embedding (web object + URL action) is also documented prior art. No public example was located combining a bucketed, hypothesis-driven anomaly drill-down — Tableau as the 2D KPI layer, with dashboard actions opening purpose-built 3D Plotly deep-dives scoped to specific behavioral buckets on a documented, forensics-style cleaned dataset. Framed conservatively: no public examples were *found* combining these elements this way — a search gap is not proof of absence, and this is stated as such rather than as a claim of true novelty.

### Verifying the Recency Gap — and Finding a Real One Instead

While rotating toward the recency axis, a possible density gap was noticed in the 100-250 day range — flagged explicitly as a *candidate*, not a confirmed finding, pending a SQL check.

**99** — `99_recency_gap_histogram_check.sql`. Bins all customers by `recency_days` into 25-day buckets, counting customers per bucket, to test whether the apparent 100-250 day gap is a real drop in density or a rendering/overplotting artifact of the 3D chart. Run in SQL, then the bucket counts were plotted as a 2D bar chart — consistent with this project's established verification workflow (Chapter Three's Method Honesty Assessment): a table of 30 bucket counts is technically readable, but the chart is what makes a real structural feature versus normal decay immediately obvious rather than requiring the numbers to be scanned row by row.

**Result: the 100-250 day range is not a gap.** The bucket counts (267 → 167 → 143 → 159 → 145 → 123 → 123) show smooth, continuous decay consistent with a normal recency distribution — most customers are recent, with a steady taper further back. What looked like a gap while rotating was overplotting: points thinning out visually as density drops, not a structural break in the data. Documented per this chapter's method-honesty standard: the visualization suggested a pattern, SQL did not confirm it.

**A genuine anomaly surfaced instead, one bucket range over — and it was the chart, not the raw numbers, that made it unmistakable.** Counts immediately before and after the 350-424 day range: 41 → 152 → 258 → 208 → 150, versus a smoothly decaying tail everywhere else. Plotted alongside the rest of the distribution, this range stands out as a clear, isolated spike rather than a subtle shift buried in a column of numbers. A count of 258 sitting in the middle of an otherwise-declining tail is a real structural feature, not noise, and became the next investigation thread.

### Investigating the 350-424 Day Recency Bump

**100** — `100_recency_bump_cohort_check.sql`. Three steps: (1) confirmed the reference date `recency_days` was calculated against, via `MAX(invoice_date)` from `clean_transactions`; (2) derived `last_invoice_date` per customer via a CTE against `clean_transactions` (not stored directly on `customer_behavior_fields`), joined to the 618 customers with `recency_days BETWEEN 350 AND 424`; (3) summarized by calendar month.

**Result: 180 / 307 / 131 customers across October / November / December 2010** — 618 total, matching the bucket count exactly. A ramp-up-then-drop-off pattern peaking in November, consistent with small wholesale/gift retailers stocking shelves ahead of the 2010 Christmas season, then not returning. The UK Online Retail II dataset is known to skew heavily toward small shop/reseller "customers" reordering stock rather than individual consumers, which supports the hypothesis.

**101** — `101_recency_bump_cohort_frequency_check.sql`. Pulled `frequency_completed` for the same 618-customer cohort (filtered on `recency_days BETWEEN 350 AND 424`, matching query 100's cohort definition exactly), bucketed into 1 order / 2-5 orders / 6-15 orders / 16+ orders.

**Result: 259 / 306 / 45 / 8** across the four buckets (sums to 618). 91.5% *[should read 91.4% — 565/618 = 91.42%, not 91.5%; a small rounding slip in this original write-up, only caught during the July 25, 2026 re-verification below]* of the cohort placed 5 or fewer orders total, with 259 being pure one-time buyers. Only 8.6% *[superseded — see the July 25, 2026 revision, below: the true figure is 8.1% (50/618) once the 16+ bucket is corrected]* ever reached 6+ orders — the range where "established regular who churned" would be a more credible read than "seasonal one-off." **This is a low-frequency, seasonal-acquisition cohort, not a group of lost regular customers** — a meaningfully different story for a stakeholder-facing write-up than "we lost loyal customers."

**Methodological note preserved from this investigation:** the first draft of query 101 filtered on `last_invoice_date` directly (Oct 1 - Dec 31, 2010) rather than on the existing `recency_days` column, and returned 700 customers instead of 618 — a second, independent derivation of what should have been the same cohort, introduced by mistake. The fix was not to reconcile the two counts but to recognize the second definition as an error and drop it in favor of the single existing source-of-truth column (`recency_days`, already established and verified in query 100). Standing rule for the remainder of this project: when two independently-derived queries disagree on what should be the same group, the fix is to find and remove the accidental second definition, not to average or reconcile the two.

**Finding, confirmed and closed:** the 350-424 day recency bump is a real, distinct cohort — 618 customers whose last purchase clustered in the November 2010 pre-Christmas stocking window, predominantly low-frequency/one-time buyers who did not convert to repeat behavior. Flagged as a candidate Tableau calculated-field bucket for Chapter Four, alongside the 23 never-converted customers from query 98.

**[Query 101's 16+ bucket count was later found to be off by 3, discovered and corrected during Chapter Four's Nov 2010 Cohort exhibit build — see "Revisiting Query 101," under Chapter Four, below, for the full account.]**

### Investigating Customer 17961

Surfaced via hover tooltip while rotating the RFM chart: rank 4673 by monetary_gross (£2,866.74), ~120 completed orders, 20-day recency — but an average order value of ~£24, anomalously low relative to peers at the same monetary rank.

**102** — `102_customer_17961_order_history.sql`. Pulled full order-level detail (invoice_no, invoice_date, stock_code, description, quantity, unit_price, line_total) for customer 17961 across the full dataset date range, to determine whether the low average order value reflects habitual small-basket buying, a wholesale/reseller pattern, or a data quality issue.

**Result: neither a data quality issue nor classic bulk-reseller behavior.** The order history (Dec 2009 through Nov 2011, ~50+ separate orders) shows a customer placing frequent small-basket orders — many line items at £1-£10 each — almost continuously across nearly two full years, with two standout large multi-item orders landing in late December of consecutive years (Dec 4, 2009 and Dec 21, 2010), each a large haul of exactly the small trinkets, candles, and stocking-filler items this retailer sells. Two trivial cancellations appear in the record and do not materially affect the pattern. **Interpretation: a small shop or market-stall reseller who restocks in modest increments most of the year, then places one larger order ahead of Christmas each year to build holiday inventory** — a different flavor of "small retailer, seasonal peak" than the 618-customer bump cohort above, but a thematically consistent echo of it: both findings point toward the same underlying customer base of small gift/wholesale shops stocking for Christmas, surfaced through two different investigative paths.

Per this chapter's method-honesty standard: this finding closes out the case noted above — the 3D chart found 17961 by a slower, less direct path than a simple ratio query would have, but the chart-to-SQL-confirmation workflow is what turned an isolated visual anomaly into a defensible, documented finding.

### Rolling-Average Confirmation of the Frequency-Monetary Lockstep

Option 2's connected-line trace (customers sorted by monetary_gross ascending, frequency and recency plotted as a line) confirmed the lockstep finding, but the raw line was visibly noisy at full scale (5,852 points) compared to the smoother 958-point sample built earlier in this sprint. Anticipating that a stakeholder presentation would draw the same "is this just noise?" question, a rolling-average version was built as the answer to have already prepared, rather than worked out live: mean `frequency_completed` and `recency_days` per 200-customer rolling window along the monetary-sorted axis, with the raw noisy points retained underneath at low opacity so the smoothing is visible as a transformation of real data, not a hidden step.

**Result: the rolling average confirms the raw-line pattern exactly.** Frequency stays low and flat for roughly 80% of customers, then rises sharply in the top 15-20% by spend; recency declines the same way across the same range. No new pattern was introduced by smoothing — the noisy version and the smoothed version tell the same story, which is itself the finding: this isn't an artifact of overplotting, it's a real, stable relationship visible at any level of aggregation.

**Chapter Three status: core findings confirmed, write-up not yet drafted. Closed July 16, 2026 — 10 days after the July 6 project start.** Confirmed findings ready for narrative and business-recommendation drafting: the recency-monetary funnel, the frequency-monetary lockstep (confirmed twice, by raw line and rolling average), the 618-customer November 2010 stocking cohort, and the customer 17961 seasonal-reseller pattern. The veer-off observation stands as a qualitative, first-person finding per the attribution note above. Chapter Four (Tableau + bucketed drill-down architecture, wiring confirmed buckets to purpose-built Plotly deep-dives via URL actions) has one week allotted, with the entire project — Chapter Four included — targeted for full completion by July 26, twenty days after the project's July 6 start.

**Post-close update (July 18, 2026):** the funnel and lockstep findings above were run through SQL confirmation for the first time (see "Post-Chapter-Three Verification Pass," below) before being built into Chapter Four's calculated fields. Both held directionally but were revised in their specifics — the funnel is not absolute (a real lapsed-whale tail exists), and the frequency spike is narrower than originally estimated (top decile, not top 15-20%). The verification pass also surfaced that `monetary_gross` materially overstates individual customer value in at least 7 cases due to cancelled bulk orders — Chapter Four's dashboard will default to `monetary_net` as a result. The veer-off observation, unconfirmed as of this update, was later closed — see "Closing the Veer-Off Observation," below.

---

## Post-Chapter-Three Exploration — The Remaining Eight Fields

With Chapter Three formally closed, the evening of July 16 was spent on informal, undirected exploration of the eight derived fields the RFM-focused chapter never touched — `cancellation_count`, `avg_interval_whole_day`, `avg_interval_fractional_day`, `distinct_variants_purchased`, `distinct_families_purchased`, `order_return_rate_pct`, and `line_item_return_rate_pct` — against the same 5,852-customer population, no exceptions, consistent with the standing rule against changing the underlying dataset mid-exploration. Framed explicitly as low-stakes ("for giggles") rather than hypothesis-driven, but the same verification discipline applied regardless: nothing here gets written up as a finding without a SQL check behind it.

**103** — `103_full_field_export_for_exploration.sql`. Exported all eleven derived fields plus customer_id for the full 5,852-customer population (matching the same `frequency_completed IS NOT NULL` filter used throughout Chapter Three).

**Correlation heatmap.** Computed pairwise Pearson correlation across all eleven fields as a fast orientation pass before committing to any specific 3D trio. Two findings surfaced immediately:
- `avg_interval_whole_day` and `avg_interval_fractional_day` correlate at 1.00 — genuinely identical, not just similar, confirming these are two versions of the same measurement (as anticipated by the project's "build both" standing rule, same pattern as frequency completed-vs-all and monetary gross-vs-net).
- `distinct_variants_purchased` and `distinct_families_purchased` also correlate at 1.00 — more notable, since these are conceptually different granularities (specific product variants vs. product family/category), not the same measurement twice. For this dataset, customers who buy a wide variety of specific products also buy across a wide variety of product families, with no meaningful gap between the two views.
- `order_return_rate_pct` and `line_item_return_rate_pct` correlate at only 0.65 — genuinely different information, unlike the interval pair.
- `cancellation_count` correlates moderately-to-strongly with frequency (0.75), variants/families (0.57), and return rate (0.41/0.23) — flagged as the most promising untouched trio for a 3D pass, since moderate-not-perfect correlation leaves room for a cube to show spatial structure the correlation number alone can't.

**Cube: cancellation_count, order_return_rate_pct, frequency_completed.** Built as a rotatable Plotly 3D scatter (1,800-point sample) using the trio flagged above. Two distinct structures were visually identified while rotating — attributed here as first-person, direct observation, per this project's established attribution standard (Claude cannot see rendered visual output and did not independently confirm either shape):

> *"I see a wave form and a spray formation."*

Recolored on a second pass — high-return-rate customers (`order_return_rate_pct > 30`) highlighted against the main population in gray — to separate the two structures visually rather than blending them into one gradient. The recolored view confirmed: a dense, curved main population (the "wave," where frequency and cancellation count rise together in a smooth sweep, staying near 0% return rate — this is what the heatmap's 0.75 frequency/cancellation correlation looks like in space) and a distinct, sparser cluster (the "spray") breaking off in its own direction — low-to-moderate frequency and cancellation count, but a wide range of return rate (20-70%), not following the wave's curve.

**104** — `104_high_return_low_frequency_cluster.sql`. Pulled full field detail for the "spray" cluster (`order_return_rate_pct > 30 AND frequency_completed < 10`) to determine whether this is a genuine distinct customer behavior or an artifact.

**Result: the spray is a statistical artifact of low order counts, not a distinct customer population.** Across the returned cluster, `frequency_completed` is overwhelmingly 1-3, with very few customers reaching higher order counts. `order_return_rate_pct` and `line_item_return_rate_pct` diverge sharply and consistently: order-level return rate is high (33-80%) almost entirely because the denominator is tiny — with only 1-3 completed orders, a single order containing any return produces a large percentage almost automatically (e.g. customer 12590: 1 completed order, 75.0% order return rate, but only 5.6% line-item return rate). Monetary values across the cluster show no consistent skew.

**Standing rule added:** `order_return_rate_pct` is statistically unstable for customers with low order counts and should not be used in customer-facing buckets, dashboard metrics, or segmentation without either a minimum-frequency floor or being paired with the far more stable `line_item_return_rate_pct`. Using order-level return rate alone risks treating a one-time customer who returned a single item as behaviorally identical to a chronic high-volume returner. This applies directly to Chapter Four's bucketed drill-down design — any return-rate-based bucket must account for this before being built into the Tableau workbook.

**Status: exploratory, not yet a locked Chapter Three or Four finding.** The wave/spray observation and the return-rate-artifact conclusion are logged here for continuity but have not been assigned to a specific chapter — to be formally placed (likely as a Chapter Four design consideration, given the direct implication for bucket construction) when the write-up resumes.

---

## Post-Chapter-Three Verification Pass — Queries 105-119

Conducted July 18, 2026, before Chapter Four's Tableau build began. Chapter Three's Method Honesty Assessment established the rule this pass exists to enforce: *"the visualization suggests where to look, SQL/stats confirm what's actually there."* The recency-monetary funnel and frequency-monetary lockstep were written up as findings from chart rotation alone — this pass runs both through SQL for the first time, following the standard header format adopted this session (`-- Query [number]_[descriptive_filename]`, applied to 105 onward and retroactively owed on 1-104 as a deferred cleanup pass — see Open Items).

Per this project's standing both-forks rule, every claim below was tested with two independently-derived queries, run side by side rather than one to completion before starting the other.

### Recency-Monetary Funnel — Confirmed, Revised

**105** — Fixed 50-day recency buckets, MAX/AVG `monetary_gross` per bucket (mirroring query 99's bucketing approach). **106** — recency quartile × monetary quartile crosstab, testing the same claim without an arbitrary day cutoff.

**Result:** AVG monetary_gross decays steadily and consistently with recency in both forks — the funnel holds for the typical customer. But MAX monetary_gross does not funnel at all: erratic spikes appear at every recency range, including £77,352.96 at 300-349 days and £34,023.26 at 600-649 days. The quartile crosstab confirmed this directly: 61 customers sit in both the highest monetary quartile and the most-lapsed recency quartile — not zero, contradicting the original absolute claim.

**Revised finding:** average customer spend declines steadily as recency increases, but a small population of high-value outliers ("lapsed whales") exists at every recency level. The funnel governs the typical customer; it does not govern the tail.

### Frequency-Monetary Lockstep — Confirmed, Revised

**107** — same 50-day recency buckets as 105, MAX/AVG `frequency_completed` per bucket. **108** — monetary decile × frequency crosstab (deciles rather than quartiles specifically to test the original "top 15-20%" estimate against real percentile boundaries).

**Result:** AVG frequency declines steadily with recency, matching the funnel's shape — confirms the general lockstep tendency. But the frequency spike is narrower than originally estimated: AVG frequency climbs gradually through deciles 1-9, then jumps sharply in decile 10 (90th+ percentile) — 26.84 vs. decile 9's 10.26, a 2.6x jump. The spike is concentrated in the top decile, not the broader top 15-20% the chart rotation suggested.

**109** — cross-check: MAX frequency (107) and MAX monetary (105) both spiked in the identical 300-349 day bucket, adjacent to the confirmed 618-customer cohort. Speculated this might be the same customer showing up as an outlier on both axes at once — tested directly rather than assumed. **Disproved:** two unrelated customers, opposite profiles (customer 17850: 155 orders, high frequency; customer 12346: 3 orders, high monetary), neither flagged as a lapsed whale. A genuine methodological catch: an aggregate spike in two separate metrics landing in the same bucket does not imply a shared population driving both.

**110** — chased a second outlier (decile 8's MAX frequency of 100, breaking the otherwise-clean ascending pattern). Traced to customer 17961 — already investigated and closed in this chapter (see "Investigating Customer 17961," above). Cross-chapter consistency: the same customer surfaced independently via chart rotation in Chapter Three and via decile crosstab in this verification pass.

### The Gross-vs-Net Discovery

**111** — characterized customer 12346 (query 109's monetary outlier) by pulling their full transaction history. **Result: their £77,352.96 monetary_gross is almost entirely a single 74,215-unit bulk order (invoice 541431) cancelled 16 minutes later (invoice C541433).** Real net spend across their legitimate activity: ~£169.36. The "lapsed whale" outlier was a `monetary_gross` artifact, not a genuine high-value dormant customer.

This directly violated this project's standing both-forks rule — a `monetary_net` version of queries 105 and 106 should have existed from the start, the same way frequency-completed-vs-all-orders and interval-whole-vs-fractional were built as matched pairs. It was not. **112** (net twin of 105) and **115** (net twin of 106) were built in response, closing that gap.

**112 result:** AVG monetary_net tracks AVG monetary_gross closely — the central-tendency funnel is unaffected. But several MAX values dropped meaningfully once cancellations were excluded: 300-349 days fell from £77,352.96 to £50,407.77 (customer 12346's artifact removed); 200-249 days fell from £44,534.30 to £21,535.90 — a new, previously unexamined gap.

**115 result:** the lapsed-whale population barely changed (61 → 59 customers, a 3% shift) despite the individual MAX-value swings seen in 112. **This is not a contradiction** — the two forks are complementary readings of the same data: the quartile view shows the *population* of lapsed whales is real and stable; the fixed-bucket MAX view shows *individual figures* within that population can be badly distorted by cancellation artifacts.

**116** — chased the new 200-249 day gap. Traced to customer 15749: 3 orders, 1 cancellation, same signature as 12346 (£22,998.40 gap, 51.6% of gross). Two instances of the identical pattern, found by chasing individual buckets one at a time, prompted a shift to systematic detection.

**118** — full-dataset scan for the cancelled-bulk-order signature (low frequency, large gross/net gap). **Result: 7 customers match** — 12346, 15749, and five previously unexamined cases (12454, 13091, 16077, 12607, 14213), ranging from 51.6% to 221.1% of gross wiped out by cancellation. Three customers (16077, 12607, 14213) show gross spend that is entirely or almost entirely cancelled — real net contribution of zero. One customer (13091) shows **negative** net — cancellations exceed completed purchase value.

**Recommendation for Chapter Four:** the primary dashboard spend metric should default to `monetary_net`, since `monetary_gross` is demonstrably unreliable as a proxy for real customer value at the individual level — even though it performed adequately in aggregate/population views. `monetary_gross` remains available as a secondary/toggle metric, per this project's standing both-forks rule, rather than being dropped.

**119** — characterized customer 13091's negative-net anomaly specifically, since it differed structurally from the other 6 (a single genuine large cancellation). **Result: likely a source-data artifact, not genuine return behavior.** Two near-identical large cancellation invoices (C490807 and C490946) sit two hours apart on the same day, covering nearly the same item list — consistent with a duplicated cancellation record rather than two separate cancelled orders — followed by one completed replacement order covering only about half the item list. Flagged as a documented known exception for Chapter Four rather than corrected or excluded, consistent with this project's segregate-don't-delete standard.

### Nov 2010 Cohort — Monetary Profile Closed

**113** — characterized customer 17850 (query 109's frequency outlier) via monthly order history. **Result: genuine, sustained buyer, not an artifact.** 14+ months of real activity (Dec 2009-Feb 2011), including a Dec 2010 stocking-pattern spike echoing the confirmed 618-customer cohort's timing, in an otherwise unrelated high-frequency customer segment. Churned cleanly after a final small cancellation in Feb 2011. Confirmed as a legitimate lapsed high-value customer and a genuine counterexample to the original "no lapsed whales" claim.

**114** and **117** — the 618-customer Nov 2010 cohort's monetary distribution (queries 100-101 had only characterized frequency, never spend). Min £10.95, max £65,500.07, avg £913.76, median £468.08 — right-skewed. Bucketed breakdown: 70.9% of the cohort spent £100-999 (consistent with modest small-shop restocking), 22.7% spent £1,000-4,999, and 1.6% (10 customers) exceeded £5,000. Supports the original small-retailer-Christmas-stocking hypothesis for the bulk of the cohort, with a real high-spend tail. The cohort's £65,500.07 maximum was traced back to the same unexamined 350-399 day spike flagged in query 105. *[Resolved by Query 121 (350_399day_bucket_monetary_spike_check), run July 18, 2026: the £65,500.07 figure belongs to customer 16754 — 371 days recency, 29 completed orders, 5 cancellations, monetary_net £54,692.82. Unlike the cancelled-bulk-order artifacts found in customers 12346 and 15749 (query 118), this is genuine spend from a real, substantial order history — the gross/net gap (16.5% of gross) is consistent with ordinary cancellation activity, not a single large cancelled order. Confirmed as a real member of the lapsed-whale population, not an artifact.]*

### Visual Gut-Check

Per this project's standing practice ("anything consequential that doesn't naturally produce a chart should still receive an intentional visual pass"), a set of reference charts was built after the fact for queries 105-119 — not new findings, a second visual verification pass over numbers already confirmed in SQL. Saved as a standalone exhibit, later expanded to cover queries 120-121 as well (see "Closing the Veer-Off Observation" and "Closing the 350-399 Day Monetary Spike," below) and renamed accordingly to `gutcheck_105_121_funnel_lockstep_review.html`, styled consistently with the Chapter Three exhibit gallery. Confirmed added to the `3dplots/index.html` gallery — see Open Items for resolution status.

### Closing the Veer-Off Observation

**120** — with the exact axis mapping and chart region pinned down via direct screenshot review (the RFM cube's high-monetary/yellow zone), pulled the top 20 customers by `monetary_gross` alongside recency and frequency, to identify the specific customer breaking away from the main cluster. **Result: customer 12346 — the only top-20 customer at 325 days recency, versus 0-38 days for every other high-monetary customer in the list.** This is the same customer already investigated in query 111. The veer-off observation and the 12346 cancelled-bulk-order finding are the same discovery, reached by two independent paths — chart rotation first in Chapter Three, SQL ranking first in this pass. Closed; see the revision notation on the original Chapter Three entry, above.

### Closing the 350-399 Day Monetary Spike

**121** — pulled every customer in the 350-399 day recency bucket, sorted by `monetary_gross` descending, to finally trace the £65,500.07 figure left unexamined since query 105 and resurfaced unresolved in query 114. **Result: customer 16754** — 371 days recency, 29 completed orders, 5 cancellations, monetary_net £54,692.82 (gap only 16.5% of gross). Structurally different from the cancelled-bulk-order artifacts (12346, 15749): this customer has a real, substantial order history, and the gross/net gap is consistent with ordinary cancellation activity rather than one large cancelled order. **Confirmed as genuine spend** — a real member of the lapsed-whale population, not an artifact. Closes the last open thread from the funnel/lockstep verification pass.

## Chapter Four: Tableau Dashboard and 3D Drill-Down Exhibits

With Chapter Three's headline findings confirmed in SQL (see the verification pass immediately above), this chapter builds the stakeholder-facing deliverable: a Tableau dashboard where mark-click URL actions route to purpose-built 3D Plotly exhibits, letting a viewer move from a summary chart directly to the specific customer population behind it. This chapter also absorbs two pieces of retroactive housekeeping deferred from earlier chapters — the sequence-numbered header/verification-format retrofit owed on queries 1–104 (see Open Items), and, later, a correction to Query 101 discovered while extending this chapter's exhibit lineup to the Nov 2010 Cohort.

### Discovering NTILE Non-Determinism — Queries 122-128

Surfaced while building Chapter Four's Tableau calculated fields, translating the confirmed SQL findings into working IF-statement logic.

**122** — replaced an unchecked £5,000 guess for the "lapsed whale" monetary threshold with the actual boundary from query 115's confirmed 59-customer population. **Result: £2,180.28**, not £5,000 — the guess would have wrongly excluded a real portion of the confirmed population.

**123** — same correction for the recency side, replacing a guessed 400-day cutoff. **Result: 377 days.** The query's own output showed a tie at the exact boundary (quartile 3's max and quartile 4's min both reporting 377) — flagged at the time as "expected behavior," but this tie was actually the first visible sign of a deeper problem.

Built into Tableau as `Recency-Monetary Tier (Rev. Q105/106/122)`: `IF [Recency Days] <= 377 THEN "Recent" ELSEIF [Recency Days] > 377 AND ROUND([Spend (Net)], 2) >= 2180.28 THEN "Lapsed Whale" ELSE "Lapsed, Typical" END`. Filtered and counted in Tableau: **58**, not the 59 confirmed in queries 115/122.

Two hypotheses tested and ruled out before finding the real cause:
- **124** — checked whether the 377-day tie itself explained the gap (customers at exactly 377 days who might fall on the wrong side of a `>` vs `>=` comparison). All four customers at exactly 377 days had monetary values far below the whale threshold regardless — ruled out.
- **125** — checked for floating-point precision at the exact £2,180.28 threshold value (customer 15476 sits precisely there). Isolated directly in Tableau — 15476 computed correctly and was correctly tagged "Lapsed Whale." Ruled out.
- **126** — rather than continue testing individual hypotheses, reconstructed the full 59-customer list directly with the simple dual-threshold definition (`recency_days >= 377 AND monetary_net >= 2180.28`). **Result: 58, not 59** — confirming Tableau was correct all along, and the discrepancy lived in the original quartile-based queries, not in Tableau.
- **127** — identified the exact customer causing the gap: **customer 13542**, `recency_days = 376`, found sitting in `recency_quartile 4` despite being below the 377-day minimum that query 123 itself reported for that quartile.

**Root cause confirmed:** `NTILE(4) OVER (ORDER BY recency_days)`, used throughout queries 106, 115, 122, and 123, has no secondary tiebreaker column. PostgreSQL does not guarantee stable, reproducible ordering for tied rows without one — meaning the exact quartile boundaries and membership counts reported in those four queries are not guaranteed to reproduce identically on rerun. This is a genuine methodological gap: queries that were treated as fixed reference points for multiple subsequent queries this session were themselves non-deterministic.

**Decision:** rather than retrofit a tiebreaker and rerun the full NTILE chain to chase exact reproducibility, the simple dual-threshold definition — `recency_days >= 377 AND monetary_net >= 2180.28`, yielding **58 customers** — is adopted as the standard "lapsed whale" definition for all Chapter Four production use. It is fully deterministic, reproducible on every run, and easier to explain to a stakeholder than a population-quartile intersection. The NTILE-based 59-count remains documented as the original discovery mechanism (queries 106, 115) but is superseded for production use. Per this project's standing rule, queries 106, 115, 122, and 123 each carry their own revision notation rather than being silently corrected — see those files directly.

**128** — Applying the same non-determinism lesson to the separate Frequency Spike threshold before it could repeat the same mistake: rebuilt the top-decile monetary boundary using `PERCENTILE_CONT` rather than `NTILE`, specifically to get a threshold that doesn't depend on tie-breaking behavior at all. **Result: £5,224.45** net spend (90th percentile) — the value adopted directly into `Frequency Spike Tier (Rev. Q108/128)`. This closes the same class of gap query 127 found, pre-emptively, before it could surface downstream in Chapter Four's second bucketed field the way it did in the first.

**All five Chapter Four calculated fields** built from this verification pass (`Spend (Net)`, `Nov 2010 Cohort Flag`, `Never Converted Flag`, `Recency-Monetary Tier (Rev. Q105/106/122)`, `Frequency Spike Tier (Rev. Q108/128)`) — including full formulas, threshold history, and two independent verification passes each (initial build-time check, and a clean-rebuild-from-blank-sheet re-check) — are documented in full in `docs/chapter_four_calculated_fields.md`. *[Revised July 19, 2026 — see "Building the Chapter Four Drill-Down Exhibits," below: the `Recency-Monetary Tier` field was found to silently mislabel the 23 never-converted customers and was corrected. `docs/chapter_four_calculated_fields.md` reflects the corrected formula.]*

### Building the Chapter Four Drill-Down Exhibits — Queries 129-130

Mark-click URL actions wired to `Funnel Tier Overview`: clicking a bar opens a new browser tab to a 3D exhibit matching the clicked tier.

**Initial mapping error.** "Lapsed Whale" was first mapped to `gutcheck_105_121_funnel_lockstep_review.html` — a static 2D verification summary, not a 3D exhibit. Identified on first test click. No existing gallery exhibit isolated the whale population specifically; `uk_retail_rfm_3d_log.html` shows the full population only.

**129** — `129_lapsed_whale_exhibit_data_pull.sql`. Pulled `recency_days`, `frequency_completed`, `monetary_net`, and a whale flag (fixed dual-threshold definition, queries 122/126/127) for the full population. **Result: 58 Lapsed Whale / 5,794 Other**, matching the confirmed count. Used to build `lapsed_whale_isolated_3d.html`: full population plotted in gray, 58 whales rendered larger, colored on a log-scaled Viridis gradient by net spend. Log transform applied because whale spend is right-skewed — linear scaling compressed most points into one shade. Axis spike lines added for positional reference at close zoom.

**Count mismatch, second exhibit.** Reconstructing the "Lapsed, Typical" population directly from the same data produced 1,387 customers; the Tableau field reported 1,409. Gap of 22.

**130** — `130_never_converted_tier_leakage_check.sql`. Tested whether the 23 never-converted customers (query 98) were misrouted. **Result:** 1 customer at `recency_days <= 377` (routes to "Recent"), 22 at `recency_days > 377` (routes to "Lapsed, Typical") — exact match to the gap (4,407+1=4,408; 1,387+22=1,409). **Cause:** `monetary_net` is NULL for this group; Tableau's `ELSEIF` evaluates a NULL comparison as false, not an error, so these customers fall through to `ELSE` based on `recency_days` alone.

**Fix** — `ISNULL` check added as the first condition in `Recency-Monetary Tier (Rev. Q105/106/122)`:
```
IF ISNULL([Spend (Net)]) THEN "Never Converted"
ELSEIF [Recency Days] <= 377 THEN "Recent"
ELSEIF [Recency Days] > 377 AND ROUND([Spend (Net)], 2) >= 2180.28 THEN "Lapsed Whale"
ELSE "Lapsed, Typical"
END
```
Re-verified: **23 Never Converted / 4,407 Recent / 1,387 Lapsed, Typical / 58 Lapsed Whale**, sum 5,875.

Two further exhibits built from the corrected populations: `lapsed_typical_isolated_3d.html` (1,387 customers) and `recent_isolated_3d.html` (4,407 customers), same color/spike-line treatment. New field `Exhibit URL (Funnel Tier)` routes each tier to its exhibit:
```
IF ISNULL([Spend (Net)]) THEN "uk_retail_rfm_3d_log.html"
ELSEIF [Recency-Monetary Tier (Rev. Q105/106/122)] = "Lapsed Whale" THEN "lapsed_whale_isolated_3d.html"
ELSEIF [Recency-Monetary Tier (Rev. Q105/106/122)] = "Lapsed, Typical" THEN "lapsed_typical_isolated_3d.html"
ELSE "uk_retail_rfm_3d_log.html"
END
```
"Never Converted" and "Recent" route to the general RFM cube by default. A dedicated exhibit for the 23-customer Never Converted group was judged unnecessary given size; open for reconsideration (see Open Items).

**Visual style.** These three exhibits use a white background rather than the Chapter Three gallery's dark case-file styling, at author request — the dark palette compressed perceptual differences at the low end of the log-scaled color gradient on the whale exhibit's first draft.

---

### Building the Never Converted Exhibit — Queries 131-135

Revisits Open Item 4 below (never-converted dedicated exhibit, previously judged
unnecessary given population size). Deliberately run visual-first rather than
SQL-first — see the methodology note at the end of this section for why.

**131** — `131_never_converted_time_axis_check.sql`. Tested time-based fields
(`first_transaction_date`, `active_span_days`) as a third exhibit axis, since
`monetary_net` is NULL for the entire never-converted group by definition (the
same NULL that caused the Query 130 tier-leakage bug) and is not usable.
**Result:** 15 of 23 never-converted customers (65%) made their sole transaction
attempt within the dataset's first three weeks (Dec 1-22, 2009); the remaining 8
are isolated single-attempt cancellations scattered through 2010 with no further
clustering. `frequency_completed` and `active_span_days` are both degenerate for
this group (NULL/0 for all but one customer, customer 15767) and are not viable
axes. **Confirmed finding:** the never-converted group reads as an early-platform
abandonment cohort plus a thin unclustered tail, not steady-state churn.
`first_transaction_date` is the only field carrying real separating signal.

**132** — `132_never_converted_attempt_count_pull.sql`. Pulled a raw attempt
count (completed + cancelled invoices combined) to replace `frequency_completed`,
which excludes this group by definition. **Result:** 21 of 23 customers (91%)
made exactly one attempt, ever; only two (15767, 17632) made two attempts, none
made three or more. **Confirmed finding:** the group is overwhelmingly
single-attempt, not just zero-completed-orders — two distinct failure modes
(launch-window abandonment; scattered one-off tail), both single-shot.
`attempt_count` confirmed as a usable, non-degenerate (values 1-2) axis.

**133** — `133_never_converted_exhibit_data_pull.sql`. Consolidated Queries 131
and 132 into a single source-of-truth pull (`recency_days`,
`first_transaction_date`, `attempt_count`, boolean never-converted flag) for
exhibit construction. Data-shaping query, not a new finding.

**First exhibit build, and a real sampling bug.** The Query 133 result set was
pasted into the working session and truncated at 977 rows. Because the source
query was ordered by `recency_days` ascending, the truncation wasn't random —
every one of the 977 rows fell between `recency_days` 0 and 14, nowhere near the
never-converted group's actual range (371-738). The resulting exhibit
(`never_converted_signal_check_partial_sample.html`) understated the population's
spread and made the never-converted cluster look isolated in empty space for the
wrong reason. Caught by inspection, not by a formal check — worth noting as a
category of error a SQL-first workflow is less likely to produce, since it's
specific to how much of a result set survives being pasted into a chat interface.
Preserved under an honest filename with a superseded-by note rather than deleted,
per this project's segregate-don't-delete standard.

**134** — `134_never_converted_full_range_sample.sql`. Fixed the sampling method
itself: a systematic 1-in-9 pull ordered by `customer_id` (uncorrelated with
recency) rather than by the axis being plotted, guaranteeing full-range coverage
regardless of where a paste gets cut off. **Result:** 650 rows, confirmed
spanning `recency_days` 0-737 (vs. the flawed pull's 0-14), with a natural
concentration at the low end (304 of 650 rows under 100 days) reflecting the
population's real shape rather than a sampling artifact. Rebuilt as
`never_converted_isolated_3d.html` — the corrected base exhibit.

**Three colored variants** were built on top of the corrected base to test
whether the population's attempt-count layering (a striation effect produced by
the log-scaled Z axis rendering each integer attempt count as its own plane)
carried further structure:
- **Colored by `first_transaction_date`** (`never_converted_colored_by_date.html`):
  population forms a visible cohort gradient, recent (green) to old (purple).
  The 23 never-converted customers sit at the oldest edge of that gradient —
  consistent with, not additional to, Query 131's finding.
- **Colored by `attempt_count`**, log-scaled color mapping matching the log Z
  axis (`never_converted_colored_by_attempts.html`) — a linear color scale
  first collapsed nearly the whole population into one shade given the 1-466
  range; fixed the same way the Z-axis skew was handled. Surfaced a visible
  concentration of high-attempt customers around 500-700 days recency,
  concentrated in early (2009-2010) first-transaction cohorts by color.
  Flagged as chart-rotation-only pending SQL confirmation.
- **Colored by `recency_days`** (`never_converted_colored_by_recency.html`):
  no additional structure beyond what the other two variants already show.

**135** — `135_attempt_count_by_cohort_check.sql`. SQL-confirmed the high-attempt
tower observed in the colored-by-attempts rotation, by grouping all 5,875
customers into first-transaction quarterly cohorts and comparing mean, median,
and max `attempt_count` per cohort. **Result:** median attempt_count declines
nearly monotonically across cohorts — 10 (Q4 2009, n=1,040) → 6 → 4 → 3 → 2 → 2
→ 2 → 2 → 1 (Q4 2011, n=440) — with the average-to-median ratio staying roughly
constant (~1.3-2x) across all nine quarters rather than widening in the earliest
one. **Confirmed finding:** the tower is real and population-wide, not an
artifact of a small number of outliers like the 466-attempt customer — the
effect holds at the median across 1,000+ customers in the earliest cohort, not
just in the mean. `attempt_count` accumulation is substantially tenure-driven:
customers who joined earlier have simply had more calendar time to generate
attempts (completed and cancelled combined), independent of whether they ever
converted. Candidate for its own dedicated Chapter Four exhibit, separate from
the never-converted lineup, once that set is finalized.

**136** — `136_high_attempt_recency_distribution_check.sql`. A second rotation
of the colored-by-attempts exhibit (side angle, log Z axis facing the viewer)
appeared to show the high-attempt "tower" peaking around 250-350 days recency,
not at the 500-700 day range the Query 135 cohort-median trend might suggest.
Rather than accept either reading, this query pulled the actual recency_days
distribution for the top 5% of customers by attempt_count (threshold: >=25
attempts, 311 customers) directly. **Result:** 292 of 311 customers (94%) sit
at recency_days under 100 — not clustered at 250-350, and not at 500-700.
**The rotation's specific visual read was wrong.** This is not a subtle
refinement of the Query 135 finding; the claimed peak location was incorrect
by several hundred days. Most likely cause: overplotting and viewing-angle
density effects in a 650+ point log-scaled 3D scatter — the actual densest
cluster (near recency=0, where roughly a third of the full sample already
sits) can visually recede or partially occlude depending on rotation, while a
sparser, more isolated set of points elsewhere reads as more visually
prominent simply because it has open space around it. This is a known failure
mode of 3D scatter density, not a one-off fluke specific to this exhibit.

**Reconciled with Query 135, not contradicting it.** Query 135 measured
median attempt_count by COHORT (grouped by first_transaction_date) and found
older cohorts have higher medians — that finding stands, confirmed at the
median across 1,000+ customers per cohort. Query 136 measured something
different: where individual high-attempt OUTLIERS sit on the recency axis
specifically. The two are compatible: a customer can belong to an early,
high-median cohort by first_transaction_date while still showing low
recency_days, if they've simply remained active recently. The corrected,
sharper finding: this population's highest-attempt individuals are
disproportionately customers who are BOTH long-tenured AND still recently
active — sustained engagement, not a lapsed-and-done cohort. That is a
better, more specific finding than what the rotation alone suggested, and it
only exists because the rotation's claim was checked rather than trusted.

**Why this matters for the methodology note above:** this is the clearest
example in this thread of the standing "nothing becomes a finding on a chart
alone" rule doing real work, not just formal due diligence. The rotation
didn't just need refining — its specific, stated claim (peak at 250-350 days)
was factually wrong, and would have gone into this log incorrect if accepted
on sight. The rule caught it working exactly as intended.

**Geometric note, not a finding.** Rotating the corrected exhibit to the
Recency × First-Transaction-Date plane shows the 23 never-converted customers
falling on a near-perfect diagonal. This is a mathematical consequence of the
group's own definition, not discovered structure — 21 of 23 have exactly one
transaction attempt (Query 132), so `first_transaction_date` and
`last_transaction_date` are identical for them by construction, which forces
`recency_days` and "time since first touch" to be the same number. Recorded
here specifically so it isn't mistaken for a finding in a later pass.

**Open, unresolved:** final exhibit lineup and file naming for the gallery not
yet settled — decide between one preferred link, or a small multi-angle set
matching the Q98 source/full-scale/v2/log-scaled pattern already used for the
RFM cube.

#### Methodology Note — The Visual-First Experiment, and What It's Actually Testing

Queries 131-135 were deliberately run visual-first rather than SQL-first for
several of their findings — rotate the cube, spot a candidate shape, then
confirm or kill it in SQL. That's backwards from how a production analytics
workflow should run, and it was backwards on purpose: this project's founding
question is whether 3D rotation earns a place in the analytical toolkit, and
the only way to actually test that is to let the visual go first and see what
it's good for and what it isn't — not assume the answer and build the
efficient version.

Result, stated plainly: rotation reliably generated real candidates worth
checking — a tenure effect (Query 135, confirmed) and a launch-window cohort
(Query 131, confirmed). SQL confirmed both. But the visual layer also
introduced its own failure modes that a SQL-first pass never would have hit: a
truncated, badly biased sample (the first exhibit build's population backdrop
covered `recency_days` 0-14 only, nowhere near the group being studied), an
uncalibrated linear color scale that collapsed a 1-466 range into one shade,
a diagonal line that looked like discovered structure but was actually a
geometric necessity of the group's own definition, and — the sharpest case —
a specific, stated visual claim (Query 136: "the high-attempt tower peaks
around 250-350 days recency") that turned out to be factually wrong. The real
distribution put 94% of that population under 100 days, several hundred days
off from what the rotation appeared to show, most likely due to overplotting
and viewing-angle density effects in a dense log-scaled scatter. None of
those four were data findings. All four were visualization-layer failures,
caught and fixed the same way a bad SQL join gets caught and fixed — which is
itself informative about what working this way actually costs, and the last
one in particular is the clearest evidence in this project so far that a
rotation's specific numeric or spatial claim cannot be trusted on sight, only
the fact that it flagged something worth checking.

Honest conclusion so far: visuals are a strong hypothesis-generation layer on
top of disciplined SQL, not a replacement for it, and not a source of
confirmable specifics on their own — the flag is trustworthy, the read is
not. A tight SQL-first exploration script (group by cohort, compare mean to
median, done) likely reaches the same confirmed findings faster and without
the rebuild cycles or the risk of banking an incorrect visual read. What the
rotation adds is the prompt to ask the question in the first place, plus a
second, separate thing worth testing on its own terms: whether that same
rotation is a functional communication layer for a stakeholder who doesn't
read SQL output — someone who will never run Query 135 or 136 themselves but
might genuinely understand "customers who joined early have had more time to
try, twice" faster from a rotatable cube than from a table of cohort quarters
and medians. That's a different question from whether the visual finds things
correctly, and this project hasn't tested it yet. Worth its own explicit pass
before Chapter Four closes: hand a completed exhibit to someone outside the
analysis, with no SQL underneath it visible, and see whether they walk away
with the
correct finding or a wrong one.

---

### Header-Format Retrofit and Verification Pass — Queries 1–106

The sequence-numbered header format adopted at Query 105 (`-- Query [number]_[descriptive_filename]`, with WHAT/WHY preserved as originally written and RESULT/CONFIRMED FINDING blocks appended only after verification against actual pasted data) was owed retroactively on queries 1–104, which predate it. This retrofit pass, carried out July 21, 2026, applied that standard to queries 94 through 106 — chosen as a first slice rather than the full 1–104 range, since Field 6 and Final Field Assembly (queries 91–95) mark a natural chapter boundary just before Chapter Three begins.

**Status: complete for queries 1–106.** Queries 105 and 106 already carried the header at time of writing but had their RESULT/CONFIRMED FINDING blocks independently re-verified against the pasted CSVs during this pass, surfacing the corrections below. Queries 107 onward are not yet re-verified — this is a RESULT/CONFIRMED FINDING accuracy pass still owed, not a header retrofit, since those queries already carry the post-105 format (see Open Items).

**Corrections and discrepancies surfaced during this pass**, each also carrying its own append-only notation in the individual query write-up above:

- **Query 96** (`unattributed_transactions`): WHAT block claimed 243,007 rows; actual `CREATE TABLE AS` result was 228,297. Resolved by Query 97's independent re-confirmation (228,297, matching exactly) — the gap traces to the 243,007 figure being pre-deduplication (Query 14, against `raw_transactions`), not a new error.
- **Query 99** (recency gap histogram): `WHERE recency_days IS NOT NULL` does not exclude the 23 never-converted customers as commented — it's a no-op, since `recency_days` has no NULLs (only `frequency_completed`/`monetary_gross` are NULL for those 23). Total returned was 5,875, not 5,852. The hypothesized 100-250 day density gap was not confirmed; a genuine, unhypothesized dip-then-rebound at 325-424 days was found instead.
- **Query 100–101** (recency bump cohort): Confirmed the 350-424 day bump as a real, dateable Oct-Dec 2010 seasonal cohort — 618 customers, 91.4% with ≤5 orders, consistent with the previously established seasonal-acquisition finding. This pass verified only that aggregate figure — not Query 101's full four-bucket breakdown. That distinction matters: see "Revisiting Query 101," immediately below, for a further correction this pass did not catch.
- **Query 102** (customer 17961 order history): WHAT block claimed ~120 completed orders / ~£24 average order value; actual pulled data showed 100 completed orders / £28.67 average. Resolved by Query 103's full-field export, which confirmed `frequency_completed = 100` directly from `customer_behavior_fields`.
- **Query 104** (high-return/low-frequency cluster): WHY block claimed a "20-60%" return-rate range for the cluster; actual range (given the query's own `> 30` filter) was 30.8-80.0%. The referenced "moderate 0.41" full-population correlation figure has not been traced to its source query or independently verified within this retrofit. Separately, this pass retrofitted Query 104 with a full verified write-up — which directly contradicts Open Items' prior characterization of Query 104 as "explicitly deprioritized; not being actively pursued." Both claims are part of the historical record; see Open Items, below, for current status.
- **Query 105** (recency-monetary funnel, fixed buckets): Same `WHERE recency_days IS NOT NULL` no-op as Query 99 (total 5,875, not 5,852) — a confirmed recurring pattern across two queries, worth checking for elsewhere (see Open Items). Original RESULT text also omitted the single largest MAX value in the table (£580,987.04, in the 0-49 day bucket) from its outlier discussion.
- **Query 106** (recency-monetary funnel, quartile crosstab): Verified clean — all percentages and the 61-lapsed-whale figure confirmed exactly against the CSV. This query's embedded revision notice (citing Query 127's later supersession via the fixed dual-threshold definition, 58 customers) was preserved as-is, since it is part of the actual historical record rather than a forward citation introduced during this retrofit pass.

### Revisiting Query 101

Query 101's frequency-bucket breakdown (259 / 306 / 45 / 8, see above) was re-verified while extending this chapter's exhibit lineup to the Nov 2010 Cohort, well after the header-retrofit pass above had already touched these same two queries. Pulling `frequency_completed` fresh from `customer_behavior_fields` for all 618 Nov 2010 Cohort customers (Query 181, `nov_2010_cohort_frequency_buckets_3d.html`) reproduced three of the four buckets exactly (259 / 306 / 45), but the 16+ orders bucket returned **5**, not the originally reported **8** — a 3-customer, 615-vs-618 total discrepancy. The gap is not explained by the 3 cancellation-only cohort members held out of this pull (consistent with this project's Never Converted handling): those customers carry `NULL` `frequency_completed` and could never have qualified for a 16+ bucket regardless.

Two possible causes were checked. Field 2 (Frequency)'s two rebuilds (queries ~76–80, addressing administrative-code contamination and the 80,995-unit outlier) both predate Query 101, so Query 101 should already have been running against the corrected field — ruled out. The header-retrofit pass above did explicitly re-touch Queries 100–101, reporting "618 customers, 91.4% with ≤5 orders" — matching 565/618 (259 + 306) exactly — but confirmed only that aggregate figure, never the 6-15 or 16+ bucket counts specifically, where this discrepancy sits. So the retrofit did touch these queries, just at a coarser grain than the one now in question.

This is a genuine shortfall against the retrofit's own stated standard, not just an unlucky miss: that pass's method is to append "RESULT and CONFIRMED FINDING blocks after verification against actual pasted data — never assumed." Verifying only the derived 91.4% aggregate, while leaving the query's full four-bucket result unchecked against the actual pasted data, does not meet that bar — a summary statistic is not the same as the underlying result it was computed from. Worth flagging as a pattern to watch for elsewhere across the 1–104 retrofit generally: a query's RESULT block being "confirmed" at the level of one summary figure doesn't guarantee every value in that query's original output was actually checked.

**Cross-check supporting the corrected figure:** two of the five customers in the current 16+ bucket (16754: 29 orders, £54,692.82 net; 13564: 36 orders, £15,613.10 net) match `141_nov2010_cohort_high_spend_tail_list.csv` exactly, an independently-run pull — supporting the current 615-customer, 259/306/45/5 breakdown as accurate. Customer 16754 also independently matches Query 121's £54,692.82 finding from the funnel/lockstep verification pass, a third, fully independent corroboration.

**Adopted for production use:** 259 / 306 / 45 / 5 (615 categorized; 3 cancellation-only customers held out), used in `nov_2010_cohort_frequency_buckets_3d.html`. Correspondingly, the ≤5-orders share is 91.4% unchanged (565/618, since the correction sits entirely inside the two upper buckets), but the 6+-orders share revises from the original 8.6% to **8.1%** (50/618). Query 101's original 259/306/45/8 remains documented at its original location above as the original discovery figure but is superseded for production use, per this project's standing rule that queries carry their own revision notation rather than being silently corrected.

---

## Chapter Five: MRP/Inventory Signal Sprint

With Chapter Four's dashboard architecture proven, this chapter points the same method — SQL-confirmed findings driving purpose-built 3D drill-downs — at a second business function never part of the original plan: warehousing and purchasing. The MRP scope is deliberately bounded to what the dataset's 8 raw columns can support (no separate purchasing, warehousing, or supplier tables exist in UK Retail II); this is documented as a scope decision, not a limitation discovered too late.

**151** — Built `uk_retail.full_transactions` as the union of `clean_transactions` and `unattributed_transactions`, with `customer_id` dropped and a `had_customer_id` provenance flag added. Expected 1,256,734 rows (1,028,437 + 228,297); actual result **1,250,814** — a 5,920-row gap, investigated rather than assumed harmless.

**152** — Row-count reconciliation for the Query 151 gap. Independently confirmed `clean_transactions` = 1,022,517 and `unattributed_transactions` = 228,297 (sum = 1,250,814, matching Query 151 exactly), and concluded the gap traced to `clean_transactions`'s stale pre-amendment figure (1,028,437, from Query 38, before Queries 59 and 74 reduced it by 5,918 + 2 rows). **This conclusion was later found to be a false positive** — see the July 31, 2026 forensic-review revision appended to Query 152 itself: a matching sum does not prove a correct disjoint union, and it doesn't when one source table is a subset copy of the other rather than genuinely disjoint. `unattributed_transactions` is a copy of `clean_transactions`'s NULL-customer-ID rows (Query 96), not a split — meaning `clean_transactions` still contained every one of those 228,297 rows internally. Left standing per the append-only rule as a documented instance of an arithmetic check passing while the underlying data was still wrong.

**151b** — Row-level duplicate check on `full_transactions`, GROUP BY invoice/stock/date/quantity/`had_customer_id`. Confirmed the same physical transaction line present twice — once via `clean_transactions` (mislabeled `had_customer_id = TRUE`), once via `unattributed_transactions` (correctly `FALSE`).

**151c** — Full duplicate count: **228,297 affected rows, an exact match** to `unattributed_transactions`'s total. The bug was fully systematic, not partial — every unattributed row double-counted, none escaped it.

**151d** — Corrected rebuild, adding `WHERE customer_id IS NOT NULL` to the `clean_transactions` branch. Result: **1,022,517 rows**, exactly matching `clean_transactions` alone — confirming `unattributed_transactions` contributed zero net-new rows once the duplication was removed. This is now the authoritative `full_transactions`.

**153–158** — The six individual stock-side fields (recency, frequency, monetary, interval, demand breadth, return rate), each built and independently verified against the (at-the-time still buggy) `full_transactions`, mirroring Chapter Two's customer-side field-by-field discipline. Once the Query 151d fix was confirmed, each field was re-examined for exposure:

- **153 (recency, MAX-based)** and **154 (frequency, COUNT DISTINCT-based)**: reasoned duplicate-insensitive by construction, then independently confirmed via rerun-and-diff — zero differences across all rows in both.
- **156 (interval, built on DISTINCT stock_code/invoice_no pairs)**: same treatment, same result — confirmed unaffected via rerun.
- **157 (demand breadth)**: sources from `clean_transactions` directly, never touched `full_transactions` at all — safe by lineage, no rerun needed.
- **155 (monetary, SUM-based)**: confirmed genuinely affected — 4,184 of 4,721 SKUs (89%) had different `monetary_gross`/`monetary_net` values pre- vs. post-fix, all inflated in the buggy version. The Query 155 cross-verification against customer 12346's cancelled bulk order (stock code 23166, gap £77,479.64) held exactly regardless, since that transaction was attributed, not unattributed.
- **158 (return rate)**: a mixed case — `order_return_rate_pct` (COUNT DISTINCT) confirmed unaffected; `line_item_return_rate_pct` (raw COUNT(*)) confirmed affected, with 2,540 of 4,734 SKUs (54%) changing — mostly *upward* on correction, the opposite direction from Query 155, since the duplicated unattributed rows skewed toward completed rather than cancelled activity for most SKUs.

**159** — Assembled `stock_behavior_fields`. **The original SQL file for this query was overwritten and is unrecoverable.** The version now in use is a reconstruction built from the six confirmed field queries above, following Query 94's customer-side LEFT-JOIN-on-recency pattern. Run against the corrected `full_transactions`: **4,734 rows**, confirmed both by row count and by an independent pgAdmin schema check (12 columns, correct order). Query 160's spot-check (stock code 23166, full row) matched every expected corrected value exactly, reproduced on a second independent run — the join logic is sound.

**161** — Variant-vs-family grain decision: 4,734 variant-level SKUs vs. 3,957 family-level (16.4% consolidation). Decision: remain at variant grain, since a warehouse reorders specific SKUs, not abstract product families. Unaffected by the bug (touches only `stock_code`).

**162** — First-pass Overdue Restock signal: SKUs whose current dormancy (`recency_days`) is at least 3× their own historical restocking rhythm (`avg_interval_fractional_day`), restricted to `frequency_completed >= 5`. Top-30 by `overdue_multiple` reviewed as a sample. Confirmed via rerun: the SKU list and ranking were never at risk (built entirely on already-safe fields); only the displayed `monetary_net` context values needed refreshing, all correcting downward.

**163** — Dead Stock Candidates: `recency_days >= 377` (reusing the customer-side "most lapsed" threshold, Query 123) AND `frequency_completed <= 3`. Top-30 by recency then `monetary_net`. Confirmed via rerun: the 30-SKU membership was identical pre- and post-fix; only the tiebreak *order* within tied recency groups shifted (several SKUs' `monetary_net` corrected by exactly 50%, consistent with a single duplicated transaction each).

**164** — Full population stats for Query 163's threshold: **201 total candidates**, max 3 distinct customers (a structural artifact of the `frequency_completed <= 3` filter, not a genuine finding), £14,025.45 aggregate historical value. `COUNT(*)` and `MAX(distinct_customers)` confirmed safe (both built on already-unaffected fields); the aggregate confirmed via rerun at a corrected **£13,352.35**.

**165** — Seasonality safeguard: of the 201 dead-stock candidates, which have their entire order history clustered in a single month? **93 of 201 (46.3%)** cluster in November or December — confirmed via multi-order clustering far beyond chance (6 SKUs with all 3 orders in December, 23 with both of 2 orders in December). Revised recommendation: these 93 should be excluded from clearance and flagged for seasonal restocking instead; the remaining **108** (201 − 93) are genuine clearance candidates. Confirmed via rerun: identical 93-SKU set, zero drift — this query proved duplicate-insensitive (COUNT DISTINCT invoice_no), never actually at risk. One pre-existing, bug-unrelated correction surfaced during this review: the original write-up stated "only 3" SKUs fall in November while naming four (15002, 37477C, 90142B, 90142C) — the CSV confirms 4 is correct; "3" was a miscount.

**166–170** — A separate, unrelated side investigation opened during this same forensic-review pass: whether stock code `47503J` (a genuine product, per Query 20's original Chapter One finding) was still being incorrectly caught by Query 59's administrative-code exclusion, a regression flagged since the original project handoff and never resolved across three subsequent `clean_transactions` amendments. **166**'s original SQL was found truncated and non-functional, its own RESULT block correctly noting the query never executed — but a real CSV existed for it; reconstructed and confirmed via rerun (exact match). **167** confirmed `raw_transactions` uses identical column naming to `clean_transactions`, closing out 166's failure as a syntax error, not a schema mismatch. **168** (a genuine, working file, independently corroborating the 166 reconstruction) characterized the gap precisely: 80 rows under the clean `47503J` code, exactly 1 row (£16.13) under the trailing-space `'47503J '` variant, same product. **169** confirmed the trailing-space row is still absent from `clean_transactions` — the regression is real, small, and fully scoped. **170** independently confirmed the "moderate 0.41" correlation figure cited in Query 104's WHY block via PostgreSQL's `CORR()` (0.410 exactly), and surfaced a second, previously uncomputed figure (cancellation count vs. line-item return rate, 0.225). Neither 166–170 query touches `full_transactions`; entirely outside the double-counting bug's scope. **[REVISION, August 1, 2026]** The `47503J` fix was an open decision as of this section's original write-up; it has since been resolved — see Open Items: accepted as a documented, immaterial gap (£16.13 against a >£1M-revenue dataset), no fourth amendment planned.

**171** — Retested Query 162's 3× threshold at full population scale: **1,532 SKUs (32.4% of the catalog)** — too loose to function as a targeted signal, capturing routine order-timing variance rather than genuine anomalous dormancy. Confirmed via rerun: count unaffected (safe fields only); aggregate corrected to £2,889,383.43.

**172** — First combined three-category exhibit pull, using Query 162's loose 3× threshold. 1,733 rows (1,532 / 108 / 93) — explicitly marked not exhibit-ready pending Query 173's retightening. **Original SQL was an unexpanded placeholder with no recoverable original**; reconstructed from Query 171's WHERE logic plus Query 165's seasonal-CTE logic, and confirmed via rerun to reproduce the identical category breakdown.

**173** — Retightened Overdue Restock definition: raised the multiple from 3× to **8×**, and added a **£1,000 historical net-value floor**. Original run: **572 candidates**, £2,328,688.20 aggregate. **This is the one query in the entire chapter where the bug genuinely mattered**: unlike every other headline query, `monetary_net >= 1000` sits directly in the `WHERE` clause here, gating population membership rather than only appearing in a display or sort column. Rerun against the corrected `stock_behavior_fields` confirmed the risk was real: **572 → 513** (−59 SKUs, −10.3%), aggregate corrected to £1,973,816.36.

**174** — Final combined exhibit pull, using Query 173's retightened definition. **Independently reproduced 513/108/93 (714 rows total) via a completely different mechanic** (row-level category assignment via `CASE`, rather than a direct aggregate `COUNT`) — a second, fully independent confirmation of 513, with zero discrepancy against Query 173's result.

**175** — Dead Stock vs. Seasonal Dormant deep-dive dataset, introducing `avg_order_month` as a derived axis. **Confirmed finding:** clean spatial separation — Seasonal Dormant clusters 11.0–12.0, Dead Stock spreads 1.0–10.25, zero overlap. Population (108 + 93) confirmed unaffected by the bug; individual `monetary_net` values within it will need the same refresh as everywhere else once this exhibit is rebuilt.

**176** — Standalone Overdue Restock exhibit data, using `overdue_multiple` as an axis. Built on the same fields as Query 173 — population and axis values need rebuilding against the corrected 513-SKU population.

**177–179** — Tested whether the "wave/spray" visual shape from the Chapter Three customer-side cube and this sprint's Overdue Restock exhibit were the same underlying phenomenon or a coincidental shared artifact of `frequency_completed` being independently right-skewed on both sides. First attempt (177) had a customer-population-vs-filtered-stock-subset scope mismatch; corrected in 178, comparing both FULL populations: 2.08× right-skew (customer) vs. 2.36× (stock) — similar in magnitude. Query 179's follow-up histogram (10,573 rows: 5,852 customer + 4,721 stock) showed the two distributions are shaped differently despite the similar skew ratio — customer is spike-and-tail, stock is a broad hump. **Confirmed finding: the shapes are NOT the same phenomenon** — a clean example of the project's own lesson that a single summary statistic can confirm skew exists without confirming two distributions are shaped alike. This query is customer/stock frequency-based (`frequency_completed`), not monetary-based — unaffected by the bug.

**Exhibits built this chapter (all self-contained Plotly HTML):**
- `inventory_signal_3d.html` — three categories, recency/monetary/log-frequency axes. **Needs rebuild**: population and Overdue Restock values changed (773→714 rows, 572→513).
- `dead_stock_seasonal_deepdive_3d.html` — the two dead-stock-derived categories, recency/monetary/avg_order_month axes. **Needs rebuild**: population unchanged (108+93), but individual `monetary_net` values shifted, so plotted positions would be slightly off.
- `overdue_restock_standalone_3d.html` — standalone view, `overdue_multiple` as an axis. **Needs rebuild**: population changed 572→513, values changed.
- `frequency_distribution_comparison.html` — the Query 177–179 skew comparison. **Safe, no rebuild needed**: built entirely on `frequency_completed`, confirmed unaffected on both customer and stock sides.

**⚠️ [REVISION, July 31, 2026, superseding the entire chapter's prior figures]** This chapter was originally written as a reconstruction from prior session summaries, not a direct query-by-query transcription, and cited **572/93/108** as the headline trio. A forensic review pass applying the header-retrofit standard to this chapter (the same kind of audit already run once on queries 1–106) found a real bug in Query 151 — not a documentation gap — that had gone undetected through an earlier verification step (Query 152) which passed on aggregate arithmetic without catching a row-level duplication. The bug was traced, fixed, and its actual impact fully quantified query by query, confirmed via direct reruns rather than assumption. Outcome: **93 (Seasonal Dormant) and 108 (Dead Stock) were never actually at risk** — both are confirmed identical before and after the fix. **572 (Overdue Restock) was genuinely wrong — the corrected figure is 513**, confirmed independently twice (Query 173's direct count and Query 174's row-level category assignment, zero discrepancy between them).

**Corrected Chapter Five headline trio: 513 Overdue Restock / 93 Seasonal Dormant / 108 Dead Stock.** This supersedes 572/93/108 everywhere it was previously cited (README, storyboard, `chapter_four_calculated_fields.md`, and this document's own prior version).

**Chapter Five status: findings confirmed and re-verified; three exhibits and downstream documentation still need updating to match.** Tableau is live-connected to PostgreSQL — the corrected 513/93/108 will surface automatically on next query, no manual refresh needed. The Tableau calculated fields and worksheets built on top of these findings (Fields 8-15: Overdue Multiple, Inventory Signal Category, Total/Nov-Dec Orders per SKU, Is Seasonal Dormant, Exhibit URL routing) are documented in `docs/chapter_four_calculated_fields.md`, which still needs its own correction pass to replace 572 with 513.

### Open Items

Consolidated and current as of July 25, 2026 — carried forward from July 20's original list and the July 21 retrofit pass, deduplicated rather than repeated across multiple dated entries.

1. **Query 104 status contradiction, unresolved.** The original Open Items list (July 20) characterized Query 104 as "explicitly deprioritized; not being actively pursued." The July 21 header-retrofit pass shows Query 104 was in fact completed with a full verified write-up that same session. Both statements are part of the historical record; which one accurately reflects the intended status has not been reconciled, and no source has been identified to check it against. Left open rather than guessed at.
2. **Remaining SQL verification pass, queries 107 onward.** Not yet re-verified against pasted results. These already carry the post-105 header format, so this is a RESULT/CONFIRMED FINDING accuracy pass (same treatment as 105/106 above), not a header retrofit.
3. **Recurring `WHERE recency_days IS NOT NULL` no-op pattern** (confirmed twice: Queries 99 and 105). Flagged July 21 as worth a deliberate check across queries 107+ for the same mistaken exclusion claim; that check has not yet been carried out.
4. ~~**Query 59's "47503J " trailing-space false positive.**~~ **RESOLVED, decision confirmed August 1, 2026.** Fully characterized via Queries 166-170: a single genuine product row, £16.13, one invoice (2010-07-05), confirmed still absent from `clean_transactions`. **Decision: accepted as a documented, immaterial gap — no fourth `clean_transactions` amendment will be made.** £16.13 against a >£1M-revenue dataset does not meet the bar for a formal correction. This is a closed decision, not a deferred one: the row stays excluded from `clean_transactions`, its absence is fully documented here (Queries 166-170) rather than silently unexplained, and no further action is planned. If circumstances change (e.g., a stakeholder specifically needs full-precision `47503J` totals), this can be revisited, but the default going forward is "documented, accepted, closed."
5. ~~**Query 104's "moderate 0.41" correlation figure.**~~ — **RESOLVED, confirmed July 31, 2026.** Query 170 independently verified via PostgreSQL's `CORR()` aggregate: 0.410 exactly, matching the narrative citation. A second, previously uncomputed correlation (cancellation count vs. line-item return rate) also surfaced: 0.225.
6. ~~**Append-only notations still owed in the canonical `/sql/` files**~~ — **RESOLVED, confirmed July 27, 2026.** Both notations are physically present: `sql/096` carries a `[REVISION NOTICE — added per Query 97...]` block correcting 243,007 → 228,297, and `sql/102` carries a `[REVISION NOTICE — added per Query 103...]` block correcting ~120 orders/~£24 avg → 100 orders/£28.67 avg. Both cite the resolving query and preserve the original figures above, per standing rule. (Original item text, distinct from this narrative document, where the corrected figures are already reflected: Query 96's 243,007 → 228,297 correction (citing Query 97) and Query 102's ~120 orders/~£24 avg → 100 orders/£28.67 avg correction (citing Query 103) were drafted during the July 21 retrofit but, as of that session, not yet physically inserted into the individual query files themselves. Status since then not confirmed.)
7. **Business recommendations section.** Drafted conversationally in a prior session (one recommendation per confirmed finding) but not yet written into this log as a formal section. Originally held until the MRP/inventory sprint completed. **[REVISION, July 31, 2026]** That sprint is now Chapter Five, complete — the blocker is cleared. Still genuinely open; no longer blocked on anything else in the project.
8. **Never Converted exhibit gallery — final lineup.** A dedicated exhibit was built (four variants: isolated base, colored by first-transaction-date, colored by attempt count, colored by recency); still open is which subset makes the final gallery, and under what filenames (see "Building the Never Converted Exhibit," above, for the full context).
9. **Attempt-count tenure effect exhibit.** Query 135 confirmed a real, population-wide finding (attempt count is substantially tenure-driven) that doesn't yet have its own dedicated exhibit. Candidate for a Chapter Four view once the Never Converted lineup (item 8) is settled.
10. **Stakeholder-communication test for interactive exhibits.** This project has tested whether 3D rotation helps *find* things, but not yet whether it helps *communicate* confirmed findings to someone who doesn't read SQL (see the Query 136 methodology note, above). Candidate: hand a finished exhibit to someone outside the analysis and see whether they arrive at the correct finding.
12. **Current/Historical page structure.** Not yet built as of July 31, 2026 (confirmed). Tracked in `docs/chapter_four_calculated_fields.md`'s Status section as the one remaining "not yet built" item on the Tableau side.
13. **Nov 2010 Cohort worksheets (Fields 16-22) — per-field verification write-up owed.** Confirmed built July 31, 2026, but `docs/chapter_four_calculated_fields.md` doesn't yet have the field-by-field WHAT/WHY/Formula/Verification/Result detail that every other field in that document carries. Not a finding-accuracy concern — a documentation-completeness gap.
14. **Chapter Five exhibit rebuilds, confirmed July 31, 2026.** Three of four Chapter Five exhibits need rebuilding against the corrected `stock_behavior_fields`: `overdue_restock_standalone_3d.html`, `inventory_signal_3d.html`, `dead_stock_seasonal_deepdive_3d.html`. `frequency_distribution_comparison.html` is confirmed unaffected, no rebuild needed. Not yet started.
15. **Downstream documentation correction, confirmed July 31, 2026.** README.md, the current storyboard_spine, and `chapter_four_calculated_fields.md` all still cite the superseded 572 figure and need updating to 513 (93 and 108 were unaffected, no change needed there).
11. ~~**Chapter Four Tableau dashboard build.**~~ — **RESOLVED, confirmed July 30, 2026.** Chapter Four is complete; see roadmap entry above and `docs/chapter_four_calculated_fields.md` for full build detail. (Original item text: "The active sprint deliverable, target July 26, 2026. Substantial progress since this item was first logged (July 21) is tracked in `docs/chapter_four_calculated_fields.md` rather than duplicated here.")

**Resolved:**
- **Project close date and timeline extension** — **RESOLVED, confirmed July 30, 2026.** All five chapters confirmed complete. Actual project window: July 6 – July 30, 2026 (24 days against the original 20-day/July 26 target). The 4-day extension was a technical constraint, not a scope or rigor gap: the project's volume of data-intensive 3D chart rendering (31+ standalone Plotly HTML exhibits, several rebuilt multiple times during the visual-standardization pass) repeatedly exhausted available context/token budget mid-session, requiring the remaining work to be split across more sessions than the original plan allowed for. No finding, verification step, or standing rule was affected — only the calendar.
- ~~Gut-check exhibit gallery entry~~ — **RESOLVED.** `gutcheck_105_121_funnel_lockstep_review.html` (expanded from the original 105-119 range to include the veer-off closure and the 350-399 day spike resolution) is confirmed placed in `3dplots/` and linked from `index.html`, alongside caveat notations on the two Chapter Three exhibit descriptions it revises.
- ~~Header-format retrofit, queries 1–106~~ — **RESOLVED**, per "Header-Format Retrofit and Verification Pass," above. Queries 107+ remain open as item 2, above.
- ~~Append-only notations owed in `sql/096` and `sql/102`~~ — **RESOLVED, confirmed July 27, 2026.** See item 6, above, for detail.
- ~~91.5%→91.4% correction, canonical log~~ — **RESOLVED.** The "Revisiting Query 101" section, above, already documents the corrected 91.4% (565/618) figure and the revised 259/306/45/5 bucket breakdown in full, with the "Adopted for production use" line closing it out. Confirmed landed July 27, 2026; no further action needed. (The exhibit caption in `nov_2010_cohort_frequency_buckets_3d.html` was already consistent with this.)
- ~~Lapsed Whale beat placement, storyboard~~ — **RESOLVED, confirmed July 29, 2026.** During the storyboard build, the "Lapsed Whale" finding (queries 105/106/109/111/113/115/122/125/126/129, `lapsed_whale_isolated_3d.html`) was placed on Story page 6 — "Chapter Three: Customer RFM in 3D" — not page 9 (Nov 2010 Cohort). The placement was settled correctly in the storyboard copy at build time; this entry is the missing formal log confirmation that the decision is closed, since it was never explicitly noted here when it happened.
- ~~`uk_retail_rfm_3d_log.html` orphaned status~~ — **RESOLVED, confirmed July 29, 2026.** This exhibit is orphaned from the Tableau workbook's Frequency Spike Tier field — the branching IF/THEN previously routing to it (as the ELSE-branch target) was replaced with a constant string pointing to the rebuilt `frequency_spike_tier_isolated_3d.html`. Orphaned status is intentional, not a defect: `uk_retail_rfm_3d_log.html` was the project's first attempt at this data (full population, log-scaled), and it remains in the `3dplots/` gallery deliberately, as process documentation showing the evolution from that first attempt to the current exhibit's greater granularity and interactivity. No further action needed; nothing to fix.

---

**Document version:** v58 — *In progress; this document is actively updated as the investigation continues. Version number increments with each substantive revision. (v53: added Chapter Five — MRP/Inventory Signal Sprint — reconstructed from prior session records; see provenance note at the top of that section. v54: Chapter Four roadmap status corrected from "in progress" to "complete" per Ree's July 30, 2026 confirmation. v55: actual project close date and 4-day timeline extension documented — cause: repeated context/token exhaustion from data-intensive 3D chart rendering volume. v56: confirmed July 31, 2026 — Current/Historical page structure and business-recommendations write-up still open; Nov 2010 Cohort Tableau worksheets confirmed built, per-field verification write-up still owed. v57: Chapter Five fully rewritten as a genuine query-by-query transcription/verification, July 31, 2026 — the reconstruction's provenance caveat is retired. Found and fixed a real bug in full_transactions (systematic double-counting of all 228,297 unattributed transactions), traced through Queries 151b/151c/151d. Every downstream query in the chapter's blast radius individually checked: 93 and 108 confirmed unaffected; 572 confirmed wrong, corrected to 513, independently verified twice. Also resolved the standing 47503J gap (166-170) and the Query 104 correlation citation (170) during the same pass. v58: the 47503J decision itself finalized, August 1, 2026 — accepted as a documented, immaterial gap; no fourth clean_transactions amendment planned.)*

*This document is updated as each new phase of investigation is completed. Individual query documentation lives in `/sql/`; this file is the narrative connecting them.*
