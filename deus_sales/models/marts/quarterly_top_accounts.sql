
with quarterly_account_revenue as (
    select
        date_trunc('quarter', i.invoice_date)::date as quarter,
        i.account_id,
        a.account_name,
        sum(i.amount_eur) as revenue_eur
    from {{ ref('int_invoices_deduplicated') }} i
    inner join {{ ref('stg_accounts') }} a
        on i.account_id = a.account_id
    where i.invoice_date >= date '2025-01-01'
      and i.invoice_date < date '2026-01-01'
    group by
        date_trunc('quarter', i.invoice_date)::date,
        i.account_id,
        a.account_name
),

ranked_accounts as (
    select
        quarter,
        account_id,
        account_name,
        revenue_eur,
        row_number() over (
            partition by quarter
            order by revenue_eur desc, account_id
        ) as revenue_rank
    from quarterly_account_revenue
)

select
    quarter,
    revenue_rank,
    account_id,
    account_name,
    revenue_eur
from ranked_accounts
where revenue_rank <= 3
order by quarter, revenue_rank
