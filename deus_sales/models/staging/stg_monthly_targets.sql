
with source as (

    select *
    from {{ ref('monthly_targets') }}

),

cleaned as (

    select
        cast(concat(trim(month), '-01') as date) as month,
        trim(team) as team,
        cast(target_revenue_eur as decimal(12, 2)) as target_revenue_eur
    from source

)

select *
from cleaned
