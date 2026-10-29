
select
    i.invoice_id,
    i.account_id
from {{ ref('int_invoices_deduplicated') }} i
left join {{ ref('stg_accounts') }} a
    on i.account_id = a.account_id
where a.account_id is null
