import 'package:flutter/foundation.dart';
import '../../../shared/domain/entities/user_entity.dart';
import '../../../core/constants/enums.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../services/zoho/zoho_service.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final ZohoService _zohoService = ZohoService();

  AuthProvider(this._repository);

  // State
  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _errorMessage;
  String? _phoneNumber;
  bool _otpSent = false;

  // Getters
  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get phoneNumber => _phoneNumber;
  bool get otpSent => _otpSent;

  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isCustomer => _currentUser?.role == UserRole.customer;
  bool get isDealer => _currentUser?.role == UserRole.dealer;
  bool get isPlumber => _currentUser?.role == UserRole.plumber;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  // Initialize - Check if user is already logged in
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing auth provider');

      final result = await _repository.getCurrentUser();

      result.fold(
        (failure) {
          _status = AuthStatus.unauthenticated;
          AppLogger.warning('No authenticated user found');
        },
        (user) {
          if (user != null) {
            _currentUser = user;
            _status = AuthStatus.authenticated;
            AppLogger.success('User authenticated: ${user.phoneNumber}');
          } else {
            _status = AuthStatus.unauthenticated;
          }
        },
      );

      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing auth', e, stackTrace);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Send OTP
  Future<bool> sendOtp(String phoneNumber) async {
    // Don't set loading state or notify listeners - let UI handle it locally
    _errorMessage = null;

    AppLogger.info('Sending OTP to: $phoneNumber');

    final result = await _repository.sendOtp(phoneNumber);

    return result.fold(
      (failure) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = _mapFailureToMessage(failure);
        AppLogger.error('Failed to send OTP: $_errorMessage');
        // Don't notify listeners to prevent widget unmounting
        return false;
      },
      (success) {
        _phoneNumber = phoneNumber;
        _otpSent = true;
        _status = AuthStatus.unauthenticated;
        AppLogger.success('OTP sent successfully');
        // DON'T notify listeners here - it causes widget to unmount before navigation
        return true;
      },
    );
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (_phoneNumber == null) {
      _errorMessage = 'Phone number not found';
      notifyListeners();
      return false;
    }

    // Don't notify listeners during loading - let UI handle it locally
    _status = AuthStatus.loading;
    _errorMessage = null;

    AppLogger.info('Verifying OTP');

    final result = await _repository.verifyOtp(_phoneNumber!, otp);

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = _mapFailureToMessage(failure);
        AppLogger.error('Failed to verify OTP: $_errorMessage');
        notifyListeners();
        return false;
      },
      (user) async {
        // If user is a dealer, verify with Zoho CRM
        if (user.role == UserRole.dealer) {
          AppLogger.info('Dealer login detected, verifying with Zoho CRM');

          final dealerData = await _zohoService.verifyDealer(_phoneNumber!);

          if (dealerData == null) {
            _status = AuthStatus.error;
            _errorMessage = 'Your dealer account is not verified in our system. Please contact support at support@waytowebs.com for assistance.';
            AppLogger.error('Dealer verification failed: Not found or not verified in Zoho CRM');

            // Logout the user since verification failed
            await _repository.logout();

            // Notify UI AFTER logout so the error can be shown on the OTP screen
            notifyListeners();
            return false;
          }

          // Update user with Zoho credit settings
          AppLogger.info('Dealer verified, updating credit settings from Zoho');
          final updatedUser = user.copyWith(
            credit30DaysEnabled: dealerData['credit_30_enabled'] as bool,
            credit90DaysEnabled: dealerData['credit_90_enabled'] as bool,
          );

          // Update in database
          final updateResult = await _repository.updateProfile(updatedUser);

          return updateResult.fold(
            (failure) {
              _status = AuthStatus.error;
              _errorMessage = 'Failed to sync dealer settings';
              AppLogger.error('Failed to update dealer settings');
              notifyListeners();
              return false;
            },
            (finalUser) {
              _currentUser = finalUser;
              _status = AuthStatus.authenticated;
              _otpSent = false;
              AppLogger.success('Dealer authenticated and synced with Zoho');
              notifyListeners();
              return true;
            },
          );
        }

        // Non-dealer users proceed normally
        _currentUser = user;
        _status = AuthStatus.authenticated;
        _otpSent = false;
        AppLogger.success('OTP verified, user authenticated');
        notifyListeners();
        return true;
      },
    );
  }

  // Logout
  Future<void> logout() async {
    AppLogger.info('Logging out user');

    await _repository.logout();

    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _phoneNumber = null;
    _otpSent = false;
    _errorMessage = null;

    AppLogger.success('User logged out');
    notifyListeners();
  }

  // Update Profile
  Future<bool> updateProfile(UserEntity user) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.updateProfile(user);

    return result.fold(
      (failure) {
        _status = AuthStatus.authenticated;
        _errorMessage = _mapFailureToMessage(failure);
        notifyListeners();
        return false;
      },
      (updatedUser) {
        _currentUser = updatedUser;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      },
    );
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset OTP state
  void resetOtpState() {
    _otpSent = false;
    _phoneNumber = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Helper - Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    if (failure is AuthFailure) return failure.message;
    return 'An unexpected error occurred';
  }
}
