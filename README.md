# Data-Analyst-Projects-PBI-Sql-Python-
Power BI (PBIP) project for the ecommercecloud analytics stack — semantic model, report, RLS/OLS, Incremental Refresh, and Dev→Test→Prod deployment pipeline.


# EcommerceCloud – Power BI • SQL • PBIP

Portfolio project on **sample ecommerce data** showing end-to-end BI craft:
- Star schema with **Incremental Refresh**
- Dynamic **RLS** (Region) + **OLS** (hide cost/PII for partner persona)
- **Deployment Pipelines** (Dev → Test → Prod)
- **PBIP + Git** 
- Performance tuning (running totals, query reduction, aggregations)


 This repo focuses on **how** the solution is designed, secured, optimized, and released. No real data or secrets.

---

## 🧭 Highlights
- **KPIs (sample 2025):** **$37.6M** Total Sales · **48K** Orders · **14.1%** RefundRate · **$33.8M** Net Sales  
- **Top-N storytelling:** “Top 5 + Others” pattern on product views
- **Returns analytics:** reasons, vendor impact, return/refund cycle time
- **RLS/OLS:** regions APAC/AMER/EMEA/LATAM; partner audience cannot see cost/PII
- **IR policy:** Store 5y, refresh last 7d on fact tables

---

## 📸 Report Tour (screenshots)
- `01-Overview.png`, `02-Sales.png`, `03-Customers.png`, `04-Returns.png`, `05-Products.png`



**Narrative highlights**
- **Overview:** KPIs + MoM%, Sales vs Last Year, Total vs Net Sales. Late-Q3 dip aligns with refund spike.
- **Sales:** YTD vs PY, Orders by Quarter, 3-month rolling trend, monthly breakdown by category.
- **Customers:** Unique/Repeat customers, RepeatRate, ACV, ActiveCustomers3M vs Churn—signals retention risk.
- **Returns:** Reasons (Quality Issue/Damaged lead), vendor country mix, average return/refund days.
- **Products:** Top category/subcategory/product; **Top 5 + Others** keeps focus on leaders while counting the tail.
- **Pipelines/App:** Dev→Test→Prod promotions with rules & credentials; app for end users.

---

## 🧱 Architecture

Azure SQL (views)
└─ Power Query (folding) → Star schema
Facts: Orders, Returns
Dims : Date, Customer, Product, Region
├─ DAX measures (YTD/YoY, refund KPIs, TopN+Others)
├─ RLS (Region via Security_UserRegion)
├─ OLS (Read=None on cost/PII for partner role)
└─ Incremental Refresh (store 5y, refresh 7d)
Power BI Service
└─ Deployment Pipeline (Dev → Test → Prod) → App audiences
GitHub
└─ PBIP project (dataset+report JSON), SQL DDL, docs



---

