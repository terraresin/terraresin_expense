alter table public.organization_members
add column role_id uuid;


alter table public.organization_members
add constraint fk_organization_members_role
    foreign key (role_id)
    references public.roles(id)
    on delete set null;


create index idx_organization_members_role_id
    on public.organization_members(role_id);


comment on column public.organization_members.role_id is
    'Role assigned to the user within this organization.';