WITH addresses as (select * from {{ source('postgres', 'addresses') }})

SELECT
    address_id,
    address,
    lpad(zipcode, 5, 0) AS zipcode,
    state,
    country
FROM
    addresses
