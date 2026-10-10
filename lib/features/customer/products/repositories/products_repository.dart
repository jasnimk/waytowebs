import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductsRepository {
  final SupabaseClient _supabase;

  ProductsRepository(this._supabase);

  // Fetch all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      AppLogger.info('Fetching categories from Supabase');

      final response = await _supabase
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final categories = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${categories.length} categories');
      return categories;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching categories', e, stackTrace);
      rethrow;
    }
  }

  // Fetch products by category
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      AppLogger.info('Fetching products for category: $categoryId');

      final response = await _supabase
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final products = (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${products.length} products');
      return products;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching products', e, stackTrace);
      rethrow;
    }
  }

  // Fetch all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      AppLogger.info('Fetching all products');

      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final products = (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${products.length} products');
      return products;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching all products', e, stackTrace);
      rethrow;
    }
  }

  // Fetch all featured products
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      AppLogger.info('Fetching featured products');

      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(10);

      final products = (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${products.length} featured products');
      return products;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching featured products', e, stackTrace);
      rethrow;
    }
  }

  // Fetch single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      AppLogger.info('Fetching product: $productId');

      final response = await _supabase
          .from('products')
          .select()
          .eq('id', productId)
          .single();

      final product = ProductModel.fromJson(response);
      AppLogger.success('Fetched product: ${product.name}');
      return product;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching product', e, stackTrace);
      return null;
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      AppLogger.info('Searching products: $query');

      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .or('name.ilike.%$query%,description.ilike.%$query%,sku.ilike.%$query%')
          .order('created_at', ascending: false);

      final products = (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();

      AppLogger.success('Found ${products.length} products');
      return products;
    } catch (e, stackTrace) {
      AppLogger.error('Error searching products', e, stackTrace);
      rethrow;
    }
  }

  // Upsert products (insert or update) - for Zoho sync
  Future<void> upsertProducts(List<ProductModel> products) async {
    try {
      AppLogger.info('Upserting ${products.length} products to Supabase');

      final productData = products.map((p) => p.toJson()).toList();

      await _supabase
          .from('products')
          .upsert(productData, onConflict: 'id');

      AppLogger.success('Upserted ${products.length} products successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error upserting products', e, stackTrace);
      rethrow;
    }
  }
}
