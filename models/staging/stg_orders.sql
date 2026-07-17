{{
    config(
        materialized = 'table',
        tags = ['supabase','stg','orders'],
        alias = 'stg_orders'
    )
}}

SELECT
    transaction_id AS TRANSACTION_ID,
    transaction_timestamp as TRANSACTION_TIMESTAMP,
    customer_id as CUSTOMER_ID,
    product_id as PRODUCT_ID,
    quantity AS QUANTITY,
    payment_method AS PAYMENT_METHOD,
    order_status AS ORDER_STATUS
FROM {{ source('raw_snowflake', var('source_table', 'ECOM_TABLE')) }}