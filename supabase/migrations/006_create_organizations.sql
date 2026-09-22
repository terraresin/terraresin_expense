create table public.organizations (
    id uuid primary key default gen_random_uuid(),

    -- ============================================================
    -- BASIC ORGANIZATION INFORMATION
    -- ============================================================

    name text not null,

    legal_name text,

    organization_type text not null default 'company'
        check (
            organization_type in (
                'company',
                'association',
                'trust',
                'society',
                'ngo',
                'other'
            )
        ),

    registration_number text,

    tax_number text,


    -- ============================================================
    -- CONTACT INFORMATION
    -- ============================================================

    email text,

    phone text,

    website text,


    -- ============================================================
    -- ADDRESS
    -- ============================================================

    address_line_1 text,

    address_line_2 text,

    city text,

    state text,

    country_code text not null default 'IN'
        check (char_length(country_code) = 2),

    postal_code text,


    -- ============================================================
    -- REGIONAL SETTINGS
    -- ============================================================

    currency_code text not null default 'INR'
        check (char_length(currency_code) = 3),

    timezone text not null default 'Asia/Kolkata',

    locale text not null default 'en-IN',

    date_format text not null default 'dd/MM/yyyy',

    number_format text not null default 'en-IN',


    -- ============================================================
    -- STATUS
    -- ============================================================

    is_active boolean not null default true,


    -- ============================================================
    -- AUDIT
    -- ============================================================

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now()
);


-- ============================================================
-- INDEXES
-- ============================================================

create index idx_organizations_name
    on public.organizations(name);

create index idx_organizations_is_active
    on public.organizations(is_active);

create index idx_organizations_country_code
    on public.organizations(country_code);


-- ============================================================
-- COMMENTS
-- ============================================================

comment on table public.organizations is
    'Organizations/tenants using the TerraRezyn ERP SaaS platform.';

comment on column public.organizations.country_code is
    'ISO 3166-1 alpha-2 country code, for example IN, AE, US.';

comment on column public.organizations.currency_code is
    'ISO 4217 currency code, for example INR, AED, USD.';

comment on column public.organizations.timezone is
    'IANA timezone identifier, for example Asia/Kolkata or America/New_York.';

comment on column public.organizations.locale is
    'Organization locale, for example en-IN, en-US, or ar-AE.';