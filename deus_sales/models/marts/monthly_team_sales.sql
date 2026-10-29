
with targets as (

    select
        month,
        team,
        target_revenue_eur
    from {{ ref('stg_monthly_targets') }}
    where month >= date '2025-01-01'
      and month < date '2026-01-01'

),

actuals as (

    select
        invoice_month as month,
        team,
        count(*) as invoice_count,
        sum(amount_eur) as actual_revenue_eur,
        sum(amount_eur - cost_eur) as calculated_margin_eur,
        sum(
            case
                when cost_eur is null then 1
                else 0
            end
        ) as missing_cost_rows
    from {{ ref('int_invoice_enriched') }}
    where invoice_date >= date '2025-01-01'
      and invoice_date < date '2026-01-01'
      and attribution_status = 'matched'
    group by
        invoice_month,
        team

),

report as (

    select
        t.month,
        t.team,
        coalesce(a.invoice_count, 0) as invoice_count,
        coalesce(a.actual_revenue_eur, 0) as actual_revenue_eur,

        case
            when a.invoice_count is null then 0
            when a.missing_cost_rows > 0 then null
            else a.calculated_margin_eur
        end as margin_eur,

        t.target_revenue_eur,

        coalesce(a.actual_revenue_eur, 0)
            - t.target_revenue_eur as variance_to_target_eur,

        100.0 * coalesce(a.actual_revenue_eur, 0)
            / nullif(t.target_revenue_eur, 0)
            as target_attainment_pct,

        coalesce(a.missing_cost_rows, 0) as missing_cost_rows

    from targets t
    left join actuals a
        on t.month = a.month
       and t.team = a.team

)

select *
from report
order by month, team
