import 'package:flutter/material.dart';
import 'auth_layout.dart';

class DesktopLoginView extends StatelessWidget {
  const DesktopLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Panel (55%)
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              Image.asset(
                'assets/images/pickleball_background.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Container(color: Colors.black.withOpacity(0.55)),
              Container(color: const Color(0x734F6F52)),
              Padding(
                padding: const EdgeInsets.all(64.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Logo (Top Left)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA8C686),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Icon(
                            Icons.sports_tennis_rounded,
                            color: Color(0xFF4F6F52),
                            size: 28.0,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        const Text(
                          'Plaqora',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Headline & Subtext
                    const Text(
                      'PLAY\nBEYOND\nTHE GAME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 64.0,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      'Connect with athletes nearby, join events, book courts, and track your ratings. Experience the game at a whole new level.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Right Panel (45%)
        Expanded(
          flex: 45,
          child: Container(
            color: const Color(0xFFF9FBF9),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420.0),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(
                        isDesktop: true,
                        title: 'Welcome Back!',
                        subtitle: 'Log in to keep the rally going.',
                      ),
                      SizedBox(height: 36.0),
                      AuthLoginForm(),
                      SizedBox(height: 28.0),
                      SocialLogins(),
                      SizedBox(height: 32.0),
                      AuthRegisterFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
