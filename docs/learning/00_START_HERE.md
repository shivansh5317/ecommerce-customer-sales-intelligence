# 00 — START HERE

> Yeh poora `docs/learning/` folder tumhare liye ek **complete study book** hai — is exact
> project (E-Commerce Customer & Sales Intelligence) ke around banaya gaya. Goal simple hai:
> tum abhi Data Analytics mein **complete beginner** ho, aur is book ko khatam karne ke baad
> tumhe apna hi project **end-to-end, confidently, bina AI-generated cheat-sheet yaad kiye**
> ek entry-level Data Analyst interview mein explain karna aana chahiye.

---

## 1. Yeh project kya hai (30-second version)

Tumne ek **real e-commerce company (Olist, Brazil)** ka ~100,000 orders wala data liya, use
**clean** kiya, SQL aur Python se **analyze** kiya, customers ko **segment** kiya (RFM), aur
Power BI mein ek **dashboard design** banaya — taaki sales/customer/delivery se related real
business sawalon ke jawab data se diye ja sakein, guess se nahi.

Poora detail: [02_PROJECT_OVERVIEW.md](02_PROJECT_OVERVIEW.md).

## 2. Is book se tum kya seekhoge

| Area | Tumhe kya aayega end mein |
|---|---|
| **Data Analytics fundamentals** | DA kya hota hai, DA workflow kya hota hai, key vocabulary (KPI/metric/insight/etc.) |
| **SQL** | Zero se leke JOINs/GROUP BY/subqueries/CTEs/window functions tak, apne hi project ki real queries ke through |
| **Python + Pandas** | Data cleaning aur EDA ke liye zaroori Pandas functions, apne hi notebook ke through |
| **Statistics** | Mean/median/percentile/correlation jaisi basics — sirf utni jitni project/interview ke liye chahiye |
| **Business Metrics** | Revenue, AOV, repeat-rate jaise metrics — kya hain aur company inhe kyun track karti hai |
| **Customer Segmentation (RFM)** | Recency/Frequency/Monetary se customers ko segment karna |
| **Power BI** | Data model, relationships, DAX measures, dashboard design thinking |
| **Interview Skills** | Apna project confidently explain karna, follow-up questions handle karna, resume bullets defend karna |

## 3. Yeh notes kaise use karo

- **Sequentially padho** — yeh ek reference manual nahi, ek **course** hai. Topics ek doosre
  par build hote hain (e.g. SQL samjhe bina "SQL used in my project" file samajh nahi aayegi).
- Har file mein teen cheezein alag-alag milengi — inhe **kabhi mix mat karna apne dimaag mein**:
  - **GENERAL** → Data Analytics mein yeh concept generally kya hota hai (kisi bhi project mein)
  - **MY PROJECT** → Maine ismein exactly kahan/kaise use kiya (real facts, is repo se)
  - **INTERVIEW** → Interviewer isko kaise pooch sakta hai
- Jab bhi ek naya file kholo, uske andar ke headings + tables ko dhyan se padho — beech mein
  skip mat karo, especially "Interview Tip" aur "Common Mistake" boxes.
- Har major topic ke end mein ek chhota **"What I should remember"** summary hai — agar time
  kam ho, revision ke waqt sirf wahi dobara padho.

## 4. Study Order (yeh order follow karo, random mat kudo)

```
PROJECT BASICS            -> 01, 02, 03, 04
SQL                        -> 05, 06
PYTHON / PANDAS            -> 07, 08
DATA CLEANING               -> 09
EDA / VISUALIZATION          -> 10
STATISTICS                    -> 11
BUSINESS METRICS                -> 12
CUSTOMER ANALYSIS                  -> 13
CUSTOMER SEGMENTATION (RFM)           -> 14
POWER BI                                -> 15, 16
BUSINESS INSIGHTS                          -> 17
FULL WALKTHROUGH                              -> 18
INTERVIEW PREP (sabse important, sabse aakhri) -> 19 to 30
```

Poora sequence, file-by-file:

