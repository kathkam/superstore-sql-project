/*
This file creates a dimension table containing data of all products appearing in the source data.

After reviewing the initially created table it became apparent that there are multiple product_id values with more than one product_name,
with category and sub_category being unique for each product_id.
There are therefore two parts to this script - the 1st version is the table created initially, and the 2nd version is the table with unique product_name.
If there are multiple names with the same max frequency, I pick the first name in an alphabetical order.

It will contain the following information:
- product_id
- category
- sub_category
- product_name

Run after: 04_clean_superstore_orders.

Safe to re-run.
*/

/* 1st version with duplicate product_name values -- the below code was run before it was determined that there are multiple product_name values

drop table if exists mart.dim_product;

create table mart.dim_product(
product_id text,
category text,
sub_category text,
product_name text
);

insert into mart.dim_product
	(product_id, category, sub_category, product_name)
select distinct
	trim(product_id),
	trim(category),
	trim(sub_category),
	trim(product_name)
from clean.superstore_orders;

-- checks if there are no duplicates and product_id is unique
select
	count(*) as count_of_rows,
	count(distinct product_id) as count_of_product_id
from mart.dim_product;

-- checks if there are any product_id with multiple categories/sub_categories/product_names assigned
select 
	product_id,
	count(distinct category) as count_of_categories,
	count(distinct sub_category) as count_of_sub_categories,
	count(distinct product_name) as count_of_product_names
from clean.superstore_orders
group by product_id
having
	count(distinct category) > 1 or
	count(distinct sub_category) > 1 or
	count(distinct product_name) > 1;

-- list of product_id values with multiple names assigned
with duplicate_names as (
select product_id
from
	(select 
		product_id,
		count(distinct category) as count_of_categories,
		count(distinct sub_category) as count_of_sub_categories,
		count(distinct product_name) as count_of_product_names
	from clean.superstore_orders
	group by product_id
	having
		count(distinct category) > 1 or
		count(distinct sub_category) > 1 or
		count(distinct product_name) > 1))
select distinct product_id, product_name, count(product_name) as count_of_occurrences
from clean.superstore_orders
where product_id in (
	select * from duplicate_names)
	group by product_id, product_name
order by product_id, count_of_occurrences desc;
*/


-- 2nd version with unique product_name values - determined using the most frequently occuring name

drop table if exists mart.dim_product;

create table mart.dim_product(
product_id text primary key,
category text,
sub_category text,
product_name text
);

with 	
	product_name_count as(
		select 
			trim(product_id) as product_id,
			trim(product_name) as product_name,
			count(*) as count_of_occurrences
		from clean.superstore_orders
		group by product_id, product_name
	),
	max_occurrences as(
		select 
			product_id,
			max(count_of_occurrences) as max_occurrences
		from product_name_count
		group by product_id
	),
	final_product_names as(
		select
			p.product_id,
			min(p.product_name) as name_with_max_occurrences
		from max_occurrences as o
		join product_name_count as p
		on p.product_id = o.product_id
			and o.max_occurrences = p.count_of_occurrences
		group by p.product_id)

insert into mart.dim_product
	(product_id, category, sub_category, product_name)
select distinct
	names.product_id as product_id,
	clean.category as category,
	clean.sub_category as sub_category,
	names.name_with_max_occurrences as product_name
from final_product_names as names
join clean.superstore_orders as clean
on clean.product_id = names.product_id
	and clean.product_name = names.name_with_max_occurrences;


-- checks if there are no duplicates and product_id is unique
select
	count(*) as count_of_rows,
	count(distinct product_id) as count_of_product_id
from mart.dim_product;

-- checks if there are any product_id with multiple names or categories assigned
select 
	product_id,
	count(distinct product_name) as count_of_product_names,
	count(distinct category) as count_of_category
from mart.dim_product
group by product_id
having 
	count(distinct product_name) > 1
	or count(distinct category) > 1
order by count_of_product_names desc, count_of_category desc;























