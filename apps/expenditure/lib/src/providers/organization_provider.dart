import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terraresin_database/database.dart';
import 'package:terraresin_shared_models/shared_models.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository();
});

final organizationsProvider = FutureProvider<List<Organization>>((ref) async {
  final repository = ref.watch(organizationRepositoryProvider);

  return repository.getMyOrganizations();
});
