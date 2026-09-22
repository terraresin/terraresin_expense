create table public.roles (
    id uuid primary key default gen_random_uuid(),

    -- ============================================================
    -- ORGANIZATION
    -- ============================================================

    organization_id uuid not null
        references public.organizations(id)
        on delete cascade,


    -- ============================================================
    -- ROLE INFORMATION
    -- ============================================================

    name text not null,

    code text not null,

    description text,

    is_system_role boolean not null default false,

    is_active boolean not null default true,


    -- ============================================================
    -- AUDIT
    -- ============================================================

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),


    -- ============================================================
    -- CONSTRAINTS
    -- ============================================================

    constraint uq_roles_organization_code
        unique (organization_id, code)
);


-- ============================================================
-- INDEXES
-- ============================================================

create index idx_roles_organization_id
    on public.roles(organization_id);

create index idx_roles_active
    on public.roles(is_active);


-- ============================================================
-- COMMENTS
-- ============================================================

comment on table public.roles is
    'Organization-specific roles used by the TerraRezyn ERP authorization system.';

comment on column public.roles.organization_id is
    'Organization that owns this role.';

comment on column public.roles.code is
    'Unique role code within an organization.';

comment on column public.roles.is_system_role is
    'Indicates a role created by the TerraRezyn platform rather than the organization administrator.';