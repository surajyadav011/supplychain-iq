def validate(df):
    errors = []
    if not df["order_item_id"].is_unique:
        errors.append("order_item_id is not unique")
    for col in ["order_id", "customer_id", "product_card_id", "order_date", "sales"]:
        if df[col].isna().any():
            errors.append(f"{col} has null values")
    if (df["sales"] <= 0).any():
        errors.append("sales must be positive")
    if df["is_late"].sum() == 0:
        errors.append("is_late is all zero, check the delivery_status label")
    if errors:
        raise ValueError("Validation failed: " + "; ".join(errors))
    print("Validation passed:", len(df), "rows")


if __name__ == "__main__":
    from clean import clean
    validate(clean(save=False))
