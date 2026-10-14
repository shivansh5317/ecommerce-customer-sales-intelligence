# 19 — Project Interview (Full Question Bank)

> Har question is **exact repository** ke facts par based hai. Format: **Question → Simple
> Hinglish answer → Technical answer → Possible follow-up → What interviewer is testing →
> Mistake to avoid.**

---

## A. Basic Project Questions

### A1. "Apne project ke baare mein batao."
- **Simple answer:** Maine Olist (Brazilian e-commerce) ke ~100k real orders ka data liya, clean
  kiya, SQL+Python se analyze kiya, customers segment kiye, aur Power BI dashboard design kiya.
- **Technical answer:** Poora pitch [02_PROJECT_OVERVIEW.md](02_PROJECT_OVERVIEW.md) section 10
  mein (30s/1min/2min/5min versions).
- **Follow-up:** "Sabse interesting finding kya tha?" → Insight 1 (delivery vs rating).
- **Testing:** Kya tum apna project **communicate** kar sakte ho bina ramble kiye.
- **Mistake to avoid:** Sirf tools ka naam-drop karna ("SQL, Python, Power BI kiya") bina
  business-context ke — hamesha business-problem se shuru karo.

### A2. "Yeh project kyun banaya?"
- **Simple answer:** Data Analytics ke real skills (SQL, Python, Power BI, business thinking)
  ek real, messy dataset par practice karne ke liye — tutorial-toy-dataset nahi.
- **Technical answer:** Olist dataset real business-messiness (nulls, duplicates, inconsistent
  categories) deता hai jo genuinely realistic practice deता hai.
- **Follow-up:** "Koi aur dataset consider kiya tha?" → UCI "Online Retail" — lekin usme delivery
  dates/review scores nahi hain, jo delivery/satisfaction analysis (required areas) ke liye
  Olist ko better banata hai.
- **Testing:** Kya decision-making ke peeche reasoning hai, ya random choice thi.
- **Mistake to avoid:** "Kyunki tutorial mein tha" jaisा weak reason — concrete reason do.

### A3. "Is project mein tumhara individual role/contribution kya tha?"
- **Simple answer:** Poora project — dataset selection se leke data cleaning, SQL analysis,
  Python EDA, RFM segmentation, aur Power BI design tak, sab khud kiya.
- **Technical answer:** Har decision (cleaning choices, revenue-formula, RFM-scoring-method)
  explicitly reasoned aur documented — copy-pasted nahi.
- **Follow-up:** "Kya AI tools use kiye?" → Honest raho apne actual process ke baare mein; jo bhi
  use kiya ho, core yeh hai ki tum **har decision ko khud explain kar sakte ho**, chahe likhने
  mein kisी ne bhi madad ki ho.
- **Testing:** Ownership aur genuine understanding, na ki memorization.
- **Mistake to avoid:** Vague rehna ("maine sab kuch kiya") — specific decisions/bugs
  (jaise RFM recency-direction bug) bolो jo genuine hands-on kaam dikhाते hain.

### A4. "Project ka scope kya tha, kya nahi tha?"
- **Simple answer:** Sales/customer/product/regional/delivery analysis + RFM segmentation +
  dashboard design. ML clustering, NLP, forecasting **nahi** kiya — jaan-boojh kar.
- **Technical answer:** README "Future Improvements" section explicitly list karta hai kya
  scope se bahar rakha gaya, aur kyun (dekho [25_PROJECT_DEFENSE.md](25_PROJECT_DEFENSE.md)).
- **Follow-up:** "Yeh limitations weakness hain?" → Nahi — deliberate scoping decisions hain jo
  project ko beginner-defensible/interview-safe rakhती hain.
- **Testing:** Kya tum apni project-boundaries ko confidently articulate kar sakte ho.
- **Mistake to avoid:** "Maine sab kuch kar diya, koi limitation nahi" bolना — red flag hai.

---

## B. Dataset Questions

