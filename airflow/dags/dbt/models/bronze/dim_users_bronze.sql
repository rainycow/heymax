SELECT DISTINCT
    user_id,
    country
FROM
    {{ ref('event_stream') }}