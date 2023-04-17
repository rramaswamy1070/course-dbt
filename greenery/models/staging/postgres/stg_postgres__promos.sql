{{
  config(
    materialized='table'
  )
}}

SELECT 
    PROMO_ID, 
    DISCOUNT, 
    STATUS AS PROMO_STATUS
FROM 
  {{ source('postgres', 'promos') }}