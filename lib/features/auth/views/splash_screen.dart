import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for 2 seconds to show splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Navigate based on authentication status
    if (authProvider.isAuthenticated) {
      // Router will handle redirect to appropriate dashboard
      if (authProvider.isCustomer) {
        context.go('/customer/dashboard');
      } else if (authProvider.isDealer) {
        context.go('/dealer/dashboard');
      } else if (authProvider.isPlumber) {
        context.go('/plumber/dashboard');
      }
    } else {
      context.go('/auth/phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.water_drop,
                size: 60,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Way to Webs',
              style: AppTextStyles.displayMedium(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Plumbing Solutions',
              style: AppTextStyles.bodyMedium(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
