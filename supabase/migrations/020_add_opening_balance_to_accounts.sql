alter table public.accounts
add column opening_balance numeric(15,2) not null default 0;