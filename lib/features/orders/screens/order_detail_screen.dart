import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/orders_provider.dart';
import '../models/order_model.dart';
import '../../../core/theme/app_theme.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Detail')),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (order) => _buildBody(context, order),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(order.orderNumber, style: Theme.of(context).textTheme.headlineSmall),
          _StatusChip(status: order.status),
        ]),
        const SizedBox(height: 4),
        Text('Placed ${DateFormat('d MMM yyyy, h:mm a').format(order.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall),

        // Tracking
        if (order.trackingNumber != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.local_shipping_outlined, color: AppColors.gold),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Tracking: ${order.trackingNumber}', style: Theme.of(context).textTheme.titleMedium),
                  if (order.estimatedDelivery != null)
                    Text('Est. ${DateFormat('d MMM yyyy').format(order.estimatedDelivery!)}',
                        style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
              if (order.trackingUrl != null)
                TextButton(
                  onPressed: () => launchUrl(Uri.parse(order.trackingUrl!)),
                  child: const Text('Track'),
                ),
            ]),
          ),
        ],

        const SizedBox(height: 24),
        Text('Items', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...order.items.map((item) => _OrderItemRow(item: item)),

        const SizedBox(height: 24),
        Text('Timeline', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...order.timeline.map((t) => _TimelineRow(timeline: t)),

        // Write review button for delivered orders
        if (order.status == 'DELIVERED') ...[
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              if (order.items.isNotEmpty) {
                context.push('/reviews/write/${order.items.first.productId}');
              }
            },
            icon: const Icon(Icons.star_outline),
            label: const Text('Write a Review'),
          ),
        ],
        const SizedBox(height: 40),
      ]),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get color {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(status.replaceAll('_', ' '),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItemModel item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        if (item.image.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(imageUrl: item.image, width: 56, height: 56, fit: BoxFit.cover),
          )
        else
          Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(8))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium),
            Text('Qty: ${item.quantity}  •  ₹${item.price.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        Text('₹${item.total.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gold)),
      ]),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final OrderTimeline timeline;
  const _TimelineRow({required this.timeline});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
          ),
          Container(width: 2, height: 32, color: AppColors.beige),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(timeline.status.replaceAll('_', ' '), style: Theme.of(context).textTheme.titleMedium),
            Text(timeline.message, style: Theme.of(context).textTheme.bodySmall),
            Text(DateFormat('d MMM, h:mm a').format(timeline.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
          ]),
        ),
      ]),
    );
  }
}
