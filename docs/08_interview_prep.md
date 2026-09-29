# 08 — Interview Preparation

> Har question ka format: **Question → Simple Hinglish answer → Technical answer → Follow-up
> question → Mistake to avoid.** Sirf wahi concepts cover kiye hain jo is project mein
> **actually use hue hain** — kuch bhi unrelated/advanced nahi.

---

## Part 1 — Basic Questions

### 1. SQL kya hai aur Data Analysis mein kyun use hota hai?

- **Simple answer:** SQL (Structured Query Language) ek language hai jisse hum database mein
  se data nikal (query kar) sakte hain, filter kar sakte hain, aggregate kar sakte hain.
- **Technical answer:** SQL relational databases (tables, rows, columns, relationships) ke
  saath interact karne ka standard language hai — `SELECT`, `INSERT`, `UPDATE`, `DELETE` jaise
  commands hote hain. DA context mein mostly `SELECT`-based querying use hoti hai.
- **Follow-up:** *"SQL ek programming language hai?"* → Technically "declarative" language hai
  (tum batate ho "kya chahiye," "kaise nikalna hai" nahi) — general-purpose programming
  language (jaise Python) se different category hai.
- **Mistake to avoid:** SQL ko "sirf SELECT * likhna" mat samjho — filtering, joining,
  aggregating sahi se karna hi real skill hai.

### 2. WHERE aur HAVING mein kya fark hai?

- **Simple answer:** `WHERE` raw rows ko filter karta hai, `GROUP BY` se pehle. `HAVING`
  grouped/aggregated result ko filter karta hai, `GROUP BY` ke baad.
- **Technical answer:** `WHERE` aggregate functions (`SUM`, `COUNT`, etc.) ke result par
  condition nahi laga sakta kyunki wo abhi compute hi nahi hue hote — isliye `HAVING` chahiye
  jab condition ek aggregate value par ho (e.g. `HAVING COUNT(*) > 100`).
- **Follow-up:** *"Ek query mein dono use kar sakte ho?"* → Haan — `WHERE` pehle rows filter
  karega, phir `GROUP BY`, phir `HAVING` grouped result filter karega.
- **Mistake to avoid:** `WHERE COUNT(*) > 100` likhna — yeh error dega, `HAVING` chahiye.
  (Project mein use: `sql/03_product_analysis.sql` Query 2.)

### 3. JOIN kya hai? Types kya hain?

- **Simple answer:** JOIN do tables ko ek common column (key) ke through jodta hai.
- **Technical answer:** Main types — `INNER JOIN` (sirf dono tables mein match hone wali rows),
  `LEFT JOIN` (left table ki saari rows, right se match na ho toh NULL), `RIGHT JOIN`,
  `FULL OUTER JOIN`. Is project mein mostly `INNER JOIN` (matching orders/items/products) aur
  `LEFT JOIN` (category translation, jahan match na ho toh bhi product row rakhni thi) use
  hue hain.
- **Follow-up:** *"Project mein LEFT JOIN kahan use kiya?"* → Notebook cleaning section 4.6 mein
  — `products.merge(category_translation, how="left")`, taaki bina-translation-wale products
  bhi drop na ho jaayein.
- **Mistake to avoid:** Hamesha `INNER JOIN` use karna bina soche — agar "left table ki saari
  rows chahiye chahe match ho ya na ho," `LEFT JOIN` chahiye, warna data silently gayab ho
  jaata hai.

### 4. GROUP BY kya karta hai?

- **Simple answer:** Rows ko kisi column ke value ke hisab se groups mein baantta hai, phir har
  group par ek aggregate function (SUM/AVG/COUNT) lagate hain.
- **Technical answer:** `SELECT` mein jo bhi columns non-aggregated hain, unhe `GROUP BY` mein
  hona hi chahiye (warna error ya undefined behavior).
- **Follow-up:** *"GROUP BY ke bina agar SUM() use karo toh?"* → Poori table ka ek hi total
  aayega (koi grouping nahi).
- **Mistake to avoid:** `GROUP BY` mein galat column daalna (jaise `product_id` ki jagah
  `product_name`, jab do products ka same naam ho) — duplicate/wrong groups ban sakte hain.

