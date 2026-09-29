# Power BI Dashboard — Build Guide

> This folder contains everything that CAN be prepared without opening Power BI Desktop:
> the data model, relationships, calculated columns, and DAX measures. Power BI Desktop itself
> is a GUI application that cannot be automated from here — **you need to build the visuals
> yourself in Power BI Desktop by following this guide.** See `HOW_TO_BUILD.md` for the exact
> manual steps. Concept explanations (why each measure/visual/relationship) are in
> `docs/06_powerbi_learning.md`.

## 1. Data source

Import these CSVs from `data/processed/` into Power BI (**Get Data → Text/CSV**):

| File | Role | Grain (1 row =) |
|---|---|---|
| `orders.csv` | Fact table (order lifecycle) | 1 order |
| `order_items.csv` | Fact table (line items) | 1 product within an order |
| `order_payments.csv` | Fact table (payments) | 1 payment transaction |
| `order_reviews.csv` | Fact table (reviews) | 1 review |
| `products.csv` | Lookup table | 1 product |
| `customers.csv` | Lookup table | 1 customer_id (order-level) |
| `sellers.csv` | Lookup table | 1 seller |
| `customer_segments.csv` | RFM lookup table | 1 real customer (`customer_unique_id`) |
| `category_performance.csv` | Precomputed summary (see note below) | 1 category |

**Note on `category_performance.csv`:** combining category + revenue + order-count + avg price
+ avg rating in one visual needs a 3-table relationship chain
(`products → order_items → orders → order_reviews`). That chain requires a **bidirectional**
relationship to work, which is an easy source of confusing/ambiguous results for a beginner
model. Instead, this one cross-cutting summary is precomputed in Python
(`scripts/export_powerbi_tables.py` — same numbers as `sql/01` and `sql/03`, not new analysis)
and imported as its own small standalone table used only for category-performance visuals.

## 2. Relationships (set these up in Power BI's Model view)

| From table | To table | Cardinality | Cross-filter direction |
|---|---|---|---|
| `orders[order_id]` | `order_items[order_id]` | One-to-many | Single (orders → order_items) |
| `orders[order_id]` | `order_payments[order_id]` | One-to-many | Single |
| `orders[order_id]` | `order_reviews[order_id]` | One-to-many* | Single |
| `order_items[product_id]` | `products[product_id]` | Many-to-one | Single |
| `order_items[seller_id]` | `sellers[seller_id]` | Many-to-one | Single |
| `orders[customer_id]` | `customers[customer_id]` | One-to-one | Both (Power BI default for 1:1) |
| `customers[customer_unique_id]` | `customer_segments[customer_unique_id]` | Many-to-one | Single |

`category_performance` stays **unrelated** (no relationship) — it is used standalone, filtered
only by its own `category` column via slicers, not cross-filtered from other tables.

*In practice each order has 0 or 1 review after cleaning, but Power BI still models it as
one-to-many since it cannot enforce that uniqueness itself.

## 3. Calculated columns to create

On the **`orders`** table:

```dax
Delivery Days = DATEDIFF(orders[order_purchase_timestamp], orders[order_delivered_customer_date], DAY)

Delivery Status =
IF(
    ISBLANK(orders[order_delivered_customer_date]),
    BLANK(),
    IF(orders[order_delivered_customer_date] <= orders[order_estimated_delivery_date], "On Time", "Late")
)
```

On the **`customer_segments`** table:

```dax
Customer Type = IF(customer_segments[frequency] > 1, "Repeat", "One-Time")
```

## 4. DAX measures to create

Create a dedicated **"Measures" table** (Modeling → New Table → `Measures = {BLANK()}`, then
delete its column) to keep all measures organized in one place rather than scattered across
data tables — this is a common, simple Power BI hygiene practice.

