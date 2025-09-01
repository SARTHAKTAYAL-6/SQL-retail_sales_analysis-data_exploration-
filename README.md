# Sales Analysis SQL Project

## Project Overview

**Project Title**:  Sales Analysis  
**Database**: `p1_retail_db`

This project is a hands-on demonstration of SQL techniques for analyzing retail sales data. It covers database creation, data cleaning, and exploratory analysis, as well as writing SQL queries to answer practical business questions. It’s designed for aspiring data analysts who want to build a strong foundation in SQL and gain real-world experience

## Objectives

**Design and Populate the Retail Sales Database**
Build a structured database using the provided sales dataset to enable efficient querying and analysis.

**Data Cleaning and Preparation**
Ensure data quality by detecting, handling, and correcting missing or inconsistent records.

**Perform Exploratory Data Analysis (EDA)**
Analyze the dataset to identify trends, patterns, and key metrics that inform business decisions.

**Generate Business Insights Using SQL**
Develop SQL queries to answer strategic business questions and extract actionable insights from the retail sales data.

## key features



**Database Setup**: Structured the retail sales database to support robust querying and analysis.

**Data Cleaning**: Removed missing or null values to ensure data integrity.

**Exploratory Analysis**: Explored key metrics, such as total sales, transactions per category, and customer behavior.

**Advanced SQL Queries**:

Aggregate sales metrics by category, month, and shift

Identify top-performing customers and products

Calculate average sales, total transactions, and percentages

Apply window functions for ranking and comparative analysis

## Skills Demonstrated

SQL for data extraction, transformation, and analysis

Database design and data cleaning

Exploratory data analysis (EDA)

Business intelligence insights and decision-making

Use of window functions, aggregations, and conditional logic

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `p1_retail_db`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE p1_retail_db;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on the most recent date:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = (SELECT MAX(sale_date) FROM retail_sales ;
```

2. **Write a SQL query to retrieve all transactions where the category is 'Beauty' and the total sale amount is greater than 1000 in the month of December 2022.**:
```sql
SELECT 
    *
FROM retail_sales
WHERE 
    category = 'Beauty'
    AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-12'
    AND total_sale > 1000;

```

3. **Write a SQL query to calculate the total sales (total_sale) and the number of transactions for each category in November 2022. Sort the results by total sales in descending order.**:
```sql
SELECT 
    category,
    SUM(total_sale) AS total_sales,
    COUNT(transaction_id) AS total_transactions
FROM retail_sales
WHERE TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
GROUP BY category
ORDER BY total_sales DESC;

```

4. **Write a SQL query to find the average age of male and female customers who purchased items from the 'Beauty' category in 2022.**:
```sql
SELECT 
    gender,
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty'
  AND EXTRACT(YEAR FROM sale_date) = 2022
GROUP BY gender;

```

5. **Write a SQL query to find the number of transactions for each category where the total_sale is greater than 1000, and display only categories having more than 5 such transactions.**:
```sql
SELECT 
    category,
    COUNT(transaction_id) AS high_value_transactions
FROM retail_sales
WHERE total_sale > 1000
GROUP BY category
HAVING COUNT(transaction_id) > 5
ORDER BY high_value_transactions DESC;

```

6. **Rank categories by the number of transactions for each gender in 2022.**:
```sql
SELECT 
    category,
    gender,
    COUNT(transaction_id) AS total_transactions,
    RANK() OVER (PARTITION BY gender ORDER BY COUNT(transaction_id) DESC) AS category_rank
FROM retail_sales
WHERE EXTRACT(YEAR FROM sale_date) = 2022
GROUP BY category, gender;

```

7. **For each year, find the best-selling month and also calculate its percentage contribution to the year’s total sales.**:
```sql
SELECT 
    year,
    month,
    total_sales,
    ROUND(
        100.0 * total_sales / SUM(total_sales) OVER (PARTITION BY year), 
        2
    ) AS pct_of_year_sales
FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        TO_CHAR(sale_date, 'Month') AS month,
        SUM(total_sale) AS total_sales,
        RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY SUM(total_sale) DESC) AS rnk
    FROM retail_sales
    GROUP BY EXTRACT(YEAR FROM sale_date), TO_CHAR(sale_date, 'Month')
) t
WHERE rnk = 1
ORDER BY year;

```

8. **Find the top 5 customers based on the highest total sales in 2022, along with:

Total sales per customer

Number of transactions

Average sale per transaction

Rank customers within the year**:
```sql
SELECT 
    customer_id,
    COUNT(transaction_id) AS total_transactions,
    SUM(total_sale) AS total_sales,
    ROUND(AVG(total_sale), 2) AS avg_sale_per_transaction,
    RANK() OVER (ORDER BY SUM(total_sale) DESC) AS customer_rank
FROM retail_sales
WHERE EXTRACT(YEAR FROM sale_date) = 2022
GROUP BY customer_id
ORDER BY customer_rank
LIMIT 5;  

```

9. **Find the top 3 customers in each month of 2022 based on total sales. Include:

Customer ID

Month

Total sales

Number of transactions

Rank within the month.**:
```sql
WITH monthly_customer_sales AS (
    SELECT 
        customer_id,
        TO_CHAR(sale_date, 'YYYY-MM') AS year_month,
        SUM(total_sale) AS total_sales,
        COUNT(transaction_id) AS total_transactions,
        RANK() OVER (PARTITION BY TO_CHAR(sale_date, 'YYYY-MM') ORDER BY SUM(total_sale) DESC) AS month_rank
    FROM retail_sales
    WHERE EXTRACT(YEAR FROM sale_date) = 2022
    GROUP BY customer_id, TO_CHAR(sale_date, 'YYYY-MM')
)
SELECT *
FROM monthly_customer_sales
WHERE month_rank <= 3
ORDER BY year_month, month_rank;

```

10. **For each shift in 2022, find:

Total number of orders

Total sales

Average sale per transaction

Percentage contribution of each shift to total sales

Rank the shifts by total sales

Shifts definition:

Morning → before 12:00

Afternoon → 12:00 to 17:00

Evening → after 17:00**:
```sql
WITH shift_stats AS (
    SELECT 
        CASE 
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift,
        COUNT(transaction_id) AS total_orders,
        SUM(total_sale) AS total_sales,
        ROUND(AVG(total_sale), 2) AS avg_sale
    FROM retail_sales
    WHERE EXTRACT(YEAR FROM sale_date) = 2022
    GROUP BY 
        CASE 
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END
)
SELECT 
    shift,
    total_orders,
    total_sales,
    avg_sale,
    ROUND(100.0 * total_sales / SUM(total_sales) OVER (), 2) AS pct_of_total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS shift_rank
FROM shift_stats
ORDER BY shift_rank;

```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.
  

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.






