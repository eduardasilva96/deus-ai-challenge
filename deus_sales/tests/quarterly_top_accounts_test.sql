
with quarter_counts as (
    select
        quarter,
        count(*) as ranked_accounts,
        count(distinct account_id) as distinct_accounts
    from {{ ref('quarterly_top_accounts') }}
    group by quarter
)

select *
from quarter_counts
where ranked_accounts <> 3
   or distinct_accounts <> 3
