# Current Projects
**Cherrie Cosby**  
[linkedin.com/in/cherriecosby](https://linkedin.com/in/cherriecosby) | cherriecosby@gmail.com

---

Active learning and development work. Updated regularly — commit history reflects ongoing progress.

---

## In Progress

---

### Cyclistic Bike-Share — Phase 2 Geospatial Pipeline
**Tools:** ClickHouse · SQL · Tableau  
**Status:** In development  
**Related:** [Cyclistic Phase 1](https://github.com/CosbyCD/Data-Analytics-Portfolio/tree/main/Cyclistic)

Phase 1 of the Cyclistic analysis — published on RPubs — surfaced geospatial questions that R alone could not resolve. The introduction of third party temporal data — holidays and weather patterns — revealed patterns at the intersection of time, geography, and rider behavior that demand a different infrastructure to answer visually.

PostgreSQL served Phase 1 well for the core analysis. Phase 2 requires a columnar engine built for analytical speed at scale across millions of records with coordinate data. ClickHouse was selected for its MergeTree storage engine, sparse indexing, and compression capabilities — enabling the high-volume time-series and geospatial queries that will power the Tableau animated visualization.

**Pipeline:** Kaggle → ClickHouse → Tableau  
**Deliverable:** Animated geospatial visualization of rider behavior and temporal patterns across time and geography

---

### COVID-19 Containment Measures — Phase 2 Geospatial Pipeline
**Tools:** ClickHouse · SQL · Tableau  
**Status:** Queued — follows Cyclistic Phase 2  
**Related:** [COVID-19 Phase 1](https://github.com/CosbyCD/Data-Analytics-Portfolio/tree/main/COVID-19)

Phase 1 analyzed global vs. U.S. infection data in Python. Phase 2 builds a ClickHouse pipeline to power a Tableau animated geospatial visualization — mapping infection wave patterns across countries over time with full temporal animation.

**Pipeline:** Kaggle → ClickHouse → Tableau  
**Deliverable:** Animated world map of COVID-19 infection wave patterns over time

---

### Supply Chain & Logistics Analysis
**Tools:** ClickHouse · SQL · Tableau  
**Status:** Queued — follows COVID-19 Phase 2

Two-project analytical series using supply chain and logistics data:

**Project 1 — Supply Chain Performance Analysis**  
Operational efficiency patterns across lead times, fulfillment rates, and vendor performance.

**Project 2 — Supply Chain Fraud Detection**  
Anomaly detection across transactions — identifying irregularities in vendor behavior, order patterns, and fulfillment data.

Both projects are directly relevant to target industries including distribution, healthcare supply chain, and enterprise data operations.

**Pipeline:** Kaggle → ClickHouse → Tableau

---

## Completed Projects

See [Data Analytics Portfolio](https://github.com/CosbyCD/Data-Analytics-Portfolio) for completed work.

---

*The industries and tools change. The discipline doesn't. Documentation makes the difference. ~ Polymath*
