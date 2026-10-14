# 11 — Statistics From Zero

> Sirf utni statistics jitni is project/entry-level DA interview ke liye chahiye. Har concept:
> **intuition pehle, formula baad mein.**

---

## 1. Population vs Sample

- **Simple explanation:** **Population** = poora group jisme tumhara interest hai (jaise
  "Olist ke SAARE customers"). **Sample** = us population ka ek chhota, represent karne wala
  hissa.
- **Project context:** Is project mein hum **population par hi kaam kar rahe hain**, sample par
  nahi — humare paas Olist ke (nearly) saare orders/customers ka data hai (2016-2018), koi
  random sample nahi liya. Isliye humare numbers "estimates" nahi, **actual counts/values** hain.
- **Interview angle:** Agar tumhara data sirf ek "sample" hota (jaise survey ke 500 log), tab
  statistical techniques (confidence intervals, hypothesis tests) zyada important ho jaate —
  is project mein humare paas "population-level" data hai isliye unki utni zaroorat nahi padी.

## 2. Mean, Median, Mode

| Measure | Simple Meaning | Formula | Kab misleading ho sakta hai |
|---|---|---|---|
| **Mean (Average)** | Sab values jodkar count se divide | $\bar{x} = \frac{\sum x_i}{n}$ | Extreme outliers se bahut affect hota hai |
| **Median** | Sorted data ka **beech wala** value | Sort karo, middle value lo | Outliers se kam affect hota hai — "typical" value ke liye better |
| **Mode** | Sabse zyada baar aane wala value | — | Categorical data ke liye useful (jaise "sabse common payment type") |

**Tiny example:** Salaries = [20k, 22k, 25k, 27k, 500k]. Mean = 118.8k (**bahut misleading** —
ek outlier ne pura khींच diya). Median = 25k (**zyada representative** hai typical employee ke
liye).

**Project usage:** `.describe()` (notebook Section 7) mean/median/std/quartiles saath dikhata
hai — `price` column jaisे right-skewed data ke liye, mean aur median mein fark khud hi batata
hai ki data skewed hai.

**Interview:** *"Mean use karoge ya median?"* → Depends: symmetric data → mean theek hai;
skewed data ya outliers ho toh → median zyada representative hai.

## 3. Range, Variance, Standard Deviation

- **Range:** Max − Min. Simplest "spread" measure, lekin outliers se bahut sensitive.
- **Variance:** Average of squared differences from the mean —
  $\sigma^2 = \frac{\sum (x_i - \bar{x})^2}{n}$. Data kitna "mean ke around bikhra hua" hai.
- **Standard Deviation (SD):** $\sigma = \sqrt{\sigma^2}$ — variance ka square root, **same
  units mein** jaise original data (variance ki units squared hoती hain, jo directly samajhna
  mushkil hota).

**Intuition:** Agar SD chhota hai, data mean ke aas-paas tight cluster hai. Agar SD bada hai,
data bahut spread out hai.

**Project usage:** `.describe()` output mein `std` column — `delivery_days` ke liye std
dikhata hai delivery time kitna **consistent** hai vs kitna **variable**. Bada std matlab kuch
orders bahut jaldi, kuch bahut der se — jo Chart 4 ki lambi tail se match karta hai.

## 4. Percentile & Quartiles

- **Simple explanation:** Percentile batata hai "kitne % data is value se **neeche** hai."
  75th percentile = wo value jisse neeche 75% data hai.
- **Quartiles:** Data ko **4 barabar hisso** mein baantne wale 3 cut-points — Q1 (25th
  percentile), Q2 (50th = median), Q3 (75th percentile).

**Project usage (bahut important — yeh RFM ka core idea hai):** `NTILE(4)` SQL function bilkul
yehi karta hai — customers ko unke Recency/Monetary value ke hisab se **4 quartile groups**
mein baantता hai. Quartile 1 = worst 25%, Quartile 4 = best 25%. (Poora detail: file 06/14.)

**Interview:** *"Quartile aur percentile mein fark?"* → Percentile ek general concept hai (kisi
bhi %), quartile specifically data ko 4 barabar hisso mein baantने wale 3 specific percentiles
(25th/50th/75th) hain.

## 5. Distribution Shape

- **Simple explanation:** Data "kaise dikhta hai" agar chart banaya jaaye — symmetric hai,
  skewed hai, ya do peaks (bimodal) hain.

| Shape | Matlab | Project example |
|---|---|---|
| **Right-skewed** | Lambi tail right side (kuch bahut bade values) | `price` distribution (₹0.85 se ₹6,735) |
| **Bimodal** | Do "peaks" — data do groups mein cluster karta hai | `review_score` (5★ aur 1★ dono high, beech kam) |

**Interview:** *"Skewed distribution ka average par kya effect hota hai?"* → Mean ko tail ki
taraf khींच leta hai — isliye skewed data ke liye median ya log-scale visualization zyada
"honest" representation deता hai.

## 6. Outliers

- **Simple explanation:** Values jo baaki data se bahut alag/extreme hain.
- **Kaise detect karte hain:** Visual (histogram/box plot ki tail), ya statistical rule (jaise
  "Q3 + 1.5×IQR se zyada").
