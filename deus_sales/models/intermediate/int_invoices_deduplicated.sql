
with ranked as (

    select
        *,
        row_number() over (
            partition by
                invoice_id,
                invoice_date,
                account_id,
                opportunity_id,
                line_type,
                amount_eur,
                cost_eur
            order by invoice_id
        ) as row_num
    from {{ ref('stg_invoices') }}

)

select
    invoice_id,
    invoice_date,
    account_id,
    opportunity_id,
    line_type,
    amount_eur,
    cost_eur
from ranked
where row_num = 1
