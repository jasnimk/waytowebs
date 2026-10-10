import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/data/models/user_model.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/constants/enums.dart';

class UsersRepository {
  final SupabaseClient _supabase;

  UsersRepository(this._supabase);

  /// Fetch users by role
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      AppLogger.info('Fetching users with role: ${role.name}');

      final response = await _supabase
          .from('users')
          .select()
          .eq('role', role.name)
          .order('created_at', ascending: false);

      AppLogger.info('Raw response: $response');

      final users = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${users.length} users with role ${role.name}');
      return users;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching users by role', e, stackTrace);
      rethrow;
    }
  }

  /// Update user details
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      AppLogger.info('Updating user $userId with data: $updates');

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId);

      AppLogger.success('Updated user $userId successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating user', e, stackTrace);
      rethrow;
    }
  }

  /// Toggle user active status
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      AppLogger.info('Setting user $userId active status to $isActive');

      await _supabase
          .from('users')
          .update({'is_active': isActive})
          .eq('id', userId);

      AppLogger.success('Updated user $userId status to $isActive');
    } catch (e, stackTrace) {
      AppLogger.error('Error toggling user status', e, stackTrace);
      rethrow;
    }
  }

  /// Search users by name or phone across all roles
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      AppLogger.info('Searching users with query: $query');

      final response = await _supabase
          .from('users')
          .select()
          .or('full_name.ilike.%$query%,phone_number.ilike.%$query%')
          .order('created_at', ascending: false);

      final users = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      AppLogger.success('Found ${users.length} users matching "$query"');
      return users;
    } catch (e, stackTrace) {
      AppLogger.error('Error searching users', e, stackTrace);
      rethrow;
    }
  }

  /// Create new user
  Future<UserModel> createUser({
    required String phoneNumber,
    required UserRole role,
    String? fullName,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    bool credit30DaysEnabled = false,
    bool credit90DaysEnabled = false,
  }) async {
    try {
      AppLogger.info('Creating new user with phone: $phoneNumber, role: ${role.name}');

      final userData = {
        'phone_number': phoneNumber,
        'role': role.name,
        'full_name': fullName,
        'email': email,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'is_active': true,
        'credit_30_days_enabled': credit30DaysEnabled,
        'credit_90_days_enabled': credit90DaysEnabled,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('users')
          .insert(userData)
          .select()
          .single();

      final user = UserModel.fromJson(response);
      AppLogger.success('Created user ${user.id} successfully');
      return user;
    } catch (e, stackTrace) {
      AppLogger.error('Error creating user', e, stackTrace);
      rethrow;
    }
  }
}
