class CartItemModel {
  final String id;
  final String productId;
  final String? variantId;
  final int quantity;
  final bool giftWrap;
  final String? giftMessage;
  final CartProduct product;
  final CartVariant? variant;

  const CartItemModel({
    required this.id,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.giftWrap,
    this.giftMessage,
    required this.product,
    this.variant,
  });

  double get unitPrice => variant?.price ?? product.price;
  double get total => unitPrice * quantity;
  String get name => product.name;
  String get imageUrl => product.imageUrl;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final p = json['product'] as Map<String, dynamic>;
    final v = json['variant'] as Map<String, dynamic>?;
    return CartItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      variantId: json['variantId'] as String?,
      quantity: json['quantity'] as int,
      giftWrap: json['giftWrap'] as bool? ?? false,
      giftMessage: json['giftMessage'] as String?,
      product: CartProduct.fromJson(p),
      variant: v != null ? CartVariant.fromJson(v) : null,
    );
  }
}

class CartProduct {
  final String id;
  final String name;
  final String slug;
  final double price;
  final String imageUrl;

  const CartProduct({required this.id, required this.name, required this.slug, required this.price, required this.imageUrl});

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    final url = images != null && images.isNotEmpty
        ? (images[0] as Map<String, dynamic>)['url'] as String? ?? ''
        : '';
    return CartProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: url,
    );
  }
}

class CartVariant {
  final String id;
  final String name;
  final double price;
  final int stock;

  const CartVariant({required this.id, required this.name, required this.price, required this.stock});

  factory CartVariant.fromJson(Map<String, dynamic> json) => CartVariant(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        stock: json['stock'] as int? ?? 0,
      );
}