### 5. Primary Key aur Foreign Key mein kya fark hai?

- **Simple answer:** Primary Key ek table mein har row ko uniquely identify karta hai. Foreign
  Key ek table ka column hai jo doosri table ke Primary Key ko reference karta hai.
- **Technical answer:** Primary Key unique + not-null hota hai. Foreign Key relationship
  enforce karta hai (referential integrity) — is project mein `orders.order_id` primary key
  hai `orders` table ka, aur `order_items.order_id` uska foreign key hai.
- **Follow-up:** *"Is dataset mein customers table ka primary key kya hai?"* → Trick question —
  `customer_id` hai (order-level unique), lekin "real business primary key" (real customer)
  `customer_unique_id` hai. (Dekho `docs/01` section 3.1.)
- **Mistake to avoid:** Assume karna ki jo bhi "id" column dikhe wahi sabse meaningful unique
  identifier hai — hamesha verify karo (`nunique()` check karke).

### 6. COUNT(*) aur COUNT(column) mein kya fark hai?

- **Simple answer:** `COUNT(*)` saari rows ginta hai. `COUNT(column)` sirf un rows ko ginta hai
  jahan wo column NULL nahi hai.
- **Technical answer:** `COUNT(DISTINCT column)` ek teesra variant hai — unique non-null values
  ginta hai.
- **Follow-up:** *"Project mein COUNT(DISTINCT ...) kahan zaroori tha?"* → Order count nikalte
  waqt `order_items` se (jahan ek order ki multiple rows ho sakti hain) — `COUNT(DISTINCT
  order_id)` na use karte toh order count galat (zyada) aata.
- **Mistake to avoid:** `order_items` jaisी line-item-level table mein `COUNT(order_id)` (bina
  DISTINCT) use karna jab "kitne orders" poocha ja raha ho.

### 7. Pandas kya hai aur kyun use karte hain?

- **Simple answer:** Pandas ek Python library hai jo Excel-jaisa tabular data (rows/columns)
  ko code se handle karne deti hai.
- **Technical answer:** Core object `DataFrame` hai — cleaning, transformation, aggregation,
  aur analysis ke liye vectorized operations deta hai (loop se bahut fast).
- **Follow-up:** *"Pandas SQL se better hai ya worse?"* → Dono alag purpose ke liye best hain
  (dekho `docs/05` section 1) — competing nahi, complementary hain.
- **Mistake to avoid:** Pandas mein Python `for` loop se row-by-row process karna — bahut slow
  hai; vectorized operations (`.apply()`, direct column arithmetic) use karo.

### 8. DataFrame kya hai?

- **Simple answer:** Ek 2D table-jaisa structure — rows aur named columns, jisme alag-alag
  columns ke alag data types ho sakte hain.
- **Technical answer:** Internally columns `Series` objects hain; DataFrame unka collection hai,
  ek shared row-index ke saath.
- **Follow-up:** *"DataFrame aur SQL table mein kya similar hai?"* → Dono "rows x named columns"
  structure hain — concept transferable hai (isiliye `.merge()` SQL JOIN jaisa lagta hai).
- **Mistake to avoid:** DataFrame ko modify karte waqt (jaise filter karke) original ko galti se
  na-chaha overwrite kar dena — `.copy()` use karo jab zaroori ho.

### 9. Missing/null data ko kaise handle karte ho?

- **Simple answer:** Pehle dekho **kitna** missing hai aur **kyun** missing hai, phir decide
  karo — delete karna hamesha sahi option nahi hota.
- **Technical answer:** Options: (a) drop rows/columns (`.dropna()`) — jab negligible/critical
  data missing ho, (b) fill with a placeholder (`.fillna("unknown")`) — jab categorical aur
  meaningful default ho, (c) leave as-is — jab null khud ek valid business state ho (jaise
  "order deliver hi nahi hua").
- **Follow-up:** *"Is project mein teeno approach kahan use hui?"* → (a) products dimension
  missing (2 rows dropped), (b) product category missing (`"unknown"` filled), (c) order
  delivery dates missing for non-delivered orders (left as null). Dekho `docs/02`.
