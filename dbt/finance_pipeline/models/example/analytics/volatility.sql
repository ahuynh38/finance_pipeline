select
	ticker,
	price_date,
	daily_return,
	round(STDDEV(daily_return) over (
		partition by ticker
		order by price_date
		rows between 29 preceding and current row
	), 2) as volatility_30d
from {{ ref('daily_return') }}