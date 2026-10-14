# 21 — SQL Interview Prep

> Beginner-to-intermediate SQL interview guide — conceptual + coding questions, EASY → MEDIUM →
> PROJECT-SPECIFIC. Format: Understand question → Approach (Hinglish) → SQL solution →
> Explain query → Common mistake → Follow-up.

---

## Conceptual Questions (rapid-fire, samjho na ki ratto)

1. **SELECT vs FROM order of execution?** → `FROM` pehle chalta hai (logically), `SELECT`
   baad mein — dekho file 05 "Query Execution Order."
2. **WHERE vs HAVING?** → WHERE = row-filter (before GROUP BY); HAVING = group-filter (after).
3. **INNER vs LEFT JOIN?** → INNER = sirf matches; LEFT = left table ki saari rows + matches
   (na milne par NULL).
4. **COUNT(*) vs COUNT(column) vs COUNT(DISTINCT column)?** → Saari rows vs non-null rows vs
   unique non-null values.
5. **Subquery vs CTE?** → Same kaam, CTE zyada readable multi-step ke liye.
6. **What is a Primary Key?** → Row ko uniquely identify karta hai, never null, never duplicate.
7. **What is a Window function?** → Aggregate jaisा calculation but rows ko squash nahi karta.
8. **DELETE vs TRUNCATE vs DROP?** → DELETE = rows hataata hai (condition ke saath, rollback-able);
   TRUNCATE = saari rows fast-delete (structure rakhta hai); DROP = poori table hi mita deta hai.

---

## EASY — Coding Problems

### E1. "Har category ka total revenue nikalo." (generic employees/products table assume karo)

- **Understand:** Ek GROUP BY + SUM chahiye.
- **Approach:** Category ke hisab se group karo, revenue sum karo.
- **SQL:**
  ```sql
  SELECT category, SUM(price) AS total_revenue
  FROM products
  GROUP BY category;
  ```
- **Common mistake:** `SELECT category, product_name, SUM(price)` likhна — `product_name`
  non-aggregated hai aur GROUP BY mein nahi, error/ambiguity.
- **Follow-up:** "Sirf top 5 categories chahiye, revenue ke hisab se?" → `ORDER BY
  total_revenue DESC LIMIT 5` add karo.

### E2. "Kitne distinct customers hain?"

- **SQL:** `SELECT COUNT(DISTINCT customer_id) FROM customers;`
- **Common mistake:** `COUNT(customer_id)` (bina DISTINCT) — agar table mein duplicates hain,
  galat (zyada) count aayega.
- **Follow-up:** (Project-specific twist) "Is dataset mein `customer_id` sahi column hai
   'unique customer' ke liye?" → Nahi, `customer_unique_id` chahiye (dekho file 03).

### E3. "Un customers ko dikhao jinhone kabhi order nahi kiya."

- **Understand:** Yeh ek "anti-join" pattern hai — LEFT JOIN + `WHERE right.key IS NULL`.
- **SQL:**
  ```sql
  SELECT c.customer_id
  FROM customers c
  LEFT JOIN orders o ON o.customer_id = c.customer_id
  WHERE o.order_id IS NULL;
  ```
- **Common mistake:** INNER JOIN use karna — yeh sirf un customers ko dikhाएga jinhone order
  kiya hai, ulta result.
- **Follow-up:** "Isko subquery se kaise likhoge?" →
  `WHERE customer_id NOT IN (SELECT customer_id FROM orders)`.

---

## MEDIUM — Coding Problems

### M1. "Har customer ka 2nd order kaunsa tha (order date ke hisab se)?"

- **Understand:** Yeh ranking/window-function problem hai.
- **Approach:** Har customer ke orders ko date ke hisab se number do (`ROW_NUMBER`), phir
  `= 2` filter karo.
- **SQL:**
  ```sql
  WITH ranked AS (
      SELECT
          customer_id, order_id, order_date,
          ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
      FROM orders
  )
  SELECT * FROM ranked WHERE rn = 2;
  ```
