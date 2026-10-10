import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../../customer/orders/models/order_model.dart';
import '../repositories/orders_repository.dart';

class OrdersController extends ChangeNotifier {
  final OrdersRepository _repository;

  OrdersController(this._repository);

  // State
  List<OrderModel> _allOrders = [];
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _processingOrders = [];
  List<OrderModel> _shippedOrders = [];
  List<OrderModel> _deliveredOrders = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<OrderModel> get allOrders => _allOrders;
  List<OrderModel> get pendingOrders => _pendingOrders;
  List<OrderModel> get processingOrders => _processingOrders;
  List<OrderModel> get shippedOrders => _shippedOrders;
  List<OrderModel> get deliveredOrders => _deliveredOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all orders
  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allOrders = await _repository.getAllOrders();

      // Categorize orders by status
      _pendingOrders = _allOrders.where((o) => o.isPending).toList();
      _processingOrders = _allOrders.where((o) => o.isProcessing).toList();
      _shippedOrders = _allOrders.where((o) => o.isShipped).toList();
      _deliveredOrders = _allOrders.where((o) => o.isDelivered).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load orders';
      _isLoading = false;
      AppLogger.error('Error in fetchAllOrders', e);
      notifyListeners();
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _repository.updateOrderStatus(orderId, newStatus);

      // Refresh orders
      await fetchAllOrders();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update order status';
      AppLogger.error('Error in updateOrderStatus', e);
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
