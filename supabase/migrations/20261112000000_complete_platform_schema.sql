-- ====================================================================
-- NARDANA CONNECT: Comprehensive Platform Expansion Schema
-- Coverage: EXCLUSIVELY Nardana Village (PIN: 425404)
-- ====================================================================

-- 1. BUSINESS PHOTOS TABLE
CREATE TABLE IF NOT EXISTS public.business_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES public.businesses(id) ON DELETE CASCADE,
    photo_url TEXT NOT NULL,
    caption TEXT,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_business_photos_biz ON public.business_photos(business_id);

-- 2. SERVICES TABLE (Dedicated services catalog)
CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    village_id UUID REFERENCES public.villages(id) ON DELETE SET NULL,
    name_mr TEXT NOT NULL,
    name_en TEXT,
    provider_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    whatsapp TEXT,
    address TEXT NOT NULL,
    description TEXT,
    opening_hours TEXT DEFAULT 'सकाळी ८:०० ते संध्याकाळी ८:००',
    status TEXT DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_services_status ON public.services(status);
CREATE INDEX IF NOT EXISTS idx_services_cat ON public.services(category_id);

-- 3. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title_mr TEXT NOT NULL,
    title_en TEXT,
    body_mr TEXT NOT NULL,
    body_en TEXT,
    type TEXT DEFAULT 'announcement' CHECK (type IN ('announcement', 'water', 'electricity', 'ad', 'general')),
    target_url TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(is_read);

