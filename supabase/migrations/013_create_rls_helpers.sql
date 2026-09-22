-- ============================================================
-- TERRAREZYN ERP
-- STEP 90.4
-- MULTI-TENANT RLS SECURITY HELPERS
-- ============================================================


-- ============================================================
-- FUNCTION: CHECK ORGANIZATION MEMBERSHIP
-- ============================================================
--
-- This function answers:
--
-- "Is the current authenticated user an active member
--  of this organization?"
--
-- SECURITY DEFINER is intentional.
-- It prevents the function from being blocked by the
-- organization_members RLS policies that will use it.
-- ============================================================

create or replace function public.is_organization_member(
    p_organization_id uuid
)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
    select exists (
        select 1
        from public.organization_members om
        where om.organization_id = p_organization_id
          and om.user_id = auth.uid()
          and om.is_active = true
    );
$$;


-- ============================================================
-- FUNCTION: CHECK ORGANIZATION ADMIN
-- ============================================================
--
-- This will be useful later for administrative operations.
--
-- We are checking the role code rather than the role name.
-- Role codes should remain stable even if the display name
-- changes.
-- ============================================================

create or replace function public.is_organization_admin(
    p_organization_id uuid
)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
    select exists (
        select 1
        from public.organization_members om
        inner join public.roles r
            on r.id = om.role_id
        where om.organization_id = p_organization_id
          and om.user_id = auth.uid()
          and om.is_active = true
          and r.is_active = true
          and r.code = 'organization_admin'
    );
$$;


-- ============================================================
-- FUNCTION: CHECK PERMISSION
-- ============================================================
--
-- This will eventually allow policies such as:
--
-- expenditure.create
-- expenditure.approve
-- purchase.create
-- inventory.adjust
--
-- The permission is checked within the user's organization.
-- ============================================================

create or replace function public.has_permission(
    p_organization_id uuid,
    p_permission_code text
)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
    select exists (
        select 1
        from public.organization_members om
        inner join public.roles r
            on r.id = om.role_id
        inner join public.role_permissions rp
            on rp.role_id = r.id
        inner join public.permissions p
            on p.id = rp.permission_id
        where om.organization_id = p_organization_id
          and om.user_id = auth.uid()
          and om.is_active = true
          and r.is_active = true
          and p.is_active = true
          and p.code = p_permission_code
    );
$$;


-- ============================================================
-- FUNCTION: GET CURRENT USER ORGANIZATIONS
-- ============================================================
--
-- Returns organization IDs the current user can access.
--
-- This function will also be useful from the application layer.
-- ============================================================

create or replace function public.get_user_organization_ids()
returns setof uuid
language sql
security definer
set search_path = public
stable
as $$
    select om.organization_id
    from public.organization_members om
    where om.user_id = auth.uid()
      and om.is_active = true;
$$;


-- ============================================================
-- FUNCTION SECURITY
-- ============================================================
--
-- Functions should not be executable by anonymous users.
-- Authenticated users can use them through PostgreSQL/Supabase.
-- ============================================================

revoke execute
on function public.is_organization_member(uuid)
from public;

grant execute
on function public.is_organization_member(uuid)
to authenticated;


revoke execute
on function public.is_organization_admin(uuid)
from public;

grant execute
on function public.is_organization_admin(uuid)
to authenticated;


revoke execute
on function public.has_permission(uuid, text)
from public;

grant execute
on function public.has_permission(uuid, text)
to authenticated;


revoke execute
on function public.get_user_organization_ids()
from public;

grant execute
on function public.get_user_organization_ids()
to authenticated;


-- ============================================================
-- COMMENTS
-- ============================================================

comment on function public.is_organization_member(uuid) is
    'Returns true when the authenticated TerraRezyn ERP user is an active member of the specified organization.';

comment on function public.is_organization_admin(uuid) is
    'Returns true when the authenticated TerraRezyn ERP user has the organization_admin role for the specified organization.';

comment on function public.has_permission(uuid, text) is
    'Returns true when the authenticated TerraRezyn ERP user has the specified permission within the organization.';

comment on function public.get_user_organization_ids() is
    'Returns organization IDs for which the authenticated TerraRezyn ERP user has active membership.';