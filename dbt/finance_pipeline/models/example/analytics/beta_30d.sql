WITH stock_vs_market AS (
    SELECT
        s.ticker,
        s.price_date,
        s.daily_return,
        m.daily_return AS spy_return
    FROM {{ ref('daily_return') }} s
    JOIN {{ ref('daily_return') }} m
        ON s.price_date = m.price_date
        AND m.ticker = 'SPY'
    WHERE s.ticker != 'SPY'
),
spy_variance AS (
    SELECT
        price_date,
        VAR_SAMP(daily_return) OVER (
            ORDER BY price_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS spy_var
    FROM {{ ref('daily_return') }}
    WHERE ticker = 'SPY'
)

SELECT
    s.ticker,
    s.price_date,
    s.daily_return,
    s.spy_return,
    ROUND(
        (COVAR_SAMP(s.daily_return, s.spy_return) OVER (
            PARTITION BY s.ticker
            ORDER BY s.price_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) /
        NULLIF(v.spy_var, 0))::NUMERIC
    , 2) AS beta_30d
FROM stock_vs_market s
JOIN spy_variance v
    ON s.price_date = v.price_date