# 00 — Learning Roadmap

> Yeh file **sabse pehle padho** — is project ke har hisse ko samajhne ke liye jo concepts
> chahiye, wo sab yahan hain. Har concept ke saath: **kya hai / is project mein kyun zaroori
> hai / chhota example / kahan use hua / interview importance.** Poori depth-wali explanation
> respective `docs/` file mein hai — yeh sirf ek **map** hai ki kya padhna hai aur kis order mein.

---

## A. SQL — yeh samajhna zaroori hai `sql/` folder aur `docs/03`/`docs/04` padhne se pehle

| Concept | Kyun zaroori hai | Tiny example | Kahan use hua | Interview importance |
|---|---|---|---|---|
| `SELECT` / `WHERE` | Har query ka foundation — columns choose karna, rows filter karna | `SELECT * FROM orders WHERE order_status='delivered'` | Har SQL file mein | 🔴 Must know |
| `JOIN` (INNER/LEFT) | Multiple tables ka data ek saath laane ke liye | `orders JOIN order_items ON orders.order_id = order_items.order_id` | Har SQL file mein | 🔴 Must know |
| `GROUP BY` + aggregates | Category/state/customer-wise summaries banane ke liye | `GROUP BY category` + `SUM(revenue)` | Sabhi 6 SQL files | 🔴 Must know |
| `HAVING` | Aggregated results ko filter karna (WHERE se different) | `HAVING orders_count >= 100` | `03_product_analysis.sql` | 🟡 Good to know |
| `ORDER BY` / `LIMIT` | Ranking aur "top N" results | `ORDER BY revenue DESC LIMIT 10` | Har file mein rankings ke liye | 🔴 Must know |
| `CASE WHEN` | Conditional logic — buckets/labels banana | `CASE WHEN score>=3 THEN 'Good' ELSE 'Bad' END` | Delivery status, RFM segments | 🔴 Must know |
| Subquery | Query-ke-andar-query, jab multi-step calculation chahiye | AOV calculation (per-order total, phir average) | `01_basic_sales_analysis.sql` Q3 | 🟡 Good to know |
| CTE (`WITH`) | Subquery ka readable version, multi-step logic ke liye | `WITH customer_orders AS (...) SELECT ...` | `02_customer_analysis.sql`, RFM | 🟡 Good to know |
| Window function (`NTILE`) | Rows ko squash kiye bina ranking/bucketing | `NTILE(4) OVER (ORDER BY monetary)` | RFM scoring (`06_customer_segmentation.sql`) | 🟢 Optional (but this project uses it meaningfully) |
| `VIEW` | Ek complex query ko "saved" reusable table ki tarah rakhna | `CREATE VIEW customer_rfm AS ...` | `06_customer_segmentation.sql` | 🟢 Optional |
| Date functions (`strftime`, `julianday`) | Month extract karna, date-differences nikalna | `strftime('%Y-%m', date_col)` | Monthly trend, delivery-days | 🟡 Good to know |

**Padhne ka order:** `docs/03_sql_learning.md` (concept-by-concept, real queries ke saath) →
phir `docs/04_customer_segmentation.md` (RFM deep-dive).

---

## B. Python / Pandas — `notebooks/01_eda.ipynb` aur `docs/02`/`docs/05` padhne se pehle

| Concept | Kyun zaroori hai | Tiny example | Kahan use hua | Interview importance |
|---|---|---|---|---|
| `DataFrame` basics (`.head()`, `.info()`, `.describe()`) | Data ko "dekhna" — kitni rows, columns, basic stats | `df.info()` | Section 2-3 of notebook | 🔴 Must know |
| `.dtypes`, `.isnull().sum()`, `.duplicated().sum()` | Data-quality problems identify karna | `df.isnull().sum()` | Section 3 (Inspect) | 🔴 Must know |
| `pd.to_datetime(errors="coerce")` | Text dates ko real datetime banana, safely | `pd.to_datetime(col, errors="coerce")` | Section 4.1, 4.3, 4.5 | 🔴 Must know |
| Missing-value handling (`.fillna()`, `.dropna(subset=)`) | Nulls ko sochke handle karna, blindly delete nahi | `df["category"].fillna("unknown")` | Section 4.6 | 🔴 Must know |
| Duplicates (`.drop_duplicates(subset=, keep=)`) | Exact aur logical duplicates dono handle karna | `.drop_duplicates(subset="order_id", keep="last")` | Section 4.5, 4.7 | 🟡 Good to know |
| `.merge()` | Pandas ka JOIN | `products.merge(category_translation, how="left")` | Section 4.6 | 🔴 Must know |
| `.groupby().agg()` | SQL GROUP BY ka pandas equivalent | `.groupby("state").agg(revenue=("total","sum"))` | EDA charts, geolocation aggregation | 🔴 Must know |
| Method chaining (`.assign()`, multi-line pipelines) | Readable, step-by-step transformations | Dekho `docs/05` section 2 | Section 9 (charts data prep) | 🟡 Good to know |
| Matplotlib/Seaborn (`barplot`, `histplot`, `plot`) | Data ko visually communicate karna | `sns.barplot(x=..., y=...)` | Section 8-9 (10 charts) | 🔴 Must know |
| Log-scale histograms | Heavily-skewed numeric data ko readable banana | `sns.histplot(data, log_scale=True)` | Chart 3 (price distribution) | 🟢 Optional |

