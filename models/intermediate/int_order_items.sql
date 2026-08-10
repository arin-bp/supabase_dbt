{{
    config(
        materialized='table',
        tags=['snowflake','int','order_items'],
        alias='int_order_items'
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
products AS (
    SELECT * FROM {{ ref('stg_products') }}
),
joined AS (
    SELECT
        o.order_id,
        o.order_date,
        o.customer_id,
        1 AS product_id,
        p.product_sku,
        p.product_category,
        1 AS quantity,
        p.unit_price,
        p.discount_rate,
        o.amount AS gross_revenue,
        (o.amount * (1 - COALESCE(p.discount_rate, 0))) AS net_revenue,
        o.status AS order_status
    FROM orders o
    LEFT JOIN products p ON p.product_id = 1
)
SELECT * FROM joined