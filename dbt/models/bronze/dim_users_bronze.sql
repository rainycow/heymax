SELECT DISTINCT
    user_id,
    country,
   '{{ run_started_at.strftime("%Y-%m-%d") }}' as loaded_at
FROM
    {{ ref('event_stream') }}