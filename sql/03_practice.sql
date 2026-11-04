USE supplychain_iq;

# P1: Second highest selling product
SELECT product_id, total_sales
FROM (SELECT product_id, ROUND(SUM(sales), 2) AS total_sales,
             DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) AS r
      FROM fact_order_items
      GROUP BY product_id) t
WHERE r = 2;

# P2: Duplicate primary key check (should return no rows)
SELECT order_item_id, COUNT(*) AS cnt
FROM fact_order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;

# P3: Customers with more than 10 orders
SELECT customer_id, COUNT(DISTINCT order_id) AS orders
FROM fact_order_items
GROUP BY customer_id
HAVING COUNT(DISTINCT order_id) > 10
ORDER BY orders DESC
LIMIT 10;

# P4: Month with the highest sales
SELECT DATE_FORMAT(order_date, '%Y-%m') AS ym, ROUND(SUM(sales), 2) AS total_sales
FROM fact_order_items
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY total_sales DESC
LIMIT 1;

# P5: Year over year sales growth
WITH y AS (
    SELECT YEAR(order_date) AS yr, SUM(sales) AS s
    FROM fact_order_items
    GROUP BY YEAR(order_date)
)
SELECT yr, ROUND(s, 2) AS sales,
       ROUND(LAG(s) OVER (ORDER BY yr), 2) AS prev_year,
       ROUND(100 * (s - LAG(s) OVER (ORDER BY yr)) / LAG(s) OVER (ORDER BY yr), 2) AS yoy_pct
FROM y;

# P6: Late percentage by customer segment
SELECT c.customer_segment, COUNT(*) AS items, ROUND(100 * AVG(f.is_late), 2) AS late_pct
FROM fact_order_items f
JOIN dim_customer c ON f.customer_id = c.customer_id
WHERE f.delivery_status <> 'Shipping canceled'
GROUP BY c.customer_segment;

# P7: Customers who have at least one loss making item (EXISTS)
SELECT COUNT(*) AS customers_with_a_loss
FROM dim_customer c
WHERE EXISTS (SELECT 1 FROM fact_order_items f
              WHERE f.customer_id = c.customer_id AND f.profit < 0);

# P8: Products with no orders (anti join)
SELECT p.product_id, p.product_name
FROM dim_product p
LEFT JOIN fact_order_items f ON f.product_id = p.product_id
WHERE f.order_item_id IS NULL;

# P9: Customers split into 4 groups by total sales (NTILE)
SELECT quartile, COUNT(*) AS customers, ROUND(MIN(total_sales), 2) AS min_sales,
       ROUND(MAX(total_sales), 2) AS max_sales
FROM (SELECT customer_id, SUM(sales) AS total_sales,
             NTILE(4) OVER (ORDER BY SUM(sales) DESC) AS quartile
      FROM fact_order_items
      GROUP BY customer_id) t
GROUP BY quartile
ORDER BY quartile;

# P10: Check that sales minus discount equals order_item_total
SELECT ROUND(SUM(sales - discount), 2) AS expected_total,
       ROUND(SUM(order_item_total), 2) AS actual_total
FROM fact_order_items;

# P11: Does the index on market get used?
EXPLAIN SELECT COUNT(*) FROM fact_order_items WHERE market = 'Europe';
