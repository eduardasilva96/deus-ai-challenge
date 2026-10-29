
with source as (

    select *
    from {{ ref('sales_reps') }}

),

cleaned as (

    select
        trim(rep_id) as rep_id,
        trim(rep_name) as rep_name,
        trim(team) as team
    from source

)

select *
from cleaned
