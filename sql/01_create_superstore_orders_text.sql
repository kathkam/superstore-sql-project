/*
This file creates an empty table with columns based on headers from the source CSV file.
The columns are stored as text to guarantee safe data import from CSV of unknown quality.
Type casting and validation are intentionally deferred to the "clean" schema.
This should be run after "00_create_schemas" script.

This file is safe to re-run.
*/

drop table if exists raw.superstore_orders_text;

create table raw.superstore_orders_text (
row_id text,
order_id text,
order_date text,
ship_date text,
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
sales text,
quantity text,
discount text,
profit text
);
