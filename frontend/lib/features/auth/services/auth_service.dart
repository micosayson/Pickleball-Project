import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Register a new user with email, password, and full name.
  /// Full name is stored in user metadata.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  /// Sign out the currently authenticated user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Returns the currently logged-in user, or null if not authenticated.
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
