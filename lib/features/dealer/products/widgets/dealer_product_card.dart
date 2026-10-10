import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../customer/products/models/product_model.dart';
import '../../cart/controllers/dealer_cart_controller.dart';

class DealerProductCard extends StatelessWidget {
  final ProductModel product;

  const DealerProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final bool lowStock = product.stockQuantity > 0 && product.stockQuantity < 10;
    final bool outOfStock = product.stockQuantity == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: outOfStock
              ? context.colors.error.withValues(alpha: 0.3)
              : lowStock
                  ? context.colors.orange.withValues(alpha: 0.3)
                  : context.colors.mist,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.colors.canvas,
                borderRadius: BorderRadius.circular(8),
                image: product.thumbnailUrl != null
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
                  ? Icon(Icons.inventory_2, size: 32, color: context.colors.grey)
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
                    style: AppTextStyles.titleMedium(color: context.colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.description != null) ...[
                    Text(
                      product.description!,
                      style: AppTextStyles.bodySmall(color: context.colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Price
                  Text(
                    'Rs ${product.price.toStringAsFixed(0)}',
                    style: AppTextStyles.titleMedium(color: context.colors.primary),
                  ),
                  const SizedBox(height: 8),

                  // Stock Status
                  Row(
                    children: [
                      Icon(
                        outOfStock
                            ? Icons.remove_circle
                            : lowStock
                                ? Icons.warning
                                : Icons.check_circle,
                        size: 16,
                        color: outOfStock
                            ? context.colors.error
                            : lowStock
                                ? context.colors.orange
                                : context.colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        outOfStock
                            ? 'Out of Stock'
                            : lowStock
                                ? 'Low Stock: ${product.stockQuantity} units'
                                : 'In Stock: ${product.stockQuantity} units',
                        style: AppTextStyles.labelSmall(
                          color: outOfStock
                              ? context.colors.error
                              : lowStock
                                  ? context.colors.orange
                                  : context.colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add to Cart Button
            Column(
              children: [
                IconButton(
                  onPressed: outOfStock ? null : () async {
                    final cartController = context.read<DealerCartController>();
                    final success = await cartController.addToCart(
                      productId: product.id,
                      quantity: 1,
                    );

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.add_shopping_cart,
                    color: outOfStock ? context.colors.grey : context.colors.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: outOfStock
                        ? context.colors.canvas
                        : context.colors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
