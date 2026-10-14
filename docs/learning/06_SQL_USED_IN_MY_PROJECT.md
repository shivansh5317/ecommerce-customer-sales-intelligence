# 06 — SQL Used In My Project

> Yeh file poore project ki **har SQL query** ko is format mein todती hai: **Business question
> → Why it matters → Query → Breakdown → Result → Why the logic is correct → Edge cases →
> Alternative approach → Interview questions.** Database: `data/ecommerce.db` (SQLite). Khud
> try karne ke liye: `python scripts/run_sql.py sql/01_basic_sales_analysis.sql` (ya koi bhi
> file). Concepts ka intro [05_SQL_FROM_ZERO.md](05_SQL_FROM_ZERO.md) mein hai — yahan hum
> unhi concepts ko **real queries** mein dekhte hain.

**Scope rule jo poori file mein baar-baar dikhega:** Revenue/AOV/delivery/satisfaction queries
sirf `order_status = 'delivered'` orders par based hain, kyunki canceled/unavailable orders
mein real transaction complete nahi hua (poora reasoning:
[09_DATA_CLEANING.md](09_DATA_CLEANING.md)).

---

# File: `sql/01_basic_sales_analysis.sql` — Sales Performance

## Query 1.1 — Total Revenue

- **Business question:** Company ka total revenue kitna hai?
- **Why it matters:** Yeh sabse basic, sabse zyada poocha jaane wala business number hai — har
  aur cheez isse compare hoti hai.
- **Query:**
  ```sql
  SELECT
      ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered';
  ```
- **Breakdown:**
  - `FROM order_items oi` — line-item level data se start (har product jo bika, ek row).
  - `JOIN orders o ON o.order_id = oi.order_id` — order ka status pata karne ke liye
    (`order_items` mein status column hi nahi hai).
  - `WHERE o.order_status = 'delivered'` — sirf complete hui orders.
  - `SUM(oi.price + oi.freight_value)` — product price + shipping, sab jodkar total.
  - `ROUND(..., 2)` — currency ke liye 2 decimal places standard hai.
- **Result:** `total_revenue = R$ 15,419,773.75`
- **Why the logic is correct:** Revenue = jo customer ne actually product + shipping ke liye
  pay kiya, sirf un orders ke liye jo successfully complete hue. Cross-verified against
  `order_payments.payment_value` — sirf 0.017% difference (dekho
  [09_DATA_CLEANING.md](09_DATA_CLEANING.md)).
- **Edge cases:** Agar `freight_value` NULL hota kisi row mein, `SUM` use silently ignore kar
  deta (SQL mein NULL + number = NULL, lekin `SUM` NULLs ko skip karta hai) — is dataset mein
  yeh column kabhi null nahi tha, isliye issue nahi aaya, par yeh general SQL behavior yaad
  rakhna important hai.
- **Alternative approach:** `order_payments.payment_value` ko primary source bana sakte the —
  lekin `order_items` line-item level hai (category breakdown seedha milta hai), isliye better
  choice tha.
- **Interview questions:**
  - *"SUM() aur COUNT() mein kya fark hai?"* → `SUM` values add karta hai, `COUNT` rows ginta hai.
  - *"Agar WHERE clause hata do toh?"* → Sabhi order statuses include ho jayenge, revenue galat
    tarike se zyada dikhega.

## Query 1.2 — Total Orders Placed vs Delivered

- **Business question:** Kitne orders place hue, aur unme se kitne successfully deliver hue?
- **Why it matters:** "Orders placed" (demand/interest) aur "orders delivered" (successful
  fulfillment) alag business metrics hain — dono ka apna importance hai.
- **Query:**
  ```sql
  SELECT
      COUNT(*) AS total_orders_all_status,
      SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders
  FROM orders;
  ```
- **Breakdown:**
  - `COUNT(*)` — `orders` table ki total rows (kisi bhi status ke).
  - `CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END` — har row 1 ya 0.
  - `SUM(...)` — un 1's ko jodkar delivered-count. Yeh **"CASE WHEN + SUM = conditional COUNT"**
    trick hai.