### B1. "Yeh data kahan se aaya?"
- **Simple answer:** Kaggle se, Olist (real Brazilian marketplace) ka public dataset,
  `kagglehub` library se download kiya.
- **Technical answer:** 9 relational CSVs, ~100k orders, Sep 2016 - Oct 2018, anonymized real
  production data.
- **Follow-up:** "Data anonymized kaise hai?" → IDs hashed/randomized hain (jaise
  `customer_id`), koi real naam/address nahi, sirf city/state-level location.
- **Testing:** Data-provenance awareness.
- **Mistake to avoid:** "Kahin se bhi le liya" jaisा vague answer.

### B2. "Dataset ka sabse tricky/confusing part kya tha?"
- **Simple answer:** `customer_id` vs `customer_unique_id`.
- **Technical answer:** `customer_id` order-level unique (99,441), `customer_unique_id`
  person-level unique (96,096) — dekho [03_DATASET_DEEP_DIVE.md](03_DATASET_DEEP_DIVE.md).
- **Follow-up:** "Agar galti se `customer_id` use karte, kya hota?" → "0% repeat customers"
  dikhता — completely galat.
- **Testing:** Kya tumne data ko genuinely deeply samjha hai, ya sirf load kiya hai.
- **Mistake to avoid:** Kisi bhi naye dataset mein har "id"-jaisi column ko bina verify kiye
  "unique key" maan lena.

### B3. "Data ka grain kya hai, aur yeh kyun important hai?"
- **Simple answer:** Grain = ek row exactly kis cheez ko represent karti hai. `order_items` ka
  grain "line item" hai, "order" nahi.
- **Technical answer:** Grain samajhe bina average/count nikalna galat result deta hai — AOV
  ka subquery-based calculation (file 06) isकी sabse badi example hai.
- **Follow-up:** "Kis aur jagah grain-mismatch ka risk tha?" → `geolocation` table (many rows
  per zip) — agar directly join karte, fan-out ho jaata.
- **Testing:** Fundamental data-modeling understanding.
- **Mistake to avoid:** Kisi bhi average nikalne se pehle "grain kya hai" confirm na karna.

### B4. "Is dataset mein sabse dirty/problematic table kaunsi thi?"
- **Simple answer:** `geolocation` — 26% duplicate rows, aur "many rows per zip" grain problem.
- **Technical answer:** 1,000,163 rows → 738,332 (dedup) → 19,015 (aggregate to 1/zip).
- **Follow-up:** "Isko fix kyun zaroori tha?" → Bina fix ke, customer/seller se join karте waqt
  fan-out (duplicate rows multiply) ho jaata, revenue jaisi metrics galat ho jaatीं.
- **Testing:** Cleaning-reasoning depth.
- **Mistake to avoid:** Sirf "maine dedup kiya" bolना, "kyun zaroori tha" na explain karna.

---

## C. Data Cleaning Questions

### C1. "Apna cleaning process walk-through karo."
- **Simple answer:** Pehle inspect kiya (nulls/duplicates/dtypes), phir har table ke liye
  specific issues fix kiye — bina blindly delete kiye.
- **Technical answer:** [09_DATA_CLEANING.md](09_DATA_CLEANING.md) poora reference hai.
- **Follow-up:** "Sabse tricky cleaning decision?" → Geolocation ka aggregation (mean lat/lng,
  mode city).
- **Testing:** Structured thinking, not just "ran .dropna() everywhere."
- **Mistake to avoid:** Cleaning ko "sirf `.dropna()` chala do" jaisa oversimplify karna.

### C2. "Missing values ko kaise decide karte ho — delete karo, fill karo, ya chhodो?"
- **Simple answer:** Depends on **why** it's missing aur **kितna** missing hai.
- **Technical answer:** 3 cases in this project: (a) legitimate lifecycle nulls (order abhi
  delivered nahi hua) → chhodो as-is; (b) categorical missing with reasonable default →
  `fillna("unknown")`; (c) tiny count, critical numeric, no way to impute honestly → drop
  (2 rows only).
