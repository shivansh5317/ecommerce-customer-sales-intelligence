# 15 — Power BI From Zero

> Assume tumne Power BI **kabhi khola bhi nahi hai.** Yeh file har basic concept explain karti
> hai. Agla file ([16](16_POWER_BI_IN_MY_PROJECT.md)) dikhaएga yeh sab humare project mein
> exactly kaise use hua.

---

## 1. What is Power BI, and why do analysts use it?

**Power BI** Microsoft ka ek **Business Intelligence (BI) tool** hai — isse tum data ko import
karke, usse relationships se jodkar, aur interactive charts/dashboards bana kar business users
ke saath **visually communicate** kar sakte ho.

**Kyun use karte hain (SQL/Excel ke hote hue bhi):**
- SQL results **static** hote hain (ek baar query chalाई, ek result mila). Power BI
  **interactive** hai — user khud filter/slice kar sakta hai bina naya query likhe.
- Excel mein bahut sara data handle karna aur relationships manage karna mushkil ho jaata hai;
  Power BI isे professionally, scalably karta hai.
- Non-technical stakeholders (managers) SQL nahi jaanते — ek visual dashboard unke liye
  seedha "consumable" hai.

## 2. Core Vocabulary

| Term | Simple Meaning |
|---|---|
| **Power BI Desktop** | Windows application jahan tum dashboard **design/build** karte ho (free) |
| **Dataset** | Data jo tumने Power BI mein import kiya (CSVs, databases, etc.) |
| **Data model** | Tables + unke beech relationships — poora "structure" jispar dashboard chalta hai |
| **Relationship** | Do tables ke beech ek connection (jaise SQL ka JOIN, lekin ek baar set karke reusable) |
| **Report** | Ek ya zyada "pages" jinme visuals hote hain |
| **Dashboard** | (Power BI Service mein) Multiple reports se pinned visuals ka ek single-screen summary — Desktop mein hum usually "Report" banate hain jisme multiple pages hote hain |
| **Visual** | Ek individual chart/card/table (jaise ek bar chart) |
| **Slicer** | Ek interactive filter jo user directly report par click kar sakta hai (jaise date-range ya category chuनना) |
| **Filter** | Data ko restrict karna — slicer se, ya "Filters" pane se |

> 📌 **"Dashboard" vs "Report" (interview-relevant nuance):** Strictly Power BI terminology mein,
> jo tum Desktop mein banate ho usе **"Report"** kehte hain (multi-page). "Dashboard" technically
> Power BI **Service** (cloud) ka ek feature hai (single-page pinned-visuals summary). Colloquially
> log dono ko "dashboard" bol dete hain — is project mein bhi hum "3-page dashboard" bolते hain
> (matlab technically ek 3-page Report), jo bilkul normal/common usage hai.

## 3. Building a Data Model — key steps

1. **Get Data** → CSV/Excel/database se data import karo.
2. **Power Query Editor** mein basic cleaning kar sakte ho (column types fix karna, rename,
   etc.) — lekin agar cleaning already ho chuki hai (jaisा is project mein Python se hua), yeh
   step minimal hota hai.
3. **Model view** mein relationships banaओ (tables ke beech lines khींचकर, ya auto-detect hone
   dो).
4. Calculated Columns aur Measures add karo (dekho section 5).
5. Report pages par visuals daalo.

## 4. Calculated Column vs Measure (bahut common interview/practical confusion)

| | Calculated Column | Measure |
|---|---|---|
| **Kab compute hota hai** | Data-load/refresh ke time, **row-by-row**, result table mein "stored" ho jaata hai | Query/visual render hone ke time, **on-the-fly** |
| **Storage** | Extra space leta hai | Koi extra storage nahi |
| **Kab use karo** | Jab result **row-level** hona chahiye | Jab result **aggregation** hai jo filters ke saath dynamically change ho |
| **Example** | "Is order late thi ya nahi" (har row ka apna fixed answer) | "Total Revenue" (jo state/date filter ke hisab se badalta hai) |

