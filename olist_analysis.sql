/*
================================================================================
PROJECT: Olist E-Commerce Multi-Dimensional Business Intelligence
AUTHOR: Mansur Mohammed (York University - Business Economics)
FILE: olist_master_analysis.sql
DESCRIPTION: 
    This script serves as the complete technical foundation for analyzing over 
    100,000 orders from the Olist Brazilian marketplace. It includes:
    1. Schema Architecture & Data Ingestion Protocols
    2. Data Normalization (English Category Translations)
    3. Multi-Dimensional Business Health Reporting
================================================================================
*/


CREATE DATABASE IF NOT EXISTS olist_project;
USE olist_project;

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

-- WHY: Standardizing Portuguese categories to English for global business reporting.
CREATE TABLE IF NOT EXISTS product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

-- 1.3 Order Reviews Table Setup
CREATE TABLE IF NOT EXISTS olist_order_reviews_dataset (
    review_id VARCHAR(100),
    order_id VARCHAR(100),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date VARCHAR(50),
    review_answer_timestamp VARCHAR(50)
);

-- INSTRUCTIONS: Update the file paths below to match your local secure directory.

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- WHAT: Average delivery time calculated per State.
-- WHY: To identify geographical bottlenecks in the supply chain.
SELECT 
    c.customer_state,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- WHAT: A master query combining Sales, Logistics, and Satisfaction metrics.
-- WHY: To provide leadership with a single view of category health and operational efficiency.
SELECT 
    t.product_category_name_english AS category,
    
    -- SALES DATA
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_ticket_size,
    
    -- LOGISTICS DATA
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_time_days,
    
    -- CUSTOMER SATISFACTION
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    
    -- OPERATIONAL HEALTH (Metric: On-Time Delivery %)
    ROUND(SUM(CASE WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1 ELSE 0 END) 
          / COUNT(o.order_id) * 100, 2) AS pct_on_time_delivery

FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_products_dataset p ON oi.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id

WHERE o.order_status = 'delivered' -- Focused on completed business cycles.
GROUP BY 1
HAVING total_orders > 100 -- Focused on statistically significant categories.
ORDER BY total_revenue DESC;
