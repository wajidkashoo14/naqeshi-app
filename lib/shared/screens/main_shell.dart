import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../core/theme/app_theme.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', path: '/'),
    (icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: 'Shop', path: '/products'),
    (icon: Icons.favorite_border, activeIcon: Icons.favorite, label: 'Wishlist', path: '/wishlist'),
    (icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag, label: 'Cart', path: '/cart'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', path: '/profile'),
  ];

  int _indexForLocation(String location) {
    if (location.startsWith('/products')) return 1;
    if (location.startsWith('/wishlist')) return 2;
    if (location.startsWith('/cart') || location.startsWith('/checkout')) return 3;
    if (location.startsWith('/profile') || location.startsWith('/orders')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final cartCount = ref.watch(cartCountProvider);
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_tabs[i].path),
        items: _tabs.map((t) {
          final isCart = t.path == '/cart';
          return BottomNavigationBarItem(
            icon: isCart
                ? Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    child: Icon(t.icon),
                  )
                : Icon(t.icon),
            activeIcon: isCart
                ? Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    child: Icon(t.activeIcon, color: AppColors.gold),
                  )
                : Icon(t.activeIcon, color: AppColors.gold),
            label: t.label,
          );
        }).toList(),
      ),
    );
  }
}
