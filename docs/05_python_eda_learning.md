# 05 — Python / Pandas EDA Learning Notes

> Yeh file `notebooks/01_eda.ipynb` ka companion hai — wahan **code + real charts** hain, yahan
> hum **pandas/matplotlib/seaborn concepts** ko explain kar rahe hain jo notebook mein use hue,
> taaki tumhe pata ho **kya likha, kyun likha, aur kaise kaam karta hai.**

## 1. Kyun Python/Pandas, jab SQL se bhi analysis ho sakta tha?

Dono complementary hain, competing nahi:
- **SQL** — structured questions ke liye best hai ("total revenue kitna," "top categories
  kaunsi") — database directly se fast, precise answers.
- **Python/Pandas** — **exploration, visualization, aur data cleaning** ke liye best hai — jahan
  humein data ko "dekhna" hai (charts), ya complex multi-step transformations karni hain jo SQL
  mein likhna mushkil/unreadable ho jaata.

Real DA jobs mein dono use hote hain — SQL "server-side" heavy-lifting ke liye, Python
"analyst-side" exploration/reporting ke liye.

## 2. Pandas concepts used (with where + why)

### `pd.read_csv()`
Har raw CSV file ko ek `DataFrame` (Excel-sheet jaisa table object, lekin code se control
karne wala) mein load karta hai. Used: Section 2 of the notebook, sabhi 9 files ke liye.

### `.dtypes`, `.isnull().sum()`, `.duplicated().sum()`
Data **inspect** karne ke 3 basic tools:
- `.dtypes` — har column ka data type (`int64`, `float64`, `object`=text, etc.) dikhata hai.
- `.isnull().sum()` — har column mein kitne missing (`NaN`) values hain, count karta hai.
- `.duplicated().sum()` — poori row exactly kitni baar repeat hui, count karta hai.

**Used:** Section 3 (Inspect Data) — cleaning shuru karne se pehle problems identify karne ke
liye.

### `pd.to_datetime(col, errors="coerce")`
Text column ko real `datetime` type mein convert karta hai. `errors="coerce"` — agar koi value
parse na ho paaye, crash karne ke bajaye use `NaT` (datetime ka "null") bana deta hai.
**Used:** Section 4.1, 4.3, 4.5 (date columns clean karte waqt).

### `.astype(str).str.zfill(5)`
`.astype(str)` — number ko text mein convert karta hai. `.str.zfill(5)` — text ko 5 characters
tak left-side `0` se pad karta hai (`"1310"` → `"01310"`). **Used:** zip code leading-zero fix
(Section 4.2, 4.7).

### `.merge()`
Pandas ka JOIN — do DataFrames ko ek common column ke basis par jodta hai (`on="..."`,
`how="left"/"inner"`). **Used:** `products.merge(category_translation, on="product_category_name",
how="left")` — SQL ke `LEFT JOIN` jaisa hi concept, bas pandas syntax mein.

### `.groupby().agg()`
SQL ke `GROUP BY` + aggregate functions ka pandas equivalent. `.agg()` mein multiple named
aggregations ek saath likh sakte ho (e.g. `mean lat`, `mode city`). **Used:** geolocation ko
"1 row per zip" banane ke liye (Section 4.7), aur EDA mein `category_revenue`,
`state_revenue` jaisi summaries banane ke liye.

### `.sort_values()` + `.drop_duplicates(subset=..., keep="last")`
Rows ko sort karke, ek column (`subset`) ke duplicate hone par sirf **last** wali row rakhta
hai. **Used:** `order_reviews` mein duplicate `order_id` handle karne ke liye — pehle latest
review upar laane ke liye sort kiya, phir duplicates hataye.

### `.dropna(subset=[...])`
Sirf specified columns mein null hone par row hataata hai (poori row mein kahin bhi null hone
par nahi — yeh important fark hai `.dropna()` (no args) se, jo bahut aggressive hota). **Used:**
Section 4.6, sirf 2 rows hataane ke liye jinke physical dimensions missing the.

### Method chaining (`.assign()`, multi-line `(...)`)
Section 9 ke charts mein `order_revenue`, `category_revenue` jaise variables banate waqt, humne
**method chaining** style use ki:
```python
result = (
    df.merge(...)
      .query(...)
      .assign(new_col=lambda d: ...)
      .groupby(...)
      .agg(...)
)
```
**Kyun yeh style?** Har step ek naya intermediate variable banane ke bajaye, poora transformation
pipeline ek hi readable block mein dikh jaata hai (top-se-neeche padho, samajh aa jaayega har
step kya kar raha hai). `.assign()` ek naya column banata hai bina original DataFrame ko directly
modify kiye. `lambda d: ...` us column ko current (pehle se transformed) DataFrame ke reference
se compute karta hai.

## 3. Visualization concepts used

| Chart type | Kab use karte hain | Is project mein kahan |
|---|---|---|
| **Bar chart** (`sns.barplot`) | Categorical data compare karna (categories/states/segments) | Category revenue, state revenue, order status, RFM segments |
| **Horizontal bar** | Jab category names lambe hon, ya ranking dikhani ho | Top-10 categories/states |
| **Histogram** (`sns.histplot`) | Continuous numeric data ki **shape/spread** dikhani ho | Price distribution, delivery-days distribution |
| **Line chart** (`plt.plot`) | Time-series / trend over time | Monthly revenue trend |
| **Log scale** (`log_scale=True`) | Jab data heavily right-skewed ho (kuch bahut bade outliers pura chart "squash" kar dete) | Price distribution |

**General principle jo humne follow ki:** Chart type **data ke type** se decide hota hai —
categorical → bar, continuous-single-variable → histogram, trend-over-time → line. Yeh ek
common interview-relevant judgment call hai ("kaunsa chart kab use karoge?").

## 4. Charts summary (full explanation har chart ke saath notebook mein hai)

1. Order Status Distribution — operational health check
2. Review Score Distribution — bimodal pattern discovery
3. Price Distribution (log scale) — pricing spread
4. Delivery Time Distribution — operations baseline + outlier tail
5. Monthly Revenue Trend — growth story + seasonality + data-cutoff caution
6. Top 10 Categories by Revenue
7. Top 10 Categories by Order Volume — volume vs revenue divergence insight
8. Top 10 States by Revenue — geographic concentration
9. **Delivery Performance vs Satisfaction** — strongest insight in the whole project (4.29★ vs 2.57★)
10. RFM Segment Distribution — segment sizes + value, ties into `docs/04`

## 5. Key learnings / interview angle

- **"SQL aur Pandas mein same cheez kyun dobara ki?"** → Nahi ki — SQL files "answer the business
  question" ke liye the (precise numbers), notebook "visualize + explore" ke liye hai (charts,
  patterns jo sirf numbers dekh kar nahi pakड़े jaate, jaise distribution ki shape).
- **"Tumne kaunsa chart kab use kiya, aur kyun?"** → Section 3 ka table use karo — data-type se
  chart-type map hota hai.
- **"Method chaining kyun use ki, step-by-step variables kyun nahi?"** → Readability aur "no
  intermediate clutter" — lekin dono valid approaches hain; agar debug karna ho, step-by-step
  temporarily easier hota hai (chain todh kar beech mein `print()`/`.head()` daal sakte ho).
- **"Log scale histogram kyun, normal nahi?"** → Jab data mein bahut bada range ho (₹0.85 se
  ₹6,735), normal-scale histogram sab kuch ek corner mein dikhata hai — log scale spread ko
  zyada meaningfully dikhata hai.
