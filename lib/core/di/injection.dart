import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/repositories/auth_repository_impl.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/controllers/auth_provider.dart';
import '../../features/customer/products/repositories/products_repository.dart';
import '../../features/customer/products/controllers/products_controller.dart';
import '../../features/customer/cart/repositories/cart_repository.dart';
import '../../features/customer/cart/controllers/cart_controller.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/supabase_service.dart';

class AppProviders {
  static List<SingleChildWidget> providers = [
    // Services
    Provider<SupabaseService>(
      create: (_) => SupabaseService(),
    ),
    Provider<StorageService>(
      create: (_) => StorageService.instance,
    ),

    // Repositories
    ProxyProvider<SupabaseService, AuthRepository>(
      update: (_, supabase, __) => AuthRepositoryImpl(supabase),
    ),
    Provider<ProductsRepository>(
      create: (_) => ProductsRepository(Supabase.instance.client),
    ),
    Provider<CartRepository>(
      create: (_) => CartRepository(Supabase.instance.client),
    ),

    // Providers
    ChangeNotifierProxyProvider<AuthRepository, AuthProvider>(
      create: (context) => AuthProvider(
        context.read<AuthRepository>(),
      )..initialize(),
      update: (_, repository, previous) =>
          previous ?? AuthProvider(repository)..initialize(),
    ),
    ChangeNotifierProxyProvider<ProductsRepository, ProductsController>(
      create: (context) => ProductsController(
        context.read<ProductsRepository>(),
      ),
      update: (_, repository, previous) =>
          previous ?? ProductsController(repository),
    ),
    ChangeNotifierProxyProvider<CartRepository, CartController>(
      create: (context) => CartController(
        context.read<CartRepository>(),
      ),
      update: (_, repository, previous) =>
          previous ?? CartController(repository),
    ),
  ];
}
