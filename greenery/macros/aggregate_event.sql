{%- macro aggregate_event(col_name, e) -%}

        sum(case when {{ col_name }} = '{{ e }}' then 1 else 0 end)

{%- endmacro -%}
