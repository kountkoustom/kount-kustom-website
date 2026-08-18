-- Kount Kustom Admin authorization migration
-- Run once in Supabase SQL Editor if not already applied.

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.admin_users enable row level security;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admin_users where user_id = auth.uid()
  );
$$;

drop policy if exists "admins manage leads" on public.leads;

create policy "admins manage leads"
on public.leads for all to authenticated
using (public.is_admin())
with check (public.is_admin());

grant insert on public.leads to anon, authenticated;
grant select, update, delete on public.leads to authenticated;

grant select on public.admin_users to authenticated;

drop policy if exists "admins read admin_users" on public.admin_users;
create policy "admins read admin_users"
on public.admin_users for select to authenticated
using (public.is_admin());
