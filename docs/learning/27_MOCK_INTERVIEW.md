# 27 — Mock Interview

> **How to use this file:** Har question ke baad ek **"👉 Ab tum bolो (out loud, before scrolling)"**
> prompt hai. Ruko, apna answer boलो/likhो, **phir** neeche "Model Answer" section padho. Isको
> jaldbaazi mein skip mat karo — active-recall hi is file ka poora point hai.

---

## Round 1 — Basic Project Questions

**Q1.1: "Apne project ke baare mein batao."**

👉 Ab tum bolो.

> **Model Answer:** File 02 ka 1-minute pitch use karo.
> **Why it's good:** Business-problem se shuru hota hai (na ki "maine SQL use kiya" se), ek
> specific finding ke saath end hota hai.
> **Common mistake:** Tools ki list bolна shuru mein hi ("maine SQL, Python, Power BI use
> kiya...") bina business-context ke.

**Q1.2: "Yeh project real work experience jaisा kyun hai?"**

👉 Ab tum bolो.

> **Model Answer:** "Kyunki maine ek real, messy, production-grade dataset use kiya (na ki
> ek clean tutorial-dataset), aur poore pipeline ko khud design kiya — cleaning-decisions se
> leke dashboard-design tak, har jagah reasoning-based choices lie, na ki sirf ek tutorial
> follow kiya."
> **Common mistake:** "Kyunki maine bahut kuch seekha" jaisa vague answer — specific bolो.

---

## Round 2 — SQL

**Q2.1: "AOV kaise calculate kiya, line-by-line samझाओ."**

👉 Ab tum bolो.

> **Model Answer:** File 06 Query 1.3 ka poora breakdown use karo — subquery pehle order-level
> total banाता hai, phir outer query uska average leता hai.
> **Why it's good:** Grain-mismatch concept ko explicitly naam leke explain karta hai.
> **Common mistake:** Sirf "maine subquery use ki" bolना bina **kyun** explain kiye.

**Q2.2: "WHERE aur HAVING mein fark, apne project ke query ke saath."**

👉 Ab tum bolो.

> **Model Answer:** File 06 Query 3.2 (`HAVING orders_count >= 100`) use karo.
> **Common mistake:** Sirf definition bolना, real query-example na dena.

---

## Round 3 — Python/Pandas

**Q3.1: "`order_reviews` mein duplicates kaise handle kiye?"**

👉 Ab tum bolो.

> **Model Answer:** `sort_values("review_answer_timestamp").drop_duplicates(subset="order_id",
> keep="last")` — file 08/09 ka reasoning (latest review = final opinion).
> **Common mistake:** "Maine drop_duplicates() use kiya" bolना bina `subset`/`keep` parameters
> ke role explain kiye.

**Q3.2: "Geolocation table ko kaise clean kiya, aur kyun aggregate kiya?"**

👉 Ab tum bolो.

> **Model Answer:** File 09 section "sellers and geolocation" — dedup (26% duplicate rows),
> phir groupby-zip-aggregate (fan-out-join se bachने ke liye).
> **Why it's good:** "Fan-out join" concept ko naam leke explain karna technical depth dikhाता hai.

---

## Round 4 — Power BI

**Q4.1: "Apna data model explain karo."**

👉 Ab tum bolो.

> **Model Answer:** Fact tables (orders/items/payments/reviews) + Dimension tables
> (customers/products/sellers), file 16 section 2 ka relationship-table use karo.
> **Common mistake:** Sirf "maine relationships banाई" bolна, cardinality/cross-filter-direction
> ka detail na dena.

**Q4.2: "Calculated Column aur Measure — ek project-example do."**

👉 Ab tum bolो.

> **Model Answer:** `Delivery Status` (column) vs `Total Revenue` (measure) — file 15 section 4.

---

## Round 5 — Statistics

**Q5.1: "Correlation vs Causation — apne project mein kahan relevant tha?"**

