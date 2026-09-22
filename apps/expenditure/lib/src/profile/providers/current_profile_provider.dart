import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth/auth_providers.dart';
import '../models/user_profile.dart';
import 'profile_providers.dart';

final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = await ref.watch(currentUserProvider.future);

  if (authState == null) {
    return null;
  }

  final profileRepository = ref.watch(profileRepositoryProvider);

  return profileRepository.getProfile(authState.id);
});
