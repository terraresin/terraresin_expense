import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terraresin_database/database.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repository = ref.watch(transactionRepositoryProvider);

  try {
    final transactions = await repository.getTransactions().timeout(
      const Duration(seconds: 15),
    );

    debugPrint('TRANSACTIONS SUCCESS: ${transactions.length} rows');

    return transactions;
  } catch (error, stackTrace) {
    debugPrint('TRANSACTIONS ERROR: $error');
    debugPrint('TRANSACTIONS STACK: $stackTrace');

    rethrow;
  }
});
