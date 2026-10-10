import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../repositories/cart_repository.dart';
import '../../../../core/utils/logger.dart';

class CartController extends ChangeNotifier {
  final CartRepository _repository;
  String? _userId;

  CartController(this._repository);

  // State
  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;

  // Calculate totals
  double get subtotal => _items.fold(
      0.0, (sum, item) => sum + item.price * item.quantity);

  double get dealerSubtotal => _items.fold(
      0.0, (sum, item) => sum + (item.dealerPrice ?? item.price) * item.quantity);

  // Set user ID
  void setUserId(String userId) {
    _userId = userId;
    fetchCartItems();
  }

  // Fetch cart items
  Future<void> fetchCartItems() async {
    if (_userId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getCartItems(_userId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load cart items';
      _isLoading = false;
      AppLogger.error('Error in fetchCartItems', e);
      notifyListeners();
    }
  }

  // Add to cart
  Future<bool> addToCart({
    required String productId,
    required int quantity,
  }) async {
    if (_userId == null) return false;

    try {
      await _repository.addToCart(
        userId: _userId!,
        productId: productId,
        quantity: quantity,
      );

      // Refresh cart
      await fetchCartItems();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add item to cart';
      AppLogger.error('Error in addToCart', e);
      notifyListeners();
      return false;
    }
  }

  // Update quantity
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    try {
      await _repository.updateQuantity(cartItemId, quantity);

      // Update local state
      final index = _items.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(quantity: quantity);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update quantity';
      AppLogger.error('Error in updateQuantity', e);
      notifyListeners();
    }
  }

  // Increment quantity
  Future<void> incrementQuantity(String cartItemId) async {
    final item = _items.firstWhere((item) => item.id == cartItemId);
    if (item.quantity < item.stockQuantity) {
      await updateQuantity(cartItemId, item.quantity + 1);
    }
  }

  // Decrement quantity
  Future<void> decrementQuantity(String cartItemId) async {
    final item = _items.firstWhere((item) => item.id == cartItemId);
    await updateQuantity(cartItemId, item.quantity - 1);
  }

  // Remove from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _repository.removeFromCart(cartItemId);

      // Update local state
      _items.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove item';
      AppLogger.error('Error in removeFromCart', e);
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    if (_userId == null) return;

    try {
      await _repository.clearCart(_userId!);
      _items = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear cart';
      AppLogger.error('Error in clearCart', e);
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
