-- ============================================================
-- TERRAREZYN ERP
-- STEP 90.7
-- EXPENDITURE TABLE ROW LEVEL SECURITY
-- ============================================================


-- ------------------------------------------------------------
-- 1. Enable RLS
-- ------------------------------------------------------------

alter table public.accounts enable row level security;

alter table public.categories enable row level security;

alter table public.projects enable row level security;

alter table public.transactions enable row level security;


-- ------------------------------------------------------------
-- 2. ACCOUNTS
-- ------------------------------------------------------------

create policy accounts_select_member
on public.accounts
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);

create policy accounts_insert_member
on public.accounts
for insert
to authenticated
with check (
    public.is_organization_member(organization_id)
);

create policy accounts_update_member
on public.accounts
for update
to authenticated
using (
    public.is_organization_member(organization_id)
)
with check (
    public.is_organization_member(organization_id)
);

create policy accounts_delete_member
on public.accounts
for delete
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ------------------------------------------------------------
-- 3. CATEGORIES
-- ------------------------------------------------------------

create policy categories_select_member
on public.categories
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);

create policy categories_insert_member
on public.categories
for insert
to authenticated
with check (
    public.is_organization_member(organization_id)
);

create policy categories_update_member
on public.categories
for update
to authenticated
using (
    public.is_organization_member(organization_id)
)
with check (
    public.is_organization_member(organization_id)
);

create policy categories_delete_member
on public.categories
for delete
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ------------------------------------------------------------
-- 4. PROJECTS
-- ------------------------------------------------------------

create policy projects_select_member
on public.projects
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);

create policy projects_insert_member
on public.projects
for insert
to authenticated
with check (
    public.is_organization_member(organization_id)
);

create policy projects_update_member
on public.projects
for update
to authenticated
using (
    public.is_organization_member(organization_id)
)
with check (
    public.is_organization_member(organization_id)
);

create policy projects_delete_member
on public.projects
for delete
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ------------------------------------------------------------
-- 5. TRANSACTIONS
-- ------------------------------------------------------------

create policy transactions_select_member
on public.transactions
for select
to authenticated
using (
    public.is_organization_member(organization_id)
);

create policy transactions_insert_member
on public.transactions
for insert
to authenticated
with check (
    public.is_organization_member(organization_id)
);

create policy transactions_update_member
on public.transactions
for update
to authenticated
using (
    public.is_organization_member(organization_id)
)
with check (
    public.is_organization_member(organization_id)
);

create policy transactions_delete_member
on public.transactions
for delete
to authenticated
using (
    public.is_organization_member(organization_id)
);


-- ------------------------------------------------------------
-- 6. Documentation
-- ------------------------------------------------------------

comment on policy accounts_select_member
on public.accounts is
    'Allows organization members to view accounts belonging to their organization.';

comment on policy categories_select_member
on public.categories is
    'Allows organization members to view categories belonging to their organization.';

comment on policy projects_select_member
on public.projects is
    'Allows organization members to view projects belonging to their organization.';

comment on policy transactions_select_member
on public.transactions is
    'Allows organization members to view transactions belonging to their organization.';