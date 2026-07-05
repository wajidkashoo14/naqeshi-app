import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/products/models/product_model.dart';
import '../../features/wishlist/providers/wishlist_provider.dart';
import '../../core/theme/app_theme.dart';
import 'price_text.dart';

class ProductCard extends ConsumerWidget {
  final ProductSummary product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(isWishlistedProvider(product.id));

    return GestureDetector(
      onTap: () => context.push('/products/${product.slug}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.beige,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(color: AppColors.beige),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.beige,
                        child: const Icon(Icons.image_outlined, color: AppColors.muted),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => ref.read(wishlistProvider.notifier).toggle(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isWishlisted ? AppColors.copper : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  PriceText(price: product.price, comparePrice: product.comparePrice),
                  if (product.avgRating > 0) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star, size: 12, color: AppColors.gold),
                      const SizedBox(width: 2),
                      Text(product.avgRating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall),
                      Text(' (${product.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
