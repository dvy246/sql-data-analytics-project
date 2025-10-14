/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

use DataWarehouseAnalytics;
Go 


-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================

-- Customer Analytics Report
-- This query produces key customer metrics and segments customers by value and age group.

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO


CREATE VIEW gold.report_customers as
with base_customer_query as (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
    select 
        s.order_number,
        s.order_date,
        c.customer_key,
        c.customer_number,
        s.product_key,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        CONCAT(DATEDIFF(year, c.birthdate, GETDATE()), ' years') as age,
        s.sales_amount,
        s.quantity,
        c.birthdate
    from gold.fact_sales s
    left join gold.dim_customers c
    on s.product_key = c.customer_key
    where s.order_date is not null
), aggregate_customer_query as (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
    select
        customer_key,
        customer_name,
        customer_number,
        age,
        count(distinct product_key) as total_products,
        count(distinct order_number) as total_orders,
        sum(sales_amount) as total_sales,
        sum(quantity) as total_quantity,
        max(order_date) as last_order_date,
        datediff(month, min(order_date), max(order_date)) as lifespan
    from base_customer_query
    group by
        customer_key,
        customer_name,
        customer_number,
        age
)


select
    customer_key,
    customer_number,
    customer_name,
    age,
    case
        when try_cast(replace(age, ' years', '') as int) < 20 then 'below-20'
        when try_cast(replace(age, ' years', '') as int) between 20 and 40 then 'between-20-40'
        when try_cast(replace(age, ' years', '') as int) > 40 then 'above-40'
        else 'unknown'
    end as age_group,
    total_sales,
    lifespan,
    case
        when total_sales > 10000 and lifespan >= 12 then 'VIP'
        when total_sales <= 10000 and lifespan >= 12 then 'LOYAL'
        else 'NEW'
    end as customer_segment,
    datediff(month, last_order_date, getdate()) as recency,
    case
        when total_orders = 0 then 0
        else cast(round(total_sales / total_orders, 2) as bigint)
    end as avg_order_value,
    case
        when lifespan = 0 then 0
        else cast(round(total_sales / lifespan, 2) as bigint)
    end as avg_monthly_spend
from aggregate_customer_query;


-- Check all the views in the current database--
select 
    table_schema, 
    table_name 
from information_schema.views
order by table_schema, table_name;





