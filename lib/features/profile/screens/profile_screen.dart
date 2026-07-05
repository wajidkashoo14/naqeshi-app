import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // Avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.beige,
                backgroundImage: user.image != null ? CachedNetworkImageProvider(user.image!) : null,
                child: user.image == null
                    ? Text(user.name?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(fontSize: 32, color: AppColors.gold))
                    : null,
              ),
              const SizedBox(height: 12),
              Text(user.name ?? 'No name', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(user.email, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 32),

              // Menu
              _MenuTile(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () => context.push('/profile/edit')),
              _MenuTile(icon: Icons.receipt_long_outlined, label: 'My Orders', onTap: () => context.push('/orders')),
              _MenuTile(icon: Icons.favorite_border, label: 'Wishlist', onTap: () => context.push('/wishlist')),
              _MenuTile(icon: Icons.location_on_outlined, label: 'Addresses', onTap: () => context.push('/profile/addresses')),
              const Divider(height: 32),
              _MenuTile(
                icon: Icons.logout,
                label: 'Sign Out',
                color: AppColors.error,
                onTap: () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ]),
          );
        },
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.ink;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: c)),
      trailing: Icon(Icons.chevron_right, color: c),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
