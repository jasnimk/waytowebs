import 'package:flutter/foundation.dart';
import '../../../../shared/data/models/user_model.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/users_repository.dart';

class UsersController extends ChangeNotifier {
  final UsersRepository _repository;

  UsersController(this._repository);

  // State
  List<UserModel> _customers = [];
  List<UserModel> _dealers = [];
  List<UserModel> _plumbers = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserModel> get customers => _customers;
  List<UserModel> get dealers => _dealers;
  List<UserModel> get plumbers => _plumbers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch users by role
  Future<void> fetchUsersByRole(UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final users = await _repository.getUsersByRole(role);

      switch (role) {
        case UserRole.customer:
          _customers = users;
          break;
        case UserRole.dealer:
          _dealers = users;
          break;
        case UserRole.plumber:
          _plumbers = users;
          break;
        case UserRole.admin:
          // Admin users are not displayed in this screen
          break;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load users';
      _isLoading = false;
      AppLogger.error('Error in fetchUsersByRole', e);
      notifyListeners();
    }
  }

  // Update user
  Future<bool> updateUser(
    String userId,
    UserRole role, {
    String? fullName,
    String? phoneNumber,
    String? email,
    int? creditDays,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (email != null) updates['email'] = email;

      // Handle credit days for dealers
      if (role == UserRole.dealer && creditDays != null) {
        updates['credit_30_days_enabled'] = creditDays == 30;
        updates['credit_90_days_enabled'] = creditDays == 90;
      }

      await _repository.updateUser(userId, updates);

      // Refresh the users list
      await fetchUsersByRole(role);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user';
      AppLogger.error('Error in updateUser', e);
      notifyListeners();
      return false;
    }
  }

  // Toggle user status
  Future<bool> toggleUserStatus(String userId, UserRole role, bool isActive) async {
    try {
      await _repository.toggleUserStatus(userId, isActive);

      // Refresh the users list
      await fetchUsersByRole(role);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user status';
      AppLogger.error('Error in toggleUserStatus', e);
      notifyListeners();
      return false;
    }
  }

  // Create user
  Future<bool> createUser({
    required String phoneNumber,
    required UserRole role,
    String? fullName,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    int? creditDays,
  }) async {
    try {
      await _repository.createUser(
        phoneNumber: phoneNumber,
        role: role,
        fullName: fullName,
        email: email,
        address: address,
        city: city,
        state: state,
        pincode: pincode,
        credit30DaysEnabled: creditDays == 30,
        credit90DaysEnabled: creditDays == 90,
      );

      // Refresh the users list
      await fetchUsersByRole(role);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create user';
      AppLogger.error('Error in createUser', e);
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
