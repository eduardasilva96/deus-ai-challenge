
select
    count(*) as target_rows,
    sum(case when target_revenue_eur <= 0 then 1 else 0 end)
        as non_positive_targets,
    sum(case when target_revenue_eur is null then 1 else 0 end)
        as null_targets,
    count(distinct month || '-' || team) as distinct_month_team_pairs
from {{ ref('stg_monthly_targets') }}
where month >= date '2025-01-01'
  and month < date '2026-01-01'

