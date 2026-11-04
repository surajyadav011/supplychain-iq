import pandas as pd
from config import RAW_CSV, CLEAN_CSV

# Columns that repeat another column: {column to drop: column to keep}
DUPLICATES = {
    "order_customer_id": "customer_id",
    "order_item_cardprod_id": "product_card_id",
    "product_category_id": "category_id",
    "order_profit_per_order": "benefit_per_order",
    "order_item_product_price": "product_price",
}
# Personal data and empty columns
DROP = [
    "customer_email", "customer_password", "customer_fname", "customer_lname",
    "customer_street", "product_description", "product_image", "order_zipcode",
]


def clean(save=True):
    df = pd.read_csv(RAW_CSV, encoding="latin-1")
    print("Raw shape:", df.shape)

    # Make column names lowercase with underscores
    df.columns = (df.columns.str.strip().str.lower()
                  .str.replace(r"[^a-z0-9]+", "_", regex=True).str.strip("_"))
    df = df.rename(columns={"order_date_dateorders": "order_date",
                            "shipping_date_dateorders": "shipping_date"})

    # Drop a duplicate column only after proving it is identical
    for extra, keep in DUPLICATES.items():
        assert df[extra].equals(df[keep]), f"{extra} is different from {keep}"
    df = df.drop(columns=list(DUPLICATES) + DROP)

    # Text to real dates
    for col in ["order_date", "shipping_date"]:
        df[col] = pd.to_datetime(df[col], format="%m/%d/%Y %H:%M", errors="coerce")
        print(col, "invalid dates:", df[col].isna().sum())

    # The filters in this project depend on these exact labels
    labels = set(df["delivery_status"].unique())
    assert {"Late delivery", "Shipping canceled"} <= labels, f"Unexpected labels: {labels}"

    # New columns used in the analysis
    df["delay_days"] = df["days_for_shipping_real"] - df["days_for_shipment_scheduled"]
    df["is_late"] = (df["delivery_status"] == "Late delivery").astype(int)
    df["is_loss"] = (df["benefit_per_order"] < 0).astype(int)

    print("Clean shape:", df.shape)
    if save:
        df.to_csv(CLEAN_CSV, index=False, encoding="utf-8-sig")
        print("Saved:", CLEAN_CSV)
    return df


if __name__ == "__main__":
    clean()