class CartItemModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final double? dealerPrice;
  final int quantity;
  final int stockQuantity;
  final DateTime createdAt;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    this.dealerPrice,
    required this.quantity,
    required this.stockQuantity,
    required this.createdAt,
  });

  // Calculate total price
  double get totalPrice => price * quantity;
  double get totalDealerPrice => (dealerPrice ?? price) * quantity;

  // Check if item is in stock
  bool get isInStock => quantity <= stockQuantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String? ?? '',
      productImage: json['product_image'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      dealerPrice: (json['dealer_price'] as num?)?.toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'dealer_price': dealerPrice,
      'quantity': quantity,
      'stock_quantity': stockQuantity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CartItemModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    double? dealerPrice,
    int? quantity,
    int? stockQuantity,
    DateTime? createdAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      dealerPrice: dealerPrice ?? this.dealerPrice,
      quantity: quantity ?? this.quantity,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
