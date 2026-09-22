import '../domain/profile_repository.dart';
import '../models/user_profile.dart';
import 'profile_remote_data_source.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository({required this._remoteDataSource});

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile?> getProfile(String userId) {
    return _remoteDataSource.getProfile(userId);
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) {
    return _remoteDataSource.updateProfile(profile);
  }
}
