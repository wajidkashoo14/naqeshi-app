import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/wishlist_item_model.dart';

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, List<WishlistItemModel>>(() => WishlistNotifier());

final isWishlistedProvider = Provider.family<bool, String>((ref, productId) {
  final items = ref.watch(wishlistProvider).valueOrNull ?? [];
  return items.any((i) => i.product.id == productId);
});

class WishlistNotifier extends AsyncNotifier<List<WishlistItemModel>> {
  late DioClient _client;

  @override
  Future<List<WishlistItemModel>> build() async {
    _client = ref.read(dioClientProvider);
    return _fetch();
  }

  Future<List<WishlistItemModel>> _fetch() async {
    final res = await _client.dio.get('/mobile/wishlist');
    return (res.data['items'] as List)
        .map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> toggle(String productId) async {
    await _client.dio.post('/mobile/wishlist', data: {'productId': productId});
    state = AsyncData(await _fetch());
  }
}
