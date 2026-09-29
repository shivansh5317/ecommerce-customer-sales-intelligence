"""
Creates (or refreshes) the customer_rfm view in data/ecommerce.db and exports it to
data/processed/customer_segments.csv, ready for Power BI import.

Run with: python scripts/export_customer_segments.py
(Run this AFTER scripts/build_database.py and AFTER sql/06_customer_segmentation.sql
 logic has been finalized - this script re-creates the view from the same .sql file
 so the CSV always matches what's documented in docs/04_customer_segmentation.md.)
"""
import sqlite3
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = PROJECT_ROOT / "data" / "ecommerce.db"
SQL_PATH = PROJECT_ROOT / "sql" / "06_customer_segmentation.sql"
OUT_PATH = PROJECT_ROOT / "data" / "processed" / "customer_segments.csv"


def main() -> None:
    conn = sqlite3.connect(DB_PATH)

    # Pull out just the DROP VIEW / CREATE VIEW statement block from the .sql file
    # (everything from "DROP VIEW" to the first ";" that follows "customer_segment").
    text = SQL_PATH.read_text(encoding="utf-8")
    start = text.index("DROP VIEW")
    end = text.index("FROM rfm_scores;") + len("FROM rfm_scores;")
    view_sql = text[start:end]

    conn.executescript(view_sql)
    conn.commit()

    df = pd.read_sql("SELECT * FROM customer_rfm", conn)
    df.to_csv(OUT_PATH, index=False)
    print(f"Exported {len(df):,} customer segment rows -> {OUT_PATH}")
    print(df["customer_segment"].value_counts())

    conn.close()


if __name__ == "__main__":
    main()
