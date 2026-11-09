-- NARDANA CONNECT: Comprehensive Village Community Platform Schema
-- Extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ====================================================================
-- 1. ROLES AND ACCESS CONTROL
-- ====================================================================

create table if not exists public.roles (
    id text primary key,
    description text
);

insert into public.roles (id, description) values
    ('super_admin', 'Full platform administrator'),
    ('village_admin', 'Gram Panchayat or Village Official Admin'),
    ('moderator', 'Community moderator for content approval'),
    ('citizen', 'Standard village citizen / user')
on conflict (id) do nothing;

-- ====================================================================
-- 2. VILLAGES (Nardana & Surrounding Region)
-- ====================================================================

create table if not exists public.villages (
    id uuid primary key default gen_random_uuid(),
    name_mr text not null,
    name_en text not null,
    taluka text default 'Shindkheda' not null,
    district text default 'Dhule' not null,
    pincode text default '425404' not null,
    is_active boolean default true not null,
    created_at timestamptz default now() not null
);

create index if not exists idx_villages_active on public.villages(is_active);

-- ====================================================================
-- 3. CITIZEN PROFILES
-- ====================================================================

create table if not exists public.profiles (
    id uuid primary key references auth.users on delete cascade,
    full_name text,
    phone text unique,
    village_id uuid references public.villages(id) on delete set null,
    avatar_url text,
    preferred_language text default 'mr' check (preferred_language in ('mr', 'en')),
    role text default 'citizen' references public.roles(id),
    is_blocked boolean default false,
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null
);

create index if not exists idx_profiles_phone on public.profiles(phone);
create index if not exists idx_profiles_village on public.profiles(village_id);

-- User Roles Junction Table for granular RBAC
create table if not exists public.user_roles (
    user_id uuid references auth.users(id) on delete cascade not null,
    role_id text references public.roles(id) on delete cascade not null,
    assigned_at timestamptz default now() not null,
    primary key (user_id, role_id)
);

-- ====================================================================
-- 4. CATEGORIES (Local Services & Shops)
-- ====================================================================

create table if not exists public.categories (
    id uuid primary key default gen_random_uuid(),
    name_mr text not null,
    name_en text not null,
    slug text unique not null,
    group_type text not null check (group_type in ('home_services', 'shops', 'agriculture', 'transport', 'health', 'education', 'digital', 'other')),
    icon text not null default 'store',
    sort_order int default 0 not null,
    is_active boolean default true not null,
    created_at timestamptz default now() not null
);

create index if not exists idx_categories_group on public.categories(group_type);

-- ====================================================================
-- 5. BUSINESSES AND LOCAL SERVICES
-- ====================================================================

create table if not exists public.businesses (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete set null,
    village_id uuid references public.villages(id) on delete restrict not null,
    category_id uuid references public.categories(id) on delete restrict not null,
    business_name_mr text not null,
    business_name_en text not null,
    owner_name text not null,
    phone text not null,
    whatsapp text,
    address text not null,
    description text,
    photos text[] default '{}' not null,
    opening_hours text,
    map_lat double precision,
    map_lng double precision,
    status text default 'pending' check (status in ('pending', 'approved', 'rejected')),
    rejection_reason text,
    view_count int default 0 not null,
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null
);

create index if not exists idx_businesses_village on public.businesses(village_id);
create index if not exists idx_businesses_category on public.businesses(category_id);
create index if not exists idx_businesses_status on public.businesses(status);

-- ====================================================================
-- 6. JOBS AND EMPLOYMENT MODULE
-- ====================================================================

create table if not exists public.jobs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete set null,
    village_id uuid references public.villages(id) on delete restrict not null,
    job_title text not null,
    company_name text not null,
    employer_name text not null,
    salary_range text,
    qualification text,
    experience text,
    job_location text not null,
    contact_number text not null,
    description text not null,
    job_type text default 'Full-time' check (job_type in ('Full-time', 'Part-time', 'Daily Wage', 'Contract')),
    last_date date,
    status text default 'pending' check (status in ('pending', 'approved', 'rejected', 'expired')),
    rejection_reason text,
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null
);

create index if not exists idx_jobs_village on public.jobs(village_id);
create index if not exists idx_jobs_status on public.jobs(status);

-- ====================================================================
-- 7. BUY & SELL MARKETPLACE
-- ====================================================================

create table if not exists public.marketplace_items (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete set null,
    village_id uuid references public.villages(id) on delete restrict not null,
    title text not null,
    category text not null,
    price numeric(12,2) not null,
    description text not null,
    images text[] default '{}' not null,
    seller_name text not null,
    phone text not null,
    listing_type text default 'SELL' check (listing_type in ('SELL', 'WANTED')),
    status text default 'pending' check (status in ('pending', 'approved', 'rejected')),
    is_sold boolean default false not null,
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null
);

