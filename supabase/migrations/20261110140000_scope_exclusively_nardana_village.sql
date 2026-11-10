-- Migration: Set Exclusively Nardana Village Scope
-- Date: 2026-11-10
-- Rule: NARDANA CONNECT serves NARDANA VILLAGE ONLY. No other village coverage.

-- 1. Reassign all existing records to Nardana
UPDATE public.businesses SET village_id = 'a0000000-0000-0000-0000-000000000001';
UPDATE public.jobs SET village_id = 'a0000000-0000-0000-0000-000000000001';
UPDATE public.marketplace_items SET village_id = 'a0000000-0000-0000-0000-000000000001';
UPDATE public.notices SET village_id = 'a0000000-0000-0000-0000-000000000001';
UPDATE public.emergency_contacts SET village_id = 'a0000000-0000-0000-0000-000000000001';
UPDATE public.profiles SET village_id = 'a0000000-0000-0000-0000-000000000001';
UPDATE public.banners SET village_id = 'a0000000-0000-0000-0000-000000000001';

-- 2. Remove all non-Nardana villages from database
DELETE FROM public.villages WHERE id != 'a0000000-0000-0000-0000-000000000001';

-- 3. Set default village_id on all tables to Nardana
ALTER TABLE public.businesses ALTER COLUMN village_id SET DEFAULT 'a0000000-0000-0000-0000-000000000001';
ALTER TABLE public.jobs ALTER COLUMN village_id SET DEFAULT 'a0000000-0000-0000-0000-000000000001';
ALTER TABLE public.marketplace_items ALTER COLUMN village_id SET DEFAULT 'a0000000-0000-0000-0000-000000000001';
ALTER TABLE public.notices ALTER COLUMN village_id SET DEFAULT 'a0000000-0000-0000-0000-000000000001';
ALTER TABLE public.emergency_contacts ALTER COLUMN village_id SET DEFAULT 'a0000000-0000-0000-0000-000000000001';
ALTER TABLE public.profiles ALTER COLUMN village_id SET DEFAULT 'a0000000-0000-0000-0000-000000000001';
ALTER TABLE public.banners ALTER COLUMN village_id SET DEFAULT 'a0000000-0000-0000-0000-000000000001';

-- 4. Set Nardana village record details
UPDATE public.villages 
SET name_mr = 'नरडाणा', 
    name_en = 'Nardana', 
    taluka = 'शिंदखेडा (Shindkheda)', 
    district = 'धुळे (Dhule)', 
    pincode = '425404', 
    is_active = true
WHERE id = 'a0000000-0000-0000-0000-000000000001';

