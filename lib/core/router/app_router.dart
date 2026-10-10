import 'package:go_router/go_router.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/views/phone_input_screen.dart';
import '../../features/auth/views/otp_verification_screen.dart';
import '../../features/auth/controllers/auth_provider.dart';
import '../../features/customer/dashboard/views/customer_main_screen.dart';
import '../../features/dealer/dashboard/views/dealer_main_screen.dart';
import '../../features/plumber/dashboard/views/plumber_main_screen.dart';
import '../../features/admin/dashboard/views/admin_main_screen.dart';
import '../../features/customer/products/views/products_list_screen.dart';
import '../../features/customer/products/views/product_details_screen.dart';
import '../../features/customer/orders/views/checkout_screen.dart';

class AppRouter {
  static bool _isInitialized = false;

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final location = state.matchedLocation;
        final uri = state.uri.toString();

        print('🟢 ═══════════════════════════════════════════════');
        print('🟢 ROUTER REDIRECT CALLED');
        print('🟢 Location: $location');
        print('🟢 URI: $uri');
        print('🟢 isAuthenticated: $isAuthenticated');
        print('🟢 ═══════════════════════════════════════════════');

        // If authenticated, redirect auth pages and splash to dashboard
        if (isAuthenticated && (location.startsWith('/auth') || location == '/splash')) {
          if (authProvider.isCustomer) {
            print('🟢 → Redirecting authenticated customer to dashboard');
            return '/customer/dashboard';
          } else if (authProvider.isDealer) {
            print('🟢 → Redirecting authenticated dealer to dashboard');
            return '/dealer/dashboard';
          } else if (authProvider.isPlumber) {
            print('🟢 → Redirecting authenticated plumber to dashboard');
            return '/plumber/dashboard';
          } else if (authProvider.isAdmin) {
            print('🟢 → Redirecting authenticated admin to dashboard');
            return '/admin/dashboard';
          }
        }

        // Allow splash screen when not authenticated
        if (location == '/splash') {
          print('🟢 → ✅ Allowing splash screen');
          return null;
        }

        // Allow all auth pages when not authenticated
        if (!isAuthenticated) {
          // Allow navigation to any /auth/* page
          if (location.startsWith('/auth')) {
            print('🟢 → ✅ Allowing navigation to $location');
            return null;
          }
          // Redirect any other page to login
          print('🟢 → Redirecting $location to /auth/phone');
          return '/auth/phone';
        }

        print('🟢 → ✅ No redirect needed');
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/auth/phone',
          builder: (context, state) => const PhoneInputScreen(),
        ),
        GoRoute(
          path: '/auth/otp',
          builder: (context, state) => const OtpVerificationScreen(),
        ),

        // Dashboard routes
        GoRoute(
          path: '/customer/dashboard',
          builder: (context, state) {
            final tab = state.uri.queryParameters['tab'];
            final index = tab != null ? int.tryParse(tab) ?? 0 : 0;
            return CustomerMainScreen(initialIndex: index);
          },
        ),
        GoRoute(
          path: '/dealer/dashboard',
          builder: (context, state) => const DealerMainScreen(),
        ),
        GoRoute(
          path: '/plumber/dashboard',
          builder: (context, state) => const PlumberMainScreen(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminMainScreen(),
        ),

        // Product routes
        GoRoute(
          path: '/products/:categoryId',
          builder: (context, state) {
            final categoryId = state.pathParameters['categoryId']!;
            final categoryName = state.uri.queryParameters['name'] ?? 'Products';
            return ProductsListScreen(
              categoryId: categoryId,
              categoryName: categoryName,
            );
          },
        ),
        GoRoute(
          path: '/products/details/:productId',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            return ProductDetailsScreen(productId: productId);
          },
        ),

        // Order routes
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
      ],
    );
  }
}
