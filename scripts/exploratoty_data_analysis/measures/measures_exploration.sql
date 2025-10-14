select * from gold.dim_customers

select * from gold.fact_sales

select * from gold.dim_products

--total sales--
select sum(sales_amount) as total_revenue from gold.fact_sales

--total quantity of goods--
select sum(quantity) as total_quantity from gold.fact_sales

---average selling price--
select avg(price) as average_selling_price from gold.fact_sales

--total number of orders--
select count(order_number) as total_orders from gold.fact_sales
SELECT count(DISTINCT order_number) AS unique_orders_count
FROM gold.fact_sales;

--total number of products--
select count(product_key) as total_products from gold.dim_products
select count(DISTINCT product_key) as total_products from gold.dim_products

--total number of customers--
select count(customer_key) as total_customers from gold.dim_customers
select count(DISTINCT customer_key) as total_customers from gold.dim_customers