"""
One-time exploration script for Phase 1 (Data Understanding).

Reads every raw CSV in data/raw/ and prints:
- shape, dtypes, memory usage
- null counts per column
- duplicate row counts
- key business facts (date ranges, order status mix, review score mix, etc.)

Output of this script is the factual basis for docs/01_dataset_understanding.md.
Nothing in that doc should say anything this script didn't actually show.
"""
import pandas as pd
from pathlib import Path

RAW_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"

FILES = [
    "olist_customers_dataset.csv",
    "olist_geolocation_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_products_dataset.csv",
    "olist_sellers_dataset.csv",
    "product_category_name_translation.csv",
]

pd.set_option("display.max_columns", None)
pd.set_option("display.width", 160)

dfs = {}
for fname in FILES:
    df = pd.read_csv(RAW_DIR / fname)
    dfs[fname] = df
    print("=" * 100)
    print(fname)
    print("=" * 100)
    print(f"shape: {df.shape[0]:,} rows x {df.shape[1]} cols")
    print(f"memory: {df.memory_usage(deep=True).sum() / 1_048_576:.2f} MB")
    print("\ncolumns & dtypes:")
    print(df.dtypes)
    print("\nnull counts (only columns with > 0 nulls):")
    nulls = df.isnull().sum()
    nulls = nulls[nulls > 0]
    if len(nulls) == 0:
        print("  none")
    else:
        for col, cnt in nulls.items():
            print(f"  {col}: {cnt:,} ({cnt / len(df) * 100:.2f}%)")
    print(f"\nfully duplicated rows: {df.duplicated().sum():,}")
    print("\nsample rows:")
    print(df.head(2))
    print()

# ---- Business-context facts (real numbers, not guesses) ----
orders = dfs["olist_orders_dataset.csv"]
items = dfs["olist_order_items_dataset.csv"]
payments = dfs["olist_order_payments_dataset.csv"]
reviews = dfs["olist_order_reviews_dataset.csv"]
customers = dfs["olist_customers_dataset.csv"]
products = dfs["olist_products_dataset.csv"]
sellers = dfs["olist_sellers_dataset.csv"]
geo = dfs["olist_geolocation_dataset.csv"]
cat_trans = dfs["product_category_name_translation.csv"]

print("#" * 100)
print("BUSINESS CONTEXT FACTS")
print("#" * 100)

print("\n--- order_status value counts ---")
print(orders["order_status"].value_counts())

for col in ["order_purchase_timestamp", "order_approved_at", "order_delivered_carrier_date",
            "order_delivered_customer_date", "order_estimated_delivery_date"]:
    print(f"\n--- date range: {col} ---")
    parsed = pd.to_datetime(orders[col], errors="coerce")
    print(f"min: {parsed.min()}  max: {parsed.max()}  missing: {parsed.isnull().sum():,}")

print(f"\nunique customer_id in customers.csv: {customers['customer_id'].nunique():,}")
print(f"unique customer_unique_id in customers.csv: {customers['customer_unique_id'].nunique():,}")
print(f"unique order_id in orders.csv: {orders['order_id'].nunique():,}")
print(f"unique order_id in order_items.csv: {items['order_id'].nunique():,}")
print(f"total order_item rows (line items): {len(items):,}")
print(f"unique product_id in products.csv: {products['product_id'].nunique():,}")
print(f"unique product_id referenced in order_items.csv: {items['product_id'].nunique():,}")
print(f"unique seller_id in sellers.csv: {sellers['seller_id'].nunique():,}")
print(f"unique seller_id referenced in order_items.csv: {items['seller_id'].nunique():,}")

print("\n--- payment_type value counts ---")
print(payments["payment_type"].value_counts())
print(f"\npayment installments range: {payments['payment_installments'].min()} to {payments['payment_installments'].max()}")

print("\n--- review_score value counts ---")
print(reviews["review_score"].value_counts().sort_index())
print(f"unique order_id in reviews: {reviews['order_id'].nunique():,}  total review rows: {len(reviews):,}")

print(f"\nproduct_category_name nulls in products.csv: {products['product_category_name'].isnull().sum():,}")
print(f"unique product_category_name (raw, PT-BR): {products['product_category_name'].nunique():,}")
print(f"unique category translations available: {cat_trans['product_category_name'].nunique():,}")

# Referential coverage checks
missing_cat_after_join = products.merge(
    cat_trans, on="product_category_name", how="left"
)["product_category_name_english"].isnull().sum()
print(f"products whose category has NO english translation match: {missing_cat_after_join:,}")

print(f"\nunique customer_state in customers.csv: {customers['customer_state'].nunique()}")
print(customers["customer_state"].value_counts().head(10))

print(f"\nunique zip_code_prefix in geolocation: {geo['geolocation_zip_code_prefix'].nunique():,}")
print(f"geolocation rows: {len(geo):,} (many rows per zip due to multiple lat/lng samples)")

# order_items <-> orders status cross check: how many delivered vs not, for revenue scoping decision
merged = items.merge(orders[["order_id", "order_status"]], on="order_id", how="left")
print("\n--- order_items joined to order_status (for revenue scoping decision) ---")
print(merged["order_status"].value_counts())
