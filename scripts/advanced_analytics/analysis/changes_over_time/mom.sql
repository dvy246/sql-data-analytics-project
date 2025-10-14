/*****************************************************************************
 * Changes Over Time Analysis SQL Script(Monthly)
 *
 * This script provides a series of analytical queries to evaluate changes and trends
 * in key business metrics over time, with time measured at the date level.
 * Analysts can use this script to examine variations in revenue, sales volume,
 * and other relevant measures across different date ranges, enabling the identification
 * of patterns, seasonality, and growth over time within the DataWarehouseAnalytics environment.
 *
 * All queries are organized to be clear and actionable for data analysts and business users.
 *****************************************************************************/

USE DataWarehouseAnalytics;
GO

/*****************************************************************************
 * Query 1: Preview fact_sales Table  
 * Returns the first 100 rows of the gold.fact_sales table for exploratory analysis
 * and to provide an overview of the data structure.
 *****************************************************************************/
SELECT TOP (100) *
FROM gold.fact_sales;


/*****************************************************************************
 * Query 2: Daily Revenue Reporting
 * Retrieves all records with non-null order dates, displaying the order_date
 * and the corresponding sales_amount. Useful for analyzing revenue on a day-to-day
 * basis to observe trends or detect anomalies.
 *****************************************************************************/
SELECT
    order_date,
    sales_amount
FROM gold.fact_sales
WHERE order_date IS NOT NULL
ORDER BY order_date;


/*****************************************************************************
 * Query 3: Monthly Revenue Aggregation
 * Aggregates total revenue by calendar month (across all years).
 * Provides a high-level view of sales seasonality and cyclical patterns.
 *****************************************************************************/
SELECT
    MONTH(order_date) AS month,
    SUM(sales_amount) AS total_revenue
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);


/*****************************************************************************
 * Query 4: Revenue by Month-Year
 * Sums total revenue for each individual year-month combination using DATETRUNC.
 * This allows for trend analysis over time, not just cyclical monthly patterns.
 *****************************************************************************/
SELECT
    DATETRUNC(month, order_date) AS date,
    MONTH(order_date) AS month,
    SUM(sales_amount) AS total_revenue
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date), MONTH(order_date)
ORDER BY total_revenue DESC;


/*****************************************************************************
 * Query 5: Top 5 Months by Sales Quantity
 * Identifies the top 5 months (month-year) with the highest number of quantity sold.
 * Includes both total sales price and total sales quantity for comprehensive analysis.
 *****************************************************************************/
SELECT TOP 5
    DATETRUNC(month, order_date) AS date,
    MONTH(order_date) AS month,
    SUM(price) AS total_price,
    COUNT(quantity) AS total_quantity
FROM gold.fact_sales
GROUP BY DATETRUNC(month, order_date), MONTH(order_date)
HAVING DATETRUNC(month, order_date) IS NOT NULL
ORDER BY COUNT(quantity) DESC;


/*****************************************************************************
 * Query 6: Top 5 Months by Sales Price
 * Retrieves the top 5 months with the highest total sales price (revenue), alongside
 * quantity sold. Useful for understanding peak revenue periods.
 *****************************************************************************/
SELECT TOP 5
    DATETRUNC(month, order_date) AS date,
    MONTH(order_date) AS month,
    SUM(price) AS total_price,
    COUNT(quantity) AS total_quantity
FROM gold.fact_sales
GROUP BY DATETRUNC(month, order_date), MONTH(order_date)
HAVING DATETRUNC(month, order_date) IS NOT NULL
ORDER BY SUM(price) DESC, COUNT(quantity) DESC;


/*****************************************************************************
 * Query 7: Top 5 Revenue Months with Customer Counts
 * For each month-year, calculates total revenue, counts of unique customers, and
 * ranks months based on revenue. Returns the top 5 months by revenue.
 * Useful for correlating revenue surges with customer engagement.
 *****************************************************************************/
SELECT *
FROM (
    SELECT
        DATETRUNC(month, order_date) AS date,
        MONTH(order_date) AS month,
        SUM(sales_amount) AS total_revenue,
        COUNT(DISTINCT customer_key) AS total_customers,
        RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS rank_revenue
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date), MONTH(order_date)
) t
WHERE rank_revenue <= 5;


/*****************************************************************************
 * Query 8: Top 5 Months by Shipping Date Revenue
 * Similar to Query 7, but aggregates by shipping_date instead of order_date.
 * Highlights revenue and unique customer counts for top shipping months, ordered by total revenue.
 *****************************************************************************/
SELECT *
FROM (
    SELECT
        DATETRUNC(month, shipping_date) AS ship_date,
        MONTH(shipping_date) AS month,
        SUM(sales_amount) AS total_revenue,
        COUNT(DISTINCT customer_key) AS total_customers,
        RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS rank_revenue
    FROM gold.fact_sales
    WHERE shipping_date IS NOT NULL
    GROUP BY DATETRUNC(month, shipping_date), MONTH(shipping_date)
) t
WHERE rank_revenue <= 5
ORDER BY total_revenue DESC;

