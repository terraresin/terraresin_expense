import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/accounts/account_providers.dart';
import '../../providers/accounts/bank_balance_providers.dart';
import '../../providers/categories/category_providers.dart';
import '../../providers/founders/founder_providers.dart';
import '../../providers/transactions/transaction_providers.dart';

class TransactionFormDialog extends ConsumerStatefulWidget {
  const TransactionFormDialog({super.key, this.transaction});

  final Map<String, dynamic>? transaction;

  @override
  ConsumerState<TransactionFormDialog> createState() =>
      _TransactionFormDialogState();
}

class _TransactionFormDialogState extends ConsumerState<TransactionFormDialog> {
  static const paymentTypes = [
    'bank_transfer',
    'cash',
    'cheque',
    'founder_paid_cash',
    'founder_paid_netbanking',
    'founder_paid_upi',
  ];

  static const paymentTypeLabels = {
    'bank_transfer': 'Bank Transfer',
    'cash': 'Cash',
    'cheque': 'Cheque',
    'founder_paid_cash': 'Founder Paid Cash',
    'founder_paid_netbanking': 'Founder Paid NetBanking',
    'founder_paid_upi': 'Founder Paid UPI',
  };

  static const founderPaidCategoryNames = {
    'Founder Paid Cash',
    'Founder Paid NetBanking',
    'Founder Paid UPI',
    'Founder Paid Cash or NetBanking or UPI',
  };

  static const chequeIssuerBanks = ['PNB', 'Axis Bank'];

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _partyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _chequeNumberController = TextEditingController();
  final _chequeIssuerBankController = TextEditingController();

  String _transactionType = 'company_expense';
  String _direction = 'debit';
  String _paymentType = 'bank_transfer';
  String? _accountId;
  String? _categoryId;
  String? _founderId;
  String _categoryName = '';
  String _categoryType = '';
  String _categoryDescription = '';
  bool _requiresFounder = false;
  DateTime _transactionDate = DateTime.now();
  DateTime? _chequeDate;
  bool _isLoading = false;

