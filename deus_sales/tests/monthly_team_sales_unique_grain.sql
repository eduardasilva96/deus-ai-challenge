
select
    month,
    team,
    count(*) as row_count
from {{ ref('monthly_team_sales') }}
group by month, team
having count(*) > 1
