alter table public.transactions
add column direction text
    check (direction in ('credit', 'debit'));