import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/common/app_snackbar.dart';
import '../../../auth/controllers/auth_provider.dart';

class DealerProfileScreen extends StatelessWidget {
  const DealerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.primary,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: context.colors.secondary.withValues(alpha: 0.1),
                  child: Icon(Icons.person, size: 40, color: context.colors.secondary),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? 'Dealer',
                  style: AppTextStyles.titleLarge(color: context.colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.phoneNumber ?? '',
                  style: AppTextStyles.bodyMedium(color: context.colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'DEALER',
                    style: AppTextStyles.labelSmall(color: context.colors.secondary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Credit Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Credit Status',
                  style: AppTextStyles.titleMedium(color: context.colors.black),
                ),
                const SizedBox(height: 12),
                if (user?.credit90DaysEnabled == true)
                  _buildCreditBadge(context, '90 Days Credit', Colors.purple)
                else if (user?.credit30DaysEnabled == true)
                  _buildCreditBadge(context, '30 Days Credit', Colors.orange)
                else
                  _buildCreditBadge(context, 'No Credit', Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Menu Options
          _buildMenuTile(
            context,
            'Payment History',
            Icons.payment,
            () {
              AppSnackbar.info(context, 'Payment History - Coming soon!');
            },
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            'Credit Details',
            Icons.credit_card,
            () {
              AppSnackbar.info(context, 'Credit Details - Coming soon!');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreditBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: context.colors.secondary),
        title: Text(title, style: AppTextStyles.bodyLarge(color: context.colors.black)),
        trailing: Icon(Icons.chevron_right, color: context.colors.grey),
        onTap: onTap,
      ),
    );
  }
}
