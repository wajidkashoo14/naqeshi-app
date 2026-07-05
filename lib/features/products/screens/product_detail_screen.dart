import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../providers/products_provider.dart';
import '../models/product_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../../shared/widgets/price_text.dart';
import '../../../core/theme/app_theme.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _imageIndex = 0;
  ProductVariant? _selectedVariant;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.slug));

    return productAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (product) => _buildScaffold(context, product),
    );
  }

  Widget _buildScaffold(BuildContext context, ProductDetail product) {
    final isWishlisted = ref.watch(isWishlistedProvider(product.id));
    final price = _selectedVariant?.price ?? product.price;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? AppColors.copper : AppColors.ink,
                ),
                onPressed: () => ref.read(wishlistProvider.notifier).toggle(product.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  if (product.images.isNotEmpty)
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 400,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        onPageChanged: (i, _) => setState(() => _imageIndex = i),
                      ),
                      items: product.images
                          .map((img) => CachedNetworkImage(
                                imageUrl: img.url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ))
                          .toList(),
                    )
                  else
                    Container(color: AppColors.beige),
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedSmoothIndicator(
                          activeIndex: _imageIndex,
                          count: product.images.length,
                          effect: const WormEffect(
                            dotColor: AppColors.beige,
                            activeDotColor: AppColors.gold,
                            dotHeight: 8,
                            dotWidth: 8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(product.name, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                PriceText(price: price, comparePrice: product.comparePrice),
                if (product.avgRating > 0) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < product.avgRating.round() ? Icons.star : Icons.star_border,
                        color: AppColors.gold,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${product.avgRating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ]),
                ],
                if (product.stock <= 5 && product.stock > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Only ${product.stock} left in stock!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.copper),
                  ),
                ],
                if (product.stock == 0) ...[
                  const SizedBox(height: 8),
                  Text('Out of stock', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error)),
                ],
                if (product.variants.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Options', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.variants.map((v) {
                      final selected = _selectedVariant?.id == v.id;
                      final outOfStock = v.stock == 0;
                      return ChoiceChip(
                        label: Text(v.name),
                        selected: selected,
                        onSelected: outOfStock ? null : (_) => setState(() => _selectedVariant = v),
                        selectedColor: AppColors.gold,
                        disabledColor: AppColors.beige,
                        labelStyle: TextStyle(
                          color: outOfStock
                              ? AppColors.muted
                              : selected
                                  ? AppColors.white
                                  : AppColors.ink,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (product.shortDesc != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    product.shortDesc!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
                if (product.description != null) ...[
                  const SizedBox(height: 20),
                  Text('Description', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(product.description!, style: Theme.of(context).textTheme.bodyMedium),
                ],
                if (product.material != null || product.artisanName != null) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  if (product.material != null) _infoRow(context, 'Material', product.material!),
                  if (product.artisanName != null) _infoRow(context, 'Artisan', product.artisanName!),
                ],
                if (product.artisanStory != null) ...[
                  const SizedBox(height: 16),
                  Text('Artisan Story', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    product.artisanStory!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
                if (product.reviews.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Text('Reviews', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  ...product.reviews.map((r) => _ReviewTile(review: r)),
                ],
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: product.stock > 0
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: AppColors.ivory,
                  border: Border(top: BorderSide(color: AppColors.ink.withOpacity(0.14))),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Row 1: qty stepper + wishlist
                  Row(children: [
                    // Qty stepper
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.ink),
                        ),
                        child: Row(children: [
                          _QtyBtn(
                            icon: Icons.remove,
                            onTap: () { if (_qty > 1) setState(() => _qty--); },
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '$_qty',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                          _QtyBtn(
                            icon: Icons.add,
                            onTap: () {
                              if (_qty < product.stock) setState(() => _qty++);
                            },
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Wishlist button
                    _WishlistBtn(productId: product.id),
                  ]),
                  const SizedBox(height: 10),
                  // Row 2: full-width Add to Cart
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(cartProvider.notifier).addItem(
                              productId: product.id,
                              variantId: _selectedVariant?.id,
                              quantity: _qty,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_qty > 1 ? 'Added $_qty items to cart' : 'Added to cart'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Add to Cart'),
                    ),
                  ),
                ]),
              ),
            )
          : null,
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
      ]),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ProductReview review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          ...List.generate(
            5,
            (i) => Icon(
              i < review.rating ? Icons.star : Icons.star_border,
              color: AppColors.gold,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(review.user.name ?? 'Anonymous', style: Theme.of(context).textTheme.titleMedium),
        ]),
        if (review.title.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(review.title, style: Theme.of(context).textTheme.titleMedium),
        ],
        if (review.body.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(review.body, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const Divider(height: 24),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 18, color: AppColors.ink),
      ),
    );
  }
}

class _WishlistBtn extends ConsumerWidget {
  final String productId;
  const _WishlistBtn({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(isWishlistedProvider(productId));
    return GestureDetector(
      onTap: () => ref.read(wishlistProvider.notifier).toggle(productId),
      child: Container(
        width: 52,
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.ink.withOpacity(0.14)),
        ),
        child: Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          color: isWishlisted ? AppColors.gold : AppColors.ink,
          size: 20,
        ),
      ),
    );
  }
}
