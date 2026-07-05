class ProductImage {
  final String url;
  final String? alt;

  const ProductImage({required this.url, this.alt});

  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      ProductImage(url: json['url'] as String, alt: json['alt'] as String?);
}

class ProductVariant {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String? image;
  final Map<String, dynamic> options;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.image,
    required this.options,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        stock: json['stock'] as int? ?? 0,
        image: json['image'] as String?,
        options: json['options'] as Map<String, dynamic>? ?? {},
      );
}

class ReviewAuthor {
  final String? name;
  final String? image;
  const ReviewAuthor({this.name, this.image});

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) =>
      ReviewAuthor(name: json['name'] as String?, image: json['image'] as String?);
}

class ProductReview {
  final String id;
  final int rating;
  final String title;
  final String body;
  final ReviewAuthor user;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.rating,
    required this.title,
    required this.body,
    required this.user,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
        id: json['id'] as String,
        rating: json['rating'] as int,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        user: ReviewAuthor.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ProductDetail {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? shortDesc;
  final double price;
  final double? comparePrice;
  final List<ProductImage> images;
  final double avgRating;
  final int reviewCount;
  final String? material;
  final String? artisanName;
  final String? artisanStory;
  final List<ProductVariant> variants;
  final List<ProductReview> reviews;
  final int stock;

  const ProductDetail({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.shortDesc,
    required this.price,
    this.comparePrice,
    required this.images,
    required this.avgRating,
    required this.reviewCount,
    this.material,
    this.artisanName,
    this.artisanStory,
    required this.variants,
    required this.reviews,
    required this.stock,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final imgs = (json['images'] as List?)
            ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return ProductDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      shortDesc: json['shortDesc'] as String?,
      price: (json['price'] as num).toDouble(),
      comparePrice: json['comparePrice'] != null ? (json['comparePrice'] as num).toDouble() : null,
      images: imgs,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      material: json['material'] as String?,
      artisanName: json['artisanName'] as String?,
      artisanStory: json['artisanStory'] as String?,
      variants: (json['variants'] as List?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reviews: (json['reviews'] as List?)
              ?.map((e) => ProductReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stock: json['inventory']?['stock'] as int? ?? 0,
    );
  }
}

class ProductSummary {
  final String id;
  final String name;
  final String slug;
  final String imageUrl;
  final double price;
  final double? comparePrice;
  final double avgRating;
  final int reviewCount;

  const ProductSummary({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.price,
    this.comparePrice,
    required this.avgRating,
    required this.reviewCount,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    final imageUrl = images != null && images.isNotEmpty
        ? (images[0] as Map<String, dynamic>)['url'] as String? ?? ''
        : '';
    return ProductSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      imageUrl: imageUrl,
      price: (json['price'] as num).toDouble(),
      comparePrice: json['comparePrice'] != null ? (json['comparePrice'] as num).toDouble() : null,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }
}
