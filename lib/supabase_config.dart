import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://uiublaevwngtqbklkjjz.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpdWJsYWV2d25ndHFia2xramp6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTc5MzY2MzAsImV4cCI6MjAzMzUxMjYzMH0.b8DR31fj8gAi54e3KxyrIT3kn7FmT90IZ4AZOBOYSmo';

  static void initialize() {
    Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}