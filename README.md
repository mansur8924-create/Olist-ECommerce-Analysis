# Olist-ECommerce-Analysis

Project Overview
This project involves a comprehensive analysis of the Brazilian Olist E-Commerce dataset. Using complex SQL queries, I explored over 100,000 orders to uncover insights into sales performance, customer behavior, and logistics efficiency. The goal was to provide actionable data regarding regional sales trends and delivery performance.

Tools & Technologies

SQL (PostgreSQL/MySQL): Primary tool for data querying, joining 8+ relational tables, and performing aggregations.

Relational Mapping: Designing and understanding the Entity-Relationship Diagram (ERD) to navigate the database structure.

Data Cleaning: Handling null values in delivery timestamps and normalizing payment types.

Project Structure

Revenue Analysis: Queries identifying the highest-grossing product categories and seasonal sales spikes.

Customer Insights: Segmenting customers by geographic location and calculating lifetime value.

Logistics & Fulfillment: Measuring the gap between "Estimated Delivery Date" and "Actual Delivery Date" to identify shipping bottlenecks.

Key Skills Demonstrated

Complex Joins: Connecting orders, order_items, products, and sellers tables to track a single transaction's lifecycle.

Window Functions: Using RANK() and PARTITION BY to find the top-selling products in every state.

CTE (Common Table Expressions): Writing "Clean SQL" by breaking long queries into readable, temporary result blocks.

How to Use

Load the Dataset: Import the Olist CSV files into your SQL environment.

Run the Scripts: Execute olist_business_queries.sql to generate the analytical report.
