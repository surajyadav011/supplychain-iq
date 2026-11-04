USE supplychain_iq;

# Row counts of the three tables
SELECT 'fact_order_items' AS table_name, COUNT(*) AS row_count FROM fact_order_items
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product;

# Foreign key check: both results should be 0
SELECT COUNT(*) AS orphan_customers
FROM fact_order_items f
LEFT JOIN dim_customer c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS orphan_products
FROM fact_order_items f
LEFT JOIN dim_product p ON f.product_id = p.product_id
WHERE p.product_id IS NULL;

# Look at a few rows
SELECT order_item_id, order_id, customer_id, product_id,
       delay_days, is_late, sales, profit
FROM fact_order_items
ORDER BY order_item_id
LIMIT 5;

# Date range
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order
FROM fact_order_items;
