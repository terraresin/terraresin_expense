create table public.permissions (
    id uuid primary key default gen_random_uuid(),

    -- ============================================================
    -- PERMISSION INFORMATION
    -- ============================================================

    code text not null,

    name text not null,

    description text,

    module text not null,

    action text not null,

    is_active boolean not null default true,


    -- ============================================================
    -- AUDIT
    -- ============================================================

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),


    -- ============================================================
    -- CONSTRAINTS
    -- ============================================================

    constraint uq_permissions_code
        unique (code)
);


-- ============================================================
-- INDEXES
-- ============================================================

create index idx_permissions_module
    on public.permissions(module);

create index idx_permissions_action
    on public.permissions(action);

create index idx_permissions_active
    on public.permissions(is_active);


-- ============================================================
-- COMMENTS
-- ============================================================

comment on table public.permissions is
    'System permissions available in the TerraRezyn ERP platform.';

comment on column public.permissions.code is
    'Unique permission code such as expenditure.create.';

comment on column public.permissions.module is
    'ERP module associated with the permission.';

comment on column public.permissions.action is
    'Action allowed by the permission.';