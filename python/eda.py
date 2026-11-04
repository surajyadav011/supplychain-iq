import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import seaborn as sns
from config import CLEAN_CSV, REPORT_DIR

df = pd.read_csv(CLEAN_CSV, parse_dates=["order_date"])
delivered = df[df["delivery_status"] != "Shipping canceled"]
out = REPORT_DIR / "charts"
out.mkdir(parents=True, exist_ok=True)

# 1. Delivery status for each shipping mode
plt.figure(figsize=(10, 5))
sns.countplot(data=df, x="shipping_mode", hue="delivery_status")
plt.title("Delivery Status by Shipping Mode")
plt.savefig(out / "status_by_mode.png", dpi=120, bbox_inches="tight")
plt.close()

# 2. Late percentage by shipping mode
late = delivered.groupby("shipping_mode")["is_late"].mean().mul(100).sort_values()
late.plot(kind="barh", title="Late Delivery % by Shipping Mode", figsize=(8, 4))
plt.xlabel("Late items (%)")
plt.savefig(out / "late_by_mode.png", dpi=120, bbox_inches="tight")
plt.close()

# 3. Top 10 categories by sales
top = df.groupby("category_name")["sales"].sum().sort_values(ascending=False).head(10)
top.plot(kind="bar", color="teal", title="Top 10 Categories by Sales", figsize=(10, 5))
plt.ylabel("Total sales")
plt.xticks(rotation=45, ha="right")
plt.savefig(out / "top_categories.png", dpi=120, bbox_inches="tight")
plt.close()

# 4. Monthly sales trend
monthly = df.groupby(df["order_date"].dt.to_period("M"))["sales"].sum()
monthly.index = monthly.index.to_timestamp()
monthly.plot(title="Monthly Sales", figsize=(10, 4))
plt.ylabel("Total sales")
plt.savefig(out / "monthly_sales.png", dpi=120, bbox_inches="tight")
plt.close()

print("Charts saved in", out)
