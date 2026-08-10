WITH source AS (
    SELECT * FROM {{ ref('raw_orders') }}
)
SELECT
    order_id,
    customer_id,
    order_date,
    status,
    amount
FROM source