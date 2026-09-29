# 04 — Customer Segmentation (RFM)

## 1. Concept — RFM kya hai aur kyun useful hai

**RFM** ek simple, classic customer-segmentation technique hai jo sirf **3 numbers** se har
customer ko categorize karta hai:

| Letter | Full form | Matlab | Business question jo yeh answer karta hai |
|---|---|---|---|
| **R** | Recency | Customer ne **kitne din pehle** last order kiya | "Yeh customer abhi bhi active hai ya gayab ho gaya?" |
| **F** | Frequency | Customer ne **kitni baar** order kiya | "Yeh customer regular hai ya one-time?" |
| **M** | Monetary | Customer ne **total kitna** spend kiya | "Yeh customer business ke liye financially kitna valuable hai?" |

**Why useful hai (business case):** Har customer ko individually treat karna practically
impossible hai (yahan 96,096 customers hain!). RFM unhe **thodi si categories** mein baant
deta hai (e.g. "High Value", "At Risk") taaki marketing/business team **targeted actions** le
sake — jaise "At Risk" segment ko ek discount email bhejna, ya "High Value" segment ko VIP
treatment dena. Yeh **ML/clustering se bahut simpler** hai (koi model training nahi, sirf SQL)
lekin phir bhi resume/portfolio mein "customer segmentation" jaisa hi professional dikhta hai —
isliye is project ke liye perfect fit hai (advanced ML avoid karte hue bhi ek real segmentation
story milti hai).

## 2. Formula — har part kaise calculate hota hai

