import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terraresin_design_system/design_system.dart';

import '../../formatters/currency_formatter.dart';
import '../../providers/transactions/transaction_providers.dart';
import '../../providers/accounts/bank_balance_providers.dart';
import '../transactions/transaction_form_dialog.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsFuture = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: TerraResinColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const TransactionFormDialog(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: transactionsFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading expenses: $error')),
        data: (rawTransactions) {
          final expenses = rawTransactions.where((t) {
            final direction = t['direction'] as String?;
            return direction == 'debit';
          }).toList();

          if (expenses.isEmpty) {
            return const Center(
              child: Text('No company expenses recorded yet. Click + to add.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final item = expenses[index];
              final description =
                  item['description'] as String? ?? 'No description';
              final partyName = item['party_name'] as String? ?? 'N/A';
              final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
              final dateStr = item['transaction_date'] as String? ?? '';
              final date = dateStr.isNotEmpty
                  ? DateTime.parse(dateStr)
                  : DateTime.now();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: TerraResinColors.border),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    child: const Icon(Icons.arrow_downward, color: Colors.red),
                  ),
                  title: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TerraResinColors.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'To: $partyName • ${date.day}/${date.month}/${date.year}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TerraResinColors.textSecondary,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 110,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            formatIndianCurrency(amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  TransactionFormDialog(transaction: item),
                            );
                          } else if (value == 'void') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Void Expense'),
                                content: const Text(
                                  'Financial transactions should not be permanently deleted. Do you want to void this expense?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Void'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref
                                  .read(transactionRepositoryProvider)
                                  .deleteTransaction(
                                    item['id'] as String,
                                    reason: 'Voided from expense list',
                                  );
                              ref.invalidate(transactionsProvider);
                              ref.invalidate(companyBankBalancesProvider);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'void',
                            child: ListTile(
                              leading: Icon(Icons.undo, color: Colors.orange),
                              title: Text('Void'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
