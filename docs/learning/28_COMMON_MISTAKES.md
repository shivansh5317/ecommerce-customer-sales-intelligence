# 28 — Common Mistakes

> Har mistake: **Wrong approach → Why wrong → Correct approach → Interview lesson.**

---

## 1. Confusing Metric vs KPI

- **Wrong approach:** Har number ko "KPI" bol dena.
- **Why wrong:** Har metric KPI nahi hota — KPI wo metric hai jo business **specifically,
  regularly track karti hai** apne goals ke against.
- **Correct approach:** "On-Time Delivery %" ek KPI hai (operations team track karti hai);
  "average price per line-item" ek metric hai lekin typically KPI nahi.
- **Interview lesson:** Interviewer chhote-chhote vocabulary-precision se batता hai ki tumने
  concepts genuinely samझे hain ya sirf buzzwords ratट liye hain.

## 2. Using the Wrong JOIN

- **Wrong approach:** Hamesha INNER JOIN use karna, bina soche.
- **Why wrong:** Agar ek table mein match na ho, poori row **silently gayab** ho jaati hai —
  koi error nahi aata, bas kam/galat rows return hoती hain.
- **Correct approach:** Pehle poocho "agar match na ho, kya wo row phir bhi chahiye?" — agar
  haan, LEFT JOIN (jaisा project mein `products LEFT JOIN category_translation` — 623 products
  bina translation ke bhi rakhने ke liye).
- **Interview lesson:** *"INNER JOIN aur LEFT JOIN mein choose karte waqt tumhara decision
  process kya hai?"* — is reasoning ko bolो.

## 3. Counting Duplicates (Grain Mismatch)

- **Wrong approach:** `order_items` (line-item level) par directly `COUNT(order_id)` ya
  `AVG(price)` lagana jab "order-level" ya "AOV" chahiye ho.
- **Why wrong:** Multi-item orders **multiple baar** count/average ho jaते hain — galat weighting.
- **Correct approach:** Pehle `COUNT(DISTINCT order_id)`, ya pehle per-order total banaओ
  (subquery/CTE), phir uska average lo.
- **Interview lesson:** Yeh is poore project ka **sabse important, sabse zyada-tested** mistake
  hai — AOV calculation (file 06 Query 1.3) isकी direct example hai.

## 4. Incorrect Aggregation (choosing the wrong function)

- **Wrong approach:** Har jagah `AVG()` use karna, chahe `SUM()` ya `COUNT()` chahiye ho.
- **Why wrong:** "Total revenue" ke liye `AVG(price)` bilkul galत hoगा (`SUM()` chahiye);
  "kितne customers" ke liye `SUM()` galت hoगा (`COUNT(DISTINCT)` chahiye).
- **Correct approach:** Business-question ko pehले carefully padhो — "total" → SUM, "kितne" →
  COUNT, "average" → AVG, "sabse zyada/kam" → MAX/MIN.
- **Interview lesson:** Dhyan se socho **kya poocha ja raha hai** se pehले SQL likhने se pehले.

## 5. Misleading Charts

- **Wrong approach:** Ek chart-type ko "universally best" maan lena (jaise hamesha pie chart).
- **Why wrong:** Pie chart 20+ categories ke saath unreadable ho jaata hai; normal-scale
  histogram heavily-skewed data (jaisा `price`) ko ek corner mein "chipka" deता hai.
- **Correct approach:** Data-type se chart-type decide karo (file 10 section 2) — categorical→
  bar, continuous→histogram (log-scale agar skewed), trend→line.
- **Interview lesson:** *"Kaunsa chart kab use karoge"* — yeh judgment poochा jaता hai, ek fixed
  rule nahi.

## 6. Confusing Correlation with Causation

- **Wrong approach:** "Late delivery **cause** karti hai low rating" bolна as a proven fact.
- **Why wrong:** Observational data se causation formally prove nahi hota — koi confounding
  factor bhi ho sakta hai.
- **Correct approach:** "Late delivery aur low rating ka **strong association/correlation**
  hai" bolो.
