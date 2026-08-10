WITH source AS (
    SELECT * FROM {{ ref('raw_customers') }}
)
SELECT
    customer_id,
    first_name,
    last_name,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    created_at
FROM source