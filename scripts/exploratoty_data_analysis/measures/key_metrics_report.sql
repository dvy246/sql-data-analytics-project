USE DataWarehouseAnalytics;

SELECT 'total_sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'total_products' AS measure_name, COUNT(DISTINCT product_key) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'total_quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'total_customers' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.dim_customers
UNION ALL
SELECT 'total_orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'average_price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'average_sales' AS measure_name, AVG(sales_amount) AS measure_value FROM gold.fact_sales

