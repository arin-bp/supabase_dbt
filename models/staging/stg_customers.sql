{{
    config(
        materialized='table',
        tags=['snowflake', 'stg', 'asset'],
        alias='stg_customers',
    )
}}
SELECT DISTINCT
    customer_id AS CUSTOMER_ID,
    customer_first_name AS CUSTOMER_FIRST_NAME,
    customer_last_name AS CUSTOMER_LAST_NAME,
    customer_email AS CUSTOMER_EMAIL
FROM {{ source('raw_snowflake', var('source_table', 'ECOM_TABLE')) }}