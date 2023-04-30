with users as (
    select 
        * 
    from 
        {{ ref('stg_postgres__users') }}
),

user_sessions as (
    select
        *
    from
        {{ ref('stg_postgres__events') }}
),

user_session_stats as (
    select
        u.user_id,
        s.session_id,
        min(s.event_timestamp) as first_event_time,
        max(s.event_timestamp) as last_event_time,
        datediff(minutes, first_event_time, last_event_time) as session_duration
    from
        users u
        left join user_sessions s on u.user_id = s.user_id
    group by
        u.user_id,
        s.session_id
)

select
    user_id,
    count(distinct session_id) as total_sessions,
    min(session_duration) as shortest_session_duration,
    max(session_duration) as longest_session_duration,
    avg(session_duration) as avg_session_duration,
    median(session_duration) as median_session_duration
from
    user_session_stats
group by
    user_id