
with invoices as (

    select *
    from {{ ref('int_invoices_deduplicated') }}

),

opportunities as (

    select *
    from {{ ref('stg_opportunities') }}

),

accounts as (

    select *
    from {{ ref('stg_accounts') }}

),

sales_reps as (

    select *
    from {{ ref('stg_sales_reps') }}

),

enriched as (

    select
        i.invoice_id,
        i.invoice_date,
        date_trunc('month', i.invoice_date)::date as invoice_month,
        i.account_id,
        a.account_name,
        a.industry,
        a.country,
        i.opportunity_id,
        o.rep_id,
        r.rep_name,
        r.team,
        i.line_type,
        i.amount_eur,
        i.cost_eur,
        case
            when i.opportunity_id is null then 'missing_opportunity_id'
            when o.opportunity_id is null then 'opportunity_not_found'
            when r.rep_id is null then 'sales_rep_not_found'
            else 'matched'
        end as attribution_status
    from invoices i
    left join opportunities o
        on i.opportunity_id = o.opportunity_id
    left join accounts a
        on i.account_id = a.account_id
    left join sales_reps r
        on o.rep_id = r.rep_id

)

select *
from enriched
