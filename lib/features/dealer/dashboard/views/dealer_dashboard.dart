import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/common/app_snackbar.dart';
import '../../../auth/controllers/auth_provider.dart';
import '../../products/views/dealer_products_screen.dart';

class DealerDashboard extends StatefulWidget {
  const DealerDashboard({super.key});

  @override
  State<DealerDashboard> createState() => _DealerDashboardState();
}

class _DealerDashboardState extends State<DealerDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              authProvider.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.secondary,
                    context.colors.fog, // Darker blue
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🏢 DEALER',
                      style: AppTextStyles.labelSmall(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome Back!',
                    style: AppTextStyles.titleLarge(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.fullName ?? user?.phoneNumber ?? 'Dealer',
                    style: AppTextStyles.displaySmall(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Credit Available',
                    value: '₹50,000',
                    icon: Icons.account_balance_wallet,
                    color: context.colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Outstanding',
                    value: '₹12,500',
                    icon: Icons.pending_actions,
                    color: context.colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTextStyles.titleLarge(color: context.colors.black),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _QuickActionCard(
                  icon: Icons.inventory,
                  title: 'Browse Products',
                  subtitle: 'With stock info',
                  color: context.colors.secondary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DealerProductsScreen(),
                      ),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.shopping_cart,
                  title: 'Place Order',
                  subtitle: 'Bulk ordering',
                  color: context.colors.green,
                  onTap: () {
                    AppSnackbar.info(context, 'Place Order - Coming soon!');
                  },
                ),
                _QuickActionCard(
                  icon: Icons.history,
                  title: 'Order History',
                  subtitle: 'Track orders',
                  color: context.colors.orange,
                  onTap: () {
                    AppSnackbar.info(context, 'Order History - Coming soon!');
                  },
                ),
                _QuickActionCard(
                  icon: Icons.payment,
                  title: 'Payments',
                  subtitle: 'Credit tracking',
                  color: context.colors.fog,
                  onTap: () {
                    AppSnackbar.info(context, 'Payments - Coming soon!');
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Dealer Benefits
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.canvas,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dealer Benefits',
                    style: AppTextStyles.titleMedium(color: context.colors.black),
                  ),
                  const SizedBox(height: 16),
                  _BenefitItem(
                    icon: Icons.check_circle,
                    text: 'View stock quantities',
                    color: context.colors.green,
                  ),
                  _BenefitItem(
                    icon: Icons.check_circle,
                    text: 'Special dealer pricing',
                    color: context.colors.green,
                  ),
                  _BenefitItem(
                    icon: Icons.check_circle,
                    text: 'Credit payment options (30/90 days)',
                    color: context.colors.green,
                  ),
                  _BenefitItem(
                    icon: Icons.check_circle,
                    text: 'Bulk order discounts',
                    color: context.colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.mist),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.titleLarge(color: context.colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption(color: context.colors.grey),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.mist),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.titleSmall(color: context.colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption(color: context.colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _BenefitItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium(color: context.colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
