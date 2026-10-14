# 14 — Customer Segmentation (RFM)

## 1. Why do businesses segment customers? (GENERAL)

Ek company ke paas agar 96,096 customers hain, unhe **individually** treat karna practically
impossible hai. **Segmentation** ka matlab hai customers ko chhote, meaningful **groups** mein
baantना, taaki business har group ke liye ek **targeted strategy** bana sake — jaise ek group
ko discount email, doosre ko VIP treatment.

**Analogy:** Ek school teacher 100 students ko individually alag padhaने ki jagah, unhe
"weak/average/strong" groups mein baantती hai, aur har group ke liye alag teaching-strategy
banaती hai — segmentation bhi bilkul yehi karta hai, business customers ke liye.

## 2. What is RFM?

RFM ek **simple, classic, explainable** customer-segmentation technique hai jo sirf **3
numbers** se har customer ko categorize karta hai:

| Letter | Full form | Matlab | Business Question |
|---|---|---|---|
| **R** | Recency | Customer ne **kितne din pehle** last order kiya | "Yeh customer abhi bhi active hai ya gayab ho gaya?" |
| **F** | Frequency | Customer ne **kितni baar** order kiya | "Yeh customer regular hai ya one-time?" |
| **M** | Monetary | Customer ne **total kितna** spend kiya | "Yeh customer financially kितna valuable hai?" |

**Why RFM specifically (not something else)?** Yeh **ML/clustering se bahut simpler** hai (koi
model training nahi, sirf SQL) lekin phir bhi ek real, professional segmentation story deta hai
— is project ke goal (beginner-defensible, har hissa explainable) ke liye perfect fit.

## 3. Formula

