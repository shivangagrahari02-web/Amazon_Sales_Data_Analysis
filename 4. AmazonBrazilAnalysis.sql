/*Analysis - I

1. To simplify its financial reports, Amazon India needs to standardize payment values. 
Round the average payment values to integer (no decimal) for each payment type and display the results sorted in ascending order.
Output: payment_type, rounded_avg_payment*/

select payment_type, ROUND(avg(payment_value)) as rounded_avg_payment
from payments
where payment_value > 0
group by payment_type
order by rounded_avg_payment;

/* 2. To refine its payment strategy, Amazon India wants to know the distribution of orders by payment type. 
Calculate the percentage of total orders for each payment type, rounded to one decimal place, and display them in descending order
Output: payment_type, percentage_orders*/

select payment_type, Round(count(payment_type)*100/(select count(distinct(order_id)) from payments), 1)
as percentage_orders
from payments
where payment_value > 0 
group by payment_type
order by percentage_orders desc;

/* 3. Amazon India seeks to create targeted promotions for products within specific price ranges. 
Identify all products priced between 100 and 500 BRL that contain the word 'Smart' in their name. 
Display these products, sorted by price in descending order.
Output: product_id, price*/

Select P.product_id, O.price as Price
from products as P
join order_items as O
on P.product_id = O.product_id 
where (O.price between '100' and '500')
AND (P.product_category_name like '%smart%')
Order by O.price desc;

/* 4. To identify seasonal sales patterns, Amazon India needs to focus on the most successful months. 
Determine the top 3 months with the highest total sales value, rounded to the nearest integer.
Output: month, total_sales*/

Select TO_CHAR(O.order_purchase_timestamp, 'Month') as Months, Round(sum(P.payment_value)) as Total_sales
from orders as O
join payments as P 
on O.order_id = P.order_id
group by Months
order by Total_sales desc
limit 3;

/* 5. Amazon India is interested in product categories with significant price variations. 
Find categories where the difference between the maximum and minimum product prices is greater than 500 BRL.
Output: product_category_name, price_difference*/

select P.product_category_name, (max(OI.price) - min(OI.price)) as price_difference
from Products as P
Join Order_items as OI 
on P.product_id = OI.product_id 
group by P.product_category_name
having (max(OI.price) - min(OI.price)) > 500
order by price_difference desc;

/* 6. To enhance the customer experience, Amazon India wants to find which payment types have the most consistent transaction amounts. 
Identify the payment types with the least variance in transaction amounts, sorting by the smallest standard deviation first.
Output: payment_type, std_deviation */

select payment_type, STDDEV_SAMP(payment_value) as std_deviation
from payments
where payment_value > 0
group by payment_type
order by std_deviation;

/* 7. Amazon India wants to identify products that may have incomplete name in order to fix it from their end. 
Retrieve the list of products where the product category name is missing or contains only a single character.
Output: product_id, product_category_name */

select product_id, product_category_name
from products 
where
product_category_name like '_' 
/* Analysis - II

1. Amazon India wants to understand which payment types are most popular across different order value segments (e.g., low, medium, high). 
Segment order values into three ranges: orders less than 200 BRL, between 200 and 1000 BRL, and over 1000 BRL. 
Calculate the count of each payment type within these ranges and display the results in descending order of count
Output: order_value_segment, payment_type, count */

select order_value_segment, payment_type, count(payment_type) as counts
from (select payment_type, payment_value,
case
when payment_value < 200 then 'low'
when payment_value between 200 and 1000 then 'medium'
Else 'High'
End as order_value_segment
from payments)
group by payment_type, order_value_segment
order by counts desc;

/* 2. Amazon India wants to analyse the price range and average price for each product category. 
Calculate the minimum, maximum, and average price for each category, and list them in descending order by the average price.
Output: product_category_name, min_price, max_price, avg_price*/

select P.product_category_name, 
min(OI.price) as min_price, max(OI.price) as max_price, avg(OI.price) as avg_price
from products as P 
join order_items as OI
on P.product_id = OI.product_id
group by P.product_category_name
order by avg_price desc;

/* 3. Amazon India wants to identify the customers who have placed multiple orders over time. 
Find all customers with more than one order, and display their customer unique IDs along with 
the total number of orders they have placed.
Output: customer_unique_id, total_orders */

select C.customer_unique_id, count(O.order_id) as total_orders
from customers as C
join orders as O
on C.customer_id = O.customer_id
group by C.customer_unique_id
having count(O.order_id) > 1
order by total_orders desc;

/* 4. Amazon India wants to categorize customers into different types 
('New – order qty. = 1' ;  'Returning' –order qty. 2 to 4;  'Loyal' – order qty. >4) 
based on their purchase history. Use a temporary table to define these categories 
and join it with the customers table to update and display the customer types.
Output: customer_id, customer_type */

WITH cte_temp as (
select  C.customer_id, count(O.order_id) as total_orders
from customers as C
join orders as O
on C.customer_id = O.customer_id
group by C.customer_id
order by total_orders desc
)
select customer_id, 
case 
when total_orders = 1 then 'New'
when total_orders between 2 and 4 then 'Returning'
Else 'loyal'
END AS customer_type
From cte_temp

/* 5. Amazon India wants to know which product categories generate the most revenue. 
Use joins between the tables to calculate the total revenue for each product category. 
Display the top 5 categories.
Output: product_category_name, total_revenue */

