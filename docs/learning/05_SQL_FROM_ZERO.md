# 05 — SQL From Zero

> Yeh file SQL **bilkul shuru se** sikhati hai — generic, chhote examples ke saath (ek imaginary
> `employees` table use karenge jahan project-specific example zaroori nahi hai). Har concept
> ke end mein batayenge yeh humare project mein kahan use hota hai. **Real project queries, full
> breakdown ke saath,** agli file mein hain:
> [06_SQL_USED_IN_MY_PROJECT.md](06_SQL_USED_IN_MY_PROJECT.md).

**SQL kya hai (recap):** Structured Query Language — database se data nikalne/filter
karne/aggregate karne ki language. Yeh "declarative" hai — tum batate ho **kya** chahiye, "kaise
nikalna hai" nahi (jaisa Python/Java jaisi general-purpose languages mein karna padta hai).

Example table jo hum poori file mein use karenge:

```
employees
+----+----------+------------+--------+-------------+
| id | name     | department | salary | join_date   |
+----+----------+------------+--------+-------------+
| 1  | Asha     | Sales      | 45000  | 2022-01-15  |
| 2  | Ravi     | Sales      | 52000  | 2021-06-01  |
| 3  | Priya    | Tech       | 75000  | 2023-03-10  |
| 4  | Karan    | Tech       | 68000  | 2020-11-20  |
| 5  | Meena    | HR         | 40000  | 2023-07-01  |
```

---

## 1. `SELECT` / `FROM`

- **Meaning:** `SELECT` batata hai **kaunse columns** chahiye. `FROM` batata hai **kis table**
  se.
- **Syntax:** `SELECT column1, column2 FROM table_name;`
- **Example:**
  ```sql
  SELECT name, salary FROM employees;
  ```
- **Common mistake:** `SELECT *` (sab columns) production queries mein overuse karna — jab
  sirf 2 columns chahiye ho, sab mangwana slow aur unclear hota hai.
- **Why analysts use it:** Har SQL query ka foundation hai — bina iske kuch nahi ho sakta.
- **My project mein:** Har single query `SELECT` se shuru hoti hai (`sql/01` se `sql/06` tak).
- **Interview question:** *"`SELECT *` kab avoid karna chahiye?"* → Jab tumhe pata hai exactly
  kaunse columns chahiye — specific columns likhna query ko readable aur (bade tables par)
  thoda fast banata hai.

## 2. `WHERE`

- **Meaning:** Rows ko **condition ke basis par filter** karta hai — `GROUP BY` se **pehle**
  chalta hai, raw rows par.
- **Syntax:** `SELECT ... FROM ... WHERE condition;`
- **Example:**
  ```sql
  SELECT name, salary FROM employees WHERE department = 'Tech';
  ```
