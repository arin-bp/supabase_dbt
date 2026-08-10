{{
    config(
        materialized = 'table',
        tags = ['snowflake','stg','products'],
        alias = 'stg_products'
    )
}}

SELECT
    1 AS product_id,
    'SKU-1001' AS product_sku,
    'ELECTRONICS' AS product_category,
    250.00 AS unit_price,
    0.00 AS discount_rate
UNION ALL
SELECT
    2 AS product_id,
    'SKU-1002' AS product_sku,
    'APPAREL' AS product_category,
    125.50 AS unit_price,
    0.05 AS discount_rate