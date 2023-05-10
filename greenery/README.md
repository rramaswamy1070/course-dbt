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
#### Add dbt tests into your dbt project on your existing models from Week 1, and new models from the section above.

##### What assumptions are you making about each model? (i.e. why are you adding each test?)

##### Did you find any “bad” data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?

#### Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.

### Week 3

#### What is our overall conversion rate?

```sql
select
    count(distinct session_id) as total_sessions,
    count(distinct case when event_name = 'checkout' then session_id else null end) as checkout_sessions,
    1.0 * checkout_sessions / total_sessions as overall_conversion_rate
from
    stg_postgres__events;
```

###### Result: 0.624567

#### What is our conversion rate by product?

```sql
with events as (
    select * from {{ ref('stg_postgres__events') }}
),

product_viewed_session_counts as (
    select
        product_id,
        count(distinct session_id) as total_viewed_sessions
    from
        fct_page_views
    group by
        1
),

product_ordered_sessions as (
    select
        distinct o.product_id,
        o.order_id,
        e.session_id
    from
        fct_orders o
        left join events e on o.order_id = e.order_id
),

product_ordered_session_counts as (
    select
        product_id,
        count(distinct session_id) as total_ordered_sessions
    from
        product_ordered_sessions
    group by
        1
)

select
    pvsc.product_id,
    p.product_name,
    pvsc.total_viewed_sessions,
    posc.total_ordered_sessions,
    1.0 * posc.total_ordered_sessions / pvsc.total_viewed_sessions as conversion_rate
from
    product_viewed_session_counts pvsc
    left join product_ordered_session_counts posc on pvsc.product_id = posc.product_id
    left join stg_postgres__products p on pvsc.product_id = p.product_id
order by
    conversion_rate desc
```

###### Result:
```
| PRODUCT_NAME        | TOTAL_VIEWED_SESSIONS | TOTAL_ORDERED_SESSIONS | CONVERSION_RATE |
|---------------------|-----------------------|------------------------|-----------------|
| String of pearls    | 64                    | 39                     | 0.609375        |
| Arrow Head          | 63                    | 35                     | 0.555556        |
| Cactus              | 55                    | 30                     | 0.545455        |
| ZZ Plant            | 63                    | 34                     | 0.539683        |
| Bamboo              | 67                    | 36                     | 0.537313        |
| Rubber Plant        | 54                    | 28                     | 0.518519        |
| Monstera            | 49                    | 25                     | 0.510204        |
| Calathea Makoyana   | 53                    | 27                     | 0.509434        |
| Fiddle Leaf Fig     | 56                    | 28                     | 0.500000        |
| Majesty Palm        | 67                    | 33                     | 0.492537        |
| Aloe Vera           | 65                    | 32                     | 0.492308        |
| Devil's Ivy         | 45                    | 22                     | 0.488889        |
| Philodendron        | 62                    | 30                     | 0.483871        |
| Jade Plant          | 46                    | 22                     | 0.478261        |
| Spider Plant        | 59                    | 28                     | 0.474576        |
| Pilea Peperomioides | 59                    | 28                     | 0.474576        |
| Dragon Tree         | 62                    | 29                     | 0.467742        |
| Money Tree          | 56                    | 26                     | 0.464286        |
| Orchid              | 75                    | 34                     | 0.453333        |
| Bird of Paradise    | 60                    | 27                     | 0.450000        |
| Ficus               | 68                    | 29                     | 0.426471        |
| Birds Nest Fern     | 78                    | 33                     | 0.423077        |
| Pink Anthurium      | 74                    | 31                     | 0.418919        |
| Boston Fern         | 63                    | 26                     | 0.412698        |
| Alocasia Polly      | 51                    | 21                     | 0.411765        |
| Peace Lily          | 66                    | 27                     | 0.409091        |
| Ponytail Palm       | 70                    | 28                     | 0.400000        |
| Snake Plant         | 73                    | 29                     | 0.397260        |
| Angel Wings Begonia | 61                    | 24                     | 0.393443        |
| Pothos              | 61                    | 21                     | 0.344262        |
```

##### Why might certain products be converting at higher/lower rates than others?

```
**Hypotheses:**
- Lower ratings
- Higher cost
- Low stock / unavailability
- Inherent properties (maintenance, light, pet-safety, etc.)
```

##### Which products had their inventory change from Week 2 to Week 3?

```sql
with most_recent_data as (
    select 
        max(dbt_valid_from) as max_valid_from_date
    from 
        product_snapshot
)
select 
    distinct p.name as product_name
from 
    product_snapshot p
    join most_recent_data mrd on p.dbt_valid_from = mrd.max_valid_from_date
where 
    p.dbt_valid_to is null
    and p.dbt_valid_from = max_valid_from_date
```

###### Results:
```
- Monstera
- Pothos
- Philodendron
- ZZ Plant
- String of pearls
- Bamboo
```
