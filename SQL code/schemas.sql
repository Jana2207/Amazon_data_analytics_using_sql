-- Amazon Sales Data Analysis

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


SELECT * FROM category;
SELECT * FROM customers;
SELECT * FROM sellers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;
SELECT * FROM shipping;
SELECT * FROM inventory;