- **Mistake to avoid:** Blindly `.dropna()` (bina `subset` specify kiye) — poori row delete ho
  jaati hai agar kisi bhi column mein null ho, jo bahut data waste kar sakta hai.

### 10. Subquery kya hota hai?

- **Simple answer:** Ek query ke andar ek aur query — andar wali pehle evaluate hoti hai, uska
  result bahar wali query use karti hai.
- **Technical answer:** Subquery `FROM` clause mein (derived table), `WHERE`/`SELECT` clause
  mein (scalar ya correlated) use ho sakti hai.
- **Follow-up:** *"Project mein subquery ka best example?"* → AOV calculation
  (`sql/01_basic_sales_analysis.sql` Query 3) — pehle per-order total (subquery), phir uska
  average (outer query).
- **Mistake to avoid:** Direct `AVG(price)` use karna jab actually "per-order average" chahiye
  ho — line-item-level average galat result deta hai.

---

## Part 2 — Intermediate Questions

### 1. CTE (WITH) kya hai, aur subquery se better kyun?

- **Simple answer:** CTE ek "named," readable temporary result hai jo query ke start mein
  define karke aage use karte hain.
- **Technical answer:** Functionally subquery jaisa hi hai, lekin jab logic multi-step ho
  (jaise pehle aggregate, phir uspar CASE WHEN, phir uspar dobara group), CTE code ko top-se-
  neeche linear/readable banata hai instead of deeply nested subqueries.
- **Follow-up:** *"CTE performance mein subquery se fast hota hai?"* → Zaroori nahi — zyada
  engines mein dono similarly optimize hote hain; main benefit readability hai, raw performance
  nahi.
- **Mistake to avoid:** Bahut lambi CTE chain ko ek hi query mein bina comments ke likhna —
  readability ka fayda tabhi milta hai jab clearly labelled/organized ho.

### 2. Window function kya hai? Example do.

- **Simple answer:** Aggregate-jaisa hi hai, lekin rows ko squash (GROUP BY jaisa) nahi karta —
  har row apni identity rakhti hai, bas ek extra calculated column milta hai.
- **Technical answer:** `NTILE(4) OVER (ORDER BY column)` rows ko sorted order mein 4 equal-size
  buckets mein baantta hai. Project mein RFM scoring (`recency_days`, `monetary`) ke liye use
  kiya.
- **Follow-up:** *"NTILE ka koi limitation dekha project mein?"* → Haan — jab bahut saari rows
  ek hi value par "tied" hon (frequency = 1 for ~97% customers), NTILE unhe arbitrarily split
  kar deta hai. Fix: fixed `CASE WHEN` buckets use kiye frequency ke liye. (Dekho `docs/04`
  section 3, Step 2 — genuinely important, real bug jo humne khud pakड़ी.)
- **Mistake to avoid:** Window function har jagah use karna jab simple `GROUP BY` kaafi ho —
  window functions tab chahiye jab row-level identity retain karni ho.

### 3. Power BI mein Calculated Column aur Measure mein kya fark hai?

- **Simple answer:** Calculated column row-by-row compute hota hai aur table mein store hota
  hai. Measure real-time compute hota hai jab bhi filter/visual change ho.
- **Technical answer:** Column DAX row context mein evaluate hota hai (ek baar, refresh ke
  time); measure filter context mein evaluate hota hai (dynamically, visual render hone par).
- **Follow-up:** *"Project mein ek example do dono ka."* → `Delivery Status` (column — har
  order ka fixed label) vs `Total Revenue` (measure — filters ke hisab se badalta hai).
- **Mistake to avoid:** Aggregation (jaise total revenue) ko calculated column bana dena —
  slow hota hai aur filters ke saath dynamically update nahi hota jaisa measure hota hai.

### 4. RFM analysis kya hai?

- **Simple answer:** Customers ko 3 numbers (Recency, Frequency, Monetary) ke basis par
  segments mein baantne ka tarika.
- **Technical answer:** Recency = last order se kitne din ho gaye; Frequency = kitni baar order
  kiya; Monetary = total kitna spend kiya. Inhe score (e.g. quartile) karke combine kiya jaata
  hai meaningful segments (High Value, At Risk, etc.) banane ke liye.
