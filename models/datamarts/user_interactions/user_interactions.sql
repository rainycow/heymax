SELECT
    country,
    event_type,
    interactions,
    round(
        interactions / sum(interactions) OVER (
            PARTITION BY
                country,
                event_type
        ),
        1
    ) AS perc,
    transaction_category
FROM
    (
        SELECT DISTINCT
            country,
            count(u.user_id) OVER (
                PARTITION BY
                    country,
                    event_type,
                    transaction_category
            ) AS interactions,
            event_type,
            transaction_category
        FROM
             {{ source('public', 'fact_events') }} b
            JOIN  {{ source('public', 'dim_users') }} u ON b.user_id = u.user_id
    ) t1
