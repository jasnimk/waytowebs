import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../models/payment_model.dart';

class PaymentsRepository {
  final SupabaseClient _supabase;

  PaymentsRepository(this._supabase);

  /// Fetch all payments
  Future<List<PaymentModel>> getAllPayments() async {
    try {
      AppLogger.info('Fetching all payments');

      final response = await _supabase
          .from('payments')
          .select()
          .order('created_at', ascending: false);

      final payments = (response as List)
          .map((json) => PaymentModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${payments.length} payments');
      return payments;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching payments', e, stackTrace);
      rethrow;
    }
  }

  /// Fetch payments by status
  Future<List<PaymentModel>> getPaymentsByStatus(String status) async {
    try {
      AppLogger.info('Fetching payments with status: $status');

      final response = await _supabase
          .from('payments')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      final payments = (response as List)
          .map((json) => PaymentModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${payments.length} payments with status $status');
      return payments;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching payments by status', e, stackTrace);
      rethrow;
    }
  }

  /// Fetch payments by payment method
  Future<List<PaymentModel>> getPaymentsByMethod(String method) async {
    try {
      AppLogger.info('Fetching payments with method: $method');

      final response = await _supabase
          .from('payments')
          .select()
          .eq('payment_method', method)
          .order('created_at', ascending: false);

      final payments = (response as List)
          .map((json) => PaymentModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${payments.length} payments with method $method');
      return payments;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching payments by method', e, stackTrace);
      rethrow;
    }
  }

  /// Update payment status
  Future<void> updatePaymentStatus(String paymentId, String status) async {
    try {
      AppLogger.info('Updating payment $paymentId status to $status');

      await _supabase
          .from('payments')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      AppLogger.success('Updated payment $paymentId status to $status');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating payment status', e, stackTrace);
      rethrow;
    }
  }
}
