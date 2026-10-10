class PaymentModel {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String paymentMethod; // cod, online, credit_30, credit_90
  final String status; // pending, completed, failed
  final String? transactionId;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // Status helpers
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  // Payment method helpers
  bool get isCOD => paymentMethod == 'cod';
  bool get isOnline => paymentMethod == 'online';
  bool get isCredit30 => paymentMethod == 'credit_30';
  bool get isCredit90 => paymentMethod == 'credit_90';

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'cod':
        return 'Cash on Delivery';
      case 'online':
        return 'Online Payment';
      case 'credit_30':
        return '30 Days Credit';
      case 'credit_90':
        return '90 Days Credit';
      default:
        return 'Unknown';
    }
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'cod',
      status: json['status'] as String? ?? 'pending',
      transactionId: json['transaction_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'transaction_id': transactionId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
