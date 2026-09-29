# 07 — Business Insights

> Yeh insights sirf unhi numbers se aaye hain jo `sql/` queries aur `notebooks/01_eda.ipynb` mein
> **actually compute** hue hain — koi bhi number yahan manufacture/guess nahi kiya gaya hai. Har
> insight ka source query/chart reference diya gaya hai taaki verify kar sako.

---

## Insight 1 — Late delivery devastates customer satisfaction

**Observation:** Late-delivered orders ki average rating sirf **2.57★** hai, jabki on-time
orders ki average rating **4.29★** hai — 1.72-star ka gap.

**Evidence:** `sql/05_delivery_analysis.sql` Query 4 (n = 7,661 late orders vs 88,163 on-time
orders — dono solid sample sizes) — same result `notebooks/01_eda.ipynb` Chart 9 mein visually
confirm hota hai.

**Interpretation:** Delivery timing customer satisfaction ka **single sabse strong driver**
hai jo is dataset mein mila — kisi aur factor (category, price, region) ka itna bada,
consistent impact nahi dikha.

**Possible action:** Delivery-time reliability improve karna (especially estimated-delivery-date
accuracy aur actual logistics speed) directly rating/satisfaction improve kar sakta hai — is
ek area mein investment ka ROI sabse zyada predictable hai.

---

## Insight 2 — Revenue is heavily concentrated in one state

**Observation:** São Paulo (`SP`) akela total revenue ka **37.42%** contribute karta hai — koi
aur state 15% bhi nahi cross karta.

**Evidence:** `sql/04_regional_analysis.sql` Query 4 — SP: R$57.7L, RJ: R$20.6L (13.33%),
MG: R$18.2L (11.80%).

**Interpretation:** Business ek region par bahut zyada dependent hai. Yeh naturally expected hai
(Olist khud SP-based hai, aur SP Brazil ka sabse bada commercial hub hai), lekin phir bhi ek
geographic concentration risk hai.

**Possible action:** Non-SP regions (jaise RJ, MG, RS) mein targeted marketing/seller-acquisition
se revenue diversification explore ki ja sakti hai — single-region dependency kam karne ke liye.

---

## Insight 3 — Repeat purchase rate is very low (~3%)

**Observation:** 96,096 unique customers mein se sirf **2,801 (3.0%)** ne ek se zyada baar order
kiya — baaki 97% one-time buyers hain.

**Evidence:** `sql/02_customer_analysis.sql` Query 2 & 3.

**Interpretation:** Customer retention is business ki weak spot hai — acquisition (naye
customers laana) strong lagta hai (dataset mein steady month-on-month order growth hai, dekho
Insight 6), lekin unhe **dobara** khareedne par convince karna kam ho raha hai.

**Possible action:** Post-purchase engagement (email/discount for 2nd order), loyalty
incentives, ya "At Risk"/"Recent" RFM segments (dekho `docs/04`) ko targeted re-engagement
campaigns — teeno directly is gap ko address karte hain.

---

## Insight 4 — High order-volume categories aren't always high-revenue categories

**Observation:** `bed_bath_table` sabse zyada orders wali category hai (9,272), lekin revenue
mein #3 hai (R$12,25,209). `health_beauty` kam orders (8,647) ke bawajood #1 revenue category
hai (R$14,12,090) — matlab uska per-order value zyada hai.

**Evidence:** `sql/01_basic_sales_analysis.sql` Query 5 & 6; `sql/03_product_analysis.sql`
Query 2 (electronics/telephony jaisi categories high-volume-lekin-low-per-order-revenue ka
extreme example hain: electronics R$79.75/order, telephony R$92.65/order, dono >2,500 orders).

**Interpretation:** Order-volume aur revenue-contribution do alag cheezein hain — sirf "kitna
bik raha hai" dekhna kaafi nahi, "kitna kama raha hai" bhi dekhna padta hai.

**Possible action:** High-volume/low-per-order categories (electronics, telephony) mein
bundling/upsell/accessory-attachment strategy se average order value badhaya ja sakta hai.

---

## Insight 5 — One category stands out with a genuinely poor rating: office furniture

**Observation:** `office_furniture` ki average rating **3.49★** hai — sabse kharab kisi bhi
category mein, aur yeh ek chhota sample nahi hai (1,263 reviews).