- **Result:** `total_orders_all_status = 99,441` · `delivered_orders = 96,478` (97.0%)
- **Why the logic is correct:** Ek hi query mein dono numbers ek saath, bina 2 alag queries ke.
- **Edge cases:** Agar `order_status` column mein koi unexpected/new status value aa jaaye
  (jaise typo), wo automatically `0` count hoga is CASE mein (silently), na ki error — isliye
  periodically `value_counts()`/`GROUP BY order_status` se saare distinct statuses check karna
  achha practice hai.
- **Alternative approach:** `COUNT(CASE WHEN order_status='delivered' THEN 1 END)` bhi same
  result deta (COUNT NULL ko ignore karta hai, non-matching rows ke liye CASE NULL return karega
  agar ELSE na ho) — dono valid, `SUM` wala pattern zyada commonly sikhaya jaata hai.
- **Interview questions:**
  - *"COUNT(column) aur COUNT(*) mein fark?"* → `COUNT(*)` saari rows; `COUNT(column)` sirf
    non-null rows us column ke.
  - *"Yeh pattern kab use karte ho?"* → Jab ek hi query mein multiple conditional counts chahiye.

## Query 1.3 — Average Order Value (AOV)

- **Business question:** Average order value (AOV) kya hai?
- **Why it matters:** Pricing/bundling strategy ke liye baseline number.
- **Query:**
  ```sql
  SELECT
      ROUND(AVG(order_total), 2) AS average_order_value
  FROM (
      SELECT
          oi.order_id,
          SUM(oi.price + oi.freight_value) AS order_total
      FROM order_items oi
      JOIN orders o ON o.order_id = oi.order_id
      WHERE o.order_status = 'delivered'
      GROUP BY oi.order_id
  ) order_totals;
  ```
- **Breakdown:** Inner query pehle **har order ka apna total** nikalta hai (`GROUP BY
  oi.order_id`). Outer query us result ko table ki tarah treat karke `AVG()` leता hai.
- **Result:** `average_order_value = R$ 159.83`
- **Why the logic is correct (yeh sabse important concept hai is query ka):** Agar directly
  `AVG(oi.price + oi.freight_value)` karte (bina subquery), yeh **per line-item average** milta,
  per-**order** average nahi — agar ek order mein 3 products hain, wo 3 baar count ho jaate
  average mein, jo galat weighting hai. Subquery pehle order-level total banata hai, tabhi AOV
  sahi aata hai.
- **Edge cases:** Agar koi order `order_items` mein bilkul nahi (jaise 775 orders jinke zero
  line-items hain), wo is calculation mein naturally exclude ho jaayenge (kyunki `FROM
  order_items` se start ho rahe hain) — yeh sahi hai, kyunki unka koi revenue hai hi nahi.
- **Alternative approach:** CTE (`WITH order_totals AS (...)`) se bhi bilkul same result milega
  — functionally identical, bas syntax style alag.
- **Interview questions:**
  - *"AOV directly `AVG(price)` se kyun nahi nikala?"* → Upar wala explanation. **Yeh ek bahut
    common interview trap hai — dekho [28_COMMON_MISTAKES.md](28_COMMON_MISTAKES.md).**
  - *"Subquery aur CTE mein fark?"* → Functionally same; CTE zyada readable multi-step logic ke
    liye.

## Query 1.4 — Monthly Revenue Trend

- **Business question:** Revenue time ke saath kaise change hua?
- **Why it matters:** Growth aur seasonality dikhata hai — planning/forecasting ke liye base.
- **Query:**
  ```sql
  SELECT
      strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
      ROUND(SUM(oi.price + oi.freight_value), 2) AS monthly_revenue,
      COUNT(DISTINCT oi.order_id) AS orders_count
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY order_month
  ORDER BY order_month;
  ```
- **Breakdown:** `strftime('%Y-%m', ...)` poori timestamp se sirf `"2017-10"` nikalta hai.
  `GROUP BY order_month` sab orders ko month ke hisab se group karta hai. `COUNT(DISTINCT
  oi.order_id)` zaroori hai kyunki `order_items` mein ek order ki multiple rows ho sakti hain.
