{% macro calendar_date(start_date, end_date) %} 

with recursive calendar_date as (
  select 
    '{{ start_date }}' :: date as calendar_date
  union all
  select 
    date + interval '1 day'
  from 
    calendar_date
  where 
    date < '{{ end_date }}' :: date
)
select 
    calendar_date
from 
    calendar_date

{% endmacro %} 