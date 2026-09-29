# 02 — Data Cleaning

> Yeh file `notebooks/01_eda.ipynb` ke Section 4 ("Data Cleaning") ka companion hai. Notebook
> mein **code + real output** hai; yahan hum **reasoning** ko ek jagah, thoda aur detail se
> explain kar rahe hain. Har decision yahan is structure mein hai: **What was wrong → Why does
> it matter → What did we do → Why this method.**
>
> **Golden rule jo humne follow ki:** koi bhi row ya column blindly delete nahi kiya. Har action
> ka ek business/statistical reason hai, aur jahan kuch chhod diya (jaise expected nulls), wahan
> bhi explicitly likha hai ki kyun chhoda.

## 1. `orders` — date columns text se datetime

- **What was wrong?** `order_purchase_timestamp`, `order_approved_at`,
  `order_delivered_carrier_date`, `order_delivered_customer_date`,
  `order_estimated_delivery_date` — sab `object` (text) dtype mein the.
- **Why does it matter?** Delivery time jaisa metric (`delivered_date - purchase_date`) sirf
  real `datetime` values par hi calculate ho sakta hai. Text par subtraction operation
  meaningless result dega ya error dega.
- **What did we do?** `pd.to_datetime(col, errors="coerce")` se convert kiya.
- **Why this method?** `errors="coerce"` ka matlab hai: agar koi value parse na ho paaye, crash
  hone ke bajaye wo `NaT` (Not-a-Time, datetime ka null) ban jayegi. Yeh safe hai kyunki humein
  pehle se pata tha ki kuch dates missing hain (jaise `order_approved_at` mein 160 nulls) —
  coerce unhe gracefully handle karta hai.
- **Nulls we intentionally kept (not an error):** `order_approved_at` (160), `order_delivered_
  carrier_date` (1,783), `order_delivered_customer_date` (2,965). Yeh saare **order lifecycle**
  ki wajah se null hain — jo order abhi "delivered" stage tak nahi pahuncha (canceled/processing/
  shipped/etc.), uske liye delivery date exist hi nahi karti. Isko fill/impute karna galat hoga
  (fake data create karna hoga) — isliye null hi rehne diya, aur delivery-time analysis mein
  hum sirf `delivered` orders hi consider karte hain (jahan yeh dates hoti hi hain).

## 2. `customers` — zip code zero-padding

- **What was wrong?** `customer_zip_code_prefix` numeric (`int64`) tha. Brazilian zip codes
  jo `0` se start hote hain (e.g. São Paulo capital `01310`), unka leading zero drop ho jaata
  hai jab number ki tarah store karte hain (`01310` → `1310`).
- **Why does it matter?** Yeh identifier hai, quantity nahi — zip codes par kabhi addition/
  average nahi lagate. Agar hum ise galat format mein rakhte, toh geolocation table se join
  karte waqt ya Power BI mein zip display karte waqt confusing/wrong values dikhte.
- **What did we do?** `.astype(str).str.zfill(5)` — string bana kar 5-digit tak zero-pad kiya.
- **Why this method?** Simple, non-destructive fix. Koi data loss nahi, sirf representation
  format sahi kiya. (23,995 rows ka zip code prefix 5 digits se kam tha — yeh sab is fix se
  affected hue.)
- **`customer_id` vs `customer_unique_id`:** Koi cleaning action nahi li (data already correct
  tha), lekin explicitly documented ki `customer_unique_id` hi "real person" hai — is convention
  ko poore project mein consistently follow karna hai (SQL, Python, Power BI sabme).

## 3. `order_items` — date conversion + outlier check (no removal needed)

- **What was wrong?** `shipping_limit_date` text format mein tha (same date-conversion issue).
- **Why does it matter?** Consistency ke liye — agar future analysis mein "seller ne time pe
  ship kiya ya late" jaisa sawal poochna ho, toh yeh column bhi datetime hona chahiye.
- **What did we do?** Date convert kiya. Phir `price` aur `freight_value` par outlier investigation
  ki — `.describe()` dekha, `<= 0` values count ki.
- **Why this method / what we found:** Verified: **zero negative ya zero prices/freight nahi
  mile.** Max price ₹6,735 tha — humne ise "error" maan kar delete nahi kiya, kyunki yeh ek
  legitimate premium product ho sakta hai (furniture/electronics jaisi category mein). **Lesson:**
  outlier dikhne par turant delete mat karo — pehle verify karo ki wo error hai ya real
  high-value case.

## 4. `order_payments` — rare category bucketing

