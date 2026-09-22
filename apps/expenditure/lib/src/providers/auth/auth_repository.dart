import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:terraresin_database/database.dart';

class AuthRepository {
  AuthRepository({SupabaseClient? client})
    : _client = client ?? TerraRezynSupabaseClient.instance;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<Session?> refreshSession() async {
    final response = await _client.auth.refreshSession();
    return response.session;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
