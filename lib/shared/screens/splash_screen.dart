import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final user = await ref.read(authStateProvider.future);
    if (!mounted) return;
    context.go(user != null ? '/' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Naqeshi',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.gold)),
            const SizedBox(height: 8),
            Text('Authentic Kashmiri Crafts',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
