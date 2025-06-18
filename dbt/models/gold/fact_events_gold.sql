{{
    config(
        materialized='incremental',
        unique_key='event_id'
    )
}}
SELECT
    *
FROM
    {{ ref('fact_events_silver') }} silver

{% if is_incremental() %}
WHERE
    silver.loaded_at > (
        SELECT
            max(loaded_at)
        FROM
            {{ this }}
    )

{% endif %}