{{
    config(
        materialized='table',
        tags=['snowflake','int','customer_metrics'],
        alias='int_customer_metrics'
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),
aggregated AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS latest_order_date,
        SUM(amount) AS total_spend
    FROM orders
    GROUP BY customer_id
),
joined AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        COALESCE(a.total_orders, 0) AS total_orders,
        a.first_order_date,
        a.latest_order_date,
        COALESCE(a.total_spend, 0.00) AS total_spend
    FROM customers c
    LEFT JOIN aggregated a ON c.customer_id = a.customer_id
)
SELECT * FROM joined
