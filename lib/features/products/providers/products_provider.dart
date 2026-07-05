import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/product_model.dart';

class ProductsFilter {
  final String? category;
  final String? search;
  final String sortBy;
  final double? minPrice;
  final double? maxPrice;
  final int page;

  const ProductsFilter({
    this.category,
    this.search,
    this.sortBy = 'newest',
    this.minPrice,
    this.maxPrice,
    this.page = 1,
  });

  ProductsFilter copyWith({
    String? category,
    String? search,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    int? page,
  }) =>
      ProductsFilter(
        category: category ?? this.category,
        search: search ?? this.search,
        sortBy: sortBy ?? this.sortBy,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        page: page ?? this.page,
      );
}

class ProductsResult {
  final List<ProductSummary> products;
  final int total;
  final int totalPages;

  const ProductsResult({required this.products, required this.total, required this.totalPages});
}

final productsFilterProvider = StateProvider<ProductsFilter>((ref) => const ProductsFilter());

final productsProvider = FutureProvider.autoDispose<ProductsResult>((ref) async {
  final filter = ref.watch(productsFilterProvider);
  final client = ref.read(dioClientProvider);

  final params = <String, dynamic>{
    'page': filter.page,
    'limit': 20,
    'sortBy': filter.sortBy,
    if (filter.category != null) 'category': filter.category,
    if (filter.search != null) 'search': filter.search,
    if (filter.minPrice != null) 'minPrice': filter.minPrice,
    if (filter.maxPrice != null) 'maxPrice': filter.maxPrice,
  };

  final res = await client.dio.get('/products', queryParameters: params);
  final data = res.data as Map<String, dynamic>;
  return ProductsResult(
    products: (data['products'] as List)
        .map((e) => ProductSummary.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: data['total'] as int? ?? 0,
    totalPages: data['totalPages'] as int? ?? 1,
  );
});

final productDetailProvider = FutureProvider.autoDispose.family<ProductDetail, String>((ref, slug) async {
  final client = ref.read(dioClientProvider);
  final res = await client.dio.get('/mobile/products/$slug');
  return ProductDetail.fromJson(res.data['product'] as Map<String, dynamic>);
});

final searchSuggestionsProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
  if (query.length < 2) return [];
  final client = ref.read(dioClientProvider);
  final res = await client.dio.get('/search', queryParameters: {'q': query});
  return (res.data as List).map((e) => e.toString()).toList();
});
