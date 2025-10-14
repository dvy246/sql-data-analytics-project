/*****************************************************************************
 * Yearly Performance Analysis Script
 *
 * Overview:
 *   This SQL script is designed to deliver a comprehensive yearly performance analysis. 
 *   By aggregating and comparing annual metric values (such as sales, revenue, or other KPIs), 
 *   the script enables organizations to measure progress, identify trends, and evaluate their 
 *   performance over time.
 *
 * Key Features:
 *   - Aggregates key performance indicators (KPIs) at a yearly granularity.
 *   - Compares current year's results to those of previous years to highlight growth or decline.
 *   - Calculates year-over-year (YoY) absolute and percentage changes.
 *   - Uses window functions to efficiently compute trends and compare periods.
 *   - Flexible structure allows adaptation to various business domains and performance metrics.
 *
 * Use Cases:
 *   - Monitoring annual progress toward organizational goals or targets.
 *   - Identifying top-performing and underperforming products, segments, or teams by year.
 *   - Generating input data for executive dashboards and performance review meetings.
 *   - Supporting business strategy refinement and data-driven decision making.
 *
 * Notes:
 *   - Ensure that your data sources (such as fact and dimension tables) are accurate and up to date.
 *   - Modify table and column references as needed to match your organization's data model.
 *   - The script can be extended with additional dimensions (e.g., region, product) for deeper analysis.
 *
 * Example Metrics:
 *   - Sales Revenue
 *   - Units Sold
 *   - Customer Acquisition
 *   - Profit or Margin
 *
 * Result Columns (Example):
 *   - year:                  Calendar year of the analysis period.
 *   - metric_value:          Aggregated value of the selected performance metric for the year.
 *   - previous_year_value:   Value from the previous year (if available).
 *   - absolute_change:       Difference between current and previous year's metric.
 *   - percent_change:        Percentage change compared to previous year.
 *   - trend_label:           Qualitative indicator (e.g., 'growth', 'decline', 'no change').
 *
 * Usage:
 *   - Adapt this template as a starting point for year-over-year KPI analysis.
 *   - Integrate output into reporting tools or dashboards for ongoing performance tracking.
 *   - Use analysis insights to guide strategic planning, goal setting, and operational improvements.
 *****************************************************************************/


-- ============================================================================
-- Query: Yearly Sales Performance by Product
-- Description:
--   Aggregates yearly sales for each product and analyzes year-over-year changes.
--   Key metrics include current sales, previous year sales, absolute difference,
--   sales change type, average sales, deviation from average, and sales trend labels.
-- ============================================================================

WITH yearly_product_sales AS (
    SELECT 
        YEAR(s.order_date) AS year,
        p.product_name,
        SUM(s.sales_amount) AS current_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY YEAR(s.order_date), p.product_name
)
SELECT 
    year,
    product_name,
    current_sales,
    LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY year) AS previous_year_sales,
    current_sales - LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY year) AS previous_year_sales_change,
    CASE 
        WHEN current_sales - LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY year) > 0 THEN 'increase'
        WHEN current_sales - LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY year) < 0 THEN 'decrease'
        ELSE 'no change'
    END AS sales_change_type,
    AVG(current_sales) OVER (PARTITION BY product_name) AS average_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS sales_change,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'above_average'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'below_average'
        ELSE 'average'
    END AS avg_change
FROM yearly_product_sales 
ORDER BY product_name, year;


-- ============================================================================
-- Query: Yearly Quantity Sold by Product
-- Description:
--   Aggregates the quantity of products sold per year and performs year-over-year
--   comparisons of quantity sold. It computes prior year value, annual change,
--   average quantity for the product, and trends compared to prior and average.
-- ============================================================================