1. [01_DATA_ANALYTICS_FROM_ZERO.md](01_DATA_ANALYTICS_FROM_ZERO.md)
2. [02_PROJECT_OVERVIEW.md](02_PROJECT_OVERVIEW.md)
3. [03_DATASET_DEEP_DIVE.md](03_DATASET_DEEP_DIVE.md)
4. [04_DATABASE_AND_DATA_MODEL.md](04_DATABASE_AND_DATA_MODEL.md)
5. [05_SQL_FROM_ZERO.md](05_SQL_FROM_ZERO.md)
6. [06_SQL_USED_IN_MY_PROJECT.md](06_SQL_USED_IN_MY_PROJECT.md)
7. [07_PYTHON_FROM_ZERO.md](07_PYTHON_FROM_ZERO.md)
8. [08_PANDAS_FROM_ZERO.md](08_PANDAS_FROM_ZERO.md)
9. [09_DATA_CLEANING.md](09_DATA_CLEANING.md)
10. [10_EDA_AND_VISUALIZATION.md](10_EDA_AND_VISUALIZATION.md)
11. [11_STATISTICS_FROM_ZERO.md](11_STATISTICS_FROM_ZERO.md)
12. [12_BUSINESS_METRICS.md](12_BUSINESS_METRICS.md)
13. [13_CUSTOMER_ANALYSIS.md](13_CUSTOMER_ANALYSIS.md)
14. [14_CUSTOMER_SEGMENTATION.md](14_CUSTOMER_SEGMENTATION.md)
15. [15_POWER_BI_FROM_ZERO.md](15_POWER_BI_FROM_ZERO.md)
16. [16_POWER_BI_IN_MY_PROJECT.md](16_POWER_BI_IN_MY_PROJECT.md)
17. [17_BUSINESS_INSIGHTS.md](17_BUSINESS_INSIGHTS.md)
18. [18_END_TO_END_PROJECT_WALKTHROUGH.md](18_END_TO_END_PROJECT_WALKTHROUGH.md)
19. [19_PROJECT_INTERVIEW.md](19_PROJECT_INTERVIEW.md)
20. [20_DA_INTERVIEW_PREP.md](20_DA_INTERVIEW_PREP.md)
21. [21_SQL_INTERVIEW_PREP.md](21_SQL_INTERVIEW_PREP.md)
22. [22_PYTHON_INTERVIEW_PREP.md](22_PYTHON_INTERVIEW_PREP.md)
23. [23_POWER_BI_INTERVIEW_PREP.md](23_POWER_BI_INTERVIEW_PREP.md)
24. [24_STATISTICS_INTERVIEW_PREP.md](24_STATISTICS_INTERVIEW_PREP.md)
25. [25_PROJECT_DEFENSE.md](25_PROJECT_DEFENSE.md)
26. [26_RESUME_AND_PROJECT_PITCH.md](26_RESUME_AND_PROJECT_PITCH.md)
27. [27_MOCK_INTERVIEW.md](27_MOCK_INTERVIEW.md)
28. [28_COMMON_MISTAKES.md](28_COMMON_MISTAKES.md)
29. [29_QUICK_REVISION.md](29_QUICK_REVISION.md)
30. [30_GLOSSARY.md](30_GLOSSARY.md)

> 📌 Yeh `docs/learning/` folder **naya, dedicated study-book** hai. Iske alawa `docs/00` se
> `docs/09` tak already ek "project-facts" documentation set hai (usi project ke baare mein,
> thodi zyada technical/terse style mein) — is naye book ke andar hum unhi verified facts ko
> **reuse** karte hain, lekin beginner-teaching ke liye zyada depth aur structure ke saath.
> Dono ek doosre ko replace nahi karte — `docs/00-09` "what was done" hai, `docs/learning/`
> "how to learn and defend it" hai.

## 5. Must Know vs Good to Know vs Optional (poore project ke liye, top-level)

| Priority | Topics |
|---|---|
| 🔴 **MUST KNOW** (entry-level DA interview mein bina iske mत mत jaana) | SQL SELECT/WHERE/JOIN/GROUP BY/HAVING/aggregate functions, Pandas DataFrame basics + cleaning functions, revenue/AOV/repeat-rate definitions, RFM concept, `customer_id` vs `customer_unique_id` gotcha, correlation ≠ causation, apna project 2-minute mein explain karna |
| 🟡 **GOOD TO KNOW** (aayega toh acha impression padega) | CTEs, subqueries, window functions (`NTILE`), Power BI DAX (`CALCULATE`/`DIVIDE`), chart-type selection reasoning, data cleaning edge-cases |
| 🟢 **OPTIONAL** (agar poocha jaaye tabhi, proactively mention mat karo) | `VIEW`s, geolocation aggregation internals, exact DAX syntax for every measure |

(Full breakdown file-by-file hai [20_DA_INTERVIEW_PREP.md](20_DA_INTERVIEW_PREP.md) mein.)

