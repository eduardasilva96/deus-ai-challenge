
select
    count(*) as invoice_rows,
    sum(amount_eur) as net_revenue_eur,
    sum(case
        when cost_eur is null then 1
        else 0
    end) as missing_cost_rows,
    sum(case
        when cost_eur is not null then amount_eur - cost_eur
        else 0
    end) as margin_on_rows_with_known_costs_eur,
    sum(case
        when cost_eur is null then amount_eur
        else 0
    end) as revenue_with_missing_cost_eur
from {{ ref('int_invoices_deduplicated') }}
where invoice_date >= date '2025-01-01'
  and invoice_date < date '2026-01-01'
