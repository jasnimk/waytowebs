enum DealerPaymentMethod {
  upfront,
  credit30Days,
  credit90Days;

  String get displayName {
    switch (this) {
      case DealerPaymentMethod.upfront:
        return 'Upfront Payment';
      case DealerPaymentMethod.credit30Days:
        return '30 Days Credit';
      case DealerPaymentMethod.credit90Days:
        return '90 Days Credit';
    }
  }

  String get value {
    switch (this) {
      case DealerPaymentMethod.upfront:
        return 'upfront';
      case DealerPaymentMethod.credit30Days:
        return 'credit_30_days';
      case DealerPaymentMethod.credit90Days:
        return 'credit_90_days';
    }
  }

  static DealerPaymentMethod fromString(String value) {
    switch (value) {
      case 'upfront':
        return DealerPaymentMethod.upfront;
      case 'credit_30_days':
        return DealerPaymentMethod.credit30Days;
      case 'credit_90_days':
        return DealerPaymentMethod.credit90Days;
      default:
        return DealerPaymentMethod.upfront;
    }
  }
}
