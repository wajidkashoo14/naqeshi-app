import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item_model.dart';
import '../../../shared/widgets/price_text.dart';
import '../../../core/theme/app_theme.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.muted),
                const SizedBox(height: 16),
                Text('Your cart is empty', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                TextButton(onPressed: () => context.go('/products'), child: const Text('Browse products')),
              ]),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _CartItemTile(item: items[i]),
                ),
              ),
              _CartSummary(total: cartTotal, onCheckout: () => context.push('/checkout')),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItemModel item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: item.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium),
            if (item.variant != null) ...[
              const SizedBox(height: 2),
              Text(item.variant!.name, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 6),
            PriceText(price: item.unitPrice),
            const SizedBox(height: 8),
            Row(children: [
              _QtyButton(
                icon: Icons.remove,
                onTap: () {
                  if (item.quantity > 1) {
                    ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity - 1);
                  } else {
                    ref.read(cartProvider.notifier).removeItem(item.id);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${item.quantity}', style: Theme.of(context).textTheme.titleMedium),
              ),
              _QtyButton(
                icon: Icons.add,
                onTap: () => ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity + 1),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.muted),
                onPressed: () => ref.read(cartProvider.notifier).removeItem(item.id),
              ),
            ]),
            Row(children: [
              const Icon(Icons.card_giftcard_outlined, size: 16, color: AppColors.copper),
              const SizedBox(width: 6),
              Text('Gift wrap', style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Switch.adaptive(
                value: item.giftWrap,
                activeColor: AppColors.gold,
                onChanged: (v) => ref.read(cartProvider.notifier).toggleGiftWrap(item.id, v),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.beige),
        ),
        child: Icon(icon, size: 16, color: AppColors.ink),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;
  const _CartSummary({required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final shipping = total >= 999 ? 0.0 : 99.0;
    final finalTotal = total + shipping;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _summaryRow(context, 'Subtotal', '₹${total.toStringAsFixed(0)}'),
        const SizedBox(height: 6),
        _summaryRow(context, 'Shipping', shipping == 0 ? 'Free' : '₹${shipping.toStringAsFixed(0)}'),
        const Divider(height: 20),
        _summaryRow(context, 'Total', '₹${finalTotal.toStringAsFixed(0)}', bold: true),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onCheckout,
          child: const Text('Proceed to Checkout'),
        ),
      ]),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value, {bool bold = false}) {
    final style = bold
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style?.copyWith(color: AppColors.gold))],
    );
  }
}
