WITH events as (select * from {{ source('postgres', 'events') }})

SELECT
    event_id,
    session_id, 
    user_id, 
    replace(page_url, 'greenary', 'greenery') as page_url,
    created_at as event_timestamp, 
    event_type as event_name,
    order_id,
    product_id
FROM
    events
