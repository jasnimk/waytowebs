import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/loading/loading_indicator.dart';
import '../../../../shared/presentation/widgets/errors/error_widget.dart';
import '../controllers/products_controller.dart';
import '../models/category_model.dart';
import '../widgets/product_card.dart';

class ProductsListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ProductsListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsController>().fetchProductsByCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: context.typography.titleLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ProductsController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: AppErrorWidget(
                message: controller.errorMessage!,
                onRetry: () {
                  controller.fetchProductsByCategory(widget.categoryId);
                },
              ),
            );
          }

          if (controller.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: context.colors.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: context.typography.titleMedium?.copyWith(
                      color: context.colors.textLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return _isGridView ? _buildGridView(controller) : _buildListView(controller);
        },
      ),
    );
  }

  Widget _buildGridView(ProductsController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: controller.products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: controller.products[index],
          isGridView: true,
        );
      },
    );
  }

  Widget _buildListView(ProductsController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.products.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductCard(
            product: controller.products[index],
            isGridView: false,
          ),
        );
      },
    );
  }
}
