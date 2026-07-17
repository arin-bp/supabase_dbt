{{
    config(
        materialized = 'table',
        tags = ['supabase','stg','products'],
        alias = 'stg_products'
    )
}}

SELECT DISTINCT
    product_id AS PRODUCT_ID,
    product_sku as PRODUCT_SKU,
    product_category AS PRODUCT_CATEGORY,
    unit_price AS UNIT_PRICE,
    discount_rate AS DISCOUNT_RATE
FROM {{ source('raw_snowflake', var('source_table', 'ECOM_TABLE')) }}