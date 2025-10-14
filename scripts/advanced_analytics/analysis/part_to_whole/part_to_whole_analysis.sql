/*****************************************************************************
 * Part-to-Whole Analysis SQL Scripts
 *
 * Overview:
 *   This script provides SQL queries to analyze how individual parts (such as products, categories, or organizational units) contribute to the overall total within a business context. 
 *   By breaking down key metrics into constituent components, these analyses help quantify each part’s share of the whole and track how these proportions evolve over time.
 *
 * Key Features:
 *   - Calculates each item's percentage contribution to the total for a specified metric (e.g., sales, revenue, units sold).
 *   - Supports analysis by category, product, or other dimensional attributes.
 *   - Enables part-to-whole comparisons over time (monthly, yearly, etc.).
 *   - Useful for understanding concentration, distribution, and identifying top contributors.
 *
 * Use Cases:
 *   - Determining what share of overall sales each product category or region represents.
 *   - Identifying the most or least significant contributors to business performance.
 *   - Supporting Pareto (80/20) analysis for resource allocation or strategy planning.
 *
 * Notes:
 *   - Modify table and column names as appropriate for your data warehouse schema.
 *   - Can be extended to include additional dimensions, cumulative sums, or running totals if needed.
 *****************************************************************************/
 

use datawarehouseanalytics;

-- Calculates each category's total sales, its contribution to the grand total, and what percent of total sales each represents
WITH category_contribution AS (
    SELECT 
        category,
        SUM(s.sales_amount) AS total_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY category
)
SELECT
    *,
    SUM(total_sales) OVER () AS total,
    CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total_sales
FROM category_contribution
ORDER BY total_sales DESC;


-- Calculates each product's total sales and shows what percent each contributes to overall sales
WITH product_contribution AS (
    SELECT 
        product_name,
        SUM(s.sales_amount) AS total_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY product_name
)
SELECT
    *,
    SUM(total_sales) OVER () AS total_sales_overall,
    CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total_sales
FROM product_contribution
ORDER by total_sales desc;


-- Calculates each product's total cost and its contribution as a percentage of the overall product cost
WITH product_cost_contribution AS (
    SELECT 
        product_name,
        SUM(cost) AS total_cost
    FROM gold.dim_products
    GROUP BY product_name
)
SELECT
    *,
    SUM(total_cost) OVER () AS overall_cost,
    CONCAT(ROUND(CAST(total_cost AS FLOAT) / SUM(total_cost) OVER () * 100, 2), '%') AS percentage_of_total_cost
FROM product_cost_contribution
ORDER BY total_cost DESC;


-- Summarizes total price per product and what percent of the overall sales price each represents
WITH product_price_contribution AS (
    SELECT 
        p.product_name,
        SUM(s.price) AS total_price
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY p.product_name
)
SELECT
    *,
    SUM(total_price) OVER () AS overall_price,
    CONCAT(ROUND(CAST(total_price AS FLOAT) / SUM(total_price) OVER () * 100, 2), '%') AS percentage_of_total_price
FROM product_price_contribution
ORDER BY total_price DESC;


-- Computes the total quantity sold per product and the percentage each product comprises of total quantity sold
WITH product_quantity_sold_contribution AS (
    SELECT 
        p.product_name,
        SUM(s.quantity) AS total_quantity
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY p.product_name
)
SELECT
    *,
    SUM(total_quantity) OVER () AS overall_quantity,
    CONCAT(ROUND(CAST(total_quantity AS FLOAT) / SUM(total_quantity) OVER () * 100, 2), '%') AS percentage_of_total_quantity
FROM product_quantity_sold_contribution
ORDER BY total_quantity DESC;
