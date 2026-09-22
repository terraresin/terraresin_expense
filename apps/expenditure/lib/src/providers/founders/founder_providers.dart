import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terraresin_database/database.dart';

final founderRepositoryProvider = Provider<FounderRepository>((ref) {
  return FounderRepository();
});

final foundersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(founderRepositoryProvider).getFounders();
});
