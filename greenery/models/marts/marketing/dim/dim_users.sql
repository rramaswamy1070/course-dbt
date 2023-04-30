with users as (
    select 
        * 
    from 
        {{ ref('stg_postgres__users') }}
),

addresses as (
    select 
        * 
    from 
        {{ ref('stg_postgres__addresses') }}
),

user_session_stats as (
    select 
        * 
    from 
        {{ ref('int_user_sessions') }}
),

user_order_stats as (
    select 
        * 
    from 
        {{ ref('int_user_orders') }}
)

select
    u.*,
    a.address,
    a.zipcode,
    a.state,
    a.country,
    uss.total_sessions,
    uss.shortest_session_duration,
    uss.longest_session_duration,
    uss.avg_session_duration,
    uss.median_session_duration,
    uos.total_orders_placed,
    uos.num_f30_orders_placed,
    uos.num_orders_ongoing,
    uos.num_orders_shipped,
    uos.num_orders_delivered,
    uos.total_items_purchased,
    uos.total_spend,
    uos.total_shipping_spend
from
    users u
    left join addresses a on u.address_id = a.address_id
    left join user_session_stats uss on u.user_id = uss.user_id
    left join user_order_stats uos on u.user_id = uos.user_id