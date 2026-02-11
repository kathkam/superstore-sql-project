/*
This file creates a dimension table containing data of all customers appearing in the source data.
It will contain the following information:
- customer_id
- customer_name
- segment

Run after: 04_create_clean_superstore_orders.

Safe to re-run.
*/

drop table if exists mart.dim_customer;

create table mart.dim_customer (
customer_id text primary key,
customer_name text,
segment text
);

insert into mart.dim_customer
	(customer_id, customer_name, segment)
select distinct
	trim(customer_id),
	trim(customer_name),
	trim(segment)
from clean.superstore_orders;

-- checks if there are no duplicates and customer_id is unique
select
	count(*) as count_of_rows,
	count(distinct customer_id) as count_of_customer_id
from mart.dim_customer;

-- checks if there are any customer_id with multiple names or segments assigned
select 
	customer_id,
	count(distinct customer_name) as count_of_names,
	count(distinct segment) as count_of_segments
from mart.dim_customer
group by customer_id
having 
	count(distinct customer_name) > 1
	or count(distinct segment) > 1
order by count_of_names desc, count_of_segments desc;