create index if not exists idx_marketplace_village on public.marketplace_items(village_id);
create index if not exists idx_marketplace_status on public.marketplace_items(status);

-- ====================================================================
-- 8. VILLAGE NOTICES & GRAM PANCHAYAT UPDATES
-- ====================================================================

create table if not exists public.notices (
    id uuid primary key default gen_random_uuid(),
    village_id uuid references public.villages(id) on delete cascade not null,
    title_mr text not null,
    title_en text not null,
    description_mr text not null,
    description_en text not null,
    image_url text,
    pdf_url text,
    published_date timestamptz default now() not null,
    expiry_date timestamptz,
    priority text default 'normal' check (priority in ('normal', 'high', 'emergency')),
    is_gram_panchayat boolean default false not null,
    status text default 'published' check (status in ('draft', 'published', 'expired', 'archived')),
    created_by uuid references auth.users(id) on delete set null,
    created_at timestamptz default now() not null
);

create index if not exists idx_notices_village on public.notices(village_id);
create index if not exists idx_notices_status on public.notices(status);

-- ====================================================================
-- 9. EMERGENCY CONTACTS (Village Quick Dial)
-- ====================================================================

create table if not exists public.emergency_contacts (
    id uuid primary key default gen_random_uuid(),
    village_id uuid references public.villages(id) on delete cascade,
    name_mr text not null,
    name_en text not null,
    category text not null,
    phone text not null,
    secondary_phone text,
    sort_order int default 0 not null,
    is_active boolean default true not null
);

-- ====================================================================
-- 10. CITIZEN FAVORITES
-- ====================================================================

create table if not exists public.favorites (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete cascade not null,
    item_type text not null check (item_type in ('business', 'job', 'marketplace', 'notice')),
    item_id uuid not null,
    created_at timestamptz default now() not null,
    unique (user_id, item_type, item_id)
);

create index if not exists idx_favorites_user on public.favorites(user_id);

-- ====================================================================
-- 11. BANNERS
-- ====================================================================

create table if not exists public.banners (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    image_url text not null,
    link_type text,
    link_id uuid,
    village_id uuid references public.villages(id) on delete cascade,
    is_active boolean default true not null,
    sort_order int default 0 not null,
    created_at timestamptz default now() not null
);

-- ====================================================================
-- 12. COMPLAINTS & CONTENT REPORTS
-- ====================================================================

create table if not exists public.complaints (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete set null,
    target_type text not null check (target_type in ('business', 'job', 'marketplace', 'notice', 'other')),
    target_id uuid not null,
    reason text not null,
    status text default 'pending' check (status in ('pending', 'investigating', 'resolved', 'dismissed')),
    admin_notes text,
    created_at timestamptz default now() not null
);

-- ====================================================================
-- 13. BUSINESS REVIEWS & RATINGS
-- ====================================================================

create table if not exists public.reviews (
    id uuid primary key default gen_random_uuid(),
    business_id uuid references public.businesses(id) on delete cascade not null,
    user_id uuid references auth.users(id) on delete cascade not null,
    rating int not null check (rating between 1 and 5),
    comment text,
    created_at timestamptz default now() not null,
    unique(business_id, user_id)
);

-- ====================================================================
-- 14. APP SETTINGS & AUDIT LOGS
-- ====================================================================

create table if not exists public.app_settings (
    key text primary key,
    value jsonb not null,
    description text,
    updated_at timestamptz default now() not null
);

create table if not exists public.audit_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete set null,
    action text not null,
    entity_type text not null,
    entity_id text,
    details jsonb,
    ip_address text,
    created_at timestamptz default now() not null
);

-- ====================================================================
-- 15. ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================

alter table public.villages enable row level security;
alter table public.profiles enable row level security;
alter table public.roles enable row level security;
alter table public.user_roles enable row level security;
alter table public.categories enable row level security;
alter table public.businesses enable row level security;
alter table public.jobs enable row level security;
alter table public.marketplace_items enable row level security;
alter table public.notices enable row level security;
alter table public.emergency_contacts enable row level security;
alter table public.favorites enable row level security;
alter table public.banners enable row level security;
alter table public.complaints enable row level security;
alter table public.reviews enable row level security;
alter table public.app_settings enable row level security;
alter table public.audit_logs enable row level security;

-- Security helper functions
create or replace function public.is_admin(check_user_id uuid)
returns boolean as $$
begin
    return exists (
        select 1 from public.profiles
        where id = check_user_id and role in ('super_admin', 'village_admin')
    ) or exists (
        select 1 from public.user_roles
        where user_id = check_user_id and role_id in ('super_admin', 'village_admin')
    );
