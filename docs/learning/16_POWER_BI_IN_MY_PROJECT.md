# 16 — Power BI In My Project

> ⚠️ **Honesty note (bolo yeh sach interview mein, chhupao mat):** Power BI Desktop ek Windows
> **GUI application** hai — is repo ke automated/scripted environment se seedha nahi chalाई ja
> sakti. Is project mein Power BI ka **poora build-ready design** taiyaar hai — data model,
> relationships, calculated columns, DAX measures, aur page-by-page visual spec, sab
> ([dashboard/README.md](../../dashboard/README.md)) mein likha/decided hai — lekin actual
> `.pbix` file khud Power BI Desktop mein manually banaई jaani hai
> ([dashboard/HOW_TO_BUILD.md](../../dashboard/HOW_TO_BUILD.md) follow karke). Filhaal koi
> `.pbix` file ya screenshot repo mein maujood nahi hai.
>
> **Agar interviewer poochhe "dashboard dikhao":** "Maine dashboard ka poora data-model, DAX,
> aur page-by-page design bana rakha hai — Power BI Desktop mein isे build karna ek manual GUI
> step hai jo maine [status update yahan: complete/pending] kiya hai. Main aapko exact spec
> dikha sakta hoon ki har page kaisा dikhega aur kyun." Is honesty se interviewer ko pata chalta
> hai ki tumne **thinking/design ka poora kaam khud kiya hai**, sirf ek manual GUI-click step
> baaki hai — yeh ek weakness nahi, ek scope-honesty hai.

---

## 1. Data Source — kya import hota

Cleaned CSVs (`data/processed/`) import hoti (raw nahi — same "clean once, use everywhere"
principle jo SQL mein bhi tha):

| File | Role | Grain |
|---|---|---|
| `orders.csv` | Fact table | 1 order |
| `order_items.csv` | Fact table | 1 line item |
| `order_payments.csv` | Fact table | 1 payment |
| `order_reviews.csv` | Fact table | 1 review |
| `products.csv` | Lookup table | 1 product |
| `customers.csv` | Lookup table | 1 customer_id |
| `sellers.csv` | Lookup table | 1 seller |
| `customer_segments.csv` | RFM lookup table | 1 real customer |
| `category_performance.csv` | Precomputed summary | 1 category |

**`category_performance.csv` — a deliberate design choice:** Category + revenue + order-count
+ avg price + avg rating ek saath dikhane ke liye ek **3-hop relationship chain** chahiye
(`products → order_items → orders → order_reviews`), jo Power BI mein **bidirectional**
relationship maangती — beginner-model mein ambiguous-result ka common source. Isliye yeh ek
cross-cutting summary Python mein precompute kiya gaya (`scripts/export_powerbi_tables.py` —
same numbers as `sql/01`/`sql/03`, koi nayi analysis nahi) aur standalone table ki tarah import
kiya jaata.

## 2. Relationships (Data Model)

| From | To | Cardinality | Cross-filter |
|---|---|---|---|
| `orders[order_id]` | `order_items[order_id]` | One-to-many | Single |
| `orders[order_id]` | `order_payments[order_id]` | One-to-many | Single |
| `orders[order_id]` | `order_reviews[order_id]` | One-to-many* | Single |
| `order_items[product_id]` | `products[product_id]` | Many-to-one | Single |
| `order_items[seller_id]` | `sellers[seller_id]` | Many-to-one | Single |
| `orders[customer_id]` | `customers[customer_id]` | One-to-one | **Both** |
| `customers[customer_unique_id]` | `customer_segments[customer_unique_id]` | Many-to-one | Single |

`category_performance` **unrelated rehti hai** (koi relationship line) — standalone use hoti
hai, apne column se slicer ke through.

*Cleaning ke baad practically 1:1 hai, lekin Power BI ise 1:many hi model karta hai (khud
enforce nahi kar sakta uniqueness).

> **1:1 relationship ka special behavior:** `orders` ↔ `customers` One-to-One hai (kyunki
> `customer_id` khud order-level unique hai). Power BI 1:1 relationships mein **default "Both"
> cross-filter** rakhta hai (dono directions mein filter flow karta hai) — isliye "state ke
> hisab se average delivery time" jaisा cross-table metric bina extra setting ke kaam karta hai.

## 3. Calculated Columns

```dax
-- orders table
Delivery Days = DATEDIFF(orders[order_purchase_timestamp], orders[order_delivered_customer_date], DAY)

Delivery Status =
IF(
    ISBLANK(orders[order_delivered_customer_date]),
    BLANK(),
    IF(orders[order_delivered_customer_date] <= orders[order_estimated_delivery_date], "On Time", "Late")
)

-- customer_segments table
Customer Type = IF(customer_segments[frequency] > 1, "Repeat", "One-Time")
```

Yeh **row-level** hain — har order/customer ka apna fixed label, filter se nahi badalta.

## 4. DAX Measures (dedicated "Measures" table mein rakhi gayi — organization ke liye)

```dax
Total Revenue = CALCULATE(SUM(order_items[price]) + SUM(order_items[freight_value]), orders[order_status] = "delivered")
Total Orders = CALCULATE(DISTINCTCOUNT(orders[order_id]), orders[order_status] = "delivered")
Total Customers = DISTINCTCOUNT(customers[customer_unique_id])
Average Order Value = DIVIDE([Total Revenue], [Total Orders])
Avg Delivery Days = AVERAGE(orders[Delivery Days])
On-Time Orders = CALCULATE(DISTINCTCOUNT(orders[order_id]), orders[Delivery Status] = "On Time")
Delivered With Date = CALCULATE(DISTINCTCOUNT(orders[order_id]), orders[order_status] = "delivered", NOT ISBLANK(orders[order_delivered_customer_date]))
On-Time Delivery % = DIVIDE([On-Time Orders], [Delivered With Date])
Avg Review Score = AVERAGE(order_reviews[review_score])
Repeat Customers = CALCULATE(DISTINCTCOUNT(customer_segments[customer_unique_id]), customer_segments[frequency] > 1)
Total Segmented Customers = DISTINCTCOUNT(customer_segments[customer_unique_id])
Repeat Customer % = DIVIDE([Repeat Customers], [Total Segmented Customers])
Segment Revenue = SUM(customer_segments[monetary])
Avg Revenue per Customer = AVERAGE(customer_segments[monetary])
```

