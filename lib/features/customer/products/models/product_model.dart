class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String sku;
  final double price;
  final double? mrp;
  final double? dealerPrice;
  final int stockQuantity;
  final List<String> images;
  final String? thumbnailUrl;
  final Map<String, dynamic>? specifications;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.sku,
    required this.price,
    this.mrp,
    this.dealerPrice,
    required this.stockQuantity,
    required this.images,
    this.thumbnailUrl,
    this.specifications,
    required this.isActive,
    required this.isFeatured,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: json['category_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      sku: json['sku'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      mrp: json['mrp'] != null ? (json['mrp']).toDouble() : null,
      dealerPrice: json['dealer_price'] != null ? (json['dealer_price']).toDouble() : null,
      stockQuantity: json['stock_quantity'] ?? 0,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      thumbnailUrl: json['thumbnail_url'],
      specifications: json['specifications'],
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'sku': sku,
      'price': price,
      'mrp': mrp,
      'dealer_price': dealerPrice,
      'stock_quantity': stockQuantity,
      'images': images,
      'thumbnail_url': thumbnailUrl,
      'specifications': specifications,
      'is_active': isActive,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayImage => thumbnailUrl ?? (images.isNotEmpty ? images.first : '');
}
