# finance_pipeline

An end-to-end ELT pipeline that extracts financial market data from the Alpha Vantage API, loads it into PostgreSQL, transforms it with dbt, and visualizes it in Metabase.

---

## Overview

This project demonstrates a production-style data pipeline built around a personal finance use case. Raw stock price data is extracted from a public API, loaded into a local PostgreSQL database, transformed into analytics-ready models using dbt, and surfaced through a Metabase dashboard.

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
Dashboard
```

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Python | extract data from API and load into PostgreSQL |
| PostgreSQL | central data store |
| dbt Core | SQL-based transformation layer |
| Metabase | dashboarding and visualization |

---

## Project Structure

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

## Data Source

Stock price data is sourced from the [Alpha Vantage API](https://www.alphavantage.co). The free tier provides up to 25 API calls per day, which is sufficient for this project.

---

## Key Concepts Demonstrated

- ELT pipeline pattern (extract → load raw → transform in-place)
- Separation of raw and analytics data layers
- SQL transformations with dbt including rolling averages and aggregations
- Data lineage and model dependency management via dbt
- Local data warehouse setup with PostgreSQL
