# 📋 Business Questions & Analysis Framework

## Overview

This document outlines the 10 business questions addressed in this case study,
organized into 5 analytical themes. Each question is mapped to its corresponding
SQL file, the technique used, and the expected business insight.

---

## Dataset Schema

```
orders ──────────── order_items ──── products ── category_translation
   │                     │
   ├── customers          └── sellers
   │
   ├── payments
   │
   └── reviews
```

| Table | Description | Key Columns |
|---|---|---|
| `orders` | Master order records | order_id, customer_id, order_status, timestamps |
| `order_items` | Line items per order | order_id, product_id, seller_id, price, freight_value |
| `customers` | Customer details | customer_id, customer_unique_id, customer_state |
| `products` | Product catalog | product_id, product_category_name |
| `sellers` | Seller details | seller_id, seller_state |
| `payments` | Payment records | order_id, payment_type, payment_value |
| `reviews` | Customer reviews | order_id, review_score, review_comment_message |
| `geolocation` | ZIP coordinates | geolocation_zip_code_prefix, lat, lng |
| `category_translation` | Category in English | string_field_0 (PT), string_field_1 (EN) |

---

## Theme 1 — Revenue Analysis
**File:** `sql/01_revenue_analysis.sql`

### Q1: What is the monthly revenue trend and growth rate?

| Detail | Description |
|---|---|
| **Business Context** | Understanding revenue trends helps identify seasonal patterns, growth periods, and potential areas of concern |
| **SQL Techniques** | CTE, `LAG()` window function, `FORMAT_DATE()`, aggregation |
| **Output** | Monthly revenue table with MoM growth % |
| **Insight to Find** | Which months peak? Is there seasonality? Are there negative growth months? |

---

### Q2: What is the revenue contribution by product category?

| Detail | Description |
|---|---|
| **Business Context** | Knowing which categories drive revenue helps prioritize marketing spend and inventory planning |
| **SQL Techniques** | CTE, `SUM() OVER()` for percentage share, `RANK()`, multi-table JOIN |
| **Output** | Top 20 categories ranked by revenue with share % |
| **Insight to Find** | Do top 3 categories follow Pareto (80/20) rule? Which categories have high orders but low price? |

---

## Theme 2 — Customer Analysis
**File:** `sql/02_customer_analysis.sql`

### Q3: How does new vs returning customer trend look over time?

| Detail | Description |
|---|---|
| **Business Context** | Retention is cheaper than acquisition — tracking new vs returning shows platform health |
| **SQL Techniques** | CTE, `ROW_NUMBER()` window function, `PARTITION BY`, `CASE WHEN` |
| **Output** | Monthly count of new vs returning customers |
| **Insight to Find** | What % are returning? Is retention growing or flat? |

---

### Q4: Which states have the highest customer lifetime value (CLV)?

| Detail | Description |
|---|---|
| **Business Context** | CLV by region helps prioritize where to invest in marketing and logistics |
| **SQL Techniques** | Multi-table JOIN, `RANK()`, aggregation, grouping |
| **Output** | CLV ranking by state with avg orders and total revenue |
| **Insight to Find** | Which states are high CLV but low volume? (underserved markets) |

---

## Theme 3 — Seller Performance
**File:** `sql/03_seller_performance.sql`

### Q5: Who are the top performing sellers and what makes them stand out?

| Detail | Description |
|---|---|
| **Business Context** | Identifying top sellers helps replicate their patterns in onboarding programs |
| **SQL Techniques** | CTE, `RANK()`, `DATE_DIFF()`, `AVG()`, multi-table JOIN across 4 tables |
| **Output** | Top 20 sellers with revenue, review score, delivery speed |
| **Insight to Find** | Do top revenue sellers also have high ratings? Is delivery speed a differentiator? |

---

### Q6: What is the seller activity trend over time?

| Detail | Description |
|---|---|
| **Business Context** | Tracking active sellers monthly shows marketplace supply-side health |
| **SQL Techniques** | `COUNT(DISTINCT)`, `FORMAT_DATE()`, aggregation |
| **Output** | Monthly active sellers, orders, and revenue per seller |
| **Insight to Find** | Is seller count growing? Does avg revenue per seller drop as more join? (saturation) |

---

## Theme 4 — Product Analysis
**File:** `sql/04_product_analysis.sql`

### Q7: Which product categories have the highest cancellation rate?

| Detail | Description |
|---|---|
| **Business Context** | High cancellations in specific categories may signal quality issues or logistics problems |
| **SQL Techniques** | `COUNTIF()`, `NULLIF()` for safe division, `HAVING` clause, multi-table JOIN |
| **Output** | Top 15 categories by cancellation rate (filtered to min 50 orders) |
| **Insight to Find** | Which categories consistently exceed 5% cancellation? Are they worth investing in? |

---

### Q8: What is the average order value (AOV) by product category?

| Detail | Description |
|---|---|
| **Business Context** | AOV by category informs pricing strategy and promotion design |
| **SQL Techniques** | CTE, `STDDEV()`, `MIN()`, `MAX()`, `HAVING`, subquery grouping |
| **Output** | Top 20 categories by AOV with min/max/stddev |
| **Insight to Find** | Which are premium categories? Which have wide price variance? (diverse catalog) |

---

## Theme 5 — Delivery & Logistics
**File:** `sql/05_delivery_logistics.sql`

### Q9: How does delivery performance vary by region?

| Detail | Description |
|---|---|
| **Business Context** | Regional delivery gaps affect satisfaction and highlight where logistics investment is needed |
| **SQL Techniques** | `DATE_DIFF()`, `COUNTIF()`, multi-table JOIN, state-level aggregation |
| **Output** | Delivery metrics per state — avg days, delay, late delivery rate |
| **Insight to Find** | Which states have worst late delivery rates? Is there a big gap between estimated vs actual? |

---

### Q10: What is the relationship between delivery time and review scores?

| Detail | Description |
|---|---|
| **Business Context** | Quantifying how delivery speed impacts satisfaction helps justify logistics investment |
| **SQL Techniques** | CTE, `CASE WHEN` bucketing, `DATE_DIFF()`, conditional aggregation |
| **Output** | Review score breakdown by delivery time bucket and early/on-time/late status |
| **Insight to Find** | Does satisfaction drop sharply after 10 days? Do early deliveries consistently get 5 stars? |

---

## SQL Techniques Summary

| Technique | Used In |
|---|---|
| Common Table Expressions (CTEs) | Q1, Q2, Q3, Q5, Q8, Q10 |
| Window Functions (`RANK`, `LAG`, `ROW_NUMBER`) | Q1, Q2, Q3, Q4, Q5 |
| Conditional Aggregation (`COUNTIF`, `CASE WHEN`) | Q7, Q9, Q10 |
| Date Functions (`DATE_DIFF`, `FORMAT_DATE`) | Q1, Q5, Q6, Q9, Q10 |
| Multi-table JOINs (3+ tables) | Q2, Q4, Q5, Q7, Q8 |
| Percentage & Ratio Calculations | Q2, Q7, Q9 |

---

## How to Run the Queries

1. Open **Google BigQuery Console** at console.cloud.google.com
2. Select your project from the top dropdown
3. Open any `.sql` file from the `/sql` folder
4. Replace `your_project` with your actual GCP project ID
5. Paste the query into the BigQuery editor
6. Click **Run**

> 💡 **Tip:** Run one query at a time (highlight the query block and press `Ctrl + Enter`) 
> rather than running the entire file at once.

---

*Last updated: May 2026*
