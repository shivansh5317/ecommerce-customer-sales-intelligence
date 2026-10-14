# 09 — Data Cleaning

## GENERAL — Why is data "dirty"?

Real-world data is almost never perfectly ready-to-use, because:

- **Humans enter it** (typos, inconsistent formats, missing fields).
- **Systems evolve over time** (an order that's mid-lifecycle has fields that simply don't
  exist yet — e.g. a not-yet-shipped order has no delivery date).
- **Multiple sources get combined** (translation files, different systems) — coverage gaps
  happen.
- **Storage formats lose information** (e.g. a number-typed zip code loses its leading zero).

**Common categories of dirty data:**

| Problem | Simple Meaning |
|---|---|
| **Missing values** | Kuch cells khaali/null hain |
| **Duplicate rows** | Same record galti se ek se zyada baar store ho gaya |
| **Invalid values** | Values jo business-logically impossible hain (jaise negative price) |
| **Wrong data types** | Number ki jagah text, ya text ki jagah date (jaise date "object"/text ki tarah stored) |
| **Inconsistent categories** | Same cheez ko alag-alag naam se likha gaya (`"NY"` vs `"New York"`) |
| **Outliers** | Extreme values jo error bhi ho sakte hain ya genuine rare case bhi |

**Golden rule (poore project mein follow ki gayi):** Koi bhi row/column **blindly delete** mat
karo. Har action ka ek business/statistical reason hona chahiye, aur jo kuch chhod diya
(intentionally), uska bhi reason likhna chahiye.

---

## MY PROJECT — Table-by-table cleaning (PROBLEM → WHY IT MATTERS → HOW DETECTED → WHAT WE DID → WHY THIS METHOD → RESULT)

### 1. `orders` — date columns text se datetime

- **Problem:** `order_purchase_timestamp` aur 4 aur date columns `object` (text) dtype mein the.
- **Why it matters:** Delivery-time jaisa metric (`delivered - purchase`) sirf real `datetime`
  values par calculate ho sakta hai — text par subtraction meaningless/error hoga.
- **How we detected it:** `.dtypes` check kiya (notebook Section 3) — saare date-naam-wale
  columns `object` dikhe, `datetime64` nahi.
- **What we did:** `pd.to_datetime(col, errors="coerce")` se convert kiya.
- **Why this method:** `errors="coerce"` unparseable values ko crash karne ke bajaye `NaT`
  bana deta hai — safe hai kyunki humein pehle se pata tha kuch dates missing hain.
- **Result:** Saare 5 date columns ab `datetime64` type mein hain. Nulls intentionally kept:
  `order_approved_at` (160), `order_delivered_carrier_date` (1,783), `order_delivered_customer_date`
  (2,965) — yeh order-lifecycle ki wajah se hain (jo order abhi tak deliver nahi hua, uski
  delivery date exist hi nahi karti — isko fill karna **fake data create karna** hoga).

### 2. `customers` — zip code zero-padding

- **Problem:** `customer_zip_code_prefix` numeric (`int64`) tha — leading zeros (e.g. `01310`)
  drop ho jaate hain number format mein.
- **Why it matters:** Zip code ek **identifier** hai, quantity nahi — ise number ki tarah
  treat karna representation ko galat bana deta hai.
- **How we detected it:** Sample rows dekhe, zip codes 4-digit dikhe jab expected 5-digit tha.
- **What we did:** `.astype(str).str.zfill(5)` — string bana kar 5-digit tak zero-pad kiya.
- **Why this method:** Simple, non-destructive — koi data loss nahi, sirf representation format
  sahi kiya.
- **Result:** 23,995 rows ka zip code prefix ab correctly 5-digit string hai.

### 3. `order_items` — date conversion + outlier investigation (no removal needed)

- **Problem:** `shipping_limit_date` text format mein tha; `price`/`freight_value` mein outliers
  ho sakte the.
- **Why it matters:** Date consistency ke liye; outliers agar data-entry errors hote, revenue
  galat ho jaata.
- **How we detected it:** Date convert karke, `.describe()` se `price`/`freight_value` ki range
  dekhi, `<= 0` values count ki.
- **What we did:** Date convert kiya. Outlier check kiya lekin **koi row remove nahi ki**.
- **Why this method:** Verified — **zero negative/zero prices** mile. Max price ₹6,735 ek
  legitimate premium product ho sakta hai (furniture/electronics) — "outlier dikhne par turant
  delete mat karo, pehle verify karo error hai ya real high-value case."
