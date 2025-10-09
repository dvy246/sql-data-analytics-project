/*
=============================================================
DataWarehouseAnalytics Setup Script
=============================================================
Purpose:
- Create a new database 'DataWarehouseAnalytics' (drops existing one)
- Create schema 'gold'
- Create dimension and fact tables
- Load CSV data from Docker-mounted folder
=============================================================
WARNING:
Running this script will drop the database if it exists.
All data will be permanently deleted. Ensure backups before running.
*/

USE master;
GO

-- Drop existing database safely
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create new database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
BEGIN
    EXEC('CREATE SCHEMA gold');
END;
GO

-- -----------------------------
-- Create Tables
-- -----------------------------
CREATE TABLE gold.dim_customers(
    customer_key int,
    customer_id int,
    customer_number nvarchar(50),
    first_name nvarchar(50),
    last_name nvarchar(50),
    country nvarchar(50),
    marital_status nvarchar(50),
    gender nvarchar(50),
    birthdate date,
    create_date date
);
GO

CREATE TABLE gold.dim_products(
    product_key int,
    product_id int,
    product_number nvarchar(50),
    product_name nvarchar(50),
    category_id nvarchar(50),
    category nvarchar(50),
    subcategory nvarchar(50),
    maintenance nvarchar(50),
    cost int,
    product_line nvarchar(50),
    start_date date
);
GO

CREATE TABLE gold.fact_sales(
    order_number nvarchar(50),
    product_key int,
    customer_key int,
    order_date date,
    shipping_date date,
    due_date date,
    sales_amount int,
    quantity tinyint,
    price int
);
GO

-- -----------------------------
-- Load CSV data
-- -----------------------------

-- Customers
BEGIN TRY
    TRUNCATE TABLE gold.dim_customers;

    BULK INSERT gold.dim_customers
    FROM '/var/opt/mssql/data/gold_dim_customers_eda.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );
    PRINT 'dim_customers loaded successfully!';
END TRY
BEGIN CATCH
    PRINT 'Error loading dim_customers';
END CATCH;
GO

-- Products
BEGIN TRY
    TRUNCATE TABLE gold.dim_products;

    BULK INSERT gold.dim_products
    FROM '/var/opt/mssql/data/gold_dim_products_eda.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );
    PRINT 'dim_products loaded successfully!';
END TRY
BEGIN CATCH
    PRINT 'Error loading dim_products';
END CATCH;
GO

-- Fact Sales
BEGIN TRY
    TRUNCATE TABLE gold.fact_sales;

    BULK INSERT gold.fact_sales
    FROM '/var/opt/mssql/data/gold_fact_sales_eda.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );
    PRINT 'fact_sales loaded successfully!';
END TRY
BEGIN CATCH
    PRINT 'Error loading fact_sales';
END CATCH;
GO

PRINT 'All tables loaded successfully!';

BACKUP DATABASE [DataWarehouseAnalytics]
TO DISK = N'/var/opt/mssql/backup/DataWarehouseAnalytics.bak'
WITH FORMAT, INIT, NAME = 'Full Backup of DataWarehouseAnalytics';
GO

--to save the backup of ur database '''
--docker cp sql2022:/var/opt/mssql/DataWarehouseAnalytics.bak s.


SELECT name FROM sys.databases;
GO
