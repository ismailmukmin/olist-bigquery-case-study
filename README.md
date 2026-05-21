# 🛒 E-Commerce SQL Business Intelligence Case Study
### Google BigQuery · Olist Brazilian E-Commerce Dataset

## Business Problem
How can a marketplace use its transactional data to drive smarter 
decisions across revenue, customer retention, seller performance, 
product strategy, and logistics?

## Objective
Answer 10 real business questions using SQL — demonstrating 
analytical thinking, query design, and the ability to translate 
data into actionable insights.

## Dataset
- **Source:** [Olist Brazilian E-Commerce — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Size:** 100,000+ orders · 9 relational tables
- **Period:** 2016 – 2018

## Tools
`Google BigQuery` · `SQL` · `Window Functions` · `CTEs`

## Business Questions Covered

| # | Theme | Question |
|---|---|---|
| 1 | Revenue | Monthly revenue trend & MoM growth |
| 2 | Revenue | Revenue contribution by product category |
| 3 | Customer | New vs returning customer trend |
| 4 | Customer | CLV by state |
| 5 | Seller | Top performing sellers |
| 6 | Seller | Seller activity trend |
| 7 | Product | Cancellation rate by category |
| 8 | Product | Average order value by category |
| 9 | Logistics | Delivery performance by region |
| 10 | Logistics | Delivery time vs review score |

## Key Findings
- **Revenue** peaks in Q4 — clear seasonality driven by Black Friday
- **Top 5 categories** account for ~40% of total revenue (Pareto holds)
- **Returning customers** represent only ~3% — retention is a major gap
- **Late deliveries** in northern states correlate with review scores below 3.0
- **Deliveries under 10 days** average 4.2★ vs 2.8★ for 30+ day deliveries

## SQL Techniques Used
- CTEs (Common Table Expressions)
- Window functions (`RANK`, `LAG`, `ROW_NUMBER`)
- Conditional aggregation (`COUNTIF`, `CASE WHEN`)
- Date functions (`DATE_DIFF`, `FORMAT_DATE`)
- Multi-table JOINs across 5+ tables