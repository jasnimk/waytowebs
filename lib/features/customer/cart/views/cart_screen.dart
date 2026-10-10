import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/loading/loading_indicator.dart';
import '../../../../shared/presentation/widgets/buttons/primary_button.dart';
import '../../../../shared/presentation/widgets/common/app_snackbar.dart';
import '../../../auth/controllers/auth_provider.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<CartController>().setUserId(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDealer = authProvider.isDealer;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: context.typography.titleLarge,
        ),
        actions: [
          Consumer<CartController>(
            builder: (context, controller, _) {
              if (controller.items.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    _showClearCartDialog(context, controller);
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: context.colors.error),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (controller.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 120,
                    color: context.colors.textLight,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your cart is empty',
                    style: context.typography.titleLarge?.copyWith(
                      color: context.colors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to get started',
                    style: context.typography.bodyMedium?.copyWith(
                      color: context.colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Browse Products',
                    onPressed: () {
                      context.go('/customer/dashboard?tab=1');
                    },
                  ),
                ],
              ),
            );
          }

          final subtotal = isDealer ? controller.dealerSubtotal : controller.subtotal;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    final displayPrice = isDealer && item.dealerPrice != null
                        ? item.dealerPrice!
                        : item.price;

                    return Container(
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
                      child: Row(
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                            child: item.productImage != null &&
                                    item.productImage!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.productImage!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 100,
                                      height: 100,
                                      color: context.colors.backgroundLight,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        _buildImagePlaceholder(context),
                                  )
                                : _buildImagePlaceholder(context),
                          ),

                          // Product Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: context.typography.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${displayPrice.toStringAsFixed(0)}',
                                    style: context.typography.titleMedium?.copyWith(
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Quantity Controls
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: context.colors.mist,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, size: 18),
                                              onPressed: () {
                                                controller.decrementQuantity(item.id);
                                              },
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(
                                                minWidth: 32,
                                                minHeight: 32,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                              ),
                                              child: Text(
                                                item.quantity.toString(),
                                                style: context.typography.titleSmall
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add, size: 18),
                                              onPressed: item.quantity < item.stockQuantity
                                                  ? () {
                                                      controller.incrementQuantity(item.id);
                                                    }
                                                  : null,
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(
                                                minWidth: 32,
                                                minHeight: 32,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Remove Button
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: context.colors.error,
                                        ),
                                        onPressed: () {
                                          controller.removeFromCart(item.id);
                                          AppSnackbar.success(
                                            context,
                                            'Removed from cart',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Bar - Summary & Checkout
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Subtotal',
                                style: context.typography.bodyMedium?.copyWith(
                                  color: context.colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${subtotal.toStringAsFixed(0)}',
                                style: context.typography.headlineSmall?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: PrimaryButton(
                              text: 'Checkout (${controller.itemCount})',
                              onPressed: () {
                                context.push('/checkout');
                              },
                            ),
                          ),
                        ],
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

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: context.colors.backgroundLight,
      child: Icon(
        Icons.inventory_2_outlined,
        size: 40,
        color: context.colors.textLight,
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartController controller) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clearCart();
              Navigator.pop(dialogContext);
              AppSnackbar.success(context, 'Cart cleared');
            },
            child: Text(
              'Clear',
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }
}
