# 29 — Quick Revision (30-45 minute pre-interview sheet)

> Yeh file **concise** hai jaan-boojh kar — agar kisी concept ka detail chahiye, us topic ke
> dedicated file ka link diya gaya hai. Goal: interview se 30-45 min pehले sirf yeh padhो.

---

## SQL Syntax Cheat-Sheet

```sql
SELECT col1, col2 FROM table WHERE condition;
SELECT DISTINCT col FROM table;
SELECT col, COUNT(*) FROM table GROUP BY col HAVING COUNT(*) > 5 ORDER BY col DESC LIMIT 10;
SELECT CASE WHEN x > 0 THEN 'pos' ELSE 'neg' END AS label FROM table;
SELECT a.x, b.y FROM a JOIN b ON a.id = b.id;          -- INNER JOIN
SELECT a.x, b.y FROM a LEFT JOIN b ON a.id = b.id;     -- LEFT JOIN
WITH cte AS (SELECT ... ) SELECT * FROM cte;
SELECT NTILE(4) OVER (ORDER BY col) FROM table;         -- window function
CREATE VIEW v AS SELECT ...;
strftime('%Y-%m', date_col)          -- SQLite: extract year-month
julianday(date2) - julianday(date1)  -- SQLite: date difference in days
```

## SQL Concepts (one-liners)

- **WHERE** = row filter, before GROUP BY. **HAVING** = group filter, after GROUP BY.
- **INNER JOIN** = only matches. **LEFT JOIN** = all left rows + matches (NULL if none).
- **Subquery/CTE** = multi-step query; CTE = readable named version.
- **Window function (NTILE)** = ranking/bucketing without squashing rows.
- Execution order: `FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT`.

## Pandas Functions (one-liners)

`pd.read_csv()` load · `.info()/.describe()` inspect · `.isnull().sum()` nulls ·
`.duplicated().sum()` exact dupes · `pd.to_datetime(errors="coerce")` date-fix ·
`.fillna()/.dropna(subset=)` missing-values · `.drop_duplicates(subset=,keep=)` logical dupes ·
`.merge(on=,how=)` = JOIN · `.groupby().agg()` = GROUP BY · `.value_counts()` distribution ·
`.astype(str).str.zfill(n)` ID-formatting.

## DA Definitions (one-liners)

- **Metric** = any measured number. **KPI** = a metric the business specifically tracks.
- **Dimension** = categorical grouping column. **Measure** = numeric aggregated column.
- **Grain** = what one row represents — check this before any AVG/COUNT.
- **Insight** = Observation + Evidence + Interpretation + Action (not just a chart).

## Important Formulas

$$\text{Revenue} = \sum(\text{price} + \text{freight\_value}) \quad \text{[delivered only]}$$
$$\text{AOV} = \frac{\text{Total Revenue}}{\text{Total Orders}} \quad \text{(order-level, NOT line-item AVG)}$$
$$\text{Repeat Rate} = \frac{\text{customers with} > 1 \text{ order}}{\text{total unique customers}} \times 100$$
$$\bar{x} = \frac{\sum x_i}{n} \qquad \sigma = \sqrt{\frac{\sum(x_i-\bar{x})^2}{n}}$$

## Business Metrics (definitions)

Revenue · Orders · AOV · Avg Spend/Customer · Repeat Purchase Rate · Customer Count · Avg
Review Score · Avg Delivery Days · On-Time Delivery % · Revenue Concentration % · RFM
(Recency/Frequency/Monetary). **NOT in this project:** Conversion Rate, Profit, CAC (no
traffic/cost data available).

## Power BI Concepts

- **Calculated Column** = row-level, stored. **Measure** = aggregate, on-the-fly.
- `CALCULATE(expr, filter)` = change filter-context. `DIVIDE(a,b)` = safe division (no crash).
- 1:1 relationship default = "Both" cross-filter. 1:many default = single direction.
- Fact tables = orders/items/payments/reviews. Dimension tables = customers/products/sellers.

## Statistics Formulas & Concepts

- Mean sensitive to outliers; Median robust.
- SD/Variance = spread around the mean.
- Percentile = % of data below a value. Quartile = 4 equal splits (Q1/Q2/Q3).
- **Correlation ≠ Causation** — always say "association," not "proven cause."