## 6. Is book ko khatam karne ke baad tum yeh kar paoge

- Apna dataset, tables, aur unke beech relationships explain kar paoge (bina notes dekhe).
- Kisi bhi SQL query ko line-by-line explain kar paoge — kya karti hai aur kyun waisi likhi gayi.
- Pandas/data-cleaning decisions ko justify kar paoge ("humne yeh kyun kiya, delete kyun nahi kiya").
- RFM segmentation poori tarah explain kar paoge — formula se leke business-meaning tak.
- Apne Power BI dashboard design ko page-by-page walk-through kar paoge.
- Apne 8 business insights ko Observation → Evidence → Interpretation → Action format mein bata paoge.
- Common DA/SQL/Python/Power BI/Statistics interview questions confidently answer kar paoge.
- Apne resume bullets ke peeche ka proof/data explain kar paoge.
- Project ki limitations aur possible improvements honestly discuss kar paoge.

## 7. Ek cheez jo shuru mein hi samajh lo

Yeh project **jaan-boojh kar simple/interview-safe** rakha gaya hai — ML clustering, NLP/sentiment
analysis, forecasting, jaisी advanced cheezein **nahi** hain. Yeh weakness nahi hai — yeh ek
**scoping decision** hai, aur interview mein isे confidently defend karna hi is book ka ek bada
hissa hai. (Poora reasoning: [25_PROJECT_DEFENSE.md](25_PROJECT_DEFENSE.md).)

## 8. Learning Roadmap — 7-day / 14-day / 30-day plans

Apni available time ke hisab se ek plan choose karo. Har din: **kya padhna, kaunsa project-file
review karna, kya practice karna, kaunse interview-Qs answer karna.**

### 7-Day Plan (intensive, interview kal-parso hai)

| Day | Study | Project File to Review | Practice | Interview Qs |
|---|---|---|---|---|
| 1 | 01, 02, 03, 04 | README.md, docs/01 | 2-min pitch bolна | File 19 A, B |
| 2 | 05, 06 | sql/01-06 | 3 queries khud likhна (bina dekhे) | File 21 EASY+MEDIUM |
| 3 | 07, 08, 09 | notebook Sections 1-6 | Ek cleaning-decision khud explain karна | File 19 C |
| 4 | 10, 11, 12 | notebook Sections 7-10 | Har chart ka "why" bolна | File 24 |
| 5 | 13, 14 | sql/06, docs/04 | RFM poora scoring bolна (bina notes) | File 19 D, file 14 |
| 6 | 15, 16, 17, 18 | dashboard/README.md | Dashboard walk-through bolна | File 19 H, I |
| 7 | 19-30 (skim + self-test) | — | Mock interview (file 27) poora karo | File 29 self-test |

### 14-Day Plan (balanced)

| Days | Focus |
|---|---|
| 1-2 | Files 00-04 (project + dataset + data-model foundations) |
| 3-5 | Files 05-06 (SQL from zero → project queries), practice writing queries daily |
| 6-7 | Files 07-09 (Python/Pandas/cleaning) |
| 8 | Files 10-12 (EDA, statistics, metrics) |
| 9-10 | Files 13-14 (customer analysis + RFM deep-practice) |
| 11 | Files 15-16 (Power BI) |
| 12 | Files 17-18 (insights + full walkthrough), practice full pitch |
| 13 | Files 19-24 (interview question banks — answer every single one out loud) |
| 14 | Files 25-30 (defense, resume, mock interview, mistakes, revision, glossary) |

### 30-Day Plan (deep, thorough mastery)

| Week | Focus |
|---|---|
| Week 1 | Files 00-06 — project overview, dataset, data model, SQL (from zero + project). Practice: rewrite every project SQL query from memory. |
| Week 2 | Files 07-12 — Python, Pandas, cleaning, EDA, statistics, metrics. Practice: explain every chart and every cleaning decision out loud. |
| Week 3 | Files 13-18 — customer analysis, RFM, Power BI, insights, full walkthrough. Practice: full dashboard walkthrough + all 8 insights from memory. |
| Week 4 | Files 19-30 — full interview-prep gauntlet. Do the mock interview (file 27) at least twice. Do the final self-test (file 29) until every answer is fluent. |

---

**Ready ho? Shuru karo yahan se:** [01_DATA_ANALYTICS_FROM_ZERO.md](01_DATA_ANALYTICS_FROM_ZERO.md)
