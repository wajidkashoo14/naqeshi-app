import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/address_model.dart';

final addressesProvider = AsyncNotifierProvider<AddressesNotifier, List<AddressModel>>(() => AddressesNotifier());

class AddressesNotifier extends AsyncNotifier<List<AddressModel>> {
  late DioClient _client;

  @override
  Future<List<AddressModel>> build() async {
    _client = ref.read(dioClientProvider);
    return _fetch();
  }

  Future<List<AddressModel>> _fetch() async {
    final res = await _client.dio.get('/mobile/addresses');
    return (res.data['addresses'] as List)
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(Map<String, dynamic> data) async {
    await _client.dio.post('/mobile/addresses', data: data);
    state = AsyncData(await _fetch());
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _client.dio.patch('/mobile/addresses', data: {'id': id, ...data});
    state = AsyncData(await _fetch());
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/mobile/addresses', data: {'id': id});
    state = AsyncData(await _fetch());
  }
}