- **Follow-up:** "Kabhi impute (mean/median se fill) kiya?" → Nahi is project mein — kyunki
  jahan bhi numeric-missing tha, wo itna negligible tha (2 rows) ki drop karna zyada honest tha
  fabricate karne se.
- **Testing:** Nuanced decision-making, not a one-size-fits-all rule.
- **Mistake to avoid:** Ek hi rule ("hamesha delete" ya "hamesha fill") har situation mein
  apply karna.

### C3. "Duplicate data ko kaise identify aur handle kiya?"
- **Simple answer:** Do types — exact (poori row repeat) aur logical (same key, multiple rows).
- **Technical answer:** Exact: `geolocation` (`.duplicated()`, drop). Logical: `order_reviews`
  (`.duplicated(subset="order_id")`, keep-latest).
- **Follow-up:** "Keep-latest kyun, keep-first kyun nahi?" → Latest = customer ka final/updated
  opinion.
- **Testing:** Understanding that "remove duplicates" isn't one universal operation.
- **Mistake to avoid:** Logical duplicates ko `.drop_duplicates()` bina `subset` ke treat karna.

### C4. "Outlier dikhne par tumने kya kiya?"
- **Simple answer:** Turant delete nahi kiya — pehle verify kiya error hai ya genuine case.
- **Technical answer:** `order_items.price` max ₹6,735 tha — negative/zero values check ki
  (koi nahi mili), aur high value ko legitimate premium-product maan kar rakha.
- **Follow-up:** "Kaunse case mein delete karте?" → Agar negative price milता (data-entry error
  ka clear signal) — is dataset mein nahi mila.
- **Testing:** Outlier-handling maturity (not "always remove outliers").
- **Mistake to avoid:** Outlier dikhते hi automatically delete kar dena.

---

## D. SQL Questions

### D1. "Apni sabse complex SQL query explain karo."
- **Simple answer:** RFM segmentation query (`sql/06`) — CTEs + window function + CASE WHEN.
- **Technical answer:** Poora breakdown [14_CUSTOMER_SEGMENTATION.md](14_CUSTOMER_SEGMENTATION.md)
  section 4.
- **Follow-up:** "Isमें koi bug mila?" → Haan — recency scoring direction (`ASC` → `DESC` fix).
- **Testing:** Depth of SQL understanding beyond copy-paste.
- **Mistake to avoid:** Query "kya karti hai" bata dena bina "kyun aisा likhा" explain kiye.

### D2. "WHERE aur HAVING mein fark, apne project ke example ke saath."
- **Simple answer:** WHERE = row filter (before grouping); HAVING = group filter (after
  grouping).
- **Technical answer:** `sql/03_product_analysis.sql` Query 2 — `HAVING orders_count >= 100`
  (sample-size safety, ek aggregate-result par condition).
- **Follow-up:** "WHERE mein yeh condition kyun nahi likh sakte?" → `orders_count` GROUP BY
  complete hone tak exist hi nahi karta.
- **Testing:** Classic, very-commonly-asked SQL fundamental.
- **Mistake to avoid:** `WHERE COUNT(*) > x` likhने ki koshish karna.

### D3. "AOV kaise calculate kiya, directly AVG(price) kyun nahi?"
- **Simple answer:** AOV = per-**order** average; `AVG(price)` per-**line-item** average deta
  — grain mismatch.
- **Technical answer:** Subquery se pehle order-level total (`GROUP BY order_id`), phir uska
  `AVG()`.
- **Follow-up:** "Yeh mistake kितni common hai?" → Bahut — "grain mismatch" DA beginners ki
  sabse frequent galtiyon mein se ek.
- **Testing:** Ek genuinely-important, frequently-tested concept.
- **Mistake to avoid:** Kisi bhi average se pehle grain confirm na karna.

