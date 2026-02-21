-- 1.Calculate the moving average of order values for each customer over their order history
SELECT 
o.customer_id,
o.order_purchase_timestamp,
ROUND(AVG(oi.price) OVER (
PARTITION BY o.customer_id
ORDER BY o.order_purchase_timestamp
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
),2) AS moving_avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;

-- 2.Calculate the cumulative sales per month for each year
SELECT 
YEAR(o.order_purchase_timestamp) AS year,
MONTH(o.order_purchase_timestamp) AS month,
ROUND(
SUM(oi.price) OVER(
PARTITION BY YEAR(o.order_purchase_timestamp)
ORDER BY MONTH(o.order_purchase_timestamp)
),2) AS cumulative_sales
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id;

-- 3.Calculate the year-over-year growth rate of total sales
WITH yearly_sales AS (
SELECT YEAR(o.order_purchase_timestamp) AS year,
SUM(oi.price) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
)

SELECT year,
ROUND(
(total_sales - LAG(total_sales) OVER())*100 /
LAG(total_sales) OVER(),2
) AS yoy_growth
FROM yearly_sales;


-- 4.Calculate the retention rate of customers , defined as the percentage of customers who make another purchase within 6 months of their first purchase
SELECT 
ROUND(
COUNT(DISTINCT o2.customer_id)*100.0 /
COUNT(DISTINCT o1.customer_id),2
) AS retention_rate
FROM orders o1
LEFT JOIN orders o2
ON o1.customer_id=o2.customer_id
AND o2.order_purchase_timestamp > o1.order_purchase_timestamp
AND o2.order_purchase_timestamp <= DATE_ADD(o1.order_purchase_timestamp, INTERVAL 6 MONTH);

-- 5.Identify the top 3 customers who spent the most money in each year
SELECT year, customer_id, total_spent
FROM (
SELECT 
YEAR(o.order_purchase_timestamp) AS year,
o.customer_id,
SUM(oi.price) AS total_spent,
DENSE_RANK() OVER(
PARTITION BY YEAR(o.order_purchase_timestamp)
ORDER BY SUM(oi.price) DESC
) AS rnk
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY year, o.customer_id
) ranked
WHERE rnk<=3;