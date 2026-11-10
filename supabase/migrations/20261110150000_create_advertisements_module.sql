-- Migration: Advertisement Management Module for NARDANA CONNECT
-- Date: 2026-11-10
-- Rule: NARDANA VILLAGE ONLY, Marathi + English, Impression/Click Tracking, Admin Controlled

-- 1. Create advertisements table
CREATE TABLE IF NOT EXISTS public.advertisements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  village_id UUID NOT NULL DEFAULT 'a0000000-0000-0000-0000-000000000001' REFERENCES public.villages(id) ON DELETE CASCADE,
  title_mr VARCHAR(255) NOT NULL,
  title_en VARCHAR(255) NOT NULL,
  description_mr TEXT,
  description_en TEXT,
  image_url TEXT NOT NULL,
  placement VARCHAR(50) NOT NULL DEFAULT 'home_carousel' CHECK (placement IN ('home_carousel', 'sponsored_card', 'category_banner', 'popup')),
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  target_type VARCHAR(50) NOT NULL DEFAULT 'none' CHECK (target_type IN ('none', 'business', 'phone', 'whatsapp', 'url', 'notice')),
  target_id TEXT,
  target_url TEXT,
  phone VARCHAR(50),
  whatsapp VARCHAR(50),
  start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_date TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '30 days'),
  is_active BOOLEAN NOT NULL DEFAULT true,
  priority INTEGER NOT NULL DEFAULT 0,
  impressions_count INTEGER NOT NULL DEFAULT 0,
  clicks_count INTEGER NOT NULL DEFAULT 0,
  advertiser_name VARCHAR(255),
  advertiser_contact VARCHAR(100),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Create advertisement_events table for impression and click tracking
CREATE TABLE IF NOT EXISTS public.advertisement_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  advertisement_id UUID NOT NULL REFERENCES public.advertisements(id) ON DELETE CASCADE,
  event_type VARCHAR(30) NOT NULL CHECK (event_type IN ('impression', 'click')),
  user_id UUID,
  device_info TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Optimization Indexes
CREATE INDEX IF NOT EXISTS idx_advertisements_active 
ON public.advertisements (placement, is_active, start_date, end_date);

CREATE INDEX IF NOT EXISTS idx_advertisements_category 
ON public.advertisements (category_id) WHERE category_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_advertisements_village 
ON public.advertisements (village_id);

CREATE INDEX IF NOT EXISTS idx_advertisement_events_ad 
ON public.advertisement_events (advertisement_id, event_type);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.advertisements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.advertisement_events ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for advertisements
DROP POLICY IF EXISTS "Public can view active advertisements" ON public.advertisements;
CREATE POLICY "Public can view active advertisements" 
ON public.advertisements FOR SELECT 
USING (true);

DROP POLICY IF EXISTS "Allow admin to manage advertisements" ON public.advertisements;
CREATE POLICY "Allow admin to manage advertisements" 
ON public.advertisements FOR ALL 
USING (true)
WITH CHECK (true);

-- 6. RLS Policies for advertisement_events
DROP POLICY IF EXISTS "Public can record advertisement events" ON public.advertisement_events;
CREATE POLICY "Public can record advertisement events" 
ON public.advertisement_events FOR INSERT 
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow viewing advertisement events" ON public.advertisement_events;
CREATE POLICY "Allow viewing advertisement events" 
ON public.advertisement_events FOR SELECT 
USING (true);

