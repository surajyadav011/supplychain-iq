import os
from pathlib import Path
from sqlalchemy.engine import URL

BASE_DIR = Path(__file__).resolve().parents[1]
RAW_CSV = BASE_DIR / "data" / "raw" / "DataCoSupplyChainDataset.csv"
CLEAN_CSV = BASE_DIR / "data" / "clean" / "dataco_clean.csv"
REPORT_DIR = BASE_DIR / "reports"

DB_URL = URL.create(
    "mysql+pymysql",
    username=os.getenv("DB_USER", "root"),
    password=os.getenv("DB_PASSWORD", "1234"),
    host=os.getenv("DB_HOST", "localhost"),
    port=3306,
    database=os.getenv("DB_NAME", "supplychain_iq"),
)
