import { createClient } from '@supabase/supabase-js';

const supabaseUrl =
  import.meta.env.VITE_SUPABASE_URL || 'https://zrnukpkufwrexrvysmpw.supabase.co';
const supabaseAnonKey =
  import.meta.env.VITE_SUPABASE_ANON_KEY ||
  import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY ||
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpybnVrcGt1ZndyZXhydnlzbXB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQyMTk0MDgsImV4cCI6MjEwOTc5NTQwOH0.WBVjOQtaqr3tav2alG3HxaVO9HqUpAzLurI16KEv8mI';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

