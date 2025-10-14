/*
===============================================================================
DataWarehouseAnalytics - Database Exploration Script
===============================================================================

Purpose:
--------
This script provides a comprehensive set of queries for exploring the 
structure and metadata of the 'DataWarehouseAnalytics' SQL Server database. 
It is intended for use during exploratory data analysis (EDA), data 
engineering, or database administration to gain insights into the database 
objects, schemas, columns, data types, constraints, and indexes.

Sections:
---------
1. Switch to the target database.
2. List all databases on the server.
3. List all tables and views in the current database.
4. Inspect columns and metadata for key tables.
5. Review data types for each column in key tables.
6. Examine constraints applied to key tables.
7. List indexes defined on key tables.

Instructions:
-------------
- Execute each section as needed in your SQL client (e.g., Azure Data Studio, SSMS).
- Update table names if you wish to explore additional tables.

===============================================================================
*/

/* 1. Switch to the target database */
USE DataWarehouseAnalytics;
GO

/* 2. List all databases on the server */
SELECT name AS database_name
FROM sys.databases;
GO

/* 3. List all tables and views in the current database */
SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA, TABLE_NAME;
GO

/* 4. Inspect columns and metadata for key tables */
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'dim_customers';

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'dim_products';

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'fact_sales';
GO

/* 5. Review data types for each column in key tables */
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('dim_customers', 'dim_products', 'fact_sales')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO

/* 6. Examine constraints applied to key tables */
SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
WHERE TABLE_NAME IN ('dim_customers', 'dim_products', 'fact_sales')
ORDER BY TABLE_NAME, CONSTRAINT_NAME;
GO

/* 7. List indexes defined on key tables */
SELECT OBJECT_NAME(i.object_id) AS table_name, i.name AS index_name, i.type_desc, i.is_primary_key, i.is_unique
FROM sys.indexes i
WHERE i.object_id IN (
    OBJECT_ID('gold.dim_customers'),
    OBJECT_ID('gold.dim_products'),
    OBJECT_ID('gold.fact_sales')
)
ORDER BY table_name, index_name;
GO

/*
===============================================================================
End of Database Exploration Script
===============================================================================
*/