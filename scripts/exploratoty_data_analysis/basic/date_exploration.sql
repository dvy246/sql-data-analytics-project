USE DataWarehouseAnalytics;
GO

--checking the columns with data type date--
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE = 'date';

select birthdate from gold.dim_customers

select
 max(birthdate) as youngest_customer ,
 min(birthdate) as oldest_customer,
 DATEDIFF(YEAR,min(birthdate),max(birthdate)) as age_diff,
 AVG(DATEDIFF(YEAR,birthdate,GETDATE())) as avg_age_of_customers,
 DATEDIFF(year,min(birthdate),GETDATE()) as age_of_oldest_customer,
 DATEDIFF(year,max(birthdate),GETDATE()) as age_of_youngest_customer
  from gold.dim_customers

select * from gold.fact_sales

select min(order_date) as first_order, max(order_date) as last_order_date ,DATEDIFF(year,min(order_date),max(order_date)) as order_date_diff
from gold.fact_sales