/*****************************************************************************
 * Data Segmentation Analysis SQL Script
 *
 * Overview:
 *   This script provides SQL templates and analyses for breaking down large datasets into meaningful segments or groups based on specific attributes or criteria. 
 *   Data segmentation is essential for uncovering patterns, performance differences, or unique characteristics across customer groups, products, geographic regions, or time periods.
 *
 * Key Features:
 *   - Enables analysis at a segmented level (e.g., by customer tier, region, category, period, or other dimensions).
 *   - Supports the creation of cohorts, clusters, or custom-defined segments.
 *   - Facilitates comparison of key metrics between segments for targeted business insights.
 *
 * Use Cases:
 *   - Identifying high-value customer segments for focused marketing.
 *   - Segmenting products or services by performance, profitability, or growth trends.
 *   - Analyzing geographic regions or time-based segments to detect outliers or trends.
 *   - Cohort analyses (such as user retention by signup month or acquisition channel).
 *
 * Notes:
 *   - Update column, table, and segmentation criteria to match your data warehouse schema and business objectives.
 *   - Typical segmentation attributes include demographic fields, behavioral metrics, product attributes, and date partitions.
 *   - Extend with additional filters, subqueries, or analytic functions as needed.
 *****************************************************************************/

use Datawarehouseanalytics;

/*
 * Product Segmentation by Cost
 *
 * This query segments products based on their costs into predefined cost ranges, 
 * and counts how many products fall into each segment.
 * 
 * Cost segmentation ranges:
 *   - 'below 100'     : cost less than 100
 *   - '100-500'       : cost between 100 and 500
 *   - '500-1000'      : cost between 500 and 1000
 *   - 'above 1000'    : cost greater than 1000
 */

WITH product_segment AS (
    SELECT 
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'above 1000'
        END AS cost_range
    FROM gold.dim_products
)

SELECT 
    cost_range, 
    COUNT(product_key) AS number_of_products
FROM product_segment
GROUP BY cost_range
ORDER BY number_of_products DESC;

/*****************************************************************************
 * Customer Segmentation by Spending and Lifespan
 *
 * This segmentation categorizes customers into three groups based on:
 *   - Their total spending ("total_spending"), and
 *   - The number of months between their first and last order ("lifespan").
 *
 * Definitions:
 *   - VIP:       Customers with more than 12 months ordering history AND total spending greater than 5000.
 *   - LOYAL:     Customers with more than 12 months ordering history AND total spending less than or equal to 5000.
 *   - NEW:       All other customers not meeting the above criteria.
 *
 * Logic:
 *   - lifespan:      Calculated as the number of months between a customer's earliest and latest order.
 *   - total_spending: Sum of 'sales_amount' for each customer.
 *   - Segmentation:
 *       IF lifespan > 12 AND total_spending > 5000       => 'VIP'
 *       IF lifespan > 12 AND total_spending <= 5000      => 'LOYAL'
 *       ELSE                                             => 'NEW'
 *****************************************************************************/

WITH customer_spending AS (
    SELECT 
        c.customer_key,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        MIN(s.order_date) AS first_order_date,
        MAX(s.order_date) AS last_order_date,
        DATEDIFF(month, MIN(s.order_date), MAX(s.order_date)) AS lifespan,
        SUM(s.sales_amount) AS total_spending
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    GROUP BY c.customer_key, CONCAT(c.first_name, ' ', c.last_name)
)

SELECT 
    customer_segment,
    COUNT(DISTINCT customer_name) AS total_customers
FROM (
    SELECT 
        customer_name,
        customer_key,
        lifespan,
        total_spending,
        CASE 
            WHEN lifespan > 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan > 12 AND total_spending <= 5000 THEN 'LOYAL'
            ELSE 'NEW'
        END AS customer_segment
    FROM customer_spending
) t
GROUP BY customer_segment
ORDER BY total_customers DESC;

/* segmenting products based on their price ranges */

with products_price_quantity_report as (
        select 
        p.product_key,
        p.product_name,
        sum(s.price) as total_price,
        sum(s.quantity) as total_quantity
        from gold.fact_sales s 
        LEFT JOIN gold.dim_products p 
        on s.product_key=p.product_key
        GROUP BY p.product_key,
        p.product_name
         )

select 
    price_category,
    quantity_category,
    count(product_name) as product_count
from (
    select 
        product_name,
        case
            when total_price < avg(total_price) over () then 'Below Average Price'
            else 'Above Average Price'
        end as price_category,
        case
            when total_quantity > 100 then 'Above Normal Quantity'
            else 'Normal Quantity'
        end as quantity_category
    from products_price_quantity_report
) categorized_products
group by price_category, quantity_category
