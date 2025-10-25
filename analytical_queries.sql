-- Data Analytics function

/* 1. Your manager asked you to present results about your total customers, total orders and total of products. Let's use UNION ALL to present it using one query*/
SELECT 'Customers' AS category, COUNT(*) AS total FROM customers
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Products', COUNT(*) FROM products
 
 /* 2. Your manager asked you about top 5 countries with most clients. That means we need to use GROUP BY function.*/ 
SELECT country, COUNT(*) AS num_customers
FROM customers
GROUP BY country
ORDER BY num_customers DESC
FETCH FIRST 5 ROWS ONLY

/* 3. Your manager asked you to prepare a list of total sales by client. Here we need to calculate total sales using quantity_ordered - the number of products - 
from order_details table and price_each - actual price of 1 product - from product table. Using several joins we could connect all the tables to be able to complete the task*/
SELECT 
    c.customer_name,
    SUM(od.quantity_ordered * p.price_each) AS total_sales
FROM customers c
JOIN orders o 
    ON c.customer_name = o.customer_name
JOIN order_details od 
    ON o.order_id = od.order_id
JOIN products p 
    ON od.product_code = p.product_code
GROUP BY c.customer_name
ORDER BY total_sales DESC;

/* 4. Your manager asked you to present average price of orders. 
I created a subquery to find total sales of orders. 
And from the table of this subquery we calculate average price.  */ 
SELECT 
    ROUND(AVG(order_total),2) AS avg_order_value
FROM (
    SELECT 
        o.order_id, 
        SUM(od.quantity_ordered * p.price_each) AS order_total
    FROM orders o
    JOIN order_details od 
        ON o.order_id = od.order_id
    JOIN products p 
        ON od.product_code = p.product_code
    GROUP BY o.order_id
);

/* 5. Your manager asked you to present top 10 products type by revenue*/
SELECT 
    p.product_line,
    SUM(od.quantity_ordered * p.price_each) AS revenue
FROM products p
JOIN order_details od 
ON od.product_code = p.product_code
GROUP BY p.product_line
ORDER BY revenue DESC
FETCH FIRST 10 ROWS ONLY;

/* 6. Your manager asked you to bring him the data about total sales by customers and products. We need to group our data by customers and products. 
That means we need to join at least 2 tables: customers and products. But the main character is sales column, which belongs to order_details table.
So we need to join 3 tables to get the request. 
As we could see the orders table and order_details table have the same column order_id, which we could use to join those tables.
Next check the customers table and orders table: the same column is customer_name. 
And the last one: order_details has the same column product_code as product table. Now we have all the relations detected between tables, so we could join them.
To save the result we could also create a view for this query, so the data won't be missed
*/
CREATE VIEW sales_by_customers_and_product as 
SELECT c.customer_name, p.product_line, SUM(od.sales) AS total_sales
FROM order_details od 
JOIN orders o ON od.order_id = o.order_id
JOIN customers c ON o.customer_name = c.customer_name 
JOIN products p ON od.product_code = p.product_code 
GROUP BY c.customer_name, p.product_line
ORDER BY total_sales DESC

/* 7. Your manager asked you to compare average price of each product with MSRP (it stands for Manufacturer’s Suggested Retail Price)
So we calculated the average actual price, selecting also the recommended price and after that we calculated the percentage ratio between them. 
What could the percentage ratio tell us? If it's >100, then product are sold about recommended price, which could be rare, in another case it's an opposite situation*/ 
SELECT 
    product_line,
    ROUND(AVG(price_each), 2) AS avg_sold_price,
    msrp,
    ROUND(AVG(price_each) / msrp * 100, 1) AS pct_of_msrp
FROM products 
GROUP BY product_line, msrp
ORDER BY pct_of_msrp DESC;

/* 8. Your manager asked you to create a report about total sales in each month. 
We need to extract the month and the year from the order date using to_char, which changes the date into the character string. */
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') AS month,
    SUM(od.quantity_ordered * p.price_each) AS total_sales
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p on p.product_code = od.product_code
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY month;

/* 9. Your manager asked you to create a report about type of customers. He said that every customer with total sales up 1000000 should be considered as VIP.
The ones with sales between 500000 and 1000000 are regular ones, the rest of the customers should have "low value" type. 
As we already calculated the revenues several times, we just need to create new attribute named customer_type,
using CASE WHEN we could ask a compiler to split the customers*/
SELECT 
    c.customer_name,
    SUM(od.quantity_ordered * p.price_each) AS total_sales,
    CASE 
        WHEN SUM(od.quantity_ordered * p.price_each) > 1000000 THEN 'VIP'
        WHEN SUM(od.quantity_ordered * p.price_each) BETWEEN 500000 AND 1000000 THEN 'Regular'
        ELSE 'Low value'
    END AS customer_type
FROM customers c
JOIN orders o ON c.customer_name = o.customer_name
JOIN order_details od ON o.order_id = od.order_id
JOIN products p on p.product_code = od.product_code
GROUP BY c.customer_name
ORDER BY total_sales ASC;

/* 10. Your manager asked me to create a ranking based on revenues by product type. Firstly, we calculated all the revenues, 
then using function RANK we could creating rankings. Group by product type, cause we want to know which product type is number 1 :) */
SELECT 
    p.product_line,
    SUM(od.quantity_ordered * p.price_each) AS revenue,
    RANK() OVER (ORDER BY SUM(od.quantity_ordered * p.price_each) DESC) AS rank_by_sales
FROM products p
JOIN order_details od ON p.product_code = od.product_code
GROUP BY p.product_line
ORDER BY rank_by_sales;