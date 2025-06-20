SELECT
    '{{ var("event_uuid") }}' AS event_id,
    event_time::timestamp,
    event_type,
    user_id,
    transaction_category,
    miles_amount,
    platform,
    utm_source,
    '{{ run_started_at.strftime("%Y-%m-%d") }}' as loaded_at
FROM
   {{ ref('event_stream') }}