**Simple rule of thumb:** Agar answer "har row ka apna hai, filter se nahi badalta" →
Calculated Column. Agar answer "ek number hai jo currently-selected filters par depend karta
hai" → Measure.

## 5. Basic DAX (DAX = Data Analysis eXpressions — Power BI ki formula language)

| Function | Kya karta hai | Syntax |
|---|---|---|
| `SUM(column)` | Column ke saare values jodta hai | `SUM(order_items[price])` |
| `AVERAGE(column)` | Average nikalta hai | `AVERAGE(orders[Delivery Days])` |
| `DISTINCTCOUNT(column)` | Unique values ginta hai (SQL ke `COUNT(DISTINCT)` jaisa) | `DISTINCTCOUNT(customers[customer_unique_id])` |
| `CALCULATE(expr, filter)` | Ek expression ko **naye filter-context** ke saath evaluate karta hai — DAX ka sabse powerful function | `CALCULATE(SUM(x), condition)` |
| `DIVIDE(num, denom)` | Safe division — agar denom `0` ho, crash nahi, `BLANK()` return karta hai | `DIVIDE([Total Revenue], [Total Orders])` |

**`CALCULATE()` deep-dive (sabse important DAX function):**
```dax
Total Revenue =
CALCULATE(
    SUM(order_items[price]) + SUM(order_items[freight_value]),
    orders[order_status] = "delivered"
)
```
`CALCULATE` yahan "is expression (`SUM(price)+SUM(freight)`) ko sirf `delivered` orders tak
restrict karo" bolta hai. Filter khud `orders` table par hai, lekin relationship ki wajah se
yeh automatically `order_items` tak "flow" kar jaata hai — yehi CALCULATE ka core superpower hai.

**`DIVIDE()` kyun better hai normal `/` se:** Agar denominator `0` ho (koi orders hi na hon
current filter mein), `DIVIDE()` crash/error ke bajaye automatically `BLANK()` (khaali) return
karta hai. **Best practice** — har division measure mein `DIVIDE()` use karo, `/` nahi.

## 6. Visual Types & When to Use Them

| Visual | Kab use karo |
|---|---|
| **Card** | Single, high-level KPI number |
| **Line chart** | Trend over time |
| **Bar chart (horizontal)** | Ranking, especially jab labels lambe hon |
| **Donut/Pie chart** | Sirf 2-3 category proportion |
| **Table** | Jab multiple specific values ek saath dikhane hon |
| **Slicer** | User-controlled filtering |

## 7. Formatting & Design Basics

- Ek consistent color-palette use karo (poore report mein).
- Max ~6-7 visuals per page — overload mat karo.
- "Top N" filters use karo rankings ke liye (kabhi 27 states/70 categories ek saath mat dikhaओ).
- Page-level titles add karo.

---

## INTERVIEW

**Q: "Power BI kya hai, ek line mein?"**
> Microsoft ka BI tool jisse data ko import/model/visualize karke interactive dashboards bana
> sakte hain.

**Q: "Calculated Column aur Measure mein fark?"**
> Section 4 ka table use karo — row-level+stored vs aggregate+on-the-fly.

**Q: "CALCULATE() kya karta hai?"**
> Ek expression ko naye filter-context ke saath evaluate karta hai — DAX ka sabse
> powerful/core function.

**Q: "DIVIDE() kyun use karte ho, `/` kyun nahi?"**
> Divide-by-zero ko safely `BLANK()` handle karta hai, crash nahi hota — best practice.

---

## What I should remember

- Power BI = import data → model relationships → add columns/measures → build visual pages.
- Calculated Column = row-level, stored. Measure = aggregate, on-the-fly.
- `CALCULATE()` = sabse powerful DAX function (filter-context change karta hai).
- `DIVIDE()` > `/` hamesha jab bhi division ho.
- Agla file: [16_POWER_BI_IN_MY_PROJECT.md](16_POWER_BI_IN_MY_PROJECT.md) — yehi concepts,
  actual project dashboard design mein.
