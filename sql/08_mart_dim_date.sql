/*
This file creates a dimension table containing all dates appearing in the source data.
It will contain the following information:
- date_day
- year
- quarter
- month
- month_name
- day
- day_name
- is_weekend

Run after: 04_clean_superstore_orders.

Safe to re-run.
*/

drop table if exists mart.dim_date;

create table mart.dim_date(
date_day date primary key,
year int,
quarter int,
month int,
month_name text,
day int,
day_name text,
is_weekend boolean
);

with all_dates as(
	select date_day
	from
		(select order_date as date_day
		from clean.superstore_orders
		union
		select ship_date as date_day
		from clean.superstore_orders) as dates)
		
insert into mart.dim_date
	(date_day, year, quarter, month, month_name, day, day_name, is_weekend)
select distinct
	date_day,
	extract(year from date_day) as year,
	extract(quarter from date_day) as quarter,
	extract(month from date_day) as month,
	trim(to_char(date_day,'Month')) as month_name,
	extract(day from date_day) as day,
	trim(to_char(date_day, 'Day')) as day_name,
	(case when 
		trim(to_char(date_day, 'Day')) = 'Saturday'
		or trim(to_char(date_day, 'Day')) = 'Sunday' 
		then true
		else false 
		end) as is_weekend
from all_dates;