- **Result:** 23 months, Sep 2016 (₹143) se shuru, gradually badhte hue Nov 2017 (₹11,53,364 —
  saal ka sabse high month) tak, phir 2018 mein stable ₹9-11 lakh/month range.
- **Why the logic is correct:** Time-series trend dikhane ka standard tarika — month-level
  granularity business planning ke liye kaafi hai (day-level bahut noisy hota, year-level
  bahut coarse).
- **Edge cases:** ⚠️ Sep-Oct 2018 revenue bahut kam dikhega — yeh **data-collection cutoff
  artifact** hai (in months ke orders ko abhi "delivered" status milne ka time nahi mila), na
  ki real business decline. Kisi bhi time-series ka **last 1-2 period** hamesha suspect samjho.
- **Alternative approach:** `strftime('%Y', ...)` se year-level granularity mil sakti thi, lekin
  seasonal pattern (Nov spike) miss ho jaata.
- **Interview questions:**
  - *"Time series trend ke liye kya use kiya?"* → `strftime` se month extract karke `GROUP BY`.
  - *"Ek spike/dip dekh kar seedhe conclusion nikal sakte ho?"* → Nahi — pehle check karo data
    collection period complete hai ya nahi.

## Query 1.5 — Top 10 Categories by Revenue

- **Business question:** Kaunsi product categories sabse zyada revenue generate karti hain?
- **Why it matters:** Inventory/marketing priority decide karne ke liye.
- **Query:**
  ```sql
  SELECT
      p.product_category_name_english AS category,
      ROUND(SUM(oi.price + oi.freight_value), 2) AS category_revenue,
      COUNT(DISTINCT oi.order_id) AS orders_count
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  JOIN products p ON p.product_id = oi.product_id
  WHERE o.order_status = 'delivered'
  GROUP BY category
  ORDER BY category_revenue DESC
  LIMIT 10;
  ```
- **Breakdown:** 3-table JOIN (`order_items` → `orders` for status, → `products` for category),
  category-wise group, revenue descending sort, top 10.
- **Result (top 5):** `health_beauty` (R$14,12,089) → `watches_gifts` (R$12,64,333) →
  `bed_bath_table` (R$12,25,209) → `sports_leisure` (R$11,18,257) → `computers_accessories`
  (R$10,32,724).
- **Why the logic is correct:** LIMIT 10 ke pehle ORDER BY zaroori hai (dekho file 05) — warna
  "top 10" ka koi guarantee nahi.
- **Edge cases:** Products jinki category `"unknown"` hai (missing translation) apna alag bucket
  ban jaate hain — yeh sahi hai (honest labeling), lekin isse "unknown" bhi ek "category" ki
  tarah rank ho sakta hai agar uska revenue kaafi ho. Verify karna chahiye ki wo top-10 mein na
  aaye (is dataset mein nahi aata).
- **Alternative approach:** `product_category_name` (Portuguese) par bhi group kar sakte the,
  lekin English naam readability/presentation ke liye better hai.
- **Interview questions:**
  - *"3-table join likhne ka tarika?"* → Ek common key se shuru karo, phir ek-ek related table jodo.
  - *"GROUP BY mein alias (`category`) use kar sakte ho?"* → SQLite/MySQL mein haan; standard
    SQL/Postgres mein kabhi poora expression dobara likhna padta hai.

## Query 1.6 — Top 10 Categories by Order Volume

- **Business question:** Kaunsi categories sabse zyada orders generate karti hain (volume)?
- **Why it matters:** Volume aur revenue leaders alag ho sakte hain — dono jaanna zaroori.
- **Query:** Same as 1.5, bas `ORDER BY orders_count DESC` (revenue column hata diya focus se).
- **Result (top 5):** `bed_bath_table` (9,272 orders) → `health_beauty` (8,647) →
  `sports_leisure` (7,530) → `computers_accessories` (6,530) → `furniture_decor` (6,307).
- **Why the logic is correct:** Same JOIN/GROUP BY logic, sirf sort column badla — yeh dikhata
  hai ki ek hi underlying data se **different business lenses** (revenue vs volume) nikal
  sakte ho.
