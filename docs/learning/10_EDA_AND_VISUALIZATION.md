# 10 — EDA and Visualization

## 1. What is EDA?

### GENERAL

**EDA (Exploratory Data Analysis)** ka matlab hai data ko **visually aur statistically explore**
karna, bina kisi fixed hypothesis ke — yeh dekhne ke liye ki data mein kya patterns, trends,
outliers, ya relationships hain.

**SQL vs EDA — dono alag kyun hain (common confusion):** SQL "answer the business question"
ke liye best hai (precise numbers — "total revenue kitna hai"). EDA "explore + visualize" ke
liye best hai (patterns jo sirf ek number dekh kar nahi pakड़े jaate — jaise data ki **shape**,
kya wo bimodal hai, kya koi bada outlier hai).

### Why do analysts perform EDA?

- Data ki "personality" samajhne ke liye (spread, skew, outliers) — jo pure aggregates
  (`AVG`, `SUM`) chhupa dete hain.
- Data-quality issues ko **visually** confirm karne ke liye (jo sirf `.isnull().sum()` se pura
  nahi dikhta).
- Business insights ko stakeholders ke saath **communicate** karne ke liye — non-technical log
  charts se jaldi samajhte hain, raw tables se nahi.

### Univariate vs Bivariate vs Trend Analysis

| Type | Matlab | Is project mein example |
|---|---|---|
| **Univariate** | Ek single variable ko individually study karna | Review score distribution, price distribution |
| **Bivariate** | Do variables ke beech relationship dekhna | Delivery status vs review score |
| **Trend analysis** | Time ke saath change dekhna | Monthly revenue trend |
| **Distribution** | Data kaise "spread" hai (shape) | Price distribution (right-skewed), review score (bimodal) |

---

## 2. Chart Selection — GENERAL rule

| Data Type | Best Chart | Kyun |
|---|---|---|
| Categorical comparison | **Bar chart** | Categories ke counts/values side-by-side compare karna aasan |
| Continuous single-variable shape | **Histogram** | Data ki spread/shape dikhata hai (kitne values kis range mein hain) |
| Trend over time | **Line chart** | Change/direction turant dikh jaata hai |
| Two-numeric-variable relationship | **Scatter plot** | Correlation/pattern dikhane ke liye (is project mein **use nahi hua** — dekho note niche) |
| Distribution + outliers together | **Box plot** | Median/quartiles/outliers ek saath (is project mein **use nahi hua**) |
| Simple 2-3 category proportion | **Pie/Donut chart** | Sirf jab bahut kam categories hon (zyada categories ke liye bar better hai) |

> 📌 **Honesty note:** Is project ki Python EDA mein **sirf bar chart, histogram, aur line
> chart** actually use hue hain (dekho niche list) — **scatter plot aur box plot use nahi
> hue.** Power BI dashboard design mein ek **donut chart** hai (New vs Repeat Customers).
> Agar interviewer poochhe "scatter plot kyun nahi use kiya," honest answer: is project ke
> charts mostly categorical-comparison aur time-trend the — do continuous numeric variables
> ka direct relationship (jahan scatter best fit hota) explicitly nahi explore kiya gaya
> (yeh ek "Future Improvement" ho sakta hai — dekho file 25).

---

## 3. MY PROJECT — Har Chart Ka Deep-Dive

Format: **Business question → Why this chart → Variables used → What to look for → What was
observed → What it means.**

### Chart 1 — Order Status Distribution (Bar Chart)

- **Business question:** Operational health kaisi hai — kitne % orders successfully complete
  hote hain?
- **Why this chart:** `order_status` categorical hai, bar chart counts compare karne ke liye best.
- **Variables:** `order_status` (x), count (y).
- **What to look for:** `delivered` ka bar kitna dominant hai baaki ke against.
- **Observed:** `delivered` ~97%, baaki 7 statuses milkar ~3%.
- **What it means:** "Delivered-only" filter (jo revenue/delivery/satisfaction analysis mein
  use hota hai) data ka bahut bada chunk hi cover karta hai — filter safe/reasonable hai.

### Chart 2 — Review Score Distribution (Bar Chart)

- **Business question:** Customer satisfaction ka overall pattern kya hai?
- **Why this chart:** `review_score` discrete categories (1-5) hain — bar chart counts ke liye.
- **Variables:** `review_score` (x), count of reviews (y).
- **What to look for:** Kya distribution smooth hai ya koi unusual pattern.
- **Observed:** **Bimodal** — 5★ sabse zyada (57,328), lekin 1★ (11,424) bhi 2★ (3,151) se
  zyada hai.
- **What it means:** Customers ya toh bahut khush hote hain ya bahut frustrated — beech ka
  rating kam log dete hain. Sirf "average rating" dekhna kaafi nahi — 1★ ka bada chunk average
  ke andar "chhup" jaata hai; root-cause investigation (delivery delay jaisi) zaroori hai.

### Chart 3 — Price Distribution (Histogram, log scale)

- **Business question:** Product pricing ka overall spread kaisa hai?
- **Why this chart:** `price` continuous numeric hai — histogram shape/spread dikhane ke liye
  best. **Log scale** isliye kyunki price heavily right-skewed hai (₹0.85 se ₹6,735 tak range)
  — normal scale par sab kuch ek corner mein "chipak" jaata.
- **Variables:** `price` (x, log scale), count of line-items (y).
- **What to look for:** Bulk of data kahan concentrate hai, tail kitni lambi hai.
- **Observed:** Zyada products low-to-mid price range mein; lambi tail expensive products
  (`computers` jaisi categories) ki taraf.
