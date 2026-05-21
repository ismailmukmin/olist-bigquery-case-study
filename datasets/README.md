# Dataset Instructions

The data used in this project is sourced from the **Olist Brazilian E-Commerce** 
dataset, publicly available on Kaggle.

## How to Download

1. Go to: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
2. Click **Download**
3. Unzip the file
4. Place all 9 CSV files in locale

## Tables Required

| File Name | Table Name in BigQuery |  Description
|---|---|---|
| olist_orders_dataset.csv | `orders` | Master orders table |
| olist_order_items_dataset.csv | `order_items` | Items within each order |
| olist_customers_dataset.csv | `customers` | Customer information |
| olist_products_dataset.csv | `products` | Product details |
| olist_sellers_dataset.csv | `sellers` | Seller information |
| olist_order_payments_dataset.csv | `payments` | Payment methods & values |
| olist_order_reviews_dataset.csv | `reviews` | Customer review scores |
| olist_geolocation_dataset.csv | `geolocation` | ZIP code coordinates |
| product_category_name_translation.csv | `category_translation` | Category name in English |

## Loading into BigQuery

1. Create a dataset called `olist` in Google BigQuery
2. Upload each CSV as a new table (use Auto-detect schema)
