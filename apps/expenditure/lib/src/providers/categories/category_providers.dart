import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terraresin_database/database.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(categoryRepositoryProvider).getCategories();
});
