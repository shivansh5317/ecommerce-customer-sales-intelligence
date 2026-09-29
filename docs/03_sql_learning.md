# 03 — SQL Learning Notes

> Yeh file tumhari **SQL study notes** hain — is poore project mein jo bhi SQL use hua hai,
> uska business reason, concept, query, line-by-line explanation, real result, aur interview
> angle yahan hai. Database: `data/ecommerce.db` (SQLite), banaya `scripts/build_database.py`
> se, cleaned data (`data/processed/`) se. Khud try karne ke liye:
> `python scripts/run_sql.py sql/01_basic_sales_analysis.sql` (ya koi bhi sql file).
>
> **Naya SQL concept jahan pehli baar aata hai, wahan poora explain kiya hai. Baad mein wahi
> concept dobara aaye toh sirf reference diya hai** ("GROUP BY — dekho Query 1.1") — isse
> notes repetitive nahi honge, aur revision ke time tumhe pata rahega concept pehli baar
> kahan explain hua tha.

---

## SQL concepts glossary (quick reference — poore file mein yeh use honge)

| Concept | Kya karta hai |
|---|---|
| `SELECT` / `WHERE` | Columns choose karna / rows filter karna |
| `JOIN` | Do tables ko ek common column (key) ke through jodna |
| `GROUP BY` | Rows ko kisi column ke value ke basis par groups mein baantna, phir har group par aggregate function lagana |
| `HAVING` | `GROUP BY` ke **baad** (aggregated) groups ko filter karna — `WHERE` sirf raw rows filter karta hai, `HAVING` grouped results ko |
| Aggregate functions | `SUM`, `AVG`, `COUNT`, `COUNT(DISTINCT ...)`, `MIN`, `MAX` — many rows ko ek number mein convert karte hain |
| `ORDER BY` / `LIMIT` | Result ko sort karna / sirf top-N rows dikhana |
| `CASE WHEN` | SQL ka if-else — condition ke basis par ek naya column/value banata hai |
| Subquery | Ek query ke andar ek aur query (result ko table ki tarah use karna) |
| CTE (`WITH ... AS`) | "Common Table Expression" — ek temporary named result jise aage ki query mein table ki tarah use kar sakte ho (subquery ka hi readable version) |
| Window function (`NTILE`) | Aggregate ki tarah hi hai, lekin rows ko group mein "squash" nahi karta — har row apni identity rakhti hai, bas ek extra calculated column mil jaata hai |
| `VIEW` | Ek saved query jise baar-baar likhne ke bajaye ek "virtual table" ki tarah reuse kar sakte ho |

---

## File `sql/01_basic_sales_analysis.sql` — Sales Performance

**Scope rule (important, poori file mein apply hoti hai):** Revenue/AOV queries sirf
`order_status = 'delivered'` orders par based hain. **Kyun?** Canceled/unavailable orders mein
real transaction complete nahi hua — unhe count karna revenue ko galat tarike se badha dega.
(Full reasoning: `docs/02_data_cleaning.md` section 9.)

**Revenue ka formula poore project mein:** `SUM(order_items.price + order_items.freight_value)`
— verified against `order_payments.payment_value` (0.017% difference only, dekho
`docs/02_data_cleaning.md` section 8).

### Query 1.1 — Total Revenue

- **Business question:** Company ka total revenue kitna hai?
- **SQL concept:** `SELECT` + `SUM()` (aggregate function) + `JOIN` + `WHERE`
- **Query:**
  ```sql
  SELECT
      ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered';
  ```
- **Line-by-line:**
  - `FROM order_items oi` — line-item level data (har product jo bika, ek row) se start.
  - `JOIN orders o ON o.order_id = oi.order_id` — order ka status pata karne ke liye `orders`
    table jodi (`order_items` mein status column nahi hai).
  - `WHERE o.order_status = 'delivered'` — sirf complete hui orders.
  - `SUM(oi.price + oi.freight_value)` — har item ka price+freight jod kar total nikala.
  - `ROUND(..., 2)` — 2 decimal places tak round (currency ke liye standard).
