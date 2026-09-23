{{#backend_is_supabase}}import 'package:supabase_flutter/supabase_flutter.dart';
class SupabaseClientHelper {
  static Future<void> init() async {
    await Supabase.initialize(url: 'https://api.example.com', anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'));
  }
  static SupabaseClient get client => Supabase.instance.client;
}{{/backend_is_supabase}}{{^backend_is_supabase}}// not supabase{{/backend_is_supabase}}