-- Migration: 20261110160000_create_app_update_system.sql
-- Description: Centralized Android App Update and Force Update Configuration for Nardana Connect

-- 1. Create app_update_config table
CREATE TABLE IF NOT EXISTS public.app_update_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    platform TEXT NOT NULL UNIQUE DEFAULT 'android',
    latest_version TEXT NOT NULL DEFAULT '1.0.0',
    latest_build_number INTEGER NOT NULL DEFAULT 1,
    minimum_supported_version TEXT NOT NULL DEFAULT '1.0.0',
    minimum_supported_build INTEGER NOT NULL DEFAULT 1,
    force_update_enabled BOOLEAN NOT NULL DEFAULT false,
    optional_update_enabled BOOLEAN NOT NULL DEFAULT true,
    update_title_mr TEXT NOT NULL DEFAULT 'नवीन ॲप अपडेट उपलब्ध आहे!',
    update_title_en TEXT NOT NULL DEFAULT 'New App Update Available!',
    update_message_mr TEXT NOT NULL DEFAULT 'नरडाणा कनेक्ट ॲप अधिक वेगवान व सुरक्षित करण्यासाठी कृपया नवीन व्हर्जन इन्स्टॉल करा.',
    update_message_en TEXT NOT NULL DEFAULT 'Please update to the latest version of Nardana Connect for new features, speed and security enhancements.',
    release_notes_mr TEXT NOT NULL DEFAULT '• सर्व मॉड्यूल्ससाठी सविस्तर तपशील स्क्रीन\n• नवीन जाहिरात व्यवस्थापन प्रणाली\n• केवळ नरडाणा गाव कार्यक्षेत्र व वेगवान अनुभव',
    release_notes_en TEXT NOT NULL DEFAULT '• Full details screen on every module\n• Enhanced advertisement module\n• Exclusive Nardana scope and faster performance',
    play_store_url TEXT NOT NULL DEFAULT 'https://play.google.com/store/apps/details?id=in.nardana.connect.nardana_connect',
    apk_download_url TEXT NOT NULL DEFAULT 'https://github.com/siyainfotechsolar/nardana-connect/releases/download/v1.0.0/app-release.apk',
    maintenance_mode BOOLEAN NOT NULL DEFAULT false,
    maintenance_message_mr TEXT NOT NULL DEFAULT 'नरडाणा कनेक्ट ॲप सध्या नियोजित तांत्रिक देखभालीसाठी तात्पुरते बंद आहे. कृपया थोड्या वेळाने पुन्हा प्रयत्न करा.',
    maintenance_message_en TEXT NOT NULL DEFAULT 'Nardana Connect is currently undergoing scheduled maintenance. Please check back shortly.',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by TEXT NOT NULL DEFAULT 'admin'
);

-- 2. Create app_update_history audit table
CREATE TABLE IF NOT EXISTS public.app_update_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_id UUID REFERENCES public.app_update_config(id) ON DELETE SET NULL,
    platform TEXT NOT NULL DEFAULT 'android',
    latest_version TEXT NOT NULL,
    latest_build_number INTEGER NOT NULL,
    minimum_supported_version TEXT NOT NULL,
    minimum_supported_build INTEGER NOT NULL,
    force_update_enabled BOOLEAN NOT NULL,
    optional_update_enabled BOOLEAN NOT NULL,
    maintenance_mode BOOLEAN NOT NULL,
    change_summary TEXT,
    updated_by TEXT NOT NULL DEFAULT 'admin',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Indexes for high performance
CREATE INDEX IF NOT EXISTS idx_app_update_config_platform ON public.app_update_config(platform);
CREATE INDEX IF NOT EXISTS idx_app_update_history_created_at ON public.app_update_history(created_at DESC);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.app_update_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_update_history ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for app_update_config
-- Public / Anon / Authenticated mobile users can read published update config
CREATE POLICY "Allow public read app_update_config"
    ON public.app_update_config
    FOR SELECT
    USING (true);

-- Admin and portal can update settings
CREATE POLICY "Allow portal update app_update_config"
    ON public.app_update_config
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow portal insert app_update_config"
    ON public.app_update_config
    FOR INSERT
    WITH CHECK (true);

-- 6. RLS Policies for app_update_history
CREATE POLICY "Allow portal read app_update_history"
    ON public.app_update_history
    FOR SELECT
    USING (true);

CREATE POLICY "Allow portal insert app_update_history"
    ON public.app_update_history
    FOR INSERT
    WITH CHECK (true);

-- 7. Add to Realtime publication
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
        AND schemaname = 'public' 
        AND tablename = 'app_update_config'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.app_update_config;
    END IF;
END $$;

-- 8. Seed Default Android Configuration
INSERT INTO public.app_update_config (
    platform,
    latest_version,
    latest_build_number,
    minimum_supported_version,
    minimum_supported_build,
    force_update_enabled,
    optional_update_enabled,
    update_title_mr,
    update_title_en,
    update_message_mr,
    update_message_en,
    release_notes_mr,
    release_notes_en,
    play_store_url,
    apk_download_url,
    maintenance_mode,
    maintenance_message_mr,
    maintenance_message_en,
    updated_at,
    updated_by
) VALUES (
    'android',
    '1.0.0',
    1,
    '1.0.0',
    1,
    false,
    true,
    'नवीन ॲप अपडेट उपलब्ध आहे!',
    'New App Update Available!',
    'नरडाणा कनेक्ट ॲप अधिक वेगवान व सुरक्षित करण्यासाठी कृपया नवीन व्हर्जन इन्स्टॉल करा.',
    'Please update to the latest version of Nardana Connect for new features, speed and security enhancements.',
    '• सर्व मॉड्यूल्ससाठी सविस्तर तपशील स्क्रीन\n• नवीन जाहिरात व्यवस्थापन प्रणाली\n• केवळ नरडाणा गाव कार्यक्षेत्र व वेगवान अनुभव',
    '• Full details screen on every module\n• Enhanced advertisement module\n• Exclusive Nardana scope and faster performance',
    'https://play.google.com/store/apps/details?id=in.nardana.connect.nardana_connect',
    'https://github.com/siyainfotechsolar/nardana-connect/releases/download/v1.0.0/app-release.apk',
    false,
    'नरडाणा कनेक्ट ॲप सध्या नियोजित तांत्रिक देखभालीसाठी तात्पुरते बंद आहे. कृपया थोड्या वेळाने पुन्हा प्रयत्न करा.',
    'Nardana Connect is currently undergoing scheduled maintenance. Please check back shortly.',
    now(),
    'Super Admin'
)
ON CONFLICT (platform) DO UPDATE SET
    latest_version = EXCLUDED.latest_version,
    latest_build_number = EXCLUDED.latest_build_number,
    minimum_supported_version = EXCLUDED.minimum_supported_version,
    minimum_supported_build = EXCLUDED.minimum_supported_build,
    updated_at = now();

-- Initial history record
INSERT INTO public.app_update_history (
    config_id,
    platform,
    latest_version,
    latest_build_number,
    minimum_supported_version,
    minimum_supported_build,
    force_update_enabled,
    optional_update_enabled,
    maintenance_mode,
    change_summary,
    updated_by
)
SELECT 
    id,
    platform,
    latest_version,
    latest_build_number,
    minimum_supported_version,
    minimum_supported_build,
    force_update_enabled,
    optional_update_enabled,
    maintenance_mode,
    'सिस्टीम आरंभिक ॲप व्हर्जन व अपडेट धोरण संरचना (Initial Setup)',
    'Super Admin'
FROM public.app_update_config
WHERE platform = 'android';

