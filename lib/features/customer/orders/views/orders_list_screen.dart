import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import 'order_tracking_screen.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock orders data - will be replaced with real data from database
    final mockOrders = [
      {
        'orderNumber': 'ORD-2024-001',
        'date': 'Oct 10, 2024',
        'items': 3,
        'total': 2499.0,
        'status': 'delivered',
      },
      {
        'orderNumber': 'ORD-2024-002',
        'date': 'Oct 09, 2024',
        'items': 1,
        'total': 899.0,
        'status': 'shipped',
      },
      {
        'orderNumber': 'ORD-2024-003',
        'date': 'Oct 08, 2024',
        'items': 5,
        'total': 4599.0,
        'status': 'processing',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: context.typography.titleLarge,
        ),
      ),
      body: mockOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 120,
                    color: context.colors.textLight,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No orders yet',
                    style: context.typography.titleLarge?.copyWith(
                      color: context.colors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start shopping to see your orders here',
                    style: context.typography.bodyMedium?.copyWith(
                      color: context.colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockOrders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = mockOrders[index];
                return _OrderCard(order: order);
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;
    final statusColor = _getStatusColor(context, status);
    final statusLabel = _getStatusLabel(status);

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Fetch actual order and items from database
            // For now, create mock data for navigation
            final orderModel = OrderModel(
              id: 'mock-id',
              userId: 'mock-user',
              orderNumber: order['orderNumber'] as String,
              totalAmount: (order['total'] as double),
              status: order['status'] as String,
              deliveryAddress: '123 Main St, City, State - 123456',
              paymentMethod: 'cod',
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
            );

            final items = <OrderItemModel>[
              OrderItemModel(
                id: 'item-1',
                orderId: 'mock-id',
                productId: 'product-1',
                productName: 'Sample Product 1',
                quantity: 2,
                price: 499.0,
                subtotal: 998.0,
              ),
              OrderItemModel(
                id: 'item-2',
                orderId: 'mock-id',
                productId: 'product-2',
                productName: 'Sample Product 2',
                quantity: 1,
                price: 899.0,
                subtotal: 899.0,
              ),
            ];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderTrackingScreen(
                  order: orderModel,
                  items: items,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Number & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['orderNumber'] as String,
                      style: context.typography.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: context.typography.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date & Items
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: context.colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order['date'] as String,
                      style: context.typography.bodySmall?.copyWith(
                        color: context.colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: context.colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${order['items']} items',
                      style: context.typography.bodySmall?.copyWith(
                        color: context.colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const Divider(height: 1),
                const SizedBox(height: 12),

                // Total & View Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Amount',
                          style: context.typography.bodySmall?.copyWith(
                            color: context.colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${(order['total'] as double).toStringAsFixed(0)}',
                          style: context.typography.titleLarge?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Fetch actual order and items from database
                        final orderModel = OrderModel(
                          id: 'mock-id',
                          userId: 'mock-user',
                          orderNumber: order['orderNumber'] as String,
                          totalAmount: (order['total'] as double),
                          status: order['status'] as String,
                          deliveryAddress: '123 Main St, City, State - 123456',
                          paymentMethod: 'cod',
                          createdAt: DateTime.now().subtract(const Duration(days: 1)),
                        );

                        final items = <OrderItemModel>[
                          OrderItemModel(
                            id: 'item-1',
                            orderId: 'mock-id',
                            productId: 'product-1',
                            productName: 'Sample Product 1',
                            quantity: 2,
                            price: 499.0,
                            subtotal: 998.0,
                          ),
                          OrderItemModel(
                            id: 'item-2',
                            orderId: 'mock-id',
                            productId: 'product-2',
                            productName: 'Sample Product 2',
                            quantity: 1,
                            price: 899.0,
                            subtotal: 899.0,
                          ),
                        ];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderTrackingScreen(
                              order: orderModel,
                              items: items,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'delivered':
        return context.colors.success;
      case 'shipped':
        return context.colors.blue;
      case 'processing':
        return context.colors.orange;
      case 'cancelled':
        return context.colors.error;
      default:
        return context.colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'delivered':
        return 'Delivered';
      case 'shipped':
        return 'Shipped';
      case 'processing':
        return 'Processing';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}
