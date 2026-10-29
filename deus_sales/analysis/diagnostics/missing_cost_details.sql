
select
    line_type,
    invoice_id,
    invoice_date,
    account_id,
    opportunity_id,
    amount_eur,
    cost_eur
from {{ ref('int_invoices_deduplicated') }}
where invoice_date >= date '2025-01-01'
  and invoice_date < date '2026-01-01'
  and cost_eur is null
order by invoice_date, invoice_id
