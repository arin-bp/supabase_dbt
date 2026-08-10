WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),
orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        SUM(CASE WHEN status = 'COMPLETED' THEN amount ELSE 0 END) AS total_lifetime_spend
    FROM orders
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    COALESCE(co.total_orders, 0) AS total_orders,
    COALESCE(co.total_lifetime_spend, 0.00) AS total_lifetime_spend
FROM customers c
LEFT JOIN customer_orders co ON c.customer_id = co.customer_id
