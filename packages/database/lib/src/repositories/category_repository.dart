import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_client.dart';

class CategoryRepository {
  SupabaseClient get _client => TerraRezynSupabaseClient.instance;

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client
        .from('categories')
        .select(
          'id, name, category_type, description, display_order, is_active',
        )
        .order('display_order');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    final organizationId = await _getOrganizationId();
    final categories = await _client
        .from('categories')
        .select('display_order')
        .eq('organization_id', organizationId)
        .order('display_order', ascending: false)
        .limit(1);
    final lastOrder = categories.isEmpty
        ? 0
        : (categories.first['display_order'] as num?)?.toInt() ?? 0;

    await _client.from('categories').insert({
      ...data,
      'organization_id': organizationId,
      'display_order': lastOrder + 1,
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
