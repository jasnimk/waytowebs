import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../models/payment_model.dart';
import '../repositories/payments_repository.dart';

class PaymentsController extends ChangeNotifier {
  final PaymentsRepository _repository;

  PaymentsController(this._repository);

  // State
  List<PaymentModel> _allPayments = [];
  List<PaymentModel> _pendingPayments = [];
  List<PaymentModel> _completedPayments = [];
  List<PaymentModel> _failedPayments = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PaymentModel> get allPayments => _allPayments;
  List<PaymentModel> get pendingPayments => _pendingPayments;
  List<PaymentModel> get completedPayments => _completedPayments;
  List<PaymentModel> get failedPayments => _failedPayments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Statistics
  double get totalPendingAmount {
    return _pendingPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double get totalCompletedAmount {
    return _completedPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  int get codPaymentsCount {
    return _allPayments.where((p) => p.isCOD).length;
  }

  int get onlinePaymentsCount {
    return _allPayments.where((p) => p.isOnline).length;
  }

  int get creditPaymentsCount {
    return _allPayments.where((p) => p.isCredit30 || p.isCredit90).length;
  }

  // Fetch all payments
  Future<void> fetchAllPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPayments = await _repository.getAllPayments();

      // Categorize payments by status
      _pendingPayments = _allPayments.where((p) => p.isPending).toList();
      _completedPayments = _allPayments.where((p) => p.isCompleted).toList();
      _failedPayments = _allPayments.where((p) => p.isFailed).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load payments';
      _isLoading = false;
      AppLogger.error('Error in fetchAllPayments', e);
      notifyListeners();
    }
  }

  // Update payment status
  Future<bool> updatePaymentStatus(String paymentId, String newStatus) async {
    try {
      await _repository.updatePaymentStatus(paymentId, newStatus);

      // Refresh payments
      await fetchAllPayments();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update payment status';
      AppLogger.error('Error in updatePaymentStatus', e);
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
