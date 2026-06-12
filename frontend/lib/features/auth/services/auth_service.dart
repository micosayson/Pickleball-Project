import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> _syncBackendProfile({String? fullName}) async {
    if (_client.auth.currentSession == null) {
      return;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await ApiClient.instance.post(
        ApiEndpoints.userSync,
        data: {
          'full_name': fullName ?? user.userMetadata?['full_name'],
          'avatar_url': user.userMetadata?['avatar_url'],
        },
      );
    } catch (error) {
      // Auth should still work even if the backend sync is temporarily unavailable.
      // The backend will catch up on the next successful login.
      // ignore: avoid_print
      print('Backend profile sync failed: $error');
    }
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    // ignore: avoid_print
    print('AuthService.signIn start email=$email');
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // ignore: avoid_print
      print('AuthService.signIn success session=${response.session != null}');
      unawaited(_syncBackendProfile());
      return response;
    } on AuthException catch (error) {
      // ignore: avoid_print
      print('AuthService.signIn failed ${error.message}');
      rethrow;
    }
  }

  /// Register a new user with email, password, and full name.
  /// Full name is stored in user metadata.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // ignore: avoid_print
    print('AuthService.signUp start email=$email');
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      // ignore: avoid_print
      print('AuthService.signUp success session=${response.session != null}');
      if (response.session != null) {
        unawaited(_syncBackendProfile(fullName: fullName));
      }
      return response;
    } on AuthException catch (error) {
      // ignore: avoid_print
      print('AuthService.signUp failed ${error.message}');
      rethrow;
    }
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
