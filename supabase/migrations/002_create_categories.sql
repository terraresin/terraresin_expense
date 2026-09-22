create table public.categories (
    id uuid primary key default gen_random_uuid(),

    name text not null unique,

    description text,

    is_active boolean not null default true,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now()
);

insert into public.categories (name, description)
values
    ('Raw Materials', 'Raw materials and chemical purchases'),
    ('Machinery', 'Plant machinery and equipment'),
    ('Construction', 'Building, civil and construction expenses'),
    ('Transport', 'Transportation, logistics and freight'),
    ('Salaries', 'Employee salaries and wages'),
    ('Office Expenses', 'Office and administrative expenses'),
    ('Utilities', 'Electricity, water, internet and utilities'),
    ('Licences & Approvals', 'Government licences, approvals and statutory fees'),
    ('Professional Fees', 'Consultancy, legal, accounting and professional services'),
    ('Travel', 'Business travel and accommodation'),
    ('Maintenance', 'Plant, machinery and office maintenance'),
    ('Marketing', 'Marketing, advertising and promotional expenses'),
    ('Insurance', 'Insurance and related expenses'),
    ('Bank Charges', 'Bank charges and financial service fees'),
    ('Other', 'Other miscellaneous expenses');