SELECT
    *
FROM
    {{ source('public', 'dim_users') }}