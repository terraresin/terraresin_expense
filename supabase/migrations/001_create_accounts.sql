create table public.accounts (
    id uuid primary key default gen_random_uuid(),

    name text not null,

    account_type text not null
        check (account_type in ('bank', 'personal')),

    owner text not null
        check (
            owner in (
                'company',
                'chaitanya',
                'srikanth',
                'krishna_chaitanya'
            )
        ),

    bank_name text,

    account_number text,

    is_active boolean not null default true,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now()
);