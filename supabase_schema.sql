
-- KOUNT KUSTOM V6 — SUPABASE DATABASE FOUNDATION
-- Run this in Supabase Dashboard > SQL Editor after reviewing it.
-- Do NOT paste any passwords or secret keys here.

create extension if not exists pgcrypto;

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  lead_type text not null check (lead_type in ('audit','edge_box','si_partner','general')),
  name text not null,
  company text,
  mobile text not null,
  email text,
  city text,
  site_type text,
  requirement text,
  source text default 'website',
  status text not null default 'new' check (status in ('new','contacted','qualified','site_visit','proposal','won','lost')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  short_description text,
  description text,
  image_url text,
  active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.solutions (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  short_description text,
  description text,
  image_url text,
  active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.industries (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  description text,
  threats text,
  preventive_approach text,
  image_url text,
  active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.case_studies (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  industry text,
  location text,
  summary text,
  challenge text,
  existing_system text,
  security_gaps text,
  solution text,
  result text,
  image_url text,
  published boolean not null default false,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.knowledge_articles (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  category text,
  excerpt text,
  content text,
  cover_image_url text,
  published boolean not null default false,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.faqs (
  id uuid primary key default gen_random_uuid(),
  question text not null,
  answer text not null,
  category text,
  active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.testimonials (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  company text,
  role text,
  quote text not null,
  image_url text,
  active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.site_settings (
  id uuid primary key default gen_random_uuid(),
  setting_key text unique not null,
  setting_value text,
  updated_at timestamptz not null default now()
);

-- Keep website content public-readable, but require authentication for admin mutations.
alter table public.leads enable row level security;
alter table public.products enable row level security;
alter table public.solutions enable row level security;
alter table public.industries enable row level security;
alter table public.case_studies enable row level security;
alter table public.knowledge_articles enable row level security;
alter table public.faqs enable row level security;
alter table public.testimonials enable row level security;
alter table public.site_settings enable row level security;

-- Public can submit leads, but cannot read the lead table.
create policy "public can submit leads"
on public.leads for insert
to anon, authenticated
with check (true);

-- Authenticated admins can manage all application tables.
-- Admin role is granted through user_metadata.admin = true.
create or replace function public.is_admin()
returns boolean
language sql
stable
as $$
  select coalesce((auth.jwt() -> 'user_metadata' ->> 'admin') = 'true', false);
$$;

create policy "admins manage leads" on public.leads
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "public read active products" on public.products
for select to anon, authenticated using (active = true);
create policy "admins manage products" on public.products
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "public read active solutions" on public.solutions
for select to anon, authenticated using (active = true);
create policy "admins manage solutions" on public.solutions
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "public read active industries" on public.industries
for select to anon, authenticated using (active = true);
create policy "admins manage industries" on public.industries
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "public read published case studies" on public.case_studies
for select to anon, authenticated using (published = true);
create policy "admins manage case studies" on public.case_studies
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "public read published articles" on public.knowledge_articles
for select to anon, authenticated using (published = true);
create policy "admins manage articles" on public.knowledge_articles
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "public read active faqs" on public.faqs
for select to anon, authenticated using (active = true);
create policy "admins manage faqs" on public.faqs
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "public read active testimonials" on public.testimonials
for select to anon, authenticated using (active = true);
create policy "admins manage testimonials" on public.testimonials
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "public read settings" on public.site_settings
for select to anon, authenticated using (true);
create policy "admins manage settings" on public.site_settings
for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Useful indexes
create index if not exists leads_status_idx on public.leads(status);
create index if not exists leads_type_idx on public.leads(lead_type);
create index if not exists leads_created_at_idx on public.leads(created_at desc);
create index if not exists articles_published_idx on public.knowledge_articles(published, published_at desc);
create index if not exists case_studies_published_idx on public.case_studies(published, published_at desc);
