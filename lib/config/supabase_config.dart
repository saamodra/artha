import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // These will be loaded from .env file or environment variables
  static String get supabaseUrl {
    // Priority: .env file > compile-time constant > default
    final envUrl = dotenv.env['SUPABASE_URL'];
    final compileTimeUrl = const String.fromEnvironment('SUPABASE_URL');

    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    } else if (compileTimeUrl.isNotEmpty) {
      return compileTimeUrl;
    } else {
      if (kDebugMode) {
        print(
          '⚠️  Using default Supabase URL. Please configure SUPABASE_URL in .env file',
        );
      }
      return 'https://your-project.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    // Priority: .env file > compile-time constant > default
    final envKey = dotenv.env['SUPABASE_ANON_KEY'];
    final compileTimeKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    } else if (compileTimeKey.isNotEmpty) {
      return compileTimeKey;
    } else {
      if (kDebugMode) {
        print(
          '⚠️  Using default Supabase key. Please configure SUPABASE_ANON_KEY in .env file',
        );
      }
      return 'your-anon-key-here';
    }
  }

  // Helper method to validate configuration
  static bool get isConfigured {
    final url = supabaseUrl;
    final key = supabaseAnonKey;

    return url != 'https://your-project.supabase.co' &&
        key != 'your-anon-key-here' &&
        url.isNotEmpty &&
        key.isNotEmpty;
  }

  static void printConfigStatus() {
    if (kDebugMode) {
      print('🔧 Supabase Configuration Status:');
      print('   URL: ${supabaseUrl.substring(0, 30)}...');
      print('   Key: ${supabaseAnonKey.substring(0, 10)}...');
      print('   Configured: $isConfigured');
    }
  }
}
