import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/order_model.dart';

final ordersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final client = ref.read(dioClientProvider);
  final res = await client.dio.get('/mobile/orders');
  return (res.data['orders'] as List)
      .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

final orderDetailProvider = FutureProvider.autoDispose.family<OrderModel, String>((ref, id) async {
  final client = ref.read(dioClientProvider);
  final res = await client.dio.get('/mobile/orders/$id');
  return OrderModel.fromJson(res.data['order'] as Map<String, dynamic>);
});
