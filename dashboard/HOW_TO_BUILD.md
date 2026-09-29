# How To Build The Dashboard (Manual Steps — Power BI Desktop Required)

Power BI Desktop is a Windows GUI application — it cannot be scripted or automated from this
repo. Everything that COULD be prepared in advance has been (cleaned CSVs, DAX measures,
relationships, page/visual spec in `README.md`). Follow these steps yourself:

## Step 0 — Install Power BI Desktop (if not already installed)

Free download from Microsoft: search "Power BI Desktop" in the Microsoft Store, or download
from powerbi.microsoft.com. No license needed for Desktop (only needed to publish/share online).

## Step 1 — Import data

1. Open Power BI Desktop → **Home → Get Data → Text/CSV**.
2. Import each file listed in `README.md` section 1, one at a time, from this project's
   `data/processed/` folder.
3. Make sure `order_purchase_timestamp`, `order_delivered_customer_date`,
   `order_estimated_delivery_date` are recognized as **Date/Time** type (check in Power Query
   Editor — Power BI usually auto-detects this correctly for ISO-format dates).

## Step 2 — Build the data model

1. Go to **Model view** (left sidebar icon that looks like connected tables).
2. Drag to create each relationship listed in `README.md` section 2. Power BI usually
   auto-detects some of these from matching column names — verify cardinality and cross-filter
   direction match the table exactly (double-click each relationship line to check/edit).
3. Leave `category_performance` unconnected (no relationship lines to it) — this is intentional.

## Step 3 — Add calculated columns

1. Click on the `orders` table (Data view or Model view), then **Table tools → New column**.
2. Paste each formula from `README.md` section 3, one at a time, naming the column exactly as
   shown (e.g. `Delivery Days`).
3. Repeat for the `customer_segments` table (`Customer Type` column).

## Step 4 — Add measures

1. Right-click any table in the Fields pane → **New table** → type `Measures = {BLANK()}` →
   Enter. Delete the placeholder `Value` column that appears (right-click it → Delete).
2. Click the new `Measures` table → **Table tools → New measure**.
3. Paste each DAX formula from `README.md` section 4, one at a time.

## Step 5 — Build each page

1. Add 3 pages (right-click page tabs at the bottom → **New page**, or use the `+`).
2. Rename them: `Executive Overview`, `Customer Insights`, `Product & Operations`.
3. For each page, add the visuals listed in `README.md` section 5 — use the **Visualizations**
   pane to pick chart type, then drag the listed fields into Axis/Legend/Values as specified.
4. For "Top N" bar charts: click the visual → **Filters pane** → drag the axis field into
   filters → **Filter type: Top N** → enter `10` → drag the value field into "By value".

## Step 6 — Format & polish

Follow `README.md` section 6 (consistent colors, max ~6-7 visuals/page, page titles).

## Step 7 — Export screenshots

Once each page looks good: **File → Export → Export to PDF**, or simply take a screenshot of
each page (Snipping Tool / Win+Shift+S) and save into `screenshots/` as:
- `screenshots/page1_executive_overview.png`
- `screenshots/page2_customer_insights.png`
- `screenshots/page3_product_operations.png`

Then reference these screenshots in the main `README.md` (placeholders are already there).

## Step 8 — (Optional) Save the .pbix file

Save your Power BI file into this `dashboard/` folder, e.g.
`dashboard/ecommerce_dashboard.pbix`, so it's part of the repo (note: `.pbix` files are
binary — GitHub will store them fine but won't show a text diff).