### D4. "Subquery vs CTE vs Window Function — kab kaunsa use karoge?"
- **Simple answer:** Subquery/CTE = same kaam, CTE zyada readable multi-step logic ke liye.
  Window function = jab row-level identity retain karni ho (squash nahi karna).
- **Technical answer:** Project mein: subquery (AOV), CTE (customer-orders, RFM chain),
  window function (`NTILE` — RFM recency/monetary scores).
- **Follow-up:** "NTILE ka limitation dekha?" → Haan — tied data (frequency=1 for ~97%) ke saath
  arbitrarily split karta hai — fixed CASE WHEN buckets use kiye frequency ke liye.
- **Testing:** Practical judgment, not just definitions.
- **Mistake to avoid:** Window function har jagah use karna jab simple GROUP BY kaafi ho.

---

## E. Python Questions

### E1. "Python/Pandas kyun use kiya jab SQL se bhi analysis ho sakta tha?"
- **Simple answer:** Dono complementary hain — SQL answers deta hai, Python explore/visualize
  karta hai.
- **Technical answer:** [05_python_eda_learning.md](../05_python_eda_learning.md) section 1.
- **Follow-up:** "Ek concrete example do jo sirf Python mein possible tha, SQL mein nahi (aasani se)."
  → Chart-based pattern discovery (review-score ka bimodal hona) — SQL se number milता, shape
  nahi.
- **Testing:** Tool-selection reasoning.
- **Mistake to avoid:** "SQL better hai" ya "Python better hai" bolना — dono alag purpose.

### E2. "Notebook mein sabse complex data-transformation kya thi?"
- **Simple answer:** Method-chaining pipeline (merge → query → assign → groupby → agg) revenue
  charts ke liye.
- **Technical answer:** File 08 section 14 — `.assign(lambda d: ...)` current transformed state
  ka reference leta hai.
- **Testing:** Real code-reading comprehension.
- **Mistake to avoid:** Method chaining ko "fancy dikhने ke liye" bolना — actual reason
  readability/no-intermediate-clutter hai.

---

## F. Pandas Questions

### F1. "`.merge()` SQL JOIN se kaise related hai?"
- **Simple answer:** `.merge()` Pandas ka JOIN hai — same concept, alag syntax.
- **Technical answer:** `products.merge(category_translation, on="product_category_name",
  how="left")` — SQL `LEFT JOIN` jaisa hi behavior.
- **Follow-up:** "LEFT JOIN yahan kyun, INNER kyun nahi?" → 623 products bina translation ke the
  — INNER se wo silently gayab ho jaate.
- **Testing:** Cross-tool concept transfer (SQL knowledge Pandas mein apply karna).
- **Mistake to avoid:** `.merge()` ko `pd.concat()` se confuse karna (concat = stack karna,
  merge = key-based-join karna — bilkul alag operations).

### F2. "`.dropna()` use karte waqt kya dhyan rakhते ho?"
- **Simple answer:** Hamesha `subset=` specify karta hoon — poori row sirf tab delete honi
  chahiye jab **specific**, relevant columns null hon.
- **Technical answer:** `products.dropna(subset=["product_weight_g", ...])` — sirf dimension-
  columns check kiye, poori row nahi.
- **Testing:** Awareness of a very common, silent-data-loss mistake.
- **Mistake to avoid:** `.dropna()` bina argument ke use karna production/analysis code mein.

---

## G. Statistics Questions

### G1. "Is project mein correlation vs causation kahan relevant tha?"
- **Simple answer:** Delivery-vs-rating insight — strong association hai, lekin "delay hi
  guaranteed cause hai" nahi bola.
- **Technical answer:** File 11 section 8 — n>7000 dono groups, bada consistent gap, phir bhi
  "correlation" language use ki, "proven causation" nahi.
