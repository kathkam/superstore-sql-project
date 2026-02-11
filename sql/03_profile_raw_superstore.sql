/*
This file is used to review the data types, consistency of formatting and completeness of the table.
Information gathered here will be used in the later steps to cast appropriate data formats. 

This should be run after "02_load_raw_superstore_data" script.
*/

-- checks if row_id is unique
select count(*) as number_of_rows,
	count(distinct row_id) as unique_row_id
from raw.superstore_orders_text;

-- counts individual orders within the table
select count(distinct order_id) as unique_order_id
from raw.superstore_orders_text;

-- checks for rows with the same order_id + product_id + quantity combination
select order_id, product_id, quantity, count(*) as count_of_rows
from raw.superstore_orders_text
group by order_id, product_id, quantity
having count(*) > 1
order by count_of_rows desc;

-- checks for nulls in key columns
select count(*) as rows_with_nulls
from raw.superstore_orders_text
where 
	(nullif(trim(order_id), '')) is null or
	(nullif(trim(order_date), '')) is null or
	(nullif(trim(customer_id), '')) is null or
	(nullif(trim(product_id), '')) is null or
	(nullif(trim(sales), '')) is null or
	(nullif(trim(quantity), '')) is null or
	(nullif(trim(profit), '')) is null;

-- checks distinct values of order_date and ship_date to see data formats
select order_date, 
	count(*) as no_of_occurrences
from raw.superstore_orders_text
group by order_date
order by no_of_occurrences desc
limit 20;

select ship_date,
	count(*) as no_of_occurrences
from raw.superstore_orders_text
group by ship_date
order by no_of_occurrences desc
limit 20;

-- checks if sales, profit, discount, quantity columns display only numeric non-null values
select sales, quantity, discount, profit
from raw.superstore_orders_text
where trim(sales) !~ '^-?[0-9]+(\.[0-9]+)?$' or
	trim(quantity) !~ '^-?[0-9]+$' or
	trim(discount) !~ '^-?[0-9]+(\.[0-9]+)?$' or
	trim(profit) !~ '^-?[0-9]+(\.[0-9]+)?$';

-- checks quantities and ranges of various information in one dashboard
select count(*) as number_of_rows,
	count (distinct row_id) as unique_row_id,
	count (distinct order_id) as unique_orders,
	sum(case when nullif(trim(order_date), '') is null then 1 else 0 end) as missing_order_dates,
	sum(case when nullif(trim(customer_id), '') is null then 1 else 0 end) as missing_customer_id,
	sum(case when nullif(trim(product_id), '') is null then 1 else 0 end) as missing_product_id,
	sum(case when nullif(trim(sales), '') is null then 1 else 0 end) as missing_sales,
	sum(case when nullif(trim(quantity), '') is null then 1 else 0 end) as missing_quantity,
	sum(case when nullif(trim(profit), '') is null then 1 else 0 end) as missing_profit,
	sum(case when nullif(trim(order_date), '') is null then 1 else 0 end) as missing_order_dates,
	sum(case when nullif(trim(ship_date), '') is null then 1 else 0 end) as missing_ship_dates
from raw.superstore_orders_text;