👉 Ab tum bolо.

> **Model Answer:** File 11 section 8 — delivery-vs-rating insight, "association" language,
> "proven cause" nahi.
> **Why it's good:** Yeh dikhाता hai tum results ko over-claim nahi karte — high-value maturity
> signal.

**Q5.2: "Mean aur Median mein choose karna ho, kaise decide karoge — apne project ka example."**

👉 Ab tum bolो.

> **Model Answer:** `price` distribution right-skewed hai (file 11) — isliye median/log-scale
> zyada "honest" representation deता hai mean ke against.

---

## Round 6 — Business / Case Questions

**Q6.1: "Agar tumhe sirf ek insight par action lena ho, kaunsa choose karoge?"**

👉 Ab tum bolो.

> **Model Answer:** Insight 1 (delivery-vs-satisfaction) — file 19 I1 ka reasoning (strong
> evidence + directly-actionable + operational lever).
> **Common mistake:** "Sab equally important" — non-answer, prioritization dikhाओ.

**Q6.2: "Case question: Agar revenue is mahine 20% gira, tum kaise investigate karoge?"**

👉 Ab tum bolо.

> **Model Answer:** "Pehle check karunga: (1) order-volume gira ya AOV gira ya dono, (2) kya
> koi specific category/region drive kar raha hai gिravat ko, (3) kya yeh seasonal hai (jaise
> is project mein Nov-peak dikha, toh Dec/Jan naturally kam ho sakta hai — data-cutoff jaisा
> bhi ho sakta hai, dekho Insight 6), (4) external factors (holiday, supply-issue)."
> **Why it's good:** Structured, hypothesis-driven approach — sirf "pata nahi" ya random guess
> nahi.

---

## Round 7 — Deep Project Follow-ups

**Q7.1: "Tumhe abhi pata chala ki tumhare revenue-calculation mein 5% ka error tha (hypothetically).
Kya karoge?"**

👉 Ab tum bolो.

> **Model Answer:** "Pehle root-cause dhoondता — kaunsi query/step mein galti thi. Phir saari
> downstream-dependent numbers (jo is revenue-figure par based hain) ko re-verify karta — jaise
> AOV, category %, RFM monetary-scores sab. Fir documentation update karta taaki future mein
> yehi galti repeat na ho. Yeh bilkul wahi discipline hai jo maine RFM-bug aur index-slowness
> bug ke time actually follow ki thi (file 19 K1)."

**Q7.2: "Agar main tumhare SQL query mein ek jaan-boojh kar bug daal doon, kaise dhoondोगे?"**

👉 Ab tum bolो.

> **Model Answer:** "Query ka result ek chhote, manually-verifiable sample par trace karunga —
> jaise ek specific customer/order ko haath se calculate karke query ke result se compare
> karunga. Yeh bilkul wahi tarika hai jisse maine RFM recency-scoring ka direction-bug pakड़ा
> thа — verify karke, na ki assume karke ki query 'sahi honी chahiye kyunki error nahi aaya.'"

---

## Questions I MUST Practice Speaking Aloud (final checklist)

1. 30-second, 1-minute, aur 2-minute project pitch (file 02).
2. AOV subquery — line by line.
3. RFM poora scoring mechanism (Recency-direction, Frequency-CASE-WHEN reasoning).
4. WHERE vs HAVING with a real query example.
5. Delivery-vs-satisfaction insight, using "correlation" language correctly.
6. Data-model/relationships explanation (fact vs dimension tables).
7. "What are your project's limitations?" — full honest list.
8. "What was the trickiest bug you found?" — both real bugs (index-slowness, RFM-direction).

---

## What I should remember

- Active recall (answer BEFORE reading model-answer) is 10x zyada effective than passive
  re-reading — is file ko discipline se use karo.
- Har round ka common-mistake-pattern: "definition bolना bina apne project ke real example
  ke" — hamesha khud ke query/code/number tak point karo.