- **New concept — `PARTITION BY`:** Window function ko "har customer ke andar alag se" restart
  karne ke liye — bina isके, `ROW_NUMBER` poori table ko ek hi sequence maanega.
- **Common mistake:** `PARTITION BY` bhoolना — sabhi orders ko ek hi global ranking mil jaएगी.
- **Follow-up:** "Yeh is project mein kahan use ho sakta thा?" → RFM jaisा hi concept — `NTILE`
  bhi ek window function hai, bas bucketing ke liye, ranking ke liye nahi.

### M2. "Categories dikhao jinka average price company-wide average se zyada hai." (subquery/CTE)

- **SQL:**
  ```sql
  SELECT category, AVG(price) AS avg_price
  FROM products
  GROUP BY category
  HAVING AVG(price) > (SELECT AVG(price) FROM products);
  ```
- **New concept:** Scalar subquery ek fixed comparison-value deती hai (dekho file 06 Query 4.4
  ka pattern).
- **Common mistake:** `WHERE AVG(price) > ...` likhna — `WHERE` mein aggregate allowed nahi,
  `HAVING` chahiye.

### M3. "Monthly revenue growth % (previous month ke against) nikaलो." (project-adjacent)

- **Understand:** Isके liye "previous row ki value" chahiye — `LAG()` window function.
- **SQL:**
  ```sql
  WITH monthly AS (
      SELECT strftime('%Y-%m', order_date) AS month, SUM(price) AS revenue
      FROM orders GROUP BY month
  )
  SELECT month, revenue,
      revenue - LAG(revenue) OVER (ORDER BY month) AS change_from_prev_month
  FROM monthly;
  ```
- **New concept — `LAG()`:** Pichले row ki value is row mein la deता hai (bina self-join ke).
- **Note:** Is project mein `LAG`/`LEAD` **use nahi hue** (honest — sirf `NTILE` use hua),
  lekin yeh ek natural extension hota agar month-over-month % growth chahiye hota.

---

## PROJECT-SPECIFIC — (Poora breakdown [06_SQL_USED_IN_MY_PROJECT.md](06_SQL_USED_IN_MY_PROJECT.md) mein)

### P1. AOV Query (subquery)
Dekho file 06 Query 1.3 — grain-mismatch lesson.

### P2. RFM Segmentation (CTE + NTILE + CASE WHEN)
Dekho file 14 — poora scoring logic.

### P3. High-volume-low-revenue categories (HAVING)
Dekho file 06 Query 3.2 — sample-size-safety pattern.

### P4. Revenue concentration % (scalar subquery)
Dekho file 06 Query 4.4.

---

## Common SQL Interview Traps (memorize these)

| Trap | Correct Understanding |
|---|---|
| "WHERE ke andar COUNT(*) likh dena" | HAVING chahiye |
| "AVG(price) seedha AOV maan lena" | Grain-mismatch — pehle per-order total banao |
| "COUNT(*) aur COUNT(column) same hain" | COUNT(column) nulls skip karta hai |
| "GROUP BY ke bina non-aggregated column select karna" | Error/ambiguous result |
| "NTILE tied-data ke saath bhi fair hoga" | Nahi — arbitrary split hoga agar bahut rows tied hain |
| "INNER JOIN hamesha safe hai" | Data silently lost ho sakta hai agar unmatched rows chahiye thi |

---

## What I should remember

- Practice karne ka tarika: pehle **samझो** kya poocha ja raha hai (grain? aggregation-level?
  ranking?), phir SQL likho — seedha syntax yaad mat karo.
- EASY = single-table aggregates. MEDIUM = window functions/subqueries. PROJECT-SPECIFIC =
  apna khud ka context, deeply samझा hua.
- Sabse zyada-tested trap: WHERE-vs-HAVING, aur AOV grain-mismatch.