- **Interview lesson:** File 11 section 8 — is poore book ka **sabse important, sabse repeat
  hone wala** interview-trap.

## 7. Removing Missing Data Blindly

- **Wrong approach:** `.dropna()` bina `subset` ke, har jagah.
- **Why wrong:** Poori row delete ho jaती hai agar **kisी bhi** column mein null ho, chahe wo
  column irrelevant hi kyun na ho — bahut data waste hota hai.
- **Correct approach:** `subset=[...]` specify karo — sirf un columns ko check karo jo genuinely
  matter karte hain us specific cleaning-step ke liye. Aur pehle poocho "yeh missing value kyun
  hai" — kabhi wo ek legitimate business-state hoता hai (jaise non-delivered order ki delivery
  date), jise delete/fill karna hi galत hoगा.
- **Interview lesson:** File 09 poora — 3 alag missing-value-strategies, alag reasoning ke saath.

## 8. Interpreting Outliers Incorrectly

- **Wrong approach:** Outlier dikhते hi automatically delete karna.
- **Why wrong:** Outlier genuine, legitimate rare-case bhi ho sakta hai (jaise ek premium
  product ki price) — delete karna real data kho deता hai.
- **Correct approach:** Pehle verify karo — kya yeh clearly ek error hai (jaise negative price),
  ya ek legitimate rare case? Is project mein max price ₹6,735 the verify-karke-rakha gaya.
- **Interview lesson:** *"Outlier ko kab remove karoge?"* — nuanced answer do, blanket-rule nahi.

## 9. Creating Unnecessary Dashboard Visuals

- **Wrong approach:** Jitne bhi possible charts hon, sab ek page par daal dena.
- **Why wrong:** Overloaded dashboard confusing hota hai — user ko pata nahi chalता kahan dekhे.
- **Correct approach:** Max ~6-7 visuals/page, har visual ka ek specific business-question honा
  chahiye jo justify kare "yeh visual yahan kyun hai."
- **Interview lesson:** *"Ek visual kyun add kiya, ya kyun nahi kiya?"* — har visual defend kar
  sako.

## 10. Giving Business Recommendations Without Evidence

- **Wrong approach:** "Company ko X karna chahiye" bolना bina kisी data-evidence ke.
- **Why wrong:** Recommendation bina evidence ke ek **guess** hai, insight nahi.
- **Correct approach:** Observation→Evidence→Interpretation→Implication format follow karo
  (file 17) — har recommendation ek specific number/query se traceable honा chahiye.
- **Interview lesson:** *"Yeh recommendation kis data se aaई?"* — hamesha seedhे point kar sako.

## 11. (Project-specific bonus) Using the wrong "customer" identifier

- **Wrong approach:** `customer_id` ko "unique customer" maान lena.
- **Why wrong:** `customer_id` order-level unique hai — "0% repeat customers" jaisा completely
  galत result deta hai.
- **Correct approach:** `customer_unique_id` use karo har customer-level analysis mein.
- **Interview lesson:** File 03/19 B2 — is dataset ka signature gotcha.

## 12. (Project-specific bonus) Trusting NTILE with heavily-tied data

- **Wrong approach:** Har scoring/bucketing ke liye `NTILE()` use karna, bina data-distribution
  check kiye.
- **Why wrong:** Agar bahut saare rows ek hi value par tied hain (jaise 97% customers ki
  frequency=1), `NTILE` unhे arbitrarily split kar deता hai — misleading scores.
- **Correct approach:** Tied-heavy columns ke liye fixed, business-meaningful `CASE WHEN`
  buckets use karo (jaisa project ne Frequency ke liye kiya).
- **Interview lesson:** File 14 — ek genuinely-impressive, self-caught design decision.

---

## What I should remember

- Sabse zyada-tested mistakes: **grain-mismatch (AOV)** aur **correlation-vs-causation**.
- Har mistake ka fix ek **judgment call** hai, ek blanket-rule nahi — interviewer isी nuance
  ko test karta hai.
- Do project-specific "signature" mistakes bhi yaad rakho: `customer_id` gotcha, aur
  NTILE-with-tied-data.
