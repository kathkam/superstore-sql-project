/*
This file creates the schemas used in this project to separate raw data ingestion, cleaned data, and analytical models.
This should be run first, since all following SQL scripts assume these schemas exist.

Schemas explanation:
- raw: source data loaded as-is from csv file (no transformations)
- clean: data with corrected types and basic validation
- mart: analytical models

This file is safe to re-run.
*/

create schema if not exists raw;

create schema if not exists clean;

create schema if not exists mart;
