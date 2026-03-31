# finance_pipeline

An end-to-end ELT pipeline that extracts financial market data from the Alpha Vantage API, loads it into PostgreSQL, transforms it with dbt, and visualizes it in Metabase.

---

## overview

This project demonstrates a production-style data pipeline built around a personal finance use case. Raw stock price data is extracted from a public API, loaded into a local PostgreSQL database, transformed into analytics-ready models using dbt, and surfaced through a Metabase dashboard.

---

## pipeline architecture

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
Dashboard
```

---

## tech stack

| tool | purpose |
|------|---------|
| Python | extract data from API and load into PostgreSQL |
| PostgreSQL | central data store |
| dbt Core | SQL-based transformation layer |
| Metabase | dashboarding and visualization |

---

## project structure

```
finance_pipeline/
│
├── extract/
│   └── fetch_prices.py        # pulls stock price data from Alpha Vantage
│
├── dbt/
│   ├── models/
│   │   └── analytics/         # transformed dbt models
│   ├── dbt_project.yml        # dbt project configuration
│   └── profiles.yml.example   # connection config template (see setup)
│
├── .gitignore
├── requirements.txt
└── README.md
```

---

## setup

### prerequisites

- Python 3.8+
- PostgreSQL (running locally on port 5432)
- dbt Core (`pip install dbt-postgres`)
- Metabase (self-hosted, community edition)

### 1. clone the repository

```bash
git clone https://github.com/your-username/finance_pipeline.git
cd finance_pipeline
```

### 2. install Python dependencies

```bash
pip install -r requirements.txt
```

### 3. configure your database connection

Copy the example profiles file and fill in your credentials:

```bash
cp dbt/profiles.yml.example dbt/profiles.yml
```

Edit `dbt/profiles.yml` with your local PostgreSQL credentials. This file is excluded from version control.

### 4. set up your Alpha Vantage API key

Get a free API key at [alphavantage.co](https://www.alphavantage.co) and add it to your environment:

```bash
export ALPHA_VANTAGE_KEY=your_api_key_here
```

### 5. create the database schemas and tables

Run the setup SQL in your PostgreSQL client:

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
```

### 6. run the pipeline

Extract and load raw data:

```bash
python extract/fetch_prices.py
```

Run dbt transformations:

```bash
cd dbt
dbt run
```

### 7. connect Metabase

Open Metabase, connect it to your local PostgreSQL instance, and point it at the `analytics` schema to build your dashboard.

---

## data source

Stock price data is sourced from the [Alpha Vantage API](https://www.alphavantage.co). The free tier provides up to 25 API calls per day, which is sufficient for this project.

---

## key concepts demonstrated

- ELT pipeline pattern (extract → load raw → transform in-place)
- Separation of raw and analytics data layers
- SQL transformations with dbt including rolling averages and aggregations
- Data lineage and model dependency management via dbt
- Local data warehouse setup with PostgreSQL
