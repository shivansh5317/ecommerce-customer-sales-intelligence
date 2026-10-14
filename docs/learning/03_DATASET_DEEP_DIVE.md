# 03 — Dataset Deep Dive

> Yeh file tumhara **beginner-friendly data dictionary** hai — har table, har important column,
> aur unke business meaning ke saath. Agla file ([04](04_DATABASE_AND_DATA_MODEL.md)) yeh
> samjhayega ki yeh tables **database ke andar kaise judi hain**.

---

## 1. Before the tables — kuch basic data-type vocabulary (GENERAL)

Kisi bhi dataset ko samajhne se pehle, columns ko unke **type** se pehchaanna seekho:

| Data type | Matlab | Is dataset mein example |
|---|---|---|
| **Categorical data** | Fixed set of labels/categories, koi natural numeric order nahi (ya limited order) | `order_status` (`delivered`/`shipped`/`canceled`...), `customer_state` (`SP`/`RJ`...) |
| **Numerical data** | Numbers jinpar math operations (sum/average) meaningful hote hain | `price`, `freight_value`, `review_score` |
| **Date/time data** | Kisi specific pal/din ko represent karta hai | `order_purchase_timestamp` |
| **Identifier column (ID)** | Kisi row/entity ko uniquely identify karta hai — yeh ek "label" hai, quantity nahi | `order_id`, `customer_id`, `product_id` |

> ⚠️ **Common beginner mistake:** ID columns (jaise `customer_zip_code_prefix`) numbers dikhte
> hain, lekin unpar **kabhi average/sum mat lagana** — yeh identifiers hain, quantities nahi.
> (Isi wajah se zip code ko is project mein number ki jagah **text/string** treat kiya gaya —
> dekho [09_DATA_CLEANING.md](09_DATA_CLEANING.md).)

---

## 2. Dataset ka source aur scale (MY PROJECT)

- **Name:** Brazilian E-Commerce Public Dataset by Olist ([Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce))
- **Downloaded via:** Python `kagglehub` library — anonymously, koi API key nahi chahiye.
- **Time period:** Orders `2016-09-04` se `2018-10-17` tak.
- **Grain:** Data **order-level aur order-item-level** par hai — ek order mein multiple products
  ho sakte hain, har product `order_items` mein apni ek row banata hai.
- **9 raw CSV files, ~148 MB total.**

| # | File | Rows | Grain (1 row = ?) |
|---|------|------|--------------------|
| 1 | `olist_customers_dataset.csv` | 99,441 | 1 customer_id (order-level) |
| 2 | `olist_orders_dataset.csv` | 99,441 | 1 order |
| 3 | `olist_order_items_dataset.csv` | 112,650 | 1 product line-item within an order |
| 4 | `olist_order_payments_dataset.csv` | 103,886 | 1 payment transaction |
| 5 | `olist_order_reviews_dataset.csv` | 99,224 | 1 review submission |
| 6 | `olist_products_dataset.csv` | 32,951 | 1 product |
| 7 | `olist_sellers_dataset.csv` | 3,095 | 1 seller |
| 8 | `olist_geolocation_dataset.csv` | 1,000,163 | 1 lat/lng sample for a zip code prefix |
| 9 | `product_category_name_translation.csv` | 71 | 1 category (PT-BR → English) |

> **"Grain" ka matlab (important DA vocabulary):** Grain = "ek row exactly kis cheez ko
> represent karti hai." Grain samajhe bina average/count nikalna galat result deta hai (dekho
> [12_BUSINESS_METRICS.md](12_BUSINESS_METRICS.md) AOV wala example — yeh is poore project ki
> sabse common interview trap hai).

---

## 3. Table-by-table Data Dictionary

### 3.1 `customers`

- **Purpose:** Kaunsa customer kahan (city/state) se order kar raha hai.
- **Primary key:** `customer_id`
- **Foreign key:** None (yeh ek lookup/dimension table hai)

| Column | What is it? | Why needed? | How used? | What can it tell us? |
|---|---|---|---|---|
| `customer_id` | Order-specific customer key (naya har order ke liye) | Orders table se join karne ke liye | Har SQL/Pandas join mein | Kaunsa order kis customer-record se belong karta hai |
| `customer_unique_id` | **Real insaan** ko identify karta hai across orders | Repeat-customer/RFM analysis ke liye | Customer-level GROUP BY mein | Kitne unique log hain, kaun repeat karta hai |
| `customer_zip_code_prefix` | Postal code ke pehle 5 digits (text) | Geolocation join / regional grouping ke liye | Rarely used directly (state zyada use hota hai) | Fine-grained location |
| `customer_city`, `customer_state` | Shipping city/state | Regional analysis ke liye | `GROUP BY customer_state` | Kaunsa region sabse zyada revenue/orders deta hai |