select P.product_category_name, sum(payment_value) as total_revenue
from products as P 
join order_items as OI
on P.product_id = OI.product_id
join payments as PM
ON OI.order_id = PM.order_id
group by P.product_category_name
order by sum(payment_value) desc
limit 5;


/* Analysis - III

1. The marketing team wants to compare the total sales between different seasons. 
Use a subquery to calculate total sales for each season (Spring, Summer, Autumn, Winter) 
based on order purchase dates, and display the results. Spring is in the months of March, April and May. 
Summer is from June to August and Autumn is between September and November and rest months are Winter. 
Output: season, total_sales */

With my_cte(
select order_id, 
case 
when months between 3 and 5 then 'Spring'
when months between 6 and 8 then 'Summer'
when months between 9 and 11 then 'Autum'
else 'Winter'
End as season
from (select order_id, EXTRACT(MONTH FROM order_purchase_timestamp) as months
from orders)
) 
select T1
from my_cte as T1
join payments as P 
on T1.order_id = P.order_id
group by or

/*2. The inventory team is interested in identifying products that have sales volumes above the overall average.
Write a query that uses a subquery to filter products with a total quantity sold above the average quantity. 
Output: product_id, total_quantity_sold */

with my_cte as (select product_id, count(order_id) as total_quantity_sold 
from order_items 
group by product_id)
select product_id, total_quantity_sold
from my_cte
where total_quantity_sold > (select avg(total_quantity_sold) from my_cte)
order by total_quantity_sold desc;

/* 3 To understand seasonal sales patterns, the finance team is analysing the monthly revenue trends over the past year (year 2018). 
Run a query to calculate total revenue generated each month and identify periods of peak and low sales. 
Export the data to Excel and create a graph to visually represent revenue changes across the months. Output: month, total_revenue */

with my_cte as (select order_id, TO_CHAR(order_purchase_timestamp, 'MM') as months
from orders 
where EXTRACT(YEAR FROM order_purchase_timestamp) = 2018
)
select months, sum(P.payment_value) as total_revenue
from my_cte as T1
join payments as P
on T1.order_id = P.order_id
group by months
order by months ;

/* 4. A loyalty program is being designed for Amazon India. Create a segmentation based on purchase frequency: 
‘Occasional’ for customers with 1-2 orders, ‘Regular’ for 3-5 orders, and ‘Loyal’ for more than 5 orders. 
Use a CTE to classify customers and their count and generate a chart in Excel to show the proportion of each segment. 
Output: customer_type, count*/

with T1 as (
with T2 as (select customer_id, count(order_id) as order_counts
from orders
group by customer_id) 
select customer_id,
case 
when order_counts between 1 and 2 then 'occasional'
when order_counts between 3 and 5 then 'regural' 
else 'loyal'
end as customer_type
from T2)
select customer_type, count(*)
from T1
group by customer_type
order by count(*) desc;

/* 5. Amazon wants to identify high-value customers to target for an exclusive rewards program. 
You are required to rank customers based on their average order value (avg_order_value) to find the top 20 customers. 
Output: customer_id, avg_order_value, and customer_rank */

with my_cte as (select customer_id, Round(avg(payment_value)) as avg_order_value
from orders as O
join payments as P 
on O.order_id = P.order_id
group by customer_id) 
select customer_id, avg_order_value,
DENSE_RANK () OVER (order by avg_order_value desc)
as customer_rank
from my_cte
limit 20;

/* 6. Amazon wants to analyze sales growth trends for its key products over their lifecycle. 
Calculate monthly cumulative sales for each product from the date of its first sale.
Use a  CTE to compute the cumulative sales (total_sales) for each product month by month. 
Output: product_id, sale_month, and total_sales */


with table1 as (select OI.product_id,
TO_CHAR(O.order_purchase_timestamp, 'YYYY-MM') AS
sales_month, sum(P.payment_value) as monthly_sales
from order_items as OI
join orders as O 
on OI.order_id = O.order_id 
join payments as P 
on O.order_id = P.order_id
group by product_id, sales_month)
select product_id, sales_month, monthly_sales,
sum(monthly_sales)over(partition by (product_id) order by sales_month) 
as Total_sales
from table1;


/* 7. To understand how different payment methods affect monthly sales growth, 
Amazon wants to compute the total sales for each payment method and calculate the month-over-month growth rate for 
the past year (year 2018). Write query to first calculate total monthly sales for each payment method, 
then compute the percentage change from the previous month. Output: payment_type, sale_month, monthly_total, monthly_change. */

with table1 as (select P.payment_type, TO_CHAR(order_purchase_timestamp, 'YYYY-MM') as
sale_month, sum(payment_value) as monthly_sales
from payments as P
Join orders as O
On O.order_id = P.order_id 
where EXTRACT(YEAR FROM order_purchase_timestamp) = 2018 
group by payment_type, sale_month
order by payment_type, sale_month),
table2 as (
select payment_type, sale_month, monthly_sales, 
LAG(monthly_sales) over(partition by payment_type order by sale_month) as 
previous_month_sales
from table1)
select payment_type, sale_month, monthly_sales, 
ROUND((monthly_sales - previous_month_sales)*100/NULLIF(previous_month_sales,0), 2) AS 
monthly_change
FROM table2
