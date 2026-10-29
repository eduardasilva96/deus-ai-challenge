
select
    count(*) as mismatch_count
from {{ ref('int_invoices_deduplicated') }} i
inner join {{ ref('stg_opportunities') }} o
    on i.opportunity_id = o.opportunity_id
where i.account_id <> o.account_id
   or i.account_id is null
   or o.account_id is null
