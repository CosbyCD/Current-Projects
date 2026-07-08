# UK Online Retail II — Investigation Log

**Purpose:** This document tracks the meta-narrative of this investigation — the order things were looked at, what was found, and what each finding inspired next. Individual `.sql` files in `/sql/` document *what* each query does and *why* it was run in isolation. This document connects them into a single readable story: the chain of custody for the reasoning itself, not just the data.

---

## Introduction — Why This Project Exists

This project is built around a question, not just a dataset: **if you take data seriously enough to examine it from every angle, does turning it — literally, spatially, in three dimensions — reveal something a flat table or a standard 2D chart cannot?**

Standard analysis, including everything I've built up to this point, is fundamentally two-dimensional: a bar chart, a scatter plot, a dashboard tile. Even when a report has many charts, each one is still a flat plane — X against Y, one relationship at a time. That approach has real limits. In a 2D scatter plot, one data point can sit directly behind another and effectively disappear — occluded, invisible, even though it's right there in the data. What's hidden isn't actionable.

The idea driving this project is closer to how I actually picture data in my head: not as a table, but as a cube, where every data point occupies real space, positioned by its own values, and where rotating that cube changes which two dimensions you're looking at head-on. A relationship invisible from one angle — because a third variable is collapsed out of view — can snap into focus the moment you turn the structure and look at it from another plane entirely.

This isn't a new interest. I built my first dimensional workbook in 1995, at Minh Foods, structuring national institutional sales data in an OLAP-style layout years before drag-and-drop dashboards existed as a category — because a flat spreadsheet couldn't hold the relationships I needed to see at once. The instinct to think in dimensions rather than rows and columns has been consistent since then. What's changed isn't the instinct — it's that the tools have finally caught up to it. What used to require custom-built structures and nested macros can now be prompted into an interactive, rotatable, browser-based visualization directly. This project is a test of whether that gap has genuinely closed.

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

## Phase 6 — Open Threads (in progress)

Identified but not yet resolved, in priority order:

1. **The remaining 1,693 blank-description rows** — don't fit the negative-qty/no-customer/zero-price pattern from Phase 3. Unknown characteristics; highest priority since it's a direct gap in the completeness audit.
2. **Exact duplicate rows** — noticed while reviewing query 06's output that several invoices (`536525`, `537405`, `537434`) appeared as fully identical duplicate lines. Not yet checked dataset-wide. Could inflate quantity/monetary totals if present broadly.
3. **Non-numeric stock codes** (POST, DOT, C2, BANK CHARGES, AMAZONFEE, etc.) — identified via early research (before SQL investigation began) as non-product administrative rows. Never yet queried against this dataset directly.
4. **Zero or unusually low unit_price rows, broadly** — the known pattern covers zero-price rows tied to the negative-qty/blank-description group specifically. Not yet checked as a general category across the whole dataset.
5. **Country field placeholder values** — not yet checked for "Unspecified" or similar non-country entries.

---

*This document is updated as each new phase of investigation is completed. Individual query documentation lives in `/sql/`; this file is the narrative connecting them.*