- **Expected result:** `total_revenue = 15,419,773.75` (Brazilian Real, R$)
- **Insight:** Yeh humara baseline number hai — har future insight ("category X ka Y% revenue
  hai") isi total se compare hota hai.
- **Interview questions:**
  - *"SUM() aur COUNT() mein kya fark hai?"* → `SUM` values add karta hai, `COUNT` rows ginta hai.
  - *"Agar tum WHERE clause hata do toh?"* → Sabhi order statuses include ho jayenge, revenue
    galat tarike se zyada dikhega (canceled orders bhi count hongi).

### Query 1.2 — Total Orders Placed vs Delivered

- **Business question:** Kitne orders place hue, aur unme se kitne successfully deliver hue?
- **SQL concept:** `COUNT(*)` vs conditional counting with `CASE WHEN` inside `SUM()`
- **Query:**
  ```sql
  SELECT
      COUNT(*) AS total_orders_all_status,
      SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders
  FROM orders;
  ```
- **Line-by-line:**
  - `COUNT(*)` — `orders` table ki total rows ginta hai (matlab total orders, kisi bhi status ke).
  - `CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END` — har row ke liye 1 ya 0 return
    karta hai (delivered hai toh 1, warna 0).
  - `SUM(...)` — un sabhi 1's ko jod kar delivered orders ka count deta hai. Yeh ek common SQL
    trick hai: **"CASE WHEN + SUM = conditional COUNT"**.
- **Expected result:** `total_orders_all_status = 99,441` · `delivered_orders = 96,478` (97.0%)
- **Insight:** 97% delivery success rate — bahut healthy operational number hai.
- **Interview questions:**
  - *"COUNT(column) aur COUNT(*) mein fark?"* → `COUNT(*)` saari rows ginta hai; `COUNT(column)`
    sirf un rows ko ginta hai jahan wo column NULL nahi hai.
  - *"Yeh CASE WHEN + SUM pattern kab use karte ho?"* → Jab ek hi query mein multiple conditional
    counts chahiye (bina multiple queries likhe, ya bina `GROUP BY` ke jab total bhi saath mein
    chahiye ho).

### Query 1.3 — Average Order Value (AOV)

- **Business question:** Average order value (AOV) kya hai — ek order mein average kitna
  spend hota hai?
- **SQL concept:** Subquery (query ke andar query)
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
- **Line-by-line:**
  - **Inner query** (`FROM (...) order_totals`): pehle **har order ka apna total** nikala
    (`GROUP BY oi.order_id` — ek order ke multiple line-items ko ek total mein jod diya).
  - **Outer query**: inner query ke result ko ek normal table ki tarah treat karke, uspar
    `AVG()` lagaya.
  - **Yeh subquery kyun zaroori hai (bahut important concept):** Agar hum directly
    `AVG(oi.price + oi.freight_value)` karte (bina subquery ke), toh yeh **per line-item
    average** milta, per-ORDER average nahi — agar ek order mein 3 products hain, toh wo 3
    baar count ho jaata average mein, jo galat hai. Subquery pehle order-level total banata
    hai, tabhi AOV sahi aata hai.
- **Expected result:** `average_order_value = 159.83` (R$)
- **Insight:** Har order se average R$159.83 aata hai — pricing/bundling strategy ke liye
  useful baseline.
- **Interview questions:**
  - *"AOV directly `AVG(price)` se kyun nahi nikala?"* → Upar wala explanation — order-level
    vs line-item-level ka fark. **Yeh ek bahut common interview trap hai.**
  - *"Subquery aur CTE mein kya fark hai?"* → Functionally same kaam kar sakte hain; CTE
    (`WITH ... AS`) zyada readable hota hai especially jab multiple steps ho, subquery chhoti
    ek-baar-use-hone-wali cheez ke liye theek hai.

### Query 1.4 — Monthly Revenue Trend

- **Business question:** Revenue time ke saath kaise change hua?
- **SQL concept:** Date formatting (`strftime`) + `GROUP BY` + `ORDER BY`
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
- **Line-by-line:**
  - `strftime('%Y-%m', ...)` — SQLite ka date-formatting function; poori timestamp
    (`2017-10-02 10:56:33`) se sirf `"2017-10"` (year-month) nikalta hai.
  - `GROUP BY order_month` — sab orders ko unke month ke hisab se group kiya.
  - `COUNT(DISTINCT oi.order_id)` — `DISTINCT` zaroori hai kyunki `order_items` mein ek order
    ki multiple rows ho sakti hain (multiple products) — bina `DISTINCT` ke order count galat
    (zyada) aata.
- **Expected result:** 23 months, Sep 2016 (₹143) se shuru, gradually badhte hue Nov 2017
  (₹11,53,364 — saal ka sabse high month) tak, phir 2018 mein stable ₹9-11 lakh/month range.
- **Insight:** Business Sep 2016 mein bahut chhota tha, 2017 ke through fast grow kiya. **Nov
  2017 ka spike** likely Brazil ke "Black Friday" season (November) ki wajah se hai.
  ⚠️ **Caution:** Is dataset mein Sep-Oct 2018 revenue bhi included nahi dikh raha (data
  collection yahi tak hai) — isko "sales crash" mat samajhna, yeh ek **data cutoff artifact**
  hai, real business decline nahi.
- **Interview questions:**
  - *"Time series trend nikalne ke liye tumne kya use kiya?"* → `strftime` se month extract
    karke `GROUP BY`.
  - *"Ek dip/spike dekh kar seedhe business conclusion nikal sakte ho?"* → Nahi — pehle check
    karo ki data collection ka period pura hai ya nahi (yahi Nov-Sep 2018 wala caution).

### Query 1.5 — Top 10 Categories by Revenue

- **Business question:** Kaunsi product categories sabse zyada revenue generate karti hain?
- **SQL concept:** Multi-table `JOIN` + `GROUP BY` + `ORDER BY ... DESC` + `LIMIT`
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
- **Line-by-line:** Teen tables jodi (`order_items` → `orders` for status, → `products` for
  category naam), category ke hisab se group kiya, revenue ke hisab se descending sort kiya,
  top 10 liye.
- **Expected result (top 5):** `health_beauty` (R$14,12,089) → `watches_gifts` (R$12,64,333) →
  `bed_bath_table` (R$12,25,209) → `sports_leisure` (R$11,18,257) → `computers_accessories`
  (R$10,32,724).
- **Insight:** `health_beauty` #1 revenue category hai, despite `bed_bath_table` ke paas
  **zyada orders** hain (dekho Query 1.6) — matlab `health_beauty` ka per-order value zyada hai.
- **Interview questions:**
  - *"3-table join likhne ka tarika kya hai?"* → Ek common key se shuru karo (`order_items`),
    phir har related table ko uske matching key se jodo, ek-ek karke.
  - *"GROUP BY mein alias (`category`) use kar sakte ho?"* → SQLite mein haan (kuch DBs mein
    nahi — MySQL/SQLite allow karte hain, standard SQL/Postgres mein kabhi poora expression
    dobara likhna padta hai).

### Query 1.6 — Top 10 Categories by Order Volume

- **Business question:** Kaunsi categories sabse zyada orders generate karti hain (volume)?
- **SQL concept:** Same as 1.5, bas `ORDER BY orders_count DESC`
- **Expected result (top 5):** `bed_bath_table` (9,272 orders) → `health_beauty` (8,647) →
  `sports_leisure` (7,530) → `computers_accessories` (6,530) → `furniture_decor` (6,307).
- **Insight:** `bed_bath_table` **volume mein #1** hai lekin **revenue mein #3** (Query 1.5) —
  iska matlab iska per-order value average se kam hai (₹1225209/9272 ≈ ₹132/order vs
  `health_beauty` ka ₹1412089/8647 ≈ ₹163/order). Yeh exactly "high volume, relatively lower
  revenue" wala pattern hai — aur detail mein `03_product_analysis.sql` Query 3.2 mein explore
  kiya hai.
- **Interview questions:**
  - *"Revenue aur order-volume ranking alag kyun aate hain?"* → Kyunki har category ka average
    price/order alag hota hai — high-volume zaroori nahi high-revenue ho.

---

## File `sql/02_customer_analysis.sql` — Customer Behavior

**Foundational rule (poori file mein):** Hum `customers.customer_unique_id` use karte hain,
**NOT** `customer_id` — kyunki `customer_id` order-level hai (har order ka apna naya ID),
`customer_unique_id` hi real insaan ko identify karta hai. (Detail: `docs/01` section 3.1.)

### Query 2.1 — Total Unique Customers

- **Business question:** Kitne unique customers hain?
- **SQL concept:** `COUNT(DISTINCT column)`
- **Query:** `SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers FROM customers;`
- **Expected result:** `96,096` unique customers (total `customer_id` rows: 99,441 — fark
  isliye hai kyunki kuch log multiple baar order karte hain).
- **Insight:** Baseline customer-base size.
- **Interview questions:** *"Agar tum yahan `customer_id` use karte toh kya hota?"* → Result
  99,441 aata (galat) — kyunki har order ek naya `customer_id` banata hai.

### Query 2.2 — Repeat vs One-Time Customers

- **Business question:** Kitne customers repeat purchase karte hain vs sirf ek baar?
- **SQL concept:** CTE (`WITH`) + `CASE WHEN` on aggregated data
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
- **Line-by-line:**
  - CTE `customer_orders`: har customer ka apna orders_count nikala (step 1: raw aggregation).
  - Outer query: us aggregated result par `CASE WHEN` laga kar do buckets banaye, phir dobara
    `GROUP BY` kiya (is baar customer_type par) taaki final counts milein.
  - **Yeh "group on top of a group" pattern hai** — pehle customer-level group, phir uspar
    customer-type-level group. CTE isko readable banata hai (agar subquery use karte toh
    nested `FROM (SELECT ...)` likhna padta, same result, kam readable).
- **Expected result:** `one_time_customer = 90,557` · `repeat_customer = 2,801`
- **Insight:** Sirf ~3% customers repeat karte hain — bahut bada opportunity area
  (retention/loyalty programs).
- **Interview questions:**
  - *"CTE kyun use kiya, subquery kyun nahi?"* → Readability — jab logic multi-step ho
    (pehle per-customer aggregate, phir us par dusra group), CTE se code top-se-neeche padhne
    mein aasan lagta hai.

### Query 2.3 — Percentage of Repeat Customers

- **Business question:** Repeat customers ka exact % kya hai?
- **SQL concept:** Same CTE + percentage calculation
- **Query:** (same CTE as 2.2) `ROUND(100.0 * SUM(CASE WHEN orders_count > 1 THEN 1 ELSE 0 END) / COUNT(*), 2)`
- **Line-by-line:** `100.0 *` mein `.0` important hai — agar `100 *` likhte (integer), kuch
  SQL engines integer division kar sakte hain aur decimal precision kho jaati. `100.0` explicitly
  float banata hai.
- **Expected result:** `3.0%` repeat customers.
- **Insight:** Confirms Query 2.2 ka finding numerically.
- **Interview questions:** *"Integer vs float division ka bug kaise avoid karte ho SQL mein?"*
  → Ek operand ko explicitly decimal likh do (`100.0` instead of `100`).

### Query 2.4 — Top 10 Highest-Value Customers

- **Business question:** Sabse zyada value wale customers kaun hain?
- **SQL concept:** 3-table `JOIN` + `GROUP BY` + `ORDER BY DESC` + `LIMIT` (same pattern as 1.5)
- **Expected result (top 3):** `0a0a92112b...` (R$13,664, 1 order) · `da122df9ee...` (R$7,572,
  2 orders) · `763c8b1c9c...` (R$7,275, 1 order).
- **Insight:** Sabse top customer ne sirf **1 order** mein R$13,664 spend kiya — likely ek
  bulk/high-ticket item (jaise furniture ya electronics), na ki ek "loyal repeat shopper."
  **Important:** "highest value" ≠ "most loyal" — dono alag concepts hain (RFM segmentation
  mein yeh difference explicitly capture hota hai, dekho `docs/04`).
- **Interview questions:** *"Highest spender hamesha best customer hota hai?"* → Zaroori nahi —
  ek-baar ka bada purchase vs consistent repeat purchase, dono ka business value alag hota hai.

### Query 2.5 — Customer Order-Frequency Distribution

- **Business question:** Customers ke order-frequency ka overall distribution kaisa hai?
- **SQL concept:** `CASE WHEN` buckets (multiple conditions/ranges)
- **Expected result:** `1 order` → 90,557 · `2 orders` → 2,573 · `3-5 orders` → 218 ·
  `6+ orders` → 10.
- **Insight:** Distribution bahut heavily skewed hai ek-order-wale customers ki taraf — yeh
  fact RFM segmentation (`06_customer_segmentation.sql`) mein bhi important role play karta
  hai (dekho `docs/04`).
- **Interview questions:** *"CASE WHEN mein range kaise likhte ho?"* →
  `WHEN orders_count BETWEEN 3 AND 5 THEN ...` — `BETWEEN` inclusive hota hai dono ends par.

### Query 2.6 — Average Spend per Customer

- **Business question:** Ek customer se (lifetime) average kitna revenue aata hai?
- **SQL concept:** CTE + `AVG()`
- **Expected result:** `165.17` (R$)
- **Insight:** Yeh AOV (₹159.83, Query 1.3) se thoda zyada hai — matlab kuch customers multiple
  orders karte hain jo unka total lifetime value AOV se upar le jaata hai.

---

## File `sql/03_product_analysis.sql` — Product / Category Performance

### Query 3.1 — Top 10 Individual Products by Revenue

- **Business question:** Sabse zyada revenue wale individual products (categories nahi, specific
  products) kaunse hain?
- **SQL concept:** `GROUP BY` on product-level (not category-level)
- **Expected result (top 3):** `bb50f2e2...` (health_beauty, R$67,258, 186 orders) ·
  `d1c42706...` (computers_accessories, R$58,957, 313 orders) · `6cdd5384...` (health_beauty,
  R$57,934, 148 orders).
- **Insight:** Top individual products bhi mostly `health_beauty`/`computers_accessories` se
  hain — category-level finding (Query 1.5) product-level par bhi consistent hai.

### Query 3.2 — High Volume but Relatively Low Revenue-per-Order Categories

- **Business question:** Kaunsi categories mein orders bahut aate hain lekin per-order revenue
  kam hai?
- **SQL concept:** `HAVING` (naya concept yahan explain kar rahe hain)
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
- **Line-by-line — `HAVING` ka concept:**
  - `WHERE` **raw rows** ko filter karta hai, **GROUP BY se PEHLE**.
  - `HAVING` **grouped/aggregated results** ko filter karta hai, **GROUP BY ke BAAD**.
  - Yahan hum `orders_count >= 100` filter laga rahe hain — yeh ek **aggregate result**
    (`COUNT(DISTINCT ...)`) par condition hai, isliye `WHERE` mein nahi likh sakte (WHERE ko
    pata hi nahi hota "orders_count" naam ka koi cheez tab tak, jab tak GROUP BY complete na ho
    jaaye) — isliye `HAVING` chahiye.
  - Yeh filter isliye lagaya taaki sirf **statistically meaningful** categories dikhein (agar
    ek category mein sirf 2 orders hain, uska "average" bahut unreliable/noisy hoga).
- **Expected result (top 5, lowest avg_revenue_per_order):** `electronics` (R$79.75/order,
  2,517 orders) · `food` (R$81.17) · `food_drink` (R$87.50) · `books_technical` (R$89.46) ·
  `telephony` (R$92.65, **4,093 orders** — highest volume in this list).
- **Insight:** `electronics` aur `telephony` — dono high order-volume categories hain (2,517
  aur 4,093 orders) lekin per-order revenue sabse kam categories mein se hain. Business action:
  inn categories mein higher-margin bundling ya upsell strategy explore ki ja sakti hai.
- **Interview questions:**
  - *"WHERE aur HAVING mein exact fark?"* → `WHERE` row-level filter (GROUP BY se pehle),
    `HAVING` group-level/aggregate filter (GROUP BY ke baad). Yeh ek **very common interview
    question** hai.
  - *"WHERE mein aggregate function use kar sakte ho?"* → Nahi, isliye HAVING chahiye.

### Query 3.3 — Categories with Poorest Ratings

- **Business question:** Kaunsi categories ki customer ratings sabse kharab hain?
- **SQL concept:** `JOIN` with `order_reviews` + `HAVING` (sample-size filter)
- **Expected result (worst 5):** `office_furniture` (avg 3.49★, 1,263 reviews) ·
  `fashion_male_clothing` (3.64★) · `fixed_telephony` (3.68★) · `fashio_female_clothing`
  (3.75★) · `party_supplies` (3.77★).
- **Insight:** `office_furniture` sabse consistent-poor rating wali category hai **aur** sample
  size bhi bada hai (1,263 reviews) — isliye yeh sirf noise nahi, ek genuine pattern hai. Likely
  reasons ho sakte hain: assembly issues, damage during shipping (furniture heavy/fragile hota
  hai), ya product-description mismatch.
- **Interview questions:** *"Rating ka average lete waqt sample size kyun matter karta hai?"* →
  Agar sirf 2-3 reviews hain, average bahut easily skew ho sakta hai ek extreme rating se —
  isliye humne `HAVING reviews_count >= 30` laga kar sirf reliable-sample categories li.

### Query 3.4 — Category-wise Average Price

- **Business question:** Har category ka average selling price kya hai?
- **Expected result (top 3):** `computers` (R$1,098.34) · `small_appliances_home_oven_and_coffee`
  (R$624.29) · `home_appliances_2` (R$476.12).
- **Insight:** High-average-price categories (electronics/appliances) naturally low order-volume
  hoti hain (fewer people buy expensive electronics repeatedly) — pricing tier alag business
  dynamics create karta hai.

### Query 3.5 — Widest Product Variety (Catalog Depth)

- **Business question:** Kaunsi categories mein sabse zyada distinct products listed hain?
- **Expected result (top 3):** `bed_bath_table` (3,029 products) · `sports_leisure` (2,867) ·
  `furniture_decor` (2,657).
- **Insight:** Yeh wahi categories hain jo order-volume mein bhi top hain (Query 1.6) — matlab
  zyada catalog-depth zyada order-volume se correlate karta hai (intuitive: zyada options = zyada
  customers ko kuch na kuch mil jaata hai).

---

## File `sql/04_regional_analysis.sql` — Geography

### Query 4.1 — Revenue by State

- **Business question:** Kaunse states sabse zyada revenue contribute karte hain?
- **Expected result (top 5):** `SP` (R$57,69,703, 40,501 orders) · `RJ` (R$20,55,402) ·
  `MG` (R$18,18,892) · `RS` (R$8,61,473) · `PR` (R$7,81,709).
- **Insight:** `SP` (São Paulo) dominant state hai — expected, kyunki yeh Brazil ka sabse bada
  commercial hub hai aur khud Olist bhi SP mein based hai.

### Query 4.2 — Average Order Value by State

- **Business question:** Kaunse states mein AOV sabse zyada hai?
- **Expected result (top 5):** `PB` (R$266.61) · `AC` (R$244.69) · `AP` (R$240.92) ·
  `AL` (R$237.21) · `RO` (R$234.43).
- **Insight — caution zaroori hai yahan:** Yeh states (**PB, AC, AP, AL, RO**) Brazil ke
  remote/north-east/north regions hain, **SP jaisa top-revenue state nahi hai is list mein.**
  Reason: humara "revenue" `freight_value` include karta hai, aur remote states mein
  **shipping cost zyada hoti hai** (distance zyada) — isliye AOV zyada dikhta hai, iska matlab
  yeh nahi ki wahan log zyada **expensive products** khareedte hain. **Yeh ek important
  "don't over-interpret the number" lesson hai** — hamesha socho ek metric **kis components se
  bana hai** before conclusion nikalna.
- **Interview questions:** *"AOV high dekh kar tumne kya conclusion nikala?"* → Seedhe "yeh
  states zyada valuable customers hain" mat bolo — pehle check karo ki freight jaisa koi
  component number ko skew toh nahi kar raha.

### Query 4.3 — Top 5 States by Unique Customers

- **Expected result:** `SP` (40,302) · `RJ` (12,384) · `MG` (11,259) · `RS` (5,277) ·
  `PR` (4,882).
- **Insight:** Customer-count ranking revenue-ranking (Query 4.1) jaisa hi hai — matlab revenue
  mostly customer-COUNT se drive ho raha hai, na ki kisi ek region ke customers ka avg spend
  bahut alag hai.

### Query 4.4 — Revenue Concentration (% of Total)

- **SQL concept:** Scalar subquery in `SELECT` clause (ek single number return karne wali
  subquery, jo har row ke against use hoti hai)
- **Query highlight:**
  ```sql
  ROUND(100.0 * SUM(oi.price + oi.freight_value) / (
      SELECT SUM(oi2.price + oi2.freight_value)
      FROM order_items oi2
      JOIN orders o2 ON o2.order_id = oi2.order_id
      WHERE o2.order_status = 'delivered'
  ), 2) AS pct_of_total_revenue
  ```
- **Line-by-line:** Andar wali `(SELECT SUM(...) ...)` poore dataset ka total revenue nikalti
  hai (ek single number). Bahar wali query har state ka revenue us single total se divide karti
  hai — is tarah har row ko "poore total ka kitna %" mil jaata hai, bina do alag queries chalaye.
- **Expected result:** `SP` = 37.42% of total revenue akela; top-5 states combined = 73.21%.
- **Insight:** **Revenue bahut concentrated hai top few states mein** (`SP` akela ~37%) —
  business risk angle: agar SP region mein koi disruption ho (logistics/economic), bahut bada
  revenue impact hoga. Diversification ek consideration ho sakta hai.
- **Interview questions:** *"Yeh subquery har baar re-run hoti hai kya?"* → SQLite/most engines
  mein agar subquery non-correlated hai (outer row par depend nahi karti, jaisa yahan hai), query
  planner usually ek baar compute karke reuse karta hai — lekin isse guarantee samajhna
  engine-dependent hai; agar performance concern ho toh CTE mein pehle se compute karna zyada
  predictable hota hai.

---

## File `sql/05_delivery_analysis.sql` — Delivery / Operations

### Query 5.1 — Average Delivery Time

- **Business question:** Order place karne se delivery tak average kitna time lagta hai?
- **SQL concept:** Date arithmetic with `julianday()`
- **Query:**
  ```sql
  SELECT
      ROUND(AVG(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)), 1) AS avg_delivery_days
  FROM orders
  WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL;
  ```
- **Line-by-line:** `julianday()` kisi bhi date/timestamp ko ek single decimal number (Julian
  day count) mein convert karta hai — do julian-day numbers ko **directly subtract** karke
  humein "kitne din ka fark hai" mil jaata hai (dates ko seedhe subtract nahi kar sakte, unhe
  pehle is comparable numeric form mein convert karna padta hai).
- **Expected result:** `12.6` days average.
- **Insight:** Baseline delivery-speed metric — future comparisons (state-wise, on-time %) isi
  se relate hote hain.
- **Interview questions:** *"Do dates ke beech difference kaise nikalte ho SQL mein?"* → Engine
  ke hisab se alag function hota hai (`julianday()` SQLite mein, `DATEDIFF()` MySQL/SQL Server
  mein, direct subtraction PostgreSQL mein) — concept same hai: dates ko numeric form mein
  convert karke subtract karna.

### Query 5.2 — On-Time vs Late Delivery %

- **Business question:** Kitne % orders time par (ya usse pehle) deliver hue, kitne late?
- **SQL concept:** CTE + `CASE WHEN` comparing two date columns
- **Query:**
  ```sql
  WITH delivery_status AS (
      SELECT order_id,
          CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date
               THEN 'on_time' ELSE 'late' END AS delivery_status
      FROM orders
      WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
  )
  SELECT delivery_status, COUNT(*) AS orders_count,
      ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM delivery_status), 2) AS pct
  FROM delivery_status
  GROUP BY delivery_status;
  ```
- **Line-by-line:** Date columns ko **text ki tarah bhi directly compare** kar sakte hain
  (`<=`) jab tak format consistent ISO (`YYYY-MM-DD HH:MM:SS`) ho — text-comparison alphabetically
  bhi chronologically-correct order deta hai is format mein. (`julianday()` yahan zaroori nahi
  tha kyunki hume sirf "pehle/baad" jaanna tha, exact din ka gap nahi.)
- **Expected result:** `on_time` = 88,644 orders (**91.89%**) · `late` = 7,826 orders (8.11%).
- **Insight:** ~92% on-time delivery — achi operational performance, lekin 8% (~7,800 orders)
  late hain — yeh directly customer satisfaction ko affect karta hai (dekho Query 5.4).

### Query 5.3 — Slowest States by Delivery Time

- **Expected result (slowest 5):** `RR` (29.4 days, 41 orders) · `AP` (27.2 days) ·
  `AM` (26.4 days) · `AL` (24.5 days) · `PA` (23.8 days).
- **Insight:** Yeh sab Brazil ke **North/North-East remote states** hain — geography/logistics
  infrastructure ki wajah se delivery slow hai, seller/Olist ki performance issue nahi.
  Consistent hai Query 4.2 ke finding ke saath (remote states = higher freight AND slower
  delivery — dono geography-driven hain).

### Query 5.4 — Delivery Performance vs Customer Satisfaction

- **Business question:** Kya late delivery se customer ratings kharab hoti hain?
- **Expected result:** `late` orders → avg review score **2.57★** · `on_time` orders → avg
  review score **4.29★**.
- **Insight (sabse strong insight is project mein):** **1.72-star ka fark** — late delivery
  customer satisfaction ko **bahut bada** hit deta hai. Yeh clearly evidence-based hai (7,661
  late reviews vs 88,163 on-time reviews — dono sample size solid hain). Business action:
  delivery-time improvement directly rating/satisfaction improve karega — operations team ke
  liye ek concrete, data-backed priority.
- **Interview questions:** *"Correlation aur causation mein fark?"* → Yahan hum keh sakte hain
  "association/relationship dikhi hai," lekin pakka causal proof (ki DELAY hi wajah hai, koi
  aur confounding factor nahi) ke liye aur controlled analysis chahiye hoga — abhi ke liye yeh
  ek **strong, actionable correlation** hai, matlab "guaranteed causation" nahi.

---

## File `sql/06_customer_segmentation.sql` — RFM Segmentation

Is file ka poora walkthrough (concept + query + result + business meaning) alag se
**`docs/04_customer_segmentation.md`** mein hai kyunki RFM apne aap mein ek poora topic hai jo
detailed teaching deserve karta hai. Yahan sirf itna: yeh file `VIEW` (naya concept — ek saved
query jise baar-baar likhe bina reuse kar sakte ho) aur `NTILE()` (window function) introduce
karta hai.

---

## Master interview-question recap for this whole SQL section

1. **WHERE vs HAVING** — row-filter (pre-group) vs group-filter (post-group).
2. **Subquery vs CTE** — same result possible, CTE zyada readable multi-step logic ke liye.
3. **COUNT(*) vs COUNT(DISTINCT col)** — total rows vs unique values.
4. **Why AOV needs a subquery/CTE** — order-level total pehle banao, phir average lo (line-item
   level average galat hota).
5. **JOIN order matters for readability, not just correctness** — start from the most granular
   table (`order_items`), join "up" to lookup tables.
6. **Always question what a metric is made of** — e.g. AOV including freight can mislead
   regional comparisons (Query 4.2 lesson).
7. **Sample size matters before trusting an average** — `HAVING count >= N` pattern.
