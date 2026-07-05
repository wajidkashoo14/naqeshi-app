import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/products/screens/product_list_screen.dart';
import '../../features/products/screens/product_detail_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/wishlist/screens/wishlist_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/addresses_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/orders/screens/order_confirmation_screen.dart';
import '../../features/reviews/screens/write_review_screen.dart';
import '../../shared/screens/main_shell.dart';
import '../../shared/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final location = state.uri.path;

      if (location == '/splash') return null;

      final authRoutes = ['/login', '/register', '/forgot-password'];
      final isOnAuth = authRoutes.contains(location);

      if (!isAuthenticated && !isOnAuth) return '/login';
      if (isAuthenticated && isOnAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: '/products',
            builder: (_, state) => ProductListScreen(
              category: state.uri.queryParameters['category'],
              search: state.uri.queryParameters['search'],
            ),
          ),
          GoRoute(
            path: '/products/:slug',
            builder: (_, state) => ProductDetailScreen(slug: state.pathParameters['slug']!),
          ),
          GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
          GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
          GoRoute(
            path: '/order-confirmation/:orderId',
            builder: (_, state) => OrderConfirmationScreen(orderId: state.pathParameters['orderId']!),
          ),
          GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
          GoRoute(
            path: '/orders/:id',
            builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/wishlist', builder: (_, __) => const WishlistScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
          GoRoute(path: '/profile/addresses', builder: (_, __) => const AddressesScreen()),
          GoRoute(
            path: '/reviews/write/:productId',
            builder: (_, state) => WriteReviewScreen(productId: state.pathParameters['productId']!),
          ),
        ],
      ),
    ],
  );
});