$$\text{Recency} = \text{reference\_date} - \text{customer's last order date}$$
$$\text{Frequency} = \text{count of distinct delivered orders by that customer}$$
$$\text{Monetary} = \sum (\text{price} + \text{freight\_value}) \text{ across all their delivered orders}$$

### The "reference_date" problem (important, generalizable lesson)

Normally RFM mein "aaj ki date" use hoती hai. Lekin yeh dataset **historical/fixed** hai
(2016-2018 ka) — agar hum real `today()` use karte, **HAR** customer ka recency 2000+ din
dikhता (kyunki dataset khud purana hai), jo useless hota. Isliye hum **dataset ke andar ki
sabse latest order date** ko "today" maan kar use karte hain:

```sql
(SELECT MAX(order_purchase_timestamp) FROM orders WHERE order_status = 'delivered')
```

> 📌 **Generalizable lesson (interview mein bolne layak):** Kisi bhi historical/static dataset
> par RFM karte waqt, "today" = dataset ki khud ki latest date, real-world current date nahi.

## 4. How customers enter each segment — Step by Step

### Step 1 — Raw RFM values (SQL CTE `rfm_base`)

Har `customer_unique_id` ke liye: `MAX(order_purchase_timestamp)` (last order),
`COUNT(DISTINCT order_id)` (frequency), `SUM(price+freight)` (monetary).

### Step 2 — Scoring (0-100 ki jagah, ek chhota 1-4 score)

**Recency aur Monetary — `NTILE(4)` window function:**

```sql
NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
NTILE(4) OVER (ORDER BY monetary ASC)      AS m_score
```

- `NTILE(4)` saare customers ko value ke hisab se sort karke **4 barabar-size groups**
  (quartiles) mein baantता hai — group 1, 2, 3, 4.
- `ORDER BY monetary ASC` → kam spend = score 1 (worst), zyada spend = score 4 (best). Seedha.
- `ORDER BY recency_days DESC` → **yeh ulta lagta hai but sahi hai.** `recency_days` = "kितne
  din se order nahi kiya" — zyada `recency_days` = zyada stale/bura. Humein chahiye stale
  customers ko score 1, abhi-abhi order karने walon ko score 4. `NTILE` hamesha sorted-order mein
  **pehle aane wali rows ko bucket 1** deta hai — isliye stale (bade recency_days) ko pehle
  laane ke liye `DESC` chahiye.
- ⚠️ **Ek real bug jo humne khud pakड़ी:** Pehli baar `ASC` likha tha (galat), jisse result ulta
  aaya (stale customers ko best r_score mil raha tha) — verify karte waqt pakड़ी aur `DESC` kiya.
  **Genuinely common RFM-scoring mistake, interview mein pooch sakte hain.**

**Frequency — `NTILE` NAHI, fixed `CASE WHEN` (important design decision):**

```sql
CASE
    WHEN frequency = 1 THEN 1
    WHEN frequency = 2 THEN 2
    WHEN frequency BETWEEN 3 AND 5 THEN 3
    ELSE 4
END AS f_score
```

**Kyun NTILE nahi use kiya frequency ke liye?** ~97% customers ki frequency exactly `1` hai
(sirf 3% repeat karte hain — file 13). Jab itni saari rows ek hi value par "tied" hoti hain,
`NTILE(4)` unhe **arbitrarily** 4 groups mein baant deta (kisi meaningful order ke bina) — ek
customer jisne sirf 1 order kiya, use kabhi-kabhi `f_score = 4` (best!) mil jaata, jo galat hai.
**Fix:** Fixed, business-meaningful buckets (`CASE WHEN`).

> 📌 **Interview-ready lesson:** "Jab data highly skewed/tied ho, equal-population techniques
> (NTILE) ki jagah fixed meaningful thresholds zyada reliable hote hain."

### Step 3 — Final Segment (combining R/F/M scores)

```sql
CASE
    WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'High Value'
    WHEN f_score >= 3                                    THEN 'Loyal'
    WHEN r_score <= 2 AND m_score >= 3                   THEN 'At Risk'
    WHEN r_score >= 3                                    THEN 'Recent'
    ELSE 'Low Engagement'
END AS customer_segment
```

**Order matters** (top-se-neeche, pehla match wins):

| # | Segment | Kaise enter karta hai | Simple meaning |
|---|---|---|---|
| 1 | **High Value** | R aur F aur M teeno high (≥3) | Best customers — recent, frequent, aur bade spender |
| 2 | **Loyal** | F high (≥3), chahe R/M kuch bhi ho | Frequently order karta hai — repeat-buyer ko credit |
| 3 | **At Risk** | R low (≤2) LEKIN M high (≥3) | Stale ho gaya, lekin pehle achha spend karta tha |
| 4 | **Recent** | R high (≥3), lekin F/M standout nahi | Naya/casual customer, abhi-abhi aaya |
| 5 | **Low Engagement** | Baaki sab (na recent, na frequent, na high-spend) | Sabse low-priority segment |

## 5. Real Results (verified)

| Segment | Customers | % | Total Revenue | Avg Revenue/Customer |
|---|---|---|---|---|
| **Recent** | 46,536 | 49.85% | R$ 77,21,596 | R$ 165.93 |
| **At Risk** | 22,690 | 24.30% | R$ 60,54,161 | R$ 266.82 |
| **Low Engagement** | 23,904 | 25.60% | R$ 15,28,641 | R$ 63.95 |
| **High Value** | 141 | 0.15% | R$ 76,376 | R$ 541.68 |
| **Loyal** | 87 | 0.09% | R$ 38,999 | R$ 448.27 |

## 6. What each segment means, and what the company can do

- **Recent (49.85%, sabse bada):** Naye/casual one-time buyers, recently active. **Action:**
  "Second purchase" nudge (discount/reminder) — inhe repeat customer banane ka best window
  abhi hai.
- **At Risk (24.30%, 2nd-highest avg spend R$266.82):** Pehle achha spend karte the, ab
  inactive. **Action:** Sabse high-priority "win-back" segment — proven spending capability
  ki wajah se ROI sabse zyada.
- **Low Engagement (25.60%, lowest avg spend):** Na recent, na frequent, na high-spend.
  **Action:** Low marketing priority.
- **High Value (0.15%, highest avg R$541.68):** Best customers. **Action:** VIP treatment,
  early access, personal outreach.
- **Loyal (0.09%):** Genuinely repeat/frequent buyers. **Action:** Loyalty rewards/referral
  program.

> ⚠️ **Honest limitation:** Repeat-purchase rate sirf ~3% hai poore dataset mein, isliye "High
> Value" aur "Loyal" segments bahut chhote hain (141 aur 87 customers). Yeh RFM method ki galti
> nahi — yeh **is specific business/dataset ki reality** hai (Olist ek marketplace-aggregator
> hai, direct-retailer jaisा brand-loyalty pattern kam expected hai yahan).

## 7. RFM vs ML Clustering (K-Means) — why RFM here

| | RFM (used here) | K-Means / ML Clustering |
|---|---|---|
| **Kaise kaam karta hai** | Fixed rules/thresholds (quartiles + CASE WHEN) | Algorithm khud similar customers ko group karta hai |
| **Explainability** | 100% explainable — har rule bata sakte ho | Kam explainable ("black box"-ish) |
| **Complexity** | Simple SQL | Model training, feature scaling, choosing "k", etc. |
| **Is project ke liye fit** | ✅ Beginner-safe, fully defensible | ❌ Unnecessarily complex for stated scope |

> **Interview:** *"RFM aur K-Means mein choose karna ho toh kaise decide karoge?"* → Agar
> explainability/simplicity priority hai (jaise ek entry-level portfolio project, ya business
> stakeholders ko "why" samajhna zaroori hai) → RFM. Agar bahut zyada dimensions/features hain
> aur "natural groupings" khud discover karni hain → ML clustering.

## 8. Segment can change over time

Ek customer ka segment **static nahi hai** — jab bhi naya order/time-gap aata hai, recompute
karne par segment badal sakta hai. E.g. ek "At Risk" customer agar dobara order kare, wo
"Recent" ya "Loyal" ban sakta hai next recompute mein.

---

## INTERVIEW

**Q: "RFM kya hai, apne shabdon mein?"** → 3-part scoring: Recency, Frequency, Monetary — inhe
combine karke customer segments banaते hain.

**Q: "RFM ke liye 'today' kaise decide ki, jab dataset 2016-2018 ka hai?"** → Dataset ki khud
ki latest order date ko reference point maana, real current date nahi.

**Q: "NTILE() kya karta hai?"** → Rows ko unke ek column ke value ke hisab se sort karke N
barabar-size groups mein baantता hai — window function hai, GROUP BY jaisa squash nahi karta.

**Q: "Frequency ke liye NTILE kyun nahi use kiya?"** → ~97% customers tied the frequency=1 par
— NTILE aise data ko arbitrarily split karta, isliye fixed CASE WHEN buckets use kiye.

**Q: "High Value aur Loyal mein fark?"** → High Value = teeno (R,F,M) high; Loyal = sirf
Frequency high, chahe recent na ho ya monetary standout na ho.

**Q: "Ek bug tumne khud pakड़ा RFM mein?"** → Recency-scoring direction bug — pehli baar `ASC`
likha tha jo ulta result de raha tha, verify karke `DESC` fix kiya.

**Q: "Yeh clustering se kaise alag hai?"** → Section 7 ka table use karo.

---

## What I should remember

- RFM = Recency + Frequency + Monetary, sabko score (1-4) karke CASE WHEN se 5 segments.
- "Today" = dataset ki latest date, real current date nahi (historical dataset ka rule).
- Recency: `NTILE(4) ORDER BY recency_days DESC`. Monetary: `NTILE(4) ORDER BY monetary ASC`.
  Frequency: fixed CASE WHEN (kyunki NTILE tied-data ke saath fail karta).
- Segment priority order (CASE WHEN top-to-bottom): High Value > Loyal > At Risk > Recent >
  Low Engagement.
- "At Risk" = sabse important business insight (2nd-highest avg spend, best win-back target).
- RFM chosen over ML clustering for explainability + project-scope fit — not because ML is
  "worse," but because it doesn't fit this project's stated goals.
