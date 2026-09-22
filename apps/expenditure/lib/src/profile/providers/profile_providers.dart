import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_remote_data_source.dart';
import '../data/supabase_profile_remote_data_source.dart';
import '../data/supabase_profile_repository.dart';
import '../domain/profile_repository.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  return SupabaseProfileRemoteDataSource();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);

  return SupabaseProfileRepository(remoteDataSource: remoteDataSource);
});
