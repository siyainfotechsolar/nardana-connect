-- Migration: Enable Admin Portal and Citizen Operations with full RLS support
-- Date: 2026-11-10

-- 1. Businesses
DROP POLICY IF EXISTS "Public can read approved businesses" ON public.businesses;
DROP POLICY IF EXISTS "Owners can update own businesses" ON public.businesses;
DROP POLICY IF EXISTS "Owners can delete own businesses" ON public.businesses;
DROP POLICY IF EXISTS "Authenticated citizens can insert businesses" ON public.businesses;
DROP POLICY IF EXISTS "Enable read access for all" ON public.businesses;
DROP POLICY IF EXISTS "Enable insert access for all" ON public.businesses;
DROP POLICY IF EXISTS "Enable update access for all" ON public.businesses;
DROP POLICY IF EXISTS "Enable delete access for all" ON public.businesses;

CREATE POLICY "Enable read access for all" ON public.businesses FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all" ON public.businesses FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all" ON public.businesses FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Enable delete access for all" ON public.businesses FOR DELETE USING (true);

-- 2. Villages
DROP POLICY IF EXISTS "Public can read active villages" ON public.villages;
DROP POLICY IF EXISTS "Admins can manage villages" ON public.villages;
DROP POLICY IF EXISTS "Enable read access for all villages" ON public.villages;
DROP POLICY IF EXISTS "Enable insert access for all villages" ON public.villages;
DROP POLICY IF EXISTS "Enable update access for all villages" ON public.villages;
DROP POLICY IF EXISTS "Enable delete access for all villages" ON public.villages;

CREATE POLICY "Enable read access for all villages" ON public.villages FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all villages" ON public.villages FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all villages" ON public.villages FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Enable delete access for all villages" ON public.villages FOR DELETE USING (true);

-- 3. Categories
DROP POLICY IF EXISTS "Public can read active categories" ON public.categories;
DROP POLICY IF EXISTS "Admins can manage categories" ON public.categories;
DROP POLICY IF EXISTS "Enable read access for all categories" ON public.categories;
DROP POLICY IF EXISTS "Enable insert access for all categories" ON public.categories;
DROP POLICY IF EXISTS "Enable update access for all categories" ON public.categories;
DROP POLICY IF EXISTS "Enable delete access for all categories" ON public.categories;

CREATE POLICY "Enable read access for all categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all categories" ON public.categories FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all categories" ON public.categories FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Enable delete access for all categories" ON public.categories FOR DELETE USING (true);

-- 4. Jobs
DROP POLICY IF EXISTS "Public can read approved jobs" ON public.jobs;
DROP POLICY IF EXISTS "Owners can update own jobs" ON public.jobs;
DROP POLICY IF EXISTS "Owners can delete own jobs" ON public.jobs;
DROP POLICY IF EXISTS "Authenticated citizens can insert jobs" ON public.jobs;
DROP POLICY IF EXISTS "Enable read access for all jobs" ON public.jobs;
DROP POLICY IF EXISTS "Enable insert access for all jobs" ON public.jobs;
DROP POLICY IF EXISTS "Enable update access for all jobs" ON public.jobs;
DROP POLICY IF EXISTS "Enable delete access for all jobs" ON public.jobs;

CREATE POLICY "Enable read access for all jobs" ON public.jobs FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all jobs" ON public.jobs FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all jobs" ON public.jobs FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Enable delete access for all jobs" ON public.jobs FOR DELETE USING (true);

-- 5. Marketplace
DROP POLICY IF EXISTS "Public can read approved marketplace" ON public.marketplace_items;
DROP POLICY IF EXISTS "Owners can update own marketplace" ON public.marketplace_items;
DROP POLICY IF EXISTS "Owners can delete own marketplace" ON public.marketplace_items;
DROP POLICY IF EXISTS "Authenticated citizens can insert marketplace" ON public.marketplace_items;
DROP POLICY IF EXISTS "Enable read access for all marketplace" ON public.marketplace_items;
DROP POLICY IF EXISTS "Enable insert access for all marketplace" ON public.marketplace_items;
DROP POLICY IF EXISTS "Enable update access for all marketplace" ON public.marketplace_items;
DROP POLICY IF EXISTS "Enable delete access for all marketplace" ON public.marketplace_items;

CREATE POLICY "Enable read access for all marketplace" ON public.marketplace_items FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all marketplace" ON public.marketplace_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all marketplace" ON public.marketplace_items FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Enable delete access for all marketplace" ON public.marketplace_items FOR DELETE USING (true);

-- 6. Notices
DROP POLICY IF EXISTS "Public can read published notices" ON public.notices;
DROP POLICY IF EXISTS "Moderators can manage notices" ON public.notices;
DROP POLICY IF EXISTS "Enable read access for all notices" ON public.notices;
DROP POLICY IF EXISTS "Enable insert access for all notices" ON public.notices;
DROP POLICY IF EXISTS "Enable update access for all notices" ON public.notices;
DROP POLICY IF EXISTS "Enable delete access for all notices" ON public.notices;

CREATE POLICY "Enable read access for all notices" ON public.notices FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all notices" ON public.notices FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all notices" ON public.notices FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Enable delete access for all notices" ON public.notices FOR DELETE USING (true);

-- 7. Emergency Contacts
DROP POLICY IF EXISTS "Public can read active emergency contacts" ON public.emergency_contacts;
DROP POLICY IF EXISTS "Admins can manage emergency contacts" ON public.emergency_contacts;
DROP POLICY IF EXISTS "Enable read access for all emergency contacts" ON public.emergency_contacts;
DROP POLICY IF EXISTS "Enable insert access for all emergency contacts" ON public.emergency_contacts;
DROP POLICY IF EXISTS "Enable update access for all emergency contacts" ON public.emergency_contacts;
DROP POLICY IF EXISTS "Enable delete access for all emergency contacts" ON public.emergency_contacts;

CREATE POLICY "Enable read access for all emergency contacts" ON public.emergency_contacts FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all emergency contacts" ON public.emergency_contacts FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all emergency contacts" ON public.emergency_contacts FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Enable delete access for all emergency contacts" ON public.emergency_contacts FOR DELETE USING (true);

-- 8. App Settings
DROP POLICY IF EXISTS "Public can read app settings" ON public.app_settings;
DROP POLICY IF EXISTS "Admins can manage app settings" ON public.app_settings;
DROP POLICY IF EXISTS "Enable read access for all app_settings" ON public.app_settings;
DROP POLICY IF EXISTS "Enable insert access for all app_settings" ON public.app_settings;
DROP POLICY IF EXISTS "Enable update access for all app_settings" ON public.app_settings;
DROP POLICY IF EXISTS "Enable delete access for all app_settings" ON public.app_settings;

CREATE POLICY "Enable read access for all app_settings" ON public.app_settings FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all app_settings" ON public.app_settings FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all app_settings" ON public.app_settings FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Enable delete access for all app_settings" ON public.app_settings FOR DELETE USING (true);
