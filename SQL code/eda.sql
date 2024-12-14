-- EDA
select * FROM category;
select * FROM customers;
select * FROM inventory;
select * FROM order_items;
select * FROM orders;

SELECT
	DISTINCT(order_status)
FROM orders;

select * FROM payments;

SELECT
	DISTINCT(payment_status)
FROM payments;

select * FROM products;
select * FROM sellers;
select * FROM shipping;

SELECT
	DISTINCT(delivery_status)
FROM shipping;

SELECT *
FROM shipping 
WHERE return_date IS NOT NULL;

-- 6747

SELECT * FROM shipping WHERE order_id = 6747;
SELECT * FROM orders WHERE order_id = 6747;
SELECT * FROM payments WHERE order_id = 6747;

/* For order_id 6747 return date is not null which means it was returnd in shipping. 
As a result in orders also it was labelled as Returned and in
payments also it was labelled as Refunded */

SELECT * FROM payments WHERE payment_status = 'Payment Failed';

-- c
SELECT * FROM shipping WHERE order_id = 17533;
SELECT * FROM orders WHERE order_id = 17533;
SELECT * FROM payments WHERE order_id = 17533;

/* For order_id 17533 payment status is patment Failed. 
As a result in orders it was labelled as Cancelled and in
Shipping there is no entry of it */

SELECT *
FROM shipping 
WHERE return_date IS NULL;