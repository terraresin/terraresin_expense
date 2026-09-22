insert into public.organization_members (
    organization_id,
    user_id,
    role_id,
    is_primary,
    is_active
)
select
    o.id,
    'd749dc05-b6a6-422a-9202-03c735e60496',
    r.id,
    true,
    true
from public.organizations o
inner join public.roles r
    on r.organization_id = o.id
where o.name = 'TerraResin'
  and r.code = 'organization_admin';


  select
    om.id as membership_id,
    om.organization_id,
    o.name as organization_name,
    om.user_id,
    om.role_id,
    r.name as role_name,
    r.code as role_code,
    om.is_primary,
    om.is_active
from public.organization_members om
inner join public.organizations o
    on o.id = om.organization_id
inner join public.roles r
    on r.id = om.role_id
where om.user_id = 'd749dc05-b6a6-422a-9202-03c735e60496';

select
    p.id,
    p.display_name,
    p.phone,
    p.locale,
    p.timezone,
    p.is_active,
    p.created_at
from public.profiles p
where p.id = 'd749dc05-b6a6-422a-9202-03c735e60496';

select
    table_name,
    column_name,
    is_nullable
from information_schema.columns
where table_schema = 'public'
  and table_name in (
      'accounts',
      'categories',
      'projects',
      'transactions'
  )
  and column_name = 'organization_id'
order by table_name;

select
    tc.table_name,
    kcu.column_name,
    ccu.table_name as referenced_table,
    ccu.column_name as referenced_column
from information_schema.table_constraints tc
inner join information_schema.key_column_usage kcu
    on tc.constraint_name = kcu.constraint_name
    and tc.table_schema = kcu.table_schema
inner join information_schema.constraint_column_usage ccu
    on tc.constraint_name = ccu.constraint_name
    and tc.table_schema = ccu.table_schema
where tc.constraint_type = 'FOREIGN KEY'
  and tc.table_schema = 'public'
  and kcu.column_name = 'organization_id'
order by tc.table_name;

select
    schemaname,
    tablename,
    rowsecurity,
    (
        select count(*)
        from pg_policies p
        where p.schemaname = c.schemaname
          and p.tablename = c.tablename
    ) as policy_count
from pg_tables c
where schemaname = 'public'
  and tablename in (
      'organizations',
      'profiles',
      'organization_members',
      'roles',
      'permissions',
      'role_permissions',
      'accounts',
      'categories',
      'projects',
      'transactions'
  )
order by tablename;

select
    tablename,
    rowsecurity,
    (
        select count(*)
        from pg_policies p
        where p.schemaname = 'public'
          and p.tablename = c.tablename
    ) as policy_count
from pg_tables c
where schemaname = 'public'
  and tablename in (
      'organizations',
      'profiles',
      'organization_members',
      'roles',
      'permissions',
      'role_permissions',
      'accounts',
      'categories',
      'projects',
      'transactions'
  )
order by tablename;


select
    r.name as role_name,
    r.code as role_code,
    count(rp.permission_id) as permission_count
from public.roles r
left join public.role_permissions rp
    on rp.role_id = r.id
where r.organization_id = (
    select id
    from public.organizations
    where name = 'TerraResin'
    limit 1
)
and r.code = 'organization_admin'
group by
    r.id,
    r.name,
    r.code;

   select
    public.has_permission(
        (
            select id
            from public.organizations
            where name = 'TerraResin'
            limit 1
        ),
        'transactions.create'
    ) as can_create_transactions;

    select
    routine_name,
    routine_type
from information_schema.routines
where routine_schema = 'public'
  and routine_name in (
      'is_organization_member',
      'is_organization_admin',
      'has_permission',
      'get_user_organization_ids'
  )
order by routine_name;

select
    name,
    legal_name,
    country_code,
    currency_code,
    timezone,
    locale,
    date_format,
    number_format,
    is_active
from public.organizations
where name = 'TerraResin';

select
    om.user_id,
    o.name as organization_name,
    r.name as role_name,
    r.code as role_code,
    om.is_primary,
    om.is_active
from public.organization_members om
inner join public.organizations o
    on o.id = om.organization_id
inner join public.roles r
    on r.id = om.role_id
where om.user_id = 'd749dc05-b6a6-422a-9202-03c735e60496';

insert into public.organization_members (
    organization_id,
    user_id,
    role_id,
    is_primary,
    is_active
)
select
    o.id,
    p.id,
    r.id,
    true,
    true
from public.organizations o
cross join public.profiles p
inner join public.roles r
    on r.organization_id = o.id
   and r.code = 'organization_admin'
where o.name = 'TerraResin'
  and p.id = (
      select id
      from auth.users
      where email = 'terraresin25@gmail.com'
      limit 1
  )
on conflict (organization_id, user_id)
do update set
    role_id = excluded.role_id,
    is_primary = true,
    is_active = true,
    updated_at = now();

    select
    o.name as organization_name,
    p.display_name,
    r.name as role_name,
    r.code as role_code,
    om.is_primary,
    om.is_active
from public.organization_members om
inner join public.organizations o
    on o.id = om.organization_id
inner join public.profiles p
    on p.id = om.user_id
left join public.roles r
    on r.id = om.role_id
where p.id = (
    select id
    from auth.users
    where email = 'terraresin25@gmail.com'
    limit 1
);

select
    u.id as auth_user_id,
    u.email,
    p.id as profile_id,
    p.display_name,
    (u.id = p.id) as ids_match
from auth.users u
left join public.profiles p
    on p.id = u.id
where u.email = 'terraresin25@gmail.com';