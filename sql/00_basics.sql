USE supplychain_iq;

# B1: SELECT and LIMIT, look at a few rows
SELECT order_item_id, order_id, shipping_mode, sales
FROM fact_order_items
ORDER BY order_item_id
LIMIT 5;

# B2: WHERE filters rows
SELECT COUNT(*) AS same_day_items
FROM fact_order_items
WHERE shipping_mode = 'Same Day';

# B3: ORDER BY sorts rows
SELECT order_item_id, product_id, sales
FROM fact_order_items
ORDER BY sales DESC, order_item_id
LIMIT 5;

# B4: GROUP BY makes one row per group
SELECT market, COUNT(*) AS items
FROM fact_order_items
GROUP BY market
ORDER BY items DESC;

# B5: COUNT(*) against COUNT(DISTINCT ...)
SELECT COUNT(*)                   AS items,
       COUNT(DISTINCT order_id)   AS orders,
       COUNT(DISTINCT customer_id) AS customers,
       COUNT(DISTINCT product_id) AS products
FROM fact_order_items;

# B6: HAVING filters groups after GROUP BY
SELECT shipping_mode, COUNT(*) AS items
FROM fact_order_items
GROUP BY shipping_mode
HAVING COUNT(*) > 30000;

# B7: JOIN brings the product name from the dimension table
SELECT f.order_item_id, p.product_name, f.sales
FROM fact_order_items f
JOIN dim_product p ON f.product_id = p.product_id
ORDER BY f.order_item_id
LIMIT 3;

# B8: CASE WHEN creates labels
SELECT CASE WHEN profit < 0 THEN 'Loss'
            WHEN profit = 0 THEN 'Break even'
            ELSE 'Profit' END AS result,
       COUNT(*) AS items
FROM fact_order_items
GROUP BY result;
