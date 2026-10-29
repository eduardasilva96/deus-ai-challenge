## Reproducing the project

### Prerequisites

- Python 3.11
- dbt Core
- dbt-duckdb

### Build the project

From the repository root, run:

```powershell
& "$env:APPDATA\Python\Python311\Scripts\dbt.exe" debug --project-dir .\deus_sales
& "$env:APPDATA\Python\Python311\Scripts\dbt.exe" build --project-dir .\deus_sales
```

The project uses a local DuckDB database and does not require a Snowflake account.

### Export reporting tables

After a successful build, run:

```powershell
& "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe" .\deus_sales\scripts\export.py
```

The script exports the reporting models to the repository-root `deliverables/` directory:

- `monthly_team_sales.csv`
- `monthly_team_revenue_rolling.csv`
- `quarterly_top_accounts.csv`
