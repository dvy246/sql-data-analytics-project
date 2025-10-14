/*****************************************************************************
 * Monthly Performance Analysis SQL Script
 *
 * Overview:
 *   This script delivers a comprehensive monthly performance analysis for key business metrics such as sales, quantity sold, product cost, and product price. 
 *   It enables comparison of each month's performance metrics across products, identifying trends and variances using window functions to determine changes, averages, and max values.
 *
 * Key Features:
 *   - Aggregates and analyzes metrics at a monthly granularity.
 *   - Calculates month-on-month changes, variances from average and maximum values, and classifies trends.
 *   - Supports performance insights for sales, quantities, cost structure, and price realization.
 *   - Provides reusable query patterns for business intelligence and analytics.
 *
 * Usage:
 *   - Use these queries for monthly business reviews, dashboards, or to inform strategic decisions regarding sales, pricing, and cost management.
 *   - Each query includes clear documentation of its logic and intent for ease of adaptation and repeated use.
 *
 * Note:
 *   - Data sources and table references may require customization to your specific data warehouse schema.
 *   - All calculations are carried out per product and per month, rolled up across all years unless otherwise specified.
 *****************************************************************************/

USE DataWarehouseAnalytics;
GO

-- ----------------------------------------------------------------------------
-- Monthly Sales Performance by Product
-- Aggregates total monthly sales per product and analyzes monthly and average change.
-- Calculates for each product and month:
--   - total sales,
--   - prior month’s sales and change,
--   - type of sales movement (increase/decrease/no change),
--   - deviation from product’s average monthly sales,
--   - classification relative to average.
-- ----------------------------------------------------------------------------
WITH monthly_product_sales AS (
    SELECT 
        MONTH(s.order_date) AS month,
        p.product_name,
        SUM(s.sales_amount) AS current_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY MONTH(s.order_date), p.product_name
)
SELECT 
    month,
    product_name,
    current_sales,
    LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY month) AS previous_month_sales,
    current_sales - LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY month) AS previous_month_sales_change,
    CASE 
        WHEN current_sales - LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY month) > 0 THEN 'increase'
        WHEN current_sales - LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY month) < 0 THEN 'decrease'
        ELSE 'no change'
    END AS sales_change_type,
    AVG(current_sales) OVER (PARTITION BY product_name) AS average_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS sales_change,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'above_average'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'below_average'
        ELSE 'average'
    END AS avg_change_type
FROM monthly_product_sales
ORDER BY product_name, month;


-- ----------------------------------------------------------------------------
-- Monthly Quantity Sold Analysis
-- Calculates, for each product and month (across all years):
--   - total quantity sold,
--   - average quantity,
--   - prior month’s quantity and change,
--   - type of quantity change (increase/decrease/no change),
--   - deviation from product’s average monthly quantity,
--   - classification relative to average.
-- ----------------------------------------------------------------------------

WITH quantity_sold_report_month AS (
    SELECT 
        p.product_name,
        YEAR(s.order_date) AS year,
        MONTH(s.order_date) AS month,
        COUNT(quantity) AS total_quantity
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY p.product_name, YEAR(s.order_date), MONTH(s.order_date)
)
SELECT 
    year,
    month,
    product_name,
    total_quantity,
    AVG(total_quantity) OVER (PARTITION BY product_name) AS avg_quantity,
    LAG(total_quantity, 1) OVER (PARTITION BY product_name ORDER BY year, month) AS previous_month_quantity,
    total_quantity - LAG(total_quantity, 1) OVER (PARTITION BY product_name ORDER BY year, month) AS quantity_change,
    CASE 
        WHEN total_quantity - LAG(total_quantity, 1) OVER (PARTITION BY product_name ORDER BY year, month) > 0 THEN 'increase'
        WHEN total_quantity - LAG(total_quantity, 1) OVER (PARTITION BY product_name ORDER BY year, month) < 0 THEN 'decrease' 
        ELSE  'no_change'
    END AS change_type,
    total_quantity - AVG(total_quantity) OVER (PARTITION BY product_name) AS change_from_avg,
    CASE 
        WHEN total_quantity - AVG(total_quantity) OVER (PARTITION BY product_name) > 0 THEN 'larger_than_avg'
        WHEN total_quantity - AVG(total_quantity) OVER (PARTITION BY product_name) < 0 THEN 'smaller_than_avg'  
        ELSE 'no_change' 
    END AS avg_change_type
FROM quantity_sold_report_month;


