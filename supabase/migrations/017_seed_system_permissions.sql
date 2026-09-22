-- ============================================================
-- TERRAREZYN ERP
-- STEP 90.8
-- SYSTEM PERMISSIONS
-- ============================================================

insert into public.permissions (
    code,
    name,
    description,
    module,
    action
)
values
    (
        'organization.view',
        'View Organization',
        'View organization information.',
        'organization',
        'view'
    ),
    (
        'organization.update',
        'Update Organization',
        'Update organization information.',
        'organization',
        'update'
    ),
    (
        'organization.members.view',
        'View Organization Members',
        'View members belonging to an organization.',
        'organization',
        'members_view'
    ),
    (
        'organization.members.create',
        'Create Organization Members',
        'Add users to an organization.',
        'organization',
        'members_create'
    ),
    (
        'organization.members.update',
        'Update Organization Members',
        'Update organization membership details.',
        'organization',
        'members_update'
    ),
    (
        'organization.members.delete',
        'Delete Organization Members',
        'Remove users from an organization.',
        'organization',
        'members_delete'
    ),
    (
        'roles.view',
        'View Roles',
        'View organization roles.',
        'roles',
        'view'
    ),
    (
        'roles.create',
        'Create Roles',
        'Create organization roles.',
        'roles',
        'create'
    ),
    (
        'roles.update',
        'Update Roles',
        'Update organization roles.',
        'roles',
        'update'
    ),
    (
        'roles.delete',
        'Delete Roles',
        'Delete organization roles.',
        'roles',
        'delete'
    ),
    (
        'permissions.view',
        'View Permissions',
        'View available system permissions.',
        'permissions',
        'view'
    ),
    (
        'accounts.view',
        'View Accounts',
        'View organization bank and personal accounts.',
        'accounts',
        'view'
    ),
    (
        'accounts.create',
        'Create Accounts',
        'Create organization accounts.',
        'accounts',
        'create'
    ),
    (
        'accounts.update',
        'Update Accounts',
        'Update organization accounts.',
        'accounts',
        'update'
    ),
    (
        'accounts.delete',
        'Delete Accounts',
        'Delete organization accounts.',
        'accounts',
        'delete'
    ),
    (
        'categories.view',
        'View Categories',
        'View expenditure categories.',
        'categories',
        'view'
    ),
    (
        'categories.create',
        'Create Categories',
        'Create expenditure categories.',
        'categories',
        'create'
    ),
    (
        'categories.update',
        'Update Categories',
        'Update expenditure categories.',
        'categories',
        'update'
    ),
    (
        'categories.delete',
        'Delete Categories',
        'Delete expenditure categories.',
        'categories',
        'delete'
    ),
    (
        'projects.view',
        'View Projects',
        'View organization projects.',
        'projects',
        'view'
    ),
    (
        'projects.create',
        'Create Projects',
        'Create organization projects.',
        'projects',
        'create'
    ),
    (
        'projects.update',
        'Update Projects',
        'Update organization projects.',
        'projects',
        'update'
    ),
    (
        'projects.delete',
        'Delete Projects',
        'Delete organization projects.',
        'projects',
        'delete'
    ),
    (
        'transactions.view',
        'View Transactions',
        'View organization expenditure transactions.',
        'transactions',
        'view'
    ),
    (
        'transactions.create',
        'Create Transactions',
        'Create expenditure transactions.',
        'transactions',
        'create'
    ),
    (
        'transactions.update',
        'Update Transactions',
        'Update expenditure transactions.',
        'transactions',
        'update'
    ),
    (
        'transactions.delete',
        'Delete Transactions',
        'Delete expenditure transactions.',
        'transactions',
        'delete'
    )
on conflict (code)
do update set
    name = excluded.name,
    description = excluded.description,
    module = excluded.module,
    action = excluded.action,
    is_active = true,
    updated_at = now();


comment on table public.permissions is
    'System-wide permissions available to TerraRezyn ERP organizations.';