```dax
Total Revenue =
CALCULATE(
    SUM(order_items[price]) + SUM(order_items[freight_value]),
    orders[order_status] = "delivered"
)

Total Orders =
CALCULATE(DISTINCTCOUNT(orders[order_id]), orders[order_status] = "delivered")

Total Customers = DISTINCTCOUNT(customers[customer_unique_id])

Average Order Value = DIVIDE([Total Revenue], [Total Orders])

Avg Delivery Days = AVERAGE(orders[Delivery Days])

On-Time Orders = CALCULATE(DISTINCTCOUNT(orders[order_id]), orders[Delivery Status] = "On Time")

Delivered With Date =
CALCULATE(
    DISTINCTCOUNT(orders[order_id]),
    orders[order_status] = "delivered",
    NOT ISBLANK(orders[order_delivered_customer_date])
)

On-Time Delivery % = DIVIDE([On-Time Orders], [Delivered With Date])

Avg Review Score = AVERAGE(order_reviews[review_score])

Repeat Customers = CALCULATE(DISTINCTCOUNT(customer_segments[customer_unique_id]), customer_segments[frequency] > 1)

Total Segmented Customers = DISTINCTCOUNT(customer_segments[customer_unique_id])

Repeat Customer % = DIVIDE([Repeat Customers], [Total Segmented Customers])

Segment Revenue = SUM(customer_segments[monetary])

Avg Revenue per Customer = AVERAGE(customer_segments[monetary])
```

## 5. Pages & visuals

### Page 1 — Executive Overview

| Visual | Type | Fields |
|---|---|---|
| Total Revenue | Card | `[Total Revenue]` |
| Total Orders | Card | `[Total Orders]` |
| Total Customers | Card | `[Total Customers]` |
| Average Order Value | Card | `[Average Order Value]` |
| Monthly Revenue Trend | Line chart | Axis: `orders[order_purchase_timestamp]` (Month), Value: `[Total Revenue]` |
| Orders Trend | Line/column chart | Axis: `orders[order_purchase_timestamp]` (Month), Value: `[Total Orders]` |
| Top Categories | Horizontal bar | Axis: `category_performance[category]`, Value: `category_performance[revenue]` (Top N = 10) |
| Slicer | Slicer | `orders[order_purchase_timestamp]` (date range) |

### Page 2 — Customer Insights

| Visual | Type | Fields |
|---|---|---|
| New vs Repeat Customers | Donut chart | Legend: `customer_segments[Customer Type]`, Value: `[Total Segmented Customers]` |
| Customer Segments | Bar chart | Axis: `customer_segments[customer_segment]`, Value: count of `customer_unique_id` |
| Revenue by Segment | Bar chart | Axis: `customer_segments[customer_segment]`, Value: `[Segment Revenue]` |
| Top Customers | Table | `customer_segments[customer_unique_id]`, `[monetary]`, `[frequency]`, `[customer_segment]` — sorted by monetary, Top N = 10 |
| Customer Purchase Behavior | Bar chart | Axis: `customer_segments[frequency]` (binned: 1 / 2 / 3-5 / 6+), Value: count of customers |
| Slicer | Slicer | `customer_segments[customer_segment]` |

### Page 3 — Product & Operations

| Visual | Type | Fields |
|---|---|---|
| Top Categories | Bar chart | `category_performance[category]`, `category_performance[revenue]` |
| Regional Sales | Bar chart (or Map) | Axis: `customers[customer_state]`, Value: `[Total Revenue]` |
| Delivery Time | Bar chart | Axis: `customers[customer_state]`, Value: `[Avg Delivery Days]` (Top N = 10, sorted descending) |
| Delivery Performance | Card / Gauge | `[On-Time Delivery %]` |
| Ratings | Bar chart | Axis: `order_reviews[review_score]`, Value: count of reviews |
| Category/Rating relationship | Bar chart | Axis: `category_performance[category]`, Value: `category_performance[avg_review_score]` (Top N = 10 lowest) |
| Slicer | Slicer | `customers[customer_state]` |

## 6. Formatting guidance (keep it clean, not overloaded)

- One consistent color per KPI card row; use a single accent color (e.g. teal/blue) across
  all pages rather than a different palette per page.
- Max ~6-7 visuals per page (matches the tables above) — do not add more just to fill space.
- Use "Top N" filters (10) on every ranking bar chart — never show all 70+ categories or all
  27 states in one chart.
- Add a page-level title text box per page ("Executive Overview", "Customer Insights",
  "Product & Operations").
