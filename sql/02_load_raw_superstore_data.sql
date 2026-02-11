/*
This file loads data from the source csv file into the previously created table.
The csv file should already be in /data folder (/data/superstore_orders.csv)

This should be run after "01_create_superstore_orders_text" script.

This file is safe to re-run.
*/

truncate table raw.superstore_orders_text;

copy raw.superstore_orders_text
from '/data/superstore_orders.csv'
with (
    format csv,
    header true,
    delimiter ',',
    quote '"',
    encoding 'WIN1252'
);
