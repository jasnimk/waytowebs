import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class DealerOrdersScreen extends StatelessWidget {
  const DealerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.primary,
        title: const Text('My Orders', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: context.colors.grey),
            const SizedBox(height: 16),
            Text(
              'Order History',
              style: AppTextStyles.titleLarge(color: context.colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon!',
              style: AppTextStyles.bodyMedium(color: context.colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