- **What it means:** Pricing/inventory strategy — bulk catalog budget-friendly hai, premium
  items niche hain.

### Chart 4 — Delivery Time Distribution (Histogram)

- **Business question:** Order place karne se delivery tak kitna time lagta hai, aur kitna
  consistent hai?
- **Why this chart:** `delivery_days` continuous hai, shape/spread dekhni hai.
- **Variables:** `delivery_days` (x), count of orders (y).
- **What to look for:** Mean kahan hai, tail kitni lambi hai.
- **Observed:** Average ~12.6 din, ek right tail hai (kuch orders 60+ din bhi lete hain).
- **What it means:** Operations team ke liye — is tail ko chhota karna (outlier-slow deliveries
  fix karna) directly satisfaction improve karega (dekho Chart 9).

### Chart 5 — Monthly Revenue Trend (Line Chart)

- **Business question:** Revenue time ke saath kaise change hua?
- **Why this chart:** Line chart time-series data ke liye best — trend/direction turant dikhta hai.
- **Variables:** Month (x), total revenue (y).
- **What to look for:** Overall direction, koi spike/dip.
- **Observed:** Steady growth 2016→2017, **Nov 2017 mein bada spike** (Black Friday season),
  phir 2018 mein stable/mature level.
- **What it means:** Seasonal (Nov) inventory/staffing planning; growth-trend confirm karta hai
  business scale kar raha tha. ⚠️ Sep-Oct 2018 ka dip **data-cutoff artifact hai**, real decline
  nahi.

### Chart 6 — Top 10 Categories by Revenue (Horizontal Bar)

- **Business question:** Kaunsi categories sabse zyada revenue deती hain?
- **Why this chart:** Horizontal bar — category names lambe hain, padhna aasan; ranking turant
  dikhti hai.
- **Observed:** `health_beauty` #1, lekin Chart 7 (volume) mein `bed_bath_table` #1 hai.
- **What it means:** Revenue-leader aur volume-leader alag ho sakte hain.

### Chart 7 — Top 10 Categories by Order Volume (Horizontal Bar)

- **Business question:** Kaunsi categories sabse zyada orders generate karti hain?
- **Observed:** `bed_bath_table` #1 (9,272 orders) but revenue mein sirf #3.
- **What it means:** Iska per-order value average se kam hai — bundling/upsell opportunity.

### Chart 8 — Revenue by State (Top 10, Bar)

- **Business question:** Kaunse states sabse zyada revenue contribute karte hain?
- **Observed:** `SP` itna dominant hai ki baaki states bahut chhote dikhte hain (~37%).
- **What it means:** Geographic concentration risk — diversification consideration ho sakta hai.

### Chart 9 — Delivery Performance vs Satisfaction (2-bar comparison) — sabse strong insight

- **Business question:** Kya delivery timing satisfaction affect karti hai?
- **Why this chart:** Simple 2-group comparison — on_time vs late ka average review score
  side-by-side.
- **Observed:** on_time ~**4.29★** vs late ~**2.57★** — bahut bada gap.
- **What it means:** Delivery delay customer satisfaction ko directly, strongly affect karta
  hai — delivery-time improvement is business ka sabse high-ROI investment (agar goal
  satisfaction improve karna hai).

### Chart 10 — RFM Segment Distribution (2 subplots — count + avg revenue)

- **Business question:** RFM segments ka size aur value kya hai?
- **Observed:** `Recent` sabse bada segment (count), lekin `At Risk` ka average revenue per
  customer sabse zyada hai non-high-value segments mein.
- **What it means:** `At Risk` par targeted win-back campaign ka ROI sabse zyada hone ki
  sambhavna hai. (Poora detail: [14_CUSTOMER_SEGMENTATION.md](14_CUSTOMER_SEGMENTATION.md).)

---

## 4. Chart Selection — INTERVIEW Questions

**Q: "Kaunsa chart kab use karoge, general rule batao?"**
> Categorical comparison → bar chart. Continuous single-variable shape → histogram. Trend over
> time → line chart. (Poori table upar section 2 mein.)

**Q: "Log-scale histogram kyun use kiya, normal kyun nahi?"**
> Jab data mein bahut bada range ho (₹0.85 se ₹6,735), normal-scale histogram sab kuch ek corner
> mein dikhata hai — log scale spread ko zyada meaningfully dikhata hai.

**Q: "Pie chart kyun use nahi kiya?"**
> Pie chart sirf 2-3 categories ke liye readable hota hai — is project mein categories/states
> jaise variables mein 27-70+ distinct values hain, jahan bar chart (especially "Top N" ke
> saath) zyada readable/comparable hota hai.

**Q: "SQL se number pehle hi mil gaya tha, chart kyun banaya dobara?"**
> SQL "answer" deta hai, chart us answer ko **visually communicate** karta hai aur pattern ki
> "shape" dikhata hai jo ek single number nahi dikha sakta (jaise review-score ka bimodal hona).

---

## What I should remember

- EDA = data ko explore karna (patterns/shape/outliers), SQL se complementary, competing nahi.
- Univariate (single var) vs Bivariate (do vars ka relation) vs Trend (time) — teeno types is
  project mein use hue.
- Chart-type decide hota hai **data ke type** se — categorical→bar, continuous→histogram,
  time→line.
- Is project ke 10 charts mein sirf bar/histogram/line use hue — scatter/box plot nahi (honest
  gap, future-improvement candidate).
- Sabse important chart: Chart 9 (delivery vs satisfaction) — poore project ka strongest insight.
