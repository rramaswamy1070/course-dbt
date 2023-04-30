with products as (
    select * from {{ ref('stg_postgres__products') }}
),

order_items as (
    select * from {{ ref('stg_postgres__order_items') }}
),

orders as (
    select * from {{ ref('stg_postgres__orders') }}
),

users as (
    select * from {{ ref('stg_postgres__users') }}
),

addresses as (
    select * from {{ ref('stg_postgres__addresses') }}
),

promos as (
    select * from {{ ref('stg_postgres__promos') }}
)

select
    o.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.signup_date,
    a.address,
    a.state,
    a.country,
    a.zipcode,
    o.order_id,
    o.created_at as order_created_at,
    o.order_status,
    o.estimated_delivery_at,
    o.delivered_at,
    o.shipping_service,
    o.shipping_cost,
    o.tracking_id,
    p.inventory,
    p.product_id,
    p.product_name,
    p.product_price,
    oi.quantity,
    pr.promo_id,
    pr.promo_status,
    o.order_total,
    pr.discount
from
    products p
    left join order_items oi on p.product_id = oi.product_id
    left join orders o on oi.order_id = o.order_id
    left join users u on o.user_id = u.user_id
    left join addresses a on u.address_id = a.address_id
    left join promos pr on o.promo_id = pr.promo_id
order by
    o.user_id,
    o.created_at