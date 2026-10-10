import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:way_to_webs/features/admin/users/views/users_management_screen.dart';
import 'package:way_to_webs/features/admin/products/views/products_management_screen.dart';
import 'package:way_to_webs/features/admin/orders/views/orders_management_screen.dart';
import '../widgets/payments_screen_export.dart';
import 'admin_dashboard.dart';

const platform = MethodChannel('com.example.way_to_webs/back_handler');

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const AdminDashboard(),
    const UsersManagementScreen(),
    const ProductsManagementScreen(),
    const OrdersManagementScreen(),
    const PaymentsManagementScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  DateTime? _lastBackPress;

  @override
  Future<bool> didPopRoute() async {
    print('📱 [ADMIN] didPopRoute called - currentIndex: $_currentIndex');

    if (_currentIndex != 0) {
      // Not on dashboard - go to dashboard
      print('➡️ [ADMIN] Switching to dashboard');
      setState(() => _currentIndex = 0);
      return true; // We handled it
    } else {
      // On dashboard - show exit confirmation via snackbar
      print('🏠 [ADMIN] On dashboard, checking double back press');

      final now = DateTime.now();
      if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
        // First press or too much time passed - show snackbar
        _lastBackPress = now;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return true; // We handled it
      } else {
        // Second press within 2 seconds - exit app
        print('✅ [ADMIN] Double back press detected, exiting app');
        await _exitApp();
        return true;
      }
    }
  }

  Future<void> _exitApp() async {
    try {
      await platform.invokeMethod('exitApp');
    } on PlatformException catch (e) {
      print("Failed to exit app: '${e.message}'.");
      SystemNavigator.pop(); // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1A1A1A),
            unselectedItemColor: const Color(0xFF999999),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Users',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payment_outlined),
                activeIcon: Icon(Icons.payment),
                label: 'Payments',
              ),
            ],
          ),
    );
  }
}
