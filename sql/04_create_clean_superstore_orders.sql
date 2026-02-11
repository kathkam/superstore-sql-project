/*
This file creates a clean table, based on the raw table loaded in step 02, which was then profiled in step 03.
It includes only rows for which the key fields are not missing, and casts appropriate types to each column, trims text columns, removes duplicated rows.

This should be run after "02_load_raw_superstore_data" script.

This file is safe to re-run.
*/

drop table if exists clean.superstore_orders;

create table clean.superstore_orders (
row_id int,
order_id text,
order_date date,
ship_date date,
ship_mode text,
customer_id text,
customer_name text,
segment text,
country text,
city text,
state text,
postal_code text,
region text,
product_id text,
category text,
sub_category text,
product_name text,
sales numeric(12,4),
quantity int,
discount numeric(5,4),
profit numeric(12,4)
);

insert into clean.superstore_orders 
	(row_id, order_id, order_date, ship_date, ship_mode,
	customer_id, customer_name, segment, country, city, state, postal_code, region,
	product_id, category, sub_category, product_name, 
	sales, quantity, discount, profit)
select distinct
	nullif(trim(row_id), '')::int as row_id,
	nullif(trim(order_id), '') as order_id,
	to_date(nullif(trim(order_date), ''), 'MM/DD/YYYY') as order_date,
	to_date(nullif(trim(ship_date), ''), 'MM/DD/YYYY') as ship_date,
	nullif(trim(ship_mode), '') as ship_mode,
	nullif(trim(customer_id), '') as customer_id,
	nullif(trim(customer_name), '') as customer_name,
	nullif(trim(segment), '') as segment,
	nullif(trim(country), '') as country,
	nullif(trim(city), '') as city,
	nullif(trim(state), '') as state,
	nullif(trim(postal_code), '') as postal_code,
	nullif(trim(region), '') as region,
	nullif(trim(product_id), '') as product_id,
	nullif(trim(category), '') as category,
	nullif(trim(sub_category), '') as sub_category,
	nullif(trim(product_name), '') as product_name,
	nullif(trim(sales), '')::numeric(12,4) as sales,
	nullif(trim(quantity), '')::int as quantity,
	nullif(trim(discount), '')::numeric(5,4) as discount,
	nullif(trim(profit), '')::numeric(12,4) as profit
from raw.superstore_orders_text
where 
	nullif(trim(order_id), '') is not null and
	nullif(trim(order_date), '') is not null and 
	nullif(trim(ship_date), '') is not null and 
	nullif(trim(customer_id), '') is not null and 
	nullif(trim(product_id), '') is not null and 
	nullif(trim(sales), '') is not null and 
	nullif(trim(quantity), '') is not null and 
	nullif(trim(profit), '') is not null;

-- comparison of number of rows and uniqueness of row_id in raw and clean files
select
	count(*) as no_of_rows_in_raw,
	count(distinct(trim(row_id))) as unique_row_id_raw,
	(select count(*)
	from clean.superstore_orders) as no_of_rows_in_clean,
	(select count(distinct(row_id))
	from clean.superstore_orders) as unique_row_id_clean
from raw.superstore_orders_text;
