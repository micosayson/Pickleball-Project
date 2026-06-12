import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/pages/login_page.dart';
import '../../auth/services/auth_service.dart';

/// Temporary placeholder shown after a successful login.
/// Includes a small API tester so you can verify backend GET/POST/PATCH calls.
class HomePlaceholderPage extends StatefulWidget {
  const HomePlaceholderPage({super.key});

  @override
  State<HomePlaceholderPage> createState() => _HomePlaceholderPageState();
}

class _HomePlaceholderPageState extends State<HomePlaceholderPage> {
  String _lastResult = 'Press a test button to hit the backend.';
  bool _isLoading = false;

  Future<void> _runRequest(Future<dynamic> Function() request, String label) async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Running $label...';
    });

    try {
      final response = await request();
      if (!mounted) return;
      setState(() {
        _lastResult = '$label succeeded: ${response.data}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _lastResult = '$label failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ?? 'Player';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(79, 111, 82, 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_tennis_rounded,
                      color: Color(0xFF4F6F52),
                      size: 40.0,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Welcome, $fullName!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF4F6F52),
                      fontSize: 28.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF739072),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(168, 198, 134, 0.2),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color.fromRGBO(168, 198, 134, 0.5),
                      ),
                    ),
                    child: const Text(
                      'Home screen coming soon',
                      style: TextStyle(
                        color: Color(0xFF4F6F52),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Backend API Tester',
                              style: TextStyle(
                                color: Color(0xFF4F6F52),
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Use these buttons to confirm GET, POST, and PATCH requests hit FastAPI.',
                              style: TextStyle(
                                color: Color(0xFF739072),
                                fontSize: 13.0,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Wrap(
                              spacing: 12.0,
                              runSpacing: 12.0,
                              children: [
                                ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => _runRequest(
                                            () => ApiClient.instance.get(ApiEndpoints.authMe),
                                            'GET /auth/me',
                                          ),
                                  child: const Text('GET /auth/me'),
                                ),
                                ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => _runRequest(
                                            () => ApiClient.instance.post(
                                              ApiEndpoints.userSync,
                                              data: {
                                                'full_name': fullName,
                                                'avatar_url': user?.userMetadata?['avatar_url'],
                                              },
                                            ),
                                            'POST /users/sync',
                                          ),
                                  child: const Text('POST /users/sync'),
                                ),
                                ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => _runRequest(
                                            () => ApiClient.instance.patch(
                                              ApiEndpoints.usersMe,
                                              data: {'full_name': '$fullName Updated'},
                                            ),
                                            'PATCH /users/me',
                                          ),
                                  child: const Text('PATCH /users/me'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              _lastResult,
                              style: const TextStyle(
                                color: Color(0xFF4F6F52),
                                fontSize: 13.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  SizedBox(
                    width: 200.0,
                    height: 50.0,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await AuthService().signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18.0),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4F6F52),
                        side: const BorderSide(color: Color(0xFF4F6F52), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
