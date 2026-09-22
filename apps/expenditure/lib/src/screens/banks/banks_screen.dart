import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terraresin_design_system/design_system.dart';

import '../../formatters/currency_formatter.dart';
import '../../providers/accounts/bank_balance_providers.dart';
import '../../providers/accounts/account_providers.dart';
import 'account_form_dialog.dart';

class BanksScreen extends ConsumerWidget {
  const BanksScreen({super.key, this.showAddButton = false});

  final bool showAddButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bankBalances = ref.watch(companyBankBalancesProvider);

    return Scaffold(
      backgroundColor: TerraResinColors.background,
      body: bankBalances.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading bank accounts: $error')),
        data: (banks) {
          if (banks.isEmpty) {
            return Column(
              children: [
                if (showAddButton) _buildAddBankButton(context),
                const Expanded(
                  child: Center(
                    child: Text('No active company bank accounts found.'),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              if (showAddButton) _buildAddBankButton(context),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: banks.length,
                  itemBuilder: (context, index) {
                    final isPhone = MediaQuery.sizeOf(context).width < 600;
                    final bankItem = banks[index];
                    final acc = bankItem.account;
                    final name = acc['name'] as String? ?? 'Unknown Account';
                    final bankName = acc['bank_name'] as String? ?? 'N/A';
                    final accNum =
                        acc['account_number'] as String? ?? '•••• ••••';

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
                          backgroundColor: TerraResinColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            color: TerraResinColors.primary,
                          ),
                        ),
                        title: Text(
                          name,
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
                            '$bankName • $accNum\nOwner: ${acc['owner']}',
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
                              width: isPhone ? 82 : 110,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  formatIndianCurrency(bankItem.balance),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: TerraResinColors.textPrimary,
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
                                        AccountFormDialog(account: acc),
                                  );
                                } else if (value == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Deactivate Account'),
                                      content: const Text(
                                        'Are you sure you want to deactivate this bank account?',
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
                                          child: const Text('Deactivate'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await ref
                                        .read(accountRepositoryProvider)
                                        .deleteAccount(acc['id'] as String);
                                    ref.invalidate(companyBankAccountsProvider);
                                  }
                                }
                              },
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
                                    leading: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    title: Text(
                                      'Deactivate',
                                      style: TextStyle(color: Colors.red),
                                    ),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddBankButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: FilledButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AccountFormDialog(),
            );
          },
          icon: const Icon(Icons.account_balance_outlined),
          label: const Text('Add Bank'),
        ),
      ),
    );
  }
}