- **Edge cases:** None beyond Query 1.5's.
- **Alternative approach:** Dono metrics (revenue aur orders_count) ek hi query mein nikal ke,
  do alag `ORDER BY`/`LIMIT` se do results dikhana bhi ho sakta tha — is project mein clarity
  ke liye 2 alag queries rakhi gayi.
- **Interview questions:**
  - *"Revenue aur order-volume ranking alag kyun aate hain?"* → Har category ka average
    price/order alag hota hai — high-volume zaroori nahi high-revenue ho
    (`bed_bath_table` ≈ R$132/order vs `health_beauty` ≈ R$163/order).

---

# File: `sql/02_customer_analysis.sql` — Customer Behavior

**Foundational rule (poori file mein):** `customers.customer_unique_id` use karte hain, NOT
`customer_id` (dekho file 03 ka gotcha).

## Query 2.1 — Total Unique Customers

- **Business question:** Kitne unique customers hain?
- **Query:** `SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers FROM customers;`
- **Result:** `96,096` unique customers.
- **Why the logic is correct:** `DISTINCT` duplicate real-people ko ek baar hi ginta hai.
- **Edge cases:** Agar `customer_unique_id` mein koi NULL hota, `COUNT(DISTINCT ...)` use
  automatically exclude kar deta — is table mein koi null nahi hai.
- **Interview questions:** *"Agar `customer_id` use karte toh?"* → 99,441 (galat) aata.

## Query 2.2 — Repeat vs One-Time Customers

- **Business question:** Kitne customers repeat purchase karte hain vs sirf ek baar?
- **Query:**
  ```sql
  WITH customer_orders AS (
      SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS orders_count
      FROM customers c
      JOIN orders o ON o.customer_id = c.customer_id
      WHERE o.order_status = 'delivered'
      GROUP BY c.customer_unique_id
  )
  SELECT
      CASE WHEN orders_count = 1 THEN 'one_time_customer' ELSE 'repeat_customer' END AS customer_type,
      COUNT(*) AS customers_count
  FROM customer_orders
  GROUP BY customer_type;
  ```
- **Breakdown:** CTE `customer_orders` — har real customer ka apna orders_count (step 1). Outer
  query — us par `CASE WHEN` laga kar 2 buckets, phir dobara `GROUP BY` (customer_type par) —
  yeh **"group on top of a group"** pattern hai.
- **Result:** `one_time_customer = 90,557` · `repeat_customer = 2,801`
- **Why the logic is correct:** Har customer ka orders_count sirf ek baar count hota hai (CTE
  mein hi group ho chuka), phir type-level dobara group hota hai — koi double counting nahi.
- **Edge cases:** Customer jinka koi delivered order nahi hai (sirf canceled orders), wo is CTE
  mein bilkul appear nahi karenge (kyunki `WHERE order_status='delivered'` pehle hi filter kar
  deta hai) — yeh business-question ke hisab se sahi hai ("kitne delivered-repeat customers").
- **Alternative approach:** Subquery se bhi likh sakte the — CTE zyada readable hai jab logic
  multi-step ho.
- **Interview questions:** *"CTE kyun, subquery kyun nahi?"* → Readability, jab multi-step
  logic ho.

## Query 2.3 — Percentage of Repeat Customers

- **Business question:** Repeat customers ka exact % kya hai?
- **Query (same CTE):** `ROUND(100.0 * SUM(CASE WHEN orders_count > 1 THEN 1 ELSE 0 END) / COUNT(*), 2)`
- **Breakdown:** `100.0 *` mein `.0` important hai — integer division se bachne ke liye
  (agar `100 *` likhte, kuch SQL engines integer division kar sakte, decimal precision khokar).
- **Result:** `3.0%` repeat customers.
- **Why the logic is correct:** Numerator (repeat count) ÷ denominator (total count) ×100 —
  standard percentage formula, float-safe.