- **Follow-up:** *"RFM ML-based clustering (K-Means) se kaise different hai?"* → RFM rule-based/
  fully-explainable hai (fixed thresholds); K-Means algorithmic hai, explainability kam hoti hai,
  aur is project ke scope ke liye unnecessarily complex hota (dekho `docs/04` Q6).
- **Mistake to avoid:** "Today" ke liye real current date use karna jab dataset historical/fixed
  ho — dataset ki khud ki latest date use karni chahiye (dekho `docs/04` section 2).

### 5. INNER JOIN aur LEFT JOIN ka fark ek example ke saath samjhao.

- **Simple answer:** INNER JOIN sirf woh rows deta hai jo dono tables mein match karti hain.
  LEFT JOIN left table ki SAARI rows deta hai, chahe match ho ya na ho (na hone par NULL).
- **Technical answer:** Project mein `products LEFT JOIN category_translation` — agar
  `INNER JOIN` use karte, toh jin products ki category translation missing thi (623 products),
  wo poori tarah result se gayab ho jaate — data silently lost ho jaata.
- **Follow-up:** *"Yeh silently data lose hona kyun dangerous hai?"* → Koi error nahi aata,
  bas kam rows return hoti hain — agar aggregate (jaise total product count) le rahe ho, galat
  (kam) number milega bina kisi warning ke.
- **Mistake to avoid:** Default mein hamesha INNER JOIN use karna — pehle socho "agar match na
  ho, toh kya wo row phir bhi chahiye?"

### 6. Data cleaning kyun important hai analysis se pehle?

- **Simple answer:** Agar data galat/inconsistent hai, toh usse nikala gaya koi bhi insight bhi
  galat hoga — "garbage in, garbage out."
- **Technical answer:** Cleaning issues typically: wrong data types (dates as text), missing
  values, duplicates, inconsistent categories — sab analysis ko silently corrupt kar sakte hain
  bina kisi obvious error ke.
- **Follow-up:** *"Ek concrete example do jahan bina cleaning ke result galat aata."* →
  Geolocation table mein 26% duplicate rows the — agar unhe drop na karte aur customers se
  directly join karte, revenue jaisi metrics multiply (fan-out) ho jaatin.
- **Mistake to avoid:** Cleaning ko "ek baar kar diya, khatam" samajhna — cleaning decisions ko
  document karna utna hi important hai jitna khud cleaning karna (taaki koi aur — ya khud tum
  6 mahine baad — samajh sako kyun wo decision liya gaya).

### 7. Duplicate data ko kaise identify aur handle karte ho?

- **Simple answer:** Do tarah ke duplicates hote hain — **exact** (poori row repeat) aur
  **logical** (same key multiple baar, values alag).
- **Technical answer:** Exact duplicates: `.duplicated().sum()` se detect, `.drop_duplicates()`
  se remove. Logical duplicates: `.duplicated(subset=["key"])` se detect — inhe handle karne
  ke liye decide karna padta hai **kaunsi row rakhni hai** (e.g. latest wali).
  waali).
- **Follow-up:** *"Project mein dono types kahan mile?"* → Exact: `geolocation` (261,831 rows).
  Logical: `order_reviews` (551 orders ki 2 review-rows).
- **Mistake to avoid:** Logical duplicates ko exact-duplicate-removal se treat karna
  (`.drop_duplicates()` bina subset ke) — kaam nahi karega kyunki rows exactly same nahi hain.

### 8. Fact table aur dimension/lookup table mein kya fark hai?

- **Simple answer:** Fact table mein "events/transactions" hote hain (jaise orders, payments).
  Dimension table mein "descriptive info" hoti hai (jaise product details, customer details).
- **Technical answer:** Fact tables typically bade hote hain, numeric/measurable columns rakhte
  hain, aur dimension tables ki keys reference karte hain. Is project mein `orders`/
  `order_items`/`order_payments`/`order_reviews` = facts; `products`/`customers`/`sellers` =
  dimensions.
- **Follow-up:** *"Power BI mein yeh distinction kyun matter karta hai?"* → Star-schema design
  (facts center mein, dimensions around) simple aur performant models banata hai — is project
  ke Power BI model mein bhi yehi pattern follow kiya gaya.
