import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_providers.dart';
import '../transactions/transaction_providers.dart';

class BankBalance {
  const BankBalance({required this.account, required this.balance});

  final Map<String, dynamic> account;
  final double balance;
}

final companyBankBalancesProvider = FutureProvider<List<BankBalance>>((
  ref,
) async {
  final accounts = await ref.watch(companyBankAccountsProvider.future);
  final transactions = await ref.watch(transactionsProvider.future);

  final balances = <BankBalance>[];

  for (final account in accounts) {
    final accountId = account['id'] as String;

    final openingBalance =
        (account['opening_balance'] as num?)?.toDouble() ?? 0.0;

    final accountTransactions = transactions.where((transaction) {
      if (transaction['account_id'] == accountId) {
        return true;
      }

      final accountData = transaction['accounts'];

      if (accountData is! Map) {
        return false;
      }

      return accountData['id'] == accountId;
    });

    var balance = openingBalance;

    for (final transaction in accountTransactions) {
      final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;

      final direction = transaction['direction'] as String?;

      if (direction == 'credit') {
        balance += amount;
      } else if (direction == 'debit') {
        balance -= amount;
      }
    }

    balances.add(BankBalance(account: account, balance: balance));
  }

  return balances;
});
