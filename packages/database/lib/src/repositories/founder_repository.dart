import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_client.dart';

class FounderRepository {
  SupabaseClient get _client => TerraRezynSupabaseClient.instance;

  Future<List<Map<String, dynamic>>> getFounders() async {
    final response = await _client
        .from('founders')
        .select('id, name, code, contact, is_active')
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createFounder(Map<String, dynamic> data) async {
    await _client.from('founders').insert({
      ...data,
      'organization_id': await _getOrganizationId(),
    });
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
