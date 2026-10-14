# 12 — Business Metrics

> Sirf wahi metrics jo is project mein **actually calculate** hue hain. Har metric: Definition
> → Formula → Simple example → Business meaning → Where used → Interview → Common confusion.

---

## 1. Revenue (Total Revenue)

- **Definition:** Total money jo delivered orders se aaya (products + shipping).
- **Formula:** $\text{Revenue} = \sum (\text{price} + \text{freight\_value})$, delivered orders only.
- **Simple example:** 3 orders — R$100, R$150, R$80 → total revenue = R$330.
- **Business meaning:** Company ka top-line financial performance — sabse basic "kitna business
  hua" number.
- **Where used:** `sql/01` Query 1; poore project ka baseline number.
- **Result:** R$ 15,419,773.75.
- **Interview:** *"Revenue aur Profit mein fark?"* → Revenue = total inflow (bina cost ghataye);
  Profit = Revenue − Costs. **Is project mein hum sirf Revenue calculate karte hain — Profit
  nahi, kyunki dataset mein product cost/COGS ka data hi nahi hai** — yeh ek honest limitation
  hai, bolne layak.
- **Common confusion:** "Total orders placed" (99,441) ≠ "Revenue-generating orders" (delivered,
  96,478) — dono alag scope hain.

## 2. Orders (Order Count)

- **Definition:** Kitne distinct orders place/deliver hue.
- **Formula:** `COUNT(DISTINCT order_id)`.
- **Business meaning:** Demand/volume ka signal — revenue se independent (ek order chhota bhi
  ho sakta hai, bada bhi).
- **Where used:** Har sales/category query mein `orders_count` column.
- **Result:** 99,441 total placed; 96,478 delivered (97.0%).
- **Interview:** *"Order count aur Revenue dono zaroori kyun hain?"* → Order count "kitne log
  khareed rahe hain" batata hai, revenue "kitna kama rahe hain" — dono divergent ho sakte hain
  (dekho Insight 4 — `bed_bath_table` volume-leader, revenue mein 3rd).

## 3. Average Order Value (AOV)

- **Definition:** Ek order ka average total value.
- **Formula:** $\text{AOV} = \dfrac{\text{Total Revenue}}{\text{Total Orders}}$
- **Simple example:** Total revenue R$330, 3 orders → AOV = R$110.
- **Business meaning:** Pricing/bundling strategy ke liye baseline — "average customer ek baar
  mein kitna khareedta hai."
- **Where used:** `sql/01` Query 3 (subquery-based — dekho file 06 grain-mismatch lesson).
- **Result:** R$ 159.83.
- **Interview:** *"AOV directly `AVG(price)` se kyun nahi nikalte?"* → **Sabse important
  interview trap is project mein** — `order_items` line-item-level hai; directly average lene
  se multi-item orders galat weight ho jaate. Pehle per-order total banao (GROUP BY order_id),
  phir uska average lo.
- **Common confusion:** AOV (per-order) vs Avg Spend per Customer (per-person, lifetime) —
  agla metric dekho.

## 4. Average Spend per Customer

- **Definition:** Ek customer (lifetime) se average kitna revenue aata hai.
- **Formula:** Per-customer total spend ka average (`GROUP BY customer_unique_id` phir `AVG`).
- **Business meaning:** Customer Lifetime Value ka ek simple proxy.
- **Result:** R$ 165.17 (AOV se thoda zyada — repeat customers ka effect).
- **Interview:** *"Yeh AOV se different kyun hai?"* → AOV = per-**order**; yeh = per-**customer**
  (jo multiple orders karta hai uska total is mein zyada weight leta hai).

## 5. Repeat Purchase Rate

- **Definition:** Kitne % unique customers ne **ek se zyada baar** order kiya.
- **Formula:** $\dfrac{\text{customers with} > 1 \text{ order}}{\text{total unique customers}} \times 100$
- **Business meaning:** Customer retention/loyalty ka sabse direct signal.
- **Where used:** `sql/02` Query 2 & 3.
- **Result:** **3.0%** (2,801 of 96,096).
- **Interview:** *"3% bahut kam lagta hai — kya yeh problem hai?"* → Business-context-dependent:
  Olist ek marketplace-aggregator hai (customer brand se nahi, individual sellers se khareedता
  hai) — isliye direct-retailer jaisा repeat-purchase pattern kam expected hai. Phir bhi, yeh
  ek clear **growth lever** hai (dekho Insight 3).
- **Common confusion:** Yeh calculation `customer_unique_id` par based honा chahiye,
  `customer_id` par nahi (warna 0% dikhega, poori tarah galat).

## 6. Customer Count (Unique Customers)

