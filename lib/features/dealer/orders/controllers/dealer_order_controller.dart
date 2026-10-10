import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../../customer/cart/models/cart_item_model.dart';
import '../models/dealer_payment_method.dart';

class DealerOrderController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> placeOrder({
    required String userId,
    required List<CartItemModel> cartItems,
    required String shippingAddress,
    required String shippingCity,
    required String shippingState,
    required String shippingPincode,
    required DealerPaymentMethod paymentMethod,
    String? notes,
  }) async {
    try {
      AppLogger.info('Placing dealer order for user: $userId');

      // Calculate totals
      final subtotal = cartItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.dealerPrice ?? item.price) * item.quantity,
      );

      // Prepare order data
      final orderData = {
        'user_id': userId,
        'subtotal': subtotal,
        'total': subtotal, // Can add taxes/shipping later
        'payment_method': paymentMethod.value,
        'payment_status': paymentMethod == DealerPaymentMethod.upfront
            ? 'pending'
            : 'credit', // Credit orders marked as 'credit'
        'order_status': 'pending',
        'shipping_address': shippingAddress,
        'shipping_city': shippingCity,
        'shipping_state': shippingState,
        'shipping_pincode': shippingPincode,
        'shipping_name': '', // Can get from user profile
        'shipping_phone': '', // Can get from user profile
        'notes': notes,
      };

      // Insert order
      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      final orderId = orderResponse['id'];

      AppLogger.info('Order created: $orderId');

      // Insert order items
      final orderItems = cartItems.map((item) {
        return {
          'order_id': orderId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.dealerPrice ?? item.price, // Use dealer price
        };
      }).toList();

      await _supabase.from('order_items').insert(orderItems);

      AppLogger.success('Dealer order placed successfully: $orderId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error placing dealer order', e, stackTrace);
      return false;
    }
  }
}
