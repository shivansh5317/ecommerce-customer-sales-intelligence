# 08 — Pandas From Zero

> Pandas ek Python library hai jo Excel-jaisa tabular data (rows/columns) ko **code se** handle
> karne deती hai — cleaning, transformation, aggregation, analysis, sab kuch. Yeh file har
> important Pandas function ko: syntax + simple example + project usage + interview question
> format mein sikhati hai.

---

## 1. `DataFrame` aur `Series` — core objects

| Term | Kya hai | Example |
|---|---|---|
| **DataFrame** | 2D table — rows aur named columns | `orders` (poori `orders.csv`) |
| **Series** | Ek single column (1D) | `orders["order_status"]` |

**Analogy:** DataFrame = poori Excel sheet. Series = usmein se ek column.

```python
import pandas as pd
orders = pd.read_csv("data/raw/olist_orders_dataset.csv")
print(type(orders))                  # DataFrame
print(type(orders["order_status"]))  # Series
```

## 2. Inspecting Data — `.head()`, `.tail()`, `.shape`, `.columns`, `.info()`, `.describe()`

| Function | Kya karta hai | Example output |
|---|---|---|
| `.head(n)` | Pehle `n` rows dikhata hai (default 5) | Preview karne ke liye |
| `.tail(n)` | Aakhri `n` rows | Data ke end ko check karne ke liye |
| `.shape` | `(rows, columns)` tuple | `(99441, 8)` |
| `.columns` | Column names ki list | `Index(['order_id', 'customer_id', ...])` |
| `.info()` | Column dtypes + non-null counts, ek saath | Data types aur nulls ka quick overview |
| `.describe()` | Numeric columns ka statistical summary (mean/std/min/max/quartiles) | `price` column ke liye mean/min/max |

**My project mein:** `notebooks/01_eda.ipynb` Section 3 ("Inspect Data") mein `.dtypes` aur
`.isnull().sum()` — yeh cleaning shuru karne se **pehle** "kya galat hai" pata karne ke liye use
hote hain.

> **Interview Tip:** *"Cleaning shuru karne se pehle tum kya karte ho?"* → "`.info()` aur
> `.describe()` se data ki shape/types/nulls samajhta hoon, tabhi decide karta hoon kya clean
> karna hai."

## 3. Selecting Data — `.loc[]` vs `.iloc[]`

| | `.loc[]` | `.iloc[]` |
|---|---|---|
| **Kaam karta hai** | **Label/name** ke basis par | **Position/index number** ke basis par |
| **Example** | `df.loc[0, "price"]` (row-label 0, column "price") | `df.iloc[0, 2]` (row position 0, column position 2) |

```python
df.loc[df["order_status"] == "delivered", "order_id"]   # condition + specific column
df.iloc[0:5, 0:3]                                          # first 5 rows, first 3 columns
```

## 4. Filtering

```python
delivered = orders[orders["order_status"] == "delivered"]
high_price = order_items[order_items["price"] > 1000]
multi_condition = orders[(orders["order_status"] == "delivered") & (orders["delivery_days"] > 30)]
```

> ⚠️ **Common mistake:** Python ke normal `and`/`or` use karna Pandas condition mein — Pandas
> ko `&`/`|` chahiye (aur har condition ko bracket `()` mein rakhna zaroori hai).

## 5. Sorting

```python
orders.sort_values("order_purchase_timestamp")
orders.sort_values("price", ascending=False)   # descending
```

## 6. Missing Values — `.isnull()`, `.dropna()`, `.fillna()`

| Function | Kya karta hai | Kab use karo |
|---|---|---|
| `.isnull().sum()` | Har column mein kitne null count karta hai | Inspection step |
| `.dropna()` | Rows/columns delete karta hai jinme null hai | Jab data itna negligible ho ki drop karna safe ho |
| `.dropna(subset=["col1", "col2"])` | Sirf specified columns mein null hone par row hataata hai | **Zyada safe** — poori row sirf kisi ek irrelevant column ke null hone par delete nahi hoti |
| `.fillna("value")` | Null ko ek default value se replace karta hai | Jab categorical column mein meaningful default ho |

