# 18 — End-to-End Project Walkthrough

> Is file ka goal: tumhe poora project **beginning se end tak, ek saans mein**, dependencies
> samajhते hue narrate karna aana chahiye — including "iske baad yeh step kyun aaya, pehle
> kyun nahi."

---

## The Full Narrative (practice saying this out loud)

### 1. Business Problem

Olist (Brazilian e-commerce marketplace) ki leadership ki taraf se sochte hue, 5 core sawal
identify kiye: revenue trend, customer retention, category/regional performance, delivery
performance, aur customer value/segmentation.

### 2. Dataset

Kaggle se Olist ka real ~100k-order dataset (9 relational CSVs) `kagglehub` se download kiya.

### 3. Data Understanding

`scripts/explore_raw_data.py` chalाया — shapes, dtypes, null%, duplicate counts, aur key
business facts (order_status mix, review_score mix, etc.) print kiye. Isse
[docs/01_dataset_understanding.md](../01_dataset_understanding.md) likhi — verified facts,
guess nahi.

**Why this step before anything else?** Bina data ko samjhe, cleaning/analysis shuru karna
galtiyon ki taraf le jaata (jaise `customer_id` ko galat "unique customer" maan lena).

### 4. Cleaning

`notebooks/01_eda.ipynb` Sections 1-6 mein 8 tables clean ki — date-types fix kiye, zip
zero-padded, missing categories filled, duplicate reviews/geolocation rows resolve kiye, revenue
formula decide/verify kiya. Cleaned CSVs `data/processed/` mein export kiye.

**Why cleaning before analysis (not after)?** "Garbage in, garbage out" — agar galat/dirty data
par SQL query chalाते (jaise duplicate geolocation rows join karke), result khud galat aata
bina kisi error/warning ke. Cleaning ek **one-time, upstream** step hai taaki downstream (SQL,
Python EDA, Power BI) sab **same, trusted** data use karein.

### 5. SQL

`scripts/build_database.py` se cleaned CSVs ko `data/ecommerce.db` (SQLite) mein load kiya +
indexes banaye. `sql/01`-`06_*.sql` mein 25+ queries likhीं — sales, customer, product,
regional, delivery, RFM.

**Why SQL specifically for this part?** Structured, aggregate-heavy business questions
("total revenue," "top categories") SQL mein sabse **fast, precise, aur readable** tarike se
answer hote hain — ek database engine bade data par aggregate karne ke liye optimized hota hai.

### 6. Python (EDA)

Same notebook, Sections 7-10 — descriptive stats, univariate analysis, 10 business-relevant
charts.

**Why Python EDA agar SQL se already answers mil chuke the?** SQL numbers **deta** hai, Python
charts unhe **visually explore/communicate** karte hain — patterns jaise distribution-shape
(bimodal ratings) ya outlier-tails sirf ek number se nahi dikhते, ek chart se dikhते hain. Dono
complementary hain, redundant nahi.

### 7. Metrics

Revenue, AOV, Repeat Rate, Delivery %, etc. — sab define/calculate kiye consistent formulas ke
saath (dekho file 12).

### 8. Customer Analysis

Repeat-vs-one-time, frequency-distribution, highest-value customers (file 13).

### 9. Segmentation (RFM)

`sql/06_customer_segmentation.sql` — Recency/Frequency/Monetary scoring, 5 segments,
`scripts/export_customer_segments.py` se CSV export (file 14).

### 10. Power BI

Data model + relationships + DAX measures + 3-page visual design (files 15-16).

**Why Power BI after Python/SQL, not before?** Power BI dashboard **cleaned, already-analyzed**
data consume karta hai (`data/processed/*.csv` + `customer_segments.csv`) — dashboard design
khud koi naya analysis nahi karta, sirf existing verified numbers ko **interactive visual form**
mein present karta hai. Isliye yeh naturally pipeline ka **last-but-one** step hai.

### 11. Insights

8 documented insights, Observation→Evidence→Interpretation→Implication format (file 17).

### 12. Limitations

- Koi ML/clustering, NLP/sentiment, forecasting nahi (deliberate scope decision).
- Koi Profit/Conversion-Rate metric (data available hi nahi thi).
- Koi formal cohort-retention analysis ya hypothesis-testing.
- Power BI dashboard design-complete hai, `.pbix` build manual step hai.

### 13. Recommendations

Har insight ke saath ek "possible action" (file 17) — jaise At-Risk win-back campaign, delivery-
reliability investment, non-SP regional expansion.

---

## Why This Tool At This Step? (dependency reasoning, bullet-point cheat-sheet)

| Question | Answer |
|---|---|
| **Why did cleaning happen before analysis?** | Dirty data → silently wrong results (no error, just wrong numbers) — cleaning removes this risk upstream, once, for everyone downstream. |
| **Why use SQL?** | Structured aggregate business-questions ke liye fast/precise/readable — database engines yehi karne ke liye optimized hain. |
| **Why use Python if SQL already exists?** | SQL = answers; Python = exploration/visualization/complex-multi-step-cleaning. Complementary roles. |
| **Why Power BI after Python?** | Dashboard consumes already-cleaned, already-analyzed data — it's a presentation/interaction layer, not a new analysis layer. |
| **Why not do everything in Excel?** | Excel ~100k+ rows aur multi-table relationships ke saath clunky/slow ho jaata hai; SQL/Pandas is scale par zyada robust, reproducible (script se dobara chalाya ja sakta hai), aur version-controllable (Git) hain — Excel files diff/track karna mushkil hota hai. |
| **Why SQLite specifically (not MySQL/Postgres)?** | Zero-setup, file-based, single-user — is project ke scale/scope ke liye kaafi; production multi-user system ke liye client-server DB zyada appropriate hota. |
| **Why RFM instead of ML clustering?** | Fully explainable, no model-training complexity — project ka stated goal "beginner-defensible, har hissa samajh sakoon" tha. |

---

## INTERVIEW

**Q: "Apna poora project process se batao (walkthrough do)."**
> Upar wala "Full Narrative" section use karo — 13 steps, har ek ka 1-2 line summary.

**Q: "Agar tumhe yeh project dobara banana ho, kya order badloge?"**
> Core order same rahega (understanding→cleaning→analysis→visualization→insights) kyunki yeh
> ek **logical dependency chain** hai — har step agले ko trustworthy input deta hai. Shayad
> main dashboard-design ko thoda pehle sketch karta (parallel mein) taaki pata chale kaunse
> exact summary-tables chahiye honge Python export ke liye.

---

## What I should remember

- Pipeline: Understanding → Cleaning → SQL → Python EDA → Metrics → Customer Analysis →
  Segmentation → Power BI → Insights → Limitations → Recommendations.
- Har step ka doosre par ek **dependency reason** hai — yeh random order nahi hai.
- SQL aur Python complementary hain; Power BI ek presentation layer hai, naya analysis nahi.
- Limitations ko confidently, proactively bolna chahiye — yeh maturity dikhाता hai.
