import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/styles/design_tokens.dart';
import '../pages/login_page.dart';
import '../../home/pages/home_route_pages.dart';

/// AuthGate listens to Supabase auth state and routes to the
/// correct screen: LoginPage if logged out, HomePlaceholderPage if logged in.
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
            backgroundColor: Color(0xFF050604),
            body: Center(
              child: CircularProgressIndicator(color: DesignColors.freshGreen),
            ),
          );
        }

        final session = snapshot.hasData
            ? snapshot.data!.session
            : Supabase.instance.client.auth.currentSession;
        debugPrint('AuthGate session=${session != null}');

        if (session != null) {
          return const PlayRoutePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
