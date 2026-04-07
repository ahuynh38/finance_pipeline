SELECT
    ticker,
    price_date,
    close_price,
    AVG(close_price) OVER (
        PARTITION BY ticker
        ORDER BY price_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS rolling_30d_avg
FROM {{ ref('basic_close_price') }}