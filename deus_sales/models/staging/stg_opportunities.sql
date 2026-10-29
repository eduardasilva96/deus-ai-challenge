
with source as (

    select *
    from {{ ref('opportunities') }}

),

cleaned as (

    select
        trim(opportunity_id) as opportunity_id,
        trim(account_id) as account_id,
        nullif(trim(rep_id), '') as rep_id,
        cast(created_date as date) as created_date,
        cast(close_date as date) as close_date,
        upper(trim(stage)) as stage,
        cast(amount_eur as decimal(12, 2)) as amount_eur
    from source

)

select *
from cleaned
