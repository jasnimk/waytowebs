import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/payment_model.dart';
import '../controllers/payments_controller.dart';
import '../repositories/payments_repository.dart';

class PaymentsManagementScreen extends StatefulWidget {
  const PaymentsManagementScreen({super.key});

  @override
  State<PaymentsManagementScreen> createState() => _PaymentsManagementScreenState();
}

class _PaymentsManagementScreenState extends State<PaymentsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PaymentsController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    final repository = PaymentsRepository(Supabase.instance.client);
    _controller = PaymentsController(repository);
    _controller.fetchAllPayments();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _controller.fetchAllPayments();
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
            'Payments Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _controller.fetchAllPayments(),
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
              Tab(text: 'Completed'),
              Tab(text: 'Failed'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildStatsBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPaymentsList('all'),
                  _buildPaymentsList('pending'),
                  _buildPaymentsList('completed'),
                  _buildPaymentsList('failed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Consumer<PaymentsController>(
      builder: (context, controller, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  'Rs ${controller.totalPendingAmount.toStringAsFixed(0)}',
                  Icons.schedule,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  'Rs ${controller.totalCompletedAmount.toStringAsFixed(0)}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(String filter) {
    return Consumer<PaymentsController>(
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
                  onPressed: () => controller.fetchAllPayments(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<PaymentModel> payments;
        switch (filter) {
          case 'pending':
            payments = controller.pendingPayments;
            break;
          case 'completed':
            payments = controller.completedPayments;
            break;
          case 'failed':
            payments = controller.failedPayments;
            break;
          default:
            payments = controller.allPayments;
        }

        if (payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No payments found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) => _buildPaymentCard(payments[index]),
        );
      },
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    Color statusColor;
    IconData statusIcon;

    switch (payment.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    Color methodColor;
    IconData methodIcon;

    switch (payment.paymentMethod) {
      case 'cod':
        methodColor = Colors.blue;
        methodIcon = Icons.money;
        break;
      case 'online':
        methodColor = Colors.purple;
        methodIcon = Icons.credit_card;
        break;
      case 'credit_30':
      case 'credit_90':
        methodColor = const Color(0xFF9B59B6);
        methodIcon = Icons.calendar_month;
        break;
      default:
        methodColor = Colors.grey;
        methodIcon = Icons.payment;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPaymentDetails(payment),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs ${payment.amount.toStringAsFixed(2)}',
                            style: context.typography.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order ID: ${payment.orderId.substring(0, 8)}...',
                            style: context.typography.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            payment.statusLabel,
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
                    Icon(methodIcon, size: 16, color: methodColor),
                    const SizedBox(width: 6),
                    Text(
                      payment.paymentMethodLabel,
                      style: context.typography.bodySmall?.copyWith(
                        color: methodColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
                      style: context.typography.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (payment.transactionId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'TXN: ${payment.transactionId}',
                      style: context.typography.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 10,
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

  void _showPaymentDetails(PaymentModel payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                          'Payment Details',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rs ${payment.amount.toStringAsFixed(2)}',
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
                    _buildDetailRow('Amount', 'Rs ${payment.amount.toStringAsFixed(2)}'),
                    _buildDetailRow('Status', payment.statusLabel),
                    _buildDetailRow('Payment Method', payment.paymentMethodLabel),
                    _buildDetailRow('Order ID', payment.orderId),
                    if (payment.transactionId != null)
                      _buildDetailRow('Transaction ID', payment.transactionId!),
                    _buildDetailRow(
                      'Date',
                      '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
                    ),
                    if (payment.notes != null) _buildDetailRow('Notes', payment.notes!),
                    const SizedBox(height: 24),
                    const Text('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusChip('pending', payment),
                        _buildStatusChip('completed', payment),
                        _buildStatusChip('failed', payment),
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

  Widget _buildStatusChip(String status, PaymentModel payment) {
    final isSelected = payment.status == status;
    Color chipColor;

    switch (status) {
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'failed':
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
        if (selected && status != payment.status) {
          Navigator.pop(context);

          final scaffoldMessenger = ScaffoldMessenger.of(this.context);
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Updating payment status...')),
          );

          final success = await _controller.updatePaymentStatus(payment.id, status);
          scaffoldMessenger.clearSnackBars();

          if (success) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Payment status updated'), backgroundColor: Colors.green),
            );
          } else {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Failed to update'), backgroundColor: Colors.red),
            );
          }
        }
      },
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      backgroundColor: chipColor.withValues(alpha: 0.1),
    );
  }
}
