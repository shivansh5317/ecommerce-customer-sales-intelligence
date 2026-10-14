# 23 — Power BI Interview Prep

> Fresher-level questions jo realistically poochे jaate hain — dashboard use karne se leke
> basic DAX aur design-thinking tak.

---

## Basics

**Q: "Power BI Desktop aur Power BI Service mein fark?"**
> Desktop = Windows app jahan tum report **design/build** karte ho (free). Service = cloud
> platform jahan tum published reports **share/view/collaborate** karte ho (kuch features
> license-based).

**Q: "Data loading ke liye kaunse sources support karta hai Power BI?"**
> CSV/Excel, databases (SQL Server, PostgreSQL, etc.), web/API sources, cloud services. Is
> project mein CSV (Text/CSV connector) use hone wala design hai.

**Q: "Power Query kya hai?"**
> Data import karte waqt ka ek "cleaning/shaping" editor — column-types fix karna, rename
> karna, filter karna, before data model mein load ho. Is project mein heavy cleaning already
> Python mein ho chuki hai, isliye Power Query ka role minimal hai.

## Relationships

**Q: "Relationship set karte waqt kya-kya decide karna padta hai?"**
> Cardinality (1:1, 1:many, many:many) aur cross-filter direction (single/both).

**Q: "1:1 relationship mein default cross-filter kya hota hai, aur 1:many mein?"**
> 1:1 → default "Both" (dono directions filter flow karते hain). 1:many → default sirf "one"
> se "many" taraf (single direction).

**Q: "Agar do fact tables (jaise orders aur payments) ko directly jodना ho?"**
> Directly mat jodो — inhe unke common dimension/parent table (jaise dono `order_id` se
> `orders` table se related hain) ke through indirectly jodो. Fact-to-fact direct relationships
> ambiguous/incorrect filtering create kar sakte hain.

## Filters & Slicers

**Q: "Filter aur Slicer mein fark?"**
> Slicer ek **visual** hai jo report par dikhता hai, user directly click/select karta hai.
> Filter (Filters pane) developer/user dono set kar sakte hain lekin utना "visually prominent"
> nahi hota — page/visual/report-level bhi ho sakta hai.

**Q: "'Top N' filter kaise lagate ho?"**
> Visual select karo → Filters pane → axis-field ko filter mein daalo → Filter type: Top N →
> N enter karo → value-field "By value" mein daalo. (Is project mein har ranking bar-chart par
> Top N=10 use hone wala design hai.)

## Visuals & Measures

**Q: "Card aur KPI visual mein fark?"**
> Card = single, static number. KPI visual = number + trend-indicator (target ke against
> up/down) — extra context deता hai.

**Q: "CALCULATE() ka ek real use-case do."**
> `Total Revenue` measure — `SUM(price+freight)` ko `order_status="delivered"` filter ke saath
> restrict karta hai, chahe `order_status` column khud kisी doosri table (`orders`) mein ho.

**Q: "DIVIDE() better kyun hai `/` se?"**
> Divide-by-zero ko `BLANK()` handle karta hai automatically, crash nahi hota.

## Dashboard Design / Business Storytelling

**Q: "Ek achha dashboard design karte waqt tum kya priorities rakhte ho?"**
> 1) Business-question-first (har visual ek specific sawal answer kare), 2) Consistent
> color/style, 3) Max ~6-7 visuals/page (overload mat karo), 4) Top-N filters rankings ke liye,
> 5) Slicers jahan interactivity genuinely useful ho.

**Q: "Agar ek manager ko sirf 10 second mein dashboard dekhна ho, kya priority dogे?"**
> KPI Cards sabse top/prominent jagah — sabse critical numbers (Revenue, Orders, AOV) ek nazar
> mein dikhne chahiye, detail-charts uske baad.

**Q: "Bahut saari categories/states ko ek chart mein kaise dikhaओge bina overwhelming kiye?"**
> "Top N" filter (jaise Top 10) use karo — poore 70+ categories ya 27 states ek saath kabhi
> mat dikhaओ.

---

## Project-Specific Power BI Questions (recap — full detail file 16)

**Q: "Tumhare dashboard mein kितne pages hain, aur har ek ka purpose kya hai?"**
> 3 — Executive Overview (high-level sales KPIs), Customer Insights (RFM-interactive), Product
> & Operations (category + delivery + ratings).

**Q: "`category_performance` table alag kyun rakhi, relationship kyun nahi banाई?"**
> 3-hop relationship chain (products→items→orders→reviews) ke liye bidirectional relationship
> chahiye hoती — beginner-model mein ambiguous results ka risk. Isliye Python mein precompute
> karke standalone table banाई.

**Q: "Dashboard actually Power BI Desktop mein bana hai?"**
> Honest raho: poora design/DAX/spec ready hai; `.pbix` build manual GUI step hai jo alag se
> hona hai (dekho file 16 ka honesty-note).

---

## What I should remember

- Power BI Desktop = build; Service = share/collaborate.
- Relationship cardinality + cross-filter-direction dono decide karne padते hain.
- CALCULATE() aur DIVIDE() = do sabse zyada poochे jaने wale DAX functions.
- Dashboard design = business-question-first, consistent, Top-N-filtered, not overloaded.
