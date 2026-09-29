# 06 — Power BI Learning Notes

> ⚠️ **Important honesty note:** Power BI Desktop ek Windows GUI application hai jo is
> environment se directly automate/run nahi ki ja sakti. Isliye is project mein Power BI ka
> **poora build-ready spec** hai (`dashboard/README.md` — data model, relationships, DAX,
> page/visual layout) aur **step-by-step manual instructions** hain
> (`dashboard/HOW_TO_BUILD.md`) — lekin actual `.pbix` file aur screenshots tumhe khud Power BI
> Desktop mein banane honge. Yeh file (`docs/06`) samjhati hai **kyun** har decision li gayi.

## 1. Data model — kya import kiya aur kyun

Humne **cleaned CSVs** (`data/processed/`) import karne ka plan banaya hai, raw data nahi —
same principle jo SQL mein bhi tha: ek jagah clean karo, sabjaga wahi clean data use hota hai.

**Ek extra table banayi: `category_performance.csv`.** Yeh normal cleaned data nahi hai, balki
ek **precomputed summary** hai (category + revenue + order-count + avg price + avg rating, sab
ek row mein per category). **Kyun banaya?**

- "Category ka rating" nikalne ke liye path hai: `products → order_items → orders → order_reviews`
  (3 hops).
- Power BI mein relationships ek direction mein filter "flow" karte hain by default (jaise ek
  one-to-many relationship mein "one" side "many" side ko filter karta hai, ulta nahi). Is
  3-hop chain mein, agar hum category se filter karna chahein aur wo reviews tak "pahunche,"
  humein beech ki ek relationship ko **bidirectional** (dono taraf filter flow) karna padta —
  yeh ek real Power BI concept hai lekin beginners ke liye confusing/ambiguous results ka
  common source bhi hai.
- **Simple solution:** Yeh cross-cutting number Python mein pehle se calculate kar diya
  (`scripts/export_powerbi_tables.py`) — koi nayi analysis nahi hai, bas wahi numbers jo
  `sql/01` aur `sql/03` mein already verify ho chuke the, ek convenient single table mein.
- **Lesson:** Real BI tools mein, jab data-model complex ho jaaye, **precomputed summary
  tables** (kabhi "denormalized" ya "reporting mart" bhi bolte hain) ek valid, common
  simplification technique hai — har cheez ko live relationships se solve karna zaroori nahi.

## 2. Relationships — 1:1 vs 1:many, aur cross-filter direction

- **`orders` ↔ `order_items`, `order_payments`, `order_reviews`:** One-to-many — ek order ke
  multiple line-items/payments/reviews ho sakte hain.
- **`orders` ↔ `customers`:** **One-to-one** — kyun? Kyunki `customer_id` khud order-level
  unique hai (dekho `docs/01` section 3.1) — matlab har order ka apna hi ek customer row hai.
  Power BI 1:1 relationships mein **dono directions mein automatically filter flow karta hai**
  (default "Both" cross-filter) — isliye "state ke hisab se average delivery time" jaisa
  cross-table metric bina kisi extra setting ke kaam karta hai.
- **`customers` ↔ `customer_segments`:** Many-to-one — kyunki ek `customer_unique_id` (real
  insaan) ke multiple `customer_id` rows ho sakte hain (repeat customers), lekin
  `customer_segments` mein har unique insaan ki sirf ek hi row hai.

## 3. Calculated Columns vs Measures — fark kya hai (bahut common interview/practical confusion)

| | Calculated Column | Measure |
|---|---|---|
| Kab compute hota hai | Data load/refresh ke time, **row-by-row**, result table mein "stored" ho jaata hai | Query/visual render hone ke time, **on-the-fly** |
| Storage | Extra space leta hai (physically stored) | Koi extra storage nahi |
| Kab use karo | Jab result **row-level** hona chahiye (e.g. "is order late thi ya nahi" — har row ka apna answer) | Jab result **aggregation** hai (e.g. "total revenue," "average delivery days") jo filters/slicers ke saath dynamically change ho |
| Is project mein example | `Delivery Status` (har order ke liye ek fixed label) | `Total Revenue` (jo state/category/date filter ke hisab se badalta rahega) |

**Simple rule of thumb jo yaad rakhna:** Agar answer "har row ka apna hai aur filter se nahi
badalta" → Calculated Column. Agar answer "ek number hai jo currently-selected filters par
depend karta hai" → Measure.

## 4. DAX measures explained

