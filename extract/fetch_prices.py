import requests
import psycopg2
import os
import time
from datetime import datetime

# API config
API_KEY = os.environ.get("ALPHA_VANTAGE_KEY")
TICKERS = [
    "AAPL", "GOOGL", "MSFT", "NVDA", # large cap tech
    "AMZN", "META",                  # more tech
    "JPM",                           # financials
    "JNJ",                           # defensive, low volatility
    "SPY"                            # benchmark
]

# database config
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "financial_pipeline",
    "user": "postgres",
    "password": os.environ.get("PG_PASSWORD")
}

# fetch data from the API
def fetch_prices(ticker):
    url = "https://www.alphavantage.co/query"
    params = {
        "function": "TIME_SERIES_DAILY",
        "symbol": ticker,
        "outputsize": "compact",
        "apikey": API_KEY
    }
    response = requests.get(url, params=params)
    data = response.json()

    if "Information" in data:
        print(f"WARNING: We probably hit the API limit. Message: {data['Information']}")
        return {}
    
    return data.get("Time Series (Daily)", {})

# load data into PostgreSQL
def load_prices(ticker, daily_data):
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    for date_str, values in daily_data.items():
        cursor.execute("""
                        INSERT INTO raw.stock_prices (
                            ticker, price_date, open_price, high_price,
                            low_price, close_price, volume, loaded_at
                       ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                       ON CONFLICT (ticker, price_date) DO NOTHING
                       """, (
                           ticker,
                           date_str,
                           float(values["1. open"]),
                           float(values["2. high"]),
                           float(values["3. low"]),
                           float(values["4. close"]),
                           int(values["5. volume"]),
                           datetime.now()
                       ))
    conn.commit()
    cursor.close()
    conn.close()
    print(f"Loaded {len(daily_data)} rows for {ticker}")

def main():
    for ticker in TICKERS:
        print(f"Fetching {ticker}...")
        daily_data = fetch_prices(ticker)
        if not daily_data:
            print(f"Skipping {ticker} -- no data returned")
            continue
        load_prices(ticker, daily_data)
        time.sleep(2)

if __name__ == "__main__":
    main()