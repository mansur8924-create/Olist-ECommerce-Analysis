/*
================================================================================
PROJECT: Olist E-Commerce Business Intelligence
AUTHOR: Mansur Mohammed (York University - Business Economics)
FILE: olist_master_analysis.sql
DESCRIPTION: 
    Complete analysis pipeline for Olist Brazilian marketplace orders.
    Includes:
    1. Schema creation and CSV ingestion
    2. Product category translation
    3. Key metrics: Sales, Delivery, Customer Satisfaction
================================================================================
*/

-- Create project database
CREATE DATABASE IF NOT EXISTS olist_project;
USE olist_project;

-- Products table
CREATE TABLE IF NOT EXISTS olist_products_dataset (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght VARCHAR(10), 
    product_description_lenght VARCHAR(10),
    product_photos_qty VARCHAR(10),
    product_weight_g VARCHAR(10),
    product_length_cm VARCHAR(10),
    product_height_cm VARCHAR(10),
    product_width_cm VARCHAR(10)
);

-- Category translation table (Portuguese -> English)
CREATE TABLE IF NOT EXISTS product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

-- Order reviews table
CREATE TABLE IF NOT EXISTS olist_order_reviews_dataset (
    review_id VARCHAR(100),
    order_id VARCHAR(100),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date VARCHAR(50),
    review_answer_timestamp VARCHAR(50)
);

-- Load CSV data (update paths as needed)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- Average delivery time by state
SELECT 
    c.customer_state,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- Category-level dashboard combining sales, logistics, and satisfaction
SELECT 
    t.product_category_name_english AS category,
    
    -- Sales
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_ticket_size,
    
    -- Logistics
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_time_days,
    
    -- Customer satisfaction
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    
    -- Operational health: On-time delivery %
    ROUND(SUM(CASE WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1 ELSE 0 END) 
          / COUNT(o.order_id) * 100, 2) AS pct_on_time_delivery

FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_products_dataset p ON oi.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
GROUP BY 1
HAVING total_orders > 100
ORDER BY total_revenue DESC;
