WITH order_items as (select * from {{ source('postgres', 'order_items') }})

SELECT
    ORDER_ID, 
    PRODUCT_ID, 
    QUANTITY
FROM
    order_items
