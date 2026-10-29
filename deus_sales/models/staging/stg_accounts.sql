
with source as (

    select *
    from {{ ref('accounts') }}

),

cleaned as (

    select
        trim(account_id) as account_id,
        trim(account_name) as account_name,
        nullif(trim(industry), '') as industry,
        nullif(trim(country), '') as country
    from source

)

select *
from cleaned