**Evidence:** `sql/03_product_analysis.sql` Query 3.

**Interpretation:** Furniture jaisi heavy/fragile items shipping ke dauran damage/assembly
issues face kar sakti hain, ya product-description customer-expectation se mismatch ho sakta
hai — dono hi common furniture-e-commerce challenges hain.

**Possible action:** Is category ke reviews ka qualitative/text review (agar future scope mein
NLP add ho) ya seller-level breakdown se root cause identify kiya ja sakta hai — packaging
standards ya listing-accuracy audit se shuru kiya ja sakta hai.

---

## Insight 6 — Business grew steadily through 2017, with a clear seasonal peak

**Observation:** Monthly revenue Sep 2016 (R$143) se grow karke Nov 2017 mein peak (R$11,53,364)
tak pahuncha, phir 2018 mein R$9-11 lakh/month ke stable/mature range mein settle hua.

**Evidence:** `sql/01_basic_sales_analysis.sql` Query 4; `notebooks/01_eda.ipynb` Chart 5.

**Interpretation:** November ka spike Brazil ke "Black Friday" shopping season se align karta
hai — seasonal demand ka real, expected pattern hai.

**Possible action:** Seasonal inventory/staffing/marketing planning November ke around
prioritize ki ja sakti hai. ⚠️ Sep-Oct 2018 ka apparent dip **data-collection cutoff hai** (in
months ke orders ko "delivered" status milne ka time nahi mila dataset snapshot tak) — isse
"business decline" mat samjho, yeh galat conclusion hoga.

---

## Insight 7 — The "At Risk" RFM segment represents the clearest win-back opportunity

**Observation:** RFM segmentation mein "At Risk" segment (24.30% customers, 22,690 log) ka
average revenue-per-customer **R$266.82** hai — `High Value`/`Loyal` ke baad **sabse zyada**
among all segments, despite inactive hone ke.

**Evidence:** `sql/06_customer_segmentation.sql` Query 4; full explanation `docs/04`.

**Interpretation:** Yeh customers pehle proven-valuable the (achha spend karte the) lekin
recently inactive hain — yeh "Low Engagement" segment (jo kabhi bhi high-value nahi tha) se
bilkul different business opportunity hai.

**Possible action:** "At Risk" segment ko specifically target karta ek re-engagement campaign
(personalized discount/reminder) design kiya ja sakta hai — inki proven spending history ki
wajah se yeh sabse high-ROI targeted marketing segment hai.

---

## Insight 8 — Remote-state "higher average order value" is a freight-cost artifact, not a spending-behavior insight

**Observation:** Sabse high-AOV states (PB, AC, AP, AL, RO — sab R$220-267 range) Brazil ke
remote North/North-East states hain, jabki SP (sabse bada revenue state) is list mein top-5
mein bhi nahi hai.

**Evidence:** `sql/04_regional_analysis.sql` Query 2, cross-referenced with Query 3 (slowest
delivery states — same remote states).

**Interpretation:** Humara "revenue"/AOV metric `freight_value` include karta hai, aur remote
states mein shipping cost naturally zyada hoti hai (distance zyada) — is se AOV inflate ho
jaata hai bina customers ke "zyada expensive products" khareedne ke.

**Possible action (meta-lesson, not a marketing action):** Isko galat tarike se "remote-state
customers zyada valuable hain" mat interpret karo — yeh ek data-literacy insight hai: **kisi
bhi metric ko conclusion nikalne se pehle uske components samajhna zaroori hai.**

---

## Summary table

| # | Insight | Strength of evidence |
|---|---|---|
| 1 | Late delivery → much lower ratings | Very strong (large n, big gap) |
| 2 | SP = 37% revenue concentration | Strong (direct aggregation) |
| 3 | Only 3% repeat customers | Strong (direct aggregation) |
| 4 | Volume ≠ revenue leader | Strong (direct comparison) |
| 5 | office_furniture = worst rated | Strong (large sample) |
| 6 | Steady growth + Nov seasonality | Strong, with an explicit data-cutoff caveat |
| 7 | "At Risk" = best win-back target | Strong (RFM-derived, real revenue numbers) |
| 8 | Remote-state AOV is a freight artifact | Strong (cross-referenced with delivery data) |
