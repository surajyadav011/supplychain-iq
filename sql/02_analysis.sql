USE supplychain_iq;

# Q1: Headline numbers
SELECT COUNT(DISTINCT order_id)                 AS total_orders,
       COUNT(*)                                 AS total_items,
       ROUND(SUM(sales), 2)                     AS total_sales,
       ROUND(SUM(profit), 2)                    AS total_profit,
       ROUND(100 * SUM(profit) / SUM(sales), 2) AS profit_margin_pct
FROM fact_order_items;

# Q2: Overall late delivery percentage, cancelled shipping excluded
SELECT COUNT(*)                     AS delivered_items,
       SUM(is_late)                 AS late_items,
       ROUND(100 * AVG(is_late), 2) AS late_pct
FROM fact_order_items
WHERE delivery_status <> 'Shipping canceled';

# Q3: Late percentage by shipping mode
SELECT shipping_mode,
       COUNT(*)                     AS items,
       SUM(is_late)                 AS late_items,
       ROUND(100 * AVG(is_late), 2) AS late_pct,
       ROUND(AVG(delay_days), 2)    AS avg_delay_days
FROM fact_order_items
WHERE delivery_status <> 'Shipping canceled'
GROUP BY shipping_mode
ORDER BY late_pct DESC;

# Q4: Late percentage, sales and profit by market
# Sales and profit use all items, late percentage uses delivered items only
SELECT market,
       ROUND(100 * AVG(CASE WHEN delivery_status <> 'Shipping canceled'
                            THEN is_late END), 2) AS late_pct,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit
FROM fact_order_items
GROUP BY market
ORDER BY total_sales DESC;

# Q5: Top 10 products by profit (JOIN)
SELECT p.product_name, p.category_name,
       ROUND(SUM(f.sales), 2)  AS total_sales,
       ROUND(SUM(f.profit), 2) AS total_profit
FROM fact_order_items f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name, p.category_name
ORDER BY total_profit DESC
LIMIT 10;

# Q6: Top 3 products inside each category (RANK)
SELECT category_name, product_name, total_profit, rnk
FROM (
    SELECT p.category_name, p.product_name,
           ROUND(SUM(f.profit), 2) AS total_profit,
           RANK() OVER (PARTITION BY p.category_name
                        ORDER BY SUM(f.profit) DESC) AS rnk
    FROM fact_order_items f
    JOIN dim_product p ON f.product_id = p.product_id
    GROUP BY p.category_name, p.product_name
) t
WHERE rnk <= 3
ORDER BY category_name, rnk;

# Q7: Loss making items by category
SELECT p.category_name,
       COUNT(*)                AS loss_items,
       ROUND(SUM(f.profit), 2) AS total_loss
FROM fact_order_items f
JOIN dim_product p ON f.product_id = p.product_id
WHERE f.profit < 0
GROUP BY p.category_name
ORDER BY total_loss ASC
LIMIT 10;

# Q8: Customer segment performance
SELECT c.customer_segment,
       COUNT(DISTINCT f.order_id) AS orders,
       ROUND(SUM(f.sales), 2)     AS total_sales,
       ROUND(SUM(f.profit), 2)    AS total_profit
FROM fact_order_items f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY total_sales DESC;

# Q9: Monthly sales with previous month and growth (CTE and LAG)
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS ym, SUM(sales) AS sales
    FROM fact_order_items
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT ym,
       ROUND(sales, 2)                                AS sales,
       ROUND(LAG(sales) OVER (ORDER BY ym), 2)        AS prev_month_sales,
       ROUND(100 * (sales - LAG(sales) OVER (ORDER BY ym))
             / LAG(sales) OVER (ORDER BY ym), 2)      AS growth_pct
FROM monthly
ORDER BY ym;

# Q10: Running total of monthly sales
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS ym, SUM(sales) AS sales
    FROM fact_order_items
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT ym, ROUND(sales, 2) AS sales,
       ROUND(SUM(sales) OVER (ORDER BY ym), 2) AS running_total
FROM monthly
ORDER BY ym;

# Q11: Scheduled days against real days by shipping mode
SELECT shipping_mode,
       ROUND(AVG(days_scheduled), 2)             AS avg_scheduled_days,
       ROUND(AVG(days_real), 2)                  AS avg_real_days,
       ROUND(AVG(days_real - days_scheduled), 2) AS avg_gap_days
FROM fact_order_items
WHERE delivery_status <> 'Shipping canceled'
GROUP BY shipping_mode
ORDER BY avg_gap_days DESC;

# Q12: Late percentage at order level (an order is late if any item is late)
WITH order_level AS (
    SELECT order_id, MAX(is_late) AS any_late
    FROM fact_order_items
    WHERE delivery_status <> 'Shipping canceled'
    GROUP BY order_id
)
SELECT COUNT(*)                               AS total_orders,
       SUM(any_late)                          AS late_orders,
       ROUND(100 * SUM(any_late) / COUNT(*), 2) AS late_order_pct
FROM order_level;

# Q13: Share of each shipping mode (window function over a group)
SELECT shipping_mode,
       COUNT(*) AS items,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_pct
FROM fact_order_items
GROUP BY shipping_mode
ORDER BY items DESC;

# Q14: Top 3 customers in each market (ROW_NUMBER)
SELECT market, customer_id, total_sales, rn
FROM (
    SELECT market, customer_id,
           ROUND(SUM(sales), 2) AS total_sales,
           ROW_NUMBER() OVER (PARTITION BY market
                              ORDER BY SUM(sales) DESC) AS rn
    FROM fact_order_items
    GROUP BY market, customer_id
) t
WHERE rn <= 3
ORDER BY market, rn;

# Q15: Delay buckets (CASE WHEN)
SELECT CASE WHEN delay_days <= 0 THEN 'On time or early'
            WHEN delay_days = 1  THEN '1 day late'
            WHEN delay_days = 2  THEN '2 days late'
            ELSE '3 or more days late' END AS delay_bucket,
       COUNT(*) AS items
FROM fact_order_items
WHERE delivery_status <> 'Shipping canceled'
GROUP BY delay_bucket
ORDER BY MIN(delay_days);

# View used by Power BI
CREATE OR REPLACE VIEW vw_supplychain AS
SELECT f.*, c.customer_segment, c.customer_city, c.customer_state, c.customer_country,
       p.product_name, p.category_name, p.department_name
FROM fact_order_items f
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_product  p ON f.product_id  = p.product_id;
