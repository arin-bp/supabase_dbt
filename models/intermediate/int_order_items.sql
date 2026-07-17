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
        o.transaction_id,
        o.transaction_timestamp,
        o.customer_id,
        o.product_id,
        p.product_sku,
        p.product_category,
        o.quantity,
        p.unit_price,
        p.discount_rate,
        (o.quantity * p.unit_price) AS gross_revenue,
        ((o.quantity * p.unit_price) * (1 - COALESCE(p.discount_rate, 0))) AS net_revenue,
        o.payment_method,
        o.order_status
    FROM orders o
    LEFT JOIN products p ON o.product_id = p.product_id

)

SELECT * FROM joined