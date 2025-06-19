SELECT
    *,
    '{{ run_started_at.strftime("%Y-%m-%d") }}' as loaded_at
FROM
    {{ ref('fact_events_bronze') }} bronze
