# Superstore SQL Project (PostgreSQL)

## Project Overview

This project is an SQL analysis of the Superstore dataset (sourced from Kaggle).

The goal of this project was to:
- Design a structured PostgreSQL database
- Separate raw, clean and analytical layers
- Build a dimensional model (fact + dimension tables)
- Perform business analysis using SQL

The repository is structured so that anyone can clone it and run it locally.

---

## Data Source

Dataset used:  
https://www.kaggle.com/datasets/vivek468/superstore-dataset-final

After downloading the CSV file, place it inside the following folder:
/data

Change the name to "superstore_orders.csv" - this is the file name the SQL scripts will be looking for. 

---

## Project Structure

/data
superstore_orders.csv

/sql  
00_create_schemas.sql  
01_create_raw_table.sql  
02_load_raw_data.sql  
03_profile_raw_data.sql  
04_create_clean_table.sql  
05_mart_dim_customer.sql  
06_mart_dim_location.sql  
07_mart_dim_product.sql  
08_mart_dim_date.sql  
09_mart_fact_sales.sql  
10_sales_overview.sql  
11_customer_analysis.sql  
12_product_analysis.sql  
13_shipping_timing_analysis.sql  

docker-compose.yml

README.md

---

## Database Architecture

The project uses three schemas:

### raw
Contains the original CSV data loaded as text without transformations.

### clean
Contains validated and typed data:
- Proper data types applied
- Empty strings converted to NULL
- Duplicates handled
- Invalid rows excluded

### mart
Dimensional model used for analysis:
- fact_sales
- dim_customer
- dim_product
- dim_location
- dim_date

The fact table represents order-line level sales.

---

## How to Run the Project

### 1. Clone the repository
Open a terminal (Git Bash, PowerShell, or CMD) and run:
```
git clone https://github.com/kathkam/superstore-sql-project.git  
cd superstore_sql_project
```
### 2. Download dataset
Download the Superstore CSV from Kaggle and place it in the /data folder with name "superstore_orders.csv":
superstore_sql_project/data/superstore_orders.csv

### 3. Start PostgreSQL with Docker
From inside the project folder (where docker-compose.yml is located), open the terminal and run:  
docker compose up -d

This will start a PostgreSQL container.

### 4. Connect using DBeaver
Create a new PostgreSQL connection. Use the following connection settings:

Host: localhost  
Port: 5432  
Database: superstore_db  
Username: superstore  
Password: superstore  

### 5. Run SQL files in order
Execute SQL scripts from the /sql folder in numerical order:  
00_create_schemas.sql  
01_create_raw_table.sql  
02_load_raw_data.sql  
03_profile_raw_data.sql  
04_create_clean_table.sql  
05-09 - dimensional and fact tables  
10-13 - business analysis  

---

## Resetting the Database (Optional)
PostgreSQL initialization scripts only run on first startup.  
If you want to completely reset the database and re-run everything:  
docker compose down -v  
docker compose up -d

The -v flag removes the Docker volume, which deletes all database data.  
After resetting, re-run the SQL scripts in order.

---

## Data Modeling Decisions
Raw data is loaded as text to avoid import failures which may be caused by an unknown source.  
Data types are applied in the clean layer.  
Empty strings are converted using NULLIF.  
Numeric type is used for financial values.  
Dimensional model separates fact and dimensions.  
Foreign keys are used in the fact table to ensure integrity.  
Product name inconsistencies were resolved using the most frequently occurring name per product_id.  

---

## Key Findings
Below are the main business insights derived from the analysis.

### Sales Overview
Overall total sales: 2297200.86  
Overall total profit: 286397.02  
Sales are significantly higher in 3rd and 4th quarter of each year, with total yearly sales growing each year.   
The most profitable category is Technology, while the most profitable sub-categories are: Copiers, Phones, Accessories (all from Technology category).  
Most profitable states are California, New York, Washington.  

### Customer Analysis
Top 10 customers contribute to 17.52% of total profit.  
Most customers make between 6 and 10 orders.  
The most profitable customer segment is Consumer, and the least profitable is Home Office segment.   
98.49 % of all customers place more than 1 order.  

### Product Analysis
Top 3 products by profit are: Canon imageCLASS 2200 Advanced Copier, Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind, Hewlett Packard LaserJet 3310 Copier.   
Top 3 products sold in the highest quantities are: Imation 16GB Mini TravelDrive USB 2.0 Flash Drive, Xerox 1881, GBC Premium Transparent Covers with Diagonal Lined Pattern.   
Among the top 10 selling products by quantity sold, the highest profit margin comes from sales with no discount. Sales of these products amount to only 2.61% of the total profit.   

### Shipping & Operations
Average shipping delay is just below 4 days, with the longest delay in shipping happening in the "Standard Class" ship mode (5 days).   
The quickest average shipping delay appears in West Virginia (2 days), while the longest delay is in District of Columbia (5.5 days).   
The highest profit margin comes from the First Class ship mode.  
There was no anomalies in terms of shipping found in the database.  

---

## Skills Demonstrated
PostgreSQL  
Data cleaning & validation  
Dimensional modeling  
Fact/dimension design  
CTEs  
Aggregations  
Window logic  
Bucketing & segmentation  
Business-oriented analysis  
Data anomaly detection  
