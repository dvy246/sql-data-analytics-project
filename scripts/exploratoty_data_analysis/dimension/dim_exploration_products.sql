USE DataWarehouseAnalytics;
GO

--checking table data types--
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('dim_products')

SELECT top(100) * FROM gold.dim_products;

select DISTINCT product_name,category,subcategory,product_line from gold.dim_products ORDER BY 1,2,3,4