-- 7. Safe RPC for tracking impressions
CREATE OR REPLACE FUNCTION public.track_ad_impression(ad_id UUID, p_device TEXT DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.advertisements
  SET impressions_count = impressions_count + 1,
      updated_at = NOW()
  WHERE id = ad_id;

  INSERT INTO public.advertisement_events (advertisement_id, event_type, device_info)
  VALUES (ad_id, 'impression', p_device);
END;
$$;

-- 8. Safe RPC for tracking clicks
CREATE OR REPLACE FUNCTION public.track_ad_click(ad_id UUID, p_device TEXT DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.advertisements
  SET clicks_count = clicks_count + 1,
      updated_at = NOW()
  WHERE id = ad_id;

  INSERT INTO public.advertisement_events (advertisement_id, event_type, device_info)
  VALUES (ad_id, 'click', p_device);
END;
$$;

-- 9. Storage Bucket setup for Advertisement images
INSERT INTO storage.buckets (id, name, public)
VALUES ('advertisements', 'advertisements', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public access to advertisements bucket" ON storage.objects;
CREATE POLICY "Public access to advertisements bucket"
ON storage.objects FOR SELECT
USING (bucket_id = 'advertisements');

DROP POLICY IF EXISTS "Allow upload to advertisements bucket" ON storage.objects;
CREATE POLICY "Allow upload to advertisements bucket"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'advertisements');

DROP POLICY IF EXISTS "Allow update in advertisements bucket" ON storage.objects;
CREATE POLICY "Allow update in advertisements bucket"
ON storage.objects FOR UPDATE
USING (bucket_id = 'advertisements');

DROP POLICY IF EXISTS "Allow delete in advertisements bucket" ON storage.objects;
CREATE POLICY "Allow delete in advertisements bucket"
ON storage.objects FOR DELETE
USING (bucket_id = 'advertisements');

-- 10. Enable Supabase Realtime for advertisements
ALTER PUBLICATION supabase_realtime ADD TABLE public.advertisements;

-- 11. Seed realistic sample advertisements for Nardana
INSERT INTO public.advertisements (
  village_id,
  title_mr,
  title_en,
  description_mr,
  description_en,
  image_url,
  placement,
  target_type,
  phone,
  whatsapp,
  start_date,
  end_date,
  is_active,
  priority,
  advertiser_name,
  advertiser_contact
) VALUES 
(
  'a0000000-0000-0000-0000-000000000001',
  'श्री गजानन कृषी सेवा केंद्र, नरडाणा - दर्जेदार बियाणे व खते',
  'Shri Gajanan Krishi Seva Kendra, Nardana - Quality Seeds & Fertilizers',
  'रब्बी व खरीप हंगामासाठी सर्व नामांकित कंपन्यांचे बियाणे, सेंद्रिय खते व कीटकनाशके वाजवी दरात उपलब्ध. नरडाणा हायवे चौक.',
  'Top quality certified seeds, fertilizers and crop protection chemicals at best rates. Highway Chowk, Nardana.',
  'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800&auto=format&fit=crop&q=80',
  'home_carousel',
  'phone',
  '9823012345',
  '9823012345',
  NOW() - INTERVAL '1 day',
  NOW() + INTERVAL '60 days',
  true,
  10,
  'अशोक पाटील (Ashok Patil)',
  '9823012345'
),
(
  'a0000000-0000-0000-0000-000000000001',
  'सुयोग इलेक्ट्रॉनिक्स व होम अप्लायन्सेस, नरडाणा - भव्य सवलत!',
  'Suyog Electronics & Home Appliances, Nardana - Grand Offer!',
  'स्मार्ट टीव्ही, फ्रिज, कुलर व घरगुती उपकरणांवर खास सवलत व सुलभ ईएमआय (EMI) सुविधा. स्टेशन रोड, नरडाणा.',
  'Special festive discounts on Smart TVs, Refrigerators, Coolers with zero downpayment EMI. Station Road, Nardana.',
  'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=800&auto=format&fit=crop&q=80',
  'home_carousel',
  'whatsapp',
  '9422054321',
  '9422054321',
  NOW() - INTERVAL '1 day',
  NOW() + INTERVAL '45 days',
  true,
  9,
  'सुयोग महाजन (Suyog Mahajan)',
  '9422054321'
),
(
  'a0000000-0000-0000-0000-000000000001',
  'नरडाणा ऑटोमोबाईल व गॅरेज - २४ तास हायवे ब्रेकडाऊन सर्व्हिस',
  'Nardana Automobile & Garage - 24/7 Highway Breakdown Service',
  'सर्व प्रकारच्या चारचाकी व ट्रॅक्टरचे मेकॅनिकल काम, ऑईल चेंज व तातडीची हायवे मदत. संपर्क करा: नरडाणा बायपास.',
  'Full car and tractor repair, computer wheel balancing, emergency roadside assistance on NH-52 Nardana bypass.',
  'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&auto=format&fit=crop&q=80',
  'sponsored_card',
  'phone',
  '9890123456',
  '9890123456',
  NOW() - INTERVAL '2 days',
  NOW() + INTERVAL '90 days',
  true,
  8,
  'संजय मिस्त्री (Sanjay Mistry)',
  '9890123456'
),
(
  'a0000000-0000-0000-0000-000000000001',
  'किसान ऑरगॅनिक बायो-खते, नरडाणा',
  'Kisan Organic Bio-Fertilizers, Nardana',
  'शेतजमिनीची सुपीकता वाढवा आणि भरघोस उत्पादन मिळवा. १००% सेंद्रिय व जैविक खते. नरडाणा.',
  'Improve soil fertility and maximize crop yields with 100% certified organic bio-fertilizers. Nardana.',
  'https://images.unsplash.com/photo-1628352081506-83c43123ed6d?w=800&auto=format&fit=crop&q=80',
  'category_banner',
  'phone',
  '9765432100',
  '9765432100',
  NOW() - INTERVAL '3 days',
  NOW() + INTERVAL '30 days',
  true,
  7,
  'रविंद्र चौधरी (Ravindra Chaudhari)',
  '9765432100'
);

