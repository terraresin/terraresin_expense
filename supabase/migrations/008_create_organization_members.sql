create table public.organization_members (
    id uuid primary key default gen_random_uuid(),

    -- ============================================================
    -- RELATIONSHIPS
    -- ============================================================

    organization_id uuid not null
        references public.organizations(id)
        on delete cascade,

    user_id uuid not null
        references public.profiles(id)
        on delete cascade,


    -- ============================================================
    -- MEMBERSHIP INFORMATION
    -- ============================================================

    job_title text,

    employee_code text,

    is_primary boolean not null default false,

    is_active boolean not null default true,


    -- ============================================================
    -- AUDIT
    -- ============================================================

    joined_at timestamptz not null default now(),

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),


    -- ============================================================
    -- CONSTRAINTS
    -- ============================================================

    constraint uq_organization_member
        unique (organization_id, user_id)
);


-- ============================================================
-- INDEXES
-- ============================================================

create index idx_organization_members_organization_id
    on public.organization_members(organization_id);

create index idx_organization_members_user_id
    on public.organization_members(user_id);

create index idx_organization_members_active
    on public.organization_members(is_active);


-- ============================================================
-- COMMENTS
-- ============================================================

comment on table public.organization_members is
    'Links TerraRezyn ERP users to organizations they are authorized to access.';

comment on column public.organization_members.organization_id is
    'Organization/tenant this membership belongs to.';

comment on column public.organization_members.user_id is
    'Supabase Auth user profile associated with this membership.';

comment on column public.organization_members.is_primary is
    'Indicates the users preferred primary organization.';

comment on column public.organization_members.job_title is
    'Users job title within this organization.';

comment on column public.organization_members.employee_code is
    'Optional employee code within this organization.';
    