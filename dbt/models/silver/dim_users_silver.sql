SELECT DISTINCT
    *, 
    '{{ run_started_at.strftime("%Y-%m-%d") }}' as loaded_at
FROM
    {{ ref('dim_users_bronze') }} bronze