- **Mistake to avoid:** Do fact tables ko directly aapas mein relate karne ki koshish karna
  (jaise `order_items` ko `order_payments` se seedha) — dimension/common-key (`orders`) ke
  through hi jodna chahiye.

### 9. Average Order Value kaise calculate kiya, aur seedhe AVG(price) kyun nahi?

- **Simple answer:** AOV = "ek order ka average total value" — isliye pehle har ORDER ka total
  nikalna padta hai, phir uska average.
- **Technical answer:** `order_items` line-item-level hai — agar directly `AVG(price)` karte,
  toh multi-item orders ke items multiple baar average mein count ho jaate (galat weighting).
  Subquery/CTE se pehle `GROUP BY order_id` karke per-order total banaya, phir uska AVG liya.
- **Follow-up:** *"Yeh mistake production mein kitni common hai?"* → Bahut common hai — "grain
  mismatch" (kis level par ek row hai, aur us level se different level ka average nikalne ki
  koshish) DA beginners ki sabse frequent galtiyon mein se ek hai.
- **Mistake to avoid:** Kisi bhi average nikalne se pehle yeh confirm mat karna "table ka grain
  kya hai" (ek row kisko represent karti hai).

### 10. Correlation aur causation mein kya fark hai — project mein kahan relevant hai?

- **Simple answer:** Correlation ka matlab hai do cheezein saath change hoti hain. Causation ka
  matlab hai ek cheez doosri ko **directly cause** karti hai.
- **Technical answer:** Late delivery aur low rating ka strong association mila (Insight 1,
  `docs/07`) — yeh evidence-based association hai, lekin poori tarah "prove" nahi karta ki
  SIRF delay hi wajah hai (koi aur confounding factor bhi ho sakta hai).
- **Follow-up:** *"Toh kya insight useless hai agar causation confirm nahi hai?"* → Nahi —
  strong, large-sample correlation bhi business action ke liye kaafi actionable hoti hai; sirf
  language mein "correlation/relationship" bolna chahiye, "guaranteed cause" nahi.
- **Mistake to avoid:** Kisi bhi correlation ko seedhe "X ne Y cause kiya" bol dena bina
  qualification ke — interview mein yeh nuance dikhana **maturity ka signal** hai.

---

## Part 3 — Project-Specific Questions

### 1. Tumne Olist dataset hi kyun choose kiya?

- **Simple answer:** Yeh ek real, publicly-available, rich e-commerce dataset hai jisme sales,
  customers, delivery, aur reviews — sab kuch ek saath hai.
- **Technical answer:** ~100k orders, 9 relational tables, real business messiness (nulls,
  duplicates, inconsistent categories) — jo genuinely realistic data-cleaning aur analysis
  practice deta hai, fake/synthetic data se better.
- **Follow-up:** *"Koi alternative dataset consider kiya tha?"* → UCI "Online Retail" dataset
  bhi ek option tha, lekin usme delivery dates aur review scores nahi hain — jo delivery aur
  satisfaction analysis (do required business areas) ke liye Olist ko better banata hai.
- **Mistake to avoid:** "Kyunki tutorial mein use hua tha" jaisa weak reason mat do — data
  richness/business-relevance ka concrete reason do.

### 2. Apna data cleaning process walk-through karo.

- **Simple answer:** Pehle inspect kiya (nulls, duplicates, dtypes), phir har table ke liye
  specific issues fix kiye — bina blindly delete kiye.
- **Technical answer:** Reference `docs/02_data_cleaning.md` — date conversions, zip zero-
  padding, category-null filling, duplicate-review removal, geolocation de-duplication +
  aggregation, aur ek verified revenue-definition decision.
- **Follow-up:** *"Sabse tricky cleaning decision kaunsa tha?"* → Geolocation ka "many rows per
  zip" grain — usse "1 row per zip" banane ke liye aggregate (mean lat/lng, mode city) karna
  pada, taaki future joins fan-out na karein.
- **Mistake to avoid:** Cleaning ko "sirf `.dropna()` chala do" jaisa oversimplify mat karo —
  interviewer turant follow-up karega "kaunse specific issues the, kya reasoning thi."

