import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://hmcfvzdtotmtjlufaszt.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhtY2Z2emR0b3RtdGpsdWZhc3p0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzNDExMDQsImV4cCI6MjA2MDkxNzEwNH0.IoVRrR8-Mc1ZaOCrgCXKgWf0vm0rMufPfl1sfwYzrOA';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
