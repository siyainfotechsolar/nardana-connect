-- Nardana Connect - Initial Database Schema
-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Profiles table linked to Supabase Auth
create table if not exists public.profiles (
    id uuid references auth.users on delete cascade primary key,
    full_name text,
    avatar_url text,
    phone text,
    role text default 'user' check (role in ('admin', 'user', 'manager')),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security (RLS)
alter table public.profiles enable row level security;

-- Policies for profiles
create policy "Users can view their own profile." 
    on public.profiles for select 
    using (auth.uid() = id);

create policy "Users can update their own profile." 
    on public.profiles for update 
    using (auth.uid() = id);

-- Handle new user signup trigger
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (id, full_name, avatar_url)
    values (
        new.id,
        new.raw_user_meta_data->>'full_name',
        new.raw_user_meta_data->>'avatar_url'
    );
    return new;
end;
$$ language plpgsql security definer;

-- Trigger execution on auth.users create
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

