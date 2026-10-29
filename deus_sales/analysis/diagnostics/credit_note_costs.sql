
select
    line_type,
    count(*) as row_count,
    sum(amount_eur) as total_amount_eur,
    sum(cost_eur) as total_cost_eur,
    min(amount_eur) as min_amount_eur,
    max(amount_eur) as max_amount_eur,
    min(cost_eur) as min_cost_eur,
    max(cost_eur) as max_cost_eur,
    sum(case when cost_eur < 0 then 1 else 0 end) as negative_cost_rows,
    sum(case when cost_eur is null then 1 else 0 end) as missing_cost_rows
from {{ ref('int_invoices_deduplicated') }}
group by line_type
order by line_type
