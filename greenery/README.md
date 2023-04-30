### Week 1

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
##### Note: 
###### You should consider a purchase to be a single order. In other words, if a user places one order for 3 products, they are considered to have made 1 purchase.

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

### Week 2

#### What is our user repeat rate? Repeat Rate = Users who purchased 2 or more times / users who purchased

```sql
with user_purchases as (
    select
        user_id,
        count(distinct order_id) as num_purchases
    from
        stg_postgres__orders
    group by
        user_id
)

select
    count(distinct user_id) as users_who_purchased,
    count(distinct case when num_purchases >= 2 then user_id else null end) as num_users_who_purchased_twice_or_more,
    num_users_who_purchased_twice_or_more / users_who_purchased as repeat_rate
from
    user_purchases;
```

###### Result: 0.798387

#### What are good indicators of a user who will likely purchase again? 
```
1. Time from signup to first order
2. How a user's order frequency compares to median/average order frequency
3. High spend per order / large order volume (number of items)
4. Session duration
```

#### What about indicators of users who are likely NOT to purchase again? 
```
1. Users who signed up but didn't place any orders, or signed up, placed 1 order and never ordered again (baseline would be median/average order frequency)
2. Users whose orders got delivered late (baseline would be median/average order delivery time)
3. Low spend per order / small order volume (number of items)
4. Session duration
```

#### If you had more data, what features would you want to look into to answer this question?

```
1. Ratings/reviews
2. User demographics (age, gender, etc.)
3. Discount code/coupon usage
```
