---

# **Amazon USA Sales Analysis 📊📦💰**

---

## **Project Overview**


I analyzed a dataset of over 20,000 sales records from an Amazon-like e-commerce platform. 🛒📈 This project involved advanced querying in PostgreSQL to explore customer behavior, product performance, and sales trends. Key tasks included revenue analysis, customer segmentation, and inventory management, addressing real-world business challenges through structured queries. 💻📊

The work emphasized data cleaning, handling null values, and optimizing database performance. An ERD diagram was created to visually represent the database schema and relationships, ensuring clarity in table interactions. 📋🔍

---

![ERD Scratch](https://github.com/Jana2207/Amazon_data_analytics_using_sql/blob/main/datasets/Amazon%20ERD.png)

## **Database Setup & Design**

### **Schema Structure**

```sql

-- Creating Category Table
CREATE TABLE category(
	category_id INT PRIMARY KEY,
    category_name VARCHAR(25)
);

-- Creating Customers Table
CREATE TABLE customers(
	Customer_id INT PRIMARY KEY,
    first_name	VARCHAR(15),
    last_name	VARCHAR(15),
    state VARCHAR(20),
    adress VARCHAR(10) DEFAULT('xxx')
);

-- Creating sellets table
CREATE TABLE sellers(
	seller_id INT PRIMARY KEY,
    seller_name	VARCHAR(25),
    origin VARCHAR(10)
);

-- Creating Products table
CREATE TABLE products(
	product_id	INT PRIMARY KEY,
    product_name VARCHAR(50),
    price FLOAT,
    cogs FLOAT,
    category_id INT, -- FK
    CONSTRAINT product_fk_category FOREIGN KEY(category_id) REFERENCES category(category_id)
);

-- Creating orders table
CREATE TABLE orders(
	order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id	INT, -- FK
    seller_id INT, -- FK
    order_status VARCHAR(12),
    CONSTRAINT orders_fk_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    CONSTRAINT orders_fk_sellers FOREIGN KEY(seller_id) REFERENCES sellers(seller_id)
);

-- Creating order_items table
CREATE TABLE order_items(
	order_item_id INT PRIMARY KEY,
	order_id INT, -- FK
    product_id INT, -- FK
    quantity INT,
    price_per_unit FLOAT,
    CONSTRAINT order_items_fk_orders FOREIGN KEY(order_id) REFERENCES orders(order_id),
    CONSTRAINT order_items_fk_products FOREIGN KEY(product_id) REFERENCES products(product_id)
);

-- Creating Table Payments
CREATE TABLE payments(
	payment_id INT PRIMARY KEY,
	order_id INT, -- FK
    payment_date DATE,
    payment_status VARCHAR(20),
    CONSTRAINT payments_fk_orders FOREIGN KEY(order_id) REFERENCES orders(order_id)
);

-- Creating Table shipping
CREATE TABLE shipping(
	shipping_id	INT PRIMARY KEY,
    order_id INT, -- FK
	shipping_date DATE,
    return_date DATE,
    shipping_providers VARCHAR(10),
    delivery_status VARCHAR(10),
	CONSTRAINT shipping_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Creating Table inventory
CREATE TABLE inventory(
	inventory_id INT PRIMARY KEY,
    product_id INT, -- FK
    stock INT,
    warehouse_id INT,	
    last_stock_date DATE,
    CONSTRAINT inventory_fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);

```

---

## **Task: Data Cleaning 🧹✨**  

I cleaned the dataset by:  
- **Removing duplicates**: 🗑️ Identified and removed duplicate entries in customer and order tables.  
- **Handling missing values**: 🧩 Addressed null values in critical fields like customer address and payment status using context-specific methods.  

---  

## **Handling Null Values 🤔🔧**  

Null values were managed contextually:  
- **Customer addresses**: 🏠 Assigned default placeholder values for missing entries.  
- **Payment statuses**: 💳 Categorized orders with null statuses as “Pending.”  
- **Shipping information**: 🚚 Left null return dates unchanged for shipments not returned.  

---  

## **Objective 🎯📊**  

The project aims to demonstrate SQL proficiency through complex queries that solve real-world e-commerce challenges. The analysis spans:  
- 🛒 Customer behavior  
- 📈 Sales trends  
- 📦 Inventory management  
- 💰 Payment and shipping insights  
- 🔮 Product performance and forecasting  

---  

## **Identifying Business Problems 🔍🚨**  

Key business challenges identified include:  
1. 🛍️ Inconsistent restocking leading to low product availability.  
2. 🔄 High return rates for certain product categories.  
3. ⏱️ Delays in shipments and inconsistent delivery times.  
4. 💸 Elevated customer acquisition costs paired with low retention rates.  


---

## **Solving Business Problems**

### Solutions Implemented:
1. Top Selling Products 🏆
Query the top 10 products by total sales value 💰.
Challenge: Include product name 🛍️, total quantity sold 📦, and total sales value 💸.

```sql
-- Adding Total Sales column

ALTER TABLE order_items
ADD COLUMN total_sales FLOAT ;

-- Updating table
UPDATE order_items 
SET total_sales = CASE
                     WHEN order_id IN (
                         SELECT 
						 	order_id
                         FROM payments
                         WHERE payment_status = 'Payment Successed'
                     )
                     THEN quantity * price_per_unit
                     ELSE 0
                 END;

-- Final query
SELECT
	oi.product_id AS product_id,
	p.product_name AS product_name,
	COUNT(oi.quantity) AS total_quantity_sold,
	SUM(oi.total_sales) AS total_sales
FROM orders AS o
JOIN order_items AS oi
ON oi.order_id = o.order_id
JOIN products AS p
ON p.product_id = oi.product_id
GROUP BY oi.product_id , p.product_name
ORDER BY total_sales DESC
LIMIT 10;
```
---

2. Revenue by Category 📊
Calculate total revenue generated by each product category 🏷️.
Challenge: Include the percentage contribution of each category to total revenue 💵.

```sql
SELECT
	c.category_id AS category_id,
	c.category_name AS category_name,
	SUM(oi.total_sales) AS total_sales,
	SUM(oi.total_sales) / (SELECT SUM(total_sales) FROM order_items) * 100
	AS percentage_contribution
FROM order_items AS oi
JOIN products AS p
ON p.product_id = oi.product_id
LEFT JOIN category AS c
ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_sales DESC;

```
---

3. Average Order Value (AOV) 💳
Compute the average order value for each customer 👤.
Challenge: Include only customers with more than 5 orders 🛍️.

```sql
SELECT
	c.customer_id AS customer_id,
	c.first_name AS first_name,
	c.last_name AS last_name,
	COUNT(o.order_id) AS total_quantity,
	SUM(oi.total_sales) / COUNT(o.order_id) AS average_order_vale
FROM customers AS c
JOIN orders AS o
ON o.customer_id = c.customer_id
JOIN order_items AS oi
ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 5
ORDER BY average_order_vale DESC;
```
---

4.Monthly Sales Trend 📅
Query monthly total sales over the past year 📊.
Challenge: Display the sales trend 📈, grouping by month 🗓️, and return current month's sales 💵 and last month's sales 💵!

```sql
SELECT
	Year,
	Month,
	current_month_sales,
	LAG(current_month_sales,1) OVER(ORDER BY Year, Month) AS last_month_sales
FROM(
SELECT
	EXTRACT(MONTH FROM o.order_date) As Month,
	EXTRACT(YEAR FROM o.order_date) AS Year,
	ROUND(SUM(oi.total_sales :: numeric),2) AS current_month_sales
FROM orders AS o
JOIN order_items AS oi
ON oi.order_id = o.order_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY Month,Year
ORDER BY Year, Month
) AS t1

```
---

5. Customers with No Purchases 🚫🛒
Find customers who have registered but never placed an order 👤.
Challenge: List customer details 📋 and the time since their registration ⏳.

```sql
-- Aproach_1
SELECT
	customer_id,
	first_name,
	last_name,
	state
FROM customers
WHERE customer_id NOT IN (
	SELECT
		DISTINCT(customer_id)
	FROM orders
);

-- Aproach_2
SELECT
	c.customer_id AS customer_id,
	c.first_name AS first_name,
	c.last_name AS last_name
FROM customers AS c
LEFT JOIN orders AS o
ON o.customer_id = c.customer_id
WHERE o.customer_id IS NULL;

```
---

6. Least-Selling Categories by State 📍
Identify the least-selling product category for each state 🏞️.
Challenge: Include the total sales for that category within each state 💸.
```sql
WITH ranking_by_state
AS(
	SELECT
		c.state AS state,
		ca.category_id AS category_id,
		ca.category_name AS category_name,
		SUM(oi.total_sales) As total_sales,
		RANK() OVER(PARTITION BY c.state ORDER BY SUM(oi.total_sales)) AS Rank
	FROM customers AS c
	JOIN orders AS o
	ON o.customer_id = c.customer_id
	JOIN order_items AS oi
	ON oi.order_id = o.order_id
	JOIN products AS p
	ON oi.product_id = p.product_id
	JOIN category AS ca
	ON ca.category_id  = p.category_id
	GROUP BY c.state, ca.category_id,ca.category_name
)

SELECT
	state,
	category_id,
	category_name,
	total_sales
FROM ranking_by_state
WHERE Rank = 1;

```

---

7. Customer Lifetime Value (CLTV) 💎
Calculate the total value of orders placed by each customer over their lifetime 👤💰.
Challenge: Rank customers based on their CLTV 📊.

```sql
SELECT
	c.customer_id AS customer_id,
	c.first_name AS first_name,
	c.last_name AS last_name,
	SUM(oi.total_sales) AS CLTV,
	DENSE_RANK() OVER(ORDER BY SUM(oi.total_sales) DESC) AS Rank
FROM orders AS o
JOIN customers As c
ON c.customer_id = o.customer_id
JOIN order_items As oi
ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY CLTV DESC;
```
---

8. Inventory Stock Alerts 🚨
Query products with stock levels below a certain threshold (e.g., less than 10 units) 📉.
Challenge: Include last restock date 📅 and warehouse information 🏢.

```sql
SELECT
	p.product_id AS product_id,
	p.product_name AS product_name,
	i.inventory_id AS inventory_id,
	i.stock AS stock,
	i.warehouse_id AS warehouse_id,
	i.last_stock_date AS last_stock_date
FROM products AS p
JOIN inventory AS i
ON i.product_id = p.product_id
WHERE i.stock < 10;
```
---

9. Shipping Delays 🚚⏳
Identify orders where the shipping date is later than 3 days after the order date 📅.
Challenge: Include customer 👤, order details 📦, and delivery provider 🚚.

```sql
SELECT
	c.customer_id AS customer_id,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	o.order_id AS order_id,
	o.order_date AS order_date,
	s.shipping_id AS shipping_id,
	s.shipping_date AS shipping_date,
	s.shipping_providers AS delivery_provider,
	s.shipping_date - o.order_date AS days_for_shipping
FROM orders AS o
LEFT JOIN shipping AS s
ON o.order_id = s.order_id
LEFT JOIN customers As c
ON o.customer_id = c.customer_id
WHERE s.shipping_date - o.order_date > 3
ORDER BY days_for_shipping DESC;
```
---

10. Payment Success Rate 💳✅
Calculate the percentage of successful payments across all orders 📊.
Challenge: Include breakdowns by payment status (e.g., failed ❌, pending ⏳).

```sql
SELECT
	payment_status,
	COUNT(payment_id) AS payment_count,
	ROUND((COUNT(*) / (SELECT COUNT(*) FROM payments)::numeric) * 100,2) AS percentage
FROM payments
GROUP BY payment_status
ORDER BY percentage DESC;
```
---

11. Top Performing Sellers 🏆
Find the top 5 sellers based on total sales value 💰.
Challenge: Include both successful ✔️ and failed ❌ orders, and display their percentage of successful orders 📊.

```sql
WITH top_sellers
AS(
	SELECT
		s.seller_id AS seller_id,
		s.seller_name AS seller_name,
		ROUND(SUM(oi.total_sales)::numeric ,2) AS sales_value
	FROM orders AS o
	LEFT JOIN sellers s
	ON o.seller_id = s.seller_id
	LEFT JOIN order_items AS oi
	ON o.order_id = oi.order_id
	GROUP BY s.seller_id,s.seller_name
	ORDER BY sales_value DESC
	LIMIT 5
),
sellers_report
AS(
	SELECT
		ts.seller_id AS seller_id,
		ts.seller_name AS seller_name,
		o.order_status AS order_status,
		COUNT(*) AS total_orders
	FROM orders as o
	JOIN top_sellers AS ts
	ON ts.seller_id = o.seller_id
	WHERE o.order_status NOT IN ('Returned','Inprogress')
	GROUP BY ts.seller_id, ts.seller_name, o.order_status
	ORDER BY seller_id
)
SELECT 
	seller_id,
	seller_name,
	SUM(CASE WHEN order_status = 'Completed' THEN total_orders ELSE 0 END) AS completed_orders,
	SUM(CASE WHEN order_status = 'Cancelled' THEN total_orders ELSE 0 END) AS cancelled_orders,
	SUM(total_orders) AS total_orders,
	ROUND(SUM(CASE WHEN order_status = 'Completed' THEN total_orders ELSE 0 END)::numeric / 
	SUM(total_orders)::numeric * 100, 2) AS percentage_sucessful_orders
FROM sellers_report
GROUP BY seller_id, seller_name
ORDER BY percentage_sucessful_orders DESC;

```
---

12. Product Profit Margin 💸
Calculate the profit margin for each product (difference between price and cost of goods sold) 🏷️.
Challenge: Rank products by their profit margin 📊, showing highest to lowest.



```sql
SELECT
	product_id,
	product_name,
	cost_price,
	selling_price,
	profit_margin,
	DENSE_RANK() OVER(ORDER BY profit_margin DESC) AS Margin_rank
FROM(
	SELECT
		p.product_id AS product_id,
		p.product_name AS product_name,
		ROUND(SUM((oi.quantity * p.cogs))::numeric,5) AS cost_price,
		ROUND(SUM(oi.total_sales)::numeric,5) AS selling_price,
		ROUND(((SUM(oi.total_sales)::numeric) - SUM((oi.quantity * p.cogs)))::numeric/
		(SUM(oi.total_sales)::numeric) * 100 ,5) AS profit_margin
	FROM orders AS o
	JOIN order_items AS oi
	ON oi.order_id = o.order_id
	JOIN products AS p
	ON p.product_id = oi.product_id
	GROUP BY p.product_id, p.product_name
) AS t1
```
---

13. Most Returned Products 🔄
Query the top 10 products by the number of returns 📦.
Challenge: Display the return rate as a percentage of total units sold for each product 📊.

```sql
SELECT
	p.product_id AS product_id,
	p.product_name AS product_name,
	p.price AS price,
	p.cogs AS cogs,
	COUNT(*) AS number_of_units_sold,
	SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS no_of_returned_units,
	ROUND(((SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END))::numeric
		/COUNT(*)::numeric) * 100 ,2)  AS return_rate
FROM orders AS o
LEFT JOIN order_items AS oi
ON oi.order_id = o.order_id
LEFT JOIN products AS p
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.price, p.cogs
ORDER BY return_rate DESC
LIMIT 10;

```
---

14. Orders Pending Delivery 🚚⏳
Find orders that have been paid but are still pending delivery 📦.
Challenge: Include order details 📋, payment date 💳, and customer information 👤.

```sql
-- observing the connection between order_statu and delivery_status
SELECT
	o.order_status,
	s.delivery_status
FROM orders AS o
JOIN shipping AS s
ON s.order_id = o.order_id
GROUP BY 1,2 -- order_status(Inprogress) = delivery_status(still pending, Shipped) --> not deliveried

-- Main solution
SELECT
	o.order_id AS order_id,
	o.order_date AS order_date,
	c.customer_id AS customer_id,
	c.first_name AS first_name,
	c.last_name AS last_name,
	p.payment_id AS payment_id,
	p.payment_date AS payment_date,
	p.payment_status AS payment_status,
	o.order_status AS delivery_status
FROM orders AS o
LEFT JOIN payments AS p
ON p.order_id = o.order_id
LEFT JOIN customers AS c
ON c.customer_id = o.customer_id
WHERE p.payment_status = 'Payment Successed'
	AND o.order_status = 'Inprogress'

```
---

15. Inactive Sellers 🚫🛍️
Identify sellers who haven’t made any sales in the last 6 months 📅.
Challenge: Show the last sale date 📆 and total sales from those sellers 💸.

```sql
WITH inactive_sellers
AS(
SELECT
	seller_id,
	seller_name,
	origin
FROM sellers
WHERE seller_id NOT IN(SELECT seller_id FROM orders WHERE order_date >= CURRENT_DATE - INTERVAL '6 months')
)

SELECT
	ias.seller_id,
	ias.seller_name,
	ias.origin,
	MAX(o.order_date) AS last_order_date,
	SUM(oi.total_sales) AS total_sales
FROM inactive_sellers AS ias
LEFT JOIN orders AS o
ON ias.seller_id = o.seller_id
LEFT JOIN order_items AS oi
ON o.order_id = oi.order_id
GROUP BY ias.seller_id, ias.seller_name, ias.origin
ORDER BY total_sales DESC;
```
---

16. Customer Segmentation: Returning or New 🔄🆕
Identify customers into returning or new based on return activity.
If the customer has done more than 5 returns, categorize them as returning 🔄; otherwise, categorize them as new 🆕.
Challenge: List customer ID 🆔, name 🏷️, total orders 📦, total returns 🔄, and total sales 💰.

```sql
SELECT
	customer_id,
	customer_name,
	total_orders,
	returned_orders,
	CASE WHEN returned_orders > 5 THEN 'Returning' ELSE 'New' END AS category,
	total_sales
FROM(
	SELECT
		c.customer_id AS customer_id,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		COUNT(*) AS total_orders,
		SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders,
		SUM(oi.total_sales) AS total_sales
	FROM customers AS c
	JOIN orders AS o
	ON o.customer_id = c.customer_id
	JOIN order_items AS oi
	ON oi.order_id = o.order_id
	GROUP BY 1,2
) t1
ORDER BY returned_orders DESC;
```
---

17. Cross-Sell Opportunities 🔄🛍️
Find customers who purchased product A but not product B (e.g., customers who bought Apple AirPods Max but not Apple AirPods 3rd Gen).
Challenge: Suggest cross-sell opportunities by displaying matching product categories 🛒.

```sql
WITH final_data
AS(
	SELECT
		o.order_id,
		cu.customer_id,
		cu.first_name,
		cu.last_name,
		p.product_id,
		p.product_name,
		ca.category_id,
		ca.category_name
	FROM orders AS o
	JOIN customers AS cu
	ON cu.customer_id = o.customer_id
	JOIN order_items AS oi
	ON oi.order_id = o.order_id
	JOIN products AS p
	ON p.product_id = oi.product_id
	JOIN category AS ca
	ON ca.category_id = p.category_id
)
SELECT
	customer_id,
	first_name,
	last_name,
	product_id,
	product_name,
	category_id,
	category_name
FROM final_data
WHERE product_name = 'Apple AirPods Max'
	AND customer_id NOT IN(SELECT
								customer_id
							FROM final_data
							WHERE product_name = 'Apple AirPods 3rd Gen');
	
```
---

18. Top 5 Customers by Orders in Each State 🏆🌍
Identify the top 5 customers with the highest number of orders for each state 🗺️.
Challenge: Include the number of orders 📦 and total sales 💰 for each customer.

```sql
SELECT
	state,
	customer_name,
	no_of_orders,
	total_sales
FROM(
	SELECT
		c.state AS state,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		COUNT(o.order_id) AS no_of_orders,
		SUM(oi.total_sales) AS total_sales,
		DENSE_RANK() OVER(PARTITION BY c.state ORDER BY COUNT(o.order_id) DESC) AS Rank
	FROM orders AS o
	JOIN customers AS c
	ON c.customer_id = o.customer_id
	JOIN order_items AS oi
	ON oi.order_id = o.order_id
	GROUP BY 1,2
	ORDER BY state , 3 DESC
) AS t1
WHERE Rank<=5
```
---

19. Revenue by Shipping Provider 🚚💵
Calculate the total revenue handled by each shipping provider.
Challenge: Include the total number of orders 📦 handled and the average delivery time ⏱️ for each provider.

```sql
SELECT
	s.shipping_providers AS shipping_provider,
	COUNT(o.order_id) AS total_orders,
	SUM(oi.total_sales) AS total_sales,
	AVG(s.shipping_date - o.order_date) AS average_delivery_time
FROM orders AS o
JOIN order_items AS oi
ON oi.order_id = o.order_id
JOIN shipping AS s
ON s.order_id = o.order_id
GROUP BY shipping_provider
ORDER BY total_sales DESC;	
```
---

20. Top 10 Products with Highest Decreasing Revenue Ratio 📉📦
Compare the revenue ratio of products from 2022 to 2023 and identify the top 10 products with the highest decrease in revenue.
Challenge: Return product_id, product_name, category_name, 2022 revenue, and the 2023 revenue decrease ratio (rounded to 2 decimal places).

Note: Decrease ratio = cr-ls/ls* 100 (cs = current_year ls=last_year)

```sql
WITH previous_year_data
AS(
SELECT
	p.product_id AS product_id,
	p.product_name AS product_name,
	c.category_name AS category_name,
	COUNT(o.order_id) AS previous_year_orders,
	SUM(total_sales) AS previous_year_sales
FROM orders AS o
JOIN order_items AS oi
ON oi.order_id = o.order_id
JOIN products AS p
ON p.product_id = oi.product_id
JOIN category AS c
ON c.category_id = p.category_id
WHERE EXTRACT(YEAR FROM order_date) = 2022
	AND o.order_status IN ('Completed', 'Inprogress')
GROUP BY 1,2,3
),
current_year_data
AS(
SELECT
	p.product_id AS product_id,
	p.product_name AS product_name,
	c.category_name AS category_name,
	COUNT(o.order_id) AS current_year_orders,
	SUM(total_sales) AS current_year_sales
FROM orders AS o
JOIN order_items AS oi
ON oi.order_id = o.order_id
JOIN products AS p
ON p.product_id = oi.product_id
JOIN category AS c
ON c.category_id = p.category_id
WHERE EXTRACT(YEAR FROM order_date) = 2023
	AND o.order_status IN ('Completed', 'Inprogress')
GROUP BY 1,2,3
)

SELECT
	p.product_id AS product_id,
	p.product_name AS product_name,
	p.category_name AS category_name,
	p.previous_year_orders AS previous_year_orders,
	c.current_year_orders::numeric AS current_year_orders,
	ROUND(p.previous_year_sales::numeric,2) AS previous_year_sales,
	ROUND(c.current_year_sales::numeric,2) AS current_year_sales,
	CASE 
        WHEN p.previous_year_sales = 0 THEN NULL
        ELSE ROUND(((c.current_year_sales - p.previous_year_sales)::numeric / p.previous_year_sales::numeric) * 100,2)
    END AS Ratio
FROM previous_year_data AS p
JOIN current_year_data AS c
ON p.product_id = c.product_id
ORDER BY Ratio ASC
LIMIT 10;
```
---

Final Task
🚀 Store Procedure
Create a function 🛠️ that automatically reduces the quantity from the inventory table 📦 as soon as a product is sold. 
When a sale is recorded 💳, it should update the stock in the inventory table based on the product ID and the quantity purchased 🛒.


```sql
CREATE OR REPLACE PROCEDURE add_orders
(
p_order_id INT,
-- p_order_date -- current date
p_customer_id INT,
p_seller_id INT,
p_category_id INT,
-- p_order_status -- Inprogress
p_order_item_id INT,
p_product_id INT,
p_quantity INT,
p_payment_id INT,
-- p_payment_date -- current date
p_payment_status VARCHAR(20)
)
LANGUAGE plpgsql
AS $$

DECLARE
v_stock INT;
v_price_per_unit FLOAT;
v_product_name TEXT;

BEGIN
	-- Checking whether the stock is available or not
	SELECT
		COUNT(*) INTO v_stock
	FROM inventory 
	WHERE product_id = p_product_id
		AND stock >= p_quantity;

	SELECT
		price_per_unit INTO v_price_per_unit
	FROM order_items
	WHERE product_id = p_product_id;

	SELECT
		product_name INTO v_product_name
	FROM products
	WHERE product_id = p_product_id;
	
	IF v_stock > 0 THEN
		-- Updating inventory
		UPDATE inventory
		SET stock = stock - p_quantity,
			last_stock_date = CURRENT_DATE
		WHERE product_id = p_product_id;
		
		-- Adding order into orders
		INSERT INTO orders(order_id, order_date, customer_id, seller_id, order_status)
		VALUES(p_order_id, CURRENT_DATE, p_customer_id, p_seller_id, 'Inprogress');

		-- Adding order into order_items
		INSERT INTO order_items(order_item_id, order_id, product_id, quantity, price_per_unit, total_sales)
		VALUES(p_order_item_id, p_order_id, p_product_id, p_quantity, v_price_per_unit, p_quantity*v_price_per_unit);

		-- Updating products table
		UPDATE products
		SET cogs = cogs+p_quantity
		WHERE product_id = p_product_id
			AND category_id = p_category_id;

		-- Adding payments
		INSERT INTO payments(payment_id, order_id, payment_date, payment_status)
		VALUES (p_payment_id, p_order_id, CURRENT_DATE, p_payment_status);

		RAISE NOTICE 'Thank you product: % with id % sale has been added also inventory stock updated', v_product_name, p_product_id;

	ELSE
		RAISE NOTICE 'Thank you for you information: product % with id % of % quantity is not available', v_product_name, p_product_id, p_quantity;

	END IF;

END;
$$

```
---


## **Learning Outcomes** 📚

This project enabled me to:
- 🎨 Design and implement a normalized **database schema**.
- 🧹 Clean and preprocess real-world datasets for **analysis**.
- 🧠 Use advanced **SQL techniques**, including **window functions**, **subqueries**, and **joins**.
- 📊 Conduct in-depth **business analysis** using SQL.
- 🚀 Optimize **query performance** and handle large datasets efficiently.

---

## **Conclusion** 🎯

This advanced SQL project successfully demonstrates my ability to solve real-world **e-commerce** problems using structured queries. From improving **customer retention** to optimizing **inventory** and **logistics**, the project provides valuable insights into operational challenges and solutions.

By completing this project, I have gained a deeper understanding of how SQL can be used to tackle complex data problems and drive **business decision-making**.

---

### **Entity Relationship Diagram (ERD)**
![ERD](https://github.com/Jana2207/Amazon_data_analytics_using_sql/blob/main/amazon%20ERD.png)

---
