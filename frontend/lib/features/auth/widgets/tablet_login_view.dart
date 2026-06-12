import 'package:flutter/material.dart';
import 'auth_layout.dart';

class TabletLoginView extends StatelessWidget {
  const TabletLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Image.asset(
          'assets/images/pickleball_background.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Dark/Green tint Overlays
        Container(color: Colors.black.withOpacity(0.55)),
        Container(color: const Color(0x734F6F52)),
        // Centered Card
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Card(
              color: Colors.white,
              elevation: 12.0,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              child: Container(
                width: 500.0,
                padding: const EdgeInsets.all(40.0),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthHeader(
                      isDesktop: false,
                      title: 'Welcome Back!',
                      subtitle: 'Log in to keep the rally going.',
                    ),
                    SizedBox(height: 32.0),
                    AuthLoginForm(),
                    SizedBox(height: 24.0),
                    SocialLogins(),
                    SizedBox(height: 28.0),
                    AuthRegisterFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
