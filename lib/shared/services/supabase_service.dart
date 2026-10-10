import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  // Auth
  GoTrueClient get auth => _client.auth;

  // Database
  SupabaseClient get database => _client;

  // Storage
  SupabaseStorageClient get storage => _client.storage;

  // Realtime
  RealtimeClient get realtime => _client.realtime;

  // Get current user
  User? get currentUser => auth.currentUser;

  // Get current session
  Session? get currentSession => auth.currentSession;

  // Check if user is authenticated
  bool get isAuthenticated => currentSession != null;

  // Sign out
  Future<void> signOut() async {
    try {
      await auth.signOut();
      AppLogger.info('User signed out successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error signing out', e, stackTrace);
      rethrow;
    }
  }

  // Upload file to storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    try {
      await storage.from(bucket).upload(path, file);
      final url = storage.from(bucket).getPublicUrl(path);
      AppLogger.success('File uploaded: $url');
      return url;
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading file', e, stackTrace);
      rethrow;
    }
  }

  // Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await storage.from(bucket).remove([path]);
      AppLogger.info('File deleted from storage');
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting file', e, stackTrace);
      rethrow;
    }
  }

  // Execute RPC (Remote Procedure Call)
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) async {
    try {
      final response = await _client.rpc(functionName, params: params);
      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Error executing RPC: $functionName', e, stackTrace);
      rethrow;
    }
  }
}
