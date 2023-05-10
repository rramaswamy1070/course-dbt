with events as (
    select * from {{ ref('stg_postgres__events') }}
)

select
    *
from
    events
where
    event_name = 'checkout'
