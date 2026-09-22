-- ============================================================
-- TERRAREZYN ERP
-- STEP 90.10
-- AUTOMATIC PROFILE CREATION
-- ============================================================


-- ------------------------------------------------------------
-- 1. Create profile creation function
-- ------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.profiles (
        id,
        first_name,
        last_name,
        display_name,
        phone,
        locale,
        timezone
    )
    values (
        new.id,
        new.raw_user_meta_data ->> 'first_name',
        new.raw_user_meta_data ->> 'last_name',
        coalesce(
            new.raw_user_meta_data ->> 'display_name',
            new.raw_user_meta_data ->> 'full_name',
            new.email
        ),
        new.phone,
        new.raw_user_meta_data ->> 'locale',
        new.raw_user_meta_data ->> 'timezone'
    );

    return new;
end;
$$;


-- ------------------------------------------------------------
-- 2. Create trigger on Supabase Auth users
-- ------------------------------------------------------------

drop trigger if exists on_auth_user_created
on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();


-- ------------------------------------------------------------
-- 3. Security
-- ------------------------------------------------------------

revoke execute
on function public.handle_new_user()
from public;

comment on function public.handle_new_user() is
    'Automatically creates a TerraRezyn ERP profile when a Supabase Auth user is created.';