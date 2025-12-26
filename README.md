Apple Retail Sales & Warranty Analytics (SQL Project)
📌 Project Overview
This project is an advanced SQL-based Exploratory Data Analysis (EDA) of a mock Apple retail dataset. The goal is to solve real-world business problems related to sales performance, product lifecycle trends, and warranty risk analysis.

By analyzing over 1 million transaction records, this project derives actionable insights into:

Sales Trends: Identifying seasonal peaks and high-growth stores.

Product Quality: Analyzing warranty claim rates and "Void" percentages to detect high-risk products.

Store Performance: calculating Year-over-Year (YoY) growth and revenue density per region.

🗂️ Database Schema
The dataset consists of 5 relational tables organized in a Star Schema structure.

1. stores
Description: Contains details of Apple retail locations globally.

Columns:

store_id (PK): Unique identifier for each store.

store_name: Name of the store.

city: City location.

country: Country location.

2. category
Description: Classification of Apple products (e.g., Laptops, Phones, Accessories).

Columns:

category_id (PK): Unique identifier.

category_name: Name of the category.

3. products
Description: Product catalog including pricing and launch details.

Columns:

product_id (PK): Unique identifier.

product_name: Name of the product (e.g., iPhone 14, MacBook Pro).

category_id (FK): Links to category table.

launch_date: Official release date.

price: Retail price.

4. sales
Description: Historical transaction data.

Columns:

sale_id (PK): Unique identifier.

sale_date: Transaction date.

store_id (FK): Links to stores.

product_id (FK): Links to products.

quantity: Units sold in the transaction.

5. warranty
Description: Warranty claim records linked to specific sales.

Columns:

claim_id (PK): Unique identifier.

claim_date: Date the claim was filed.

sale_id (FK): Links to the original transaction in sales.

repair_status: Status of the claim (e.g., 'Paid Repaired', 'Warranty Void', 'Repaired').

🚀 Key Business Problems Solved
This project uses complex SQL queries to answer critical business questions:

1. Performance Optimization
Query Indexing: Implemented indexes on product_id, store_id, and sale_date to improve query execution speed for large aggregations.

2. Sales & Growth Analysis
YoY Growth: Calculated year-over-year growth ratios for every store to identify underperforming locations.

Seasonality: Identified best-selling days and months to optimize inventory stocking.

Market Penetration: Analyzed sales volume across different countries (USA, UK, Germany, etc.).

3. Warranty & Risk Analytics
Claim Velocity: Determined how many warranty claims are filed within 180 days of purchase.

Void Rate Analysis: Calculated the percentage of warranty claims marked as "Warranty Void" to identify potential fraud or user damage trends.

Product Reliability: Identified product categories with the highest claim density to inform quality control teams.

🛠️ Tech Stack
Database: PostgreSQL / MS SQL Server (T-SQL)

SQL Skills: Window Functions (RANK, DENSE_RANK, LAG), CTEs (Common Table Expressions), Joins, Aggregations.

Tools: PGAdmin 4 / SSMS.
