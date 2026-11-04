# SupplyChain IQ

Analysis of late deliveries, sales and profit in the DataCo Smart Supply Chain dataset from Kaggle,
using Python, MySQL, Excel and Power BI. This is a personal portfolio project built on public data.

## Dataset
DataCo SMART SUPPLY CHAIN FOR BIG DATA ANALYSIS (Kaggle). One row is one order item:
180,519 rows, 65,752 orders, 20,652 customers, 118 products, orders from 2015-01-01 to 2018-01-31.
Put DataCoSupplyChainDataset.csv in data/raw/ (the data folders are not uploaded to GitHub).

## Pipeline
raw CSV -> clean.py -> validate.py -> load_mysql.py -> MySQL (1 fact table, 2 dimension tables)
-> SQL queries, Excel report, Power BI

## Definitions
- Late % = late items divided by delivered items. Items with "Shipping canceled" are excluded.
- Profit = the benefit_per_order column. Sales = sales before discount.

## How to run
1. pip install -r requirements.txt
2. Run sql/01_schema.sql in MySQL Workbench
3. Set the database password: $env:DB_PASSWORD = "your_password" (PowerShell)
4. cd python, then python run_pipeline.py

## Files
- python/config.py: paths and database login
- python/clean.py: cleans the raw CSV
- python/validate.py: data quality checks
- python/load_mysql.py: loads the three tables
- python/eda.py: charts
- python/report.py: Excel report from SQL
- python/run_pipeline.py: runs all steps
- sql/00_basics.sql: SQL basics examples
- sql/01_schema.sql: tables
- sql/02_analysis.sql: analysis queries
- sql/03_practice.sql: practice queries
- sql/load_checks.sql: checks after loading
