/*
This file provides an overview of the sales documented in the source database.

Questions answered:
1. What is the total sales, profit, quantity, and average discount given?
2. How do sales and profit trend over time?
3. Which product categories and subcategories generate the most profit?
4. Which states generate the most profit and sales?
5. Which cities, among the top 3 states with highest profit, generate the most profit?
6. What is the profit margin by category and by state?
7. What are top 10 products and top 10 customers by profit margin?
8. What is the profit margin per discount bucket?
9. What is the average amount of days between order and shipping (by ship_mode)?
 */

-- 1. What is the total sales, profit, quantity, and average discount given?
select 
	sum(sales) as total_sales,
	sum(profit) as total_profit,
	sum(quantity) as total_quantity,
	avg(discount)::numeric(5,4) as average_discount
from mart.fact_sales;

-- 2. How do sales and profit trend over time?
select 
	d.year as year,
	d.quarter as quarter,
	sum(s.sales) as total_sales,
	sum(s.profit) as total_profit
from mart.fact_sales as s
join mart.dim_date as d
	on s.order_date_day = d.date_day
group by d.year, d.quarter
order by d.year, d.quarter;

-- 3. Which product categories and subcategories generate the most profit?
select
	p.category as category,
	sum(s.profit) as profit
from mart.fact_sales as s
join mart.dim_product as p
	on s.product_id = p.product_id
group by p.category
order by profit desc;

select
	p.sub_category as sub_category,
	p.category as category,
	sum(s.profit) as profit
from mart.fact_sales as s
join mart.dim_product as p
	on s.product_id = p.product_id
group by p.sub_category, p.category 
order by profit desc;

-- 4. Which states generate the most profit and sales?
select 
	state,
	sum(profit) as profit,
	sum(sales) as sales
from mart.fact_sales
group by state
order by profit desc;

select 
	state,
	sum(sales) as sales,
	sum(profit) as profit
from mart.fact_sales
group by state
order by sales desc;

-- 5. Which cities, among the top 3 states with highest profit, generate the most profit?
with top_states as(
	select 
		state,
		sum(profit) as profit
	from mart.fact_sales
	group by state
	order by profit desc
	limit 3
)
select
	state,
	city,
	sum(profit) as profit
from mart.fact_sales
where state in(
	select state
	from top_states)
group by state, city
order by profit desc;

-- 6. What is the profit margin by category and by state?
select 
	p.category as category,
	(sum(s.profit) / nullif(sum(s.sales), 0)) as profit_margin
from mart.fact_sales as s
join mart.dim_product as p
	on s.product_id = p.product_id
group by p.category
order by profit_margin desc;

select 
	state,
	(sum(profit) / nullif(sum(sales), 0)) as profit_margin
from mart.fact_sales
group by state
order by profit_margin desc;

-- 7. What are top 10 products and top 10 customers by profit margin?
select 
	p.product_name as product_name,
	round((sum(s.profit) / nullif(sum(s.sales), 0)), 4) as profit_margin
from mart.fact_sales as s
join mart.dim_product as p
	on s.product_id = p.product_id
group by p.product_name
order by profit_margin desc
limit 10;

select 
	c.customer_name as customer_name,
	round((sum(s.profit) / nullif(sum(s.sales), 0)), 4) as profit_margin
from mart.fact_sales as s
join mart.dim_customer as c
	on s.customer_id = c.customer_id
group by c.customer_name
order by profit_margin desc
limit 10;

-- 8. What is the profit margin per discount bucket?
select 
	case when (discount = 0) then '0.0'
	when (discount > 0 and discount <= 0.2) then '0.0 - 0.2'
	when (discount > 0.2 and discount <= 0.4) then '0.2 - 0.4'
	when (discount > 0.4 and discount <= 0.6) then '0.4 - 0.6'
	when (discount > 0.6 and discount <= 0.8) then '0.6 - 0.8'
	else '> 0.8'
	end as discount_size,
	round((sum(profit) / nullif(sum(sales), 0)), 4) as profit_margin
from mart.fact_sales
group by discount_size
order by discount_size;

-- 9. What is the average amount of days between order and shipping (by ship_mode)?
select 
	ship_mode,
	avg((ship_date_day - order_date_day))::numeric(6,4) as avg_shipping_delay_days
from mart.fact_sales
group by ship_mode
order by avg_shipping_delay_days;
