import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../repositories/products_repository.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/zoho/zoho_service.dart';
import 'package:uuid/uuid.dart';

class ProductsController extends ChangeNotifier {
  final ProductsRepository _repository;

  ProductsController(this._repository);

  // State
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  ProductModel? _selectedProduct;

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories';
      _isLoading = false;
      AppLogger.error('Error in fetchCategories', e);
      notifyListeners();
    }
  }

  // Fetch products by category
  Future<void> fetchProductsByCategory(String categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getProductsByCategory(categoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load products';
      _isLoading = false;
      AppLogger.error('Error in fetchProductsByCategory', e);
      notifyListeners();
    }
  }

  // Fetch featured products
  Future<void> fetchFeaturedProducts() async {
    try {
      _featuredProducts = await _repository.getFeaturedProducts();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error in fetchFeaturedProducts', e);
    }
  }

  // Fetch single product
  Future<void> fetchProductById(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProduct = await _repository.getProductById(productId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load product details';
      _isLoading = false;
      AppLogger.error('Error in fetchProductById', e);
      notifyListeners();
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _products = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.searchProducts(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to search products';
      _isLoading = false;
      AppLogger.error('Error in searchProducts', e);
      notifyListeners();
    }
  }

  // Clear products
  void clearProducts() {
    _products = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sync products from Zoho Books
  Future<Map<String, dynamic>> syncFromZohoBooks() async {
    try {
      final zohoService = ZohoService();
      final result = await zohoService.syncProductsFromZoho();

      if (result['success'] == true) {
        final zohoProducts = result['products'] as List;

        // Convert Zoho products to ProductModel
        // Using a default category ID for uncategorized products
        // You can update this later to map Zoho categories to Supabase category IDs
        const defaultCategoryId = '00000000-0000-0000-0000-000000000001';
        const uuid = Uuid();

        _products = zohoProducts.map((zp) {
          // Generate a proper UUID for Supabase
          // Store Zoho's ID in the SKU field for reference
          final zohoId = zp['id'] as String;
          final productUuid = uuid.v5(Uuid.NAMESPACE_OID, zohoId); // Deterministic UUID from Zoho ID

          return ProductModel(
            id: productUuid, // Use generated UUID
            categoryId: defaultCategoryId,
            name: zp['name'] as String,
            description: zp['description'] as String? ?? '',
            sku: zohoId, // Store Zoho ID here for reference
            price: zp['customer_price'] as double,
            mrp: zp['customer_price'] as double,
            dealerPrice: zp['dealer_price'] as double,
            stockQuantity: zp['stock'] as int,
            images: (zp['image_url'] as String? ?? '').isNotEmpty
              ? [zp['image_url'] as String]
              : [],
            isActive: true,
            isFeatured: false,
            createdAt: DateTime.now(),
          );
        }).toList();

        // Save products to Supabase for persistence
        await _repository.upsertProducts(_products);

        notifyListeners();
      }

      return result;
    } catch (e) {
      AppLogger.error('Error syncing from Zoho Books', e);
      return {
        'success': false,
        'error': e.toString(),
        'products': [],
        'count': 0,
      };
    }
  }
}
