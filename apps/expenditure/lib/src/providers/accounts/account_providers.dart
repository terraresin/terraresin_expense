import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terraresin_database/database.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository();
});

final companyBankAccountsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repository = ref.watch(accountRepositoryProvider);

  final stopwatch = Stopwatch()..start();

  debugPrint('BANK ACCOUNTS: START');

  try {
    final accounts = await repository.getCompanyBankAccounts().timeout(
      const Duration(seconds: 15),
    );

    stopwatch.stop();

    debugPrint(
      'BANK ACCOUNTS: SUCCESS - ${accounts.length} rows - '
      '${stopwatch.elapsedMilliseconds} ms',
    );

    return accounts;
  } catch (error, stackTrace) {
    stopwatch.stop();

    debugPrint(
      'BANK ACCOUNTS: ERROR - '
      '${stopwatch.elapsedMilliseconds} ms - $error',
    );

    debugPrint('$stackTrace');

    rethrow;
  }
});
