"""
Small reusable helper to execute .sql files (or ad-hoc query strings) against
data/ecommerce.db and print real results. Used while building sql/*.sql so that every
"expected result" written into docs/03_sql_learning.md reflects ACTUAL query output.

Each .sql file is expected to contain one or more statements separated by `;`.
A statement can be preceded by a `-- Query N: <title>` comment line, which is used as a label.

Run with: python scripts/run_sql.py sql/01_basic_sales_analysis.sql
"""
import sqlite3
import sys
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = PROJECT_ROOT / "data" / "ecommerce.db"


def split_statements(sql_text: str):
    statements = []
    current_lines = []
    label = None
    for line in sql_text.splitlines():
        stripped = line.strip()
        if stripped.startswith("-- Query"):
            label = stripped.lstrip("- ").strip()
        current_lines.append(line)
        if stripped.endswith(";"):
            stmt = "\n".join(current_lines)
            if stmt.strip().lstrip("-").strip():
                statements.append((label, stmt))
            current_lines = []
            label = None
    remainder = "\n".join(current_lines).strip()
    if remainder:
        statements.append((label, remainder))
    return statements


def main():
    sql_file = Path(sys.argv[1])
    conn = sqlite3.connect(DB_PATH)
    pd.set_option("display.max_columns", None)
    pd.set_option("display.width", 160)
    pd.set_option("display.max_rows", 30)

    text = sql_file.read_text(encoding="utf-8")
    statements = split_statements(text)

    for label, stmt in statements:
        clean_stmt = "\n".join(
            l for l in stmt.splitlines() if not l.strip().startswith("--")
        ).strip()
        if not clean_stmt:
            continue
        print("=" * 100)
        print(label or "(query)")
        print("=" * 100)
        try:
            if clean_stmt.lower().startswith(("select", "with")):
                df = pd.read_sql(clean_stmt, conn)
                print(df.to_string(index=False))
                print(f"\n[{len(df)} row(s) returned]")
            else:
                conn.execute(clean_stmt)
                conn.commit()
                print("(executed - no result set)")
        except Exception as e:
            print(f"ERROR: {e}")
        print()

    conn.close()


if __name__ == "__main__":
    main()