- **Important lesson (project mein khud follow ki):** Outlier dikhne par **turant delete mat
  karo** — pehle verify karo wo genuinely error hai ya legitimate rare case. Is project mein
  `price` ka max ₹6,735 tha — verify kiya ki koi negative/zero price nahi hai, aur is high value
  ko ek legitimate premium product maan kar **rakha**, delete nahi kiya.
- **Interview:** *"Outlier ko kab remove karoge, kab nahi?"* → Remove karo agar wo clearly
  **data-entry error** hai (jaise negative price, ya "age = 200"). Rakho agar wo ek genuine,
  rare-but-real business case hai (jaise ek premium product ya ek bulk order).

## 7. Correlation

- **Simple explanation:** Do variables **saath mein kaise change** hote hain — jab ek badhta
  hai, doosra bhi badhta hai (positive), ghatta hai (negative), ya koi pattern nahi (zero/weak).
- **Project usage:** Delivery status (on_time/late) aur review score ka **strong relationship**
  hai — jab delivery late hoti hai, rating **consistently** kam hoती hai (4.29★ → 2.57★).
- **⚠️ Correlation ≠ Causation (bahut important, dekho section 8 niche).**

---

## 8. Correlation vs Causation — the most important interview-trap concept in this book

### GENERAL

- **Correlation:** Do cheezein **saath change** hoती dikhaई deती hain.
- **Causation:** Ek cheez **directly, provably** doosri cheez ko cause karti hai.

**Chhota unrelated example:** Ice-cream sales aur drowning incidents dono garmiyon mein badhte
hain — **correlated** hain, lekin ice-cream drowning **cause nahi karta**. Doosra factor
(garmi/summer) dono ko affect kar raha hai — isे "confounding variable" kehte hain.

### MY PROJECT

**Insight 1** ("Late delivery se rating girती hai," 4.29★ vs 2.57★) ek **strong, large-sample
correlation** hai — lekin humne kabhi nahi bola "delay **guaranteed** cause hai." Ho sakta hai
koi aur factor (jaise product-quality issue jo delay bhi karaye aur rating bhi girाए) dono ko
simultaneously affect kar raha ho.

### INTERVIEW

**Q: "Toh kya yeh insight useless hai agar causation confirm nahi hai?"**
> Nahi — strong, large-sample (n>7000 dono groups) correlation bhi business action ke liye
> kaafi actionable hoti hai. Sirf **language mein** "correlation/relationship/association"
> bolna chahiye, "guaranteed cause" nahi.

**Q: "Data se hume causation prove ho sakta hai kya?"**
> Sirf observational data se (jaisा humare paas hai) — nahi, poori tarah nahi. Causation prove
> karne ke liye usually **controlled experiments** (A/B tests) chahiye hote hain, jahan tum
> khud ek variable ko control/change karte ho aur baaki sab same rakhte ho.

> **Yaad rakhne wala sentence:** "Data se hume association dikh raha hai, causation prove
> nahi hota." Isko bolna interview mein **maturity ka signal** hai.

---

## 9. Probability, Hypothesis Testing, p-value, Confidence Interval — 🟢 optional (project mein use nahi hue)

Yeh concepts is project mein **directly use nahi hue** (koi formal statistical test — jaise
t-test — nahi chalaya gaya). Lekin general DA interviews mein basic awareness poochi ja sakti
hai, isliye ek-line intuition:

| Concept | One-line intuition |
|---|---|
| **Probability** | Kisi event ke hone ka chance, 0 (impossible) se 1 (certain) ke beech |
| **Hypothesis testing** | Ek statistical tarika yeh check karne ka ki koi observed difference "real" hai ya sirf random chance |
| **p-value** | Agar sach mein koi difference nahi hota (null hypothesis sach hoti), itna extreme result milne ka chance kitna hota — chhota p-value (usually <0.05) "significant" difference maana jaata hai |
| **Confidence Interval** | Ek range jisme "true" population value likely hai (jaise "95% confident revenue R$150-170 ke beech hai") |

> **Agar interviewer poochhe "tumne apne insights par koi statistical significance test kiya?"**
> Honest answer: "Nahi — is project ka scope descriptive analytics tha, formal hypothesis
> testing nahi. Lekin main samajhta hoon ki agar sample sizes chhote hote (jaise 5-10 reviews
> wali category), tab significance testing zyada zaroori ho jaati — isliye maine `HAVING
> reviews_count >= 30` jaisे sample-size safeguards use kiye bina formal test ke bhi."

---

## What I should remember

- Mean sensitive to outliers, median nahi — skewed data mein median/log-scale zyada honest hai.
- Quartiles = data ko 4 barabar hisso mein baantna — RFM scoring ka core mechanism (`NTILE(4)`).
- Outlier dikhte hi delete mat karo — pehle verify karo error hai ya genuine rare case.
- Correlation ≠ Causation — is project ka sabse strong insight (delivery→rating) bhi ek
  correlation hai, "proven cause" nahi — hamesha yeh nuance interview mein bolo.
- Formal hypothesis testing/p-value is project mein use nahi hui — honest rehna, invent mat karo.
