CREATE TABLE walmart_data (
    invoice_id INT,
    Branch VARCHAR(20),
    City VARCHAR(50),
    category VARCHAR(50),
    unit_price NUMERIC(10,2),
    quantity INT,
    date DATE,
    time TIME,
    payment_method VARCHAR(20),
    rating NUMERIC(3,1),
    profit_margin NUMERIC(5,2)
);

ALTER TABLE walmart_data ALTER COLUMN quantity TYPE numeric;

\copy walmart_data FROM 'C:/Users/nitya/Desktop/Walmart_clean csv.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM walmart_data LIMIT 5;

--
SELECT payment_method , COUNT (*) FROM walmart_data GROUP BY payment_method;

--
SELECT COUNT (DISTINCT branch) FROM walmart_data;
	--COUNT DISTINCT BRANCHES

-- 

SELECT MAX(quantity) FROM walmart_data;


-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold
 
SELECT payment_method ,
COUNT(*) AS no_payment,
SUM (quantity) AS no_qty_sold
FROM walmart_data GROUP BY payment_method;


 -- Project Question 
--  Q.2 Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING
SELECT * FROM walmart_data;

SELECT branch , category , 
	AVG(rating) AS avg_rating,
	RANK() OVER (PARTITION BY branch ORDER BY 	AVG(rating) DESC) AS rank
	FROM walmart_data 
	GROUP BY 1,2;
	
-- OR
	
SELECT * 
FROM
(	
	SELECT branch , category , 
	AVG(rating) AS avg_rating,
	RANK() OVER (PARTITION BY branch ORDER BY 	AVG(rating) DESC) AS rank
	FROM walmart_data 
	GROUP BY 1,2
)
WHERE rank = 1;

-- Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT * FROM walmart_data;

SELECT date FROM walmart_data;

SELECT 
  date,
  date::DATE AS formatted_date
FROM walmart_data;

SELECT 
  date,
  TO_CHAR(date, 'Day') AS day_name
FROM walmart_data;


SELECT 
  branch,
  TO_CHAR(date, 'Day') AS day_name,
  COUNT(*) AS no_transactions
FROM walmart_data
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

-- Q. 4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT 
	payment_method , 
	SUM(quantity) AS no_qty_sold
	FROM walmart_data
	GROUP BY payment_method;
-- Q.5 Determine the average, minimum, and maximum rating of category for each city. 
--     List the city, average_rating, min_rating, and max_rating.

SELECT * FROM walmart_data;

SELECT 
	city,
	category,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating,
	AVG(rating) AS avg_rating
FROM walmart_data
GROUP BY 1,2

-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT * FROM walmart_data;

SELECT 
    category,
    SUM(unit_price * quantity) AS total_revenue,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart_data
GROUP BY category; 

-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH cte AS (
  SELECT
    branch,
    payment_method,
    COUNT(*) AS total_trans,
    RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
  FROM walmart_data
  GROUP BY branch, payment_method
)
SELECT *
FROM cte
WHERE rank = 1;

-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

WITH shifts AS (
    SELECT
        branch,
        invoice_id,
        CASE
            WHEN time >= '06:00:00' AND time < '12:00:00' THEN 'Morning'
            WHEN time >= '12:00:00' AND time < '18:00:00' THEN 'Afternoon'
            WHEN time >= '18:00:00' AND time <= '23:59:59' THEN 'Evening'
            ELSE 'Night'
        END AS day_time
    FROM walmart_data
)
SELECT
    branch,
    day_time,
    COUNT(DISTINCT invoice_id) AS count
FROM shifts
GROUP BY branch, day_time
ORDER BY branch,
    CASE day_time
        WHEN 'Morning' THEN 1
        WHEN 'Afternoon' THEN 2
        WHEN 'Evening' THEN 3
        ELSE 4
    END;


-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100


WITH revenue_2022 AS (
  SELECT
    branch,
    SUM(unit_price * quantity) AS last_year_revenue
  FROM walmart_data
  WHERE EXTRACT(YEAR FROM date) = 2022
  GROUP BY branch
),
revenue_2023 AS (
  SELECT
    branch,
    SUM(unit_price * quantity) AS current_year_revenue
  FROM walmart_data
  WHERE EXTRACT(YEAR FROM date) = 2023
  GROUP BY branch
)
SELECT
  r22.branch,
  r22.last_year_revenue,
  r23.current_year_revenue,
  ROUND(((r22.last_year_revenue - r23.current_year_revenue) / r22.last_year_revenue) * 100, 2) AS rev_dec_ratio
FROM revenue_2022 r22
JOIN revenue_2023 r23 ON r22.branch = r23.branch
ORDER BY rev_dec_ratio DESC
LIMIT 5;


















































 


