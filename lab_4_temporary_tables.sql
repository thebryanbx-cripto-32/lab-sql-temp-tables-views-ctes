-- LAB SQL Temporary Tables, Views and CTEs
-- Dataset: Sakila database
-- Author: Bryan Calderon

USE sakila;

-- Step 1: Create a View: Rental information for each customer
SELECT * FROM customer;
CREATE or REPLACE VIEW customer_rental_summary AS     ## Better to avoid errors :)
SELECT c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, ## '' This is for an extra space 
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r
    ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email;
SELECT * FROM customer_rental_summary;

-- Step 2: Create a Temporary Table: Total amount paid by each customer
DROP TEMPORARY TABLE IF EXISTS customer_payment_summary;  ## Just in case!
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT crs.customer_id, crs.customer_name, crs.email,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
LEFT JOIN payment p
    ON crs.customer_id = p.customer_id
GROUP BY 
    crs.customer_id,
    crs.customer_name,
    crs.email;
SELECT * FROM customer_payment_summary; ## It works!

-- Step 3: Create a CTE and final Customer Summary Report
WITH customer_summary_cte AS (
    SELECT crs.customer_name, crs.email,
        crs.rental_count, cps.total_paid
    FROM customer_rental_summary crs
    JOIN customer_payment_summary cps
        ON crs.customer_id = cps.customer_id
)
SELECT 
    customer_name,
    email,
    rental_count,
    ROUND(total_paid, 2) AS total_paid,
    ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM customer_summary_cte
ORDER BY total_paid DESC;
## Hope it is ok !