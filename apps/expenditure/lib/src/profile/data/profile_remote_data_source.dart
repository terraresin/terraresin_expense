import '../models/user_profile.dart';

abstract interface class ProfileRemoteDataSource {
  Future<UserProfile?> getProfile(String userId);

  Future<UserProfile> updateProfile(UserProfile profile);
}
