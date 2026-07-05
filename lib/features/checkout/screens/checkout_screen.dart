import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/addresses_provider.dart';
import '../models/address_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_button.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddressId;
  String _paymentMethod = 'RAZORPAY';
  final _couponCtrl = TextEditingController();
  bool _isLoading = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _couponCtrl.dispose();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    final orderId = response.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;
    if (orderId == null || paymentId == null || signature == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incomplete payment response. Contact support.')),
      );
      return;
    }
    final client = ref.read(dioClientProvider);
    try {
      final res = await client.dio.post('/mobile/checkout/verify', data: {
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
      });
      ref.read(cartProvider.notifier).clear();
      if (mounted) context.go('/order-confirmation/${res.data['orderId']}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment verification failed: $e')),
        );
      }
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a delivery address')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final client = ref.read(dioClientProvider);
      final res = await client.dio.post('/mobile/checkout', data: {
        'addressId': _selectedAddressId,
        'paymentMethod': _paymentMethod,
        if (_couponCtrl.text.isNotEmpty) 'couponCode': _couponCtrl.text.trim(),
      });

      if (_paymentMethod == 'COD') {
        ref.read(cartProvider.notifier).clear();
        if (mounted) context.go('/order-confirmation/${res.data['orderId']}');
      } else {
        // Open Razorpay SDK
        _razorpay.open({
          'key': res.data['keyId'],
          'amount': res.data['amount'],
          'currency': res.data['currency'],
          'order_id': res.data['razorpayOrderId'],
          'name': 'Naqeshi',
          'description': 'Authentic Kashmiri Handicrafts',
          'theme': {'color': '#C2A14E'},
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(addressesProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final shipping = cartTotal >= 999 ? 0.0 : 99.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Delivery Address', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          addressesAsync.when(
            loading: () => const CircularProgressIndicator(color: AppColors.gold),
            error: (e, _) => Text('Error loading addresses: $e'),
            data: (addresses) {
              if (addresses.isEmpty) {
                return OutlinedButton.icon(
                  onPressed: () => context.push('/profile/addresses'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Address'),
                );
              }
              // Auto-select default
              if (_selectedAddressId == null) {
                final def = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
                _selectedAddressId = def.id;
              }
              return Column(
                children: [
                  ...addresses.map((a) => _AddressTile(
                        address: a,
                        selected: _selectedAddressId == a.id,
                        onTap: () => setState(() => _selectedAddressId = a.id),
                      )),
                  TextButton.icon(
                    onPressed: () => context.push('/profile/addresses'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Payment Method', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _PaymentOption(
            label: 'Pay Online (Razorpay)',
            value: 'RAZORPAY',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
          _PaymentOption(
            label: 'Cash on Delivery',
            value: 'COD',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
          const SizedBox(height: 24),
          Text('Coupon Code', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _couponCtrl,
            decoration: const InputDecoration(hintText: 'Enter coupon code (optional)'),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _SummaryRow('Subtotal', '₹${cartTotal.toStringAsFixed(0)}'),
              const SizedBox(height: 6),
              _SummaryRow('Shipping', shipping == 0 ? 'Free' : '₹${shipping.toStringAsFixed(0)}'),
              const Divider(height: 20),
              _SummaryRow('Total', '₹${(cartTotal + shipping).toStringAsFixed(0)}', bold: true),
            ]),
          ),
          const SizedBox(height: 24),
          LoadingButton(label: 'Place Order', isLoading: _isLoading, onPressed: _placeOrder),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final AddressModel address;
  final bool selected;
  final VoidCallback onTap;

  const _AddressTile({required this.address, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withOpacity(0.1) : AppColors.beige,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.gold : Colors.transparent),
        ),
        child: Row(children: [
          Radio<bool>(value: true, groupValue: selected, onChanged: (_) => onTap(), activeColor: AppColors.gold),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(address.fullName, style: Theme.of(context).textTheme.titleMedium),
              Text(address.displayLine, style: Theme.of(context).textTheme.bodySmall),
              Text(address.phone, style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({required this.label, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      activeColor: AppColors.gold,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style?.copyWith(color: AppColors.gold))],
    );
  }
}
