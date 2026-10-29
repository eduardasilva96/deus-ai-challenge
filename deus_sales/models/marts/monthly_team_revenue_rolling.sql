
with calendar as (

    select
        month,
        team
    from {{ ref('stg_monthly_targets') }}
    where month >= date '2025-01-01'
      and month < date '2026-01-01'

),

monthly_revenue as (

    select
        invoice_month as month,
        team,
        sum(amount_eur) as monthly_revenue_eur
    from {{ ref('int_invoice_enriched') }}
    where invoice_date >= date '2025-01-01'
      and invoice_date < date '2026-01-01'
      and attribution_status = 'matched'
    group by
        invoice_month,
        team

),

complete_months as (

    select
        c.month,
        c.team,
        coalesce(m.monthly_revenue_eur, 0) as monthly_revenue_eur
    from calendar c
    left join monthly_revenue m
        on c.month = m.month
       and c.team = m.team

)

select
    month,
    team,
    monthly_revenue_eur,
    sum(monthly_revenue_eur) over (
        partition by team
        order by month
        rows between 2 preceding and current row
    ) as trailing_3_month_revenue_eur
from complete_months
order by team, month
