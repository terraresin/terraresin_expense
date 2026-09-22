create table public.role_permissions (
    id uuid primary key default gen_random_uuid(),

    -- ============================================================
    -- RELATIONSHIPS
    -- ============================================================

    role_id uuid not null
        references public.roles(id)
        on delete cascade,

    permission_id uuid not null
        references public.permissions(id)
        on delete cascade,


    -- ============================================================
    -- AUDIT
    -- ============================================================

    created_at timestamptz not null default now(),


    -- ============================================================
    -- CONSTRAINTS
    -- ============================================================

    constraint uq_role_permission
        unique (role_id, permission_id)
);


-- ============================================================
-- INDEXES
-- ============================================================

create index idx_role_permissions_role_id
    on public.role_permissions(role_id);

create index idx_role_permissions_permission_id
    on public.role_permissions(permission_id);


-- ============================================================
-- COMMENTS
-- ============================================================

comment on table public.role_permissions is
    'Maps TerraRezyn ERP roles to their permitted actions.';