- **Edge cases:** Agar `COUNT(*)` kabhi `0` ho (empty table), yeh divide-by-zero error dega —
  SQL mein (unlike DAX's `DIVIDE()`) koi automatic safe-guard nahi hai; is dataset mein table
  kabhi empty nahi hai isliye issue nahi aaya, lekin production code mein isko handle karna
  chahiye.
- **Interview questions:** *"Integer vs float division ka bug kaise avoid karte ho?"* → Ek
  operand ko explicitly decimal likho (`100.0` instead of `100`).

## Query 2.4 — Top 10 Highest-Value Customers

- **Business question:** Sabse zyada value wale customers kaun hain?
- **Query:** 3-table JOIN (`customers` → `orders` → `order_items`) + `GROUP BY
  customer_unique_id` + `ORDER BY total_spend DESC LIMIT 10`.
- **Result (top 3):** R$13,664 (1 order) · R$7,572 (2 orders) · R$7,275 (1 order).
- **Why the logic is correct:** Same "aggregate per real-person" pattern.
- **Edge cases:** Top customer ne sirf **1 order** mein itna spend kiya — matlab "highest value"
  ≠ "most loyal." Agar business sirf yeh number dekhe bina context ke, galat assume kar sakta
  hai ki yeh ek "loyal" customer hai.
- **Interview questions:** *"Highest spender hamesha best customer hota hai?"* → Zaroori nahi —
  ek-baar ka bada purchase vs consistent repeat purchase, business value alag.

## Query 2.5 — Customer Order-Frequency Distribution

- **Business question:** Order-frequency ka overall distribution kaisa hai?
- **Query:** Same CTE + `CASE WHEN` buckets (`1 order`/`2 orders`/`3-5 orders`/`6+ orders`).
- **Result:** `1` → 90,557 · `2` → 2,573 · `3-5` → 218 · `6+` → 10.
- **Why the logic is correct:** `BETWEEN 3 AND 5` inclusive hota hai dono ends par — koi gap
  ya overlap nahi banti buckets ke beech.
- **Edge cases:** Bucket boundaries ko double-check karo overlap na ho (`= 2` phir `BETWEEN 3
  AND 5` — koi customer dono mein nahi aa sakta, sahi hai).
- **Interview questions:** *"CASE WHEN mein range kaise likhte ho?"* → `WHEN col BETWEEN x AND
  y THEN ...`.

## Query 2.6 — Average Spend per Customer

- **Business question:** Ek customer se (lifetime) average kitna revenue aata hai?
- **Result:** `R$ 165.17`
- **Why the logic is correct:** AOV (R$159.83) se thoda zyada — matlab kuch customers multiple
  orders karte hain jo unka total lifetime value AOV se upar le jaata hai.
- **Interview questions:** *"Yeh AOV se different kyun hai?"* → AOV = per-ORDER average;
  yeh = per-CUSTOMER average (jo multiple orders wale customers ke liye zyada ho sakta hai).

---

# File: `sql/03_product_analysis.sql` — Product / Category Performance

## Query 3.1 — Top 10 Individual Products by Revenue

- **Business question:** Sabse zyada revenue wale individual products kaunse hain (category
  nahi, specific products)?
- **Query:** `GROUP BY oi.product_id, category` (product-level, category-level nahi).
- **Result (top 3):** `bb50f2e2...` (health_beauty, R$67,258, 186 orders) ·
  `d1c42706...` (computers_accessories, R$58,957, 313 orders) · `6cdd5384...`
  (health_beauty, R$57,934, 148 orders).
- **Why the logic is correct:** Product-level finding category-level finding (Query 1.5) ke
  saath consistent hai — health_beauty products yahan bhi top pe.
- **Edge cases:** Agar do products ka naam same ho (par `product_id` alag), wo galti se merge
  nahi honge kyunki humne `product_id` (unique) par group kiya, naam par nahi.

## Query 3.2 — High Volume but Relatively Low Revenue-per-Order Categories

- **Business question:** Kaunsi categories mein orders bahut aate hain lekin per-order revenue
  kam hai?
- **Query:**
  ```sql
  SELECT
      p.product_category_name_english AS category,
      COUNT(DISTINCT oi.order_id) AS orders_count,
      ROUND(SUM(oi.price + oi.freight_value), 2) AS category_revenue,
      ROUND(SUM(oi.price + oi.freight_value) * 1.0 / COUNT(DISTINCT oi.order_id), 2) AS avg_revenue_per_order
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  JOIN products p ON p.product_id = oi.product_id
  WHERE o.order_status = 'delivered'
  GROUP BY category
  HAVING orders_count >= 100
  ORDER BY avg_revenue_per_order ASC
  LIMIT 10;
  ```
- **Breakdown — `HAVING` (naya concept yahan):** `WHERE` raw rows filter karta hai (GROUP BY se
  pehle). `HAVING` grouped/aggregated results filter karta hai (GROUP BY ke baad). Yahan
  `orders_count >= 100` ek **aggregate result** (`COUNT DISTINCT`) par condition hai — `WHERE`
  mein nahi likh sakte (WHERE ko "orders_count" naam ka koi cheez pata hi nahi hota tab tak jab
  tak GROUP BY complete na ho).
- **Result (top 5, lowest avg_revenue_per_order):** `electronics` (R$79.75/order, 2,517 orders)
  · `food` (R$81.17) · `food_drink` (R$87.50) · `books_technical` (R$89.46) · `telephony`
  (R$92.65, 4,093 orders — highest volume in this list).
- **Why the logic is correct:** `HAVING orders_count >= 100` filter isliye lagaya taaki sirf
  **statistically meaningful** categories dikhein — 2-3 orders wali category ka "average"
  bahut noisy hoga.
- **Edge cases:** Agar `orders_count >= 100` threshold hata dete, chhote/niche categories
  (jaise 3-4 orders wali) apna "avg_revenue_per_order" extreme values ke saath top mein aa
  sakti thi — misleading.
- **Alternative approach:** Threshold ko 50 ya 200 bhi rakh sakte the — 100 ek reasonable middle
  ground hai is dataset ke scale (~100k orders, ~70 categories) ke liye.
- **Interview questions:**
  - *"WHERE aur HAVING mein exact fark?"* → **Very common interview question** — WHERE row-level
    (before GROUP BY), HAVING group-level (after GROUP BY).
  - *"WHERE mein aggregate function use kar sakte ho?"* → Nahi, isliye HAVING chahiye.

## Query 3.3 — Categories with Poorest Ratings

- **Business question:** Kaunsi categories ki ratings sabse kharab hain?
- **Query:** `JOIN order_reviews` + `HAVING reviews_count >= 30` (sample-size filter).
- **Result (worst 5):** `office_furniture` (avg 3.49★, 1,263 reviews) ·
  `fashion_male_clothing` (3.64★) · `fixed_telephony` (3.68★) · `fashio_female_clothing`
  (3.75★) · `party_supplies` (3.77★).
- **Why the logic is correct:** `office_furniture` sabse consistent-poor rating wali category
  **aur** sample size bhi bada hai (1,263 reviews) — isliye yeh sirf noise nahi, genuine
  pattern.
- **Edge cases:** Bina `HAVING reviews_count >= 30` ke, koi 2-review category ka average
  (jaise dono 1★) top-5 "worst" mein aa sakti thi, jabki wo statistically meaningless hoti.
- **Interview questions:** *"Rating ka average lete waqt sample size kyun matter karta hai?"*
  → Chhota sample bahut easily skew ho sakta hai ek extreme rating se.

## Query 3.4 — Category-wise Average Price

- **Business question:** Har category ka average selling price kya hai?
- **Result (top 3):** `computers` (R$1,098.34) · `small_appliances_home_oven_and_coffee`
  (R$624.29) · `home_appliances_2` (R$476.12).
- **Why the logic is correct:** Simple `AVG(price)` yahan sahi hai kyunki hume "per-item price"
  chahiye, "per-order total" nahi (yeh AOV wali grain-mismatch situation nahi hai — dekho file 12).
- **Interview questions:** *"Yahan `AVG(price)` seedha use kiya, AOV mein subquery kyun chahiye
  thi?"* → Yahan hume line-item-level average chahiye (per product price), waha order-level
  chahiye tha — dono alag business questions, alag grain.

## Query 3.5 — Categories with the Widest Product Variety

- **Business question:** Kaunsi categories mein sabse zyada distinct products hain (catalog depth)?
- **Query:** `COUNT(DISTINCT p.product_id)` grouped by category, from `products` table alone
  (no orders/sales involved).
- **Why the logic is correct:** Yeh "catalog breadth" hai, sales se independent metric.

---

# File: `sql/04_regional_analysis.sql` — Geography / Regional Performance

## Query 4.1 — Revenue by State (Top 10)

- **Business question:** Kaunse states sabse zyada revenue dete hain?
- **Query:** `order_items → orders → customers`, `GROUP BY customer_state`.
- **Why the logic is correct:** `customers` table se `customer_state` liya (order ka shipping
  state), na ki `sellers` se — revenue geography **demand-side** (kahan bik raha hai) dikhata
  hai, supply-side nahi.

## Query 4.2 — Average Order Value by State (states with ≥ 50 orders)

- **Business question:** Kis state mein average order value zyada hai?
- **Query:** CTE se pehle order-level total (state ke saath), phir state-wise `AVG`, `HAVING
  orders_count >= 50`.
- **Result (top 5):** PB, AC, AP, AL, RO — sab R$220-267 range mein, sab remote North/North-East
  states.
- **Why the logic is correct (par careful interpretation zaroori):** Yeh remote states
  isliye high hain kyunki `freight_value` (jo humare revenue formula mein shamil hai) remote
  areas mein zyada hota hai — yeh "customers zyada expensive products kharidte hain" nahi
  matlab, balki "shipping costly hai" matlab. Dekho
  [17_BUSINESS_INSIGHTS.md](17_BUSINESS_INSIGHTS.md) Insight 8 — **important
  don't-over-interpret lesson.**
- **Edge cases:** `HAVING orders_count >= 50` na hota toh koi 2-3-order-wala tiny state ek
  freak-high AOV dikha sakta tha.

## Query 4.3 — Top 5 States by Number of Unique Customers

- **Business question:** Kis state mein sabse zyada unique customers hain?
- **Query:** Simple `GROUP BY customer_state` + `COUNT(DISTINCT customer_unique_id)`.

## Query 4.4 — Revenue Concentration (% of Total)

- **Business question:** Har state ka total revenue mein % share kya hai?
- **Query:**
  ```sql
  SELECT
      c.customer_state AS state,
      ROUND(SUM(oi.price + oi.freight_value), 2) AS state_revenue,
      ROUND(100.0 * SUM(oi.price + oi.freight_value) / (
          SELECT SUM(oi2.price + oi2.freight_value)
          FROM order_items oi2
          JOIN orders o2 ON o2.order_id = oi2.order_id
          WHERE o2.order_status = 'delivered'
      ), 2) AS pct_of_total_revenue
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  JOIN customers c ON c.customer_id = o.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY state
  ORDER BY state_revenue DESC
  LIMIT 5;
  ```
- **Breakdown — Scalar Subquery (naya concept):** Yeh subquery `SELECT SUM(...)` **ek hi
  number** return karti hai (poora company-wide total revenue) — isse "scalar subquery" kehte
  hain (matlab ek single value, ek table nahi). Yeh har row ke liye denominator ki tarah use
  hoti hai.
- **Result:** SP: R$57.7L (37.42%) · RJ: R$20.6L (13.33%) · MG: R$18.2L (11.80%).
- **Why the logic is correct:** State revenue ÷ company-wide total = share. Scalar subquery
  ek fixed number hai (same for every row), isliye ratio meaningful hai.
- **Edge cases:** Yeh scalar subquery **har outer row ke liye dobara compute** ho sakta hai
  performance-wise (SQLite mein) — chhote data (5 rows output) ke liye issue nahi, lekin bade
  scale par isse ek CTE mein precompute karna behtar hota.
- **Alternative approach:** Total revenue ko ek CTE mein pehle compute karke, phir cross join
  karna — zyada "explicit" style, same result.
- **Interview questions:** *"Scalar subquery kya hoti hai?"* → Ek subquery jo exactly ek row,
  ek column (ek single value) return karti hai — kisi expression ki jagah use ho sakti hai.

---

# File: `sql/05_delivery_analysis.sql` — Delivery / Operations Performance

## Query 5.1 — Overall Average Delivery Time

- **Business question:** Average kitne din lagte hain delivery mein?
- **Query:** `AVG(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp))`
- **Result:** ~12.6 days (delivered orders only).
- **Why the logic is correct:** `julianday()` dono dates ko ek numeric "day count" mein convert
  karta hai, subtraction se difference (days) milta hai. `WHERE order_delivered_customer_date
  IS NOT NULL` zaroori hai warna non-delivered orders ke null dates se `NULL` results aa jaate.

## Query 5.2 — On-Time vs Late Delivery

- **Business question:** Kitne % orders on-time deliver hue (estimate ke against)?
- **Query:** CTE mein `CASE WHEN delivered_date <= estimated_date THEN 'on_time' ELSE 'late'
  END`, phir `GROUP BY` + percentage.
- **Why the logic is correct:** "On-time" ki definition **Olist ke apne estimate ke against**
  hai, kisi fixed number of days ke against nahi — yeh customer-expectation-based hai, jo
  business-relevant framing hai.
- **Edge cases:** Agar `order_estimated_delivery_date` hi missing hota kisi row mein, comparison
  `NULL` ban jaata aur wo row kisi bhi group mein nahi aati (silently excluded) — is dataset mein
  yeh column kabhi null nahi tha for delivered orders.

## Query 5.3 — Slowest 10 States by Average Delivery Time

- **Business question:** Kaunse states mein delivery sabse slow hai?
- **Query:** `GROUP BY customer_state`, `HAVING delivered_orders >= 30`, `ORDER BY
  avg_delivery_days DESC`.
- **Why the logic is correct:** Same sample-size-safety pattern (`HAVING >= 30`) jo Query 3.3
  mein tha.
- **Cross-reference:** Yeh **same remote states** hain jo Query 4.2 mein high-AOV dikhe the —
  connecting these two findings gives Insight 8 (freight-cost artifact), a genuinely impressive
  interview point (shows you connect queries, not just run them independently).

## Query 5.4 — Delivery Performance vs Customer Satisfaction

- **Business question:** Kya delivery timing satisfaction ko affect karti hai?
- **Query:** CTE (on_time/late label) `JOIN order_reviews`, `GROUP BY delivery_status`,
  `AVG(review_score)`.
- **Result:** on_time avg **4.29★** (n=88,163) vs late avg **2.57★** (n=7,661).
- **Why the logic is correct:** Dono groups ka sample size bada hai (n>7000 dono taraf), isliye
  yeh difference statistically meaningful hai, sirf coincidence nahi.
- **This is the project's strongest insight** — dekho
  [17_BUSINESS_INSIGHTS.md](17_BUSINESS_INSIGHTS.md) Insight 1.
- **Interview questions:** *"Yeh causation prove karta hai?"* → Nahi — strong **correlation/
  association** hai, causation nahi "proven" (dekho file 11/24 correlation vs causation).

---

# File: `sql/06_customer_segmentation.sql` — RFM

Poora RFM concept + formula + scoring logic deep-dive: [14_CUSTOMER_SEGMENTATION.md](14_CUSTOMER_SEGMENTATION.md)
(is file mein duplicate nahi karenge, RFM itna important hai ki apni dedicated file deserve
karta hai). Yahan sirf itna: yeh file `WITH` (CTE chains), `NTILE()` (window function),
`CASE WHEN` (segment logic), aur `CREATE VIEW` — SQL ke sabse advanced concepts jo is project
mein use hue, sab ek saath demonstrate karti hai.

---

## What I should remember

- Har query ka core pattern: `JOIN` (related tables jodo) → `WHERE` (scope decide karo,
  usually `delivered`) → `GROUP BY` (business-dimension par) → aggregate (`SUM`/`AVG`/`COUNT`) →
  `ORDER BY`/`LIMIT` (ranking).
- `HAVING` hamesha "sample size safety" ke liye use hua hai is project mein — chhote groups ka
  average trust mat karo.
- AOV subquery = is project ki sabse important "grain mismatch" lesson.
- Query 4.2 aur 5.3 ka cross-reference (remote states = high AOV AND slow delivery) dikhata hai
  ki insights sirf individual queries se nahi, **queries ko jodkar** bhi aate hain.
- Sabse strong insight (delivery vs satisfaction) ek simple `GROUP BY` + `AVG` se aaya — complex
  SQL zaroori nahi, sahi business question poochna zyada important hai.
