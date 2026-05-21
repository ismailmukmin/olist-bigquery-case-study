# Dataset Instructions

The data used in this project is sourced from the **Olist Brazilian E-Commerce** 
dataset, publicly available on Kaggle.

## How to Download

1. Go to: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
2. Click **Download**
3. Unzip the file
4. Place all 9 CSV files into `/datasets` folder in locale

## Tables Required

| File Name | Description |
|---|---|
| olist_orders_dataset.csv | Master orders table |
| olist_order_items_dataset.csv | Items within each order |
| olist_customers_dataset.csv | Customer information |
| olist_products_dataset.csv | Product details |
| olist_sellers_dataset.csv | Seller information |
| olist_order_payments_dataset.csv | Payment methods & values |
| olist_order_reviews_dataset.csv | Customer review scores |
| olist_geolocation_dataset.csv | ZIP code coordinates |
| product_category_name_translation.csv | Category name in English |

## Loading into BigQuery

1. Create a dataset called `olist` in Google BigQuery
2. Upload each CSV as a new table (use Auto-detect schema)
3. Update `your_project` in all `.sql` files with your GCP project ID