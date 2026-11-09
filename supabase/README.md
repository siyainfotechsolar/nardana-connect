# Supabase Database Schema & Migrations

This folder contains database migrations and SQL schema definitions for **Nardana Connect**.

## Structure
- `schema.sql`: Cumulative or current database schema
- `migrations/`: Versioned migration scripts (`00001_initial_schema.sql`, etc.)

## How to run migrations
Run migrations directly via:
1. Supabase Dashboard: **SQL Editor** -> Paste SQL -> **Run**
2. Or Supabase CLI: `supabase db push` / `supabase migration up`