---

## Project Facts (memorize these numbers)

| Fact | Value |
|---|---|
| Total orders (raw) | 99,441 |
| Delivered orders | 96,478 (97.0%) |
| Unique customers (`customer_unique_id`) | 96,096 |
| Total Revenue (delivered) | R$ 15,419,773.75 |
| AOV | R$ 159.83 |
| Avg spend/customer | R$ 165.17 |
| Repeat purchase rate | 3.0% (2,801 customers) |
| Avg delivery time | ~12.6 days |
| On-time vs late rating | 4.29★ vs 2.57★ |
| Top revenue category | health_beauty (R$14.12L) |
| Top volume category | bed_bath_table (9,272 orders) |
| Worst-rated category | office_furniture (3.49★) |
| Top state by revenue | SP (37.42%) |
| RFM segments | High Value (141) · Loyal (87) · At Risk (22,690) · Recent (46,536) · Low Engagement (23,904) |
| Database | SQLite (`data/ecommerce.db`), 6 SQL files, 25+ queries |
| Dashboard | 3 pages, design-complete, `.pbix` build is a manual step |

---

## Top Project Questions (rapid recall)

1. Business problem? → Olist leadership's realistic sales/customer/delivery questions.
2. Biggest dataset gotcha? → `customer_id` (order-level) vs `customer_unique_id` (real person).
3. Revenue formula? → `SUM(price+freight)`, delivered only, cross-verified vs `order_payments`.
4. AOV mistake to avoid? → Don't `AVG(price)` directly — grain mismatch.
5. Strongest insight? → On-time 4.29★ vs late 2.57★.
6. RFM frequency scoring? → Fixed CASE WHEN, not NTILE (97% tied at freq=1).
7. Biggest bug found? → RFM recency-direction (ASC→DESC fix) + missing SQLite indexes.
8. Why SQLite? → Zero-setup, file-based, fits this project's scale.
9. Why RFM not ML clustering? → Explainability + project-scope fit.
10. Dashboard status? → Design/DAX/spec complete; physical `.pbix` build is a separate manual step.

## Top 25 SQL Questions (see files 05/06/21 for full answers)

SELECT/WHERE/DISTINCT/ORDER BY/LIMIT basics · COUNT vs COUNT(DISTINCT) · SUM vs AVG ·
GROUP BY mechanics · WHERE vs HAVING · CASE WHEN buckets · INNER vs LEFT JOIN · 3-table joins ·
Subquery vs CTE · Scalar subquery · NTILE() and its tied-data limitation · AOV grain-mismatch ·
Revenue formula & scope · Monthly trend with strftime · Delivery-days with julianday ·
Sample-size-safety HAVING pattern · Revenue-concentration scalar-subquery pattern · VIEW purpose ·
customer_unique_id vs customer_id · RFM CTE chain · Execution order of a SQL query ·
ROW_NUMBER/PARTITION BY (general, not project) · LAG/LEAD (general, not project) ·
Primary vs Foreign Key · Fact vs Dimension tables.

## Top 15 Python/Pandas Questions (see files 07/08/22)

DataFrame vs Series · `.info()/.describe()` · `.loc` vs `.iloc` · filtering with `&`/`|` ·
`.dropna(subset=)` vs bare `.dropna()` · exact vs logical duplicates · `.merge(how=)` ·
`.groupby().agg()` · `.value_counts()` · `pd.to_datetime(errors="coerce")` ·
`.astype(str).str.zfill()` · method chaining/`.assign()` · vectorized ops vs `.apply()` vs loops ·
`np.where()` for conditional columns · why Pandas + SQL are complementary.

## Top 15 Power BI Questions (see files 15/16/23)

Desktop vs Service · Data model/relationships · Calculated Column vs Measure ·
`CALCULATE()` · `DIVIDE()` · 1:1 vs 1:many cross-filter defaults · Fact vs Dimension tables ·
why a precomputed `category_performance` table · Top-N filters · Slicer vs Filter ·
Card vs KPI visual · Visual-type selection reasoning · Star-schema basics ·
dashboard-design principles (max visuals/page, consistent color) · project's 3-page structure.

## Top 15 Statistics Questions (see files 11/24)

