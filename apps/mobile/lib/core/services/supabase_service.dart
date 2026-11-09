import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://zrnukpkufwrexrvysmpw.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpybnVrcGt1ZndyZXhydnlzbXB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQyMTk0MDgsImV4cCI6MjEwOTc5NTQwOH0.WBVjOQtaqr3tav2alG3HxaVO9HqUpAzLurI16KEv8mI';

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
    } catch (e) {
      // In offline / preview mode, proceed gracefully
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
