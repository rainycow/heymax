SELECT
    *, 
    '{{ run_started_at.strftime("%Y-%m-%d") }}' as loaded_at
FROM
    {{ ref('dim_users_bronze') }} bronze

{% if is_incremental() %}
WHERE
    bronze.loaded_at > (
        SELECT
            max(loaded_at)
        FROM
            {{this}}
    )

{% endif %}