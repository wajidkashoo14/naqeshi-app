import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/cart_item_model.dart';

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItemModel>>(() => CartNotifier());

final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider).valueOrNull ?? [];
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider).valueOrNull ?? [];
  return cart.fold(0.0, (sum, item) => sum + item.total);
});

class CartNotifier extends AsyncNotifier<List<CartItemModel>> {
  late DioClient _client;

  @override
  Future<List<CartItemModel>> build() async {
    _client = ref.read(dioClientProvider);
    return _fetchCart();
  }

  Future<List<CartItemModel>> _fetchCart() async {
    final res = await _client.dio.get('/mobile/cart');
    return (res.data['items'] as List)
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addItem({required String productId, String? variantId, int quantity = 1}) async {
    await _client.dio.post('/mobile/cart', data: {
      'productId': productId,
      if (variantId != null) 'variantId': variantId,
      'quantity': quantity,
    });
    state = AsyncData(await _fetchCart());
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    await _client.dio.patch('/mobile/cart/update', data: {'itemId': itemId, 'quantity': quantity});
    state = AsyncData(await _fetchCart());
  }

  Future<void> removeItem(String itemId) async {
    await _client.dio.delete('/mobile/cart/remove', data: {'itemId': itemId});
    state = AsyncData(await _fetchCart());
  }

  Future<void> toggleGiftWrap(String itemId, bool giftWrap) async {
    await _client.dio.patch('/mobile/cart/update', data: {'itemId': itemId, 'giftWrap': giftWrap});
    state = AsyncData(await _fetchCart());
  }

  void clear() => state = const AsyncData([]);
}
