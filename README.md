# 📊 SQL Data Analytics Project

## 🚀 Project Overview

This project provides a comprehensive framework for analyzing and deriving actionable insights from a structured dataset using SQL. The analysis is divided into two main phases:

1.  **Exploratory Data Analysis (EDA)**: The initial phase focuses on understanding the fundamental characteristics of the data. This includes exploring the database schema, examining dimensions and dates, analyzing key measures, understanding data magnitudes, and identifying top/bottom performers through ranking.
2.  **Advanced Analytics**: Building on the EDA, this phase employs more complex analytical techniques to uncover deeper insights. These include analyzing change-over-time trends, performing cumulative and performance analysis, assessing part-to-whole relationships, and segmenting data for targeted insights.

The ultimate goal is to create a clear, data-driven narrative that can inform strategic business decisions and be presented through reports and dashboards.

## 📁 Project Structure

/*
---------------------------------------------------------
|                 PROJECT STRUCTURE WHITEBOARD           |
---------------------------------------------------------
|  data/                |  - Data extraction scripts     |
|                       |  - Output CSV files           |
|-----------------------|-------------------------------|
|  database/            |  - DB backups                 |
|                       |  - Schemas                    |
|                       |  - Initialization scripts     |
|-----------------------|-------------------------------|
|  docs/                |  - Analysis reports           |
|                       |  - Diagrams (e.g., flowcharts)|
|                       |  - Methodology docs           |
|-----------------------|-------------------------------|
|  scripts/             |  - All analysis scripts       |
|    ├─ eda/            |    - EDA SQL scripts          |
|    └─ advanced_analysis/ | - Advanced analytics SQL    |
|-----------------------|-------------------------------|
|  notebooks/           |  - (Optional) Jupyter         |
|                       |    notebooks for exploration  |
|-----------------------|-------------------------------|
|  tests/               |  - (Optional) Data validation |
|                       |    and unit test scripts      |
|-----------------------|-------------------------------|
|  requirements.txt     |  - Python dependencies list   |
|-----------------------|-------------------------------|
|  README.md            |  - Project overview & guide   |
---------------------------------------------------------
*/

## 🔍 Exploratory Data Analysis (EDA)

The EDA process is the foundation of our analysis, designed to systematically explore the dataset from multiple angles. The SQL scripts for each step are located in the `scripts/eda/` directory.

-   **Database Exploration**:
    -   `database_exploration.sql`: Queries to understand the database schema, tables, columns, data types, and relationships between entities.

-   **Dimensions Exploration**:
    -   `dim_exploration.sql`: Analysis of dimensional tables (e.g., customers, products) to understand their attributes, distributions, and unique values.

-   **Date Exploration**:
    -   `date_exploration.sql`: Queries focused on the temporal aspects of the data, such as the range of dates, seasonality, and time-based patterns.

-   **Measures Exploration**:
    -   `measures_exploration.sql`: Initial analysis of key numeric fields (e.g., sales amount, quantity) to understand their basic statistics (mean, median, min, max).

-   **Magnitude Analysis**:
    -   `magnitude_analysis.sql`: Queries to gauge the scale and distribution of important measures, helping to identify outliers and understand the overall data landscape.

-   **Ranking Analysis**:
    -   `ranking_analysis.sql`: Scripts to rank data based on key metrics, identifying Top N and Bottom N performers (e.g., top-selling products, least active customers).

---

## 📈 Advanced Analytics

This section leverages the insights from EDA to perform more sophisticated analyses. The scripts are located in the `scripts/advanced_analysis/` directory.

-   **Change-Over-Time Trends**: Analyzing how key metrics evolve over time (e.g., month-over-month sales growth).
-   **Cumulative Analysis**: Calculating running totals and cumulative values (e.g., cumulative sales over a year).
-   **Performance Analysis**: Comparing performance across different segments or against predefined targets and benchmarks.
-   **Part-to-Whole/Proportional Analysis**: Examining the contribution of different segments to the total (e.g., sales percentage per product category).
-   **Data Segmentation**: Grouping data into distinct segments based on shared characteristics (e.g., customer segmentation by purchasing behavior).
-   **Reporting/Dashboarding**: Queries designed to feed directly into reports and dashboards, summarizing key findings in an easily digestible format.

---

## 🛠️ Installation and Setup

To get the project up and running on your local machine, follow these steps:

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/your-username/sql-data-analytics-project.git
    cd sql-data-analytics-project
    ```

2.  **Install Dependencies**:
    If there are any Python scripts, install the required libraries from `requirements.txt`.
    ```bash
    pip install -r requirements.txt
    ```

3.  **Set Up the Database**:
    -   Ensure you have a running SQL Server instance.
    -   Restore the database using the backup file located in `database/backup/`. Refer to your database client's documentation for instructions on how to restore from a `.bak` or `.sql` file.

4.  **Run Analytics Scripts**:
    -   Connect to the newly restored database using your preferred SQL client.
    -   Open and execute the scripts in the `scripts/eda/` and `scripts/advanced_analysis/` directories to perform the analysis.

---

## 🚀 Usage

To use this project for analysis:

-   **Follow the prescribed order**: Start with the EDA scripts in `scripts/eda/` to build a foundational understanding of the data.
-   **Proceed to Advanced Analytics**: Use the scripts in `scripts/advanced_analysis/` to explore more complex questions and generate deeper insights.
-   **Customize and Extend**: Modify the existing queries or add new scripts to investigate your own specific hypotheses.

### Sample Output

You can expect the output of these scripts to be tabular data, which can then be exported or used to create visualizations. For visual workflows and diagrams, refer to the `docs/` directory.

---

## 🎨 Visuals

For a high-level illustration of the analytics workflow and data flow within this project, please see the `project_flow.png` diagram located in the `docs/` directory.

![Project Flow](docs/project_flow.png)

---

## 🙌 Contributing

We welcome contributions to this project! If you'd like to contribute, please follow these steps:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/your-feature-name`).
3.  Make your changes and commit them (`git commit -m 'Add some feature'`).
4.  Push to the branch (`git push origin feature/your-feature-name`).
5.  Open a Pull Request.

Please ensure your code adheres to the project's naming conventions and includes appropriate documentation.

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

### Install Dependencies

If there are any Python scripts, install the required libraries from `requirements.txt`
