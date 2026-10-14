# 22 — Python/Pandas Interview Prep

> Sirf DA-relevant Python — lists, dicts, loops, functions, Pandas. Yeh generic Software
> Engineering interview guide **nahi** hai.

---

## Conceptual Questions

**Q: "List aur Dictionary mein fark?"**
> List = ordered collection, index (position) se access karte ho (`list[0]`). Dictionary =
> key-value pairs, key se access karte ho (`dict["key"]`).

**Q: "DataFrame aur List-of-Dictionaries mein kya similarity/fark hai?"**
> Dono tabular-jaisa data represent kar sakte hain (list of dicts = list of rows), lekin
> DataFrame ke paas built-in vectorized operations, column-type-awareness, aur analysis
> functions (`.groupby()`, `.merge()`) hain jo list-of-dicts mein manually likhने padते.

**Q: "Mutable vs Immutable — list vs tuple example ke saath."**
> List **mutable** hai (change kar sakte ho — `list.append()`). Tuple **immutable** hai (ek baar
> banने ke baad change nahi kar sakte). DA context mein: column-names ki list agar accidentally
> kahin modify ho jaaye, bugs aa sakte hain — isliye kabhi-kabhi tuple safer hota hai fixed
> configs ke liye.

---

## Pandas — Coding Questions

### Q1. "Ek DataFrame diya hai `orders` (columns: order_id, customer_id, amount, status). Sirf
'completed' status wale orders filter karo."

```python
completed = orders[orders["status"] == "completed"]
```
- **Common mistake:** `orders["status"] = "completed"` likhна (single `=`) — yeh **assignment**
  hai, filter nahi! Hamesha `==` (comparison) use karo filter condition mein.

### Q2. "Har customer ka total spend nikalo."

```python
customer_spend = orders.groupby("customer_id", as_index=False)["amount"].sum()
```
- **Follow-up:** "Top 5 highest-spending customers?" →
  `customer_spend.sort_values("amount", ascending=False).head(5)`

### Q3. "Do DataFrames (`orders` aur `customers`) ko jodkar customer_name ke saath order details
dikhao."

```python
result = orders.merge(customers[["customer_id", "customer_name"]], on="customer_id", how="left")
```
- **Common mistake:** `how` parameter bhoolना (default `"inner"` hai) — agar kuch customers
  match na hon, unke orders silently gayab ho jaayenge.
- **Follow-up:** "Agar `customer_id` column ka naam dono tables mein alag ho (`cust_id` vs
  `customer_id`)?" → `left_on="cust_id", right_on="customer_id"` use karo.

### Q4. "Missing values kaise handle karoge is column mein?"

```python
df["category"].isnull().sum()          # kितने missing hain
df["category"] = df["category"].fillna("unknown")   # ya
df = df.dropna(subset=["category"])                   # context ke hisab se decide karo
```
- **Follow-up:** "Kab fillna, kab dropna?" → File 09/28 ka reasoning use karo — categorical +
  meaningful default → fillna; negligible count + critical numeric → dropna(subset=).

### Q5. "Duplicate rows kaise hataओge, sirf `order_id` ke basis par, latest wali rakhते hue?"

```python
df = df.sort_values("timestamp").drop_duplicates(subset="order_id", keep="last")
```
- **This is a direct project pattern** — `order_reviews` cleaning (file 08/09) mein exactly
  yehi use hua.

### Q6. "Ek column banao jo bataए order 'high_value' hai ya 'low_value' (price > 500 ke basis par)."

```python
import numpy as np
df["value_tier"] = np.where(df["price"] > 500, "high_value", "low_value")
```
- **Common mistake:** Yeh Python `if/else` se karne ki koshish karna row-by-row loop mein —
  bahut slow. `np.where()` ya `.apply()` (vectorized/semi-vectorized) use karo.
- **Follow-up:** "3+ categories ke liye?" → `np.select()` ya `pd.cut()` (agar numeric ranges
  hain) use karo.

### Q7. "`.apply()` kab use karte ho, kab nahi?"

> Jab koi built-in vectorized function (jaise `+`, `.sum()`, `np.where()`) available ho, use
> **prefer** karo — fast hai. `.apply()` tab use karo jab logic itна custom ho ki koi built-in
> function fit na ho (jaise ek complex multi-column custom rule) — lekin yeh dhीma hota hai
> bade data par.

---

## "Explain this code" Questions (project-style)

**Q: Yeh code kya karta hai?**
```python
geolocation_agg = (
    geolocation.groupby("geolocation_zip_code_prefix")
    .agg(
        geolocation_lat=("geolocation_lat", "mean"),
        geolocation_city=("geolocation_city", lambda s: s.mode().iat[0]),
    )
    .reset_index()
)
```
> "Har zip-code-prefix ke liye ek row banata hai — latitude ka average leता hai, aur city ka
> **sabse common (mode)** value leता hai. `lambda s: s.mode().iat[0]` ek chhota inline function
> hai jo `.mode()` (jo multiple values return kar sakta hai agar tie ho) mein se pehla value
> uthाता hai. `.reset_index()` zip-code ko wapas ek normal column banata hai (groupby ke baad
> yeh index ban jaata hai)."

---

## What I should remember

- Filter mein `==` na `=`, aur `subset=` `.dropna()`/`.drop_duplicates()` dono mein specify karo.
- `.merge(how=)` explicitly socho, default `"inner"` chupke se data drop kar sakta hai.
- Vectorized operations (`np.where`, direct column-math) > `for` loops > `.apply()` (jab avoidable ho).
- Yeh sab exact patterns is project mein use hue hain — apna khud ka code hi best practice
  reference hai revision ke liye.
