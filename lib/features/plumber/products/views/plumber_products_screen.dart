import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../customer/products/repositories/products_repository.dart';
import '../../../customer/products/controllers/products_controller.dart';
import '../../../customer/products/models/product_model.dart';

class PlumberProductsScreen extends StatefulWidget {
  const PlumberProductsScreen({super.key});

  @override
  State<PlumberProductsScreen> createState() => _PlumberProductsScreenState();
}

class _PlumberProductsScreenState extends State<PlumberProductsScreen> with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  ProductsController? _productsController;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize once
    if (!_isInitialized) {
      _isInitialized = true;
      final repository = ProductsRepository(Supabase.instance.client);
      _productsController = ProductsController(repository);
      _productsController!.fetchFeaturedProducts();
    }
  }

  @override
  void dispose() {
    _productsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_productsController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _productsController!,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.primary,
          title: const Text('Products Catalog', style: TextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.mist),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.mist),
                  ),
                  filled: true,
                  fillColor: context.colors.canvas,
                ),
              ),
            ),

            // Products List
            Expanded(
              child: Consumer<ProductsController>(
                builder: (context, controller, _) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: context.colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage!,
                            style: AppTextStyles.bodyLarge(color: context.colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.fetchFeaturedProducts(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Apply search filter
                  var filteredProducts = controller.featuredProducts;
                  if (_searchQuery.isNotEmpty) {
                    filteredProducts = filteredProducts.where((product) {
                      final nameLower = product.name.toLowerCase();
                      final queryLower = _searchQuery.toLowerCase();
                      return nameLower.contains(queryLower);
                    }).toList();
                  }

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Text(
                        'No products found',
                        style: AppTextStyles.bodyLarge(color: context.colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _ProductCard(product: product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.mist),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.colors.canvas,
              borderRadius: BorderRadius.circular(8),
              image: (product.thumbnailUrl != null && product.thumbnailUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(product.thumbnailUrl!),
                      fit: BoxFit.cover,
                    )
                  : product.images.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.images.first),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: (product.thumbnailUrl == null || product.thumbnailUrl!.isEmpty) && product.images.isEmpty
                ? Icon(Icons.build, size: 32, color: context.colors.grey)
                : null,
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.titleSmall(color: context.colors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (product.description.isNotEmpty)
                  Text(
                    product.description,
                    style: AppTextStyles.bodySmall(color: context.colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₹${product.price.toStringAsFixed(2)}',
                      style: AppTextStyles.titleSmall(color: context.colors.primary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.stockQuantity > 0
                            ? context.colors.green.withValues(alpha: 0.1)
                            : context.colors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.stockQuantity > 0 ? 'In Stock' : 'Out of Stock',
                        style: AppTextStyles.labelSmall(
                          color: product.stockQuantity > 0 ? context.colors.green : context.colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
