import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../customer/orders/models/order_model.dart';
import '../controllers/orders_controller.dart';
import '../repositories/orders_repository.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrdersController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    final repository = OrdersRepository(Supabase.instance.client);
    _controller = OrdersController(repository);
    _controller.fetchAllOrders();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _controller.fetchAllOrders();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.primary,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Orders Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _controller.fetchAllOrders(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            isScrollable: true,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Processing'),
              Tab(text: 'Shipped'),
              Tab(text: 'Delivered'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOrdersList('all'),
            _buildOrdersList('pending'),
            _buildOrdersList('processing'),
            _buildOrdersList('shipped'),
            _buildOrdersList('delivered'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(String filter) {
    return Consumer<OrdersController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchAllOrders(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<OrderModel> orders;
        switch (filter) {
          case 'pending':
            orders = controller.pendingOrders;
            break;
          case 'processing':
            orders = controller.processingOrders;
            break;
          case 'shipped':
            orders = controller.shippedOrders;
            break;
          case 'delivered':
            orders = controller.deliveredOrders;
            break;
          default:
            orders = controller.allOrders;
        }

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No ${filter == 'all' ? '' : filter} orders',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) => _buildOrderCard(orders[index]),
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'processing':
        statusColor = Colors.blue;
        statusIcon = Icons.autorenew;
        break;
      case 'shipped':
        statusColor = Colors.purple;
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOrderDetails(order),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.orderNumber,
                        style: context.typography.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            order.statusLabel,
                            style: context.typography.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: context.typography.bodySmall?.copyWith(
                              color: const Color(0xFF999999),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${order.totalAmount.toStringAsFixed(2)}',
                            style: context.typography.titleMedium?.copyWith(
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Date',
                            style: context.typography.bodySmall?.copyWith(
                              color: const Color(0xFF999999),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                            style: context.typography.bodySmall?.copyWith(
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (order.dealerDiscount != null && order.dealerDiscount! > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B59B6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Dealer Discount: ₹${order.dealerDiscount!.toStringAsFixed(2)}',
                        style: context.typography.bodySmall?.copyWith(
                          color: const Color(0xFF9B59B6),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          order.orderNumber,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Order Number', order.orderNumber),
                    _buildDetailRow('Status', order.statusLabel),
                    _buildDetailRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(2)}'),
                    if (order.dealerDiscount != null && order.dealerDiscount! > 0)
                      _buildDetailRow('Dealer Discount', '₹${order.dealerDiscount!.toStringAsFixed(2)}'),
                    _buildDetailRow(
                      'Order Date',
                      '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                    ),
                    if (order.deliveryAddress != null)
                      _buildDetailRow('Delivery Address', order.deliveryAddress!),
                    if (order.paymentMethod != null)
                      _buildDetailRow('Payment Method', order.paymentMethod!),
                    if (order.notes != null) _buildDetailRow('Notes', order.notes!),
                    const SizedBox(height: 24),
                    const Text('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusChip('pending', order),
                        _buildStatusChip('processing', order),
                        _buildStatusChip('shipped', order),
                        _buildStatusChip('delivered', order),
                        _buildStatusChip('cancelled', order),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, OrderModel order) {
    final isSelected = order.status == status;
    Color chipColor;

    switch (status) {
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'processing':
        chipColor = Colors.blue;
        break;
      case 'shipped':
        chipColor = Colors.purple;
        break;
      case 'delivered':
        chipColor = Colors.green;
        break;
      case 'cancelled':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return FilterChip(
      label: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: isSelected ? Colors.white : chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) async {
        if (selected && status != order.status) {
          Navigator.pop(context);

          final scaffoldMessenger = ScaffoldMessenger.of(this.context);
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Updating order status...')),
          );

          final success = await _controller.updateOrderStatus(order.id, status);
          scaffoldMessenger.clearSnackBars();

          if (success) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('✅ Order status updated'), backgroundColor: Colors.green),
            );
          } else {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('❌ Failed to update'), backgroundColor: Colors.red),
            );
          }
        }
      },
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      backgroundColor: chipColor.withOpacity(0.1),
    );
  }
}
