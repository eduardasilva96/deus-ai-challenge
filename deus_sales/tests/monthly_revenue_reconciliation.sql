
with invoice_revenue as (
    select sum(amount_eur) as revenue_eur
    from {{ ref('int_invoice_enriched') }}
    where invoice_date >= date '2025-01-01'
      and invoice_date < date '2026-01-01'
      and attribution_status = 'matched'
),

reported_revenue as (
    select sum(actual_revenue_eur) as revenue_eur
    from {{ ref('monthly_team_sales') }}
)

select
    i.revenue_eur as invoice_revenue_eur,
    r.revenue_eur as reported_revenue_eur
from invoice_revenue i
cross join reported_revenue r
where abs(i.revenue_eur - r.revenue_eur) > 0.01
