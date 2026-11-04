# Database with one fact table and two dimension tables
CREATE DATABASE IF NOT EXISTS supplychain_iq;
USE supplychain_iq;

DROP TABLE IF EXISTS fact_order_items;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product;

CREATE TABLE dim_customer (
    customer_id       INT PRIMARY KEY,
    customer_segment  VARCHAR(30),
    customer_city     VARCHAR(100),
    customer_state    VARCHAR(100),
    customer_country  VARCHAR(100)
);

CREATE TABLE dim_product (
    product_id      INT PRIMARY KEY,
    product_name    VARCHAR(255),
    product_price   DECIMAL(10,2),
    category_id     INT,
    category_name   VARCHAR(100),
    department_id   INT,
    department_name VARCHAR(100)
);

CREATE TABLE fact_order_items (
    order_item_id      INT PRIMARY KEY,
    order_id           INT NOT NULL,
    customer_id        INT NOT NULL,
    product_id         INT NOT NULL,
    order_date         DATETIME,
    shipping_date      DATETIME,
    order_status       VARCHAR(30),
    payment_type       VARCHAR(20),
    shipping_mode      VARCHAR(30),
    delivery_status    VARCHAR(30),
    late_delivery_risk TINYINT,
    days_scheduled     TINYINT,
    days_real          TINYINT,
    delay_days         SMALLINT,
    is_late            TINYINT,
    is_loss            TINYINT,
    market             VARCHAR(30),
    order_region       VARCHAR(60),
    order_country      VARCHAR(100),
    order_city         VARCHAR(100),
    order_state        VARCHAR(100),
    quantity           SMALLINT,
    sales              DECIMAL(12,2),
    discount           DECIMAL(12,2),
    discount_rate      DECIMAL(8,4),
    order_item_total   DECIMAL(12,2),
    profit             DECIMAL(12,2),
    profit_ratio       DECIMAL(10,4),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    CONSTRAINT fk_product  FOREIGN KEY (product_id)  REFERENCES dim_product(product_id),
    INDEX idx_order (order_id),
    INDEX idx_date (order_date),
    INDEX idx_mode (shipping_mode),
    INDEX idx_market (market)
);
