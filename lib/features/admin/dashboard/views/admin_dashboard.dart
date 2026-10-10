import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/common/app_snackbar.dart';
import '../../../auth/controllers/auth_provider.dart';
import 'package:way_to_webs/features/admin/users/views/users_management_screen.dart';
import 'package:way_to_webs/features/admin/products/views/products_management_screen.dart';
import 'package:way_to_webs/features/admin/orders/views/orders_management_screen.dart';
import '../widgets/payments_screen_export.dart';
import 'package:way_to_webs/features/admin/credit/views/dealer_credit_management_screen.dart';
import 'package:way_to_webs/features/admin/reports/views/reports_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.primary,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true && context.mounted) {
                await authProvider.logout();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.colors.primary, const Color(0xFF25272F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${user?.fullName?.split(' ').first ?? 'Admin'}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage your e-commerce platform',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Overview
            Text(
              'Overview',
              style: context.typography.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard(
                  context,
                  'Total Users',
                  '1,234',
                  Icons.people_outline,
                  context.colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Total Orders',
                  '567',
                  Icons.shopping_bag_outlined,
                  const Color(0xFF50C878),
                ),
                _buildStatCard(
                  context,
                  'Products',
                  '89',
                  Icons.inventory_2_outlined,
                  const Color(0xFFE67E22),
                ),
                _buildStatCard(
                  context,
                  'Revenue',
                  '₹2.5L',
                  Icons.currency_rupee,
                  const Color(0xFF9B59B6),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Management Sections
            Text(
              'Management',
              style: context.typography.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildManagementCard(
              context,
              'User Management',
              'Manage customers, dealers & plumbers',
              Icons.people_outline,
              context.colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsersManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildManagementCard(
              context,
              'Product Management',
              'Manage products & stock',
              Icons.inventory_2_outlined,
              const Color(0xFFE67E22),
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsManagementScreen()));
              },
            ),
            const SizedBox(height: 12),

            _buildManagementCard(
              context,
              'Order Management',
              'Track & manage orders',
              Icons.shopping_bag_outlined,
              const Color(0xFF50C878),
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersManagementScreen()));
              },
            ),
            const SizedBox(height: 12),

            _buildManagementCard(
              context,
              'Payments Management',
              'Track payments & transactions',
              Icons.payment_outlined,
              const Color(0xFF9B59B6),
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsManagementScreen()));
              },
            ),
            const SizedBox(height: 12),

            _buildManagementCard(
              context,
              'Dealer Credit',
              'Manage credit eligibility & limits',
              Icons.credit_card_outlined,
              const Color(0xFFFF9800),
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DealerCreditManagementScreen()));
              },
            ),
            const SizedBox(height: 12),

            _buildManagementCard(
              context,
              'Reports & Analytics',
              'View sales reports and insights',
              Icons.analytics_outlined,
              const Color(0xFFE74C3C),
              () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: context.typography.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: context.typography.labelSmall?.copyWith(
                    color: const Color(0xFF666666),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.typography.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.typography.bodySmall?.copyWith(
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: const Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }
}