**My project mein:**
```python
products["product_category_name"] = products["product_category_name"].fillna("unknown")
products = products.dropna(subset=["product_weight_g", "product_length_cm",
                                    "product_height_cm", "product_width_cm"])
```

> ⚠️ **Bahut common beginner mistake:** `.dropna()` bina `subset` ke use karna — yeh poori row
> delete kar deta hai agar **kisi bhi** column mein null ho, chahe wo column tumhare analysis
> ke liye irrelevant hi kyun na ho. Hamesha socho: "kaunse specific columns null hone par yeh
> row useless hai?" phir wahi `subset` mein do.

## 7. Duplicates — `.duplicated()`, `.drop_duplicates()`

```python
orders.duplicated().sum()                                  # kitni fully-duplicate rows hain
order_reviews.drop_duplicates(subset="order_id", keep="last")  # logical duplicates handle karna
```

**Do tarah ke duplicates (important distinction):**

| Type | Matlab | Detect karne ka tarika | Is project mein example |
|---|---|---|---|
| **Exact duplicate** | Poori row hi repeat ho rahi hai | `.duplicated().sum()` | `geolocation` — 261,831 rows |
| **Logical duplicate** | Same "key" (jaise `order_id`) multiple baar, values alag ho sakte hain | `.duplicated(subset=["key"])` | `order_reviews` — 551 orders ki 2 review-rows |

**My project mein (order_reviews):**
```python
order_reviews = (
    order_reviews.sort_values("review_answer_timestamp")
    .drop_duplicates(subset="order_id", keep="last")
    .reset_index(drop=True)
)
```
`keep="last"` = jab duplicate mile, **sabse latest** wali row rakho (pehle sort kiya isliye
"last" = "sabse recent").

## 8. `.astype()` and `.str` methods

```python
customers["customer_zip_code_prefix"] = customers["customer_zip_code_prefix"].astype(str).str.zfill(5)
```
- `.astype(str)` — number ko text mein convert karta hai.
- `.str.zfill(5)` — text ko 5 characters tak left-side `0` se pad karta hai
  (`"1310"` → `"01310"`).

## 9. Date/Time — `pd.to_datetime()`

```python
orders["order_purchase_timestamp"] = pd.to_datetime(
    orders["order_purchase_timestamp"], errors="coerce"
)
```
- Text column ko real `datetime` type mein convert karta hai.
- `errors="coerce"` — agar koi value parse na ho paaye, crash karne ke bajaye `NaT`
  (Not-a-Time, datetime ka null) bana deta hai.
- Uske baad date-math possible hoti hai: `(date2 - date1).dt.total_seconds() / 86400` (days mein
  convert karna).

## 10. `.merge()` — Pandas ka JOIN

```python
products = products.merge(category_translation, on="product_category_name", how="left")
```

| Parameter | Matlab |
|---|---|
| `on="..."` | Kaunsa common column match karna hai |
| `how="left"` | LEFT JOIN jaisa — left table ki saari rows rakho, right se match na ho toh NaN |
| `how="inner"` | INNER JOIN jaisa — sirf matching rows |

> Poora JOIN-type concept: [04_DATABASE_AND_DATA_MODEL.md](04_DATABASE_AND_DATA_MODEL.md).

## 11. `.groupby()` + `.agg()`

```python
category_revenue = (
    order_items.groupby("product_category_name_english", as_index=False)
    .agg(revenue=("item_revenue", "sum"), orders_count=("order_id", "nunique"))
)
```

- `.groupby("column")` — SQL ke `GROUP BY` jaisा.
- `.agg(new_col=("source_col", "function"))` — ek saath **multiple named aggregations**.
- `as_index=False` — group-column ko normal column rakhta hai (index nahi banata) — result
  ko dobara table jaisा treat karna aasan ho jaata hai.

**My project mein (geolocation aggregation):**
```python
geolocation_agg = (
    geolocation.groupby("geolocation_zip_code_prefix")
    .agg(
        geolocation_lat=("geolocation_lat", "mean"),
        geolocation_lng=("geolocation_lng", "mean"),
        geolocation_city=("geolocation_city", lambda s: s.mode().iat[0]),
    )
    .reset_index()
)
```

