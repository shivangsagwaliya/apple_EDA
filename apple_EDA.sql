-- IMPROVING QUERY PERFORMANCE BY INDEXING 

CREATE INDEX sales_product_id ON sales(product_id)
CREATE INDEX sales_store_id ON sales(store_id)
CREATE INDEX sales_sale_date ON sales(sale_date)


-- Find the number of stores in each country

SELECT Country ,COUNT(DISTINCT Store_ID) AS total_stores FROM stores
GROUP BY Country;

-- Calculate the total number of units sold by each store.

SELECT store_id , COUNT(quantity) As total_units_sold 
FROM sales
GROUP BY store_id;

--Identify how many sales occurred in December 2023

SELECT COUNT(DISTINCT sale_id) AS total_sales_dec FROM sales
WHERE MONTH(sale_date) = 12;


-- Determine how many stores have never had a warranty claimed filed.

SELECT store_id FROM stores
WHERE store_id NOT IN
					(SELECT DISTINCT store_id FROM sales s
					RIGHT JOIN warranty w 
					ON s.sale_id= w.sale_id
					WHERE s.store_id IS NOT NULL);


-- Calculate the percentage of warranty claims marked as "Warranty Void"

	
	SELECT CONCAT(CAST(CAST(COUNT(claim_id) AS NUMERIC)/(SELECT COUNT(claim_id) FROM warranty)  * 100 AS DECIMAL(10,2)),' ','%') AS Warranty_void_percentage
	FROM warranty
	WHERE repair_status = 'Rejected'


-- Identify Which store had the highest total units sold in the last year 


SELECT TOP 1 store_id ,COUNT(quantity) AS total
FROM sales 
WHERE sale_date >= DATEADD(YEAR,-1,GETDATE())
GROUP BY store_id
ORDER BY COUNT(quantity) DESC;


-- Count the number of unique products sold in the last year

SELECT COUNT(DISTINCT product_id) FROM sales
WHERE sale_date >= DATEADD(YEAR,-1,GETDATE());


-- Select the average price of products in each category 

SELECT c.Category_ID, c.category_name ,AVG(Price) AS avg_price
FROM products p
JOIN category c
ON p.Category_ID=c.category_id
GROUP BY c.Category_ID,c.category_name
ORDER BY AVG(Price) DESC;


-- For each store , identify the best selling day based on highest quantity sold 

SELECT store_id , 
sale_day , 
total_sale 
FROM
	
	(SELECT store_id ,
	FORMAT(sale_date,'dddd') sale_day,
	SUM(quantity) AS total_sale,
	RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS rn
	FROM sales
	GROUP BY store_id , FORMAT(sale_date,'dddd') )t
	WHERE rn =1;


-- Identify the least selling product in each country for each year based on total_units sold

SELECT product_id ,
	product_name,
		Year , 
		total_sale,
		Country
		FROM

(
	SELECT st.Country,
	s.product_id,
	p.product_name,
	YEAR(s.sale_date) AS Year,
	SUM(s.quantity) AS total_sale,
	
	DENSE_RANK() OVER (PARTITION BY st.Country ORDER BY SUM(s.quantity) ASC) AS rn

	FROM sales s
	JOIN stores st 
	ON st.Store_ID = s.Store_id
	JOIN products p
	ON p.Product_ID = s.product_id
	GROUP BY st.Country , s.product_id , YEAR(s.sale_date), p.product_name)t
	WHERE rn = 1;

-- Calculate how many warranty claims were filed within 180 days of product sale 

SELECT COUNT(w.claim_id) AS total_claims
FROM Warranty  w
LEFT JOIN sales s
  ON w.sale_id = s.sale_id
WHERE DATEDIFF(DAY,w.claim_date, s.sale_date) <= 180;

-- Determine how many warranty claims were filed for products lauched in the last two years .

SELECT COUNT(w.claim_id) AS total_claims
FROM Warranty  w
LEFT JOIN sales s
  ON w.sale_id = s.sale_id 
LEFT JOIN products p 
ON s.product_id= p.product_id
WHERE  p.launch_date >= DATEADD(YEAR, -2, GETDATE());

-- List the months in the last three years where sales exceeded 5000 units in the usa

SELECT	FORMAT(s.sale_Date,'MM,yyy') AS sale_date ,
		SUM(s.quantity) AS quantity
FROM  sales s
	JOIN stores st 
	ON st.Store_ID = s.Store_id
	JOIN products p
	ON s.product_id= p.Product_ID
	WHERE st.Country = 'USA'
	AND s.sale_date >= DATEADD(YEAR,-3,GETDATE())
	GROUP BY FORMAT(s.sale_Date,'MM,yyy')
	HAVING SUM(s.quantity) > 5000 

--- Identify the product category with the most warranty claims filed in the last two years


	SELECT TOP 1 p.category_ID, c.category_name, COUNT(w.claim_id) AS total_claims
	FROM Warranty  w
	LEFT JOIN sales s
	  ON w.sale_id = s.sale_id 
	LEFT JOIN products p 
	ON s.product_id= p.product_id
	LEFT JOIN category c
	ON
	p.category_id = c.category_id
	WHERE  p.launch_date >= DATEADD(YEAR, -2, GETDATE())
	GROUP BY p.category_ID , c.category_name
	ORDER BY total_claims DESC;



