with prices_with_prev as (
	select
		ticker,
		price_date,
		close_price,
		lag(close_price, 1) over (
			partition by ticker
			order by price_date
		) as prev_close
	from {{ ref('basic_close_price') }}
)

select
	ticker,
	price_date,
	close_price,
	prev_close,
	round((close_price - prev_close) / prev_close * 100, 2) as daily_return
from prices_with_prev
where prev_close is not null