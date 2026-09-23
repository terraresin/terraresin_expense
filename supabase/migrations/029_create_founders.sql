create table public.founders (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null
        references public.organizations(id)
        on delete cascade,
    name text not null,
    code text not null,
    contact text,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint uq_founders_organization_code unique (organization_id, code)
);

create index idx_founders_organization_name
    on public.founders(organization_id, name);

alter table public.founders enable row level security;

create policy founders_select_member
on public.founders
for select
to authenticated
using (public.is_organization_member(organization_id));

create policy founders_insert_member
on public.founders
for insert
to authenticated
with check (public.is_organization_member(organization_id));

create policy founders_update_member
on public.founders
for update
to authenticated
using (public.is_organization_member(organization_id))
with check (public.is_organization_member(organization_id));

insert into public.founders (organization_id, name, code, contact)
select organization.id, seed.name, seed.code, seed.contact
from (
    values
        ('Chaitanya Chintala', 'FO-001', 'chaitanya@terrarezyn.com'),
        ('Srikanth Chintala', 'FO-002', 'srikanth@terrarezyn.com'),
        ('Krishna Chaitanya K', 'FO-003', 'krishna@terrarezyn.com')
) as seed(name, code, contact)
cross join lateral (
    select id
    from public.organizations
    where name = 'TerraResin'
    order by created_at
    limit 1
) as organization;

alter table public.transactions
    add column founder_id uuid
        references public.founders(id)
        on delete set null;

create index idx_transactions_founder_id
    on public.transactions(founder_id);