- **Definition:** Kitne distinct real log hain.
- **Formula:** `COUNT(DISTINCT customer_unique_id)`.
- **Result:** 96,096.

## 7. Customer Rating / Review Score

- **Definition:** Customer satisfaction, 1-5 star scale.
- **Formula:** `AVG(review_score)`.
- **Business meaning:** Quality/satisfaction ka core signal.
- **Where used:** Category-wise (`sql/03` Query 3), delivery-status-wise (`sql/05` Query 4).
- **Result:** Overall distribution bimodal; on-time 4.29★ vs late 2.57★; worst category
  `office_furniture` 3.49★.
- **Interview:** *"Sirf average rating dekhna kaafi hai?"* → Nahi — bimodal distribution (bahut
  saare 1★ bhi) average ke peeche chhup sakta hai. Distribution (histogram) bhi dekhna zaroori.

## 8. Delivery Time (Avg Delivery Days)

- **Definition:** Order-purchase se customer-delivery tak average din.
- **Formula:** `AVG(julianday(delivered_date) - julianday(purchase_date))`.
- **Business meaning:** Operational efficiency ka core KPI.
- **Result:** ~12.6 days average, right-skewed (lambi tail slow-outliers ki).

## 9. On-Time Delivery %

- **Definition:** Kitne % orders Olist ke apne estimate ke andar (ya usse pehle) deliver hue.
- **Formula:** $\dfrac{\text{orders where delivered\_date} \le \text{estimated\_date}}{\text{total delivered orders with a date}} \times 100$
- **Business meaning:** Customer-expectation-management ka KPI — sirf "fast" hone se zyada
  important hai "jo bola wahi hua."
- **Where used:** `sql/05` Query 2; Power BI measure `On-Time Delivery %`.
- **Interview:** *"On-time ka matlab 'jaldi' hai?"* → Nahi — on-time ka matlab hai **apne hi
  diye gaye estimate ke against** time par — ek order 20 din bhi le sakta hai aur phir bhi
  "on-time" ho agar estimate 25 din tha.

## 10. Revenue Concentration (% of Total)

- **Definition:** Ek segment/state/category ka total revenue mein % share.
- **Formula:** $\dfrac{\text{segment revenue}}{\text{total revenue}} \times 100$
- **Where used:** `sql/04` Query 4 — state-wise share.
- **Result:** SP = 37.42% (single biggest concentration finding of the project).

## 11. RFM Metrics (Recency, Frequency, Monetary)

Poora dedicated file: [14_CUSTOMER_SEGMENTATION.md](14_CUSTOMER_SEGMENTATION.md).

---

## What's NOT in this project (be honest if asked)

- **Conversion Rate** (visits → purchases) — dataset mein koi website-traffic/visit data nahi
  hai, sirf completed orders hain. Isliye conversion rate calculate **nahi** kiya ja sakta is
  data se.
- **Profit / Margin** — koi product-cost (COGS) data nahi hai, sirf selling price. Isliye sirf
  Revenue track kiya, Profit nahi.
- **Customer Acquisition Cost (CAC)** — koi marketing-spend data nahi hai.

> **Interview Tip:** Agar poocha jaaye "conversion rate kya tha," honest bolo: "Is dataset mein
> traffic/visit data nahi hai, sirf completed orders — isliye conversion rate calculate karna
> possible nahi tha is scope mein." Yeh galat/invented answer dene se **kahin behtar** hai.

---

## INTERVIEW — General Metric Questions

**Q: "Metric aur KPI mein fark?"** → File 01 dekho — har KPI metric hai, har metric KPI nahi.

**Q: "Agar revenue badh raha hai lekin repeat-rate kam hai, kya business healthy hai?"**
> Mixed signal — **acquisition** (naye customers) strong hai, lekin **retention** weak hai.
> Long-term sustainable growth ke liye dono chahiye — sirf naye customers par depend karna
> risky hai (acquisition cost badhta rehta hai). Yeh bilkul is project ka real pattern hai
> (dekho Insight 3 aur 6).

**Q: "Kaunsa single metric sabse important hai is project mein?"**
> Depends on framing, lekin defensible answer: **On-Time Delivery %**, kyunki yeh directly
> customer satisfaction (rating) se strongly linked hai (Insight 1) — ek operational metric
> jo seedha ek outcome-metric ko drive karta hai.

---

## What I should remember

- Revenue, Orders, AOV, Avg Spend/Customer, Repeat Rate, Customer Count, Rating, Delivery Time,
  On-Time %, Revenue Concentration, RFM — sab **actually calculated** metrics hain.
- Conversion Rate/Profit/CAC — dataset mein possible nahi, honestly bolna hai agar poocha jaaye.
- AOV ka grain-mismatch trap sabse important interview point hai poore metrics section mein.