- **Result:** 112,650 rows unchanged, sirf date-type fix hua.

### 4. `order_payments` — rare category bucketing

- **Problem:** `payment_type` mein `"not_defined"` (sirf 3/103,886 rows, 0.003%);
  `payment_installments` mein 2 rows `= 0`.
- **Why it matters:** `"not_defined"` chart mein ek tiny confusing bar banata, koi analytical
  value nahi.
- **How we detected it:** `.value_counts()` se dekha.
- **What we did:** `"not_defined"` ko `"other"` mein replace kiya; `installments=0` wale 2 rows
  **as-is chhod diye** (documented anomaly).
- **Why this method:** Jab impact itna chhota ho (<0.01%, koi required question depend nahi
  karta), "fix" karne mein effort lagane se better hai transparently document karna.
- **Result:** `payment_type` ab 4 clean categories + `"other"`.

### 5. `order_reviews` — duplicate review submissions

- **Problem:** 99,224 review rows, lekin sirf 98,673 unique `order_id` — **551 orders ke liye
  >1 review row**.
- **Why it matters:** Duplicate rows un 551 orders ka weight galti se double kar dete satisfaction
  averages mein — chhota lekin real bias.
- **How we detected it:** `len(df)` vs `df["order_id"].nunique()` compare kiya — fark mila.
- **What we did:** `sort_values("review_answer_timestamp")` phir
  `drop_duplicates(subset="order_id", keep="last")`.
- **Why this method:** Latest review customer ka final/updated opinion represent karta hai.
- **Result:** 99,224 → 98,673 rows. Verified: `order_id.nunique() == len(df)` → `True` (perfect
  1:1 ab).

### 6. `products` — category fill + translation merge + tiny row drop

- **Problem:** 3 issues: (a) 610 products (1.85%) missing `product_category_name`; (b) category
  translation file mein sirf 71 categories, products mein 73 raw names → 623 products bina
  English label ke; (c) 2 rows mein physical dimensions missing.
- **Why it matters:** Product/category performance analysis ke liye har product ka valid
  category label chahiye.
- **How we detected it:** `.isnull().sum()`, aur `products["product_category_name"].nunique()`
  vs `cat_trans["product_category_name"].nunique()` compare karke.
- **What we did:** (a) `.fillna("unknown")`; (b) LEFT JOIN translation table se, missing match
  bhi `"unknown"`; (c) 2 rows **drop** kiye (dimensions).
- **Why this method:** `"unknown"` ek honest label hai — fake category naam invent nahi kiya.
  2 rows itna negligible (0.006%) tha ki physical measurements fabricate karna galat hota —
  drop karna clean option tha.
- **Result:** 32,951 → 32,949 rows. Har product ke paas ab valid category label hai.

### 7. `sellers` and `geolocation`

- **Problem:** `sellers` mein same zip-leading-zero issue. `geolocation` mein 261,831
  fully-duplicate rows (~26%), aur grain "ek zip = multiple GPS-sample rows" tha.
- **Why it matters:** Duplicate rows kisi bhi join/aggregation ko inflate karte — agar
  `geolocation` ko directly `customers`/`sellers` se join karte (bina aggregate kiye), ek
  customer/seller ke liye multiple duplicate rows ban jaati (**"fan-out" join**), revenue jaisi
  metrics galti se multiply ho jaatin.
- **How we detected it:** `.duplicated().sum()` → 261,831; aur zip-groupby size check karke
  multiple-rows-per-zip pattern dekha.
- **What we did:** Zip zero-padded. Exact duplicates drop kiye (1,000,163 → 738,332). Phir
  **har zip ke liye ek representative row** banayi — `groupby(zip).agg(mean lat, mean lng,
  mode city, mode state)`: 738,332 → **19,015 rows**.
- **Why this method:** Mean lat/lng ek zip-area ka reasonable "center point" deta hai —
  GPS-level precision nahi chahiye, sirf city/region-level map visual ke liye kaafi hai.
- **Result:** Ab safely `customers`/`sellers` se 1:1 join ho sakti hai bina row-count badhaye.

### 8. Revenue definition — a deliberate, verified decision (not a "cleaning" step, but same rigor)

