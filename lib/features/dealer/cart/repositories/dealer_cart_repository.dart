import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../customer/cart/models/cart_item_model.dart';

class DealerCartRepository {
  final SupabaseClient _client;

  DealerCartRepository(this._client);

  // Reuse the same cart_items table from customer
  // The cart works the same way for dealers, just uses dealer pricing

  Future<List<CartItemModel>> getCartItems(String userId) async {
    final response = await _client
        .from('cart_items')
        .select('''
          *,
          product:products(*)
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => CartItemModel.fromJson(item))
        .toList();
  }

  Future<void> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    // Check if item already exists
    final existing = await _client
        .from('cart_items')
        .select()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      // Update quantity
      await _client
          .from('cart_items')
          .update({'quantity': existing['quantity'] + quantity})
          .eq('id', existing['id']);
    } else {
      // Add new item
      await _client.from('cart_items').insert({
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await _client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId);
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  Future<void> clearCart(String userId) async {
    await _client.from('cart_items').delete().eq('user_id', userId);
  }
}
