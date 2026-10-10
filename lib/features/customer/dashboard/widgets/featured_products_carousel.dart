import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../customer/products/controllers/products_controller.dart';
import '../../../auth/controllers/auth_provider.dart';

class FeaturedProductsCarousel extends StatefulWidget {
  const FeaturedProductsCarousel({super.key});

  @override
  State<FeaturedProductsCarousel> createState() =>
      _FeaturedProductsCarouselState();
}

class _FeaturedProductsCarouselState extends State<FeaturedProductsCarousel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsController>().fetchFeaturedProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsController = context.watch<ProductsController>();
    final authProvider = context.watch<AuthProvider>();
    final isDealer = authProvider.isDealer;

    if (productsController.featuredProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: context.typography.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.go('/customer/dashboard?tab=1');
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: productsController.featuredProducts.length,
            itemBuilder: (context, index) {
              final product = productsController.featuredProducts[index];
              final displayPrice = isDealer && product.dealerPrice != null
                  ? product.dealerPrice!
                  : product.price;

              return GestureDetector(
                onTap: () {
                  context.push('/products/details/${product.id}');
                },
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: product.displayImage.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.displayImage,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 120,
                                  color: context.colors.backgroundLight,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 120,
                                  color: context.colors.backgroundLight,
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 40,
                                    color: context.colors.textLight,
                                  ),
                                ),
                              )
                            : Container(
                                height: 120,
                                color: context.colors.backgroundLight,
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 40,
                                  color: context.colors.textLight,
                                ),
                              ),
                      ),

                      // Product Details
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: context.typography.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${displayPrice.toStringAsFixed(0)}',
                                  style: context.typography.titleMedium?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (product.stockQuantity > 0)
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: context.colors.success,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
