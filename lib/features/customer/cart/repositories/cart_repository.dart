import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item_model.dart';
import '../../../../core/utils/logger.dart';

class CartRepository {
  final SupabaseClient _supabase;

  CartRepository(this._supabase);

  // Get all cart items for user
  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final response = await _supabase
          .from('cart_items')
          .select('''
            *,
            products (
              name,
              price,
              dealer_price,
              stock_quantity,
              images
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        // Merge product data into cart item
        final productData = json['products'] as Map<String, dynamic>?;
        return CartItemModel.fromJson({
          ...json,
          'product_name': productData?['name'] ?? '',
          'price': productData?['price'] ?? 0.0,
          'dealer_price': productData?['dealer_price'],
          'stock_quantity': productData?['stock_quantity'] ?? 0,
          'product_image': productData?['images'] != null &&
                  (productData!['images'] as List).isNotEmpty
              ? (productData['images'] as List)[0]
              : null,
        });
      }).toList();
    } catch (e) {
      AppLogger.error('Error fetching cart items', e);
      rethrow;
    }
  }

  // Add item to cart
  Future<CartItemModel> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      // Check if item already exists in cart
      final existing = await _supabase
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        // Update quantity
        final newQuantity = (existing['quantity'] as int) + quantity;
        final updated = await _supabase
            .from('cart_items')
            .update({'quantity': newQuantity})
            .eq('id', existing['id'])
            .select('''
              *,
              products (
                name,
                price,
                dealer_price,
                stock_quantity,
                images
              )
            ''')
            .single();

        final productData = updated['products'] as Map<String, dynamic>?;
        return CartItemModel.fromJson({
          ...updated,
          'product_name': productData?['name'] ?? '',
          'price': productData?['price'] ?? 0.0,
          'dealer_price': productData?['dealer_price'],
          'stock_quantity': productData?['stock_quantity'] ?? 0,
          'product_image': productData?['images'] != null &&
                  (productData!['images'] as List).isNotEmpty
              ? (productData['images'] as List)[0]
              : null,
        });
      } else {
        // Insert new item
        final inserted = await _supabase
            .from('cart_items')
            .insert({
              'user_id': userId,
              'product_id': productId,
              'quantity': quantity,
            })
            .select('''
              *,
              products (
                name,
                price,
                dealer_price,
                stock_quantity,
                images
              )
            ''')
            .single();

        final productData = inserted['products'] as Map<String, dynamic>?;
        return CartItemModel.fromJson({
          ...inserted,
          'product_name': productData?['name'] ?? '',
          'price': productData?['price'] ?? 0.0,
          'dealer_price': productData?['dealer_price'],
          'stock_quantity': productData?['stock_quantity'] ?? 0,
          'product_image': productData?['images'] != null &&
                  (productData!['images'] as List).isNotEmpty
              ? (productData['images'] as List)[0]
              : null,
        });
      }
    } catch (e) {
      AppLogger.error('Error adding to cart', e);
      rethrow;
    }
  }

  // Update cart item quantity
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      await _supabase
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', cartItemId);
    } catch (e) {
      AppLogger.error('Error updating cart quantity', e);
      rethrow;
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _supabase.from('cart_items').delete().eq('id', cartItemId);
    } catch (e) {
      AppLogger.error('Error removing from cart', e);
      rethrow;
    }
  }

  // Clear entire cart
  Future<void> clearCart(String userId) async {
    try {
      await _supabase.from('cart_items').delete().eq('user_id', userId);
    } catch (e) {
      AppLogger.error('Error clearing cart', e);
      rethrow;
    }
  }

  // Get cart item count
  Future<int> getCartItemCount(String userId) async {
    try {
      final response = await _supabase
          .from('cart_items')
          .select('quantity')
          .eq('user_id', userId);

      if (response is List && response.isNotEmpty) {
        return (response as List)
            .map((item) => item['quantity'] as int)
            .reduce((a, b) => a + b);
      }
      return 0;
    } catch (e) {
      AppLogger.error('Error getting cart count', e);
      return 0;
    }
  }
}
