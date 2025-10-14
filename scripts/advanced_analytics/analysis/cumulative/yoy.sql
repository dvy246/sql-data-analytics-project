/*****************************************************************************
 * Cumulative Analysis SQL Script (YEAR OVER YEAR)
 *
 * This script provides queries for cumulative analysis, including the calculation 
 * of running totals and moving averages to track cumulative progress over time. 
 * Such metrics are essential for understanding overall performance trends, 
 * momentum, and growth within the DataWarehouseAnalytics environment.
 *****************************************************************************/
/*****************************************************************************
 * Cumulative Analysis SQL Script (YEAR OVER YEAR)
 *
 * This script provides queries for cumulative analysis, including the calculation 
 * of running totals and moving averages to track cumulative progress over time. 
 * Such metrics are essential for understanding overall performance trends, 
 * momentum, and growth within the DataWarehouseAnalytics environment on a yearly basis.
 *****************************************************************************/

USE DataWarehouseAnalytics;


/*****************************************************************************
 * Query 1: Cumulative Yearly Sales with Moving Average and Running Totals
 *
 * Description:
 *   - Calculates key sales metrics for each year, including:
 *       • Total revenue (sales_amount sum)
 *       • Total price (price sum)
 *       • Total quantity sold (quantity count)
 *       • Average sales value
 *       • Average price
 *   - Computes moving averages for sales and price to reveal trends.
 *   - Calculates running (cumulative) totals for sales, price, and quantity to track cumulative progress.
 *
 * Columns returned:
 *   - year                 : Year in 'YYYY-01-01' format (first day of each year)
 *   - total_revenue        : Sum of sales_amount for the year
 *   - total_price          : Sum of price for the year
 *   - total_quantity       : Count of quantity for the year
 *   - average_price        : Average price for the year
 *   - average_sales        : Average sales_amount for the year
 *   - moving_average_sales : Moving average of average_sales up to the year (inclusive)
 *   - moving_average_price : Moving average of average_price up to the year (inclusive)
 *   - running_total_price  : Cumulative sum of price up to the year (inclusive)
 *   - running_total_sales  : Cumulative sum of revenue up to the year (inclusive)
 *   - running_total_quantity: Cumulative sum of quantity up to the year (inclusive)
 *****************************************************************************/

WITH yearly_sales AS (
    SELECT
        DATETRUNC(year, order_date) AS year,
        YEAR(order_date) as year_number,
        SUM(sales_amount) AS total_revenue,
        AVG(price) AS average_price,
        AVG(sales_amount) AS average_sales,
        SUM(price) AS total_price,
        COUNT(quantity) AS total_quantity
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date), YEAR(order_date)
)

SELECT
    year,
    year_number,
    total_revenue,
    total_price,
    total_quantity,
    average_price,
    average_sales,
    AVG(average_sales) OVER (ORDER BY year) AS moving_average_sales,
    AVG(average_price) OVER (ORDER BY year) AS moving_average_price,
    SUM(total_price) OVER (ORDER BY year) AS running_total_price,
    SUM(total_revenue) OVER (ORDER BY year) AS running_total_sales,
    SUM(total_quantity) OVER (ORDER BY year) AS running_total_quantity
FROM yearly_sales
ORDER BY year desc,year_number desc;


/*****************************************************************************
 * Query 2: Yearly Quantity Change Analysis
 *
 * Description:
 *   - Calculates, for each year, the total quantity sold.
 *   - Computes the running total (cumulative) quantity up to each year.
 *   - Identifies the year-over-year change in quantity, categorizing as 'increase', 'decrease', or 'no change'.
 *
 * Columns returned:
 *   - year                  : Year in 'YYYY-01-01' format (first day of each year)
 *   - total_quantity        : Total quantity sold in the year
 *   - running_total_quantity: Cumulative sum of quantity up to the year
 *   - previous_quantity     : Total quantity sold in the previous year
 *   - quantity_change       : Difference in quantity from the previous year (current - previous)
 *   - quantity_change_type  : Text label indicating increase, decrease, or no change
 *****************************************************************************/

SELECT 
    year,
    total_quantity,
    SUM(total_quantity) OVER (ORDER BY year) AS running_total_quantity,
    LAG(total_quantity, 1) OVER (ORDER BY year) AS previous_quantity,
    total_quantity - LAG(total_quantity, 1) OVER (ORDER BY year) AS quantity_change,
    CASE 
        WHEN total_quantity - LAG(total_quantity, 1) OVER (ORDER BY year) > 0 THEN 'increase'
        WHEN total_quantity - LAG(total_quantity, 1) OVER (ORDER BY year) < 0 THEN 'decrease'
        ELSE 'no change' 
    END AS quantity_change_type
FROM (
    SELECT 
        DATETRUNC(year, s.order_date) AS year,
        SUM(s.quantity) AS total_quantity
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY DATETRUNC(year, s.order_date)
) t
ORDER BY year;

/*****************************************************************************
 * Query 3: Year-Over-Year Cumulative Cost Analysis
 *
 * Description:
 *   - Calculates, for each year, the total cost incurred.
 *   - Computes the running (cumulative) total cost up to each year.
 *   - Retrieves the cumulative cost value from the previous year for comparison.
 *   - Determines the year-over-year change in cumulative cost.
 *
 * Columns returned:
 *   - year                    : First day of the year in 'YYYY-01-01' format.
 *   - total_cost              : Total cost for the year.
 *   - running_total_cost      : Cumulative sum of cost from the start through the current year.
 *   - previous_cost           : Running total cost as of the previous year.
 *   - cumulative_cost_change  : Difference in cumulative cost compared to the previous year.
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
        year,
        total_cost,
        avg_cost,
        SUM(total_cost) OVER ( ORDER BY year) AS running_total_cost,
        avg(avg_cost) OVER ( ORDER BY year) AS moving_average_cost
    FROM (
        SELECT
            DATETRUNC(year, s.order_date) AS year,
            SUM(p.cost) AS total_cost,
            avg(p.cost) as avg_cost
        FROM gold.fact_sales s
        LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
        WHERE s.order_date IS NOT NULL
        GROUP BY DATETRUNC(year, s.order_date)
    ) t
)

SELECT
    year,
    total_cost,
    avg_cost,
    running_total_cost,
    moving_average_cost,
    lag(avg_cost,1) over (order by YEAR) as previous_avg_cost,
    LAG(running_total_cost, 1) OVER (ORDER BY year) AS previous_cumulative_cost,
    running_total_cost - LAG(running_total_cost, 1) OVER (ORDER BY year) AS cumulative_cost_increase,
    avg_cost - LAG(avg_cost, 1) OVER (ORDER BY year) AS avg_cost_change,
    CASE 
        WHEN avg_cost - LAG(avg_cost, 1) OVER (ORDER BY year) > 0 THEN 'increase'
        WHEN avg_cost - LAG(avg_cost, 1) OVER (ORDER BY year) < 0 THEN 'decrease'
        ELSE 'no change' 
    END avg_cost_change_type
FROM cost_table
ORDER BY year;

