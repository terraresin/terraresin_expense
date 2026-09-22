import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:terraresin_shared_models/shared_models.dart';

import '../supabase_client.dart';

class OrganizationRepository {
  OrganizationRepository({SupabaseClient? client})
    : _client = client ?? TerraRezynSupabaseClient.instance;

  final SupabaseClient _client;

  Future<List<Organization>> getMyOrganizations() async {
    final response = await _client.from('organizations').select().order('name');

    return response.map((item) => Organization.fromMap(item)).toList();
  }
}
