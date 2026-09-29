"""
Exports a small, denormalized category_performance.csv summary table for Power BI.

WHY this exists (see docs/06_powerbi_learning.md section on data modeling): combining
category + revenue + order count + avg price + avg review score in one visual would require
a 3-hop relationship chain in Power BI (products -> order_items -> orders -> order_reviews)
which needs a bidirectional relationship to work correctly. For a beginner-friendly model, it
is simpler and safer to precompute this one cross-cutting summary here in Python (numbers are
identical to sql/01 and sql/03 queries - this is not new analysis, just a convenience export).

Run with: python scripts/export_powerbi_tables.py
"""
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"

orders = pd.read_csv(PROCESSED_DIR / "orders.csv", parse_dates=[
    "order_purchase_timestamp", "order_delivered_customer_date"
])
order_items = pd.read_csv(PROCESSED_DIR / "order_items.csv")
order_reviews = pd.read_csv(PROCESSED_DIR / "order_reviews.csv")
products = pd.read_csv(PROCESSED_DIR / "products.csv")

delivered_order_ids = orders.loc[orders["order_status"] == "delivered", "order_id"]

items_delivered = (
    order_items[order_items["order_id"].isin(delivered_order_ids)]
    .merge(products[["product_id", "product_category_name_english"]], on="product_id")
)

revenue_by_category = (
    items_delivered.assign(item_revenue=items_delivered["price"] + items_delivered["freight_value"])
    .groupby("product_category_name_english", as_index=False)
    .agg(
        revenue=("item_revenue", "sum"),
        orders_count=("order_id", "nunique"),
        avg_price=("price", "mean"),
    )
)

ratings_by_category = (
    order_items.merge(products[["product_id", "product_category_name_english"]], on="product_id")
    .merge(order_reviews[["order_id", "review_score"]], on="order_id")
    .groupby("product_category_name_english", as_index=False)
    .agg(avg_review_score=("review_score", "mean"), reviews_count=("order_id", "nunique"))
)

category_performance = revenue_by_category.merge(
    ratings_by_category, on="product_category_name_english", how="left"
).rename(columns={"product_category_name_english": "category"})

category_performance["revenue"] = category_performance["revenue"].round(2)
category_performance["avg_price"] = category_performance["avg_price"].round(2)
category_performance["avg_review_score"] = category_performance["avg_review_score"].round(2)

out_path = PROCESSED_DIR / "category_performance.csv"
category_performance.sort_values("revenue", ascending=False).to_csv(out_path, index=False)
print(f"Exported {len(category_performance)} categories -> {out_path}")
print(category_performance.sort_values("revenue", ascending=False).head(10))
