import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:terraresin_shared_models/shared_models.dart';

import '../supabase_client.dart';

class TransactionRepository {
  SupabaseClient get _client => TerraRezynSupabaseClient.instance;

  Future<List<Transaction>> getTypedTransactions({String? accountName}) async {
    final organizationId = await _getOrganizationId();

    final response = await _client
        .from('transactions')
        .select('''
          *,
          categories(name, category_type, description),
          founders(name),
          projects(name),
          accounts(
            id,
            name,
            account_type,
            owner
          )
        ''')
        .eq('organization_id', organizationId)
        .order('transaction_date', ascending: false)
        .order('created_at');

    final rawList = List<Map<String, dynamic>>.from(response);
    var transactions = rawList.map((m) => Transaction.fromMap(m)).toList();

    if (accountName != null) {
      transactions = transactions
          .where((t) => t.accountName == accountName)
          .toList();
    }

    return transactions;
  }

  Future<List<Map<String, dynamic>>> getTransactions({
    String? accountName,
  }) async {
    final organizationId = await _getOrganizationId();

    final response = await _client
        .from('transactions')
        .select('''
          *,
          categories(name, category_type, description),
          founders(name),
          projects(name),
          accounts(
            id,
            name,
            account_type,
            owner
          )
        ''')
        .eq('organization_id', organizationId)
        .order('transaction_date', ascending: false)
        .order('created_at');

    var transactions = List<Map<String, dynamic>>.from(response);

    if (accountName != null) {
      transactions = transactions.where((transaction) {
        final account = transaction['accounts'];

        if (account is! Map<String, dynamic>) {
          return false;
        }

        return account['name'] == accountName;
      }).toList();
    }

    return transactions;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client
        .from('categories')
        .select('id, name')
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    final response = await _client
        .from('projects')
        .select('id, name, code')
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createTransaction(Map<String, dynamic> data) async {
    final organizationId = await _getOrganizationId();
    final fullData = {...data, 'organization_id': organizationId};
    await _client.from('transactions').insert(fullData);
  }

  Future<void> createTransactionPair({
    required Map<String, dynamic> debit,
    required Map<String, dynamic> credit,
  }) async {
    final organizationId = await _getOrganizationId();
    final personalAccount = await _client
        .from('accounts')
        .select('id')
        .eq('account_type', 'personal')
        .eq('is_active', true)
        .order('created_at')
        .limit(1)
        .maybeSingle();
    if (personalAccount == null || personalAccount['id'] == null) {
      throw StateError('No active personal bank account is configured.');
    }

    final personalAccountId = personalAccount['id'] as String;
    final createdAt = DateTime.now().toUtc();
    await _client.from('transactions').insert([
      {
        ...credit,
        'account_id': personalAccountId,
        'organization_id': organizationId,
        'created_at': createdAt.toIso8601String(),
      },
      {
        ...debit,
        'account_id': personalAccountId,
        'organization_id': organizationId,
        'created_at': createdAt
            .add(const Duration(microseconds: 1))
            .toIso8601String(),
      },
    ]);
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    await _client.from('transactions').update(data).eq('id', id);
  }

  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }

  Future<void> deleteTransactionPair(String referenceNumber) async {
    await _client
        .from('transactions')
        .delete()
        .eq('reference_number', referenceNumber);
  }

  static String? _cachedOrganizationId;

  Future<String> _getOrganizationId() async {
    if (_cachedOrganizationId != null) {
      return _cachedOrganizationId!;
    }

    final response = await _client
        .from('organizations')
        .select('id')
        .eq('name', 'TerraResin')
        .maybeSingle();

    if (response == null || response['id'] == null) {
      throw StateError('TerraResin organization was not found.');
    }

    _cachedOrganizationId = response['id'] as String;
    return _cachedOrganizationId!;
  }
}
