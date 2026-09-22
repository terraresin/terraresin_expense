create table public.profiles (
    id uuid primary key
        references auth.users(id)
        on delete cascade,

    -- ============================================================
    -- PERSONAL INFORMATION
    -- ============================================================

    first_name text,

    last_name text,

    display_name text,

    phone text,

    avatar_url text,


    -- ============================================================
    -- USER PREFERENCES
    -- ============================================================

    locale text,

    timezone text,

    date_format text,

    number_format text,


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

create index idx_profiles_display_name
    on public.profiles(display_name);

create index idx_profiles_is_active
    on public.profiles(is_active);


-- ============================================================
-- COMMENTS
-- ============================================================

comment on table public.profiles is
    'Application profiles linked to Supabase Auth users for TerraRezyn ERP.';

comment on column public.profiles.id is
    'Same UUID as auth.users.id.';

comment on column public.profiles.locale is
    'Optional user-specific locale override.';

comment on column public.profiles.timezone is
    'Optional user-specific timezone override. Organization timezone is used when this is null.';