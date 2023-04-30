with users as (select * from {{ source('postgres', 'users') }})

SELECT
    user_id,
    first_name,
    last_name,
    email,
    phone_number,
    created_at as signup_date,
    updated_at,
    address_id
FROM 
  users
