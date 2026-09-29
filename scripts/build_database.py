"""
Loads the CLEANED CSVs from data/processed/ into a single SQLite database
(data/ecommerce.db) so the .sql files in sql/ can be executed for real.

This script does NOT contain any cleaning logic — all cleaning already happened
in notebooks/01_eda.ipynb. This is just a straightforward "load clean CSV -> SQL table" step.

Run with: python scripts/build_database.py
"""
import sqlite3
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"
DB_PATH = PROJECT_ROOT / "data" / "ecommerce.db"

# table_name -> csv filename
TABLES = {
    "customers": "customers.csv",
    "geolocation": "geolocation.csv",
    "orders": "orders.csv",
    "order_items": "order_items.csv",
    "order_payments": "order_payments.csv",
    "order_reviews": "order_reviews.csv",
    "products": "products.csv",
    "sellers": "sellers.csv",
}

DATE_COLUMNS = {
    "orders": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ],
    "order_items": ["shipping_limit_date"],
    "order_reviews": ["review_creation_date", "review_answer_timestamp"],
}


def main() -> None:
    if DB_PATH.exists():
        DB_PATH.unlink()  # rebuild fresh every time, keeps this script idempotent

    conn = sqlite3.connect(DB_PATH)

    for table_name, csv_name in TABLES.items():
        df = pd.read_csv(PROCESSED_DIR / csv_name)
        for col in DATE_COLUMNS.get(table_name, []):
            df[col] = pd.to_datetime(df[col], errors="coerce")
        df.to_sql(table_name, conn, if_exists="replace", index=False)
        print(f"Loaded {table_name:15s} -> {len(df):>8,} rows")

    # Helpful indexes for the join keys we will use constantly in sql/*.sql
    # IMPORTANT: pandas.to_sql does not create a PRIMARY KEY or any index, so without
    # these, joins on orders.order_id / customers.customer_id / products.product_id
    # force SQLite into a full-table-scan nested loop (extremely slow on ~100k rows).
    cur = conn.cursor()
    index_statements = [
        "CREATE INDEX idx_orders_order_id ON orders(order_id)",
        "CREATE INDEX idx_orders_customer_id ON orders(customer_id)",
        "CREATE INDEX idx_orders_status ON orders(order_status)",
        "CREATE INDEX idx_order_items_order_id ON order_items(order_id)",
        "CREATE INDEX idx_order_items_product_id ON order_items(product_id)",
        "CREATE INDEX idx_order_items_seller_id ON order_items(seller_id)",
        "CREATE INDEX idx_order_payments_order_id ON order_payments(order_id)",
        "CREATE INDEX idx_order_reviews_order_id ON order_reviews(order_id)",
        "CREATE INDEX idx_customers_customer_id ON customers(customer_id)",
        "CREATE INDEX idx_customers_unique_id ON customers(customer_unique_id)",
        "CREATE INDEX idx_customers_state ON customers(customer_state)",
        "CREATE INDEX idx_products_product_id ON products(product_id)",
        "CREATE INDEX idx_sellers_seller_id ON sellers(seller_id)",
    ]
    for stmt in index_statements:
        cur.execute(stmt)
    cur.execute("ANALYZE")  # helps the query planner actually pick these indexes
    conn.commit()

    print(f"\nSQLite database written to: {DB_PATH}")
    tables_in_db = pd.read_sql(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name", conn
    )
    print("Tables:", ", ".join(tables_in_db["name"]))
    conn.close()


if __name__ == "__main__":
    main()