> ⚠️ **Sabse important gotcha:** `customer_id` unique count = 99,441 (= total orders), lekin
> `customer_unique_id` unique count = **96,096**. Matlab kuch log multiple orders karte hain, aur
> agar galti se `customer_id` use kiya "unique customers"/"repeat customers" ke liye, result
> **completely galat** aayega (dikhega ki koi bhi repeat nahi karta). Poore project mein hum
> hamesha `customer_unique_id` use karte hain jab bhi "real customer" ki baat ho.

### 3.2 `orders`

- **Purpose:** Har order ka lifecycle (kab place hua, kab deliver hua, kis stage mein hai).
- **Primary key:** `order_id`
- **Foreign key:** `customer_id` → `customers.customer_id`

| Column | What is it? | Why needed? | How used? | What can it tell us? |
|---|---|---|---|---|
| `order_id` | Unique order identifier | Har analysis ka anchor point | Har JOIN mein | — |
| `order_status` | Order kis stage mein hai (`delivered`/`shipped`/`canceled`/...) | Revenue/delivery scope decide karne ke liye | `WHERE order_status='delivered'` | Operational health (97% delivered) |
| `order_purchase_timestamp` | Order kab place hua | Time-trend analysis ke liye | Monthly revenue GROUP BY | Growth/seasonality |
| `order_approved_at` | Payment kab approve hua | Payment-processing speed (out of scope in this project) | — | — |
| `order_delivered_carrier_date` | Courier ko kab handover hua | Logistics-stage analysis (out of scope in detail) | — | — |
| `order_delivered_customer_date` | Customer tak kab pahuncha | Delivery-time aur on-time/late calculation ke liye | `julianday(delivered) - julianday(purchase)` | Operations performance |
| `order_estimated_delivery_date` | Olist ka diya estimate | On-time vs late define karne ke liye | `delivered <= estimated ? 'on_time' : 'late'` | Customer-expectation-vs-reality |

**Categorical column deep-dive — `order_status`:** delivered 96,478 (97.0%) · shipped 1,107 ·
canceled 625 · unavailable 609 · invoiced 314 · processing 301 · created 5 · approved 2.

### 3.3 `order_items`

- **Purpose:** Har order ke andar **kaunsa product, kis price par, kis seller se** bika.
- **Primary key:** Composite (`order_id` + `order_item_id`)
- **Foreign keys:** `order_id` → `orders`, `product_id` → `products`, `seller_id` → `sellers`

| Column | What is it? | Why needed? | How used? | What can it tell us? |
|---|---|---|---|---|
| `order_item_id` | Order ke andar sequence number | Multi-item orders track karne ke liye | Rarely aggregated directly | Kitne items ek order mein the |
| `product_id` | Kaunsa product bika | Products se join, category-level analysis | Har product/category query | Product/category performance |
| `seller_id` | Kis seller ne bheja | Sellers se join (out of scope in detail) | — | Seller-level analysis (future improvement) |
| `price` | Product ki selling price | **Revenue ka core component** | `SUM(price + freight_value)` | Revenue, AOV, category pricing |
| `freight_value` | Shipping charge | Revenue ka doosra component | Same as above | Shipping-cost impact |

> 💡 **Revenue formula poore project mein:** `SUM(order_items.price + order_items.freight_value)`,
> `delivered` orders ke liye. Poora reasoning + cross-verification:
> [09_DATA_CLEANING.md](09_DATA_CLEANING.md) section "Revenue definition."

### 3.4 `order_payments`

- **Purpose:** Order kaise pay hua (method, installments, amount).
- **Primary key:** Composite (`order_id` + `payment_sequential`)
- **Foreign key:** `order_id` → `orders`

| Column | What is it? | Why needed? | How used? | What can it tell us? |
|---|---|---|---|---|
| `payment_type` | `credit_card`/`boleto`/`voucher`/`debit_card`/`other` | Payment-behavior analysis | `value_counts()` / GROUP BY | Brazil mein `boleto` (bank-slip) bhi common hai |
| `payment_installments` | Kitni EMI mein pay hua | Payment-behavior analysis | Distribution check | Installment-payment culture ka signal |
| `payment_value` | Payment amount | Revenue cross-verification | Compare against `order_items` total | Consistency check |

> **Note:** Is project mein revenue ka primary source `order_items` hai, `order_payments` nahi
> — lekin `order_payments` se cross-verify kiya gaya (0.017% difference only). Poori detail
> [06_SQL_USED_IN_MY_PROJECT.md](06_SQL_USED_IN_MY_PROJECT.md) mein.