- **Common mistake:** `WHERE` mein aggregate function use karne ki koshish karna (jaise
  `WHERE COUNT(*) > 1`) — yeh error dega, iske liye `HAVING` chahiye (concept #9).
- **Why analysts use it:** Bina filtering ke, tum poori table par kaam kar rahe ho jab sirf
  ek subset chahiye tha.
- **My project mein:** `WHERE o.order_status = 'delivered'` — poore project mein sabse zyada
  repeat hone wala filter (revenue/delivery/satisfaction sirf delivered orders ke liye).
- **Interview question:** *"WHERE aur HAVING mein fark?"* → Poora answer file 06/21 mein, lekin
  short version: WHERE = row-level filter (before grouping), HAVING = group-level filter
  (after grouping).

## 3. `DISTINCT`

- **Meaning:** Result se **duplicate values hataata hai** — sirf unique values dikhata hai.
- **Syntax:** `SELECT DISTINCT column FROM table;`
- **Example:**
  ```sql
  SELECT DISTINCT department FROM employees;
  -- Result: Sales, Tech, HR
  ```
- **Common mistake:** `DISTINCT` ko `GROUP BY` ke replacement ki tarah use karna jab aggregate
  bhi chahiye ho — `DISTINCT` sirf unique rows/values deta hai, calculation nahi karta.
- **Why analysts use it:** "Kitne unique X hain" jaise sawal ke liye zaroori (`COUNT(DISTINCT ...)`
  ke saath aur bhi powerful ho jaata hai).
- **My project mein:** `COUNT(DISTINCT customer_unique_id)` — unique customers ginne ke liye
  (`order_items` jaisi line-item table mein `COUNT(DISTINCT order_id)` bhi zaroori tha, warna
  order count galat/zyada aata).
- **Interview question:** *"`COUNT(DISTINCT column)` normal `COUNT(column)` se kaise alag hai?"*
  → `COUNT(column)` har non-null value ginta hai (repeats sahit); `COUNT(DISTINCT column)` sirf
  unique values ginta hai.

## 4. `ORDER BY` / `LIMIT`

- **Meaning:** `ORDER BY` result ko **sort** karta hai (ascending `ASC` default, ya `DESC`).
  `LIMIT` sirf **top-N rows** dikhata hai.
- **Syntax:**
  ```sql
  SELECT name, salary FROM employees ORDER BY salary DESC LIMIT 3;
  ```
- **Example result:** Priya (75000), Karan (68000), Ravi (52000) — top 3 highest-paid.
- **Common mistake:** `LIMIT` lagane se pehle `ORDER BY` bhoolna — bina order ke "top N" ka
  koi guaranteed meaning nahi hota (database kisi bhi order mein rows de sakta hai).
- **Why analysts use it:** "Top 10 categories," "Top 5 customers" jaise ranking-based business
  sawal ke liye essential.
- **My project mein:** Har "Top N" query (`ORDER BY revenue DESC LIMIT 10` — top categories, top
  customers, top products, sab yahi pattern).
- **Interview question:** *"LIMIT bina ORDER BY ke use karoge toh kya hoga?"* → Result milega,
  lekin "top N" ka koi reliable meaning nahi hoga — random/insertion-order rows aa sakti hain.

## 5. Aggregate Functions — `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`

- **Meaning:** Multiple rows ko **ek single number** mein convert karte hain.
- **Syntax / examples:**
  ```sql
  SELECT COUNT(*) FROM employees;               -- kitni rows hain
  SELECT SUM(salary) FROM employees;             -- total salary
  SELECT AVG(salary) FROM employees;             -- average salary
  SELECT MIN(salary), MAX(salary) FROM employees; -- range
  ```
- **Common mistake:** `COUNT(*)` aur `COUNT(column)` ko same samajhna — `COUNT(*)` saari rows
  ginta hai; `COUNT(column)` sirf non-null rows.
- **Why analysts use it:** Har business metric (revenue, order count, average value) ek
  aggregate function se hi nikalta hai.
- **My project mein:** `SUM(price + freight_value)` = revenue; `COUNT(DISTINCT order_id)` =
  order count; `AVG(review_score)` = satisfaction.
- **Interview question:** *"SUM() aur COUNT() mein fark?"* → `SUM` values add karta hai,
  `COUNT` rows ginta hai — dono alag purpose.

## 6. `GROUP BY`

- **Meaning:** Rows ko kisi column ke value ke basis par **groups** mein baantta hai, phir har
  group par ek aggregate function lagate hain.
- **Syntax:**
  ```sql
  SELECT department, AVG(salary) AS avg_salary
  FROM employees
  GROUP BY department;
  ```
- **Example result:** Sales → 48,500 · Tech → 71,500 · HR → 40,000.
- **Common mistake:** `SELECT` mein ek non-aggregated column daalna jo `GROUP BY` mein nahi hai
  (jaise `SELECT name, department, AVG(salary) ... GROUP BY department` — `name` yahan ambiguous
  hai, kaunse employee ka naam dikhaye ek group ke liye?).
- **Why analysts use it:** "Category-wise," "state-wise," "month-wise" summary — yeh **sabse
  zyada use hone wala** SQL concept hai Data Analytics mein.
- **My project mein:** Har category/state/month/customer-wise summary (`GROUP BY category`,
  `GROUP BY order_month`, `GROUP BY customer_unique_id`).
- **Interview question:** *"GROUP BY ke bina SUM() likho toh kya hoga?"* → Poori table ka ek
  hi total aayega (koi grouping nahi, saari rows ek "group" ban jaati hain).

## 7. `HAVING`

- **Meaning:** `GROUP BY` ke **result** (aggregated groups) ko filter karta hai — `WHERE` se
  after aata hai logically.
- **Syntax:**
  ```sql
  SELECT department, COUNT(*) AS emp_count
  FROM employees
  GROUP BY department
  HAVING COUNT(*) >= 2;
  ```
- **Example result:** Sales (2), Tech (2) dikhenge; HR (1) filter ho jayega.
- **Common mistake:** `WHERE COUNT(*) >= 2` likhna — yeh **error** dega, kyunki `WHERE` execute
  hone tak `COUNT(*)` compute hi nahi hua hota.
- **Why analysts use it:** Sirf "statistically meaningful" groups dikhane ke liye (jaise "kam se
  kam 100 orders wali categories hi dikhao" — chhote sample ka average unreliable hota hai).
- **My project mein:** `HAVING orders_count >= 100` (`03_product_analysis.sql`), `HAVING
  reviews_count >= 30` (rating reliability ke liye).
- **Interview question:** *"WHERE aur HAVING ek hi query mein use kar sakte ho?"* → Haan —
  `WHERE` pehle raw rows filter karega, phir `GROUP BY` chalega, phir `HAVING` grouped result
  filter karega. Order: `WHERE` → `GROUP BY` → `HAVING` → `ORDER BY`.

## 8. `CASE WHEN`

- **Meaning:** SQL ka **if-else** — condition ke basis par ek naya value/column banata hai.
- **Syntax:**
  ```sql
  SELECT name, salary,
      CASE
          WHEN salary >= 60000 THEN 'High'
          WHEN salary >= 45000 THEN 'Medium'
          ELSE 'Low'
      END AS salary_band
  FROM employees;
  ```
- **Common mistake:** Conditions ka order galat rakhna — `CASE WHEN` **top-se-neeche** check
  karta hai aur **pehla match** use karta hai, isliye zyada specific/restrictive conditions
  pehle likhni chahiye.
- **Why analysts use it:** Buckets/labels/segments banane ke liye (jaise "High/Medium/Low",
  "On Time/Late").
- **My project mein:** Delivery status (`on_time`/`late`), frequency buckets
  (`1 order`/`2 orders`/`3-5`/`6+`), aur poori RFM segment logic (`High Value`/`Loyal`/`At
  Risk`/`Recent`/`Low Engagement`) — dekho file 06 aur 14.
- **Interview question:** *"CASE WHEN + SUM() ka combination kab use karte ho?"* → Jab ek hi
  query mein multiple conditional counts chahiye (e.g. `SUM(CASE WHEN status='delivered' THEN
  1 ELSE 0 END)` = ek "conditional COUNT" trick).

## 9. JOINs

(Poora concept + analogy [04_DATABASE_AND_DATA_MODEL.md](04_DATABASE_AND_DATA_MODEL.md) section
3 mein hai — yahan sirf SQL syntax recap.)

```sql
SELECT e.name, d.department_head
FROM employees e
INNER JOIN department_info d ON e.department = d.department_name;
```

- **My project mein:** Almost har query multi-table JOIN use karti hai — dekho file 06.
- **Interview question:** *"3 tables ek saath kaise join karoge?"* → Ek common key se shuru
  karo, phir ek-ek karke related tables jodo (`A JOIN B ON ... JOIN C ON ...`).

## 10. Subquery

- **Meaning:** Ek query ke **andar** ek aur query — andar wali pehle evaluate hoti hai, uska
  result bahar wali query "table" ki tarah use karti hai.
- **Syntax:**
  ```sql
  SELECT AVG(dept_total) FROM (
      SELECT department, SUM(salary) AS dept_total
      FROM employees
      GROUP BY department
  ) dept_totals;
  ```
- **Common mistake:** Directly `AVG(salary)` likhna jab actually "per-department average total"
  chahiye ho — yeh **grain mismatch** hai (dekho file 12 AOV example, bilkul yehi galti).
- **Why analysts use it:** Jab calculation **do steps** mein honi chahiye (pehle ek aggregate,
  phir uska aggregate).
- **My project mein:** AOV calculation — pehle per-order total (subquery), phir uska average
  (outer query). Dekho file 06 Query 1.3.
- **Interview question:** *"Subquery aur CTE mein fark?"* → Functionally same; CTE zyada
  readable hai jab multi-step logic ho.

## 11. CTE (`WITH ... AS`)

- **Meaning:** "Common Table Expression" — ek **named**, temporary result jo query ke start
  mein define karke aage use karte hain. Subquery ka hi readable version.
- **Syntax:**
  ```sql
  WITH dept_totals AS (
      SELECT department, SUM(salary) AS total_salary
      FROM employees
      GROUP BY department
  )
  SELECT AVG(total_salary) FROM dept_totals;
  ```
- **Common mistake:** Bahut lambi CTE chains ko bina labels/comments ke likhna — readability
  ka fayda tabhi milta hai jab organized ho.
- **Why analysts use it:** Multi-step logic ko top-se-neeche, readable rakhne ke liye (nested
  subqueries jaldi confusing ho jaati hain).
- **My project mein:** `customer_orders` CTE (repeat-customer analysis), poora RFM pipeline
  (`rfm_base` → `rfm_calc` → `rfm_scores` CTEs, file 06/14).
- **Interview question:** *"CTE subquery se performance mein fast hota hai?"* → Zaroori nahi —
  zyada engines mein dono similarly optimize hote hain; main benefit **readability** hai, raw
  performance nahi.

## 12. Window Functions (`NTILE`) — 🟢 optional but used meaningfully here

- **Meaning:** Aggregate jaisa hi calculation, lekin rows ko **squash nahi karta** — har row
  apni identity retain karti hai, bas ek extra calculated column milta hai.
- **Syntax:**
  ```sql
  SELECT name, salary,
      NTILE(4) OVER (ORDER BY salary ASC) AS salary_quartile
  FROM employees;
  ```
- **`NTILE(4)` kya karta hai:** Saari rows ko sorted order mein **4 barabar-size groups**
  (quartiles) mein baant deta hai.
- **Common mistake:** Window function har jagah use karna jab simple `GROUP BY` kaafi ho —
  window functions tab chahiye jab **row-level identity retain** karni ho.
- **Why analysts use it:** Ranking/bucketing bina rows ko squash kiye — RFM scoring jaisी
  use-cases ke liye perfect.
- **My project mein:** `NTILE(4) OVER (ORDER BY recency_days DESC)` aur
  `NTILE(4) OVER (ORDER BY monetary ASC)` — RFM ke Recency/Monetary scores. **Frequency ke
  liye NTILE nahi use kiya** — kyun, poori detail file 06/14 mein (ek genuinely interesting
  design decision).
- **Interview question:** *"NTILE ka koi limitation dekha project mein?"* → Haan — jab bahut
  saari rows ek hi value par "tied" hon (frequency=1 for ~97% customers), NTILE unhe
  arbitrarily split kar deta hai. Fix: fixed `CASE WHEN` buckets use kiye.

## 13. `VIEW` — 🟢 optional

- **Meaning:** Ek **saved query** jise "virtual table" ki tarah reuse kar sakte ho.
- **Syntax:**
  ```sql
  CREATE VIEW high_earners AS
  SELECT * FROM employees WHERE salary >= 60000;

  SELECT * FROM high_earners; -- ab isे normal table ki tarah query kar sakte ho
  ```
- **My project mein:** `customer_rfm` VIEW — poora RFM computation ek baar define hota hai,
  baaki queries aur Power BI export usе simply `SELECT * FROM customer_rfm` se use karte hain.
- **Interview question:** *"VIEW aur normal table mein fark?"* → VIEW data physically store
  nahi karta — har baar query chalne par underlying tables se fresh compute hota hai.

## 14. Date Functions (`strftime`, `julianday`) — SQLite-specific

- **Meaning:** Date/time par operations — format extract karna, do dates ka difference nikalna.
- **Syntax:**
  ```sql
  SELECT strftime('%Y-%m', order_purchase_timestamp) AS order_month FROM orders;
  SELECT julianday(delivered_date) - julianday(purchase_date) AS days_taken FROM orders;
  ```
- **My project mein:** `strftime('%Y-%m', ...)` monthly revenue trend ke liye;
  `julianday(...) - julianday(...)` delivery-days calculate karne ke liye.
- **Interview question:** *"Do dates ka difference SQL mein kaise nikalte ho?"* → Database
  ke hisab se function alag hota hai — SQLite mein `julianday()` subtract karo, MySQL mein
  `DATEDIFF()`, PostgreSQL mein directly `date2 - date1`.

---

## Query Execution Order (bahut common interview question)

SQL likhte waqt hum top-se-neeche likhte hain (`SELECT ... FROM ... WHERE ... GROUP BY ...
HAVING ... ORDER BY`), lekin database **isi order mein execute nahi karta**:

```
1. FROM       (kaunsi table[s])
2. WHERE      (raw rows filter)
3. GROUP BY   (groups banao)
4. HAVING     (grouped results filter)
5. SELECT     (columns choose karo)
6. ORDER BY   (sort karo)
7. LIMIT      (top-N)
```

> **Interview Tip:** Yeh order samajhna explain karta hai ki `WHERE` mein aggregate kyun nahi
> chal sakta (WHERE, GROUP BY se pehle chalta hai — usse pata hi nahi "group" ka result kya
> hoga) — lekin `HAVING` mein chalta hai (GROUP BY ke baad).

---

## What I should remember

- Order of learning: SELECT/WHERE → DISTINCT → ORDER BY/LIMIT → aggregates → GROUP BY →
  HAVING → CASE WHEN → JOINs → Subquery → CTE → Window functions.
- WHERE = row filter (before grouping). HAVING = group filter (after grouping).
- Aggregate + GROUP BY = SQL ka sabse powerful, sabse zyada use hone wala combo in DA.
- Logical execution order: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT.
- Agla step: [06_SQL_USED_IN_MY_PROJECT.md](06_SQL_USED_IN_MY_PROJECT.md) — yehi concepts,
  ab real project queries mein, line-by-line.
