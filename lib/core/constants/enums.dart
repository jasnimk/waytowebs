enum UserRole {
  customer,
  dealer,
  plumber,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.dealer:
        return 'Dealer';
      case UserRole.plumber:
        return 'Plumber';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum PaymentStatus {
  pending,
  paid,
  credit,
  failed;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.credit:
        return 'Credit';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }
}

enum PaymentMethod {
  upfront,
  credit30,
  credit90;

  String get displayName {
    switch (this) {
      case PaymentMethod.upfront:
        return 'Pay Now';
      case PaymentMethod.credit30:
        return 'Credit - 30 Days';
      case PaymentMethod.credit90:
        return 'Credit - 90 Days';
    }
  }
}
