# DEUS.ai Challenge

## Overview

This project transforms raw sales and finance data into reporting models that support revenue performance analysis, sales target monitoring, and account ranking.

For this project i used dbt and duckDB. It was built locally while still thinking of following a layered approach that can be adapted to a warehouse.

## questions

The project wanted 3 questions answered:

1. How does monthly revenue and margin contribution compare with sales targets for each team?
2. How is team revenue performing over time, including a trailing three-month revenue view?
3. Which accounts generate the most revenue in each quarter?

The reporting outputs are provided as CSV files in `deliverables/`.

## structure

deus-ai-challenge/
├── deliverables/
│   ├── monthly_team_sales.csv
│   ├── monthly_team_revenue_rolling.csv
│   └── quarterly_top_accounts.csv
└── deus_sales/
    ├── analyses/
    │   └── diagnostics/
    ├── models/
    │   ├── staging/
    │   ├── intermediate/
    │   └── marts/
    ├── seeds/
    ├── scripts/
    ├── tests/
    ├── dbt_project.yml
    └── README.md

- **Staging:** where i standardize the source fields, types, identifiers, dates, and financial values.
- **Intermediate:** deduplicated exact duplicate invoice records and enriched invoices with account, opportunity, and sales representative information.
- **Marts:** produced the reporting tables used for analysis.
- **Tests:** validated key reporting assumptions and data consistency.
- **Analyses/diagnostics:** this i used as specific investigative queries to understand data quality and financial behaviour.
- **Seeds:** contains the input CSVs loaded into DuckDB.
- **Deliverables:** contains the exported reporting tables.

## how i approached the challenge

### 1. Layered transformations

The project separates source standardisation, business transformations, and reporting logic rather than placing all logic in a single query.

This makes the transformations easier to inspect, test, and maintain. Staging models standardise the data; intermediate models handle deduplication and attribution; marts apply the reporting definitions required by the business questions.

### 2. Invoice deduplication

The invoice source contains 143 rows. Exact duplicate records are removed in the intermediate deduplication model, resulting in 136 rows.

Deduplication is based on the full invoice record rather than invoice ID alone. This distinction matters because two records sharing an invoice ID are not necessarily identical. Records with conflicting values should be investigated rather than automatically discarded.

The deduplicated dataset is used as the basis for downstream financial reporting.

### 3. Revenue and sales team attribution

Company-wide net revenue includes deduplicated invoice and credit-note amounts, including records that cannot be attributed to a sales team.

Team reporting uses invoices that can be matched to an opportunity and sales representative with a valid team assignment. This avoids assigning revenue to a team when the source data does not support that attribution.

Consequently, company-wide revenue and team-attributed revenue are different measures. The difference represents revenue that is not included in the team-level report, rather than revenue that should be silently assigned to a team.

### 4. Credit notes and net revenue

Credit notes contain negative financial amounts. They are retained in the calculations so that revenue reflects the net effect of invoices and credits.

Filtering out credit notes or treating every transaction as positive would overstate net revenue and distort financial performance.

### 5. Missing costs and margin reporting

Some invoices have no cost information. Revenue can still be included when the invoice amount is available, but its margin contribution cannot be calculated reliably.

For this reason, the reporting logic does not treat missing costs as zero. A team-month's margin is left unknown when relevant matched invoices have missing cost information. This avoids presenting an incomplete margin calculation as a complete financial result.

The financial summary distinguishes margin contribution on rows with known costs from total company margin. These are not interchangeable measures.

### 6. Monthly targets and rolling revenue

The monthly team sales report is based on the monthly target records, preserving the expected month/team combinations even when a team has no actual revenue in a given month.

The rolling revenue model uses a three-month window consisting of the current month and the preceding two months, calculated separately for each team. Keeping a calendar-based reporting grain prevents months without sales from disappearing from the time series.

### 7. Quarterly top accounts

The quarterly account ranking uses deduplicated invoice records linked to valid accounts, including transactions that cannot be attributed to a sales team. This allows the account ranking to answer a company-wide revenue question rather than only reflecting team-attributed sales.

Credit notes remain signed, and the report returns the three highest-ranked accounts in each quarter.

## Headline financial results — 2025

| Metric | Result |
|---|---:|
| Company-wide net invoice revenue | €9,493,212.43 |
| Revenue attributed to sales teams | €7,796,501.68 |
| Revenue not attributed to sales teams | €1,696,710.75 |
| Revenue associated with missing cost information | €685,250.00 |
| Margin contribution on rows with known costs | €3,967,322.00 |

The margin figure is **incomplete**, not total company margin. Five 2025 invoice rows have missing cost information, affecting €685,250 of revenue.

These figures are based on deduplicated invoice records and include credit notes. Team-attributed revenue uses the narrower attribution rules described above.

## Data quality and validation

The project investigates and validates several data quality concerns:

- Exact duplicate invoice records.
- Missing opportunity references and incomplete sales attribution.
- Missing invoice costs.
- Invoice-to-opportunity account consistency.
- Monthly target completeness and reporting grain.
- Reconciliation between matched invoice revenue and the monthly team sales report.

Automated dbt tests validate key identifiers, reporting grain, revenue reconciliation, and the quarterly top-three output.

Investigative SQL is kept separately from production models so that data quality analysis does not become part of the reporting layer by accident.

## Reproducing the project

Run the following commands from the repository root. Python and dbt with the DuckDB adapter must be installed.

Check the dbt configuration:

```powershell
dbt debug --project-dir .\deus_sales
```

Build the models and run tests:

```powershell
dbt build --project-dir .\deus_sales
```

Export the reporting tables:

```powershell
python .\deus_sales\scripts\export.py
```

The export script writes the three report CSVs to `deliverables/`. The database is generated locally and is not required to be committed to Git.

## Limitations and assumptions

- Revenue is based on invoice amounts net of signed credit notes, not on opportunity pipeline value.
- Sales team attribution depends on valid opportunity and sales representative links.
- Margin cannot be fully calculated where cost information is missing.
- Exact duplicate rows are removed, but potentially conflicting records are not automatically resolved.
- The implementation uses DuckDB for local reproducibility; production deployment to Snowflake would require environment-specific configuration and validation.
