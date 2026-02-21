USE ecommerce;
SHOW TABLES;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sellers;

-- 1. Unique customer cities
SELECT DISTINCT customer_city
FROM customers
ORDER BY customer_city;

-- 2. Count the number of orders placed in 2017
SELECT COUNT(*) AS orders_2017
FROM orders
WHERE YEAR(order_purchase_timestamp) = 2017;

-- 3. Find the total sales per category
SELECT
p.product_category,
ROUND(SUM(oi.price),2) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY total_sales DESC;

-- 4.Calculate the percentage of orders that were paid in instAllments
SELECT
ROUND(
SUM(payment_installments > 1) * 100.0 / COUNT(*),2) AS installment_payment
FROM payments;

-- 5. Count the number of customers from each state
SELECT customer_state, COUNT(*) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;