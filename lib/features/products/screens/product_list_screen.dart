import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../core/theme/app_theme.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String? category;
  final String? search;

  const ProductListScreen({super.key, this.category, this.search});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsFilterProvider.notifier).state = ProductsFilter(
        category: widget.category,
        search: widget.search,
      );
      if (widget.search != null) _searchCtrl.text = widget.search!;
    });
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      final result = ref.read(productsProvider).valueOrNull;
      final filter = ref.read(productsFilterProvider);
      if (result != null && filter.page < result.totalPages) {
        ref.read(productsFilterProvider.notifier).state = filter.copyWith(page: filter.page + 1);
      }
    }
  }

  void _onSearch(String value) {
    ref.read(productsFilterProvider.notifier).state = ProductsFilter(
      category: ref.read(productsFilterProvider).category,
      search: value.isEmpty ? null : value,
      sortBy: ref.read(productsFilterProvider).sortBy,
    );
  }

  void _onSort(String? value) {
    if (value == null) return;
    final current = ref.read(productsFilterProvider);
    ref.read(productsFilterProvider.notifier).state = current.copyWith(sortBy: value, page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(productsFilterProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null
            ? widget.category![0].toUpperCase() + widget.category!.substring(1)
            : 'All Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: _onSearch,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: filter.sortBy,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('Newest')),
                  DropdownMenuItem(value: 'price_asc', child: Text('Price ↑')),
                  DropdownMenuItem(value: 'price_desc', child: Text('Price ↓')),
                ],
                onChanged: _onSort,
              ),
            ]),
          ),
        ),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.muted),
            const SizedBox(height: 12),
            Text('Could not load products', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.refresh(productsProvider),
              child: const Text('Retry'),
            ),
          ]),
        ),
        data: (result) {
          if (result.products.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.search_off, size: 48, color: AppColors.muted),
                const SizedBox(height: 12),
                Text('No products found', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_searchCtrl.text.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      _onSearch('');
                    },
                    child: const Text('Clear search'),
                  ),
              ]),
            );
          }
          return GridView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: result.products.length + (filter.page < result.totalPages ? 1 : 0),
            itemBuilder: (_, i) {
              if (i >= result.products.length) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.gold),
                ));
              }
              return ProductCard(product: result.products[i]);
            },
          );
        },
      ),
    );
  }
}
