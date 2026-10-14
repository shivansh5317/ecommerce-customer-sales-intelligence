# 30 — Glossary (A-Z)

> Format: **Term → Simple Hinglish meaning → One-line example → Project relevance.**

---

**AOV (Average Order Value)** → Ek order ka average total value → Revenue ÷ Orders →
Project mein R$159.83, subquery se calculate kiya (grain-mismatch se bachने ke liye).

**Aggregate Function** → Multiple rows ko ek number mein convert karने wala function →
`SUM`, `AVG`, `COUNT` → Har revenue/metric query mein use hue.

**Bimodal Distribution** → Data ke do "peaks" hon, ek nahi → Review scores (5★ aur 1★ dono high)
→ Chart 2 ka key observation.

**CASE WHEN** → SQL ka if-else → Delivery status ya RFM segment banाने mein → Poore project mein
buckets/labels ke liye use hua.

**CTE (Common Table Expression)** → `WITH ... AS` se banाई gaई readable temporary query → RFM
pipeline (`rfm_base`→`rfm_calc`→`rfm_scores`) → Multi-step SQL logic ko readable banाता hai.

**Calculated Column (Power BI)** → Row-level, stored computed column → `Delivery Status` →
Har order ka fixed label, filter se nahi badalta.

**Correlation** → Do cheezein saath change hoती dikहती hain → Delivery-status aur rating →
Insight 1 ka core concept — causation nahi, association hai.

**DAX** → Power BI ki formula language (Data Analysis eXpressions) → `CALCULATE()`, `DIVIDE()`
→ Saari dashboard measures isमें likhी gaई.

**DataFrame** → Pandas ka 2D table object → `pd.read_csv()` ka result → Har raw/cleaned table
isी form mein handle hui.

**Dimension** → Categorical grouping column → `product_category`, `customer_state` → Har GROUP
BY isी par hoता hai.

**Dimension Table** → Descriptive/lookup table (facts ke against) → `customers`, `products` →
Power BI star-schema design mein.

**Fact Table** → Transaction/event table → `orders`, `order_items` → Poore project ka core data.

**Freight Value** → Shipping charge, per line-item → `order_items.freight_value` → Revenue
formula ka hissa; remote-state-AOV insight (8) mein central role.

**Grain** → Ek row exactly kis cheez ko represent karती hai → `order_items` ka grain = line-item
→ AOV galat-calculation-mistake ki root cause samझाता hai.

**GROUP BY** → Rows ko category ke hisab se baांटकर aggregate karna → `GROUP BY category` →
Sabse zyada use hone wala SQL concept is project mein.

**HAVING** → Grouped/aggregated result ko filter karна (GROUP BY ke baad) → `HAVING
orders_count >= 100` → Sample-size-safety ke liye use hua.

**Insight** → Data se nikала hua meaningful, actionable fact → Observation→Evidence→
Interpretation→Action format → 8 documented insights (file 17).

**JOIN** → Do tables ko common key se jodना → INNER/LEFT → Har multi-table query mein.

**KPI (Key Performance Indicator)** → Wo metric jo business regularly track karती hai →
"On-Time Delivery %" → Metric ka hi ek subset, har metric KPI nahi hota.

**LEFT JOIN** → Left table ki saari rows + matches (na milने par NULL) → `products LEFT JOIN
category_translation` → 623 products ko silently-lost hone se bachaया.

**Measure (Power BI)** → Aggregate-level, on-the-fly computed value → `Total Revenue` → Filter
ke saath dynamically badalता hai.

**Metric** → Koi bhi measured/calculated number → Revenue, AOV, order count → Poore project ka
core output.

**Monetary (RFM)** → Customer ne total kितна spend kiya → `SUM(price+freight)` per customer →
RFM ka "M."

**NTILE()** → Rows ko N barabar-size groups mein baантने wala window function → RFM
Recency/Monetary scoring → Frequency ke liye jaan-boojh kar use nahi kiya (tied-data issue).

**Normalization** → Same fact ko baар-baар store na karke, ek jagah rakhkar reference karna →
`order_items` sirf `product_id` rakhta hai, poori detail `products` mein → Poore data model mein.

**On-Time Delivery %** → Estimate ke andar deliver hue orders ka % → `delivered_date <=
estimated_date` → File 12 ka core operational KPI.

**Outlier** → Baaki data se bahut alag/extreme value → `price` max ₹6,735 → Verify-then-decide
approach follow kiya, blindly delete nahi.

**Percentile** → Kितने % data kisी value se neeche hai → 75th percentile → Quartile (RFM) isकी
special case hai.

**Primary Key (PK)** → Row ko uniquely identify karता column → `order_id` → Har table ka anchor.

**Quartile** → Data ko 4 barabar hisso mein baантने wale cut-points → RFM scoring ka core idea
(`NTILE(4)`).

**RFM** → Recency, Frequency, Monetary — customer segmentation framework → 5 segments (High
Value/Loyal/At Risk/Recent/Low Engagement) → File 14, poore project ka centerpiece analysis.

**Recency (RFM)** → Last order se kितने din hue → `recency_days` → RFM ka "R."

**Repeat Purchase Rate** → % customers jinहोंने >1 baar order kiya → 3.0% → Insight 3 ka core number.

**Revenue** → `SUM(price + freight_value)`, delivered orders only → R$15,419,773.75 → Poore
project ka baseline metric.

**Scalar Subquery** → Ek subquery jo exactly ek single value return karती hai → Revenue-
concentration % query (file 06 Query 4.4) → Comparison-denominator ke liye use hua.

**Segment (Customer)** → Customers ka ek meaningful group (RFM se banая) → "At Risk" → File 14.

**Slicer (Power BI)** → Interactive visual-filter → Date-range, segment, state slicers →
Har dashboard page ka apna independent slicer.

**Star Schema** → Fact table center mein, dimension tables around — simple BI data-model design
→ Is project ka Power BI model → File 04/16.

**Subquery** → Query ke andar ek aur query → AOV calculation → Grain-mismatch fix karта hai.

**VIEW** → Saved query jo virtual-table ki tarah reuse hoती hai → `customer_rfm` → RFM
computation ko ek jagah rakhता hai.

**WHERE** → Row-level filter, GROUP BY se pehले → `WHERE order_status = 'delivered'` → Poore
project ka sabse-repeat-hone-wala filter.

**Window Function** → Aggregate-jaisा calculation jo rows ko squash nahi karता → `NTILE()` →
RFM scoring mein use hua.

---

## What I should remember

- Yeh glossary ek **quick lookup** hai — agar kisी term ka full context chahiye, us term ke
  associated dedicated file (link diया gaya hai upar description mein) padho.
- 3 terms jo sabse zyada baar poori book mein aaye: **Grain, RFM, Correlation vs Causation.**