  bool get isEditing => widget.transaction != null;
  bool get isCash => _paymentType == 'cash';
  bool get isCheque => _paymentType == 'cheque';
  bool get _isFounderPaid =>
      _paymentType.startsWith('founder_paid_') ||
      founderPaidCategoryNames.contains(_categoryName);
  bool get _requiresFounderSelection => _requiresFounder || _isFounderPaid;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction == null) return;

    _amountController.text = '${transaction['amount'] ?? ''}';
    _partyController.text = transaction['party_name'] as String? ?? '';
    _descriptionController.text = transaction['description'] as String? ?? '';
    _chequeNumberController.text =
        transaction['cheque_number'] as String? ?? '';
    _chequeIssuerBankController.text =
        transaction['cheque_issuer_bank'] as String? ?? '';
    if (transaction['cheque_date'] != null) {
      _chequeDate = DateTime.tryParse('${transaction['cheque_date']}');
    }
    _transactionType =
        transaction['transaction_type'] as String? ?? _transactionType;
    _direction = transaction['direction'] as String? ?? _direction;
    _paymentType = transaction['payment_method'] as String? ?? _paymentType;
    _accountId = transaction['account_id'] as String?;
    _categoryId = transaction['category_id'] as String?;
    _founderId = transaction['founder_id'] as String?;
    final category = transaction['categories'];
    if (category is Map) {
      final categoryName = category['name'] as String? ?? '';
      _categoryName = categoryName;
      _categoryType = category['category_type'] as String? ?? '';
      _categoryDescription = category['description'] as String? ?? '';
      _requiresFounder = categoryName.startsWith('Founder ');
    }
    _transactionDate =
        DateTime.tryParse(transaction['transaction_date'] as String? ?? '') ??
        DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _partyController.dispose();
    _descriptionController.dispose();
    _chequeNumberController.dispose();
    _chequeIssuerBankController.dispose();
    super.dispose();
  }

  String _dateValue(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _label(String value) => value
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');

  Future<void> _selectTransactionDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) {
      setState(() => _transactionDate = selected);
    }
  }

  Future<void> _selectChequeDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _chequeDate ?? _transactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) {
      setState(() => _chequeDate = selected);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    if (_categoryId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      String? founderPartyName;
      if (_requiresFounderSelection && _founderId != null) {
        final founders = await ref.read(foundersProvider.future);
        final founder = founders
            .where((item) => item['id'] == _founderId)
            .first;
        founderPartyName = founder['name'] as String? ?? '';
        if (!_isFounderPaid) _partyController.text = founderPartyName;
      }

      final data = <String, dynamic>{
        'transaction_date': _dateValue(_transactionDate),
        'transaction_type': _transactionType,
        'amount': double.parse(_amountController.text.trim()),
        'description': _descriptionController.text.trim(),
        'account_id': isCash || _isFounderPaid ? null : _accountId,
        'payment_method': _paymentType,
        'direction': _direction,
        'party_name': _partyController.text.trim(),
        'category_id': _categoryId,
        'founder_id': _requiresFounderSelection ? _founderId : null,
        'project_id': null,
        'cheque_number': null,
        'cheque_date': null,
        'reference_number': _isFounderPaid && !isEditing
            ? 'founder-paid-${DateTime.now().microsecondsSinceEpoch}'
            : widget.transaction?['reference_number'],
        'notes': null,
      };

      if (isCheque) {
        data['cheque_number'] = _chequeNumberController.text.trim();
        data['cheque_date'] = _chequeDate == null
            ? null
            : _dateValue(_chequeDate!);
        data['cheque_issuer_bank'] = _chequeIssuerBankController.text.trim();
      }

      final repository = ref.read(transactionRepositoryProvider);
      if (isEditing) {
        await repository.updateTransaction(
          widget.transaction!['id'] as String,
          data,
        );
      } else if (_isFounderPaid) {
        await repository.createTransactionPair(
          debit: data,
          credit: {
            'transaction_date': data['transaction_date'],
            'transaction_type': 'founder_contribution',
            'amount': data['amount'],
            'description': 'Founder investment for ${data['description']}',
            'account_id': null,
            'payment_method': _paymentType,
            'direction': 'credit',
            'party_name': founderPartyName ?? data['party_name'],
            'category_id': data['category_id'],
            'founder_id': _founderId,
            'project_id': null,
            'cheque_number': null,
            'cheque_date': null,
            'reference_number': data['reference_number'],
            'notes': 'Linked founder-paid investment',
          },
        );
      } else {
        await repository.createTransaction(data);
      }
      ref.invalidate(transactionsProvider);
      ref.invalidate(companyBankBalancesProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save transaction: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'This permanently deletes the transaction. Founder-paid transactions delete both the investment credit and purchase debit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final repository = ref.read(transactionRepositoryProvider);
      final referenceNumber =
          widget.transaction!['reference_number'] as String?;
      if (referenceNumber?.startsWith('founder-paid-') == true) {
        await repository.deleteTransactionPair(referenceNumber!);
      } else {
        await repository.deleteTransaction(widget.transaction!['id'] as String);
      }
      ref.invalidate(transactionsProvider);
      ref.invalidate(companyBankBalancesProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete transaction: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(companyBankAccountsProvider);
    final categories = ref.watch(categoriesProvider);
    final founders = ref.watch(foundersProvider);
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
        isEditing ? 'Edit Transaction' : 'Add Transaction',
        style: isPhone ? const TextStyle(fontSize: 26) : null,
      ),
      content: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _fieldRow([
                  _dateField(),
                  categories.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (error, stack) =>
                        Text('Unable to load categories: $error'),
                    data: _categoryAutocomplete,
                  ),
                ]),
                if (_categoryId != null)
                  _fieldRow([
                    _readOnlyField('Type', _categoryType),
                    _readOnlyField(
                      'Category Description',
                      _categoryDescription,
                      maxLines: 2,
                    ),
                  ]),
                if (!_isFounderPaid)
                  _fieldRow([
                    _textField(
                      controller: _amountController,
                      label: 'Amount*',
                      numeric: true,
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? '');
                        return amount == null || amount <= 0
                            ? 'Enter a valid amount'
                            : null;
                      },
                    ),
                    _dropdownField<String>(
                      label: 'Debit / Credit*',
                      value: _direction,
                      items: const ['debit', 'credit'],
                      onChanged: (value) => setState(() => _direction = value!),
                    ),
                  ]),
                _fieldRow([
                  if (_isFounderPaid)
                    _readOnlyField('Bank Account', 'Personal bank account')
                  else if (isCash)
                    _readOnlyField('Bank Account', 'Cash')
                  else
                    accounts.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (error, stack) =>
                          Text('Unable to load bank accounts: $error'),
                      data: (items) => _dropdownField<String>(
                        label: 'Bank Account',
                        value: _accountId ?? '',
                        items: [
                          '',
                          ...items.map((item) => item['id'] as String),
                        ],
                        itemLabels: {
                          '': 'Select bank account',
                          for (final item in items)
                            item['id'] as String:
                                item['name'] as String? ?? 'Bank',
                        },
                        onChanged: (value) => setState(
                          () => _accountId = value?.isEmpty == true
                              ? null
                              : value,
                        ),
                      ),
                    ),
                  _dropdownField<String>(
                    label: 'Payment Type*',
                    value: _paymentType,
                    items: paymentTypes,
                    itemLabels: paymentTypeLabels,
                    onChanged: (value) => setState(() {
                      _paymentType = value!;
                      if (_isFounderPaid) _direction = 'debit';
                    }),
                  ),
                ]),
                _fieldRow([
                  _requiresFounderSelection
                      ? founders.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (error, stack) =>
                              Text('Unable to load founders: $error'),
                          data: (items) => _dropdownField<String>(
                            label: 'Founder*',
                            value: _founderId ?? '',
                            items: [
                              '',
                              ...items.map((item) => item['id'] as String),
                            ],
                            itemLabels: {
                              '': 'Select founder',
                              for (final item in items)
                                item['id'] as String:
                                    item['name'] as String? ?? 'Founder',
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? 'Select a founder'
                                : null,
                            onChanged: (value) => setState(
                              () => _founderId = value?.isEmpty == true
                                  ? null
                                  : value,
                            ),
                          ),
                        )
                      : _textField(
                          controller: _partyController,
                          label: 'Party',
                        ),
                ]),
                if (_isFounderPaid)
                  _fieldRow([
                    _textField(
                      controller: _partyController,
                      label: 'Party for Debit*',
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter the party paid by the founder'
                          : null,
                    ),
                    _textField(
                      controller: _amountController,
                      label: 'Amount*',
                      numeric: true,
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? '');
                        return amount == null || amount <= 0
                            ? 'Enter a valid amount'
                            : null;
                      },
                    ),
                  ]),
                if (isCheque)
                  _fieldRow([
                    _textField(
                      controller: _chequeNumberController,
                      label: 'Cheque Number*',
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Cheque number is required'
                          : null,
                    ),
                    _chequeDateField(),
                    _dropdownField<String>(
                      label: 'Cheque Issuer Bank*',
                      value: _chequeIssuerBankController.text,
                      items: const ['', ...chequeIssuerBanks],
                      itemLabels: const {
                        '': 'Select bank',
                        'PNB': 'PNB',
                        'Axis Bank': 'Axis Bank',
                      },
                      onChanged: (value) => setState(
                        () => _chequeIssuerBankController.text = value ?? '',
                      ),
                    ),
                  ]),
                _fieldRow([
                  _textField(
                    controller: _descriptionController,
                    label: 'Description* (maximum 50 words)',
                    maxLines: 5,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Description is required';
                      if (_wordCount(text) > 50) {
                        return 'Description cannot exceed 50 words';
                      }
                      return null;
                    },
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (isEditing)
          TextButton.icon(
            onPressed: _isLoading ? null : _delete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  Widget _fieldRow(List<Widget> fields) {
    final isCompact = MediaQuery.sizeOf(context).width < 600;

    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? 8 : 16),
      child: Flex(
        direction: isCompact ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields
            .map(
              (field) => isCompact
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: field,
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: field,
                      ),
                    ),
            )
            .toList(),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    bool numeric = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }

  int _wordCount(String value) {
    return value.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  String _transactionTypeFor(String categoryName) {
    return switch (categoryName) {
      'Founder Contribution' => 'founder_contribution',
      'Founder Reimbursement' => 'reimbursement',
      'Founder Personal Expense' => 'personal_expense',
      'Cash Withdrawal' => 'bank_withdrawal',
      _ => 'company_expense',
    };
  }

  String _directionFor(String categoryName, String categoryType) {
    if (categoryName == 'Founder Contribution') return 'credit';
    if (categoryType == 'Income/Contribution') return 'credit';
    return 'debit';
  }

  Widget _categoryAutocomplete(List<Map<String, dynamic>> categories) {
    final selected = categories
        .where((category) => category['id'] == _categoryId)
        .firstOrNull;

    return Autocomplete<Map<String, dynamic>>(
      initialValue: TextEditingValue(text: selected?['name'] as String? ?? ''),
      displayStringForOption: (category) => category['name'] as String? ?? '',
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.length < 2) return categories;

        return categories.where((category) {
          final name = (category['name'] as String? ?? '').toLowerCase();
          final description = (category['description'] as String? ?? '')
              .toLowerCase();
          return name.contains(query) || description.contains(query);
        });
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 600
                  ? MediaQuery.sizeOf(context).width - 88
                  : 500,
              height: 320,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  final name = option['name'] as String? ?? '';
                  final description = option['description'] as String? ?? '';
                  return ListTile(
                    dense: true,
                    title: Text(name),
                    subtitle: description.isEmpty ? null : Text(description),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: _selectCategory,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Category Name*',
            hintText: 'Select or type at least 2 letters to search',
            suffixIcon: IconButton(
              tooltip: 'View all categories',
              icon: const Icon(Icons.arrow_drop_down),
              onPressed: () {
                controller.clear();
                if (_categoryId != null) setState(_clearCategory);
                focusNode.requestFocus();
              },
            ),
          ),
          validator: (value) => _categoryId == null
              ? 'Select a category from the suggestions'
              : null,
          onChanged: (value) {
            final selectedName = selected?['name'] as String? ?? '';
            if (_categoryId != null && value != selectedName) {
              setState(_clearCategory);
            }
          },
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }

  void _selectCategory(Map<String, dynamic> category) {
    final name = category['name'] as String? ?? '';
    setState(() {
      _categoryId = category['id'] as String?;
      _categoryName = name;
      _categoryType = category['category_type'] as String? ?? '';
      _categoryDescription = category['description'] as String? ?? '';
      _requiresFounder = name.startsWith('Founder ');
      if (!_requiresFounderSelection) _founderId = null;
      _transactionType = _transactionTypeFor(name);
      _direction = _isFounderPaid
          ? 'debit'
          : _directionFor(name, _categoryType);
    });
  }

  void _clearCategory() {
    _categoryId = null;
    _categoryName = '';
    _categoryType = '';
    _categoryDescription = '';
    _requiresFounder = false;
    if (!_isFounderPaid) _founderId = null;
  }

  Widget _readOnlyField(String label, String value, {int maxLines = 1}) {
    return TextFormField(
      key: ValueKey('$label:$value'),
      initialValue: value,
      readOnly: true,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _dateField() {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: _dateValue(_transactionDate)),
      decoration: const InputDecoration(
        labelText: 'Date*',
        suffixIcon: Icon(Icons.calendar_today_outlined),
      ),
      onTap: _selectTransactionDate,
    );
  }

  Widget _chequeDateField() {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: _chequeDate == null ? '' : _dateValue(_chequeDate!),
      ),
      decoration: const InputDecoration(
        labelText: 'Cheque Date*',
        suffixIcon: Icon(Icons.calendar_today_outlined),
      ),
      onTap: _selectChequeDate,
      validator: (value) => _chequeDate == null ? 'Select cheque date' : null,
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    Map<T, String>? itemLabels,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: items.contains(value) ? value : items.first,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabels?[item] ?? _label('$item'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
