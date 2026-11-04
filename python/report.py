from datetime import datetime
import pandas as pd
from sqlalchemy import create_engine, text
from openpyxl.styles import Font, PatternFill
from openpyxl.chart import BarChart, Reference
from config import DB_URL, REPORT_DIR

QUERIES = {
    "KPI_Summary": """
        SELECT COUNT(DISTINCT order_id) AS total_orders, COUNT(*) AS total_items,
               ROUND(SUM(sales), 2) AS total_sales, ROUND(SUM(profit), 2) AS total_profit,
               ROUND(100 * SUM(profit) / SUM(sales), 2) AS profit_margin_pct
        FROM fact_order_items""",
    "Shipping_Mode": """
        SELECT shipping_mode, COUNT(*) AS items, ROUND(100 * AVG(is_late), 2) AS late_pct,
               ROUND(AVG(delay_days), 2) AS avg_delay_days
        FROM fact_order_items WHERE delivery_status <> 'Shipping canceled'
        GROUP BY shipping_mode ORDER BY late_pct DESC""",
    "Market": """
        SELECT market,
               ROUND(100 * AVG(CASE WHEN delivery_status <> 'Shipping canceled'
                                    THEN is_late END), 2) AS late_pct,
               ROUND(SUM(sales), 2) AS total_sales, ROUND(SUM(profit), 2) AS total_profit
        FROM fact_order_items GROUP BY market ORDER BY total_sales DESC""",
    "Top10_Products": """
        SELECT p.product_name, p.category_name, ROUND(SUM(f.sales), 2) AS total_sales,
               ROUND(SUM(f.profit), 2) AS total_profit
        FROM fact_order_items f JOIN dim_product p ON f.product_id = p.product_id
        GROUP BY p.product_name, p.category_name ORDER BY total_profit DESC LIMIT 10""",
    "Monthly_Sales": """
        SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, ROUND(SUM(sales), 2) AS sales,
               ROUND(SUM(profit), 2) AS profit
        FROM fact_order_items GROUP BY DATE_FORMAT(order_date, '%Y-%m') ORDER BY month""",
}


def build_report():
    engine = create_engine(DB_URL)
    REPORT_DIR.mkdir(exist_ok=True)
    path = REPORT_DIR / f"SupplyChain_Report_{datetime.now():%Y%m%d_%H%M}.xlsx"

    with pd.ExcelWriter(path, engine="openpyxl") as writer:
        for sheet, sql in QUERIES.items():
            pd.read_sql(text(sql), engine).to_excel(writer, sheet_name=sheet, index=False)

        for ws in writer.book.worksheets:
            for cell in ws[1]:
                cell.font = Font(bold=True, color="FFFFFF")
                cell.fill = PatternFill("solid", start_color="1F4E78")
            for col in ws.columns:
                width = max(len(str(c.value or "")) for c in col) + 3
                ws.column_dimensions[col[0].column_letter].width = min(width, 45)

        ws = writer.book["Shipping_Mode"]
        chart = BarChart()
        chart.title = "Late Delivery % by Shipping Mode"
        rows = ws.max_row
        chart.add_data(Reference(ws, min_col=3, min_row=1, max_row=rows), titles_from_data=True)
        chart.set_categories(Reference(ws, min_col=1, min_row=2, max_row=rows))
        ws.add_chart(chart, "G2")

    print("Report saved:", path)
    return path


if __name__ == "__main__":
    build_report()