- **Follow-up:** "Yeh causation kaise prove karте (theoretically)?" → Controlled experiment/A-B
  test chahiye hota (jaise ek group ki delivery jaan-boojh kar slow karke measure karna) — is
  observational dataset se possible nahi.
- **Testing:** Statistical maturity — ek bahut commonly-tested DA interview concept.
- **Mistake to avoid:** Kisi bhi strong correlation ko seedha "X causes Y" bol dena.

### G2. "Mean use karoge ya median, kis situation mein?"
- **Simple answer:** Skewed data/outliers ho toh median; symmetric data ho toh mean theek hai.
- **Technical answer:** `price` distribution right-skewed hai (file 11) — isliye log-scale
  histogram use kiya visualize karne ke liye, aur `.describe()` se mean-vs-median difference
  khud hi skew ka signal deta hai.
- **Testing:** Practical statistics application, not just formula memorization.
- **Mistake to avoid:** Har jagah blindly mean use karna, especially skewed data par.

---

## H. Power BI Questions

### H1. "Apna data model design karo/explain karo."
- **Simple answer:** Fact tables (orders/items/payments/reviews) + Dimension tables
  (customers/products/sellers), star-schema-jaisa design.
- **Technical answer:** [16_POWER_BI_IN_MY_PROJECT.md](16_POWER_BI_IN_MY_PROJECT.md) sections
  1-2.
- **Follow-up:** "`category_performance` ko relationship se kyun nahi jodा?" → 3-hop chain ke
  liye bidirectional relationship chahiye hoती (ambiguity-risk) — precomputed table safer tha.
- **Testing:** Data-modeling judgment, not just "I connected the tables."
- **Mistake to avoid:** Har cross-table metric ke liye bidirectional relationships laga dena
  "quick fix" ki tarah.

### H2. "Calculated Column aur Measure mein practical fark ek project-example ke saath."
- **Simple answer:** `Delivery Status` (column, row-level fixed) vs `Total Revenue` (measure,
  filter-se-change-hone-wala).
- **Technical answer:** File 15 section 4 table.
- **Testing:** Very common practical Power BI interview question.
- **Mistake to avoid:** Aggregation ko calculated column bana dena (slow + non-dynamic).

---

## I. Business Questions

### I1. "Company ko sabse pehle kaunsi problem solve karni chahiye, tumhare insights ke hisab se?"
- **Simple answer:** Delivery reliability — kyunki yeh directly, strongly (Insight 1) satisfaction
  se linked hai aur ek operational (fixable) lever hai.
- **Technical answer:** File 17 Insight 1 — sabse strong evidence, sabse directly-actionable.
- **Follow-up:** "Retention (3% repeat rate) zyada urgent nahi hai?" → Dono important hain;
  delivery ek operational/short-term fix hai, retention ek longer-term strategic investment —
  dono parallel chalाए ja sakte hain.
- **Testing:** Business prioritization thinking, not just listing facts.
- **Mistake to avoid:** "Sab equally important hain" jaisा non-answer dena — ek clear
  prioritization dikhाओ with reasoning.

### I2. "At Risk segment ko kaise re-engage karoge, specifically?"
- **Simple answer:** Personalized discount/reminder email, unke pehले purchase-history ke
  basis par.
- **Technical answer:** At Risk = high past-monetary (R$266.82 avg) + stale recency — inki
  proven spending-capability ki wajah se ROI-highest targeted segment.
- **Testing:** Kya tum insight ko concrete-action mein translate kar sakte ho.
- **Mistake to avoid:** Generic advice ("marketing karo") bina segment-specific reasoning ke.

---

## J. Decision-Making Questions

### J1. "SQLite kyun choose kiya, koi aur database kyun nahi?"
- **Simple answer:** File-based, zero-setup, is project ke scale (~100k rows, single-user) ke
  liye kaafi.
- **Technical answer:** [04_DATABASE_AND_DATA_MODEL.md](04_DATABASE_AND_DATA_MODEL.md)
  interview section.
