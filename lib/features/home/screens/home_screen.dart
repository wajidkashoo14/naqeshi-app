import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../products/providers/products_provider.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _NaqeshiAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroBanner(),
                _CategoryRow(),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Featured Collection', onSeeAll: () => context.push('/products')),
              ],
            ),
          ),
          _FeaturedGrid(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}

class _NaqeshiAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      title: Text('Naqeshi', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.gold)),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.push('/products'),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(2),
        gradient: const LinearGradient(
          colors: [AppColors.beige, Color(0xFFE8D8C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Authentic Kashmiri\nHandicrafts',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.ink,
                    height: 1.2,
                  )),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.push('/products'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.zero),
              child: Text('Shop Now', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends ConsumerWidget {
  final _categories = const [
    (label: 'Boxes', icon: Icons.inventory_2_outlined),
    (label: 'Bowls', icon: Icons.circle_outlined),
    (label: 'Vases', icon: Icons.local_florist_outlined),
    (label: 'Trays', icon: Icons.dashboard_outlined),
    (label: 'Frames', icon: Icons.photo_frame_back_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          return GestureDetector(
            onTap: () => context.push('/products?category=${cat.label.toLowerCase()}'),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(2)),
                child: Icon(cat.icon, color: AppColors.copper),
              ),
              const SizedBox(height: 6),
              Text(cat.label, style: Theme.of(context).textTheme.bodySmall),
            ]),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionTitle({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: Text('See all', style: TextStyle(color: AppColors.gold))),
      ]),
    );
  }
}

class _FeaturedGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppColors.gold),
        )),
      ),
      error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
      data: (result) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, i) => ProductCard(product: result.products[i]),
            childCount: result.products.take(8).length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
        ),
      ),
    );
  }
}
