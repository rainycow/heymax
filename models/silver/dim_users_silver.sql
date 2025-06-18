SELECT
    *
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