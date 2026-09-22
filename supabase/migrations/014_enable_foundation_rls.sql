-- ============================================================
-- TERRAREZYN ERP
-- STEP 90.5
-- FOUNDATION ROW LEVEL SECURITY
-- ============================================================


-- ============================================================
-- ENABLE RLS
-- ============================================================

alter table public.organizations enable row level security;

alter table public.profiles enable row level security;

alter table public.organization_members enable row level security;

alter table public.roles enable row level security;

alter table public.permissions enable row level security;

alter table public.role_permissions enable row level security;


-- ============================================================
-- ORGANIZATIONS
-- ============================================================

create policy organizations_select_member
on public.organizations
for select
to authenticated
using (
    public.is_organization_member(id)
);


create policy organizations_update_admin
on public.organizations
for update
to authenticated
using (
    public.is_organization_admin(id)
)
with check (
    public.is_organization_admin(id)
);


-- ============================================================
-- PROFILES
-- ============================================================

create policy profiles_select_own
on public.profiles
for select
to authenticated
using (
    id = auth.uid()
);


create policy profiles_update_own
on public.profiles
for update
to authenticated
using (
    id = auth.uid()
)
with check (
    id = auth.uid()
);


-- ============================================================
-- ORGANIZATION MEMBERS
-- ============================================================

create policy organization_members_select_own
on public.organization_members
for select
to authenticated
using (
    user_id = auth.uid()
);


create policy organization_members_select_admin
on public.organization_members
for select
to authenticated
using (
    public.is_organization_admin(organization_id)
);


create policy organization_members_insert_admin
on public.organization_members
for insert
to authenticated
with check (
    public.is_organization_admin(organization_id)
);


create policy organization_members_update_admin
on public.organization_members
for update
to authenticated
using (
    public.is_organization_admin(organization_id)
)
with check (
    public.is_organization_admin(organization_id)
);


create policy organization_members_delete_admin
on public.organization_members
for delete
to authenticated
using (
    public.is_organization_admin(organization_id)
);


-- ============================================================
-- ROLES
-- ============================================================

create policy roles_select_member
on public.roles
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);


create policy roles_insert_admin
on public.roles
for insert
to authenticated
with check (
    public.is_organization_admin(organization_id)
);


create policy roles_update_admin
on public.roles
for update
to authenticated
using (
    public.is_organization_admin(organization_id)
)
with check (
    public.is_organization_admin(organization_id)
);


create policy roles_delete_admin
on public.roles
for delete
to authenticated
using (
    public.is_organization_admin(organization_id)
);


-- ============================================================
-- PERMISSIONS
-- ============================================================
--
-- Permissions are a system-wide catalog.
-- Users can read active permissions.
-- Organizations do not directly modify the permission catalog.
-- ============================================================

create policy permissions_select_authenticated
on public.permissions
for select
to authenticated
using (
    is_active = true
);


-- ============================================================
-- ROLE PERMISSIONS
-- ============================================================

create policy role_permissions_select_member
on public.role_permissions
for select
to authenticated
using (
    exists (
        select 1
        from public.roles r
        where r.id = role_permissions.role_id
          and public.is_organization_member(r.organization_id)
    )
);


create policy role_permissions_insert_admin
on public.role_permissions
for insert
to authenticated
with check (
    exists (
        select 1
        from public.roles r
        where r.id = role_permissions.role_id
          and public.is_organization_admin(r.organization_id)
    )
);


create policy role_permissions_delete_admin
on public.role_permissions
for delete
to authenticated
using (
    exists (
        select 1
        from public.roles r
        where r.id = role_permissions.role_id
          and public.is_organization_admin(r.organization_id)
    )
);


-- ============================================================
-- COMMENTS
-- ============================================================

comment on policy organizations_select_member
on public.organizations is
    'Allows authenticated users to view organizations where they are active members.';

comment on policy organizations_update_admin
on public.organizations is
    'Allows organization administrators to update their organization.';

comment on policy profiles_select_own
on public.profiles is
    'Allows users to view their own profile.';

comment on policy profiles_update_own
on public.profiles is
    'Allows users to update their own profile.';

comment on policy organization_members_select_own
on public.organization_members is
    'Allows users to view their own organization memberships.';

comment on policy organization_members_select_admin
on public.organization_members is
    'Allows organization administrators to view members of their organization.';

comment on policy roles_select_member
on public.roles is
    'Allows organization members to view roles belonging to their organization.';

comment on policy permissions_select_authenticated
on public.permissions is
    'Allows authenticated users to view active TerraRezyn ERP permissions.';