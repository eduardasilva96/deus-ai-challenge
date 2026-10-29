
select
    line_type,
    count(*) as row_count,
    sum(amount_eur) as total_amount_eur,
    sum(case
        when invoice_date >= date '2025-01-01'
         and invoice_date < date '2026-01-01'
        then amount_eur
        else 0
    end) as amount_2025_eur,
    sum(case
        when cost_eur is null then 1
        else 0
    end) as missing_cost_rows
from {{ ref('int_invoices_deduplicated') }}
group by line_type
order by line_type