Mean vs Median vs Mode · when mean misleads · Variance/SD intuition · Percentile vs Quartile ·
Correlation vs Causation (**most important**) · distribution shapes (skewed/bimodal) ·
outlier handling judgment · population vs sample · probability basics (general) ·
hypothesis testing/p-value/CI (general, not used in project) · project's bimodal example
(review scores) · project's skewed example (price) · project's correlation example
(delivery vs rating) · sample-size awareness (`HAVING count >= x`) · why no formal test was run.

---

## Study Priority — Final Recap

| Priority | What |
|---|---|
| 🔴 MUST KNOW | SQL fundamentals through JOINs/GROUP BY/HAVING, Pandas cleaning functions, AOV grain-mismatch, revenue/repeat-rate/RFM definitions, correlation≠causation, 2-min project pitch, all 8 business insights |
| 🟡 GOOD TO KNOW | CTEs/subqueries/NTILE, Power BI DAX basics, chart-selection reasoning, cleaning edge-cases, resume-bullet depth |
| 🟢 OPTIONAL | VIEWs, exact DAX syntax memorization, geolocation-aggregation internals, hypothesis testing details |

---

## FINAL SELF-TEST

Answer these out loud, from memory, before an interview. If you hesitate on any, revisit the
linked file.

1. What is Data Analytics? → [01](01_DATA_ANALYTICS_FROM_ZERO.md)
2. What problem does my project solve? → [02](02_PROJECT_OVERVIEW.md)
3. Explain my dataset. → [03](03_DATASET_DEEP_DIVE.md)
4. Explain the data cleaning process. → [09](09_DATA_CLEANING.md)
5. Explain one SQL query line by line. → [06](06_SQL_USED_IN_MY_PROJECT.md)
6. What is GROUP BY? → [05](05_SQL_FROM_ZERO.md)
7. What is JOIN? → [04](04_DATABASE_AND_DATA_MODEL.md)
8. Why use LEFT JOIN? → [04](04_DATABASE_AND_DATA_MODEL.md), [06](06_SQL_USED_IN_MY_PROJECT.md)
9. Why use Python if SQL is available? → [18](18_END_TO_END_PROJECT_WALKTHROUGH.md)
10. What is Pandas? → [08](08_PANDAS_FROM_ZERO.md)
11. What is EDA? → [10](10_EDA_AND_VISUALIZATION.md)
12. Why did we use this chart? → [10](10_EDA_AND_VISUALIZATION.md)
13. What is an average order value? → [12](12_BUSINESS_METRICS.md)
14. What is customer segmentation? → [14](14_CUSTOMER_SEGMENTATION.md)
15. Explain my segmentation. → [14](14_CUSTOMER_SEGMENTATION.md)
16. What is Power BI? → [15](15_POWER_BI_FROM_ZERO.md)
17. Explain my dashboard. → [16](16_POWER_BI_IN_MY_PROJECT.md)
18. Why did we choose these KPIs? → [12](12_BUSINESS_METRICS.md), [16](16_POWER_BI_IN_MY_PROJECT.md)
19. What were the key insights? → [17](17_BUSINESS_INSIGHTS.md)
20. What are the limitations? → [25](25_PROJECT_DEFENSE.md)
21. What would you improve? → [25](25_PROJECT_DEFENSE.md)
22. Tell me about the project in 1 minute. → [02](02_PROJECT_OVERVIEW.md)

**Harder follow-ups:**
- "Prove your revenue number is correct." → Cross-verification vs `order_payments` (0.017% diff).
- "Your RFM has very few 'Loyal' customers — is that a bug?" → No — reflects the dataset's real
  ~3% repeat-rate, an honest limitation of the business, not the method.
- "Your delivery-satisfaction insight — is that causal?" → No, it's a strong correlation;
  causation would need a controlled experiment.
- "Why didn't you build the actual Power BI file?" → Design/DAX/spec is complete; the `.pbix`
  is a separate manual GUI step — be ready to state your actual current build status honestly.

---

## What I should remember

- This file is your **last-mile** revision — if anything feels shaky, go to the linked deep-dive
  file, don't just re-read this summary.
- The two "must never forget" concepts of this entire book: **AOV grain-mismatch** and
  **correlation ≠ causation.**
