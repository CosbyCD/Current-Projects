# UK Online Retail II — Investigation Log

**Short on time? Prefer to see it rather than read it? [Jump to the results →](#chapter-three--3d-visualization)** *(interactive visualization link coming soon — this currently jumps to the start of Chapter Three)*

**Purpose:** This document tracks the meta-narrative of this investigation — the order things were looked at, what was found, and what each finding inspired next. Individual `.sql` files in `/sql/` document *what* each query does and *why* it was run in isolation. This document connects them into a single readable story: the chain of custody for the reasoning itself, not just the data.

---

## Introduction — Why This Project Exists

This project is built around a question, not just a dataset: **if you take data seriously enough to examine it from every angle, does turning it — literally, spatially, in three dimensions — reveal something a flat table or a standard 2D chart cannot?** Standard analysis, including everything I've built up to this point, is fundamentally two-dimensional — a bar chart, a scatter plot, one relationship at a time. That has a real limit: in a 2D scatter plot, one data point can sit directly behind another and effectively disappear. The idea driving this project is closer to how I actually picture data in my head — not as a table, but as a cube, where every point occupies real space and rotating the structure changes which two dimensions are facing you. A relationship invisible from one angle can snap into focus the moment you turn and look from another. Rotation is the core mechanic tested here, but it isn't the only interactive tool this project puts to work — hover detail and, eventually, click-through drill-down get tested too, each asked to earn its place on its own merits rather than assumed useful because it's new.

This isn't a new interest, and it isn't a new idea in the abstract either. Commercial platforms (Virtualitics, FineVis, and others) already sell 3D visualization tools built for exactly this kind of exploration. What's different about this project is the approach: building the capability directly, from raw derived data, using AI-assisted development as the bridge between having an idea and having a working tool — without a dedicated platform, a data visualization team, or a purchased license. An individual analyst, prompting their way to a capability that used to require real programming investment, and testing it rigorously rather than just demonstrating it — that's the actual experiment.

In the 1980s, I took criminal justice coursework with an eye toward law enforcement. I didn't stay in that field, but the core discipline never left: chain of custody, documentation precise enough that someone else could follow the exact same path and arrive at the same conclusion, and reporting what the evidence actually says regardless of whether the answer is convenient. That governs this project as a standing rule, stated plainly: **verify before trusting.** Every number gets checked before it's accepted, every assumption gets tested before it's built on, and every finding in this log — including the ones that complicated the analysis rather than simplifying it — follows that rule without exception.

That discipline found its way into how I think about data structure a few years later, and it started earlier than most of my career did. I'd spent several years working in Lotus 1-2-3 before most offices switched to Excel, and I'd already lived through what happens when a formula gets deleted or overwritten by accident — I knew the failure mode firsthand before I ever had to protect someone else from it. Most of the offices I contracted with at the time were just getting computers at all, and the people expected to build and maintain these spreadsheets were often secretaries, not accountants, with no formal training in the tool and no background in why a formula worked the way it did. In 1995, at Minh Foods, I built my first dimensional workbook — structuring national institutional sales data into an OLAP-style layout years before drag-and-drop dashboards existed as a category, because a flat spreadsheet couldn't hold the relationships that I needed to see all at once. It was built around four salespeople, each covering their own region, and the reality on the ground never held still: institutions changed, products changed, sometimes part of one agent's territory got reassigned to another. Every one of those changes meant the underlying formulas had to be understood well enough to adjust correctly, not just left alone because nobody dared touch them. Locking a cell wasn't enough — even a locked sheet doesn't teach the next person what's safe to change on purpose. This was the 1990s: no video calls, no easy way to bridge Houston and Minnesota beyond a phone line, and I already knew what everyone eventually learns about instructions taken down by ear — something always gets lost, and you don't realize it until you go back and can't find what you thought you'd written down. So I started sending a second file alongside the working one: every formula stripped down and printed out, no data, just the logic laid bare. Then I went further and wrote out what each part did and how the numbers were actually derived — because the people using this on the other end weren't going to keep working from my spreadsheet forever. Once their own system was set up, they were going to migrate what I'd built into it, which meant they needed to understand the logic well enough to reconstruct it somewhere else entirely, not just keep a working sheet running until it broke. The instinct to think in dimensions, and to document for the person who wasn't in the room and still has to keep the thing running after you're gone, has been consistent since then. What's changed isn't the instinct — it's that the tools have finally caught up to it. A printed formula sheet then, a WHAT/WHY comment block on every query now.

The UK Online Retail II dataset was chosen deliberately *because* it's unremarkable — a plain, heavily-studied dataset, chosen specifically so that if the 3D rotation approach does surface something meaningful, the finding is credible precisely because it came from ordinary data, not one engineered to make the method look good. The six customer behavior fields being derived in this project — extracted entirely from the 8 raw columns already present, no external enrichment — are the eventual inputs to that 3D structure. Everything documented below exists to make sure that when those fields do get placed into a rotatable structure, whatever the rotation reveals is trustworthy. A finding built on unvalidated data isn't a finding; it's noise wearing a nicer visualization.

There's a broader question behind this specific project too: the volume of data being collected across every industry right now is growing faster than the tools and habits most organizations use to actually explore it. This project is a small, deliberately rigorous test of one alternative — whether AI-assisted development has put a genuinely new exploratory capability within reach of an individual analyst, and whether that capability earns a place in the analytical toolkit or turns out to be a novelty that adds nothing. I don't know the answer yet. That's the point of testing it.

One more thing worth stating plainly, since it's easy to misread a fast timeline as a rushed one: **I didn't just use AI to go faster. I used it to run more verification passes than I'd have had time for solo, so the speed and the rigor came from the same decision, not opposite ends of a tradeoff.** The tool-chaining across this project is deliberate and cross-checked at every handoff, not just AI-assisted SQL: SQL validates what the AI-assisted 3D visualization surfaces, a web search checks whether the resulting architecture has prior art before it gets called novel, Tableau is the intended production layer while Plotly stays the prototyping layer, and analytical choices (like a rolling-average smoothing pass, built before anyone asked for it) anticipate the stakeholder question rather than react to it live. Every discrepancy this project has surfaced — a mismatched customer count, a candidate finding that didn't hold up under a SQL check — is documented in the chapter it occurred in, not quietly smoothed over. That paper trail is the actual proof of the claim: not that the work went fast, but that it went fast *and* stayed defensible, because neither one was sacrificed for the other.

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
- **Recency–monetary funnel:** no customer with recency past ~300-400 days ever reaches high monetary value. High spend and recent activity travel together; there is no population of "lapsed whales."
- **Frequency–monetary lockstep:** rotating toward the frequency axis showed the same pattern — high frequency is almost entirely confined to low recency. Three variables telling one story rather than three independent stories; worth stating directly as a finding rather than treating all three as equally independent signals for this dataset.
- **Veer-off observation:** at certain rotation angles, clusters that appear unified from one view visibly split into separate groups when rotated — points that read as one cluster from a flat projection resolve into distinct behavioral groups from another angle. *Attribution note: this observation was made by direct, first-person visual inspection while manually rotating the rendered chart. Claude does not have the ability to see rendered visual output and did not independently verify this observation — it is documented here as my direct observation, not a joint finding.*
- A second chart variant (Option 2: customers sorted by monetary_gross ascending along X, frequency and recency plotted as a connected line rather than independent points) confirmed the frequency-monetary lockstep from a different angle: frequency stays low and flat across most of the monetary-sorted range, then spikes sharply only in the top ~15-20% of customers by spend.

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

**Result: 259 / 306 / 45 / 8** across the four buckets (sums to 618). 91.5% of the cohort placed 5 or fewer orders total, with 259 being pure one-time buyers. Only 8.6% ever reached 6+ orders — the range where "established regular who churned" would be a more credible read than "seasonal one-off." **This is a low-frequency, seasonal-acquisition cohort, not a group of lost regular customers** — a meaningfully different story for a stakeholder-facing write-up than "we lost loyal customers."

**Methodological note preserved from this investigation:** the first draft of query 101 filtered on `last_invoice_date` directly (Oct 1 - Dec 31, 2010) rather than on the existing `recency_days` column, and returned 700 customers instead of 618 — a second, independent derivation of what should have been the same cohort, introduced by mistake. The fix was not to reconcile the two counts but to recognize the second definition as an error and drop it in favor of the single existing source-of-truth column (`recency_days`, already established and verified in query 100). Standing rule for the remainder of this project: when two independently-derived queries disagree on what should be the same group, the fix is to find and remove the accidental second definition, not to average or reconcile the two.

**Finding, confirmed and closed:** the 350-424 day recency bump is a real, distinct cohort — 618 customers whose last purchase clustered in the November 2010 pre-Christmas stocking window, predominantly low-frequency/one-time buyers who did not convert to repeat behavior. Flagged as a candidate Tableau calculated-field bucket for Chapter Four, alongside the 23 never-converted customers from query 98.

### Investigating Customer 17961

Surfaced via hover tooltip while rotating the RFM chart: rank 4673 by monetary_gross (£2,866.74), ~120 completed orders, 20-day recency — but an average order value of ~£24, anomalously low relative to peers at the same monetary rank.

**102** — `102_customer_17961_order_history.sql`. Pulled full order-level detail (invoice_no, invoice_date, stock_code, description, quantity, unit_price, line_total) for customer 17961 across the full dataset date range, to determine whether the low average order value reflects habitual small-basket buying, a wholesale/reseller pattern, or a data quality issue.

**Result: neither a data quality issue nor classic bulk-reseller behavior.** The order history (Dec 2009 through Nov 2011, ~50+ separate orders) shows a customer placing frequent small-basket orders — many line items at £1-£10 each — almost continuously across nearly two full years, with two standout large multi-item orders landing in late December of consecutive years (Dec 4, 2009 and Dec 21, 2010), each a large haul of exactly the small trinkets, candles, and stocking-filler items this retailer sells. Two trivial cancellations appear in the record and do not materially affect the pattern. **Interpretation: a small shop or market-stall reseller who restocks in modest increments most of the year, then places one larger order ahead of Christmas each year to build holiday inventory** — a different flavor of "small retailer, seasonal peak" than the 618-customer bump cohort above, but a thematically consistent echo of it: both findings point toward the same underlying customer base of small gift/wholesale shops stocking for Christmas, surfaced through two different investigative paths.

Per this chapter's method-honesty standard: this finding closes out the case noted above — the 3D chart found 17961 by a slower, less direct path than a simple ratio query would have, but the chart-to-SQL-confirmation workflow is what turned an isolated visual anomaly into a defensible, documented finding.

### Rolling-Average Confirmation of the Frequency-Monetary Lockstep

Option 2's connected-line trace (customers sorted by monetary_gross ascending, frequency and recency plotted as a line) confirmed the lockstep finding, but the raw line was visibly noisy at full scale (5,852 points) compared to the smoother 958-point sample built earlier in this sprint. Anticipating that a stakeholder presentation would draw the same "is this just noise?" question, a rolling-average version was built as the answer to have already prepared, rather than worked out live: mean `frequency_completed` and `recency_days` per 200-customer rolling window along the monetary-sorted axis, with the raw noisy points retained underneath at low opacity so the smoothing is visible as a transformation of real data, not a hidden step.

**Result: the rolling average confirms the raw-line pattern exactly.** Frequency stays low and flat for roughly 80% of customers, then rises sharply in the top 15-20% by spend; recency declines the same way across the same range. No new pattern was introduced by smoothing — the noisy version and the smoothed version tell the same story, which is itself the finding: this isn't an artifact of overplotting, it's a real, stable relationship visible at any level of aggregation.

**Chapter Three status: core findings confirmed, write-up not yet drafted. Closed July 16, 2026 — 10 days after the July 6 project start.** Confirmed findings ready for narrative and business-recommendation drafting: the recency-monetary funnel, the frequency-monetary lockstep (confirmed twice, by raw line and rolling average), the 618-customer November 2010 stocking cohort, and the customer 17961 seasonal-reseller pattern. The veer-off observation stands as a qualitative, first-person finding per the attribution note above. Chapter Four (Tableau + bucketed drill-down architecture, wiring confirmed buckets to purpose-built Plotly deep-dives via URL actions) has one week allotted, with the entire project — Chapter Four included — targeted for full completion by July 26, twenty days after the project's July 6 start.

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

**Document version:** v36 — *In progress; this document is actively updated as the investigation continues. Version number increments with each substantive revision.*

*This document is updated as each new phase of investigation is completed. Individual query documentation lives in `/sql/`; this file is the narrative connecting them.*