-- ----------------------------------------------------------------------------
-- Monthly Product Cost Analytics
-- For each product and month (across all years), computes:
--   - total cost,
--   - average and maximum cost,
--   - prior month’s cost and change,
--   - cost difference from average and max,
--   - classification for change direction and relative magnitude.
-- ----------------------------------------------------------------------------

WITH product_cost_report_month AS (
    SELECT 
        MONTH(s.order_date) AS month,
        p.product_name,
        SUM(p.cost) AS total_cost
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY p.product_name, MONTH(s.order_date)
)
SELECT 
    month,
    product_name,
    total_cost,
    AVG(total_cost) OVER (PARTITION BY product_name) AS avg_cost,
    LAG(total_cost, 1) OVER (PARTITION BY product_name ORDER BY month) AS previous_month_cost,
    MAX(total_cost) OVER (PARTITION BY product_name) AS max_cost,
    total_cost - AVG(total_cost) OVER (PARTITION BY product_name) AS diff_from_avg_cost,
    CASE 
        WHEN total_cost - AVG(total_cost) OVER (PARTITION BY product_name) > 0 THEN 'above_avg'
        WHEN total_cost - AVG(total_cost) OVER (PARTITION BY product_name) < 0 THEN 'below_avg'
        ELSE 'no_change'
    END AS diff_from_avg_cost_type,
    total_cost - LAG(total_cost, 1) OVER (PARTITION BY product_name ORDER BY month) AS diff_from_previous_month_cost,
    CASE 
        WHEN total_cost - LAG(total_cost, 1) OVER (PARTITION BY product_name ORDER BY month) > 0 THEN 'increase'
        WHEN total_cost - LAG(total_cost, 1) OVER (PARTITION BY product_name ORDER BY month) < 0 THEN 'decrease'
        ELSE 'no_change'
    END AS diff_from_previous_month_cost_type,
    total_cost - MAX(total_cost) OVER (PARTITION BY product_name) AS diff_from_max_cost,
    CASE 
        WHEN total_cost - MAX(total_cost) OVER (PARTITION BY product_name) > 0 THEN 'above_max'
        WHEN total_cost - MAX(total_cost) OVER (PARTITION BY product_name) < 0 THEN 'below_max'
        ELSE 'no_change'
    END AS diff_from_max_cost_type
FROM product_cost_report_month;


-- ----------------------------------------------------------------------------
-- Monthly Product Price Differential Analysis
-- Reports price performance per product and month (all years). For each, computes:
--   - total product price,
--   - average and maximum price,
--   - price difference from average and max,
--   - prior month’s price and its change,
--   - status labels for price trends and outliers.
-- ----------------------------------------------------------------------------

WITH price_report_month AS (
    SELECT
        MONTH(s.order_date) AS month,
        p.product_name,
        SUM(s.price) AS total_product_price,
        AVG(s.price) AS average_product_price
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY p.product_name, MONTH(s.order_date)
)
SELECT
    month,
    product_name,
    total_product_price,
    AVG(total_product_price) OVER (PARTITION BY product_name) AS avg_price,
    total_product_price - AVG(total_product_price) OVER (PARTITION BY product_name) AS diff_from_avg_price,
    CASE
        WHEN total_product_price - AVG(total_product_price) OVER (PARTITION BY product_name) > 0 THEN 'above_avg'
        WHEN total_product_price - AVG(total_product_price) OVER (PARTITION BY product_name) < 0 THEN 'below_avg'
        ELSE 'no_change'
    END AS diff_from_avg_price_status,

    MAX(total_product_price) OVER (PARTITION BY product_name) AS max_price,
    total_product_price - MAX(total_product_price) OVER (PARTITION BY product_name) AS diff_from_max_price,
    CASE
        WHEN total_product_price - MAX(total_product_price) OVER (PARTITION BY product_name) > 0 THEN 'above_max'
        WHEN total_product_price - MAX(total_product_price) OVER (PARTITION BY product_name) < 0 THEN 'below_max'
        ELSE 'no_change'
    END AS diff_from_max_price_status,

    LAG(total_product_price, 1) OVER (PARTITION BY product_name ORDER BY month) AS previous_month_price,
    total_product_price - LAG(total_product_price, 1) OVER (PARTITION BY product_name ORDER BY month) AS diff_from_previous_month_price,
    CASE
        WHEN total_product_price - LAG(total_product_price, 1) OVER (PARTITION BY product_name ORDER BY month) > 0 THEN 'increase'
        WHEN total_product_price - LAG(total_product_price, 1) OVER (PARTITION BY product_name ORDER BY month) < 0 THEN 'decrease'
        ELSE 'no_change'
    END AS diff_from_previous_month_price_status
FROM price_report_month;