end;
$$ language plpgsql security definer;

create or replace function public.is_moderator(check_user_id uuid)
returns boolean as $$
begin
    return exists (
        select 1 from public.profiles
        where id = check_user_id and role in ('super_admin', 'village_admin', 'moderator')
    ) or exists (
        select 1 from public.user_roles
        where user_id = check_user_id and role_id in ('super_admin', 'village_admin', 'moderator')
    );
end;
$$ language plpgsql security definer;

-- Public read policies
create policy "Public can read active villages" on public.villages for select using (is_active = true);
create policy "Public can read active categories" on public.categories for select using (is_active = true);
create policy "Public can read active emergency contacts" on public.emergency_contacts for select using (is_active = true);
create policy "Public can read active banners" on public.banners for select using (is_active = true);
create policy "Public can read approved businesses" on public.businesses for select using (status = 'approved' or auth.uid() = user_id or public.is_moderator(auth.uid()));
create policy "Public can read approved jobs" on public.jobs for select using (status = 'approved' or auth.uid() = user_id or public.is_moderator(auth.uid()));
create policy "Public can read approved marketplace" on public.marketplace_items for select using (status = 'approved' or auth.uid() = user_id or public.is_moderator(auth.uid()));
create policy "Public can read published notices" on public.notices for select using (status = 'published' or public.is_moderator(auth.uid()));
create policy "Public can read reviews" on public.reviews for select using (true);
create policy "Public can read app settings" on public.app_settings for select using (true);

-- Profile policies
create policy "Users can read all profiles" on public.profiles for select using (true);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- Authenticated citizen actions
create policy "Authenticated citizens can insert businesses" on public.businesses for insert with check (auth.uid() = user_id);
create policy "Owners can update own businesses" on public.businesses for update using (auth.uid() = user_id or public.is_moderator(auth.uid()));
create policy "Owners can delete own businesses" on public.businesses for delete using (auth.uid() = user_id or public.is_admin(auth.uid()));

create policy "Authenticated citizens can insert jobs" on public.jobs for insert with check (auth.uid() = user_id);
create policy "Owners can update own jobs" on public.jobs for update using (auth.uid() = user_id or public.is_moderator(auth.uid()));
create policy "Owners can delete own jobs" on public.jobs for delete using (auth.uid() = user_id or public.is_admin(auth.uid()));

create policy "Authenticated citizens can insert marketplace" on public.marketplace_items for insert with check (auth.uid() = user_id);
create policy "Owners can update own marketplace" on public.marketplace_items for update using (auth.uid() = user_id or public.is_moderator(auth.uid()));
create policy "Owners can delete own marketplace" on public.marketplace_items for delete using (auth.uid() = user_id or public.is_admin(auth.uid()));

create policy "Users can manage own favorites" on public.favorites for all using (auth.uid() = user_id);
create policy "Users can create reviews" on public.reviews for insert with check (auth.uid() = user_id);
create policy "Users can update own reviews" on public.reviews for update using (auth.uid() = user_id);
create policy "Users can submit complaints" on public.complaints for insert with check (auth.uid() = user_id or auth.uid() is null);

-- Admin & Moderator policies for full table management
create policy "Admins can manage villages" on public.villages for all using (public.is_admin(auth.uid()));
create policy "Admins can manage categories" on public.categories for all using (public.is_admin(auth.uid()));
create policy "Moderators can manage notices" on public.notices for all using (public.is_moderator(auth.uid()));
create policy "Admins can manage emergency contacts" on public.emergency_contacts for all using (public.is_admin(auth.uid()));
create policy "Admins can manage banners" on public.banners for all using (public.is_admin(auth.uid()));
create policy "Admins can manage complaints" on public.complaints for all using (public.is_admin(auth.uid()));
create policy "Admins can manage app settings" on public.app_settings for all using (public.is_admin(auth.uid()));
create policy "Admins can read audit logs" on public.audit_logs for select using (public.is_admin(auth.uid()));

-- ====================================================================
-- 16. USER CREATION TRIGGER
-- ====================================================================

create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (id, full_name, phone, avatar_url, role)
    values (
        new.id,
        coalesce(new.raw_user_meta_data->>'full_name', ''),
        coalesce(new.phone, new.raw_user_meta_data->>'phone'),
        coalesce(new.raw_user_meta_data->>'avatar_url', ''),
        'citizen'
    )
    on conflict (id) do update set
        phone = excluded.phone,
        full_name = case when public.profiles.full_name is null or public.profiles.full_name = '' then excluded.full_name else public.profiles.full_name end,
        updated_at = now();
    return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

