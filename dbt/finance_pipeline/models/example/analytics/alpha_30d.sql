with calculate_alpha as (
	select
		ticker,
		price_date,
		daily_return,
		spy_return,
		beta_30d,
		0.04 / 252 as risk_free_daily
	from {{ ref('beta_30d') }}
)

select
	ticker,
	price_date,
	daily_return,
	spy_return,
	beta_30d,
	ROUND((risk_free_daily + beta_30d * (spy_return - risk_free_daily))::numeric, 4) as expected_return,
	ROUND((daily_return - (risk_free_daily + beta_30d * (spy_return - risk_free_daily)))::numeric, 4) as alpha
from calculate_alpha