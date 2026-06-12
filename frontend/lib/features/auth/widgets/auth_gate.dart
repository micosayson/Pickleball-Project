import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/onboarding_page.dart';
import '../../home/pages/home_placeholder_page.dart';

/// AuthGate listens to Supabase auth state and routes to the
/// correct screen: OnboardingPage if logged out, HomePlaceholderPage if logged in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show a loader while we wait for initial auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FBF9),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4F6F52),
              ),
            ),
          );
        }

        final session = snapshot.hasData
            ? snapshot.data!.session
            : Supabase.instance.client.auth.currentSession;
        debugPrint('AuthGate session=${session != null}');

        if (session != null) {
          return const HomePlaceholderPage();
        } else {
          return const OnboardingPage();
        }
      },
    );
  }
}
