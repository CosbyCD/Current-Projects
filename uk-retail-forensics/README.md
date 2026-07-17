# UK Online Retail II — A Forensics Approach to Customer Behavior Analysis

A self-directed, end-to-end analysis of 1,067,371 UK e-commerce transactions (Dec 2009 – Dec 2011), built as a forensic "chain of custody" investigation rather than a standard cleaning-and-charting exercise. Every cleaning decision, every derived field, and every visual finding is documented and independently verified before being called a result.

**Project window:** July 6 – July 26, 2026 (20 days, four chapters)

## The question this project tests

Does a fully rotatable, interactive 3D visualization surface relationships in customer data that a flat table or standard 2D chart cannot — and where does it fall short?

## Explore it

- **[Investigation log](docs/investigation_log.md)** — the full narrative: every cleaning decision, every derived field, every finding, with the reasoning behind each one
- **[3D exhibit gallery](https://cosbycd.github.io/Current-Projects/uk-retail-forensics/3dplots/)** — rotatable, interactive charts, live in the browser
- **[SQL queries](sql/)** — 100+ numbered queries, each with a WHAT/WHY comment block explaining the reasoning, not just the code
- **[Query outputs](output/)** — the raw results behind every query

## Structure

**Chapter One — Investigation & cleaning.** 1,067,371 raw rows down to a verified `clean_transactions` table: duplicates, administrative codes, casing inconsistencies, and one confirmed data-entry error, each traced and documented rather than silently dropped.

**Chapter Two — Deriving six customer behavior fields.** Recency, frequency, monetary value, order-to-order interval, product diversity, and return rate — extracted from data already present in the raw columns, not sourced externally.

**Chapter Three — 3D visualization.** A rotatable, interactive customer-behavior cube, tested against real findings and checked line-by-line against SQL. Four confirmed findings: a recency-monetary funnel, a frequency-monetary lockstep, a 618-customer seasonal stocking cohort, and one resolved customer-level anomaly.

**Chapter Four — Tableau + drill-down architecture** *(in progress).* A production dashboard layer with bucketed, hypothesis-driven drill-downs from 2D KPIs into purpose-built 3D deep-dives.

## Standing project rules

A few habits carried through the whole investigation, documented in full in the log:

- Nothing gets deleted — inconvenient or anomalous data is segregated and preserved, never dropped silently
- When a genuine methodological fork comes up, both versions get built and compared, not just the first one that works
- When two independently-derived queries disagree on what should be the same result, the fix is to find the accidental second definition and remove it — not to average or reconcile the discrepancy
- Nothing gets called a finding on the strength of a chart alone — every visual pattern gets a SQL or statistical check before it's written up

## About

Built by [Cherrie Cosby](https://cyberphase.consulting) as a demonstration of applied data analysis rigor — AI-assisted tool-chaining used to run more verification passes than would be possible solo, not to skip them.
