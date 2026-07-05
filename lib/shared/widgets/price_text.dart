import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PriceText extends StatelessWidget {
  final double price;
  final double? comparePrice;

  const PriceText({super.key, required this.price, this.comparePrice});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = comparePrice != null && comparePrice! > price;
    return Row(
      children: [
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gold),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 6),
          Text(
            '₹${comparePrice!.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.muted,
                ),
          ),
        ],
      ],
    );
  }
}