## 🔐 Security
- **RLS**: table `Security_UserRegion (UPN, Region)` maps viewer to allowed Region(s). Role filter:
  ```DAX
  'Security_UserRegion'[UPN] = USERPRINCIPALNAME()
OLS: columns such as axis-parameters,Measures Table; partner pages avoid visuals that require those columns.

🔁 Incremental Refresh
Policy: Store 5 years, Refresh last 7 days

Filter columns: FactOrders[order_day], FactReturns[return_day]

First refresh in each stage (Dev/Test/Prod) builds partitions; subsequent refreshes are incremental.

📊 Selected Measures (simplified)
DAX
Copy code
Total Sales := SUM ( 'FactSales'[SalesAmount] )
Net Sales   := [Total Sales] - [Total Refund Amount]

YTD Sales :=
TOTALYTD ( [Total Sales], 'Date'[Date])

Sales LY := CALCULATE ( [Total Sales], DATEADD('Date'[Date], -1, YEAR) )

RefundRate := DIVIDE ( [Total Return Units], [Orders] )
AOV        := DIVIDE ( [Total Sales], [Orders] )


🚀 Release Process (summary)
Develop in PBIP (branch/PR in GitHub)

Publish to Dev workspace

Pipeline Deploy Dev→Test → set Rules, Credentials, Refresh now, RLS/OLS members

Validate → Deploy Test→Prod → Update App

🛠️ How to Run Locally
Open powerbi/ecommercecloud/ecommercecloud.pbiproj in Power BI Desktop

Set data source credentials → Refresh

Publish to Dev → promote via pipeline (see docs/DEPLOYMENT.md when added)

📁 Repo Map 

/sql/                       # DDL/views (no data)
/powerbi/ecommercecloud/    # PBIP: dataset/, report/, *.pbiproj
/docs/README-images/        # screenshots used in this README
Sample project for learning/portfolio purposes.


# Business Problem & Solution Narrative

## Context
A mid-size ecommerce business wants to **grow revenue**, **reduce refunds**, and **retain customers**. Leadership needs a single, trustworthy view aligned to the **fiscal year (April–March)** that different teams (Sales, Category, Ops, Finance, Regional leaders, and Partners) can use securely.

---

## Objectives
1. **Revenue & Growth:** Track Sales/Orders/Net Sales with clear **MTD/QTD/YTD**  and **YoY** comparisons.
2. **Profit Protection:** Identify refund drivers and shrink the **refund cycle time** (return → refund).
3. **Customer Retention:** Lift **repeat rate**, control **churn**, and improve **AOV/ACV**.
4. **Product Focus:** Concentrate on winners via **Top-N** insights while still accounting for the long tail.
5. **Regional Accountability & Secure Sharing:** Give each region only its data (**RLS**), and share externally without exposing (**OLS**).

---

## Core Questions
- **Revenue Trend:** How are **Total Sales**, **Orders**, and **Net Sales** trending **MoM/YoY** in fiscal time?
- **Drivers:** Which **categories/subcategories/products** lead or lag? Who are the **Top 5** at any time?
- **Returns:** What are the **top return reasons**? Which **vendors/regions** contribute most? How many days from **return to refund**?
- **Customers:** Are **unique** and **repeat** customers growing? What’s **Repeat Rate** and **Churn** trend? What’s our **AOV**/**ACV**?
- **Regions:** How does each region (APAC/AMER/EMEA/LATAM) perform on these KPIs?

---

## Solution (What the Report Delivers)
- **Star-schema** model (Facts: Orders, Returns; Dims: Date, Customer, Product, Region).
- **Fiscal time intelligence** : MTD/QTD/YTD and YoY aligned to business calendar.
- **Top-5 + Others** pattern to balance focus (leaders) with completeness (tail).
- **Returns analytics**: reasons, vendor country mix, and **cycle time** (return days, refund days).
- **Customer metrics**: Unique vs Repeat, **Repeat Rate**, **Churn** vs **ActiveCustomers3M**, **AOV**, **ACV**.
- **Security**:
  - **RLS** restricts users to their Region(s) using a UPN→Region mapping.
  - **OLS** hides sensitive columns (e.g., MeasuredTable etc) for partner audiences.
- **Operational reliability**:
  - **Incremental Refresh** on facts (e.g., store 5 years; refresh last 7 days).
  - **Deployment Pipelines** (Dev → Test → Prod) with stage-specific rules and credentials for safe promotion.

---

## Who Uses It & Decisions Enabled
- **Head of Sales:** Steer targets by YTD vs PY; quickly spot surging or declining categories.
- **Category Managers:** Double down on **Top-5** products; address underperformers; mitigate return-heavy SKUs.
- **Operations/Quality:** Prioritize vendors/regions with high **return rates** and **long refund cycles**.
- **Finance:** Reconcile **Net Sales** (Total − Refunds) by fiscal periods; monitor refund exposure.
- **Regional Leaders & Partners:** Consume only their data. 

---

## Example Insights (from sample data)
- **Refund spikes in late Q3** depress **Net Sales**; concentrated in **Electronics** and vendor countries **IN/CN**.
- **Repeat Rate ~21%** while **Churn rises** as ActiveCustomers dip—signals the need for lifecycle/loyalty offers.
- **Sony TWS Earbuds** leads revenue; the **Top-5 + Others** view confirms a meaningful long tail that still contributes.

---

## Success Criteria
- < 3–5s typical page load; heavy pages aided by **Apply all slicers** and aggregations where needed.
- Accurate  **MTD/QTD/YTD** and **YoY** across pages.
- RLS/OLS verified: regional leaders see only their data.
- Stable refresh with **Incremental Refresh**; partitions built successfully per environment.

---

## Scope & Assumptions
- **Sample/synthetic data** (no real customer information).
- Azure SQL views feed the model; all credentials and secrets are kept outside the repo.
- Regional taxonomy: **APAC, AMER, EMEA, LATAM**.

---

## Next Steps
- Add anomaly detection for sudden return spikes and automated vendor alerts.
- Introduce **What-If** parameters.
- Expand OLS personas.


