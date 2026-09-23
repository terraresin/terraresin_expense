import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terraresin_design_system/design_system.dart';

import '../../formatters/currency_formatter.dart';
import '../../providers/accounts/bank_balance_providers.dart';
import '../../providers/transactions/transaction_providers.dart';
import 'transaction_form_dialog.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsFuture = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: TerraResinColors.background,
      body: transactionsFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading transactions: $error')),
        data: (transactions) {
          final latestTransactions = [...transactions]
            ..sort(
              (left, right) =>
                  _transactionDate(right).compareTo(_transactionDate(left)),
            );

          return Column(
            children: [
              _buildAddTransactionButton(context),
              Expanded(
                child: latestTransactions.isEmpty
                    ? const Center(child: Text('No transactions recorded yet.'))
                    : _buildTransactionGrid(context, ref, latestTransactions),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionGrid(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> transactions,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            TerraResinColors.primary.withValues(alpha: 0.08),
          ),
          border: TableBorder.all(color: TerraResinColors.border),
          columnSpacing: 28,
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: TerraResinColors.textPrimary,
          ),
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Debit / Credit')),
            DataColumn(label: Text('Amount'), numeric: true),
            DataColumn(label: Text('Bank Account')),
            DataColumn(label: Text('Party')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Actions')),
          ],
          rows: transactions
              .map(
                (transaction) =>
                    _buildTransactionRow(context, ref, transaction),
              )
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildTransactionRow(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> transaction,
  ) {
    final direction = transaction['direction'] as String? ?? 'debit';
    final isCredit = direction == 'credit';
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0;
    final account = transaction['accounts'];
    final accountName = account is Map
        ? account['name'] as String? ?? 'Not assigned'
        : 'Not assigned';
    final date = _transactionDate(transaction);

    return DataRow(
      cells: [
        DataCell(Text(_formatDate(date))),
        DataCell(Text(_categoryName(transaction))),
        DataCell(
          Text(
            isCredit ? 'Credit' : 'Debit',
            style: TextStyle(
              color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DataCell(
          Text(
            formatIndianCurrency(amount),
            style: TextStyle(
              color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(Text(accountName)),
        DataCell(Text(transaction['party_name'] as String? ?? '')),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              transaction['description'] as String? ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          PopupMenuButton<String>(
            tooltip: 'Transaction actions',
            onSelected: (value) =>
                _handleAction(context, ref, value, transaction),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String value,
    Map<String, dynamic> transaction,
  ) async {
    if (value == 'edit') {
      await showDialog(
        context: context,
        builder: (context) => TransactionFormDialog(transaction: transaction),
      );
      return;
    }

    if (value != 'delete') return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Delete this transaction permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(transactionRepositoryProvider)
          .deleteTransaction(transaction['id'] as String);
      ref.invalidate(transactionsProvider);
      ref.invalidate(companyBankBalancesProvider);
    }
  }

  DateTime _transactionDate(Map<String, dynamic> transaction) {
    return DateTime.tryParse(
          transaction['transaction_date'] as String? ?? '',
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatDate(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) return '-';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _categoryName(Map<String, dynamic> transaction) {
    final category = transaction['categories'];
    if (category is Map) {
      return category['name'] as String? ?? 'Uncategorized';
    }
    return 'Uncategorized';
  }

  Widget _buildAddTransactionButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: FilledButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const TransactionFormDialog(),
            );
          },
          icon: const Icon(Icons.swap_horiz_outlined),
          label: const Text('Add Transaction'),
        ),
      ),
    );
  }
}
