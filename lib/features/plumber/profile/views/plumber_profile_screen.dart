import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/common/app_snackbar.dart';
import '../../../auth/controllers/auth_provider.dart';

class PlumberProfileScreen extends StatelessWidget {
  const PlumberProfileScreen({super.key});

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
            onPressed: () {
              authProvider.logout();
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.mist),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.colors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: context.colors.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Plumber',
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
                            '🔧 PLUMBER',
                            style: AppTextStyles.labelSmall(color: context.colors.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Summary
            Text(
              'Performance',
              style: AppTextStyles.titleLarge(color: context.colors.black),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    title: 'Completed',
                    value: '24',
                    color: context.colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star,
                    title: 'Rating',
                    value: '4.8',
                    color: context.colors.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Menu Options
            Text(
              'Account',
              style: AppTextStyles.titleLarge(color: context.colors.black),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.person,
              title: 'Edit Profile',
              onTap: () {
                AppSnackbar.info(context, 'Edit Profile - Coming soon!');
              },
            ),
            _MenuTile(
              icon: Icons.notifications,
              title: 'Notifications',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3',
                  style: AppTextStyles.labelSmall(color: Colors.white),
                ),
              ),
              onTap: () {
                AppSnackbar.info(context, 'Notifications - Coming soon!');
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Support',
              style: AppTextStyles.titleLarge(color: context.colors.black),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.help_outline,
              title: 'Help & FAQ',
              onTap: () {
                AppSnackbar.info(context, 'Help & FAQ - Coming soon!');
              },
            ),
            _MenuTile(
              icon: Icons.description,
              title: 'Terms & Conditions',
              onTap: () {
                AppSnackbar.info(context, 'Terms & Conditions - Coming soon!');
              },
            ),
            _MenuTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {
                AppSnackbar.info(context, 'Privacy Policy - Coming soon!');
              },
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  authProvider.logout();
                },
                icon: Icon(Icons.logout, color: context.colors.error),
                label: Text(
                  'Logout',
                  style: TextStyle(color: context.colors.error),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: context.colors.error),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // App Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: AppTextStyles.caption(color: context.colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
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
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.mist),
      ),
      child: ListTile(
        leading: Icon(icon, color: context.colors.grey),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium(color: context.colors.black),
        ),
        trailing: trailing ?? Icon(Icons.chevron_right, color: context.colors.grey),
        onTap: onTap,
      ),
    );
  }
}
