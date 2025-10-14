# SQL Analytics and Data Pipeline Scripts

> **Overview:**  
>  
> This document provides a comprehensive guide to the scripts housed within the `scripts` directory of the Data Warehouse Analytics project. These scripts form the backbone of the project's data engineering and analysis workflows, spanning robust data extraction processes, systematic exploratory data analysis (EDA), and sophisticated business analytics. The SQL scripts are purpose-built for the `DataWarehouseAnalytics` database, ensuring analytical operations are isolated from production systems and align with best-practice data governance.  
>  
> Use this document as a reference to quickly navigate the structure and intended use of each script collection, enhancing your workflow efficiency and analytical accuracy.

---

## Directory Structure

The scripts are organized into the following subdirectories:

- **`data_pipeline/`**: Contains scripts related to the data extraction process.
- **`exploratory_data_analysis/`**: Holds SQL scripts for initial data exploration and understanding.
- **`advanced_analytics/`**: Contains sophisticated SQL queries for deeper analysis and reporting.
- **`config/`**: Stores configuration files used by the various scripts.

---

## Detailed Breakdown

### 1. `data_pipeline`

This directory is responsible for the ETL (Extract, Transform, Load) processes of the project.

- **`extract_data.py`**: A Python script that connects to the source `DataWarehouseDB`, extracts data from the Gold Layer views of Data Warehouse , and saves it as CSV files in the `data/gold_tables` directory.

### 2. `exploratory_data_analysis`

This section contains scripts used for the initial phase of analysis, helping to understand the structure, quality, and characteristics of the data.

- **`basic/`**: Queries for fundamental database exploration, such as inspecting schemas, tables, columns, and date ranges.
- **`dimension/`**: Scripts focused on exploring the dimension tables (`dim_customers`, `dim_products`).
- **`magnitude/`**: Analysis of key business metrics, including totals and averages across different dimensions (e.g., revenue by country, customers by gender).
- **`measures/`**: Queries to calculate and explore core business measures like total sales, quantity, and unique counts.
- **`ranking/`**: Scripts that rank data based on performance, such as top-selling products, highest-revenue customers, and top-performing categories.

### 3. `advanced_analytics`

This directory houses scripts for more complex and targeted business analysis.

- **`analysis/`**: Contains sophisticated analytical queries organized by theme:
  - **`changes_over_time/`**: Analyzes trends and patterns over different time granularities (e.g., monthly, yearly).
  - **`cumulative/`**: Calculates cumulative totals for metrics like sales over time.
  - **`data_segmentation/`**: Scripts for segmenting data into meaningful groups (e.g., customer segments).
  - **`part_to_whole/`**: Queries that analyze the contribution of parts to a whole (e.g., percentage of sales by product line).
  - **`performance/`**: In-depth performance analysis of products, customers, or regions.
- **`report/`**: Contains SQL scripts designed to generate specific business reports, such as detailed customer and product performance summaries.

---

### How to Use

1.  **Run the Data Pipeline**: Execute `extract_data.py` to populate the `data/gold_tables` directory.
2.  **Load Data**: Load the CSV files into the `DataWarehouseAnalytics` database.
3.  **Execute SQL Scripts**: Run the SQL scripts from the `exploratory_data_analysis` and `advanced_analytics` directories against the `DataWarehouseAnalytics` database using your preferred SQL client.

For information on the naming conventions used in the SQL scripts, please refer to the `docs/naming_conventions.md` file.

