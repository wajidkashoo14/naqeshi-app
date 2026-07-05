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
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    final current = ref.read(productsFilterProvider);
    ref.read(productsFilterProvider.notifier).state = current.copyWith(search: value, page: 1);
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
        title: Text(widget.category ?? 'All Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: _onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (result) {
          if (result.products.isEmpty) {
            return const Center(child: Text('No products found'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: result.products.length,
            itemBuilder: (_, i) => ProductCard(product: result.products[i]),
          );
        },
      ),
    );
  }
}
