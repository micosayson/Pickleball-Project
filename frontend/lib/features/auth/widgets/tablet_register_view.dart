import 'package:flutter/material.dart';
import '../../../core/styles/design_tokens.dart';
import 'auth_layout.dart';

class TabletRegisterView extends StatelessWidget {
  const TabletRegisterView({super.key});

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
        Container(color: Colors.black.withValues(alpha: 0.55)),
        Container(color: DesignColors.courtGreen.withValues(alpha: 0.42)),
        // Centered Card
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 24.0,
            ),
            child: Card(
              color: DesignColors.chalk,
              elevation: 12.0,
              shadowColor: Colors.black.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
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
                      title: 'Join RallyHub',
                      subtitle: 'Sign up to start playing.',
                    ),
                    SizedBox(height: 32.0),
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
        ),
      ],
    );
  }
}