### `Total Revenue`
```dax
Total Revenue =
CALCULATE(
    SUM(order_items[price]) + SUM(order_items[freight_value]),
    orders[order_status] = "delivered"
)
```
- **`CALCULATE`** DAX ka sabse important function hai — "is expression ko naye filters ke saath
  evaluate karo." Yahan hum `SUM(price + freight)` ko sirf `delivered` orders tak restrict kar
  rahe hain.
- Filter `orders[order_status] = "delivered"` khud `order_items` table par nahi hai, `orders`
  table par hai — lekin relationship (orders → order_items) ki wajah se yeh filter automatically
  `order_items` tak "flow" kar jaata hai. **Yeh CALCULATE ka core superpower hai.**

### `Average Order Value`
```dax
Average Order Value = DIVIDE([Total Revenue], [Total Orders])
```
- **`DIVIDE()`** normal `/` operator se better hai kyunki agar denominator `0` ho (koi orders
  hi na hon current filter mein), yeh crash/error ke bajaye automatically `BLANK()` return
  karta hai. **Yeh ek DAX best-practice hai jo har measure mein use karni chahiye jahan division
  ho.**

### `Delivery Status` (calculated column) + `On-Time Delivery %`
- Pehle har order ke liye ek fixed label banaya (`"On Time"`/`"Late"`/blank) — yeh
  **row-level** cheez hai (calculated column), phir uspar measures (`On-Time Orders`,
  `Delivered With Date`, `On-Time Delivery %`) banaye jo **aggregate/percentage** nikalte hain.
  Yeh calculated-column-then-measure pattern bahut common hai.

### `Repeat Customer %`, `Segment Revenue`
- Seedha `customer_segments` table (jo already SQL mein pre-computed hai, RFM se) par based —
  koi complex DAX nahi chahiye tha kyunki heavy-lifting (RFM calculation) already SQL mein ho
  chuki thi. **Lesson:** Agar ek calculation kisi aur layer (SQL/Python) mein already solid hai,
  Power BI mein use dobara se complex DAX mein implement karne ki zaroorat nahi — bas result
  ko import karo.

## 5. Visual choices — kyun har chart wahi type hai

| Visual | Kyun yeh type? |
|---|---|
| Card (KPIs) | Single, high-level number — sabse pehli cheez jo executive dekhna chahta hai |
| Line chart (trends) | Time ke saath change dikhane ke liye best |
| Horizontal bar (rankings) | Category/state names lambe hote hain — horizontal padhne mein aasan |
| Donut (New vs Repeat) | Sirf 2 categories ka simple proportion dikhana hai |
| Table (Top Customers) | Jab multiple specific values (naam, spend, frequency, segment) ek saath dikhane hon — chart se zyada table readable hota hai yahan |

## 6. Slicer logic

- **Page 1:** Date-range slicer — poori executive summary ko kisi bhi time-period ke liye
  filter kar sakte ho.
- **Page 2:** Customer-segment slicer — "sirf At Risk customers dikhao" jaisa filter.
- **Page 3:** State slicer — regional deep-dive ke liye.

Slicers **cross-page bhi sync** ki ja sakti hain (Power BI feature: "Sync slicers" pane) —
lekin humne yeh **jaan-boojh kar simple rakha** (per-page independent slicers) taaki dashboard
confusing na ho — advanced sync-slicer setup is project ke scope se bahar hai.

## 7. Interview Questions

- **Q: Calculated column aur measure mein fark?** → Section 3 ka table use karo.
- **Q: CALCULATE() kya karta hai?** → Ek expression ko naye filter-context ke saath evaluate
  karta hai — DAX ka sabse powerful/core function.
- **Q: DIVIDE() kyun use kiya, `/` kyun nahi?** → Divide-by-zero ko safely `BLANK()` handle
  karta hai, crash nahi hota.
- **Q: Tumne ek pura relationship-chain use karne ke bajaye precomputed table kyun banayi?** →
  3-hop chain ke liye bidirectional relationship chahiye hoti, jo beginner-model mein ambiguity
  la sakti hai — simpler, safer alternative tha ek chhota precomputed summary table (same
  numbers jo SQL mein already verify ho chuke the).
- **Q: 1:1 relationship normal 1:many se kaise alag behave karti hai?** → 1:1 mein Power BI
  default cross-filter direction "Both" rakhta hai (dono taraf filter flow karta hai), jabki
  1:many mein default sirf "one" se "many" taraf (single direction) hota hai.
