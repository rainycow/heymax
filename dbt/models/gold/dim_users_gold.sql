SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id, country ORDER BY loaded_at DESC) AS rn
    FROM {{ ref('dim_users_silver') }}
) deduped
WHERE rn = 1

{% if is_incremental() %}
  AND loaded_at > (
        SELECT max(loaded_at) FROM {{ this }}
  )
{% endif %}
