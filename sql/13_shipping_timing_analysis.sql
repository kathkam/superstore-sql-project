/*
This file provides an analysis of the shipping information and periods found in the source database.

Questions answered:
1. What is the average shipping delay?
2. What is shipping delay by ship_mode?
3. What is shipping delay by state?
4. Which ship modes generate the highest profit margin?
5. Are there any anomalies in the dataset - shipping before order, extremely long delays?
6. What share of orders ship within 0–1 days, 2–3 days, 4–7 days, more than 7 days?

*/

-- 1. What is the average shipping delay?
with order_delays as (
  select
    order_id,
    (min(ship_date_day) - min(order_date_day)) as shipping_delay_days
  from mart.fact_sales
  group by order_id
)
select
  round(avg(shipping_delay_days), 2) as avg_shipping_delay_days
from order_delays;


-- 2. What is shipping delay by ship_mode?
with order_delays as (
  select
    order_id,
    min(ship_mode) as ship_mode,
    (min(ship_date_day) - min(order_date_day)) as shipping_delay_days
  from mart.fact_sales
  group by order_id
)
select
  ship_mode,
  round(avg(shipping_delay_days), 2) as avg_shipping_delay_days
from order_delays
group by ship_mode
order by avg_shipping_delay_days;


-- 3. What is shipping delay by state?
with order_delays as (
  select
    order_id,
    min(state) as state,
    (min(ship_date_day) - min(order_date_day)) as shipping_delay_days
  from mart.fact_sales
  group by order_id
)
select
  state,
  round(avg(shipping_delay_days), 2) as avg_shipping_delay_days
from order_delays
group by state
order by avg_shipping_delay_days;


-- 4. Which ship modes generate the highest profit margin?
select 
	ship_mode,
	round(sum(profit) / nullif(sum(sales),0),4) as profit_margin
from mart.fact_sales
group by ship_mode
order by profit_margin desc;

-- 5. Are there any anomalies in the dataset - shipping before order, extremely long delays?
with order_delays as (
  select
    order_id,
    min(order_date_day) as order_date_day,
    min(ship_date_day)  as ship_date_day,
    (min(ship_date_day) - min(order_date_day)) as shipping_delay_days
  from mart.fact_sales
  group by order_id
)
select
  order_id,
  order_date_day,
  ship_date_day,
  shipping_delay_days,
  case
    when shipping_delay_days < 0 then 'Shipping before order'
    when shipping_delay_days > 7 then 'More than 7 days delay in shipping'
  end as shipping_anomaly
from order_delays
where shipping_delay_days < 0
   or shipping_delay_days > 7
order by shipping_delay_days desc;

-- 6. What share of orders ship within 0–1 days, 2–3 days, 4–7 days, more than 7 days?
with shipping_delay as(
	select
		order_id,
		case when (ship_date_day - order_date_day) <= 1 then '0–1 days'
		when (ship_date_day - order_date_day) > 1 and (ship_date_day - order_date_day) <= 3 then '2-3 days'
		when (ship_date_day - order_date_day) > 3 and (ship_date_day - order_date_day) <= 7 then '4-7 days'
		else 'more than 7 days'
		end as delay
	from mart.fact_sales
)
select
	delay as order_delay,
	count(distinct order_id)
from shipping_delay
group by delay
order by delay;
