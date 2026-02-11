/*
This file provides an analysis of the customers documented in the source database.

Questions answered:
1. Who are the top 10 customers by total sales, total profit and profit margin?
2. What percentage of total profit comes from the top 10 customers (by profit)?
3. How many orders does each customer place and what does the distribution look like?
4. What is the average order value per customer?
5. What are the customer segments with the highest sales, profit and profit margin?
6. Which are the oldest customers in the database and how many orders have they placed?
7. What percentage of customers place more than one order?
 */

-- 1. Who are the top 10 customers by total sales, total profit and profit margin?
select 
	c.customer_id as customer_id,
	c.customer_name as customer,
	sum(s.sales) as sales,
	sum(s.profit) as profit,
	round((sum(s.profit) / nullif(sum(s.sales), 0)),4) as profit_margin
from mart.fact_sales as s
join mart.dim_customer as c
	on s.customer_id = c.customer_id
group by c.customer_id, c.customer_name
order by sales desc
limit 10;

select 
	c.customer_id as customer_id,
	c.customer_name as customer,
	sum(s.sales) as sales,
	sum(s.profit) as profit,
	round((sum(s.profit) / nullif(sum(s.sales), 0)),4) as profit_margin
from mart.fact_sales as s
join mart.dim_customer as c
	on s.customer_id = c.customer_id
group by c.customer_id, c.customer_name
order by profit desc
limit 10;

select 
	c.customer_id as customer_id,
	c.customer_name as customer,
	sum(s.sales) as sales,
	sum(s.profit) as profit,
	round((sum(s.profit) / nullif(sum(s.sales), 0)),4) as profit_margin
from mart.fact_sales as s
join mart.dim_customer as c
	on s.customer_id = c.customer_id
group by c.customer_id, c.customer_name
order by profit_margin desc
limit 10;

-- 2. What percentage of total profit comes from the top 10 customers (by profit)?
with top_10_customers as(
	select 
		c.customer_id as customer_id,
		c.customer_name as customer,
		sum(s.profit) as profit
	from mart.fact_sales as s
	join mart.dim_customer as c
		on s.customer_id = c.customer_id
	group by c.customer_id, c.customer_name
	order by profit desc
	limit 10
)
select 
	round(sum(profit)/
	(select sum(profit)
	from mart.fact_sales)*100,2) as percentage_of_total
from top_10_customers;

-- 3. How many orders does each customer place and what does the distribution look like?
select
	c.customer_id as customer_id,
	c.customer_name as customer_name,
	count(distinct order_id) as count_of_orders
from mart.fact_sales as s
join mart.dim_customer as c
	on s.customer_id = c.customer_id
group by c.customer_id, c.customer_name
order by count_of_orders desc;

with count_of_orders as(
	select
		customer_id as customer_id,
		count(distinct order_id) as count_of_orders
	from mart.fact_sales as s
	group by customer_id
)
select
	case when count_of_orders >= 0 and count_of_orders <= 5 then '1 - Up to 5 orders'
	when count_of_orders > 5 and count_of_orders <= 10 then '2 - Between 6 and 10 orders'
	when count_of_orders > 10 and count_of_orders <= 15 then '3 - Between 11 and 15 orders'
	else '4 - More than 15 orders'
	end as count_of_orders_bucket,
	count(distinct customer_id) as count_of_clients
from count_of_orders
group by count_of_orders_bucket
order by count_of_orders_bucket;


-- 4. What is the average order value per customer?
select
	c.customer_id as customer_id,
	c.customer_name as customer_name,
	round(sum(s.sales) / count(distinct s.order_id),4) as average_sales_value
from mart.fact_sales as s
join mart.dim_customer as c
	on s.customer_id = c.customer_id
group by c.customer_id, c.customer_name
order by average_sales_value desc;

-- 5. What are the customer segments with the highest sales, profit and profit margin?
select 
	c.segment as customer_segment,
	sum(s.sales) as sales,
	sum(s.profit) as profit,
	round((sum(s.profit) / nullif(sum(s.sales), 0)),4) as profit_margin
from mart.fact_sales as s
join mart.dim_customer as c
	on s.customer_id = c.customer_id
group by c.segment
order by sales desc;

-- 6. Which are the oldest customers in the database and how many orders have they placed?
select 
	c.customer_id as customer_id,
	c.customer_name as customer_name,
	min(s.order_date_day) as oldest_order,
	count(distinct order_id) as number_of_orders
from mart.fact_sales as s
join mart.dim_customer as c
	on s.customer_id = c.customer_id
group by c.customer_id, c.customer_name
order by oldest_order
limit 10;

-- 7. What percentage of customers place more than one order?
with number_of_orders as (
	select
		customer_id,
		count(distinct order_id) as count_of_orders
	from mart.fact_sales
	group by customer_id
	having count(distinct order_id) > 1
)
select
	round(
		(select count(distinct customer_id) from number_of_orders)::numeric
		/ count(distinct customer_id)*100
	,2) as pct_customers_with_more_than_1_order
from mart.fact_sales;
