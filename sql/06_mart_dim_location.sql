/*
This file creates a dimension table containing data of all locations appearing in the source data.
It will contain the following information:
- country
- city
- state
- postal_code
- region

Run after: 04_clean_superstore_orders.

Safe to re-run.
*/

drop table if exists mart.dim_location;

create table mart.dim_location(
country text,
city text,
state text,
postal_code text,
region text,
primary key (country, state, city, postal_code, region)
);

insert into mart.dim_location
	(country, city, state, postal_code, region)
select distinct
	trim(country),
	trim(city),
	trim(state),
	trim(postal_code),
	trim(region)
from clean.superstore_orders;