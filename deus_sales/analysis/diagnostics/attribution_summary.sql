
select
    attribution_status,
    count(*) as invoice_count,
    sum(amount_eur) as total_amount_eur,
    sum(case
        when invoice_date >= date '2025-01-01'
         and invoice_date < date '2026-01-01'
        then amount_eur
        else 0
    end) as revenue_2025_eur
from {{ ref('int_invoice_enriched') }}
group by attribution_status
order by attribution_status