### 3. `customer_id` ki jagah `customer_unique_id` kyun use kiya?

- **Simple answer:** `customer_id` har order ke liye naya banta hai (order-level), jabki
  `customer_unique_id` hi real insaan ko identify karta hai.
- **Technical answer:** Verified: `customer_id` unique count = 99,441 (= total orders), lekin
  `customer_unique_id` unique count = 96,096 — fark hi confirm karta hai kuch log repeat
  karte hain, jo sirf `customer_unique_id` se hi track ho sakta hai.
- **Follow-up:** *"Agar galti se customer_id use karte toh kya result aata?"* → "0% repeat
  customers" — completely galat conclusion, jabki actual rate 3% hai.
- **Mistake to avoid:** Kisi bhi naye dataset mein har "id"-jaisi column ko without-verification
  "the" unique key maan lena.

### 4. Is project mein "revenue" exactly kaise define/calculate kiya?

- **Simple answer:** `order_items.price + order_items.freight_value`, sirf `delivered` orders
  ke liye.
- **Technical answer:** Verify kiya ki yeh `order_payments.payment_value` ke bahut close hai
  (0.017% difference, delivered orders par) — dono reliable hain, `order_items` isliye chuna
  kyunki line-item-level hai (category-breakdown seedha milta hai) aur `order_payments` mein
  per-order multiple/edge-case rows hoti hain.
- **Follow-up:** *"Agar tumne yeh cross-check nahi kiya hota, kya risk tha?"* → Do alag jagah
  do alag revenue numbers report ho jaate — internal inconsistency, jo kisi report ki
  credibility ko nuksaan pahunchata hai.
- **Mistake to avoid:** Ek hi project ke andar revenue ke liye kabhi ek source, kabhi doosra
  use karna — consistency documented aur enforced honi chahiye.

### 5. Revenue/delivery/satisfaction analysis ko sirf `delivered` orders tak kyun scope kiya?

- **Simple answer:** Canceled/unavailable orders mein actual transaction complete nahi hua —
  unhe include karna numbers ko misleading bana deta.
- **Technical answer:** `order_status` breakdown verify kiya (96,478 delivered out of 99,441,
  97%) — baaki statuses (`canceled`, `unavailable`, etc.) mein delivery dates bhi null hoti
  hain, isliye delivery-analysis mein wo naturally exclude ho jaate.
- **Follow-up:** *"Total 'orders placed' count karte waqt bhi yehi filter lagaya?"* → Nahi — wo
  metric jaan-boojh kar sabhi statuses include karta hai, kyunki "kitne orders place hue" aur
  "kitna revenue bana" alag questions hain.
- **Mistake to avoid:** Ek hi blanket filter (jaise "sirf delivered") har metric par bina soche
  apply karna — har metric ka apna correct scope decide karna chahiye.

### 6. Apni RFM segmentation logic explain karo.

- **Simple answer:** Recency, Frequency, Monetary — teeno ko score (1-4) diya, phir CASE WHEN
  se 5 segments banaye.
- **Technical answer:** Recency/Monetary ke liye `NTILE(4)` window function; Frequency ke liye
  fixed `CASE WHEN` buckets (kyunki NTILE tied-data ke saath meaningfully kaam nahi karta thا —
  dekho `docs/04` section 3). Segment priority order: High Value → Loyal → At Risk → Recent →
  Low Engagement.
- **Follow-up:** *"Tumne is logic mein koi bug pakड़ा tha?"* → Haan — pehli baar `recency_days
  ASC` likha tha jo directionally ulta tha (stale customers ko best score de raha tha) — fix
  kiya `DESC` karke. Genuinely real bug jo verify karte waqt mila.
- **Mistake to avoid:** RFM scores ki direction (high = good ya bad) bina explicitly verify
  kiye assume kar lena — hamesha ek sample row manually trace karke confirm karo.

### 7. Is project mein sabse tricky bug/issue kya tha?

- **Simple answer:** Do bade issues the: RFM recency-scoring direction bug, aur SQLite joins
  bina index ke bahut slow ho jaana.