$$\text{Recency} = \text{reference\_date} - \text{customer's last order date}$$

$$\text{Frequency} = \text{count of distinct delivered orders by that customer}$$

$$\text{Monetary} = \sum (\text{price} + \text{freight\_value}) \text{ across all their delivered orders}$$

**"reference_date" ek important detail hai:** Normally RFM mein "aaj ki date" use hoti hai. Lekin
yeh dataset **historical/fixed** hai (2016-2018 ka, "aaj" nahi chal raha) — agar hum real
`today()` use karte, toh HAR customer ka recency 2000+ din dikhta (kyunki dataset khud purana
hai), jo useless hota. Isliye hum **dataset ke andar ki sabse latest order date** ko "today" maan
kar use karte hain:

```sql
(SELECT MAX(order_purchase_timestamp) FROM orders WHERE order_status = 'delivered')
```

Yeh ek **important, generalizable lesson hai**: kisi bhi historical/static dataset par RFM
karte waqt, "today" = dataset ki khud ki latest date, real-world current date nahi.

## 3. Implementation (SQL) — step by step

Poora code `sql/06_customer_segmentation.sql` mein hai. Yahan concept-by-concept breakdown:

### Step 1 — Raw RFM values

```sql
WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.price + oi.freight_value) AS monetary
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
```
Har customer (`customer_unique_id`) ke liye: unka sabse recent order kab tha (`MAX`), kitni
baar order kiya (`COUNT DISTINCT`), aur total kitna spend kiya (`SUM`) — sab ek `GROUP BY` mein.

### Step 2 — Scoring (0 se seedha number use karne ke bajaye, 1-4 ka score banate hain)

**Recency aur Monetary ke liye — `NTILE(4)` window function (naya concept):**

```sql
NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
NTILE(4) OVER (ORDER BY monetary ASC)      AS m_score
```

**`NTILE(4)` kya karta hai (simple explanation):** Saare customers ko unke value ke hisab se
sort karke, **4 barabar-size groups** (quartiles) mein baant deta hai — group 1, 2, 3, 4. Yeh
ek "window function" hai, matlab `GROUP BY` ki tarah rows ko squash nahi karta — **har customer
apni individual row rakhta hai**, bas ek extra column (`r_score`, `m_score`) mil jaata hai.

- `ORDER BY monetary ASC` → kam spend karne wale customers ko score 1 (worst), zyada spend
  karne walon ko score 4 (best) milta hai. Seedha/intuitive.
- `ORDER BY recency_days DESC` → **yeh ulta lagta hai but sahi hai**: `recency_days` = "kitne
  din se order nahi kiya" — matlab **zyada** `recency_days` = **zyada stale/bura**. Humein
  chahiye ki **stale customers ko score 1 (worst)** aur **abhi-abhi order karne walon ko score
  4 (best)** mile. `NTILE` hamesha ORDER BY sequence mein PEHLE aane wali rows ko bucket 1 deta
  hai — isliye stale (bade recency_days) ko pehle laane ke liye humein `DESC` chahiye.
  ⚠️ **Humne yeh galti khud pehli baar `ASC` likh kar ki thi** aur result ulta aaya tha
  (stale customers ko best r_score mil raha tha) — verify karte waqt pakड़ी aur fix ki. **Yeh
  ek genuinely common RFM-scoring mistake hai, interview mein bhi pooch sakte hain.**

**Frequency ke liye — `NTILE` NAHI, seedha `CASE WHEN` (important design decision):**

```sql
CASE
    WHEN frequency = 1 THEN 1
    WHEN frequency = 2 THEN 2
    WHEN frequency BETWEEN 3 AND 5 THEN 3
    ELSE 4
END AS f_score
```

**Kyun NTILE use nahi kiya frequency ke liye?** Humne pehle try kiya tha, lekin ek problem
mili: **~97% customers ki frequency exactly `1` hai** (Query 2.2/2.5 se pata chala — sirf 3%
log repeat karte hain). Jab itni saari rows ek hi value par "tied" hoti hain, `NTILE(4)`
**inn tied rows ko bhi arbitrarily 4 groups mein baant deta hai** (kisi bhi meaningful order
ke bina, bas jo order data mein aaya usi hisab se) — isse ek customer jisne sirf 1 order kiya
ho, use bhi kabhi-kabhi **f_score = 4 (best!)** mil jaata, jo galat/misleading hai.
**Fix:** Fixed, business-meaningful buckets use kiye (1 order / 2 orders / 3-5 / 6+) — simple
`CASE WHEN`, koi window function ki zaroorat nahi. **Yeh ek achha data-science judgment call
hai jo interview mein explain karne layak hai:** "Jab data highly skewed/tied ho, equal-population
techniques (NTILE) ki jagah fixed meaningful thresholds zyada reliable hote hain."

### Step 3 — Final segment (CASE WHEN combining all 3 scores)

```sql
CASE
    WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'High Value'
    WHEN f_score >= 3                                    THEN 'Loyal'
    WHEN r_score <= 2 AND m_score >= 3                   THEN 'At Risk'
    WHEN r_score >= 3                                    THEN 'Recent'
    ELSE 'Low Engagement'
END AS customer_segment
```

**Order of conditions matters** (SQL `CASE WHEN` top-se-neeche check karta hai, jo pehla match
hota hai wahi use hota hai):
1. **High Value** — teeno scores (recent + frequent + big spender) high hain — best customers.
2. **Loyal** — frequently order karta hai (chahe recent na ho ya spend zyada na ho) — repeat
   buyers ko loyalty ka credit milta hai.
3. **At Risk** — **stale ho gaya hai (r_score kam) LEKIN pehle achha spend karta tha
   (m_score high)** — yeh classic "hum ek valuable customer khone wale hain" segment hai.
4. **Recent** — abhi-abhi order kiya (r_score high) lekin frequency/monetary abhi standout
   nahi — naya ya casual customer.
5. **Low Engagement** — baaki sab (na recent, na frequent, na high-spend) — sabse low-priority
   segment.

### Step 4 — VIEW (reuse ke liye)

```sql
CREATE VIEW customer_rfm AS
    <poora upar wala query>
```

**`VIEW` kya hai:** Ek **saved query** jise ek "virtual table" ki tarah treat kar sakte ho —
`SELECT * FROM customer_rfm` likhne se poora RFM computation automatically chal jaata hai,
bina us lambi CTE-chain ko baar-baar likhe. Isse `sql/06_customer_segmentation.sql` ki baaki
queries (aur Power BI import) clean rehte hain.

## 4. Real Results (verified — `python scripts/run_sql.py sql/06_customer_segmentation.sql`)

| Segment | Customers | % of customers | Total Revenue | Avg Revenue/Customer |
|---|---|---|---|---|
| **Recent** | 46,536 | 49.85% | R$ 77,21,596 | R$ 165.93 |
| **At Risk** | 22,690 | 24.30% | R$ 60,54,161 | R$ 266.82 |
| **Low Engagement** | 23,904 | 25.60% | R$ 15,28,641 | R$ 63.95 |
| **High Value** | 141 | 0.15% | R$ 76,376 | R$ 541.68 |
| **Loyal** | 87 | 0.09% | R$ 38,999 | R$ 448.27 |

*(Exported to `data/processed/customer_segments.csv` for Power BI — via
`scripts/export_customer_segments.py`.)*

## 5. Business Meaning — har segment ka matlab aur possible action

- **Recent (49.85% customers, sabse bada segment):** Naye ya casual one-time buyers jo
  recently order kar chuke hain. **Action:** Ek "second purchase" nudge (discount/reminder
  email) bhejna — inhe repeat customer banane ka best window abhi hai (jab tak "recent" hain).
- **At Risk (24.30%, but 2nd-highest avg spend R$266.82):** Yeh log **kaafi accha spend karte
  the** lekin kaafi time se order nahi kiya. **Action:** Sabse high-priority "win-back" segment
  hai — inn per targeted re-engagement campaign ka ROI sabse zyada ho sakta hai (kyunki inki
  proven spending capability already high hai).
- **Low Engagement (25.60%, lowest avg spend R$63.95):** Na recent, na frequent, na high-spend.
  **Action:** Low marketing priority — inpe zyada resource kharch karna low-ROI hoga.
- **High Value (sirf 0.15%, lekin R$541.68 avg — sabse zyada):** Company ke best customers.
  **Action:** VIP treatment, early access to new products, personal outreach — inhe kabhi lose
  nahi karna.
- **Loyal (sirf 0.09%):** Genuinely repeat/frequent buyers. **Action:** Loyalty rewards/referral
  program — inhi jaisa behavior baaki customers mein encourage karna business goal ho sakta hai.

⚠️ **Honest limitation (interview mein bolne layak):** Is dataset mein repeat-purchase rate sirf
~3% hai (Query 2.2), isliye "High Value" aur "Loyal" segments bahut chhote hain (141 aur 87
customers). Yeh RFM method ki galti nahi hai — yeh **is specific business/dataset ki reality**
hai (Olist marketplace mein customers shayad hi dubara wahi seller/product dhoondte hain, kyunki
Olist khud ek "marketplace aggregator" hai, brand loyalty jaisa direct-retailer wala pattern
yahan kam hai).

## 6. Interview Questions

- **Q: RFM kya hai?** → 3-part customer scoring: Recency (kitna recent order), Frequency (kitni
  baar order), Monetary (kitna spend) — inhe combine karke customer segments banate hain.
- **Q: RFM ke liye "today" ki date kaise decide ki, jab dataset 2016-2018 ka hai?** → Real
  current date use nahi ki, dataset ki khud ki sabse latest order date ko reference point maana
  (warna sabka recency artificially bahut bada dikhta).
- **Q: NTILE() kya karta hai?** → Rows ko unke ek column ke value ke hisab se sort karke N
  barabar-size groups (quartiles agar N=4) mein baant deta hai — ek window function hai, GROUP
  BY jaisa squash nahi karta.
- **Q: Frequency ke liye NTILE kyun nahi use kiya?** → Kyunki ~97% customers ki frequency ek
  hi value (1) par tied thi — NTILE aise heavily-tied data ko arbitrarily split karta, isliye
  fixed meaningful CASE WHEN buckets use kiye.
- **Q: "High Value" aur "Loyal" mein kya fark hai tumhare segmentation logic mein?** → High
  Value = teeno (R, F, M) high; Loyal = sirf Frequency high, chahe recent na ho ya monetary
  standout na ho — matlab consistent repeat-buyer honा hi Loyal banne ke liye kaafi hai.
  **Fark:** High Value ⊂ zyada strict (sab kuch high), Loyal ⊂ sirf ek dimension (frequency)
  par based.
- **Q: Yeh clustering/ML se kaise different hai (jaise K-Means segmentation)?** → RFM
  rule-based hai (fixed thresholds/quartiles, fully explainable, koi model training nahi);
  K-Means jaisa clustering algorithmically similar customers ko group karta hai bina fixed
  rules ke, lekin explain karna harder hota hai ("black box"-ish) aur is project ke scope
  (beginner-friendly, interview-safe) ke liye zaroorat se zyada complex hota.
- **Q: Ek customer ka segment time ke saath change ho sakta hai?** → Haan — RFM ek static
  scoring nahi hai, jab bhi naya order/time-gap aata hai, recompute karne par segment badal
  sakta hai (e.g. "At Risk" customer agar dobara order kare toh "Recent"/"Loyal" ban sakta hai).
