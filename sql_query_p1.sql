-- SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p2;


-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

SELECT * FROM retail_sales
LIMIT 10


    

SELECT 
    COUNT(*) 
FROM retail_sales

-- Data Cleaning
SELECT * FROM retail_sales
WHERE transactions_id IS NULL

SELECT * FROM retail_sales
WHERE sale_date IS NULL

SELECT * FROM retail_sales
WHERE sale_time IS NULL

SELECT * FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
-- 
DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
-- Data Exploration

-- How many sales we have?
SELECT COUNT(*) as total_sale FROM retail_sales

-- How many uniuque customers we have ?

SELECT COUNT(DISTINCT customer_id) as total_sale FROM retail_sales



SELECT DISTINCT category FROM retail_sales


-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on the most recent date:
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Beauty' and the total sale amount is greater than 1000 in the month of December 2022.:
-- Q.3 Write a SQL query to calculate the total sales (total_sale) and the number of transactions for each category in November 2022. Sort the results by total sales in descending order.:
-- Q.4 Write a SQL query to find the average age of male and female customers who purchased items from the 'Beauty' category in 2022.:
-- Q.5 Write a SQL query to find the number of transactions for each category where the total_sale is greater than 1000, and display only categories having more than 5 such transactions.:
-- Q.6 Rank categories by the number of transactions for each gender in 2022.:
-- Q.7 For each year, find the best-selling month and also calculate its percentage contribution to the year’s total sales.:
-- Q.8 Find the top 5 customers based on the highest total sales in 2022, along with:Total sales per customer,Number of transactions,Average sale per transaction,Rank customers within the year**:
-- Q.9 Find the top 3 customers in each month of 2022 based on total sales. Include:Customer ID,Month,Total sales,Number of transactions,Rank within the month.**:
-- Q.10 **For each shift in 2022, find:Total number of orders,Total sales,Average sale per transaction,Percentage contribution of each shift to total sales,Rank the shifts by total sales
Shifts definition:
Morning → before 12:00
Afternoon → 12:00 to 17:00
Evening → after 17:00**:



 -- Q.1  Write a SQL query to retrieve all columns for sales made on the most recent date:

SELECT *
FROM retail_sales
WHERE sale_date = (SELECT MAX(sale_date) FROM retail_sales ;


-- Q.2  Write a SQL query to retrieve all transactions where the category is 'Beauty' and the total sale amount is greater than 1000 in the month of December 2022.

SELECT 
    *
FROM retail_sales
WHERE 
    category = 'Beauty'
    AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-12'
    AND total_sale > 1000;



-- Q.3 Write a SQL query to calculate the total sales (total_sale) and the number of transactions for each category in November 2022. Sort the results by total sales in descending order.
SELECT 
    *
FROM retail_sales
WHERE 
    category = 'Beauty'
    AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-12'
    AND total_sale > 1000;


-- Q.4 Write a SQL query to find the average age of male and female customers who purchased items from the 'Beauty' category in 2022.:.

SELECT 
    gender,
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty'
  AND EXTRACT(YEAR FROM sale_date) = 2022
GROUP BY gender;



-- Q.5 Write a SQL query to find the number of transactions for each category where the total_sale is greater than 1000, and display only categories having more than 5 such transactions.:
SELECT 
    category,
    COUNT(transaction_id) AS high_value_transactions
FROM retail_sales
WHERE total_sale > 1000
GROUP BY category
HAVING COUNT(transaction_id) > 5
ORDER BY high_value_transactions DESC;



-- Q.6 Rank categories by the number of transactions for each gender in 2022.:

SELECT 
    category,
    gender,
    COUNT(transaction_id) AS total_transactions,
    RANK() OVER (PARTITION BY gender ORDER BY COUNT(transaction_id) DESC) AS category_rank
FROM retail_sales
WHERE EXTRACT(YEAR FROM sale_date) = 2022
GROUP BY category, gender;



-- Q.7 For each year, find the best-selling month and also calculate its percentage contribution to the year’s total sales.:
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


-- Q.8 Find the top 5 customers based on the highest total sales in 2022, along with:
Total sales per customer

Number of transactions

Average sale per transaction

Rank customers within the year
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


-- Q.9 Find the top 3 customers in each month of 2022 based on total sales. Include:
Customer ID

Month

Total sales

Number of transactions

Rank within the month.:.

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



-- Q.10 ORDER BY year_month, month_rank;
**For each shift in 2022, find:
Total number of orders

Total sales

Average sale per transaction

Percentage contribution of each shift to total sales

Rank the shifts by total sales

Shifts definition:

Morning → before 12:00

Afternoon → 12:00 to 17:00

Evening → after 17:00**:
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


-- End of project