-- 4. APP FEATURES & FEATURE FLAGS TABLE
CREATE TABLE IF NOT EXISTS public.app_features (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_key TEXT UNIQUE NOT NULL,
    name_mr TEXT NOT NULL,
    name_en TEXT NOT NULL,
    is_enabled BOOLEAN DEFAULT true NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 5. HOME SECTIONS (Admin Controlled Order & Visibility)
CREATE TABLE IF NOT EXISTS public.home_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_key TEXT UNIQUE NOT NULL,
    title_mr TEXT NOT NULL,
    title_en TEXT NOT NULL,
    sort_order INT NOT NULL,
    is_visible BOOLEAN DEFAULT true NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 6. HOME BANNERS TABLE
CREATE TABLE IF NOT EXISTS public.home_banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title_mr TEXT NOT NULL,
    title_en TEXT,
    image_url TEXT NOT NULL,
    target_type TEXT DEFAULT 'internal' CHECK (target_type IN ('internal', 'external', 'notice', 'ad')),
    target_route TEXT DEFAULT '/explore',
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 7. ELECTION TABLES (Gram Panchayat Nardana)
CREATE TABLE IF NOT EXISTS public.elections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    village_id UUID REFERENCES public.villages(id) ON DELETE SET NULL,
    title_mr TEXT NOT NULL DEFAULT 'नरडाणा ग्रामपंचायत सार्वत्रिक निवडणूक',
    title_en TEXT DEFAULT 'Nardana Gram Panchayat General Election',
    election_date DATE,
    code_of_conduct_active BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.election_wards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID REFERENCES public.elections(id) ON DELETE CASCADE,
    ward_number INT NOT NULL,
    ward_name_mr TEXT NOT NULL,
    ward_name_en TEXT,
    total_voters INT DEFAULT 0,
    reserved_category TEXT DEFAULT 'खुला (General)',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.election_candidates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID REFERENCES public.elections(id) ON DELETE CASCADE,
    ward_id UUID REFERENCES public.election_wards(id) ON DELETE CASCADE,
    candidate_name_mr TEXT NOT NULL,
    candidate_name_en TEXT,
    symbol_name_mr TEXT NOT NULL,
    symbol_icon_url TEXT,
    age INT,
    education_mr TEXT,
    phone TEXT,
    manifesto_summary_mr TEXT,
    nomination_status TEXT DEFAULT 'approved' CHECK (nomination_status IN ('pending', 'approved', 'rejected', 'withdrawn')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.candidate_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    candidate_id UUID REFERENCES public.election_candidates(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL,
    document_url TEXT NOT NULL,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.election_schedule (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID REFERENCES public.elections(id) ON DELETE CASCADE,
    event_title_mr TEXT NOT NULL,
    event_title_en TEXT,
    event_date DATE NOT NULL,
    event_time TEXT,
    description_mr TEXT,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.polling_stations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID REFERENCES public.elections(id) ON DELETE CASCADE,
    ward_id UUID REFERENCES public.election_wards(id) ON DELETE SET NULL,
    station_number INT NOT NULL,
    building_name_mr TEXT NOT NULL,
    address_mr TEXT NOT NULL,
    total_registered_voters INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.election_notices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    election_id UUID REFERENCES public.elections(id) ON DELETE CASCADE,
    notice_title_mr TEXT NOT NULL,
    notice_date DATE DEFAULT CURRENT_DATE,
    pdf_url TEXT,
    authority_mr TEXT DEFAULT 'निवडणूक निर्णय अधिकारी, नरडाणा',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 8. ELECTION ADVERTISEMENT & COMPLIANCE TABLES
-- Note: Political ads are disabled until legal clearances are verified.
CREATE TABLE IF NOT EXISTS public.election_advertisement_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_mr TEXT NOT NULL,
    duration_days INT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    description_mr TEXT,
    is_active BOOLEAN DEFAULT false -- Default disabled until legal clearance
);

CREATE TABLE IF NOT EXISTS public.election_ad_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    candidate_id UUID REFERENCES public.election_candidates(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES public.election_advertisement_plans(id) ON DELETE SET NULL,
    applicant_name TEXT NOT NULL,
    applicant_phone TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'under_legal_review', 'approved', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.election_ad_creatives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID REFERENCES public.election_ad_applications(id) ON DELETE CASCADE,
    creative_url TEXT NOT NULL,
    status TEXT DEFAULT 'pending_review' CHECK (status IN ('pending_review', 'approved', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.election_ad_legal_clearances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID REFERENCES public.election_ad_applications(id) ON DELETE CASCADE,
    clearance_certificate_url TEXT,
    verified_by UUID REFERENCES auth.users(id),
    verification_status TEXT DEFAULT 'unverified' CHECK (verification_status IN ('unverified', 'verified', 'rejected')),
    verification_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.election_ad_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID REFERENCES public.election_ad_applications(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'refunded', 'failed')),
    transaction_reference TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.election_ad_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID REFERENCES public.election_ad_applications(id) ON DELETE CASCADE,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    is_live BOOLEAN DEFAULT false,
    impressions_count INT DEFAULT 0,
    clicks_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================

ALTER TABLE public.business_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.home_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.home_banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.elections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_wards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.candidate_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.polling_stations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_advertisement_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_ad_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_ad_creatives ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_ad_legal_clearances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_ad_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.election_ad_campaigns ENABLE ROW LEVEL SECURITY;

-- Public Read Policies
DO $$ BEGIN
    CREATE POLICY "Public read business_photos" ON public.business_photos FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Public read approved services" ON public.services FOR SELECT USING (status = 'approved');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Public read app_features" ON public.app_features FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Public read home_sections" ON public.home_sections FOR SELECT USING (is_visible = true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Public read home_banners" ON public.home_banners FOR SELECT USING (is_active = true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Public read elections" ON public.elections FOR SELECT USING (is_active = true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Public read election_wards" ON public.election_wards FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Public read election_candidates" ON public.election_candidates FOR SELECT USING (nomination_status = 'approved');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Public read election_schedule" ON public.election_schedule FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Public read polling_stations" ON public.polling_stations FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Public read election_notices" ON public.election_notices FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- Admin Full Access Policies
DO $$ BEGIN
    CREATE POLICY "Admin manage services" ON public.services FOR ALL USING (true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Admin manage home_sections" ON public.home_sections FOR ALL USING (true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Admin manage home_banners" ON public.home_banners FOR ALL USING (true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE POLICY "Admin manage election_candidates" ON public.election_candidates FOR ALL USING (true);
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- User specific notification access
DO $$ BEGIN
    CREATE POLICY "User read own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- ====================================================================
-- SEED DEFAULT RECORDS FOR NARDANA
-- ====================================================================

-- 1. Default Home Sections
INSERT INTO public.home_sections (section_key, title_mr, title_en, sort_order, is_visible)
VALUES
    ('main_banner', 'मुख्य बॅनर', 'Main Banner', 1, true),
    ('quick_services', 'त्वरित सेवा', 'Quick Services', 2, true),
    ('popular_categories', 'लोकप्रिय कॅटेगरी', 'Popular Categories', 3, true),
    ('local_shops', 'स्थानिक दुकाने व सेवा', 'Local Shops & Services', 4, true),
    ('village_notices', 'ग्रामपंचायत सूचना', 'Village Notices', 5, true),
    ('jobs', 'रोजगार व काम', 'Jobs & Opportunities', 6, true),
    ('marketplace', 'खरेदी - विक्री', 'Buy & Sell', 7, true),
    ('emergency', 'तातडीचे क्रमांक', 'Emergency Helplines', 8, true),
    ('advertisements', 'प्रायोजित जाहिराती', 'Sponsored Ads', 9, true),
    ('election', 'ग्रामपंचायत निवडणूक', 'Election Portal', 10, true)
ON CONFLICT (section_key) DO UPDATE
SET title_mr = EXCLUDED.title_mr, is_visible = EXCLUDED.is_visible;

-- 2. Default Feature Flags
INSERT INTO public.app_features (feature_key, name_mr, name_en, is_enabled, description)
VALUES
    ('guest_login', 'पाहुणा प्रवेश', 'Guest Login', true, 'नागरिकांना विना लॉगिन ॲप पाहण्याची परवानगी'),
    ('google_auth', 'गुगल लॉगिन', 'Google Sign-In', true, '१-क्लिक गुगल ऑथेंटिकेशन'),
    ('email_auth', 'ईमेल लॉगिन', 'Email & Password', true, 'पारंपारिक ईमेल व पासवर्ड नोंदणी'),
    ('citizen_posting', 'नागरिक पोस्टिंग', 'Citizen Post Listings', true, 'नागरिकांना खरेदी-विक्री व व्यवसाय नोंदणी सादर करण्याची मुभा'),
    ('election_portal', 'निवडणूक पोर्टल', 'Election Information Portal', true, 'ग्रामपंचायत निवडणूक उमेदवार निर्देशिका'),
    ('push_notifications', 'पुश नोटिफिकेशन्स', 'Push Notifications', true, 'महत्वाच्या गाव सूचनांचे त्वरित संदेश'),
    ('political_ads', 'राजकीय जाहिराती', 'Political Advertisements', false, 'कायदेशीर मंजुरी मिळेपर्यंत राजकीय जाहिरात बंद')
ON CONFLICT (feature_key) DO NOTHING;

-- 3. Default Election Record
INSERT INTO public.elections (id, title_mr, title_en, election_date, code_of_conduct_active, is_active)
VALUES
    ('e0000000-0000-0000-0000-000000000001', 'नरडाणा ग्रामपंचायत सार्वत्रिक निवडणूक २०२६', 'Nardana Gram Panchayat General Election 2026', '2026-12-15', true, true)
ON CONFLICT (id) DO NOTHING;

-- 4. Default Wards for Nardana
INSERT INTO public.election_wards (id, election_id, ward_number, ward_name_mr, ward_name_en, total_voters, reserved_category)
VALUES
    ('w0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 1, 'प्रभाग क्र. १ (स्टेशन परिसर व जुने गाव)', 'Ward 1 - Station Area', 1250, 'खुला (General)'),
    ('w0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 2, 'प्रभाग क्र. २ (मेन बाजारपेठ व कुंभार गल्ली)', 'Ward 2 - Main Bazar', 1420, 'नागरिकांचा मागास प्रवर्ग (OBC)'),
    ('w0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000001', 3, 'प्रभाग क्र. ३ (हायवे परिसर व नवीन वसाहत)', 'Ward 3 - Highway Area', 1180, 'महिला (खुला - Women)'),
    ('w0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000001', 4, 'प्रभाग क्र. ४ (पाटील गल्ली व माळी गल्ली)', 'Ward 4 - Patil Galli', 1310, 'अनुसूचित जमाती (ST)'),
    ('w0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000001', 5, 'प्रभाग क्र. ५ (ग्रामपंचायत चौक व शाळा परिसर)', 'Ward 5 - Gram Panchayat Chowk', 1290, 'महिला (मागास प्रवर्ग)')
ON CONFLICT (id) DO NOTHING;

-- 5. Default Candidates for Nardana (Equal presentation, strictly no ranking)
INSERT INTO public.election_candidates (id, election_id, ward_id, candidate_name_mr, candidate_name_en, symbol_name_mr, age, education_mr, phone, manifesto_summary_mr, nomination_status, is_active)
VALUES
    ('c0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'w0000000-0000-0000-0000-000000000001', 'दिलीप आनंदा पाटील', 'Dilip Ananda Patil', 'कमळ / चिन्ह अ', 46, 'बी.ए. (B.A.)', '9822011223', 'नरडाणा गावातील पाणी पुरवठा योजना नियमित करणे व नवीन सिमेंट रस्ते बांधणे.', 'approved', true),
    ('c0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', 'w0000000-0000-0000-0000-000000000002', 'अनिता सुनील चौधरी', 'Anita Sunil Chaudhari', 'शिट्टी / चिन्ह ब', 38, '१२ वी उत्तीर्ण (HSC)', '9421556677', 'महिला बचत गटांना बळकटी देणे आणि प्राथमिक आरोग्य केंद्रात २४ तास रुग्णवाहिका सेवा सुरू करणे.', 'approved', true),
    ('c0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000001', 'w0000000-0000-0000-0000-000000000003', 'सुरेश काशिनाथ माळी', 'Suresh Kashinath Mali', 'विमान / चिन्ह क', 52, 'डी.एड. (D.Ed.)', '9890887766', 'गावातील सांडपाणी व्यवस्थापन, कचरा व्यवस्थापन व शेतकरी सेवा केंद्र सक्षम करणे.', 'approved', true)
ON CONFLICT (id) DO NOTHING;