WITH quantity_sold_report_year AS (
    SELECT 
        p.product_name,
        YEAR(s.order_date) AS year,
        COUNT(quantity) AS total_quantity
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY p.product_name, YEAR(s.order_date)
)
SELECT 
    year,
    product_name,
    total_quantity,
    AVG(total_quantity) OVER (PARTITION BY product_name) AS avg_quantity,
    LAG(total_quantity, 1) OVER (PARTITION BY product_name ORDER BY year) AS previous_year_quantity,
    total_quantity - LAG(total_quantity, 1) OVER (PARTITION BY product_name ORDER BY year) AS quantity_change,
    CASE 
        WHEN total_quantity - LAG(total_quantity, 1) OVER (PARTITION BY product_name ORDER BY year) > 0 THEN 'increase'
        WHEN total_quantity - LAG(total_quantity, 1) OVER (PARTITION BY product_name ORDER BY year) < 0 THEN 'decrease' 
        ELSE  'no_change'
    END AS change_type,
    total_quantity - AVG(total_quantity) OVER (PARTITION BY product_name) AS change_from_avg,
    CASE 
        WHEN total_quantity - AVG(total_quantity) OVER (PARTITION BY product_name) > 0 THEN 'larger_than_avg'
        WHEN total_quantity - AVG(total_quantity) OVER (PARTITION BY product_name) < 0 THEN 'smaller_than_avg'  
        ELSE 'no_change' 
    END AS avg_change_type
FROM quantity_sold_report_year;


-- ============================================================================
-- Query: Yearly Product Cost Analysis
-- Description:
--   Calculates total annual cost per product and analyzes it versus previous years,
--   the average, and the maximum for each product. Includes difference calculations
--   and categorization for each comparison.
-- ============================================================================

WITH product_cost_report_year AS (
    SELECT 
        YEAR(s.order_date) AS year,
        p.product_name,
        SUM(p.cost) AS total_cost
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY p.product_name, YEAR(s.order_date)
)
SELECT 
    year,
    product_name,
    total_cost,
    AVG(total_cost) OVER (PARTITION BY product_name) AS avg_cost,
    LAG(total_cost, 1) OVER (PARTITION BY product_name ORDER BY year) AS previous_year_cost,
    MAX(total_cost) OVER (PARTITION BY product_name) AS max_cost,
    total_cost - AVG(total_cost) OVER (PARTITION BY product_name) AS diff_from_avg_cost,
    CASE 
        WHEN total_cost - AVG(total_cost) OVER (PARTITION BY product_name) > 0 THEN 'above_avg'
        WHEN total_cost - AVG(total_cost) OVER (PARTITION BY product_name) < 0 THEN 'below_avg'
        ELSE 'no_change'
    END AS diff_from_avg_cost_type,
    total_cost - LAG(total_cost, 1) OVER (PARTITION BY product_name ORDER BY year) AS diff_from_previous_year_cost,
    CASE 
        WHEN total_cost - LAG(total_cost, 1) OVER (PARTITION BY product_name ORDER BY year) > 0 THEN 'increase'
        WHEN total_cost - LAG(total_cost, 1) OVER (PARTITION BY product_name ORDER BY year) < 0 THEN 'decrease'
        ELSE 'no_change'
    END AS diff_from_previous_year_cost_type,
    total_cost - MAX(total_cost) OVER (PARTITION BY product_name) AS diff_from_max_cost,
    CASE 
        WHEN total_cost - MAX(total_cost) OVER (PARTITION BY product_name) > 0 THEN 'above_max'
        WHEN total_cost - MAX(total_cost) OVER (PARTITION BY product_name) < 0 THEN 'below_max'
        ELSE 'no_change'
    END AS diff_from_max_cost_type
FROM product_cost_report_year;


-- ============================================================================
-- Query: Yearly Product Price Analysis
-- Description:
--   Aggregates yearly total and average price for each product. Provides analysis
--   by comparing this value to the average yearly price, the maximum yearly price,
--   and the prior year's price, and labels each result semantically.
-- ============================================================================

WITH price_report AS (
    SELECT
        YEAR(s.order_date) AS year,
        p.product_name,
        SUM(s.price) AS total_product_price,
        AVG(s.price) AS average_product_price
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY p.product_name, YEAR(s.order_date)
)
SELECT
    year,
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

    LAG(total_product_price, 1) OVER (PARTITION BY product_name ORDER BY year) AS previous_year_price,
    total_product_price - LAG(total_product_price, 1) OVER (PARTITION BY product_name ORDER BY year) AS diff_from_previous_year_price,
    CASE
        WHEN total_product_price - LAG(total_product_price, 1) OVER (PARTITION BY product_name ORDER BY year) > 0 THEN 'increase'
        WHEN total_product_price - LAG(total_product_price, 1) OVER (PARTITION BY product_name ORDER BY year) < 0 THEN 'decrease'
        ELSE 'no_change'
    END AS diff_from_previous_year_price_status

FROM price_report;

