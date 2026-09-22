-- ============================================================
-- TERRAREZYN ERP
-- STEP 90.9
-- INITIAL ORGANIZATION ADMIN ROLE
-- ============================================================

-- ------------------------------------------------------------
-- 1. Create organization_admin role
-- ------------------------------------------------------------

insert into public.roles (
    organization_id,
    name,
    code,
    description,
    is_system_role,
    is_active
)
select
    id,
    'Organization Administrator',
    'organization_admin',
    'Full administrative access to the organization.',
    true,
    true
from public.organizations
where name = 'TerraResin'
on conflict (organization_id, code)
do update set
    name = excluded.name,
    description = excluded.description,
    is_system_role = true,
    is_active = true,
    updated_at = now();


-- ------------------------------------------------------------
-- 2. Assign all current permissions to organization_admin
-- ------------------------------------------------------------

insert into public.role_permissions (
    role_id,
    permission_id
)
select
    r.id,
    p.id
from public.roles r
cross join public.permissions p
where r.code = 'organization_admin'
  and r.organization_id = (
      select id
      from public.organizations
      where name = 'TerraResin'
      limit 1
  )
  and p.is_active = true
on conflict (role_id, permission_id)
do nothing;


-- ------------------------------------------------------------
-- 3. Documentation
-- ------------------------------------------------------------

comment on table public.roles is
    'Organization-specific roles used by the TerraRezyn ERP authorization system.';

comment on column public.roles.is_system_role is
    'Indicates a role created by the TerraRezyn platform rather than the organization administrator.';