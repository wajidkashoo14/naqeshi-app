import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../checkout/providers/addresses_provider.dart';
import '../../checkout/models/address_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_button.dart';

// ignore_for_file: use_build_context_synchronously

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Addresses')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.white,
        onPressed: () => _showAddressForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
      body: addressesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (addresses) {
          if (addresses.isEmpty) {
            return const Center(child: Text('No addresses saved. Add one!'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _AddressTile(
              address: addresses[i],
              onEdit: () => _showAddressForm(context, ref, address: addresses[i]),
              onDelete: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Address'),
                    content: const Text('Are you sure?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(addressesProvider.notifier).delete(addresses[i].id);
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddressForm(BuildContext context, WidgetRef ref, {AddressModel? address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.ivory,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (_) => _AddressForm(address: address),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressTile({required this.address, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: AppColors.beige),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.location_on_outlined, color: AppColors.gold, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(address.fullName, style: Theme.of(context).textTheme.titleMedium),
              if (address.isDefault) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.2)),
                  child: Text('Default', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gold)),
                ),
              ],
            ]),
            const SizedBox(height: 4),
            Text(address.displayLine, style: Theme.of(context).textTheme.bodySmall),
            Text(address.phone, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        PopupMenuButton<String>(
          onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          icon: const Icon(Icons.more_vert, color: AppColors.muted),
        ),
      ]),
    );
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  final AddressModel? address;
  const _AddressForm({this.address});

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final _form = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.address?.fullName ?? '');
  late final _phoneCtrl = TextEditingController(text: widget.address?.phone ?? '');
  late final _line1Ctrl = TextEditingController(text: widget.address?.line1 ?? '');
  late final _line2Ctrl = TextEditingController(text: widget.address?.line2 ?? '');
  late final _cityCtrl = TextEditingController(text: widget.address?.city ?? '');
  late final _stateCtrl = TextEditingController(text: widget.address?.state ?? '');
  late final _postalCtrl = TextEditingController(text: widget.address?.postalCode ?? '');
  late final _countryCtrl = TextEditingController(text: widget.address?.country ?? 'India');
  bool _isDefault = widget.address?.isDefault ?? false;
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _line1Ctrl, _line2Ctrl, _cityCtrl, _stateCtrl, _postalCtrl, _countryCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = {
        'fullName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'line1': _line1Ctrl.text.trim(),
        'line2': _line2Ctrl.text.trim().isEmpty ? null : _line2Ctrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'postalCode': _postalCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'isDefault': _isDefault,
      };
      if (widget.address != null) {
        await ref.read(addressesProvider.notifier).update(widget.address!.id, data);
      } else {
        await ref.read(addressesProvider.notifier).add(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget field(TextEditingController ctrl, String label, {bool required = true, TextInputType? type}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(labelText: label),
          validator: required ? (v) => v == null || v.trim().isEmpty ? '$label is required' : null : null,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.address != null ? 'Edit Address' : 'New Address',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          field(_nameCtrl, 'Full Name'),
          field(_phoneCtrl, 'Phone', type: TextInputType.phone),
          field(_line1Ctrl, 'Address Line 1'),
          field(_line2Ctrl, 'Address Line 2', required: false),
          field(_cityCtrl, 'City'),
          field(_stateCtrl, 'State'),
          field(_postalCtrl, 'Postal Code', type: TextInputType.number),
          field(_countryCtrl, 'Country'),
          SwitchListTile(
            value: _isDefault,
            onChanged: (v) => setState(() => _isDefault = v),
            title: const Text('Set as default'),
            activeColor: AppColors.gold,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          LoadingButton(label: 'Save Address', isLoading: _isLoading, onPressed: _save),
        ]),
      ),
    );
  }
}