- **Follow-up:** "Limitation kya face ki?" → No default indexes (`pandas.to_sql()`) — joins
  bahut slow the shuru mein, explicit `CREATE INDEX` se fix kiya.
- **Testing:** Scope-appropriate tool selection, not "biggest/most-popular tool always."
- **Mistake to avoid:** "SQLite hi best hai" bolना — yeh ek scope-appropriate choice tha.

### J2. "RFM kyun, ML clustering (K-Means) kyun nahi?"
- **Simple answer:** RFM fully explainable/simple hai; K-Means "black-box"-ish aur
  unnecessarily complex is project ke scope ke liye.
- **Technical answer:** File 14 section 7 table.
- **Testing:** Scope-discipline — knowing when NOT to use a fancier technique.
- **Mistake to avoid:** ML ko "hamesha better" maanना — context-appropriate choice matter karta
  hai.

---

## K. Challenge / Failure Questions

### K1. "Is project mein sabse tricky bug/issue kya tha?"
- **Simple answer:** Do bade issues — RFM recency-scoring direction bug, aur SQLite joins bina
  index ke bahut slow ho jaana.
- **Technical answer:**
  1. `pandas.to_sql()` se banayi tables mein koi index/PK nahi hota by default — text-column
     joins full-table-scan nested-loop bana dete hain, jo ~100k rows par "hang" jaisa dikhता
     hai. Fix: explicit `CREATE INDEX` har join column par + `ANALYZE`.
  2. RFM recency scoring directionally ulta tha (`ASC` likha tha, `DESC` chahiye tha) — verify
     karke fix kiya.
- **Follow-up:** "Aage se aise issues kaise avoid karoge?" → Naya DB banate waqt turant indexes
  add karna (proactively); koi bhi scoring/ranking logic likhne ke baad chhota sample manually
  trace/verify karna.
- **Testing:** Genuine hands-on debugging experience (vs a "perfect, bug-free" fake narrative).
- **Mistake to avoid:** "Koi issue nahi aaya, sab first-try perfect chala" bolना — non-credible.

### K2. "Kya koi cheez thi jo tum karna chahte the lekin nahi kar paye?"
- **Simple answer:** Power BI `.pbix` file ko is automated-environment se directly build nahi
  kar sakte — woh ek manual GUI step hai.
- **Technical answer:** Poora spec/DAX/design ready hai; sirf physical build Power BI Desktop
  mein hona hai.
- **Testing:** Honesty about constraints — a strong maturity signal.
- **Mistake to avoid:** Isko chhupाना ya jhooth bolना ki dashboard fully built hai agar nahi hai.

---

## L. Follow-up Questions (rapid-fire style, practice these)

| Question | One-line answer |
|---|---|
| "Revenue formula repeat karo." | `SUM(price + freight_value)`, delivered orders only. |
| "Repeat-purchase rate kितna tha?" | 3.0% |
| "On-time vs late rating gap?" | 4.29★ vs 2.57★ |
| "Sabse bada revenue-state?" | SP, 37.42% |
| "RFM ke 5 segments naam?" | High Value, Loyal, At Risk, Recent, Low Engagement |
| "Sabse worst-rated category?" | office_furniture, 3.49★ |
| "Kितni SQL files/queries?" | 6 files, 25+ queries |
| "Kितne raw tables the?" | 9 |
| "Database kaunsa use kiya?" | SQLite |
| "Dashboard kितne pages ka hai?" | 3 — Executive Overview, Customer Insights, Product & Operations |

---

## What I should remember

- Har category (A-L) ke liye kam-se-kam 2-4 questions confidently answer kar sakना chahiye.
- Follow-up questions aksar "why," "what if," ya "kaise verify kiya" hote hain — sirf fact
  yaad na rakho, **reasoning** yaad rakho.
- Honesty (limitations, bugs, incomplete-build) ek weakness nahi, ek **credibility signal** hai.
