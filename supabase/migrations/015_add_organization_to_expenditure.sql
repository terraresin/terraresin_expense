-- ============================================================
-- TERRAREZYN ERP
-- STEP 90.6
-- ADD ORGANIZATION ISOLATION TO EXPENDITURE TABLES
-- ============================================================

-- ------------------------------------------------------------
-- 1. Create the initial TerraResin organization
-- ------------------------------------------------------------

insert into public.organizations (
    name,
    legal_name,
    organization_type,
    country_code,
    currency_code,
    timezone,
    locale,
    date_format,
    number_format
)
values (
    'TerraResin',
    'TerraResin Private Limited',
    'company',
    'IN',
    'INR',
    'Asia/Kolkata',
    'en-IN',
    'dd/MM/yyyy',
    'en-IN'
)
on conflict do nothing;


-- ------------------------------------------------------------
-- 2. Add organization_id to accounts
-- ------------------------------------------------------------

alter table public.accounts
add column organization_id uuid;


-- ------------------------------------------------------------
-- 3. Add organization_id to categories
-- ------------------------------------------------------------

alter table public.categories
add column organization_id uuid;


-- ------------------------------------------------------------
-- 4. Add organization_id to projects
-- ------------------------------------------------------------

alter table public.projects
add column organization_id uuid;


-- ------------------------------------------------------------
-- 5. Add organization_id to transactions
-- ------------------------------------------------------------

alter table public.transactions
add column organization_id uuid;


-- ------------------------------------------------------------
-- 6. Assign existing records to TerraResin
-- ------------------------------------------------------------

update public.accounts
set organization_id = (
    select id
    from public.organizations
    where name = 'TerraResin'
    limit 1
)
where organization_id is null;


update public.categories
set organization_id = (
    select id
    from public.organizations
    where name = 'TerraResin'
    limit 1
)
where organization_id is null;


update public.projects
set organization_id = (
    select id
    from public.organizations
    where name = 'TerraResin'
    limit 1
)
where organization_id is null;


update public.transactions
set organization_id = (
    select id
    from public.organizations
    where name = 'TerraResin'
    limit 1
)
where organization_id is null;


-- ------------------------------------------------------------
-- 7. Make organization_id mandatory
-- ------------------------------------------------------------

alter table public.accounts
alter column organization_id set not null;


alter table public.categories
alter column organization_id set not null;


alter table public.projects
alter column organization_id set not null;


alter table public.transactions
alter column organization_id set not null;


-- ------------------------------------------------------------
-- 8. Add foreign keys
-- ------------------------------------------------------------

alter table public.accounts
add constraint fk_accounts_organization
foreign key (organization_id)
references public.organizations(id)
on delete cascade;


alter table public.categories
add constraint fk_categories_organization
foreign key (organization_id)
references public.organizations(id)
on delete cascade;


alter table public.projects
add constraint fk_projects_organization
foreign key (organization_id)
references public.organizations(id)
on delete cascade;


alter table public.transactions
add constraint fk_transactions_organization
foreign key (organization_id)
references public.organizations(id)
on delete cascade;


-- ------------------------------------------------------------
-- 9. Create organization indexes
-- ------------------------------------------------------------

create index idx_accounts_organization_id
on public.accounts(organization_id);


create index idx_categories_organization_id
on public.categories(organization_id);


create index idx_projects_organization_id
on public.projects(organization_id);


create index idx_transactions_organization_id
on public.transactions(organization_id);


-- ------------------------------------------------------------
-- 10. Replace global category uniqueness
-- ------------------------------------------------------------

alter table public.categories
drop constraint categories_name_key;


alter table public.categories
add constraint uq_categories_organization_name
unique (organization_id, name);


-- ------------------------------------------------------------
-- 11. Replace global project uniqueness
-- ------------------------------------------------------------

alter table public.projects
drop constraint projects_name_key;


alter table public.projects
drop constraint projects_code_key;


alter table public.projects
add constraint uq_projects_organization_name
unique (organization_id, name);


alter table public.projects
add constraint uq_projects_organization_code
unique (organization_id, code);


-- ------------------------------------------------------------
-- 12. Add comments
-- ------------------------------------------------------------

comment on column public.accounts.organization_id is
    'Organization/tenant that owns this account.';

comment on column public.categories.organization_id is
    'Organization/tenant that owns this expense category.';

comment on column public.projects.organization_id is
    'Organization/tenant that owns this project.';

comment on column public.transactions.organization_id is
    'Organization/tenant that owns this transaction.';