import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/loading/loading_indicator.dart';
import '../../../../shared/presentation/widgets/errors/error_widget.dart';
import '../../../../shared/presentation/widgets/buttons/primary_button.dart';
import '../../../../shared/presentation/widgets/common/app_snackbar.dart';
import '../../../auth/controllers/auth_provider.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/products_controller.dart';
import '../widgets/product_image_carousel.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsController>().fetchProductById(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: context.typography.titleLarge,
        ),
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
                  controller.fetchProductById(widget.productId);
                },
              ),
            );
          }

          final product = controller.selectedProduct;
          if (product == null) {
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
                    'Product not found',
                    style: context.typography.titleMedium?.copyWith(
                      color: context.colors.textLight,
                    ),
                  ),
                ],
              ),
            );
          }

          final authProvider = context.watch<AuthProvider>();
          final isDealer = authProvider.isDealer;
          final displayPrice = isDealer && product.dealerPrice != null
              ? product.dealerPrice!
              : product.price;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel
                      ProductImageCarousel(
                        images: product.images.isNotEmpty
                            ? product.images
                            : [product.displayImage],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(
                              product.name,
                              style: context.typography.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Price Section
                            Row(
                              children: [
                                Text(
                                  '₹${displayPrice.toStringAsFixed(0)}',
                                  style: context.typography.headlineMedium?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (product.mrp != null && product.mrp! > displayPrice) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    '₹${product.mrp!.toStringAsFixed(0)}',
                                    style: context.typography.titleMedium?.copyWith(
                                      color: context.colors.textLight,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colors.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${(((product.mrp! - displayPrice) / product.mrp!) * 100).toStringAsFixed(0)}% OFF',
                                      style: context.typography.labelSmall?.copyWith(
                                        color: context.colors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            if (isDealer && product.dealerPrice != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: context.colors.blue,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Dealer Price Applied',
                                      style: context.typography.bodySmall?.copyWith(
                                        color: context.colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Stock Status
                            Row(
                              children: [
                                Icon(
                                  product.stockQuantity > 0
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 20,
                                  color: product.stockQuantity > 0
                                      ? context.colors.success
                                      : context.colors.error,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  product.stockQuantity > 0
                                      ? isDealer
                                          ? 'In Stock (${product.stockQuantity} available)'
                                          : 'In Stock'
                                      : 'Out of Stock',
                                  style: context.typography.bodyMedium?.copyWith(
                                    color: product.stockQuantity > 0
                                        ? context.colors.success
                                        : context.colors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 24),

                            // Description
                            if (product.description != null) ...[
                              Text(
                                'Description',
                                style: context.typography.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.description!,
                                style: context.typography.bodyMedium?.copyWith(
                                  color: context.colors.grey,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Specifications
                            if (product.specifications != null &&
                                product.specifications!.isNotEmpty) ...[
                              Text(
                                'Specifications',
                                style: context.typography.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: context.colors.backgroundLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: product.specifications!.entries.map((entry) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: context.colors.mist,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              _formatSpecKey(entry.key),
                                              style: context.typography.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              entry.value.toString(),
                                              style: context.typography.bodyMedium?.copyWith(
                                                color: context.colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Bar - Quantity & Add to Cart
              if (product.stockQuantity > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // Quantity Selector
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.mist),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: _quantity > 1
                                    ? () {
                                        setState(() {
                                          _quantity--;
                                        });
                                      }
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  _quantity.toString(),
                                  style: context.typography.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _quantity < product.stockQuantity
                                    ? () {
                                        setState(() {
                                          _quantity++;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Add to Cart Button
                        Expanded(
                          child: PrimaryButton(
                            text: 'Add to Cart',
                            onPressed: () async {
                              final cartController = context.read<CartController>();
                              final success = await cartController.addToCart(
                                productId: product.id,
                                quantity: _quantity,
                              );

                              if (success && mounted) {
                                AppSnackbar.success(
                                  context,
                                  'Added $_quantity x ${product.name} to cart',
                                );
                                setState(() {
                                  _quantity = 1;
                                });
                              } else if (mounted) {
                                AppSnackbar.error(
                                  context,
                                  'Failed to add to cart',
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatSpecKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
