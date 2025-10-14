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
 
/*---------------------------------------------------------------------------
-- 11. Top 3 Most Expensive Products by Unit Cost
--     Displays the three products with the highest aggregate total cost from the product dimension table.
--     "Total cost" here is calculated as the sum of the 'cost' field for each product.
---------------------------------------------------------------------------*/
SELECT TOP 3
    product_name,
    SUM(cost) AS product_cost
FROM gold.dim_products
GROUP BY product_name
ORDER BY product_cost DESC;

-- Uses window functions (RANK) for flexible ranking and slicing of top-N products.
-- To adjust how many top products you see, just change `revenue_rank<=3` in the WHERE clause below.
-- Window function makes it easy to expand this for different analyses (e.g. DENSE_RANK, ROW_NUMBER).
-- window functions are a powerful tool for data analysis for complex queries

select *
from (
 select 
 p.product_name,
 sum(s.sales_amount) as total_revenue,
 RANK() OVER (ORDER BY SUM(s.sales_amount) DESC) AS revenue_rank
 from gold.fact_sales s
 left join gold.dim_products p
 on s.product_key = p.product_key
 GROUP BY p.product_name)t
 WHERE revenue_rank<=3

/*-----------------------------------------------------------------------------
-- 12. Top 3 Customers by Number of Orders
--     Retrieves the top three customers who have placed the most distinct orders.
--     The results include the customer key, full name, and the count of unique orders.
-----------------------------------------------------------------------------*/
SELECT TOP 3
    c.customer_key,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(DISTINCT s.order_number) AS total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders DESC;


/*-----------------------------------------------------------------------------
-- 13. Bottom 3 Customers by Number of Orders
--     Identifies the three customers with the fewest number of distinct orders.
--     The output includes customer key, full name, and their respective order count.
-----------------------------------------------------------------------------*/
SELECT TOP 3
    c.customer_key,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(DISTINCT s.order_number) AS total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders ASC;


/*-----------------------------------------------------------------------------
-- 14. Top 5 Customers by Number of Orders Using Window Functions
--     Utilizes the RANK() window function to rank customers by their total number
--     of distinct orders in descending order. Returns the five highest-ranked customers.
--     Window functions facilitate flexible ranking and allow dynamic expansion of results.
-----------------------------------------------------------------------------*/
SELECT *
FROM (
    SELECT
        c.customer_key,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        COUNT(DISTINCT s.order_number) AS total_orders,
        RANK() OVER (ORDER BY COUNT(DISTINCT s.order_number) DESC) AS order_rank
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name
) ranked_customers
WHERE order_rank <= 5;

/*-----------------------------------------------------------------------------
-- 15. Top 3 Product Lines by Revenue
--     This query identifies the three product lines that have generated the highest total sales revenue.
--     It uses a window function (RANK) to rank product lines by their total revenue in descending order,
--     and then selects only the top three. The results include the product line name, its total revenue,
--     and its revenue rank.
-----------------------------------------------------------------------------*/
SELECT
    product_line,
    total_revenue,
    revenue_rank
FROM (
    SELECT 
        p.product_line,
        SUM(s.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(s.sales_amount) DESC) AS revenue_rank
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY p.product_line
) ranked_lines
WHERE revenue_rank <= 3;