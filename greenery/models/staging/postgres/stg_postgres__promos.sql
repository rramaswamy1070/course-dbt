WITH promos as (select * from {{ source('postgres', 'promos') }})

SELECT
    PROMO_ID, 
    DISCOUNT, 
    STATUS AS PROMO_STATUS
FROM 
  promos