### 3.5 `order_reviews`

- **Purpose:** Customer satisfaction (star rating + optional text).
- **Primary key:** `review_id` (aur cleaning ke baad, effectively `order_id` bhi unique hai)
- **Foreign key:** `order_id` → `orders`

| Column | What is it? | Why needed? | How used? | What can it tell us? |
|---|---|---|---|---|
| `review_score` | 1 (worst) – 5 (best) rating | **Customer satisfaction ka core metric** | AVG, GROUP BY category/delivery-status | Category quality, delivery-satisfaction link |
| `review_comment_title`/`message` | Optional free-text | Out of scope (no NLP in this project) | Not used | — |

**review_score breakdown:** 5★ 57,328 · 4★ 19,142 · 3★ 8,179 · 2★ 3,151 · 1★ 11,424 — **bimodal**
(1★ > 2★, matlab customers ya bahut khush ya bahut frustrated hote hain).

### 3.6 `products`

- **Purpose:** Har product ki category aur physical attributes.
- **Primary key:** `product_id`

| Column | What is it? | Why needed? | How used? | What can it tell us? |
|---|---|---|---|---|
| `product_category_name` | Category (Portuguese) | Translation join ke liye | `merge()` with translation file | — |
| `product_category_name_english` | Category (English, humara cleaned column) | **Sabse zyada use hone wala column** | Har category-level GROUP BY | Category performance |
| `product_weight_g`, dimensions | Shipping ke liye physical size | Out of scope in this project's questions | Not aggregated | (Could feed freight analysis in future) |

### 3.7 `sellers`

- **Purpose:** Kis seller ne product bheja, kahan se operate karta hai.
- **Primary key:** `seller_id`
- Is project mein seller-level analysis **detail mein nahi** ki gayi — future improvement.

### 3.8 `geolocation`

- **Purpose:** Zip-code-prefix ke liye approximate lat/lng (map visuals ke liye).
- **Grain (important):** Ek zip prefix ke **multiple** GPS sample-point rows ho sakte hain —
  "ek zip = ek row" nahi hai raw form mein.
- Cleaning ke baad: 1 row per zip prefix (mean lat/lng, mode city/state) — dekho
  [09_DATA_CLEANING.md](09_DATA_CLEANING.md).

### 3.9 `product_category_name_translation`

Simple 71-row lookup: Portuguese category name → English category name.

---

## 4. Missing Values & Duplicates — quick recap (full reasoning in file 09)

| Table | Issue | Real numbers |
|---|---|---|
| `orders` | Missing delivery-lifecycle timestamps | 160 / 1,783 / 2,965 nulls (expected — order abhi tak us stage tak nahi pahuncha) |
| `products` | Missing category | 610 rows (1.85%) |
| `order_reviews` | Duplicate `order_id` (>1 review) | 551 orders |
| `geolocation` | Fully duplicate rows | 261,831 (~26%) |

---

## 5. INTERVIEW — Dataset Questions

**Q: "Yeh data kahan se aaya aur kis level ka hai?"**
> Real, anonymized, ~100k-order Brazilian marketplace dataset from Kaggle (Olist), 2016–2018,
> 9 relational CSV files.

**Q: "Is dataset ka sabse tricky/important part kya tha samajhne mein?"**
> `customer_id` vs `customer_unique_id` distinction. Isko explicitly bolna interview mein strong
> signal deta hai ki tumne data sirf load nahi kiya, deeply samjha bhi hai.

**Q: "Data ka 'grain' kya hota hai, aur yahan kyun important hai?"**
> Grain = ek row exactly kis cheez ko represent karti hai. `order_items` ka grain "line item"
> hai, "order" nahi — isliye AOV directly `AVG(price)` se nahi nikala ja sakta (dekho file 12).

**Q: "Kaunsi table sabse zyada 'dirty' thi?"**
> `geolocation` — 26% fully-duplicate rows aur "many rows per zip" grain problem, jisko fix
> karne ke liye dedup + aggregate dono steps chahiye the.

---

## What I should remember

- 9 raw tables; grain = order + order-item level.
- `customer_id` (order-level, 99,441) vs `customer_unique_id` (person-level, 96,096) — sabse
  bada gotcha.
- Revenue = `price + freight_value` from `order_items`, scoped to `delivered` orders.
- `review_score` distribution bimodal hai — average akela poori kahani nahi batata.
- `geolocation` ka grain "many rows per zip" hai — direct join karne se fan-out ho jaata.
