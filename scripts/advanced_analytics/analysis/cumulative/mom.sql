/*****************************************************************************
 * Cumulative Analysis SQL Script (MONTH OVER MONTH)
 *
 * This script provides queries for cumulative analysis, including the calculation 
 * of running totals and moving averages to track cumulative progress over time. 
 * Such metrics are essential for understanding overall performance trends, 
 * momentum, and growth within the DataWarehouseAnalytics environment.
 *****************************************************************************/

USE DataWarehouseAnalytics;


/*****************************************************************************
 * Query 1: Cumulative Monthly Sales with Moving Average and Running Totals
 *
 * Description:
 *   - Calculates key sales metrics for each month, including:
 *       • Total revenue (sales_amount sum)
 *       • Total price (price sum)
 *       • Total quantity sold (quantity count)
 *       • Average sales value
 *       • Average price
 *   - Computes moving averages for sales and price to reveal trends.
 *   - Calculates running (cumulative) totals for sales, price, and quantity to track cumulative progress.
 *
 * Columns returned:
 *   - month                : Month in 'YYYY-MM-01' format (first day of each month)
 *   - total_revenue        : Sum of sales_amount for the month
 *   - total_price          : Sum of price for the month
 *   - total_quantity       : Count of quantity for the month
 *   - average_price        : Average price for the month
 *   - average_sales        : Average sales_amount for the month
 *   - moving_average_sales : Moving average of average_sales up to the month (inclusive)
 *   - moving_average_price : Moving average of average_price up to the month (inclusive)
 *   - running_total_price  : Cumulative sum of price up to the month (inclusive)
 *   - running_total_sales  : Cumulative sum of revenue up to the month (inclusive)
 *   - running_total_quantity: Cumulative sum of quantity up to the month (inclusive)
 *****************************************************************************/

WITH monthly_sales AS (
    SELECT
        DATETRUNC(month, order_date) AS month,
        MONTH(order_date) as month_number,
        SUM(sales_amount) AS total_revenue,
        AVG(price) AS average_price,
        AVG(sales_amount) AS average_sales,
        SUM(price) AS total_price,
        COUNT(quantity) AS total_quantity
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date), MONTH(order_date) 
)

SELECT
    month,
    month_number
    total_revenue,
    total_price,
    total_quantity,
    average_price,
    average_sales,
    AVG(average_sales) OVER (ORDER BY month) AS moving_average_sales,
    AVG(average_price) OVER (ORDER BY month) AS moving_average_price,
    SUM(total_price) OVER (ORDER BY month) AS running_total_price,
    SUM(total_revenue) OVER (ORDER BY month) AS running_total_sales,
    SUM(total_quantity) OVER (ORDER BY month) AS running_total_quantity
FROM monthly_sales;


/*****************************************************************************
 * Query 2: Monthly Quantity Change Analysis
 *
 * Description:
 *   - Calculates, for each month, the total quantity sold.
 *   - Computes the running total (cumulative) quantity up to each month.
 *   - Identifies the month-over-month change in quantity, categorizing as 'increase', 'decrease', or 'no change'.
 *
 * Columns returned:
 *   - month                 : Month in 'YYYY-MM-01' format (first day of each month)
 *   - total_quantity        : Total quantity sold in the month
 *   - running_total_quantity: Cumulative sum of quantity up to the month
 *   - previous_quantity     : Total quantity sold in the previous month
 *   - quantity_change       : Difference in quantity from the previous month (current - previous)
 *   - quantity_change_type  : Text label indicating increase, decrease, or no change
 *****************************************************************************/

SELECT 
    month,
    month_number,
    total_quantity,
    SUM(total_quantity) OVER (ORDER BY month) AS running_total_quantity,
    LAG(total_quantity, 1) OVER (ORDER BY month) AS previous_quantity,
    total_quantity - LAG(total_quantity, 1) OVER (ORDER BY month) AS quantity_change,
    CASE 
        WHEN total_quantity - LAG(total_quantity, 1) OVER (ORDER BY month) > 0 THEN 'increase'
        WHEN total_quantity - LAG(total_quantity, 1) OVER (ORDER BY month) < 0 THEN 'decrease'
        ELSE 'no change' 
    END AS quantity_change_type
FROM (
    SELECT 
        DATETRUNC(month, s.order_date) AS month,
        MONTH(order_date) as month_number,
        SUM(s.quantity) AS total_quantity
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY DATETRUNC(month, s.order_date),MONTH(order_date)
) t;

/*****************************************************************************
 * Query 3: Month-Over-Month Cumulative Cost Analysis
 *
 * Description:
 *   - Calculates, for each month, the total cost incurred.
 *   - Computes the running (cumulative) total cost up to each month.
 *   - Retrieves the cumulative cost value from the previous month for comparison.
 *   - Determines the month-over-month change in cumulative cost.
 *
 * Columns returned:
 *   - month                   : First day of the month in 'YYYY-MM-01' format.
 *   - total_cost              : Total cost for the month.
 *   - running_total_cost      : Cumulative sum of cost from the start through the current month.
 *   - previous_cost           : Running total cost as of the previous month.
 *   - cumulative_cost_change  : Difference in cumulative cost compared to the previous month.
 *
 * Data Source:
 *   - gold.fact_sales: Fact table containing sales transactions.
 *   - gold.dim_products: Dimension table containing product cost information.
 *
 * Usage:
 *   - Use this query to monitor trends in cost accumulation and assess cost growth over time.
 *****************************************************************************/

WITH cost_table AS (
    SELECT
        month,
        month_number,
        total_cost,
        avg_cost,
        SUM(total_cost) OVER ( ORDER BY month) AS running_total_cost,
        AVG(avg_cost) OVER ( ORDER BY month) AS moving_average_cost
    FROM (
        SELECT
            DATETRUNC(month, s.order_date) AS month,
            SUM(p.cost) AS total_cost,
            avg(p.cost) as avg_cost,
            MONTH(order_date) as month_number
        FROM gold.fact_sales s
        LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
        WHERE s.order_date IS NOT NULL
        GROUP BY DATETRUNC(month, s.order_date),MONTH(order_date)
    ) t
)

SELECT
    month,
    month_number,
    total_cost,
    avg_cost,
    running_total_cost,
    moving_average_cost,
    LAG(running_total_cost, 1) OVER (ORDER BY month) AS previous_cost,
    running_total_cost - LAG(running_total_cost, 1) OVER (ORDER BY month) AS cumulative_cost_change
FROM cost_table;
