create table public.transactions (
    id uuid primary key default gen_random_uuid(),

    transaction_date date not null,

    transaction_type text not null
        check (
            transaction_type in (
                'bank_deposit',
                'bank_withdrawal',
                'company_expense',
                'cheque_payment',
                'personal_expense',
                'founder_contribution',
                'reimbursement'
            )
        ),

    amount numeric(15,2) not null
        check (amount > 0),

    description text not null,

    account_id uuid references public.accounts(id),

    category_id uuid references public.categories(id),

    project_id uuid references public.projects(id),

    payment_method text
        check (
            payment_method in (
                'bank_transfer',
                'cash',
                'cheque',
                'upi',
                'other'
            )
        ),

    cheque_number text,

    cheque_date date,

    reference_number text,

    notes text,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now()
);


create index idx_transactions_transaction_date
    on public.transactions(transaction_date);


create index idx_transactions_account_id
    on public.transactions(account_id);


create index idx_transactions_transaction_type
    on public.transactions(transaction_type);


create index idx_transactions_category_id
    on public.transactions(category_id);


create index idx_transactions_project_id
    on public.transactions(project_id);