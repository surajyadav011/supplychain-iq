from sqlalchemy import create_engine, text
from config import DB_URL

CUSTOMER_COLS = ["customer_id", "customer_segment", "customer_city",
                 "customer_state", "customer_country"]
PRODUCT_COLS = ["product_card_id", "product_name", "product_price", "category_id",
                "category_name", "department_id", "department_name"]
FACT_RENAME = {
    "product_card_id": "product_id",
    "type": "payment_type",
    "days_for_shipping_real": "days_real",
    "days_for_shipment_scheduled": "days_scheduled",
    "order_item_discount": "discount",
    "order_item_discount_rate": "discount_rate",
    "order_item_quantity": "quantity",
    "benefit_per_order": "profit",
    "order_item_profit_ratio": "profit_ratio",
}
FACT_COLS = [
    "order_item_id", "order_id", "customer_id", "product_id", "order_date",
    "shipping_date", "order_status", "payment_type", "shipping_mode",
    "delivery_status", "late_delivery_risk", "days_scheduled", "days_real",
    "delay_days", "is_late", "is_loss", "market", "order_region", "order_country",
    "order_city", "order_state", "quantity", "sales", "discount", "discount_rate",
    "order_item_total", "profit", "profit_ratio",
]


def build_tables(df):
    dim_customer = df[CUSTOMER_COLS].drop_duplicates("customer_id")
    dim_product = (df[PRODUCT_COLS].drop_duplicates("product_card_id")
                   .rename(columns={"product_card_id": "product_id"}))
    fact = df.rename(columns=FACT_RENAME)[FACT_COLS]
    return dim_customer, dim_product, fact


def load(df):
    engine = create_engine(DB_URL)
    names = ["dim_customer", "dim_product", "fact_order_items"]
    tables = build_tables(df)

    # Clear old rows so the script can run again. Fact goes first (foreign keys).
    with engine.begin() as conn:
        for name in reversed(names):
            conn.execute(text(f"DELETE FROM {name}"))

    for name, table in zip(names, tables):
        table.to_sql(name, engine, if_exists="append", index=False,
                     chunksize=5000, method="multi")
        print(f"Loaded {name}: {len(table)} rows")

    with engine.connect() as conn:
        count = conn.execute(text("SELECT COUNT(*) FROM fact_order_items")).scalar()
    assert count == len(tables[2]), f"Row count mismatch: MySQL has {count}"
    print("Row count verified:", count)


if __name__ == "__main__":
    from clean import clean
    load(clean(save=False))
