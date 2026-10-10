import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../customer/products/repositories/products_repository.dart';
import '../controllers/dealer_products_controller.dart';
import '../widgets/dealer_product_card.dart';

class DealerProductsScreen extends StatefulWidget {
  const DealerProductsScreen({super.key});

  @override
  State<DealerProductsScreen> createState() => _DealerProductsScreenState();
}

class _DealerProductsScreenState extends State<DealerProductsScreen> {
  String _searchQuery = '';
  String _stockFilter = 'all'; // all, in_stock, low_stock, out_of_stock

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final repository = ProductsRepository(Supabase.instance.client);
        final controller = DealerProductsController(repository);
        controller.fetchAllProducts();
        return controller;
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.primary,
          title: const Text('Browse Products', style: TextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            // Search and Filter Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search field
                  TextField(
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
                  const SizedBox(height: 12),
                  // Stock filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all', Icons.inventory_2),
                        const SizedBox(width: 8),
                        _buildFilterChip('In Stock', 'in_stock', Icons.check_circle),
                        const SizedBox(width: 8),
                        _buildFilterChip('Low Stock', 'low_stock', Icons.warning),
                        const SizedBox(width: 8),
                        _buildFilterChip('Out of Stock', 'out_of_stock', Icons.remove_circle),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Products List
            Expanded(
              child: Consumer<DealerProductsController>(
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
                            onPressed: () => controller.fetchAllProducts(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Apply filters
                  var filteredProducts = controller.products;

                  // Apply stock filter
                  switch (_stockFilter) {
                    case 'in_stock':
                      filteredProducts = controller.inStockProducts;
                      break;
                    case 'low_stock':
                      filteredProducts = controller.lowStockProducts;
                      break;
                    case 'out_of_stock':
                      filteredProducts = controller.outOfStockProducts;
                      break;
                  }

                  // Apply search filter
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
                      return DealerProductCard(product: product);
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

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _stockFilter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : context.colors.grey),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _stockFilter = value);
      },
      backgroundColor: Colors.white,
      selectedColor: context.colors.secondary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : context.colors.black,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
