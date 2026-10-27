# Telco Customer Churn Analysis
### Advanced Excel | SQL | Power BI Project

## Project Overview
Analysis of 7,043 telecom customers (IBM public Telco Churn dataset) to identify
why customers leave and which segments are highest risk. Data spans 4 linked
tables: customer profile, location, services, and churn status.

## Files in this project
| File | Purpose |
|---|---|
| `Telco_Churn_Analysis.xlsx` | Excel workbook — Main/Location/Services/Status sheets, INDEX/MATCH lookups, conditional formatting, Dashboard with KPIs + charts |
| `telco_sql_queries.sql` | SQL schema + 9 queries (joins, RANK window function, CASE bucketing, reporting view) |
| `vw_churn_summary.csv` | Pre-merged flat table (18 columns) — import this directly into Power BI |

## Key Insights
1. **Overall churn rate: 26.54%** (1,869 of 7,043 customers churned)
2. **Contract type is the strongest churn driver** — Month-to-month customers churn at **42.71%**, vs only **2.83%** for Two-year contracts. Locking customers into longer contracts is the single highest-leverage retention lever.
3. **Satisfaction score gap** — churned customers average a satisfaction score of **1.74/5**, vs **3.79/5** for retained customers, confirming the survey data lines up with actual churn behavior.
4. **Top churn reason: "Competitor had better devices"** — points to a product/device competitiveness problem, not just pricing.
5. Fiber Optic internet customers show higher churn than DSL/Cable — worth checking service quality or pricing for that segment.

## How each tool was used
- **Excel (Advanced):** INDEX/MATCH to pull Satisfaction Score, Customer Status, Churn Category, Offer, and Internet Type from separate sheets into Main; nested IF for a Risk Flag column; SUMIFS/COUNTIFS-driven Dashboard; color-scale and highlight conditional formatting; Goal Seek usable on the Churn Rate % cell.
- **SQL:** 4 normalized tables joined on CustomerID; RANK() window function to rank churned customers by CLTV; CASE-based charge-tier bucketing; a reporting VIEW (`vw_churn_summary`) that mirrors what Power BI consumes.
- **Power BI:** `vw_churn_summary.csv` (or the SQL view) as the single source — build a Churn Rate % card, Contract-wise bar chart, City map (Latitude/Longitude), and Churn Reason breakdown, with slicers on Contract and Internet Type.

## Next step for you
Open `Telco_Churn_Analysis.xlsx` and walk through the Dashboard sheet formulas,
then import `vw_churn_summary.csv` into Power BI Desktop to build the visuals.
Be ready to explain the 5 insights above in your own words — that's what
interviewers actually probe.
