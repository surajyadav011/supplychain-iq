SupplyChain IQ | Automated Analytics Pipeline
An automated, end-to-end analytics pipeline built on the DataCo Smart Supply Chain dataset (180,519 order items) using Python, MySQL, Excel, and Power BI.
A single command (`python run_pipeline.py`) cleans the raw data, executes multi-level validation checks, builds a normalized MySQL star schema, and outputs an automated Excel report.
---
📌 Executive Dashboard Overview
![Executive Summary](reports/executive_summary.png)
(3-Page Interactive Power BI Dashboard analyzing sales, profit margins, and shipping delays across global markets)
---
🎯 Key Business Findings & Impact
High Late Delivery Rate: 54.8% of total order items experienced shipping delays across all modes.
Critical Shipping Bottleneck: 100% of First Class shipments failed to meet their promised delivery window (promised 1 day, averaged ~2 days actual).
Revenue & Profitability: Analyzed $36.78M in Total Sales with an overall profit margin of 10.8% ($3.97M Total Profit).
Sales Trend Anomaly: Identified a structural drop in order line items per order after October 2017 (items per order dropped from 3.0 to ~1.0), validating that total distinct orders remained stable while line item count decreased.
---
📊 Dataset Summary
Source: DataCo Smart Supply Chain for Big Data Analysis (Kaggle)
Granularity: 1 row = 1 order item
Scale: 180,519 items | 65,752 distinct orders | 20,652 customers | 118 products
Timeframe: Jan 1, 2015 – Jan 31, 2018
---
🔄 Automated Data Pipeline Architecture
```
[Raw CSV Data] 
      │
      ▼
[python/clean.py]      --> Deduplication, Null handling, Feature engineering (is_late, delay_days)
      │
      ▼
[python/validate.py]   --> Automated schema, Null, Key, and Row-count checks
      │
      ▼
[python/load_mysql.py] --> Automated SQLAlchemy ingestion into MySQL Star Schema
      │
      ├──> [MySQL Database] (1 Fact Table + 2 Dimension Tables)
      │          └──> [15 Analytical SQL Queries (JOINs, CTEs, Window Functions)]
      │
      └──> [python/report.py] --> Automated Formatted Excel Report Generation
```
---
📐 Data Definitions & Metrics
Total Orders: Distinct count of unique order IDs (`DISTINCTCOUNT(order_id)` = 65,752).
Total Order Items: Row-level items (`COUNTROWS` = 180,519).
Late Delivery Rate: Ratio of late items against total order items (`is_late = 1 / total items` = 54.8%).
Profit Margin %: `(Total Profit / Total Sales) * 100` = 10.8%.
---
🚀 Quickstart & Execution
1. Prerequisites
Install dependencies:
```bash
pip install -r requirements.txt
```
2. Database Configuration
Run the schema setup in MySQL Workbench using `sql/01_schema.sql`.
Set your MySQL environment variable in PowerShell:
```powershell
$env:DB_PASSWORD = "your_mysql_password"
```
3. Run the Automated Pipeline
Execute the master automation script from the root directory:
```bash
cd python
python run_pipeline.py
```
---
📁 Project Structure & Files
```
supplychain-iq/
│
├── data/
│   ├── raw/                 # Unprocessed Kaggle CSV (DataCoSupplyChainDataset.csv)
│   └── clean/               # Pipeline output: Cleaned & feature-engineered CSV
│
├── python/
│   ├── config.py            # Centralized environment paths & database configuration
│   ├── clean.py             # Data cleaning, type parsing, and late flag logic
│   ├── validate.py          # Data validation suite (stops execution if checks fail)
│   ├── load_mysql.py        # SQLAlchemy loading script
│   ├── eda.py               # Exploratory data analysis & chart generation
│   ├── report.py            # Automated Excel workbook generator
│   └── run_pipeline.py      # One-command master execution script
│
├── sql/
│   ├── 01_schema.sql        # DDL scripts for Star Schema (Fact & Dimension tables)
│   ├── 02_analysis.sql      # 15 Advanced analytical queries (CTEs, Window functions)
│   └── load_checks.sql      # Data reconciliation and row-count verification queries
│
├── reports/                 # Power BI screenshots & Excel report outputs
└── requirements.txt         # Pinned Python package dependencies
```
