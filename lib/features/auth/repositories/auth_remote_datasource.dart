import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/data/models/user_model.dart';
import '../../../../core/constants/enums.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phoneNumber);
  Future<UserModel> verifyOtp(String phoneNumber, String otp);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<UserModel> updateProfile(UserModel user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSourceImpl(this._supabase);

  @override
  Future<void> sendOtp(String phoneNumber) async {
    try {
      AppLogger.info('Sending OTP to: $phoneNumber');

      await _supabase.auth.signInWithOtp(
        phone: '+91$phoneNumber',
      );

      AppLogger.success('OTP sent successfully');
    } catch (e) {
      AppLogger.error('Error sending OTP', e);
      if (e.toString().contains('auth')) {
        throw AuthException('Failed to send OTP. Please try again.');
      }
      throw ServerException('Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> verifyOtp(String phoneNumber, String otp) async {
    try {
      AppLogger.info('Verifying OTP for: $phoneNumber');

      final response = await _supabase.auth.verifyOTP(
        phone: '+91$phoneNumber',
        token: otp,
        type: OtpType.sms,
      );

      if (response.user == null) {
        throw const AuthException('Verification failed');
      }

      AppLogger.success('OTP verified successfully');

      // Check if user exists in users table
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      UserModel user;

      if (userData == null) {
        // Create new user profile
        AppLogger.info('Creating new user profile');

        final newUser = {
          'id': response.user!.id,
          'phone_number': phoneNumber,
          'role': UserRole.customer.name,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('users').insert(newUser);

        user = UserModel.fromJson({
          ...newUser,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        user = UserModel.fromJson(userData);
      }

      return user;
    } catch (e) {
      AppLogger.error('Error verifying OTP', e);
      if (e is AuthException) rethrow;
      if (e.toString().contains('Invalid') || e.toString().contains('auth')) {
        throw const AuthException('Invalid OTP. Please try again.');
      }
      throw ServerException('Failed to verify OTP: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;

      if (session == null) {
        AppLogger.info('No active session');
        return null;
      }

      final userId = session.user.id;

      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(userData);
    } catch (e) {
      AppLogger.error('Error getting current user', e);
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      AppLogger.success('Logged out successfully');
    } catch (e) {
      AppLogger.error('Error logging out', e);
      throw ServerException('Failed to logout: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      AppLogger.info('Updating user profile');

      await _supabase
          .from('users')
          .update(user.toJson())
          .eq('id', user.id);

      AppLogger.success('Profile updated successfully');

      return user;
    } catch (e) {
      AppLogger.error('Error updating profile', e);
      throw ServerException('Failed to update profile: ${e.toString()}');
    }
  }
}
