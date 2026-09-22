import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_client.dart';

class AccountRepository {
  SupabaseClient get _client => TerraRezynSupabaseClient.instance;

  Future<List<Map<String, dynamic>>> getCompanyBankAccounts() async {
    final response = await _client
        .from('accounts')
        .select('''
          id,
          name,
          account_type,
          owner,
          bank_name,
          account_number,
          opening_balance,
          is_active
        ''')
        .eq('account_type', 'bank')
        .eq('owner', 'company')
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createAccount(Map<String, dynamic> accountData) async {
    await _client.from('accounts').insert({
      ...accountData,
      'organization_id': await _getOrganizationId(),
    });
  }

  Future<void> updateAccount(
    String id,
    Map<String, dynamic> accountData,
  ) async {
    await _client.from('accounts').update(accountData).eq('id', id);
  }

  Future<void> deleteAccount(String id) async {
    await _client.from('accounts').update({'is_active': false}).eq('id', id);
  }

  Future<String> _getOrganizationId() async {
    final organization = await _client
        .from('organizations')
        .select('id')
        .eq('name', 'TerraResin')
        .maybeSingle();

    if (organization == null || organization['id'] == null) {
      throw StateError('TerraResin organization was not found.');
    }

    return organization['id'] as String;
  }
}
