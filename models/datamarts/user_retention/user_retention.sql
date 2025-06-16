WITH first_seen AS (
    SELECT
        user_id,
        MIN(event_time::date) AS cohort_date
    FROM {{ source('public', 'fact_events') }}
    GROUP BY user_id
),

activity_log AS (
    SELECT
        e.user_id,
        country,
        e.event_time::date AS activity_date,
        fs.cohort_date,
        (e.event_time::date - fs.cohort_date) AS days
    FROM {{ source('public', 'fact_events') }} e
    JOIN first_seen fs ON e.user_id = fs.user_id
    join {{ source('public', 'dim_users') }} u on u.user_id = e.user_id
    WHERE (e.event_time::date - fs.cohort_date) IN (0, 1, 7, 30, 60, 90)
    
),
--use datatable for retention

retention_counts AS (
    SELECT
        cohort_date, 
        country,
        100 AS d0_retention_rate,
        COUNT(DISTINCT CASE WHEN days = 0 THEN user_id END) AS cohort_size,
        COUNT(DISTINCT CASE WHEN days = 1 THEN user_id END) AS d1_retained,
        COUNT(DISTINCT CASE WHEN days = 7 THEN user_id END) AS d7_retained,
        COUNT(DISTINCT CASE WHEN days = 30 THEN user_id END) AS d30_retained,
        COUNT(DISTINCT CASE WHEN days = 60 THEN user_id END) AS d60_retained,
        COUNT(DISTINCT CASE WHEN days = 90 THEN user_id END) AS d90_retained
    FROM activity_log
    GROUP BY 1,2
)

SELECT
    to_char(cohort_date, 'YYYY-MM-DD') AS cohort_date,
    country,
    cohort_size,
    d0_retention_rate,
    d1_retained,
    ROUND(100 * d1_retained / NULLIF(cohort_size, 0), 4) AS d1_retention_rate,
    d7_retained,
    ROUND(100 * d7_retained / NULLIF(cohort_size, 0), 4) AS d7_retention_rate,
    d30_retained,
    ROUND(100 * d30_retained / NULLIF(cohort_size, 0), 4) AS d30_retention_rate,
    d60_retained,
    ROUND(100 * d60_retained / NULLIF(cohort_size, 0), 4) AS d60_retention_rate,
    d90_retained,
    ROUND(100 * d90_retained / NULLIF(cohort_size, 0), 4) AS d90_retention_rate
FROM retention_counts
ORDER BY cohort_date, country
