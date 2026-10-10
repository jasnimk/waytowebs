import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;
  final List<OrderItemModel> items;

  const OrderTrackingScreen({
    super.key,
    required this.order,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Tracking',
          style: context.typography.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: context.colors.primary.withOpacity(0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: context.typography.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Placed on ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt)}',
                    style: context.typography.bodyMedium?.copyWith(
                      color: context.colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Tracking Timeline
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Status',
                    style: context.typography.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _OrderTimeline(order: order),
                ],
              ),
            ),

            const Divider(height: 32, thickness: 8),

            // Order Items
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Items (${items.length})',
                    style: context.typography.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...items.map((item) => _OrderItemCard(item: item)),
                ],
              ),
            ),

            const Divider(height: 32, thickness: 8),

            // Delivery Address
            if (order.deliveryAddress != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: context.typography.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.colors.border,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: context.colors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              order.deliveryAddress!,
                              style: context.typography.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(height: 32, thickness: 8),

            // Payment & Total
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details',
                    style: context.typography.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PaymentDetailRow(
                    label: 'Payment Method',
                    value: _getPaymentMethodLabel(order.paymentMethod ?? 'cod'),
                  ),
                  const SizedBox(height: 8),
                  if (order.dealerDiscount != null && order.dealerDiscount! > 0)
                    _PaymentDetailRow(
                      label: 'Dealer Discount',
                      value: '-₹${order.dealerDiscount!.toStringAsFixed(2)}',
                      valueColor: context.colors.success,
                    ),
                  const Divider(height: 24),
                  _PaymentDetailRow(
                    label: 'Total Amount',
                    value: '₹${order.totalAmount.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const Divider(height: 32, thickness: 8),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Notes',
                      style: context.typography.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.notes!,
                        style: context.typography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'cod':
        return 'Cash on Delivery';
      case 'online':
        return 'Online Payment';
      case 'upfront':
        return 'Upfront Payment';
      case 'credit_30':
        return 'Credit Payment - 30 Days';
      case 'credit_90':
        return 'Credit Payment - 90 Days';
      default:
        return 'Unknown';
    }
  }
}

class _OrderTimeline extends StatelessWidget {
  final OrderModel order;

  const _OrderTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = _getOrderSteps();
    final currentStepIndex = _getCurrentStepIndex();

    return Column(
      children: List.generate(
        steps.length,
        (index) {
          final step = steps[index];
          final isCompleted = index < currentStepIndex;
          final isCurrent = index == currentStepIndex;
          final isLast = index == steps.length - 1;

          return _TimelineStep(
            title: step['title'] as String,
            subtitle: step['subtitle'] as String,
            icon: step['icon'] as IconData,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            isLast: isLast,
            isCancelled: order.isCancelled,
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getOrderSteps() {
    if (order.isCancelled) {
      return [
        {
          'title': 'Order Placed',
          'subtitle': DateFormat('MMM dd, hh:mm a').format(order.createdAt),
          'icon': Icons.check_circle,
        },
        {
          'title': 'Order Cancelled',
          'subtitle': order.updatedAt != null
              ? DateFormat('MMM dd, hh:mm a').format(order.updatedAt!)
              : 'Cancelled',
          'icon': Icons.cancel,
        },
      ];
    }

    return [
      {
        'title': 'Order Placed',
        'subtitle': DateFormat('MMM dd, hh:mm a').format(order.createdAt),
        'icon': Icons.shopping_bag,
      },
      {
        'title': 'Processing',
        'subtitle': 'Order is being prepared',
        'icon': Icons.inventory,
      },
      {
        'title': 'Shipped',
        'subtitle': 'Order is on the way',
        'icon': Icons.local_shipping,
      },
      {
        'title': 'Delivered',
        'subtitle': 'Order delivered successfully',
        'icon': Icons.check_circle,
      },
    ];
  }

  int _getCurrentStepIndex() {
    if (order.isCancelled) return 1;
    if (order.isDelivered) return 3;
    if (order.isShipped) return 2;
    if (order.isProcessing) return 1;
    return 0;
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final bool isCancelled;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    required this.isCancelled,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = isCancelled
        ? context.colors.error
        : context.colors.primary;
    final Color color = (isCompleted || isCurrent)
        ? activeColor
        : context.colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon & Line
        Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isCompleted || isCurrent)
                    ? color.withOpacity(0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? color : context.colors.grey.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.typography.titleMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: (isCompleted || isCurrent)
                        ? context.colors.text
                        : context.colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.typography.bodySmall?.copyWith(
                    color: context.colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final OrderItemModel item;

  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image Placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: context.colors.grey,
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: context.typography.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: context.typography.bodySmall?.copyWith(
                    color: context.colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Price
          Text(
            '₹${item.price.toStringAsFixed(0)}',
            style: context.typography.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const _PaymentDetailRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? context.typography.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )
              : context.typography.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? context.typography.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? context.colors.primary,
                )
              : context.typography.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
        ),
      ],
    );
  }
}
