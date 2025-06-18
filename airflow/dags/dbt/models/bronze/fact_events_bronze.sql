SELECT
    gen_random_uuid() AS event_id,
    event_time,
    event_type,
    user_id,
    transaction_category,
    miles_amount,
    platform,
    utm_source
FROM
   {{ ref('event_stream') }}