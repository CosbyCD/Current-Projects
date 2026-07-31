# UK Online Retail II — A Forensics Approach to Customer Behavior Analysis

*Want the full investigation instead of the summary? [Start here →](docs/investigation_log.md)*

A self-directed forensic analysis of 1,067,371 UK e-commerce transactions (Dec 2009 – Dec 2011), testing one question: **does a fully rotatable 3D visualization surface customer patterns that a flat chart hides?** Built end-to-end — cleaning, six derived behavioral fields, an interactive 3D exhibit gallery, and a Tableau dashboard — with every finding checked against SQL before it's trusted, and every mistake documented rather than quietly fixed.

**Project window:** July 6 – July 31, 2026 (25 days, five chapters — originally scoped at 20 days/four chapters; the extra time went to re-rendering the project's volume of data-intensive 3D exhibits across multiple sessions)

## The headline findings

- **Recency-monetary funnel, confirmed and refined.** Average spend does decline steadily the longer a customer's been dormant — but a real population of 58 high-value customers breaks that pattern entirely. [See it in 3D →](https://cosbycd.github.io/Current-Projects/uk-retail-forensics/3dplots/lapsed_whale_isolated_3d.html)
- **A seasonal cohort, hiding in a "gap."** What first looked like a data anomaly in the recency distribution turned out to be 618 real customers stocking up ahead of Christmas 2010 — a genuine acquisition wave, not noise.
- **Gross revenue lies about individual customers.** At least 7 customers looked like major spenders using standard revenue figures — until their cancelled orders were factored in. One customer's apparent £77,000 in spend was really £169. This changed which spend metric the entire dashboard is built on.
- **The frequency spike is real, but narrower than it first looked.** Chart rotation suggested high-frequency buying concentrated in the "top 15-20%" of spenders. SQL confirmed it's actually the top 10% specifically — a meaningfully different targeting boundary.

## The part most portfolios don't show you

Midway through building the Tableau dashboard, a population count came back **58 instead of the expected 59** — a one-customer gap. Rather than shrug it off, that gap got traced all the way down to a real bug in PostgreSQL's `NTILE` function (non-deterministic tie-breaking with no secondary sort key), fixed, and documented with the exact customer who exposed it. Nothing was rerun quietly to make the discrepancy disappear — the original numbers stay in the record, with a note explaining exactly what changed and why. [Full account →](docs/investigation_log.md#discovering-ntile-non-determinism--queries-122-128)

**A second one: this project ran one investigation thread backwards on purpose, to test itself.** The never-converted customer analysis (queries 131-135) was worked visual-first — rotate the 3D exhibit, spot a candidate shape, confirm or kill it in SQL — instead of the efficient SQL-first order everything else in this project follows. That's not a workflow mistake; it's the actual experiment this project set out to run: does 3D rotation earn a place in the analytical toolkit, or not? Result: rotation reliably flagged two real findings (a launch-window abandonment cohort; a tenure effect where attempt count tracks how long a customer has been in the dataset) that SQL then confirmed — but it also introduced its own failure modes a SQL-first pass never would have hit, including a badly biased population sample that got caught, labeled, and superseded rather than quietly fixed. It's a fair trade to name plainly: visuals are a strong hypothesis-generation layer on top of disciplined SQL, not a replacement for it. [Full account →](docs/investigation_log.md#building-the-never-converted-exhibit--queries-131-135)

## Status

**All five chapters closed.** Data cleaned and reconciled; six customer behavioral fields derived and verified; Chapters One through Three's 3D exhibit gallery built. Chapter Four's Tableau dashboard is live, connected to PostgreSQL, with seven calculated fields (six behavioral tiers plus exhibit-URL routing) built and independently verified twice each, mark-click drill-downs wired from every dashboard chart to a dedicated 3D exhibit — including isolated-population exhibits for Lapsed Whale, Lapsed Typical, Recent, and the top-decile Frequency Spike tier.

Chapter Five extends the same method to warehousing and purchasing: `stock_behavior_fields` (4,734 SKUs) built and verified, with three headline inventory signals confirmed in SQL — 513 Overdue Restock candidates, 93 Seasonal Dormant SKUs, and 108 genuine Dead Stock candidates — each with its own Tableau worksheet and 3D exhibit routing. The full exhibit gallery (`3dplots/index.html`) links 31 interactive 3D visualizations across both chapters.

## Explore further

- **[Full investigation log](docs/investigation_log.md)** — every decision, every query, every correction, in order
- **[3D exhibit gallery](https://cosbycd.github.io/Current-Projects/uk-retail-forensics/3dplots/)** — rotate the charts yourself
- **[Chapter Four calculated fields](docs/chapter_four_calculated_fields.md)** — the dashboard logic, formula by formula
- **[SQL queries](sql/)** — every query numbered, each with what it does and why
- **[Query outputs](output/)** — the raw results behind every query

## Standing project rules

- Nothing gets deleted — inconvenient or anomalous data is segregated and preserved, never dropped silently
- When a genuine methodological fork comes up, both versions get built and compared, not just the first one that works
- When two independently-derived queries disagree on what should be the same result, the fix is to find the accidental second definition and remove it — not to average or reconcile the discrepancy
- Nothing gets called a finding on the strength of a chart alone — every visual pattern gets a SQL or statistical check before it's written up
- When a documented finding is later revised, the original entry stays and gets an appended notation — citing exactly what changed it, why, and the full corrected statement — never a silent edit

---

Built by [Cherrie Cosby](https://cyberphase.consulting) as a demonstration of applied data analysis rigor — AI-assisted tool-chaining used to run more verification passes than would be possible solo, not to skip them.
