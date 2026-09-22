create table public.projects (
    id uuid primary key default gen_random_uuid(),

    name text not null unique,

    code text unique,

    description text,

    is_active boolean not null default true,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now()
);

insert into public.projects (name, code, description)
values
    (
        'TerraResin Plant',
        'TRP',
        'Overall TerraResin manufacturing plant project'
    ),
    (
        'Plant Construction',
        'CONST',
        'Building, civil and construction works'
    ),
    (
        'Machinery Installation',
        'MACH',
        'Plant machinery procurement and installation'
    ),
    (
        'Working Capital',
        'WC',
        'Working capital and operational funding'
    ),
    (
        'APIIC / Land',
        'APIIC',
        'APIIC land and related expenses'
    ),
    (
        'Future Expansion',
        'EXP',
        'Future plant expansion and additional capacity'
    );
    