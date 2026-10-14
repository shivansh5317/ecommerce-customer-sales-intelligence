# 13 — Customer Analysis

## GENERAL — How does a Data Analyst think about customers?

Customer analysis ka matlab hai company ke customer-base ko **individual transactions se
zyada, patterns ki tarah** dekhna:

| Lens | Sawal jo yeh answer karta hai |
|---|---|
| **Customer count** | Kitne log hamare customers hain? |
| **New vs Repeat** | Kitne log pehli baar aaye, kitne dobara aaye? |
| **Purchase frequency** | Log kितni baar order karte hain? |
| **Spending behavior** | Log kितna kharch karte hain (per order, lifetime)? |
| **Customer value** | Kaunse customers business ke liye sabse zyada valuable hain? |
| **Retention** | Kya log wapas aate hain, ya ek baar khareed kar chale jaate hain? |
| **Customer distribution** | Customers kahan (geography) se hain, kaise spread hain? |

**Why this matters for a business:** Naye customer laana (acquisition) usually **mehnga**
hota hai marketing-cost ke hisab se; existing customer ko wapas laana (retention) usually
**sasta** hota hai. Isliye company ko dono cheezein track karni padti hain — sirf "kitne naye
customer aaye" dekhna adhoora picture hai.

---

## MY PROJECT — Har Analysis Ka Deep-Dive

### Analysis 1 — Total Unique Customers

- **Question:** Kitne unique real customers hain?
- **Data required:** `customers.customer_unique_id`
- **Logic:** `COUNT(DISTINCT customer_unique_id)`
- **Result:** 96,096
- **Business interpretation:** Baseline customer-base size — future growth/comparison ke liye
  reference point.

### Analysis 2 — Repeat vs One-Time Customers

- **Question:** Kitne customers ek se zyada baar order karte hain?
- **Data required:** `customers` + `orders` (delivered only), grouped by `customer_unique_id`.
- **Logic:** Har customer ka orders_count nikalo, phir `= 1` vs `> 1` mein bucket karo.
- **Result:** One-time = 90,557 (94.3%) · Repeat = 2,801 (2.9% of all customers who ordered;
  3.0% among those specifically counted in the delivered-orders CTE).
- **Business interpretation:** Retention **weak spot** hai — acquisition strong lagता hai
  (steady order growth), lekin dobara khareedne ke liye convince karna kam ho raha hai.

### Analysis 3 — Highest-Value Customers

- **Question:** Sabse zyada value wale customers kaun hain?
- **Data required:** `customers` + `orders` + `order_items`, grouped by `customer_unique_id`,
  summed spend.
- **Result (top 3):** R$13,664 (1 order) · R$7,572 (2 orders) · R$7,275 (1 order).
- **Business interpretation:** **"Highest spender" ≠ "most loyal."** Top spender ne sirf ek
  bada purchase kiya (likely ek premium item) — yeh "loyal repeat shopper" wala pattern nahi
  hai. Dono alag business value rakhते hain — RFM segmentation (file 14) is difference ko
  explicitly capture karta hai.

### Analysis 4 — Purchase Frequency Distribution

- **Question:** Order-frequency ka overall spread kaisa hai?
- **Result:** 1 order → 90,557 · 2 orders → 2,573 · 3-5 orders → 218 · 6+ orders → 10.
- **Business interpretation:** Distribution **heavily skewed** hai ek-order-customers ki taraf
  — is fact ne hi RFM scoring mein Frequency ke liye `NTILE` (equal-population split) ki jagah
  fixed `CASE WHEN` buckets use karne ka decision drive kiya (file 14 mein poora reasoning).

### Analysis 5 — Average Spend per Customer

- **Question:** Ek customer se lifetime average kitna aata hai?
- **Result:** R$165.17 (AOV se thoda zyada, dekho file 12).

### Analysis 6 — Customer Distribution by State

- **Question:** Customers geographically kaise spread hain?
- **Data required:** `customers.customer_state`
- **Result:** SP mein sabse zyada unique customers (aur revenue bhi — dekho file 17 Insight 2).
- **Business interpretation:** Customer-base bhi utni hi concentrated hai jitni revenue —
  dono saath consistent hain (SP hi Olist ka home-market/hub bhi hai).

---

## What "Retention" Means Here (basics, project ke context mein)

Is project mein hum **formal retention-rate cohort analysis** (jaise "Month-1 customers mein se
kitne Month-2 mein wapas aaye") nahi karte — yeh ek zyada advanced time-based analysis hota
(cohort analysis), jo scope se bahar rakha gaya. Iski jagah hum ek **simpler, static** measure
use karte hain: "kitne % customers ne overall 1-se-zyada order kiya" (repeat-purchase rate) —
yeh RFM segmentation (file 14) se aur bhi refine hota hai (Recency ke through).

> **Interview Tip:** Agar poocha jaaye "cohort retention analysis kiya?" — honest bolo: "Nahi,
> maine simpler repeat-purchase-rate aur RFM Recency use ki hai retention proxy ke liye; time-
> based cohort analysis is project ke scope se bahar tha, ek possible future improvement hai."

---

## INTERVIEW

**Q: "Customer analysis mein sabse pehla step kya hota hai?"**
> Sahi "customer" identifier decide karna — is dataset mein `customer_unique_id` (real person),
> na ki `customer_id` (order-level). Galat identifier se pura analysis galat ho jaata hai.

**Q: "Agar tumhe ek naya customer-related metric banana ho, kya banaओge?"**
> Ek achha answer: "Customer Lifetime Value (CLV)" ka ek proper time-adjusted version, ya
> "time-to-second-purchase" (average kितne din mein customer dobara order karta hai) — dono
> is project ke current scope se aage extensions hain.

**Q: "Highest-spend customer ko company kaise treat kare?"**
> Depends: agar wo ek one-time-bulk-buyer hai, unhe "repeat" banana ka target set karna galat
> framing hoga — RFM jaisा framework use karke pehle unka **segment** samajhna chahiye
> (dekho file 14).

---

## What I should remember

- Customer analysis = count + new-vs-repeat + frequency + spend + value + distribution.
- Repeat-purchase rate (~3%) is project ka sabse actionable customer-side finding hai.
- "Highest spender" aur "most loyal" alag concepts hain — is fark ko explicitly bolna interview
  mein maturity dikhata hai.
- Formal cohort-retention analysis is project mein nahi hai (honest limitation) — RFM Recency
  ek simpler proxy deta hai.
- Agla file ([14_CUSTOMER_SEGMENTATION.md](14_CUSTOMER_SEGMENTATION.md)) in sab insights ko ek
  structured **segmentation framework** mein combine karta hai.
