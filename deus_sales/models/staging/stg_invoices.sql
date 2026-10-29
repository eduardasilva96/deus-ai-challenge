
with source as (

    select *
    from {{ ref('invoices') }}

),

cleaned as (

    select
        trim(invoice_id) as invoice_id,
        cast(invoice_date as date) as invoice_date,
        trim(account_id) as account_id,
        nullif(trim(opportunity_id), '') as opportunity_id,
        upper(trim(line_type)) as line_type,
        cast(amount_eur as decimal(12, 2)) as amount_eur,
        cast(cost_eur as decimal(12, 2)) as cost_eur

    from source

)

select *
from cleaned
