import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/orders_provider.dart';
import '../models/order_model.dart';
import '../../../core/theme/app_theme.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.muted),
                const SizedBox(height: 16),
                Text('No orders yet', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                TextButton(onPressed: () => context.go('/products'), child: const Text('Start shopping')),
              ]),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _OrderTile(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderModel order;
  const _OrderTile({required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'DELIVERED': return AppColors.success;
      case 'CANCELLED': return AppColors.error;
      case 'SHIPPED':
      case 'OUT_FOR_DELIVERY': return AppColors.copper;
      default: return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(order.orderNumber, style: Theme.of(context).textTheme.titleMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                order.status.replaceAll('_', ' '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _statusColor(order.status), fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Text('${order.items.length} item${order.items.length > 1 ? 's' : ''}  •  ₹${order.total.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(DateFormat('d MMM yyyy').format(order.createdAt), style: Theme.of(context).textTheme.bodySmall),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(order.items.map((i) => i.name).take(2).join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
          ],
        ]),
      ),
    );
  }
}
