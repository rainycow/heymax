SELECT
    country,
    event_type,
    interactions,
    perc,
    coalesce(transaction_category, 'NA') AS transaction_category
FROM
    public_metrics.user_interactions