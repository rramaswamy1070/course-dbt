SELECT 
  PRODUCT_ID, 
  NAME AS PRODUCT_NAME, 
  PRICE AS PRODUCT_PRICE, 
  INVENTORY
FROM 
  {{ source('postgres', 'products') }}