- **Problem:** Do candidate revenue sources the — `order_items` (price+freight) vs
  `order_payments` (payment_value). Consistency chahiye thi.
- **Why it matters:** Ek hi project ke andar do jagah do alag numbers report hona ek internal
  inconsistency hai jo credibility kharab karti hai.
- **How we detected/verified:** Dono sources ka total compare kiya (delivered orders ke liye):
  `order_items` = R$15,419,773.75 vs `order_payments` = R$15,422,461.77 — sirf 0.017% diff.
- **What we did:** `order_items` ko primary revenue source banaya.
- **Why this method:** Line-item level hai (category-breakdown seedha milta hai);
  `order_payments` mein per-order multiple/edge-case rows hoti hain (split payments).
- **Result:** Poore project mein ek hi, consistent revenue formula:
  `SUM(order_items.price + order_items.freight_value)`.

### 9. Scoping decision — only `delivered` orders for revenue/delivery/satisfaction

- **Problem:** `order_status` mein 8 alag values hain — sabko revenue mein count karna chahiye?
- **Why it matters:** Canceled/unavailable orders mein real transaction complete nahi hua —
  unhe count karna revenue ko misleadingly inflate karega.
- **How we detected:** `order_status.value_counts()` — delivered 96,478 (97.0%), baaki 7
  statuses chhote counts.
- **What we did:** Revenue/delivery/satisfaction queries mein `WHERE order_status = 'delivered'`.
  "Total orders placed" (volume metric) sabhi statuses include karta hai — dono clearly labelled.
- **Result:** Consistent scope rule jo poore SQL/Python analysis mein follow hua.

---

## Cases where we intentionally did NOT change something

| Column/Table | Kya chhoda | Kyun |
|---|---|---|
| `orders` delivery-lifecycle dates | Nulls as-is | Legitimate business-state (order abhi us stage tak nahi pahuncha) |
| `order_payments.payment_installments = 0` (2 rows) | As-is | Negligible impact, no business question depends on it |
| `products` listing-metadata (`name_lenght` etc., ~609 nulls) | As-is | Out of scope — koi required business question isse use nahi karti |
| `order_reviews` free-text fields (88%/59% null) | As-is (not used at all) | Optional feedback, out of scope (no NLP in this project) |

---

## INTERVIEW

**Q: "Tumne missing values kaise handle kiye?"**
> Category-type missing values ko `"unknown"` label diya (delete nahi kiya); date-type missing
> values ko legitimate business-lifecycle null maan kar chhoda; sirf 2 rows jahan critical
> numeric data missing thi (aur impute karna fabrication hota), unhe drop kiya.

**Q: "Duplicate data kaise identify aur handle ki?"**
> `geolocation` mein exact duplicate rows (`.duplicated()`), aur `order_reviews` mein logical
> duplicates (same `order_id` multiple baar) — alag-alag strategy use ki (drop exact dupes vs.
> keep-latest-per-key).

**Q: "Revenue kaunse column se nikala aur kyun?"**
> `order_items.price + freight_value`, cross-verified against `order_payments.payment_value`
> (0.017% difference).

**Q: "Kya saare canceled orders ko revenue mein include kiya?"**
> Nahi — sirf `delivered` orders ko revenue/delivery/satisfaction analysis mein include kiya.

**Q: "Ek concrete example do jahan bina cleaning ke result galat aata."**
> `geolocation` mein 26% duplicate rows — agar directly join karte, revenue jaisi metrics
> fan-out ki wajah se multiply ho jaatin.

**Q: "Kya har missing value ko fill/delete karna chahiye?"**
> Nahi — kabhi-kabhi null khud ek **valid business state** hai (jaise "order deliver hi nahi
> hua"). Isko fill karna galat/fake data create karega.

---

## What I should remember

- Golden rule: kabhi blindly delete/fill mat karo — har decision ka reason document karo.
- 3 tarah ki "no-change-needed" situations: legitimate lifecycle nulls, negligible anomalies,
  out-of-scope columns — sab explicitly reasoned, "laziness" se nahi.
- Revenue formula aur "delivered-only" scope — poore project ke 2 sabse important, sabse
  zyada repeat hone wale design decisions.
- Duplicate types: exact (`geolocation`) vs logical (`order_reviews`) — alag detection, alag fix.
- Full summary table (rows before/after): [02_data_cleaning.md](../02_data_cleaning.md) mein hai.
