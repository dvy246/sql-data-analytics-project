import pandas as pd
from sqlalchemy import create_engine
import os
import urllib

# --- Configuration (Replace with your Docker/SQL Server details) ---
SQL_SERVER = "localhost"
SQL_DATABASE = "DataWarehouseDB"
SQL_USERNAME = "SA" 
SQL_PASSWORD = "admin@1234" 
SQL_PORT = 1433

# List of all Gold Layer views you need for EDA
GOLD_VIEWS = [
    "gold.dim_customers", 
    "gold.dim_products", 
    "gold.fact_sales"
]

# --- SQL Connection Setup ---
# 1. URL-encode the password
params = urllib.parse.quote_plus(
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={SQL_SERVER},{SQL_PORT};"
    f"DATABASE={SQL_DATABASE};"
    f"UID={SQL_USERNAME};"
    f"PWD={SQL_PASSWORD}"
)
# 2. Create the SQLAlchemy Engine
try:
    engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")
except Exception as e:
    print(f"Error creating engine: {e}")
    exit()

base_dir = 'data'
output_directory = os.path.join(base_dir, 'gold_tables')
os.makedirs(output_directory, exist_ok=True)
print(f"Output directory ready at: {output_directory}")

# --- Data Extraction and Export Loop ---
print("Starting extraction of Gold Layer views...")

for view_name in GOLD_VIEWS:
    print(f"\nProcessing view: {view_name}")
    # Define the SQL query (SELECT * works on views and tables)
    query = f"SELECT * FROM {view_name}" 
    try:
        total_rows=0
        for i,csv in enumerate(pd.read_sql(query, engine,chunksize=10000)):
            csv.to_csv(path=os.path.join(output_directory,f"{view_name}.csv"),index=False)
            total_rows+=len(csv)
        print(f"-> Success! Extracted {total_rows} rows from {view_name}")
        print("\nExtraction process complete.")
    except Exception as e:
        print(f"-> ERROR extracting {view_name}: {e}")

