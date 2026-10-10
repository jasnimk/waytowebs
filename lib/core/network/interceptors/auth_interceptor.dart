import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/logger.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Get current session from Supabase
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // Add Bearer token to headers
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        AppLogger.info('Auth token added to request');
      }
    } catch (e) {
      AppLogger.error('Error adding auth token: $e');
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle unauthorized - maybe refresh token or logout
      AppLogger.warning('Unauthorized request - 401');
      // TODO: Implement token refresh logic if needed
    }

    super.onError(err, handler);
  }
}
