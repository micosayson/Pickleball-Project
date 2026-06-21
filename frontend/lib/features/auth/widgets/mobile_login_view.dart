import 'package:flutter/material.dart';
import '../../../core/styles/design_tokens.dart';
import 'auth_layout.dart';

class MobileLoginView extends StatelessWidget {
  const MobileLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topImageHeight = size.height * 0.28;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
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
                color: DesignColors.courtGreen.withValues(alpha: 0.56),
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
                        color: DesignColors.freshGreen,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        Icons.sports_tennis_rounded,
                        color: DesignColors.ink,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Text(
                      'RallyHub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -20.0),
            child: Container(
              decoration: const BoxDecoration(
                color: DesignColors.chalk,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 24.0,
                  bottom: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthHeader(
                      isDesktop: false,
                      title: 'Welcome back',
                      subtitle: 'Log in to keep the rally going.',
                    ),
                    SizedBox(height: 22.0),
                    AuthLoginForm(),
                    SizedBox(height: 18.0),
                    SocialLogins(),
                    SizedBox(height: 22.0),
                    AuthRegisterFooter(),
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
