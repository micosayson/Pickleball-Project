import 'package:flutter/material.dart';
import 'auth_layout.dart';

class MobileRegisterView extends StatelessWidget {
  const MobileRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topImageHeight = size.height * 0.25; // slightly smaller top section to accommodate more fields

    return SingleChildScrollView(
      child: Column(
        children: [
          // Top Image Section (25% height)
          Stack(
            children: [
              SizedBox(
                height: topImageHeight,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/pickleball_background.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: topImageHeight,
                color: Colors.black.withValues(alpha: 0.4),
              ),
              Container(
                height: topImageHeight,
                color: const Color(0x504F6F52),
              ),
              // App logo overlay
              Positioned(
                top: 48.0,
                left: 24.0,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA8C686),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        Icons.sports_tennis_rounded,
                        color: Color(0xFF4F6F52),
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Text(
                      'Plaqora',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Bottom overlapping card
          Transform.translate(
            offset: const Offset(0, -32.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.0),
                  topRight: Radius.circular(32.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 32.0,
                  bottom: 40.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthHeader(
                      isDesktop: false,
                      title: 'Join Plaqora',
                      subtitle: 'Sign up to start playing.',
                    ),
                    SizedBox(height: 28.0),
                    AuthRegisterForm(),
                    SizedBox(height: 24.0),
                    SocialLogins(),
                    SizedBox(height: 28.0),
                    AuthLoginFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