-- Determine the percentage chance of receiving warranty claims after each purchase for each country
WITH cte AS(		
			SELECT st.Country,
			COUNT(s.sale_id) AS total_sale,
			COUNT(claim_id) AS total_claims

			FROM Warranty  w
			FULL OUTER JOIN sales s
			  ON w.sale_id = s.sale_id 
			LEFT JOIN products p 
			ON s.product_id= p.product_id
			LEFT JOIN stores st
			ON st.Store_id = s.store_id
			GROUP BY st.Country)

			SELECT * , CONCAT(CAST(CAST(total_claims AS NUMERIC)/total_sale * 100 AS DECIMAL(10,2)),' ','%') AS chance_of_claim
			FROM cte 
			ORDER BY COUNTRY
	

-- Analyze the year-by-year growth ratio for each store

WITH yearly_sales AS (	SELECT st.Store_id,
	st.store_name,
	YEAR(sale_date) AS Year,
	SUM(s.quantity * p.price) AS total_sale
	FROM Sales s
	LEFT JOIN stores st
			ON st.Store_id = s.store_id
	LEFT JOIN Products p
	ON p.product_id=s.product_id
	GROUP BY st.Store_ID,st.Store_Name,YEAR(sale_date)),

growth_ratio as(SELECT store_name,
	   Year,
	   LAG(total_sale) OVER( PARTITION BY store_name ORDER BY Year) AS prev_sales,
	   total_sale AS current_year_sales
	   FROM yearly_Sales)

SELECT store_name,
prev_sales,
current_year_sales,
CAST(
        (current_year_sales - prev_sales) * 100.0 / NULLIF(prev_sales, 0) AS DECIMAL(10,2)
    ) AS growth_ratio_percent
FROM growth_ratio;

-- Calculate the correlation between product price and warranty claims for products sold in the last five years ,
-- segmented by pricerange 
SELECT 
		 CASE WHEN price <500 THEN 'Low range product'  
		 WHEN price BETWEEN 500 AND 1000 THEN 'Mid range product'
		 ELSE  'High range product' END AS price_segment,
COUNT(claim_id) AS total_claims
FROM products p
JOIN sales s
ON p.Product_ID = s.product_id
RIGHT JOIN warranty w
ON s.sale_id= w.sale_id
WHERE sale_date >= DATEADD(YEAR,-5,sale_date)
GROUP BY  CASE WHEN price < 500 THEN 'Low range product'  
		 WHEN price BETWEEN 500 AND 1000 THEN 'Mid range product'
		 ELSE 'High range product' END;

-- Identify the store with the highest percentage of "Pending" claims relative to total claims filed.

WITH pending AS (

SELECT 
store_id ,
COUNT(claim_id) AS pending_claims
FROM sales s
RIGHT JOIN warranty w
on s.sale_id = w.sale_id
WHERE repair_status = 'Pending'
GROUP BY store_id
),
claims AS 
( SELECT 
store_id ,
COUNT(claim_id) AS total_claims
FROM sales s
RIGHT JOIN warranty w
on s.sale_id = w.sale_id
GROUP BY store_id
)
SELECT 
p.store_id ,
s.store_name,
total_claims,
pending_claims,
CONCAT ( CAST(CAST(pending_claims AS NUMERIC)/
total_claims *100 AS DECIMAL(10,2)), ' ' , '%' )AS perc_pending_claims
FROM claims c 
JOIN pending p 
ON c.store_id = p.store_id
JOIN stores s 
ON s.store_id= p.store_id;

-- Write a query to calculate the monthly running total of sales for each store over the past four years 

WITH monthly AS
( SELECT s.store_id,
MONTH(s.sale_date) AS month,
YEAR(s.sale_date) AS year,
SUM(p.price*s.quantity) AS total_revenue
FROM sales s
JOIN stores st 
ON st.store_id = s.store_id
JOIN Products p 
ON p.Product_ID = s.product_id
GROUP BY s.store_id, YEAR(s.sale_date) , MONTH(s.sale_date)
)

SELECT 
store_id ,
year,
total_revenue,
SUM(total_revenue) OVER(PARTITION BY store_id ORDER BY year, month) AS running_total
FROM monthly



-- Analyze the product sales trends over time , segmented into key periods: from launch to 6 months, 6-12 months , 6-18 months 

SELECT 
p.Product_id,
Product_name,
COUNT(sale_id)AS total_sales,
CASE WHEN DATEDIFF(MONTH,Launch_date,sale_date) < 6 THEN '0-6 months'
	 WHEN DATEDIFF(MONTH,Launch_date,sale_date) >= 6 AND DATEDIFF(MONTH,Launch_date,sale_date) <=12  THEN '6-12 months'
	 WHEN DATEDIFF(MONTH,Launch_date,sale_date) > 12  THEN '12+ months'
	 END AS segment
FROM Sales s
JOIN Products p 
ON s.product_id=p.product_id
GROUP BY p.Product_id,
Product_name, CASE WHEN DATEDIFF(MONTH,Launch_date,sale_date) < 6 THEN '0-6 months'
	 WHEN DATEDIFF(MONTH,Launch_date,sale_date) >= 6 AND DATEDIFF(MONTH,Launch_date,sale_date) <=12  THEN '6-12 months'
	 WHEN DATEDIFF(MONTH,Launch_date,sale_date) > 12  THEN '12+ months'
	 END
ORDER BY p.Product_name, segment
