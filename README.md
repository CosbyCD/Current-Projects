# Current Projects
Cherrie Cosby [linkedin.com/in/cherriecosby](https://linkedin.com/in/cherriecosby) | [cherriecosby@gmail.com](mailto:cherriecosby@gmail.com)

Active learning and development work. Updated regularly — commit history reflects ongoing progress.

## In Progress

## UK Online Retail II — Extraction Methodology & Data Forensics

**Status:** Active | **Tools:** PostgreSQL · SQL · Nodal Display (in progress)

This project applies a forensic approach to data analysis: Something is present in the raw data, and the work is to extract it, then examine it from every angle to understand what it's actually saying. Using the UK Online Retail II dataset — an unremarkable, heavily-studied dataset, chosen deliberately — six customer behavior fields (recency, frequency, monetary value, order-to-order interval, product diversity, and return rate) are derived entirely from the 8 raw columns already present in the source data. No external data is introduced.
Every derived field and every data quality finding in this repository was validated in SQL before being accepted — this is not a drag-and-drop analysis. The SQL log documents that validation process query by query, including several data quality findings surfaced through direct inspection: an undocumented empty-CustomerID pattern (22.8% of transactions), inconsistent casing on variant stock codes, and a category of negative-quantity transactions that falls outside the dataset's documented cancellation flag entirely.
The final phase of this project tests a new capability: whether an interactive, rotatable nodal visualization of the six derived fields reveals customer behavior patterns that a standard flat chart would miss.

### Supply Chain & Logistics Analysis
Tools: ClickHouse · SQL · Tableau | Status: Queued — follows COVID-19 Phase 2

Two-project analytical series using supply chain and logistics data:

**Project 1 — Supply Chain Performance Analysis**
Operational efficiency patterns across lead times, fulfillment rates, and vendor performance.

**Project 2 — Supply Chain Fraud Detection**
Anomaly detection across transactions — identifying irregularities in vendor behavior, order patterns, and fulfillment data.

Both projects are directly relevant to target industries including distribution, healthcare supply chain, and enterprise data operations.

Pipeline: Kaggle → ClickHouse → Tableau

---

## Completed Projects
See [Data Analytics Portfolio](https://github.com/CosbyCD/Data-Analytics-Portfolio) for completed work.

---

*The industries and tools change. The discipline doesn't. Documentation makes the difference. ~ Polymath*
