#### How many users do we have?

```sql
    select 
        count(distinct user_id) as num_users
    from 
        stg_postgres__users;
```

###### Result: 130

#### On average, how many orders do we receive per hour?

```sql
with hourly_order_counts as (
    select
        date_trunc('hour', created_at) as order_hour,
        count(distinct order_id) as num_orders
    from
        stg_postgres__orders
    group by
        1
)
select 
    avg(num_orders) 
from 
    hourly_order_counts;
```

###### Result: 7.520833

#### On average, how long does an order take from being placed to being delivered?

```sql
with order_delivery_times as (
    select
        order_id,
        datediff('days', created_at, delivered_at) as time_to_deliver_days
    from
        stg_postgres__orders
    where
        delivered_at is not null
)
select
    avg(time_to_deliver_days) as avg_time_to_deliver_days
from
    order_delivery_times;
```

###### Result: 3.891803

#### How many users have only made one purchase? Two purchases? Three+ purchases?
##### Note: you should consider a purchase to be a single order. In other words, if a user places one order for 3 products, they are considered to have made 1 purchase.

```sql
with user_orders as (
    select
        user_id,
        count(distinct order_id) as num_purchases
    from
        stg_postgres__orders
    group by
        1
)
select
    case
        when num_purchases = 1 then '1'
        when num_purchases = 2 then '2'
        when num_purchases >= 3 then '3+'
    end as num_purchases,
    count(distinct user_id) as num_users
from
    user_orders
group by
    1
order by
    1;
```

###### Result:
```
| NUM_PURCHASES | NUM_USERS |
|---------------|-----------|
| 1             | 25        |
| 2             | 28        |
| 3+            | 71        |
```
#### On average, how many unique sessions do we have per hour?

```sql
with hourly_sessions as (
    select
        date_trunc('hour', created_at) as session_created_hour,
        count(distinct session_id) as num_sessions
    from
        stg_postgres__events
    group by
        1
)
select
    avg(num_sessions) as avg_sessions_per_hour
from
    hourly_sessions;
```

###### Result: 16.327586