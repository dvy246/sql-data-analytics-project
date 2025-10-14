"""
===============================================================================
extract_data.py

Purpose:
--------
This script connects to a SQL Server instance (e.g., running in Docker) and 
extracts data from specified Gold Layer  views. The extracted data 
is exported as CSV files for use in Exploratory Data Analysis (EDA) or 
downstream analytics.

Key Features:
-------------
- Connects to a SQL Server database using SQLAlchemy and ODBC.
- Extracts data from a configurable list of Gold Layer tables/views.
- Exports each table/view as a CSV file to a designated output directory.
- Handles large tables by reading and writing in chunks.
- Provides informative logging and error handling.

Configuration:
--------------
- Update the SQL_SERVER, SQL_DATABASE, SQL_USERNAME, SQL_PASSWORD, and SQL_PORT 
  variables as needed for your environment.
- Modify the GOLD_VIEWS list to include the tables/views you wish to export.

Output:
-------
- CSV files are saved in the 'data/gold_tables' directory, one per table/view.

===============================================================================
"""

import pandas as pd
from sqlalchemy import create_engine
import os
import urllib
import logging
from dotenv import load_dotenv
import sys
from scripts.config import load_yaml_config

load_dotenv()
# --- Logging Setup ---
LOG_FORMAT = "%(asctime)s %(levelname)s [%(name)s] %(message)s"
logging.basicConfig(
    level=logging.INFO,
    format=LOG_FORMAT,
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler("extract_data.log", mode="a")
    ]
)
logger = logging.getLogger("extract_data")

settings=load_yaml_config()

db_config = settings['database']
# --- Configuration: Update these values for your environment ---
SQL_SERVER = db_config['server']
SQL_DATABASE = db_config['database_name']
SQL_USERNAME = db_config['username']
SQL_PASSWORD = os.getenv(db_config['password_env_var']) # Load password using env var from config
SQL_PORT = db_config['port']
# List of Gold Layer tables/views to extract
GOLD_VIEWS = [
    "gold.dim_customers", 
    "gold.dim_products", 
    "gold.fact_sales"
]

# --- SQL Connection Setup ---
# URL-encode the connection string for ODBC Driver 17 for SQL Server
params = urllib.parse.quote_plus(
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={SQL_SERVER},{SQL_PORT};"
    f"DATABASE={SQL_DATABASE};"
    f"UID={SQL_USERNAME};"
    f"PWD={SQL_PASSWORD}"
)

# Create the SQLAlchemy engine for database connection
try:
    engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")
    logger.info("Successfully created SQLAlchemy engine.")
except Exception as e:
    logger.critical(f"Error creating SQLAlchemy engine: {e}", exc_info=True)
    sys.exit(1)

extraction=settings['data_extraction']

# --- Output Directory Setup ---
output_directory = extraction['output_directory']
chunk_size=extraction['chunk_size']

try:
    os.makedirs(output_directory, exist_ok=True)
    logger.info(f"Output directory ready at: {output_directory}")
except Exception as e:
    logger.critical(f"Failed to create output directory {output_directory}: {e}", exc_info=True)
    sys.exit(1)

# --- Data Extraction and Export ---
logger.info("Starting extraction of Gold Layer tables/views...")

# --- fetching each table rows in chunks and converting it to csv and saving it to output directory ---
for view_name in GOLD_VIEWS:
    logger.info(f"Processing table/view: {view_name}")
    query = f"SELECT * FROM {view_name}"
    try:
        total_rows = 0
        # chunks to handle large tables efficiently
        for i, chunk in enumerate(pd.read_sql(query, engine, chunksize=chunk_size)):
            csv_path = os.path.join(output_directory, f"{view_name}.csv")
            write_header = not os.path.exists(csv_path) or i == 0
            chunk.to_csv(
                path=csv_path,
                index=False,
                header=write_header,
                mode='w' if i == 0 else 'a'
            )
            total_rows += len(chunk)
            logger.debug(f"Processed chunk {i+1} of {view_name}: {len(chunk)} rows")
        logger.info(f"Success! Extracted {total_rows} rows from {view_name}")
    except Exception as e:
        logger.error(f"ERROR extracting {view_name}: {e}", exc_info=True)

logger.info("Extraction process complete.")

