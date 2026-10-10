import 'package:flutter/foundation.dart';
import '../../../customer/products/models/category_model.dart';
import '../../../customer/products/models/product_model.dart';
import '../../../customer/products/repositories/products_repository.dart';
import '../../../../core/utils/logger.dart';

class DealerProductsController extends ChangeNotifier {
  final ProductsRepository _repository;

  DealerProductsController(this._repository);

  // State
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  ProductModel? _selectedProduct;

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
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

  // Fetch all products
  Future<void> fetchAllProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getAllProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load products';
      _isLoading = false;
      AppLogger.error('Error in fetchAllProducts', e);
      notifyListeners();
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
      _errorMessage = 'Failed to load product';
      _isLoading = false;
      AppLogger.error('Error in fetchProductById', e);
      notifyListeners();
    }
  }

  // Search products
  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products.where((product) {
      final nameLower = product.name.toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();
  }

  // Filter products by stock availability
  List<ProductModel> get inStockProducts {
    return _products.where((product) => product.stockQuantity > 0).toList();
  }

  List<ProductModel> get lowStockProducts {
    return _products.where((product) =>
      product.stockQuantity > 0 && product.stockQuantity < 10
    ).toList();
  }

  List<ProductModel> get outOfStockProducts {
    return _products.where((product) => product.stockQuantity == 0).toList();
  }
}