- **Technical answer:** (1) `pandas.to_sql()` se banayi gayi tables mein koi index/primary-key
  nahi hota by default — text-column joins (`order_id`, `customer_id`) full-table-scan nested
  loop bana dete hain, jo ~100k rows par "hang" jaisa dikhta hai. Fix: explicit `CREATE INDEX`
  har join column par. (2) RFM recency scoring directionally ulta tha — verify karke fix kiya.
- **Follow-up:** *"Aage se aise issues kaise avoid karoge?"* → Koi bhi naya DB banate waqt turant
  indexes add karna (proactively, na ki jab query slow lage tab), aur koi bhi scoring/ranking
  logic likhne ke baad ek chhota sample manually trace/verify karna.
- **Mistake to avoid:** Assume karna ki "SQL query sahi hai kyunki koi error nahi aaya" —
  logically-wrong-but-error-free queries (jaisa RFM direction bug) sabse dangerous hoti hain
  kyunki silently galat result dete hain.

### 8. SQLite kyun use kiya, MySQL/PostgreSQL/SQL Server kyun nahi?

- **Simple answer:** SQLite ek file-based database hai — koi server install/setup nahi chahiye,
  bas ek `.db` file hoti hai.
- **Technical answer:** Is project ke scope ke liye (single-user, portfolio/learning project,
  ~100k rows), SQLite kaafi hai aur zero-setup deploy/share karne mein sabse aasan hai (repo
  mein directly commit ho sakti hai ya script se rebuild ho sakti hai). Production
  multi-user systems ke liye PostgreSQL/MySQL jaisa client-server DB zyada appropriate hota.
- **Follow-up:** *"SQLite ki limitation kya hai jo tumne face ki?"* → Concurrent writes achhi
  tarah handle nahi karta, aur by-default koi index nahi banata (dekho Q7) — dono is project
  ke scale par manageable the.
- **Mistake to avoid:** "SQLite hi sabse best database hai" bol dena — yeh ek **scope-appropriate
  choice** tha, universal best-choice nahi.

### 9. Power BI data model kaise banaya, aur ek alag `category_performance` table kyun hai?

- **Simple answer:** Cleaned CSVs import kiye, unke beech relationships banayi. Ek extra table
  banayi kyunki category+revenue+rating ek saath dikhane ke liye 3-hop relationship chain
  chahiye thi, jo complex ho jaati.
- **Technical answer:** `products → order_items → orders → order_reviews` chain mein filter
  flow karne ke liye ek relationship ko bidirectional karna padta — beginner-model mein
  ambiguity ka risk. Isliye yeh ek specific cross-cutting metric Python mein precompute karke
  standalone table ki tarah import kiya. (Dekho `docs/06` section 1.)
- **Follow-up:** *"Yeh 'best practice' hai ya 'workaround'?"* → Dono — real BI projects mein
  precomputed/denormalized summary tables ek legitimate, common pattern hain jab live
  relationships unnecessarily complex ho jaayein.
- **Mistake to avoid:** Har cross-table metric ke liye bidirectional relationships laga dena
  "quick fix" ki tarah — isse model mein ambiguous filter paths ban sakte hain jo debug karna
  mushkil hota hai.

### 10. Agar zyada time milta, kya improve karte?

- **Simple answer:** Ek proper Date table Power BI mein add karta (time-intelligence ke liye),
  aur review text par basic sentiment analysis explore karta.
- **Technical answer:** README ke "Future Improvements" section mein listed: ML-based
  segmentation, NLP/sentiment on review text, demand forecasting, dedicated Date dimension
  table, automated data-refresh pipeline.
- **Follow-up:** *"Yeh cheezein abhi kyun nahi ki?"* → Project ka goal tha "beginner-defensible,
  interview-safe, har part explainable" — inn advanced additions se scope/complexity badhta,
  aur is project ke stated goal (SQL/Python/PowerBI fundamentals demonstrate karna) se door
  le jaata.
- **Mistake to avoid:** "Maine sab kuch kar diya, koi limitation nahi" bolna — har achha
  candidate apne project ki honest limitations bata sakta hai, yeh red flag nahi, maturity ka
  signal hai.
