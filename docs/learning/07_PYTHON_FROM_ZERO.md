# 07 — Python From Zero

> **Important scoping note:** Yeh section **poori Python programming language nahi** sikhati —
> sirf utna jitna ek Data Analyst ko chahiye. Agar tumhe pehle se coding aati hai, yeh file
> jaldi (revision ki tarah) padh sakte ho.

## "Data Analyst ko Python se exactly kya chahiye?"

Ek DA Python ko **software banane** ke liye nahi, **data ko load/clean/analyze** karne ke liye
use karta hai. Isliye focus hota hai: variables, basic data structures (list/dict), loops,
functions, aur **libraries import karna** (especially Pandas) — advanced software-engineering
concepts (classes, OOP design patterns, multithreading, etc.) zaroori nahi.

---

## 1. Variables

- **Kya hai:** Ek naam jo kisi value ko "store" karta hai.
- **Example:**
  ```python
  price = 159.83
  category = "health_beauty"
  is_delivered = True
  ```
- **DA context:** Column names, file paths, thresholds store karne ke liye
  (`RAW_DIR = Path(...)` jaisa notebook mein hai).

## 2. Lists

- **Kya hai:** Ordered cheezon ka collection, `[...]` mein.
- **Example:**
  ```python
  categories = ["health_beauty", "bed_bath_table", "sports_leisure"]
  print(categories[0])   # health_beauty
  print(len(categories))  # 3
  ```
- **DA context:** Column names ki list (`date_cols_orders = [...]` jaisa `build_database.py`
  mein hai), ya files ki list (`FILES = [...]` jaisa `explore_raw_data.py` mein hai).

## 3. Dictionaries

- **Kya hai:** Key-Value pairs ka collection, `{key: value}` mein.
- **Example:**
  ```python
  table_files = {
      "customers": "olist_customers_dataset.csv",
      "orders": "olist_orders_dataset.csv",
  }
  print(table_files["orders"])  # olist_orders_dataset.csv
  ```
- **DA context:** Yeh project mein bahut use hua hai — `TABLES = {...}` (`build_database.py`),
  `DATE_COLUMNS = {...}` (kaunse table ke kaunse columns date hain), `tables = {...}` (notebook
  mein har DataFrame ko naam se store karna).

## 4. Loops (`for`)

- **Kya hai:** Same operation ko multiple items par repeat karna.
- **Example:**
  ```python
  for category in categories:
      print(category.upper())
  ```
- **DA context:** `for name, df in tables.items(): print(df.shape)` — har table ka shape print
  karna ek hi loop se (notebook Section 3).

## 5. Conditions (`if` / `else`)

- **Kya hai:** Condition ke basis par different code chalana.
- **Example:**
  ```python
  if price > 1000:
      tier = "premium"
  else:
      tier = "regular"
  ```
- **DA context:** Pandas mein hum yeh usually `if/else` se nahi, **vectorized** tarike se karte
  hain (`np.where`, ya `.apply()` ke andar) — dekho file 08. Direct `if/else` zyada script-level
  logic ke liye use hota hai (jaise `build_database.py` mein `if DB_PATH.exists(): DB_PATH.unlink()`).

## 6. Functions

- **Kya hai:** Code ka ek reusable block, ek naam ke saath.
- **Example:**
  ```python
  def calculate_aov(total_revenue, total_orders):
      return round(total_revenue / total_orders, 2)

  print(calculate_aov(1_541_977.75, 9_648))
  ```
- **DA context:** `def main(): ...` poore scripts (`build_database.py`, `run_sql.py`, etc.) mein
  — code ko organized rakhne ke liye. `split_statements()` (`run_sql.py`) ek DA-relevant helper
  function ka example hai.

## 7. Importing Libraries

- **Kya hai:** Kisi doosre ne likha hua, ready-made code apne program mein use karna.
- **Example:**
  ```python
  import pandas as pd
  import numpy as np
  import matplotlib.pyplot as plt
  import seaborn as sns
  from pathlib import Path
  ```
- **Why `as pd`?** Chhota alias — baar-baar `pandas.` likhne ke bajaye `pd.` likhna.
- **DA context:** Har script/notebook ka pehla step yehi hai. Is project mein: `pandas` (data),
  `numpy` (numeric ops), `matplotlib`/`seaborn` (charts), `pathlib` (file paths, OS-independent
  way), `sqlite3` (database).

## 8. Reading a CSV file

```python
import pandas as pd
df = pd.read_csv("data/raw/olist_orders_dataset.csv")
```

Yeh CSV (Comma-Separated Values — plain text file jahan har line ek row, commas se columns
separate) ko ek **DataFrame** mein load karta hai (dekho file 08).

## 9. Basic Data Manipulation (preview — full detail file 08 mein)

```python
df["new_column"] = df["price"] + df["freight_value"]   # naya column banana
filtered = df[df["order_status"] == "delivered"]         # filtering
summary = df.groupby("category")["price"].mean()          # group + aggregate
```

---

## INTERVIEW

**Q: "Pandas kya hai aur Python se iska relation kya hai?"**
> Pandas ek Python **library** hai (khud Python nahi) — Python ke upar bani hai, tabular data
> (Excel-jaisa) ko handle karne ke liye extra functionality deती hai.

**Q: "Data Analyst ko poori Python seekhni chahiye ya sirf kuch parts?"**
> Practically, DA role ke liye variables/lists/dicts/loops/functions/library-imports + Pandas
> kaafi hai. Advanced software-engineering (classes/OOP, web-frameworks, etc.) zaroori nahi
> unless role Data Engineer-adjacent ho.

**Q: "For loop aur Pandas vectorized operation mein tum kaunsa prefer karoge, aur kyun?"**
> Pandas vectorized operations (jaise `df["a"] + df["b"]`) — yeh internally optimized/fast hote
> hain. Python `for` loop se row-by-row process karna bahut slow hai bade data par. (Dekho
> [28_COMMON_MISTAKES.md](28_COMMON_MISTAKES.md).)

---

## What I should remember

- DA ke liye Python = variables + lists/dicts + loops + functions + library imports (poori
  language nahi).
- CSV read karna: `pd.read_csv(path)`.
- Real kaam **Pandas** se hota hai — agli file ([08_PANDAS_FROM_ZERO.md](08_PANDAS_FROM_ZERO.md))
  mein woh detail se.
- Is project ke scripts (`scripts/*.py`) mein yehi basics use hue hain — dictionaries (table
  names → files), loops (har table process karna), functions (`main()`).
