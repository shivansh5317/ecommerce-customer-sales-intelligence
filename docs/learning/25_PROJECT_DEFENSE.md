# 25 — Project Defense

> Goal: **naturally answer karna seekhो, script yaad mat karo.** Har answer ke peeche ka
> "reasoning pattern" samझो, taaki interviewer koi bhi phrasing mein poochे, tum adapt kar sako.

---

## "Tell me about your project."

**Reasoning pattern:** Business-problem → Approach → Key-finding → (agar time ho) Limitation.
Poora pitch: [02_PROJECT_OVERVIEW.md](02_PROJECT_OVERVIEW.md) section 10.

## "Why did you choose this project?"

**Reasoning pattern:** Ek concrete, specific reason do — "real messy data practice," "sales +
customer + delivery + satisfaction sab ek dataset mein" (dekho file 19 A2). Avoid: "tutorial
mein tha."

## "Why did you choose this dataset?"

Real (anonymized, non-synthetic), rich (9 relational tables, real messiness), aur delivery/
review-score jaise fields deता hai jo delivery aur satisfaction analysis dono possible banate
hain (file 19 A2's alternative-dataset comparison, UCI Online Retail se).

## "What was your role?"

Solo project — dataset selection se Power BI design tak, sab khud kiya. Specific-decisions bolो
(RFM recency-bug fix, index-performance-fix) generic "maine sab kiya" ki jagah.

## "What challenges did you face?"

Do concrete, real examples (file 19 K1):
1. SQLite joins slow the (no default indexes) — fixed with explicit `CREATE INDEX`.
2. RFM recency-scoring direction bug — verify karke `DESC` fix kiya.

## "What did you learn?"

- Technical: SQL (JOINs se window-functions tak), Pandas cleaning patterns, Power BI data-modeling.
- Non-technical: **Grain-mismatch awareness** (AOV lesson), **correlation vs causation
  discipline**, aur "data ke component samझो conclusion nikalने se pehle" (Insight 8, freight
  artifact).

## "Why SQL?"

Structured business-questions ke liye fast/precise/readable — database engine bade data par
aggregate karne ke liye optimized hai.

## "Why Python?"

Exploration/visualization/complex-multi-step-cleaning ke liye — SQL "answer" deta hai, Python
"pattern/shape" dikhata hai.

## "Why Power BI?"

Non-technical stakeholders ke liye interactive, visual, self-serve dashboard — SQL/Python
output ko "consume karne layak" banata hai.

## "Why not Excel?"

Scale (~100k+ rows, multi-table relationships) ke liye Pandas/SQL zyada robust/reproducible/
version-controllable hain. Excel ke core-concepts (VLOOKUP≈JOIN, PivotTable≈GROUP BY) samझते ho,
lekin is scale/complexity ke liye behतर tool चुना.

## "Why did you use this metric (e.g. Revenue = price+freight)?"

Cross-verified against alternative source (`order_payments`) — 0.017% difference, phir
line-item-level granularity ke liye `order_items` ko chuna (file 09 section 8).

## "Why did you choose this chart (e.g. line chart for revenue trend)?"

Data-type se chart-type map hota hai — time-series → line chart (trend/direction turant dikhता
hai). (Poora rule: file 10 section 2.)

## "What was your most important finding?"

Insight 1 — on-time delivery 4.29★ vs late 2.57★ — sabse bada sample, sabse bada gap, sabse
directly-actionable.

## "What would you improve?"

Honest, specific list (README "Future Improvements," bhi file 18 section 12):
- Proper Date dimension table (Power BI time-intelligence ke liye).
- Basic sentiment analysis review-text par.
- ML-based segmentation as a comparison (not replacement) to RFM.
- Demand forecasting.
- Automated data-refresh pipeline.

## "What are the limitations?"

- No Profit/CAC/Conversion-Rate (data unavailable — file 12).
- No formal hypothesis-testing (file 11/24).
- No cohort-based retention analysis (file 13).
- Power BI `.pbix` design-complete, physical-build ek separate manual step hai (file 16).

## "What if the data had missing values?" (hypothetical, generalize from your real experience)

"Maine already isse handle kiya hai several tables mein — pehle **why missing** samझता hoon
(business-lifecycle null? data-entry gap?), phir decide karta hoon: drop (negligible+critical),
fill-with-meaningful-default (categorical), ya leave-as-is (legitimate business state)."

## "What if the interviewer says your insight is not causal?"

"Sahmat hoon — maine khud is nuance ko document kiya hai (`docs/learning/17`). Yeh ek strong,
large-sample **correlation** hai jo business-action ke liye kaafi actionable hai, lekin main
ise 'proven cause' nahi bolता. Agar causation formally establish karni hoती, ek controlled
experiment (A/B test) chahiye hota."

## "What would you do with more data?"

Multi-year data hota toh year-over-year seasonality confidently establish kar sakta (abhi sirf
ek Nov-peak dikha, dusre saal repeat hone ka confirmation nahi hai). Seller-level ya
marketing-spend data hota toh CAC/Profit jaise metrics bhi possible hote.

## "What if the business rejected your recommendation?"

"Main poochega **kyun** — resource-constraint, priority-conflict, ya unproven-ROI-concern? Phir
recommendation ko refine karता — jaise 'At Risk' win-back campaign ko ek chhote pilot-batch par
pehle test karने ka suggest karta, poore-segment rollout se pehle, taaki ROI real-data se prove
ho."

---

## What I should remember

- Har answer ek **reasoning pattern** hai, script nahi — samझो "why," phir apne shabdon mein bolो.
- Limitations/challenges ko confidently, proactively bolना — chhupाना nahi.
- Har "why this tool" question ka answer: **is specific project/scope ke liye kyun sahi tha**,
  "universally best" nahi bolना.
