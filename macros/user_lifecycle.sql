-- Parameters: adjust 'time_grain' to 'day', 'week', or 'month'
{% macro render_user_lifecycle(time_grain) %}

{% set interval_step = "1 day" if time_grain == "day" else "1 month" if time_grain == "month" else "1 week" %}

WITH
    params AS (
        SELECT
            '{{ time_grain }}' AS time_grain
    ),
    -- Normalize events to time grain
    active_users_by_period AS (
        SELECT
            user_id,
            DATE_TRUNC('{{ time_grain }}', event_time) AS active_period
        FROM
           {{ source('public', 'fact_events') }}
        GROUP BY
            1,
            2
    ),
    -- First seen time period
    user_first_last_seen AS (
        SELECT
            user_id,
            MIN(DATE_TRUNC('{{ time_grain }}', event_time)) AS first_seen,
            MAX(DATE_TRUNC('{{ time_grain }}', event_time)) AS last_seen
        FROM
            {{ source('public', 'fact_events') }}
        GROUP BY
            1
    ),
    user_time_series AS (
        SELECT
            u.user_id,
            gs.period
        FROM
            user_first_last_seen u
            CROSS JOIN LATERAL generate_series(
                u.first_seen,
                u.last_seen,
                interval '{{ interval_step }}'
            ) AS gs (period)
    ),
    user_periods AS (
        SELECT
            ts.user_id,
            ts.period AS active_period,
            CASE
                WHEN ua.active_period IS NOT NULL THEN TRUE
                ELSE FALSE
            END AS is_active
        FROM
            user_time_series ts
            LEFT JOIN active_users_by_period ua ON ts.user_id = ua.user_id
            AND ts.period = ua.active_period
    ),
    user_activity_lagged AS (
        SELECT
            *,
            LAG(
                CASE
                    WHEN is_active THEN active_period
                END
            ) OVER (
                PARTITION BY
                    user_id
                ORDER BY
                    active_period
            ) AS prev_active_period
        FROM
            user_periods
    ),
    user_lifecycle AS (
        SELECT
            ual.user_id,
            active_period,
            prev_active_period,
            CASE
                WHEN is_active
                    AND active_period = first_seen THEN 'new'
                WHEN prev_active_period IS NOT NULL
                    AND active_period = prev_active_period + interval '{{ interval_step }}'
                THEN 'retained'
                WHEN is_active = FALSE 
                    AND prev_active_period IS NULL THEN 'churned'
                WHEN is_active 
                    AND prev_active_period IS NULL THEN 'resurrected'
            END AS user_status
        FROM
            user_activity_lagged ual
            LEFT JOIN user_first_last_seen ufls ON ual.user_id = ufls.user_id
    ),
    final_user_lifecycle_metrics AS (
        SELECT
            active_period,
            country,
            new_users,
            retained_users,
            resurrected_users,
            churned_users,
            new_users + retained_users + resurrected_users AS active_users
        FROM
            (
                SELECT
                    active_period,
                    country,
                    COUNT(
                        DISTINCT CASE
                            WHEN user_status = 'new' THEN lifecycle.user_id
                        END
                    ) AS new_users,
                    COUNT(
                        DISTINCT CASE
                            WHEN user_status = 'retained' THEN lifecycle.user_id
                        END
                    ) AS retained_users,
                    COUNT(
                        DISTINCT CASE
                            WHEN user_status = 'resurrected' THEN lifecycle.user_id
                        END
                    ) AS resurrected_users,
                    COUNT(
                        DISTINCT CASE
                            WHEN user_status = 'churned' THEN lifecycle.user_id
                        END
                    ) AS churned_users
                FROM
                    user_lifecycle lifecycle
                    JOIN {{ source('public', 'dim_users') }} u ON u.user_id = lifecycle.user_id
                GROUP BY
                    1,
                    2
            ) t1
    )
    
SELECT 
DISTINCT
    period,
    country,
    user_category,
    user_count,
    active_users
FROM
    (
        SELECT
            to_char(active_period, 'YYYY-MM-DD') AS period,
            country,
            unnest(
                ARRAY['new_users', 'retained_users', 'resurrected_users', 'churned_users']
            ) AS user_category,
            unnest(ARRAY[new_users, retained_users, resurrected_users, churned_users]) AS user_count,
            active_users
        FROM
            final_user_lifecycle_metrics
    ) t1
ORDER BY
    period,
    country
    
{% endmacro %}