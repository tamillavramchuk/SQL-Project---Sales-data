-- Creating all necessary tables using sales_data.csv file. 

/* As I use Oracle APEX, it automatically identifies the data type of the columns, so no need to modify them after creating. 
In another case, I would use ALTER TABLE + MODIFY to change data type
*/
-- Table customers 
CREATE TABLE customers as (SELECT DISTINCT
    CUSTOMERNAME AS customer_name,
    CONTACTFIRSTNAME AS contact_first_name,
    CONTACTLASTNAME AS contact_last_name,
    PHONE AS phone,
    ADDRESSLINE1 AS address,
    CITY AS city,
    COUNTRY AS country,
    POSTALCODE AS postal_code
FROM SALES_DATA);
-- Creating primary key for table customers. GENERATED ALWAYS AS IDENTITY PRIMARY KEY helds to create unique primary keys
ALTER TABLE customers ADD customer_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY;
-- Table products 
CREATE TABLE products AS
(SELECT DISTINCT
    PRODUCTCODE AS product_code,
    PRODUCTLINE AS product_line,
    MSRP AS msrp,
    PRICEEACH AS price_each
FROM SALES_DATA);
-- Creating primary key for table products
ALTER TABLE products ADD product_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY;
-- Table orders
CREATE TABLE orders AS
(SELECT DISTINCT
    ORDERNUMBER AS order_id,
    CUSTOMERNAME AS customer_name,
    ORDERDATE AS order_date,
    STATUS AS status,
    DEALSIZE AS deal_size,
    QTR_ID AS qtr_id,
    MONTH_ID AS month_id,
    YEAR_ID AS year_id
FROM SALES_DATA);
-- Creating primary key for table orders. We could see that we have already had order_id in the table. So we could try to make this column as primary key. But there is only one "but"
ALTER TABLE orders ADD CONSTRAINT pk_orders PRIMARY KEY (order_id);
-- The order_id attribute has duplicates, we have an error running the above query. So there is no way we could created a primary key using only this column. 
-- Let's check, if we could create composite primary key. The first option for second column for PK that came to my mind is customer_name. Let's check if it could be unique.
SELECT order_id, customer_name, COUNT(*) AS cnt
FROM orders
GROUP BY order_id, customer_name
HAVING COUNT(*) > 1;
-- Unfortunately there are so many duplicates again, but let's check the first order_id from the query above. Check the row with order_is = 10211
SELECT *
FROM orders
WHERE order_id = 10211
-- We could see that the difference between all of these orders id is deal_size. Let's check it for uniqueness.
-- -- Besides, it's good to check all the columns if there is null rows, but in that case PK won't be created and we will get an error.
SELECT order_id, deal_size, COUNT(*) AS cnt
FROM orders
GROUP BY order_id, deal_size
HAVING COUNT(*) > 1;
-- No data found. Excellent. So we could use this table for creating a PK for orders table. 
ALTER TABLE orders ADD CONSTRAINT pk_orders PRIMARY KEY (order_id,deal_size)
-- Table orders details
CREATE TABLE order_details AS
(SELECT
    ORDERNUMBER AS order_id,
    PRODUCTCODE AS product_code,
    QUANTITYORDERED AS quantity_ordered,
    ORDERLINENUMBER AS order_line_number,
    SALES AS sales
FROM SALES_DATA);
-- We will do the same thing for order_details table as we did for table orders. 
-- Checking uniqueness for PK
SELECT order_id, order_line_number, COUNT(*) AS cnt
FROM order_details
GROUP BY order_id, order_line_number
HAVING COUNT(*) > 1;
-- Creating PK for order_details table
ALTER TABLE order_details ADD CONSTRAINT pk_order_details PRIMARY KEY (order_id,order_line_number)