**Why a dedicated "Measures" table?** Sirf organization ke liye — har measure ek hi jagah milती
hai instead of scattered across data tables (common Power BI hygiene practice).

---

## 5. Page-by-Page Walkthrough

### Page 1 — Executive Overview

- **Purpose / Business question:** "Company ka overall sales health kaisa hai?" — leadership
  ke liye high-level summary.
- **KPI Cards:** Total Revenue, Total Orders, Total Customers, Average Order Value.
- **Charts:** Monthly Revenue Trend (line — Axis: month, Value: `[Total Revenue]`), Orders
  Trend (line/column), Top Categories (horizontal bar, Top N=10).
- **Slicer:** Date range (`orders[order_purchase_timestamp]`).
- **Why these visuals:** Cards = "sabse pehle dekhne wali cheez" high-level numbers. Line chart
  = trend/direction. Bar chart = ranking.
- **What I'd say if asked to explain this page:** "Yeh page ek executive ke liye hai jo sirf
  30 second mein business health samajhna chahता hai — 4 KPI cards top-line numbers deती hain,
  phir revenue trend line dikhाती hai growth/seasonality, aur top-categories bar dikhाता hai
  kahan focus karna hai."

### Page 2 — Customer Insights

- **Purpose:** "Hamare customers kaun hain, aur kितne valuable hain?"
- **Visuals:** New vs Repeat donut (Legend: `Customer Type`), Customer Segments bar
  (RFM segments), Revenue by Segment bar, Top Customers table (customer_unique_id, monetary,
  frequency, segment — Top N=10), Customer Purchase Behavior bar (frequency binned).
- **Slicer:** Customer segment.
- **Why these visuals:** Donut sirf 2-category proportion ke liye theek hai (New vs Repeat).
  Segment bars RFM story ko directly visual banaते hain. Table specific top-customer details
  ke liye (chart se zyada readable jab multiple fields ek saath chahiye hon).
- **What I'd say:** "Yeh page RFM segmentation ko interactive banata hai — koi bhi segment
  slicer se select karke uske customers/revenue dekh sakta hai, jaise sirf 'At Risk' customers
  filter karke unki list nikalna."

### Page 3 — Product & Operations

- **Purpose:** "Products aur delivery operations kaise perform kar rahe hain?"
- **Visuals:** Top Categories bar (revenue), Regional Sales bar/map (state-wise revenue),
  Delivery Time bar (state-wise avg days, Top N=10 slowest), Delivery Performance card/gauge
  (`[On-Time Delivery %]`), Ratings bar (review score distribution), Category/Rating
  relationship bar (Top N lowest-rated categories).
- **Slicer:** Customer state.
- **Why these visuals:** Yeh page do teams ke liye relevant hai — product/category (marketing/
  inventory) aur operations (delivery/logistics) — dono ko ek page par rakha kyunki dono
  "supply-side" performance dekhte hain.

## 6. Slicer Logic — per-page, not synced

Har page ka apna independent slicer hai (date on page 1, segment on page 2, state on page 3) —
**cross-page sync jaan-boojh kar nahi kiya gaya** (Power BI ka "Sync Slicers" feature exist
karta hai, lekin isе add karna extra complexity hai jo is project ke beginner-friendly scope
se bahar rakhी gayi).

## 7. Formatting Choices

- Ek consistent accent color (teal/blue) poore report mein — alag palette per page nahi.
- Max ~6-7 visuals per page.
- "Top N = 10" filter har ranking bar chart par — kabhi 70+ categories/27 states ek saath nahi.
- Page-level title text box har page ke liye.

---

## INTERVIEW

**Q: "Apna dashboard walk-through karo."**
> Page-by-page jaओ (upar section 5 use karo) — har page ka purpose, 2-3 key visual, aur "why
> this visual" bolo. End mein overall design-principle bolo (max 6-7 visuals/page, Top-N
> filters, consistent color).

**Q: "Ek alag `category_performance` table kyun banaई, relationship se kyun nahi jodी?"**
> 3-hop chain (`products→order_items→orders→order_reviews`) ke liye bidirectional relationship
> chahiye hoती, jo beginner-model mein ambiguity la sakti hai. Isliye Python mein precompute
> karke standalone table ki tarah import kiya — real BI projects mein yeh ek legitimate,
> common "denormalized reporting table" pattern hai.

**Q: "Dashboard actually build kiya hai?"**
> Honest answer: "Poora data-model/DAX/page-design ready hai — Power BI Desktop mein physically
> build karna ek manual GUI step hai." (Update this answer based on actual current status when
> you build it.)

---

## What I should remember

- 3 pages: Executive Overview (sales KPIs), Customer Insights (RFM interactive), Product &
  Operations (category + delivery + ratings).
- `category_performance` — precomputed table, no live relationship — avoids a bidirectional-
  relationship complexity trap.
- 1:1 relationship (`orders`↔`customers`) uses "Both" cross-filter direction by default.
- Slicers are per-page, not synced — a deliberate simplicity choice.
- Be honest about build status — the design is complete; the manual Power BI Desktop build
  step is separate from the analytical work.
