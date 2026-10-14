# 20 — General Data Analyst Interview Prep

> Ab hum project se **aage** jaate hain — entry-level Data Analyst interviews mein generally
> kya poocha jaata hai, chahe wo tumhare specific project se related ho ya na ho.

---

## SQL

| Priority | Topics |
|---|---|
| 🔴 Must know | SELECT/WHERE/JOIN/GROUP BY/HAVING/ORDER BY, aggregate functions, CASE WHEN |
| 🟡 Good to know | Subqueries, CTEs, basic window functions (`RANK`, `NTILE`, `ROW_NUMBER`) |
| 🟢 Optional | Advanced window functions (`LAG`/`LEAD`), stored procedures, query-optimization internals |

## Python

| Priority | Topics |
|---|---|
| 🔴 Must know | Variables, lists/dicts, loops, functions, Pandas basics (DataFrame, filtering, groupby) |
| 🟡 Good to know | `.merge()`, `.apply()`, method chaining, basic Matplotlib/Seaborn |
| 🟢 Optional | OOP/classes, decorators, async programming (not typically DA-relevant) |

## Excel

> ⚠️ **Honest note:** Is project mein Excel **use nahi hua** (Pandas ne uski jagah li) — lekin
> Excel entry-level DA interviews mein bahut common hai, isliye general awareness zaroori hai.

| Priority | Topics |
|---|---|
| 🔴 Must know | VLOOKUP/XLOOKUP, Pivot Tables, basic formulas (SUM/AVERAGE/IF/COUNTIF), sorting/filtering |
| 🟡 Good to know | INDEX-MATCH, conditional formatting, basic charts |
| 🟢 Optional | VBA/Macros, Power Query in Excel |

> **Agar poocha jaaye "Excel kyun use nahi kiya":** "Is project ke data-scale (~100k+ rows,
> multi-table relationships) ke liye Pandas/SQL zyada robust aur reproducible the — lekin
> Excel ke core concepts (VLOOKUP≈JOIN, Pivot Table≈GROUP BY) main samajhta hoon, wahi logic
> hai bas tool alag hai."

## Power BI

| Priority | Topics |
|---|---|
| 🔴 Must know | Data model/relationships, Calculated Column vs Measure, basic DAX (SUM/AVERAGE/CALCULATE/DIVIDE) |
| 🟡 Good to know | Visual-selection reasoning, slicers, Top-N filters |
| 🟢 Optional | Advanced DAX (time-intelligence, `ALL`/`FILTER` patterns), Power BI Service/publishing |

## Statistics

| Priority | Topics |
|---|---|
| 🔴 Must know | Mean/median/mode, percentages, correlation vs causation |
| 🟡 Good to know | Standard deviation/variance, percentiles/quartiles, distribution shapes |
| 🟢 Optional | Hypothesis testing, p-values, confidence intervals |

## Data Cleaning

| Priority | Topics |
|---|---|
| 🔴 Must know | Missing-value strategies (drop/fill/leave), duplicate types, why data-types matter |
| 🟡 Good to know | Outlier handling judgment, category-inconsistency fixing |

## EDA / Data Visualization

| Priority | Topics |
|---|---|
| 🔴 Must know | Chart-type selection (categorical→bar, continuous→histogram, trend→line) |
| 🟡 Good to know | Log-scale usage, distribution-shape interpretation |

## KPIs / Business Analytics

| Priority | Topics |
|---|---|
| 🔴 Must know | Metric vs KPI, revenue/AOV/repeat-rate definitions, Observation→Insight→Action framing |
| 🟡 Good to know | Segmentation frameworks (RFM), scoping decisions (why filter certain data) |

---

## Frequently-Asked GENERAL (non-project) Questions

**Q: "SQL aur NoSQL mein fark?"**
> SQL = structured, relational (tables/rows/columns, fixed schema). NoSQL = flexible schema
> (documents/key-value/graph) — jab data ka structure highly variable ho ya massive-scale
> horizontal scaling chahiye ho. Is project mein SQL (SQLite) use hua kyunki data naturally
> relational hai (fixed columns, clear relationships).

**Q: "Ek Data Analyst ke liye sabse important soft-skill kya hai?"**
> Business-communication — technical finding ko ek non-technical stakeholder ke liye
> **simple, actionable** language mein translate karna (dekho file 17 Observation→
> Interpretation→Implication framing).

**Q: "Tumhe kaise pata chalega ki tumhara analysis 'sahi' hai?"**
> Cross-verification (jaise is project mein revenue do sources se verify kiya — 0.017% diff),
> sample-size awareness (`HAVING count >= threshold`), aur logic ko manually trace karna
> (jaise RFM scoring bug jo verify karke pakड़ा gaya).

**Q: "Excel/SQL/Python/Power BI mein se agar sirf ek seekhna hota, kaunsa?"**
> SQL — kyunki data kahin bhi ho (koi bhi company), data-access/querying ek universal, most
> foundational skill hai. Baaki tools SQL ke upar build hote hain.

---

## What I should remember

- General DA interview 6 areas cover karte hain: SQL, Python, Excel, Power BI, Statistics,
  Business-thinking.
- Excel is project mein use nahi hua — honest raho, lekin general Excel-concepts (VLOOKUP,
  Pivot Table) ka mapping SQL/Pandas equivalents se pata hona chahiye.
- Priority: 🔴 Must know topics ko sabse zyada practice karo — yeh har entry-level interview
  mein aayenge.
