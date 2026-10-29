
select
    invoice_id,
    count(*) as row_count,
    count(distinct invoice_date) as dates,
    count(distinct account_id) as accounts,
    count(distinct opportunity_id) as opportunities,
    count(distinct line_type) as line_types,
    count(distinct amount_eur) as amounts,
    count(distinct cost_eur) as costs
from {{ ref('stg_invoices') }}
group by invoice_id
having count(*) > 1
order by invoice_id
