/*
This file creates a fact table containing data of all order lines appearing in the source data.
It will contain the following information:
- row_id
- order_id
- order_date_day
- ship_date_day
- ship_mode
- customer_id
- country
- state
- city
- postal_code
- region
- product_id
- sales
- quantity
- discount
- profit

Run after: 05-08 scripts with dimention tables.

Safe to re-run.
*/

drop table if exists mart.fact_sales;

create table mart.fact_sales (
row_id int primary key,
order_id text,
order_date_day date,
ship_date_day date,
ship_mode text,
customer_id text,
country text,
state text,
city text,
postal_code text,
region text,
product_id text,
sales numeric(12,4),
quantity int,
discount numeric(5,4),
profit numeric(12,4),
constraint fk_customer
	foreign key (customer_id)
	references mart.dim_customer (customer_id),
constraint fk_order_date
	foreign key (order_date_day)
	references mart.dim_date (date_day),
constraint fk_ship_date
	foreign key (ship_date_day)
	references mart.dim_date (date_day),	
constraint fk_location
	foreign key (country, state, city, postal_code, region)
	references mart.dim_location (country, state, city, postal_code, region),
constraint fk_product
	foreign key (product_id)
	references mart.dim_product (product_id)
);

insert into mart.fact_sales
	(row_id, order_id, order_date_day, ship_date_day, ship_mode, 
	customer_id, country, state, city, postal_code, region,
	product_id, sales, quantity, discount, profit)
select
	row_id,
	order_id,
	order_date as order_date_day,
	ship_date as ship_date_day,
	ship_mode,
	customer_id,
	country,
	state,
	city,
	postal_code,
	region,
	product_id,
	sales,
	quantity,
	discount,
	profit
from clean.superstore_orders;




















