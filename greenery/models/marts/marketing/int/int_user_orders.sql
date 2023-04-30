with users as (
    select 
        * 
    from 
        {{ ref('stg_postgres__users') }}
),

orders as (
    select
        *
    from
        {{ ref('stg_postgres__orders') }}
),

order_items as (
    select
        *
    from
        {{ ref('stg_postgres__order_items') }}
)

select
    u.user_id,
    u.signup_date,
    count(distinct o.order_id) as total_orders_placed,
    count(distinct case when o.created_at <= u.signup_date + interval '30 days' then o.order_id else null end) as num_f30_orders_placed,
    min(o.created_at) as first_order_date,
    max(o.created_at) as most_recent_order_date,
    datediff('days', u.signup_date, first_order_date) as time_from_signup_to_first_order,
    count(distinct case when o.order_status = 'preparing' then o.order_id else null end) as num_orders_ongoing,
    count(distinct case when o.order_status = 'shipped' then o.order_id else null end) as num_orders_shipped,
    count(distinct case when o.order_status = 'delivered' then o.order_id else null end) as num_orders_delivered,
    sum(oi.quantity) as total_items_purchased,
    sum(o.order_total) as total_spend,
    sum(o.shipping_cost) as total_shipping_spend
from
    users u
    left join orders o on u.user_id = o.user_id
    left join order_items oi on o.order_id = oi.order_id
group by
    u.user_id,
    u.signup_date