- **What was wrong?** `payment_type` mein `"not_defined"` category thi — sirf 3 rows out of
  103,886 (0.003%). `payment_installments` mein 2 rows `0` thi (jabki minimum meaningfully `1`
  hona chahiye).
- **Why does it matter?** `"not_defined"` ek chart mein apna tiny, confusing bar banata — isse
  koi analytical value nahi milti.
- **What did we do?** `"not_defined"` ko `"other"` mein replace kiya. `payment_installments == 0`
  wale 2 rows ko **as-is chhod diya** — documented as a known, negligible anomaly.
- **Why this method?** Jab issue ka impact itna chhota ho (yahan <0.01% of rows, aur koi required
  business question is field par depend nahi karta), toh usse "fix" karne mein effort lagane se
  behtar hai use transparently document karke aage badhna.

## 5. `order_reviews` — duplicate review submissions

- **What was wrong?** 99,224 total review rows the, lekin sirf 98,673 unique `order_id` — matlab
  **551 orders ke liye 1 se zyada review row** thi (customer ne dobara submit kiya).
- **Why does it matter?** Agar hum order-level ya category-level average rating nikalte waqt
  duplicate rows include karte, toh un 551 orders ka weight galti se do-guna ho jaata — thoda
  sa (chhota lekin real) bias satisfaction metrics mein aata.
- **What did we do?** `sort_values("review_answer_timestamp")` phir
  `drop_duplicates(subset="order_id", keep="last")` — matlab har order ke liye sirf **sabse
  latest** review rakha.
- **Why this method?** Latest review customer ka final/updated opinion represent karta hai.
  Result verify kiya: cleaning ke baad `order_reviews["order_id"].nunique() == len(order_reviews)`
  → `True`, matlab ab perfect 1:1 relationship hai.

## 6. `products` — category fill + translation merge + tiny row drop

- **What was wrong?** Teen alag cheezein:
  1. 610 products (1.85%) mein `product_category_name` missing thi (saath mein
     name-length/description-length/photo-qty bhi missing).
  2. Category translation file mein sirf 71 categories hain jabki products mein 73 raw category
     names hain — 2 categories ka translation missing → total **623 products** end up bina
     English category label ke.
  3. Sirf **2 rows** mein physical dimensions (`product_weight_g` and related) missing the.