## 12. `.value_counts()`

```python
orders["order_status"].value_counts()
```
Har unique value ka count deta hai, descending order mein — categorical column ki "quick
distribution" dekhne ke liye sabse fast tarika.

## 13. Creating New Columns

```python
orders["delivery_days"] = (
    orders["order_delivered_customer_date"] - orders["order_purchase_timestamp"]
).dt.total_seconds() / 86400
```

## 14. Method Chaining (`.assign()`, multi-line pipelines)

```python
order_revenue = (
    order_items.merge(orders[["order_id", "order_status", "order_purchase_timestamp"]], on="order_id")
    .query("order_status == 'delivered'")
    .assign(item_revenue=lambda d: d["price"] + d["freight_value"])
    .groupby("order_id", as_index=False)
    .agg(order_total=("item_revenue", "sum"))
)
```

- **Kyun yeh style?** Har step ek naya intermediate variable banane ke bajaye, poora
  transformation pipeline ek hi readable block mein dikh jaata hai.
- `.assign(new_col=lambda d: ...)` — ek naya column banata hai bina original DataFrame ko
  directly modify kiye; `lambda d: ...` us column ko **current (pehle se transformed)**
  DataFrame ke reference se compute karta hai.
- `.query("condition")` — `df[df["col"] == "value"]` ka ek chhota/readable alternative, string
  ke form mein condition likh sakte ho.

---

## Full Function Reference Table (quick lookup)

| Function | Syntax | Project usage |
|---|---|---|
| `read_csv` | `pd.read_csv(path)` | Har raw CSV load karna |
| `.dtypes` | `df.dtypes` | Inspection |
| `.isnull().sum()` | `df.isnull().sum()` | Inspection |
| `.duplicated().sum()` | `df.duplicated().sum()` | Inspection |
| `to_datetime` | `pd.to_datetime(col, errors="coerce")` | Date columns clean karna |
| `.fillna` | `df["c"].fillna("unknown")` | Category nulls fill karna |
| `.dropna(subset=)` | `df.dropna(subset=["c1","c2"])` | Products dimension-missing rows |
| `.drop_duplicates` | `df.drop_duplicates(subset="k", keep="last")` | Review duplicates |
| `.merge` | `df1.merge(df2, on="k", how="left")` | Category translation join |
| `.groupby().agg()` | `df.groupby("c").agg(x=("y","sum"))` | Category/state summaries |
| `.value_counts` | `df["c"].value_counts()` | Distribution checks |
| `.sort_values` | `df.sort_values("c", ascending=False)` | Ranking |

---

## INTERVIEW

**Q: "Pandas SQL se better hai ya worse?"**
> Dono alag purpose ke liye best hain — competing nahi, **complementary**. SQL structured
> business-question answers (fast, precise) ke liye best; Pandas exploration/visualization/
> complex-multi-step-cleaning ke liye best.

**Q: "`.merge()` aur SQL `JOIN` mein similarity kya hai?"**
> Dono ek common column ke basis par do tables/DataFrames ko jodते hain — `.merge(how="left")`
> SQL `LEFT JOIN` jaisा hi behave karta hai.

**Q: "DataFrame modify karte waqt kya dhyan rakhna chahiye?"**
> Filter/slice karne ke baad agar original ko galti se overwrite na karna ho, `.copy()` use
> karo — warna `SettingWithCopyWarning` jaise issues aa sakte hain.

---

## What I should remember

- DataFrame = poori table; Series = ek column.
- `.info()`/`.describe()`/`.isnull().sum()` = inspection trio, cleaning se pehle.
- `.dropna(subset=)` > `.dropna()` bina subset ke — hamesha specific rakho.
- `.merge()` = Pandas ka JOIN; `how="left"` data ko silently khone se bachata hai.
- `.groupby().agg()` = SQL GROUP BY ka Pandas equivalent, is project mein sabse zyada use hua.
- Method chaining = readable, step-by-step transformation pipelines (project ki Section 9
  charts data-prep mein extensively use hui).
