{%- set event_names_list = dbt_utils.get_column_values(
        table = ref('stg_postgres__events'),
        column = 'event_name'
    )
%}

with events as (
    select * from {{ ref ('stg_postgres__events') }}
)

select
    e.user_id,
    e.session_id
    {% for e in event_names_list %}
        , {{ aggregate_event('e.event_name', e) }} as {{ e }}
    {% endfor %}
from
    events e
group by 
    1,
    2