- **Why does it matter?** Product/category performance analysis (business question set #3) ke
  liye har product ka ek valid, usable category label chahiye.
- **What did we do?**
  1. `product_category_name.fillna("unknown")`.
  2. Category translation table se **left join** kiya; jo match nahi hua (missing translation),
     usse bhi `"unknown"` assign kiya.
  3. 2 rows jinke dimensions missing the, unhe **drop** kiya.
- **Why this method?** `"unknown"` ek honest label hai — hum fake category name invent nahi kar
  rahe, sirf transparently keh rahe "iski category pata nahi." Dimension-missing 2 rows itna
  negligible hain (0.006%) ki physical measurements ko fabricate/impute karna galat hota —
  drop karna sabse clean option tha.
- **Residual nulls (intentionally left, out of scope):** `product_name_lenght`,
  `product_description_lenght`, `product_photos_qty` mein ~609 rows abhi bhi null hain. Yeh
  listing-quality metadata hai jo humare required business questions (sales/customer/regional/
  delivery/satisfaction/segmentation) mein se kisi mein use nahi ho raha — isliye inhe fill
  karne ka koi analytical benefit nahi tha, so left as-is.

## 7. `sellers` and `geolocation`

- **What was wrong?** `sellers` mein wahi zip-code leading-zero issue tha. `geolocation` mein
  **261,831 fully duplicate rows** the (~26% of the table), aur is table ka grain
  "ek zip = multiple GPS sample-point rows" tha, "ek zip = ek row" nahi.
- **Why does it matter?** Duplicate rows kisi bhi count/aggregation ko inflate karte hain.
  Agar hum `geolocation` ko directly `customers`/`sellers` se (bina aggregate kiye) join karte,
  toh ek customer/seller ke liye **multiple duplicate rows** ban jaati (a "fan-out" join) —
  jisse revenue jaisi metrics galti se multiply ho jaatin.
- **What did we do?**
  1. Zip code zero-padded (jaise customers mein).
  2. Exact duplicate rows drop kiye: 1,000,163 → 738,332 rows.
  3. Phir **har zip prefix ke liye ek representative row** banayi — `groupby(zip).agg(mean lat,
     mean lng, most-common city, most-common state)`: 738,332 → **19,015 rows** (ek row per
     unique zip prefix).
- **Why this method?** Mean lat/lng ek zip code area ka reasonable "center point" deta hai —
  hume GPS-level precision nahi chahiye, sirf city/region-level map visual ke liye kaafi hai.
  Ab yeh table safely `customers`/`sellers` se 1:1 join ho sakti hai bina row-count badhaye.

## 8. Revenue definition — a deliberate, verified design decision

Project ke sabhi "revenue/sales" questions ek hi consistent definition use karte hain, taaki
alag-alag jagah alag numbers na aa jaayein. Do candidate sources the:

1. `order_items.price + order_items.freight_value` (product + shipping charged)
2. `order_payments.payment_value` (actual amount customer ne pay kiya)

**Hum `order_items` ko primary revenue source maan rahe hain.** Reasoning verified with real
numbers: `delivered` orders ke liye dono sources ka total compare kiya —

| Source | Total (delivered orders) |
|---|---|
| `order_items` (price + freight) | R$ 15,419,773.75 |
| `order_payments` (payment_value) | R$ 15,422,461.77 |
| **Difference** | R$ 2,688.02 (**0.017%**) |

Itna chhota difference confirm karta hai dono sources reliable hain. Humne `order_items` isliye
chuna kyunki:
- Yeh **line-item level** hai (product/category-level revenue breakdown seedha milta hai).
- `order_payments` table mein per-order multiple rows ho sakti hain (split payments) aur kuch
  edge-case zero-value rows (9 rows, mostly `voucher`/`not_defined` types) — jo revenue ke liye
  extra handling maangti.

`order_payments` table ka use hum specifically **payment behavior** analysis ke liye karte hain
(payment type mix, installments) — revenue ke liye nahi.

## 9. Business rule — only `delivered` orders count for revenue/delivery/satisfaction analysis

`order_status` breakdown: `delivered` 96,478 · `shipped` 1,107 · `canceled` 625 ·
`unavailable` 609 · `invoiced` 314 · `processing` 301 · `created` 5 · `approved` 2.

- **What was the consideration?** Canceled/unavailable orders mein actual product exchange
  nahi hua (ya reverse ho gaya) — inhe revenue mein count karna business ko misleading
  (inflated) picture dega.
- **What did we do?** Sales/revenue/delivery-performance/satisfaction queries mein hum
  `order_status = 'delivered'` filter apply karte hain (SQL files mein yeh explicitly dikhega).
  "Total orders placed" jaisa count metric (jo order volume dikhata hai, revenue nahi) sabhi
  statuses include kar sakta hai — hum dono versions ko clearly label karte hain jahan relevant.
- **Interview angle:** Agar poocha jaaye "revenue calculate karte time tumne kaunse orders liye
  aur kyun?" — is section ka answer directly use kar sakte ho.

## Summary table

| Table | Rows before | Rows after | Key actions |
|---|---|---|---|
| `orders` | 99,441 | 99,441 | date conversion only, no rows removed |
| `customers` | 99,441 | 99,441 | zip zero-padded, no rows removed |
| `order_items` | 112,650 | 112,650 | date conversion, verified no outlier removal needed |
| `order_payments` | 103,886 | 103,886 | `not_defined` → `other`, no rows removed |
| `order_reviews` | 99,224 | 98,673 | removed 551 duplicate review rows (kept latest per order) |
| `products` | 32,951 | 32,949 | filled category nulls with `"unknown"`, dropped 2 rows (missing dimensions) |
| `sellers` | 3,095 | 3,095 | zip zero-padded, no rows removed |
| `geolocation` | 1,000,163 | 19,015 | dropped exact duplicates, aggregated to 1 row per zip prefix |

## Interview questions this section prepares you for

- **"Tumne missing values kaise handle kiye?"** → Category-type missing values ko `"unknown"`
  label diya (delete nahi kiya); date-type missing values ko legitimate (business-lifecycle)
  null maan kar chhoda; sirf 2 rows jahan critical numeric data missing thi aur impute karna
  fabrication hota, unhe drop kiya.
- **"Duplicate data kaise identify aur handle ki?"** → `geolocation` mein exact duplicate rows
  (`.duplicated()`), aur `order_reviews` mein logical duplicates (same `order_id` multiple baar) —
  dono ke liye alag-alag strategy use ki (drop exact dupes vs. keep-latest-per-key).
  strategy).
- **"Revenue kaunse column se nikala aur kyun?"** → `order_items.price + freight_value`,
  cross-verified against `order_payments.payment_value` (0.017% difference) — section 8 dekho.
- **"Kya tumne saare canceled orders ko revenue mein include kiya?"** → Nahi — sirf `delivered`
  orders ko revenue/delivery/satisfaction analysis mein include kiya, aur yeh decision explicitly
  documented hai (section 9).
