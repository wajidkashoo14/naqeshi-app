class WishlistProduct {
  final String id;
  final String name;
  final String slug;
  final String imageUrl;
  final double price;
  final double? comparePrice;
  final double avgRating;
  final int reviewCount;

  const WishlistProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.price,
    this.comparePrice,
    required this.avgRating,
    required this.reviewCount,
  });

  factory WishlistProduct.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    final url = images != null && images.isNotEmpty
        ? (images[0] as Map<String, dynamic>)['url'] as String? ?? ''
        : '';
    return WishlistProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      imageUrl: url,
      price: (json['price'] as num).toDouble(),
      comparePrice: json['comparePrice'] != null ? (json['comparePrice'] as num).toDouble() : null,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }
}

class WishlistItemModel {
  final String id;
  final WishlistProduct product;

  const WishlistItemModel({required this.id, required this.product});

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) => WishlistItemModel(
        id: json['id'] as String,
        product: WishlistProduct.fromJson(json['product'] as Map<String, dynamic>),
      );
}
