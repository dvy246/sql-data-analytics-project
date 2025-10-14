/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

use DataWarehouseAnalytics;
go

select top(100)* from gold.dim_products

if OBJECT_ID('gold.report_products','V') is not null 
       drop view gold.report_products
GO
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================

/*---------------------------------------------------------------------------
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
CREATE VIEW gold.report_products as
with base_products_query as (
    select 
        s.order_date,
        s.customer_key,
        s.order_number,
        s.product_key,
        p.product_number,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        s.sales_amount,
        s.quantity
    from gold.fact_sales s
    left join gold.dim_products p
        on s.product_key = p.product_key
    where s.order_date is not null
)
, aggregation_products_query as (
    select 
        product_key,
        product_number,
        product_name,
        category,
        subcategory,
        sum(quantity) as total_quantity,
        sum(sales_amount) as total_sales,
        count(distinct customer_key) as total_customers,
        max(order_date) as last_order_date,
        count(distinct order_number) as total_orders,
        datediff(month, min(order_date), max(order_date)) as lifespan,
        avg(cast(sales_amount as float) / nullif(quantity,0)) as average_selling_price
    from base_products_query
    group by product_key, product_number, product_name, category, subcategory
)


/*---------------------------------------------------------------------------
2) Segmenting Query Documentation:
   The following (not shown here) segmenting query is used to enhance product profiling by splitting products into meaningful segments based on performance or attributes.
   Typical segmentation criteria may include:
     - Sales volume (e.g., low, medium, high)
     - Product category or subcategory
     - Customer engagement (unique customers, repeat purchases)
     - Product lifecycle or recency of last order
     - Revenue contribution (Pareto principle: top 20% products generating 80% sales)
   Purpose:
     - Enable advanced analytics and reporting on product groups
     - Support targeted marketing and inventory decisions
   NOTE: Adjust segmenting logic to specific business requirements as needed.
---------------------------------------------------------------------------*/

select 
    product_key,
    product_number,
    product_name,
    category,
    subcategory,
    total_quantity,
    total_sales,
    CASE 
        WHEN total_sales > 50000  THEN 'high_performer'
        WHEN total_sales<=10000 THEN 'Mid-Range'
        ELSE 'low_performer'
    END as performance_segment,
    CASE 
        WHEN total_quantity > avg(total_quantity) over () THEN 'above_average_quantity_sold' 
        ELSE  'below_average_quantity_sold'
    END as quantity_segment,
    lifespan,
    total_orders,
    total_customers,
    CAST(average_selling_price AS BIGINT) as avg_selling_price,
    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,
    -- Average Monthly Revenue(AMR)
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue,
    CONCAT(DATEDIFF(month, last_order_date, getdate()), ' months') as recency
from aggregation_products_query


-- Check all the views in the current database--
select 
    table_schema, 
    table_name 
from information_schema.views
order by table_schema, table_name;