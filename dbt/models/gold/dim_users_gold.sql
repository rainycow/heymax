{{
    config(
        materialized='incremental',
        unique_key='user_id'
    )
}}
SELECT
    *
FROM
    {{ ref('dim_users_silver') }} silver

{% if is_incremental() %}
WHERE
    silver.loaded_at > (
        SELECT
            max(loaded_at)
        FROM
            {{ this }}
    )

{% endif %}