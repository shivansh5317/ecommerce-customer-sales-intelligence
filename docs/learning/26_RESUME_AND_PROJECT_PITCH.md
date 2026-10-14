# 26 — Resume and Project Pitch

## 1. Pitch Lengths (practice out loud — full scripts in file 02 section 10)

- **30-second pitch** → [02_PROJECT_OVERVIEW.md](02_PROJECT_OVERVIEW.md#10-explain-my-project--4-lengths-practice-these-out-loud)
- **1-minute pitch** → same section
- **2-minute pitch** → same section
- **5-minute pitch** → same section

**How to practice:** Time yourself out loud (phone timer). Do not read — internalize the
**structure** (Business Problem → Approach → Key Finding → optional Limitation), then speak
naturally each time. Yeh naturally har baar thoda alag lagega — jo ek achha sign hai (script
nahi, samझ hai).

---

## 2. Recommended Project Title & Tech Stack Line

**Title:** E-Commerce Customer & Sales Intelligence — SQL, Python & Power BI Analytics Project

**Tech Stack:** `SQL (SQLite) · Python (Pandas, Matplotlib, Seaborn) · Power BI (DAX) ·
Jupyter Notebook · Git`

**1-Line Description:** End-to-end analysis of ~100K real e-commerce orders — SQL + Python for
cleaning/analysis/RFM segmentation, Power BI for an executive dashboard — surfacing
evidence-based insights on sales, customer retention, and delivery performance.

---

## 3. Resume Bullets — Deep-Dive (what each line means, proof, interview-follow-ups)

### Bullet 1
> "Cleaned and analyzed a 9-table, ~1.1M-row real-world e-commerce dataset (Olist, Brazil)
> using Python (Pandas) and SQL, resolving data-quality issues including duplicate records,
> inconsistent types, and referential mismatches, and documenting every cleaning decision."

- **What this line means:** Tumने 9 raw tables (~1.1M total rows across all of them, mostly
  driven by `geolocation`'s 1,000,163 rows) clean ki, real data-quality problems fix ki.
- **Proof/data supporting it:** [09_DATA_CLEANING.md](09_DATA_CLEANING.md) — har table ka
  before/after row count, har decision ka reasoning.
- **Interviewer questions this invites:** "Kaunse data-quality issues the specifically?" "Ek
  duplicate-record example do." "Referential mismatch ka matlab?" (Answer: `customer_id` vs
  `customer_unique_id` jaisa gotcha, ya category-translation coverage gap.)
- **Must know before using this bullet:** Poora file 09 — har table ke specific issues, na ki
  sirf "maine data clean kiya" generic statement.

### Bullet 2
> "Wrote 25+ SQL queries (joins, CTEs, subqueries, window functions) across 6 analysis modules
> to answer sales, customer, product, regional, and delivery business questions on a SQLite
> database of 99,441 orders totaling R$15.4M in delivered-order revenue."

- **What this line means:** 6 SQL files, 25+ distinct queries, real (not made-up) revenue
  number.
- **Proof:** [06_SQL_USED_IN_MY_PROJECT.md](06_SQL_USED_IN_MY_PROJECT.md) — har query yahan
  hai, verified.
- **Interviewer questions:** "Ek CTE example do." "Ek window-function example do." "R$15.4M yeh
  number kaise verify kiya?" (Answer: cross-checked against `order_payments`, 0.017% diff.)
- **Must know:** Kam-se-kam 3-4 queries **line-by-line** confidently explain kar sako
  (AOV subquery, RFM CTE-chain, ek HAVING-based query).

### Bullet 3
> "Built a rule-based RFM customer segmentation (Recency/Frequency/Monetary) in SQL,
> identifying that only 3.0% of 96,096 unique customers are repeat buyers and isolating an
> 'At Risk' segment (22,690 customers, R$266.82 avg. historical spend) as the highest-ROI
> retention target."

- **What this line means:** RFM segmentation banाई, aur ek specific, actionable business
  finding nikala (At Risk segment).
- **Proof:** [14_CUSTOMER_SEGMENTATION.md](14_CUSTOMER_SEGMENTATION.md) — poori scoring logic,
  real numbers.
- **Interviewer questions:** "RFM explain karo." "Yeh 'highest-ROI' kaise decide kiya?" (Answer:
  At Risk ka avg-spend 2nd-highest hai among segments, despite inactive hone ke — proven
  spending capability = high potential ROI agar re-engage kiya jaaye.)
- **Must know:** Poora RFM scoring mechanism (NTILE direction, frequency-CASE-WHEN decision,
  segment-priority-order) — yeh sabse zyada follow-up-invite karne wala bullet hai.

### Bullet 4
> "Designed a 3-page Power BI dashboard (data model, relationships, DAX measures) visualizing
> sales trends, customer segments, and delivery KPIs; uncovered that on-time deliveries
> average 4.29★ customer ratings vs. 2.57★ for late deliveries — the project's strongest,
> most actionable insight."

- **What this line means:** Dashboard **design** kiya (data-model+DAX+layout) — is bullet mein
  "designed" word use hua hai, "built the .pbix" nahi — yeh word-choice honest hai given current
  status (dekho file 16 honesty note). Agar tumने actually `.pbix` bhi bana liya ho, tab bullet
  ko update karke "Built" bhi keh sakte ho.
- **Proof:** [16_POWER_BI_IN_MY_PROJECT.md](16_POWER_BI_IN_MY_PROJECT.md) + `dashboard/README.md`.
- **Interviewer questions:** "Dashboard dikhaओ." "Data model kaise design kiya?" (Poora
  page-by-page walkthrough ready rakho.)
- **Must know:** Agar dashboard abhi tak physically nahi bana, is fact ko honestly acknowledge
  karne ke liye ready raho (dekho file 16 top).

---

## 4. Rules for Using These Bullets

- **Never add an unsupported claim.** Koi bhi "%," revenue, ya "improved X by Y%" number jo
  yahan verified nahi hai, resume mein mat likho.
- **No "before/after" improvement claims.** Is project ka koi "purana system" nahi tha jispar
  compare kiya ja sake — isliye "improved efficiency by 30%" jaisi phrases **galat/fabricated**
  honगी. Sirf jo actually measure/discover kiya, wahi bolो.
- **Prioritize bullets 3 aur 4** agar resume-space limited hai — sabse specific numbers/insights
  yahi hain.
- **Har number ko trace kar sako:** Agar interviewer poochे "yeh R$266.82 kaise aaya," seedhे
  us SQL query/file tak point kar sako.

---

## What I should remember

- 4 resume bullets, sab **verified real numbers** se banे hain — koi bhi invented percentage
  nahi.
- Bullet 4 mein "designed" word deliberately hai (not "built") — dashboard-build-status ke
  honest reflection ke liye.
- Har bullet ke peeche poori depth honी chahiye — resume ek "hook" hai, interview mein depth
  chahiye.
