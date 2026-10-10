import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../../customer/orders/models/order_model.dart';

class OrdersRepository {
  final SupabaseClient _supabase;

  OrdersRepository(this._supabase);

  /// Fetch all orders
  Future<List<OrderModel>> getAllOrders() async {
    try {
      AppLogger.info('Fetching all orders');

      final response = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      final orders = (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${orders.length} orders');
      return orders;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching orders', e, stackTrace);
      rethrow;
    }
  }

  /// Fetch orders by status
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      AppLogger.info('Fetching orders with status: $status');

      final response = await _supabase
          .from('orders')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      final orders = (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${orders.length} orders with status $status');
      return orders;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching orders by status', e, stackTrace);
      rethrow;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      AppLogger.info('Updating order $orderId status to $status');

      await _supabase
          .from('orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      AppLogger.success('Updated order $orderId status to $status');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating order status', e, stackTrace);
      rethrow;
    }
  }
}
