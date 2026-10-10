import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';
import '../utils/logger.dart';

class SupabaseConfig {
  static String get url => AppConfig.supabaseUrl;
  static String get anonKey => AppConfig.supabaseAnonKey;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );
      AppLogger.success('Supabase initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Supabase', e, stackTrace);
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
