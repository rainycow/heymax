SELECT
    *,
    '{{ run_started_at.strftime("%Y-%m-%d") }}' as loaded_at
FROM
    {{ ref('fact_events_bronze') }} bronze

{% if is_incremental() %}
WHERE
    bronze.loaded_at > (
        SELECT
            max(loaded_at)
        FROM
            {{this}}
    )

{% endif %}