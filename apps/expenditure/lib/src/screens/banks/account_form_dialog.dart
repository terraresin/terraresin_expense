import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/accounts/account_providers.dart';
import '../../providers/accounts/bank_balance_providers.dart';

class AccountFormDialog extends ConsumerStatefulWidget {
  const AccountFormDialog({super.key, this.account});

  final Map<String, dynamic>? account;

  @override
  ConsumerState<AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends ConsumerState<AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _openingBalanceController;

  String _selectedOwner = 'company';
  bool _isLoading = false;

  bool get isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.account?['name'] as String? ?? '',
    );
    _bankNameController = TextEditingController(
      text: widget.account?['bank_name'] as String? ?? '',
    );
    _accountNumberController = TextEditingController(
      text: widget.account?['account_number'] as String? ?? '',
    );
    _openingBalanceController = TextEditingController(
      text: widget.account?['opening_balance'] != null
          ? (widget.account!['opening_balance'] as num).toString()
          : '0.0',
    );
    _selectedOwner = widget.account?['owner'] as String? ?? 'company';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final repository = ref.read(accountRepositoryProvider);
    final accountData = {
      'name': _nameController.text.trim(),
      'bank_name': _bankNameController.text.trim(),
      'account_number': _accountNumberController.text.trim(),
      'opening_balance': double.tryParse(_openingBalanceController.text) ?? 0.0,
      'owner': _selectedOwner,
      'account_type': 'bank',
      'is_active': true,
    };

    try {
      if (isEditing) {
        await repository.updateAccount(
          widget.account!['id'] as String,
          accountData,
        );
      } else {
        await repository.createAccount(accountData);
      }
      ref.invalidate(companyBankAccountsProvider);
      ref.invalidate(companyBankBalancesProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save account: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 600;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isPhone ? 12 : 40,
        vertical: isPhone ? 16 : 24,
      ),
      titlePadding: EdgeInsets.fromLTRB(
        isPhone ? 20 : 24,
        isPhone ? 20 : 24,
        isPhone ? 20 : 24,
        8,
      ),
      contentPadding: EdgeInsets.fromLTRB(
        isPhone ? 20 : 24,
        0,
        isPhone ? 20 : 24,
        8,
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        isPhone ? 20 : 24,
        0,
        isPhone ? 20 : 24,
        isPhone ? 16 : 8,
      ),
      title: Text(
        isEditing ? 'Edit Bank Account' : 'Add Bank Account',
        style: isPhone ? const TextStyle(fontSize: 26) : null,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name (e.g. HDFC Primary)',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter account name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter bank name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(labelText: 'Account Number'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter account number'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedOwner,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Account Owner'),
                items: const [
                  DropdownMenuItem(
                    value: 'company',
                    child: Text('Company', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'chaitanya',
                    child: Text('Chaitanya', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'srikanth',
                    child: Text('Srikanth', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'krishna_chaitanya',
                    child: Text(
                      'Krishna Chaitanya',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedOwner = val);
                },
              ),
              const SizedBox(height: 12),
              if (!isEditing) ...[
                TextFormField(
                  controller: _openingBalanceController,
                  decoration: const InputDecoration(
                    labelText: 'Opening Balance (₹)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) => v == null || double.tryParse(v) == null
                      ? 'Please enter valid balance'
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
