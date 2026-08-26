REQUIRED={"text","label"}
def validate_data(df):
    missing=REQUIRED-set(df.columns)
    if missing: raise ValueError(f"Missing columns: {sorted(missing)}")
    if df.empty: raise ValueError("Dataset is empty")
    if df["text"].isna().any(): raise ValueError("Missing text values")
    return True
