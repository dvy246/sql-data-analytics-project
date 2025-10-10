/*****************************************************************************
 * Ranking Analysis SQL Queries
 *
 * This script provides a series of ranking queries to analyze the sales data
 * in the DataWarehouseAnalytics environment. Each query focuses on identifying
 * top and bottom performers in terms of revenue, price, and sales volume
 * across products, customers, countries, and categories.
 *
 * All queries include explicit documentation to support clarity and reuse
 * by analysts, data scientists, and business users.
 *****************************************************************************/

/*---------------------------------------------------------------------------
-- 1. Top 5 Highest Revenue Products
--    Retrieves the five products generating the highest total sales revenue.
---------------------------------------------------------------------------*/
SELECT TOP 5
    p.product_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

/*---------------------------------------------------------------------------
-- 2. Top 5 Lowest Revenue Products
--    Lists the five products with the lowest total sales revenue.
---------------------------------------------------------------------------*/
SELECT TOP 5
    p.product_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

/*---------------------------------------------------------------------------
-- 3. Top 5 Highest Revenue Customers
--    Identifies the five customers with the highest total revenue contribution.
---------------------------------------------------------------------------*/
SELECT TOP 5
    c.first_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.first_name
ORDER BY total_revenue DESC;

/*---------------------------------------------------------------------------
-- 4. Top 5 Lowest Revenue Customers
--    Returns the five customers with the lowest cumulative revenue.
---------------------------------------------------------------------------*/
SELECT TOP 5
    c.first_name,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.first_name
ORDER BY total_revenue ASC;

/*---------------------------------------------------------------------------
-- 5. Top 5 Highest Revenue Countries
--    Shows the five countries with the greatest total sales revenue.
---------------------------------------------------------------------------*/
SELECT TOP 5
    c.country,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_revenue DESC;

/*---------------------------------------------------------------------------
-- 6. Top 5 Lowest Revenue Countries
--    Lists the five countries contributing the lowest total sales revenue.
---------------------------------------------------------------------------*/
SELECT TOP 5
    c.country,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_revenue ASC;

/*---------------------------------------------------------------------------
-- 7. Top 3 Categories with Highest Revenue
--    Returns the three product categories producing the highest total revenue.
---------------------------------------------------------------------------*/
SELECT TOP 3
    p.category,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

/*---------------------------------------------------------------------------
-- 8. Top 3 Categories with Lowest Revenue
--    Identifies the three categories with the lowest total sales revenue.
---------------------------------------------------------------------------*/
SELECT TOP 3
    p.category,
    SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue ASC;

/*---------------------------------------------------------------------------
-- 9. Top 3 Products with Highest Total Price
--    Lists the three products accumulating the highest total sales price.
---------------------------------------------------------------------------*/
SELECT TOP 3
    p.product_name AS products,
    SUM(s.price) AS total_price
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_price DESC;

/*---------------------------------------------------------------------------
-- 10. Top 3 Products with Lowest Total Price
--     Identifies the three products with the lowest total sales price.
---------------------------------------------------------------------------*/
SELECT TOP 3
    p.product_name AS products,
    SUM(s.price) AS total_price
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_price ASC;
