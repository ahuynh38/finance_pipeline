# finance_pipeline

An end-to-end ELT pipeline that extracts financial market data from the Alpha Vantage API, loads it into PostgreSQL, transforms it with dbt, and visualizes it in Metabase.

---

## Overview

This project demonstrates a production-style data pipeline built around a personal finance use case. Raw stock price data is extracted from a public API, loaded into a local PostgreSQL database, transformed into analytics-ready models using dbt, and surfaced through a Metabase dashboard featuring price, risk, and performance analysis across 9 tickers.

<img width="1062" height="987" alt="image" src="https://github.com/user-attachments/assets/a979544c-ce1a-452a-91dc-d6d20daadd55" />
<img width="1059" height="507" alt="image" src="https://github.com/user-attachments/assets/310920ee-1027-477f-9e30-6a7904b83500" />
<img width="1053" height="640" alt="image" src="https://github.com/user-attachments/assets/d5069de9-9545-4d13-a513-97547043bc79" />

---

## Pipeline Architecture

```
Alpha Vantage API
      |
      | (Python - extract & load)
      v
PostgreSQL: raw schema
      |
      | (dbt - transform)
      v
PostgreSQL: analytics schema
      |
      | (Metabase - visualize)
      v
Stock Performance Dashboard
```

---

## Tech Stack

| tool | purpose |
|------|---------|
| Python | extract data from API and load into PostgreSQL |
| PostgreSQL | central data store |
| dbt Core | SQL-based transformation layer |
| Metabase | dashboarding and visualization |
| Conda | virtual environment management |

---

## Tickers Tracked

| ticker | company | profile |
|--------|---------|---------|
| AAPL | Apple | large cap tech |
| GOOGL | Alphabet | large cap tech |
| MSFT | Microsoft | large cap tech |
| NVDA | NVIDIA | large cap tech, high volatility |
| AMZN | Amazon | large cap tech |
| META | Meta | large cap tech, high volatility |
| JPM | JPMorgan Chase | financials |
| JNJ | Johnson & Johnson | defensive, low volatility |
| SPY | S&P 500 ETF | market benchmark |

---

## dbt Models

All models live in `dbt/financial_pipeline/models/analytics/` and form a dependency chain where each model builds on the previous:

| model | description | key SQL concepts |
|-------|-------------|-----------------|
| `basic_close_price` | raw daily closing prices per ticker | SELECT, FROM |
| `rolling_avg_30d` | 30-day rolling average of closing prices | window functions, AVG() OVER |
| `daily_return` | day over day percentage price change | LAG(), CTE |
| `volatility_30d` | 30-day rolling standard deviation of daily returns | STDDEV() OVER |
| `beta_30d` | 30-day rolling beta relative to SPY | COVAR_SAMP(), VAR_SAMP(), self JOIN |
| `alpha` | daily alpha vs CAPM expected return | CAPM formula, arithmetic |

---

## Dashboard

The Metabase dashboard is organized into four sections:

**price** — daily close prices and 30-day rolling averages for all tickers

**risk** — 30-day volatility and beta, showing the contrast between high volatility tickers (NVDA, META) and defensive tickers (JNJ, SPY)

**daily return** — percentage price changes split by volatility profile for readability

**performance** — alpha vs market expectations with outlier transparency table

---

## Project Structure

```
finance_pipeline/
│
├── extract/
│   └── fetch_prices.py              # pulls stock price data from Alpha Vantage
│
├── dbt/
│   └── financial_pipeline/
│       ├── models/
│       │   └── analytics/
│       │       ├── basic_close_price.sql
│       │       ├── rolling_avg_30d.sql
│       │       ├── daily_return.sql
│       │       ├── volatility_30d.sql
│       │       ├── beta_30d.sql
│       │       └── alpha.sql
│       ├── dbt_project.yml          # dbt project configuration
│       └── profiles.yml.example    # connection config template (see setup)
│
├── metabase/
│   └── metabase.jar                # not committed, see setup
│
├── .gitignore
├── requirements.txt
└── README.md
```

---

## Setup

### Prerequisites

- Python 3.8+
- PostgreSQL (running locally on port 5432)
- Java 21+ (required for Metabase)
- dbt Core (`pip install dbt-postgres`)
- Metabase open source edition (see step 7)
- Conda (recommended for virtual environment management)

### 1. Clone the repository

```bash
git clone https://github.com/your-username/finance_pipeline.git
cd finance_pipeline
```

### 2. Create and activate conda environment

```bash
conda create --name finance_pipeline python=3.11
conda activate finance_pipeline
```

### 3. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 4. Set environment variables

Set your Alpha Vantage API key and PostgreSQL password as environment variables. On Windows:

```bash
set ALPHA_VANTAGE_KEY=your_api_key_here
set PG_PASSWORD=your_postgres_password
```

For persistence across sessions, set these as permanent Windows environment variables via System Properties → Environment Variables.

Get a free Alpha Vantage API key at [alphavantage.co](https://www.alphavantage.co). The free tier provides 25 API calls per day — sufficient for this project.

### 5. Create the database schemas and tables

Connect to your local PostgreSQL instance and run:

```sql
CREATE SCHEMA raw;
CREATE SCHEMA analytics;

CREATE TABLE raw.stock_prices (
    ticker       VARCHAR(10),
    price_date   DATE,
    open_price   NUMERIC,
    high_price   NUMERIC,
    low_price    NUMERIC,
    close_price  NUMERIC,
    volume       BIGINT,
    loaded_at    TIMESTAMP DEFAULT NOW()
);

ALTER TABLE raw.stock_prices
ADD CONSTRAINT unique_ticker_date UNIQUE (ticker, price_date);
```

### 6. Configure dbt

Copy the example profiles file and fill in your credentials:

```bash
cp dbt/financial_pipeline/profiles.yml.example ~/.dbt/profiles.yml
```

Edit `~/.dbt/profiles.yml` with your local PostgreSQL credentials. This file is excluded from version control.

### 7. Run the pipeline

Extract and load raw data:

```bash
python extract/fetch_prices.py
```

Run dbt transformations:

```bash
cd dbt/financial_pipeline
dbt run
```

### 8. Set up Metabase

Download the Metabase open source edition from [metabase.com/start/oss](https://www.metabase.com/start/oss/) and place `metabase.jar` in the `metabase/` folder. Requires Java 21+.

```bash
cd metabase
java -jar metabase.jar
```

Open [http://localhost:3000](http://localhost:3000) and connect to your local PostgreSQL instance pointing at the `analytics` schema.

---

## Data Source

Stock price data is sourced from the [Alpha Vantage API](https://www.alphavantage.co). The free tier provides up to 25 API calls per day. The pipeline is designed to be idempotent — running it multiple times will not create duplicate data thanks to the `ON CONFLICT DO NOTHING` constraint on `raw.stock_prices`.

---

## Key Concepts Demonstrated

- ELT pipeline pattern (extract → load raw → transform in-place)
- Separation of raw and analytics data layers
- Idempotent pipeline design with unique constraints
- Defensive programming with API rate limit detection
- SQL window functions including rolling averages, LAG(), STDDEV(), COVAR_SAMP(), and VAR_SAMP()
- CTE-based query composition for complex multi-step transformations
- dbt model dependency management via ref() and data lineage
- Financial metrics including daily return, volatility, beta, and alpha (CAPM)
- Self joins for benchmark comparison (stock returns vs SPY)
- Data transparency with outlier documentation in the dashboard
- Local data warehouse setup with PostgreSQL
