SELECT
    ADDRESS_ID,
    ADDRESS,
    LPAD(zipcode, 5, 0) AS ZIPCODE,
    STATE,
    COUNTRY
FROM
    {{ source('postgres', 'addresses') }}