**Padhne ka order:** `docs/02_data_cleaning.md` (cleaning reasoning) → notebook khud padho/run
karo → `docs/05_python_eda_learning.md` (concepts + chart choices).

---

## C. Statistics — sirf utna jitna is project mein actually use hua

| Concept | Kyun zaroori hai | Tiny example | Kahan use hua | Interview importance |
|---|---|---|---|---|
| Mean / Median / basic descriptive stats | Data ka "typical value" aur spread samajhna | `.describe()` output | Section 7 of notebook | 🔴 Must know |
| Percentages / proportions | Business metrics communicate karne ke liye | "3% repeat customers" | Har jagah insights mein | 🔴 Must know |
| Distribution shape (skewed, bimodal) | Data ki "shape" business meaning rakhti hai | Review scores bimodal — dekho `docs/05` | Charts 2, 3 | 🟡 Good to know |
| Quartiles | Data ko 4 equal groups mein baantna | RFM scoring ka core idea | RFM (`docs/04`) | 🟡 Good to know |
| Sample-size awareness | Chhote sample se average trust na karna | `HAVING reviews_count >= 30` | `03_product_analysis.sql` Q3 | 🟡 Good to know |
| Correlation ≠ causation | Insights ko sahi confidence ke saath present karna | Delivery-vs-rating insight — dekho `docs/08` Part 2 Q10 | Insight 1, `docs/07` | 🔴 Must know (interview trap) |

**Padhne ka order:** In concepts ko standalone padhne ki zaroorat nahi — jahan bhi use hue hain
(`docs/03`, `docs/04`, `docs/05`, `docs/07`), wahin explain kiye gaye hain.

---

## D. Power BI — `dashboard/` aur `docs/06` padhne se pehle

| Concept | Kyun zaroori hai | Tiny example | Kahan use hua | Interview importance |
|---|---|---|---|---|
| Data model / relationships | Multiple tables ko ek dashboard mein jodna | 1:many, 1:1 relationships (dekho `dashboard/README.md` section 2) | Poora data model | 🔴 Must know |
| Calculated Column vs Measure | Row-level vs aggregate-level calculation ka fark | `Delivery Status` (column) vs `Total Revenue` (measure) | `dashboard/README.md` sections 3-4 | 🔴 Must know |
| Basic DAX (`CALCULATE`, `DIVIDE`, `SUM`, `AVERAGE`, `DISTINCTCOUNT`) | Business metrics compute karna | `DIVIDE([Total Revenue],[Total Orders])` | Sabhi measures | 🔴 Must know |
| Visual types (Card/Bar/Line/Donut/Table) | Sahi chart type sahi data ke liye choose karna | Dekho `docs/06` section 5 | 3 dashboard pages | 🟡 Good to know |
| Slicers | User ko dashboard interactively filter karne dena | Date range, segment, state slicers | Har page | 🟡 Good to know |

**Padhne ka order:** `docs/06_powerbi_learning.md` (concepts explained) → `dashboard/README.md`
(exact spec) → `dashboard/HOW_TO_BUILD.md` (manual steps agar khud banana ho).

---

## E. Business Analytics — poore project ko "business sense" dene wale concepts

| Concept | Kyun zaroori hai | Tiny example | Kahan use hua | Interview importance |
|---|---|---|---|---|
| Core e-commerce KPIs (Revenue, AOV, Orders, Customers) | Har DA/business role mein yeh baseline vocabulary hai | AOV = Revenue ÷ Orders | `sql/01`, dashboard Page 1 | 🔴 Must know |
| RFM segmentation | Simple, explainable customer-value framework | Dekho `docs/04` poora | `sql/06`, dashboard Page 2 | 🔴 Must know |
| Insight framing (Observation → Evidence → Interpretation → Action) | Sirf chart dikhana kaafi nahi, business meaning nikalna zaroori hai | `docs/07_business_insights.md` structure | Har insight | 🔴 Must know |
| Scoping decisions (e.g. "delivered-only" filter) | Metrics define karne ke pehle business-context decide karna | `docs/02` section 9 | Revenue/delivery/satisfaction queries | 🔴 Must know |
| Data-driven caution (don't over-interpret) | Ek number dekh kar galat conclusion na nikalna | Remote-state AOV = freight artifact, not spending insight (`docs/07` Insight 8) | Business insights | 🔴 Must know (shows maturity) |

**Padhne ka order:** `docs/07_business_insights.md` (real insights) → `docs/08_interview_prep.md`
(likely questions) → `docs/09_resume_bullets.md` (kaise present karna hai).

---

## Suggested overall reading order (agar poora project sequentially seekhna hai)

1. `docs/01_dataset_understanding.md` — data kya hai
2. `docs/02_data_cleaning.md` + `notebooks/01_eda.ipynb` (Sections 1-6) — cleaning
3. `docs/03_sql_learning.md` + `sql/01`-`05` — SQL fundamentals se business analysis tak
4. `docs/04_customer_segmentation.md` + `sql/06` — RFM
5. `docs/05_python_eda_learning.md` + `notebooks/01_eda.ipynb` (Sections 7-10) — EDA & charts
6. `docs/06_powerbi_learning.md` + `dashboard/` — dashboard design
7. `docs/07_business_insights.md` — sab kuch business insights mein convert karna
8. `docs/08_interview_prep.md` — interview ke liye practice
9. `docs/09_resume_bullets.md` — resume ke liye final packaging
