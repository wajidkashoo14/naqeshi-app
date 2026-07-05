class OrderItemModel {
  final String id;
  final String productId;
  final String name;
  final String image;
  final int quantity;
  final double price;
  final double total;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'] as String,
        productId: json['productId'] as String? ?? '',
        name: json['name'] as String,
        image: json['image'] as String? ?? '',
        quantity: json['quantity'] as int,
        price: (json['price'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
      );
}

class OrderTimeline {
  final String status;
  final String message;
  final DateTime createdAt;

  const OrderTimeline({required this.status, required this.message, required this.createdAt});

  factory OrderTimeline.fromJson(Map<String, dynamic> json) => OrderTimeline(
        status: json['status'] as String,
        message: json['message'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final double total;
  final String currency;
  final String? trackingNumber;
  final String? trackingUrl;
  final DateTime? estimatedDelivery;
  final DateTime createdAt;
  final List<OrderItemModel> items;
  final List<OrderTimeline> timeline;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.total,
    required this.currency,
    this.trackingNumber,
    this.trackingUrl,
    this.estimatedDelivery,
    required this.createdAt,
    required this.items,
    required this.timeline,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        orderNumber: json['orderNumber'] as String,
        status: json['status'] as String,
        paymentStatus: json['paymentStatus'] as String,
        paymentMethod: json['paymentMethod'] as String?,
        total: (json['total'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'INR',
        trackingNumber: json['trackingNumber'] as String?,
        trackingUrl: json['trackingUrl'] as String?,
        estimatedDelivery: json['estimatedDelivery'] != null
            ? DateTime.parse(json['estimatedDelivery'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        items: (json['items'] as List?)
                ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        timeline: (json['timeline'] as List?)
                ?.map((e) => OrderTimeline.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
