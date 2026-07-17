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
        COUNT(transaction_id) AS total_orders,
        MIN(transaction_timestamp) AS first_order_date,
        MAX(transaction_timestamp) AS latest_order_date,
        SUM(quantity) AS total_units_ordered
    FROM orders
    GROUP BY customer_id

),

joined AS (

    SELECT
        c.customer_id,
        c.customer_first_name,
        c.customer_last_name,
        c.customer_email,
        COALESCE(a.total_orders, 0) AS total_orders,
        a.first_order_date,
        a.latest_order_date,
        COALESCE(a.total_units_ordered, 0) AS total_units_ordered
    FROM customers c
    LEFT JOIN aggregated a ON c.customer_id = a.customer_id

)

SELECT * FROM joined
