/*
This file provides an analysis of the products documented in the source database and their sales performance.

Questions answered:
1. What are the top 10 products by profit, sales and profit margin?
2. How do sales, profit and margin differ by category and sub-category?
3. Which products sell in the highest quantities and what's the profit from them?
4. Among the top 10 selling products - what is the profit margin by discount bucket?
5. What percentage of total profit comes from the top 10 products by quantity sold?

*/

-- 1. What are the top 10 products by profit, sales and profit margin?
select
	p.product_id as product_id,
	p.product_name as product_name,
	sum(s.profit) as profit,
	sum(s.sales) as sales,
	round((sum(s.profit) / nullif(sum(s.sales), 0)), 4) as profit_margin
from mart.fact_sales as s
join mart.dim_product as p
	on s.product_id = p.product_id
group by p.product_id, p.product_name
order by profit desc
limit 10;

select 
	p.product_id as product_id,
	p.product_name as product_name,
	sum(s.profit) as profit,
	sum(s.sales) as sales,
	round((sum(s.profit) / nullif(sum(s.sales), 0)), 4) as profit_margin
from mart.fact_sales as s
join mart.dim_product as p
	on s.product_id = p.product_id
group by p.product_id, p.product_name
order by sales desc
limit 10;

select 
	p.product_id as product_id,
	p.product_name as product_name,
	sum(s.profit) as profit,
	sum(s.sales) as sales,
	round((sum(s.profit) / nullif(sum(s.sales), 0)), 4) as profit_margin
from mart.fact_sales as s
join mart.dim_product as p
	on s.product_id = p.product_id
group by p.product_id, p.product_name
order by profit_margin desc
limit 10;

-- 2. How do sales, profit and margin differ by category and sub-category?
select 
	p.category as category,
	p.sub_category as sub_category,
	sum(s.profit) as profit,
	sum(s.sales) as sales,
	round((sum(s.profit) / nullif(sum(s.sales), 0)),4) as profit_margin
from mart.fact_sales as s
join mart.dim_product as p
	on s.product_id = p.product_id
group by p.category, p.sub_category
order by profit desc;

-- 3. Which products sell in the highest quantities and what's the profit from them?
select
	p.product_id,
	p.product_name,
	sum(s.quantity) as quantity_sold,
	sum(s.profit) as profit
from mart.fact_sales as s
join mart.dim_product as p
	on s.product_id = p.product_id
group by p.product_id, p.product_name
order by quantity_sold desc
limit 20;

-- 4. Among the top 10 selling products (by quantity sold) - what is the profit margin by discount bucket?
with top_10_products as(
	select product_id
	from
		(select
			product_id,
			sum(quantity) as quantity_sold
		from mart.fact_sales
		group by product_id
		order by quantity_sold desc
		limit 10) as top_10_products
)
select 
	case when (discount = 0) then '0.0'
		when (discount > 0 and discount <= 0.2) then '0.0 - 0.2'
		when (discount > 0.2 and discount <= 0.4) then '0.2 - 0.4'
		when (discount > 0.4 and discount <= 0.6) then '0.4 - 0.6'
		when (discount > 0.6 and discount <= 0.8) then '0.6 - 0.8'
		else '> 0.8'
	end as discount_size,
	round((sum(profit) / nullif(sum(sales), 0)),4) as profit_margin
from mart.fact_sales
where product_id in (select * from top_10_products)
group by discount_size;

-- 5. What percentage of total profit comes from the top 10 products by quantity sold?
with top_10_products as(
	select product_id
	from
		(select
			product_id,
			sum(quantity) as quantity_sold
		from mart.fact_sales
		group by product_id
		order by quantity_sold desc
		limit 10) as top_10_products
),
profit_from_top10 as (
	select sum(profit) as profit_from_top10
	from mart.fact_sales
	where product_id in (select * from top_10_products)
),
total_profit as(
select sum(profit) as total_profit
from mart.fact_sales
)
select 
	round((profit_from_top10 / (select total_profit from total_profit) * 100),2) as pct_of_total_profit
from profit_from_top10;