import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final currentUserProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return _authenticatedUsers(authRepository);
});

Stream<User?> _authenticatedUsers(AuthRepository repository) async* {
  final cachedSession = repository.currentSession;
  if (cachedSession != null) {
    yield cachedSession.user;

    try {
      await repository.refreshSession().timeout(const Duration(seconds: 5));
    } catch (_) {
      await repository.signOut();
      yield null;
    }
  } else {
    yield null;
  }

  yield* repository.authStateChanges.map((state) => state.session?.user);
}
