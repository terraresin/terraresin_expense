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
        .order('transaction_date', ascending: false);

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
        .order('transaction_date', ascending: false);

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

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    await _client.from('transactions').update(data).eq('id', id);
  }

  Future<void> deleteTransaction(
    String id, {
    String reason = 'Voided by user',
  }) async {
    await _client
        .from('transactions')
        .update({
          'status': 'void',
          'void_reason': reason,
          'voided_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id);
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
