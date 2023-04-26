WITH products as (select * from {{ source('postgres', 'products') }})

SELECT 
  PRODUCT_ID, 
  NAME AS PRODUCT_NAME, 
  PRICE AS PRODUCT_PRICE, 
  INVENTORY
FROM 
  products
