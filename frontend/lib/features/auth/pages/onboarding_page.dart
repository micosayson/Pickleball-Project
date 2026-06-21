import 'package:flutter/material.dart';

import '../../../core/styles/design_tokens.dart';
import 'login_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050604),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1200;
          final isTablet =
              constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
          final horizontalPadding = isDesktop
              ? constraints.maxWidth * 0.12
              : (isTablet ? 48.0 : 24.0);
          final headlineFontSize = isDesktop ? 68.0 : (isTablet ? 54.0 : 40.0);
          final bodyFontSize = isDesktop ? 19.0 : (isTablet ? 17.0 : 15.0);
          final ctaWidth = isDesktop ? 220.0 : (isTablet ? 190.0 : 170.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/pickleball_background.jpg',
                fit: BoxFit.cover,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.54),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: DesignColors.courtGreen.withValues(alpha: 0.58),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    18,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _OnboardingTopBar(onLogin: () => _openLogin(context)),
                          const Spacer(),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 620),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _OnboardingBadge(),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Play beyond the game',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: headlineFontSize,
                                      fontWeight: FontWeight.w900,
                                      height: 1.02,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Discover courts, join open play, and keep your match history in one place.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: bodyFontSize,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const _OnboardingDots(),
                              const Spacer(),
                              SizedBox(
                                width: ctaWidth,
                                height: 56,
                                child: FilledButton.icon(
                                  onPressed: () => _openLogin(context),
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('Continue'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: DesignColors.freshGreen,
                                    foregroundColor: DesignColors.ink,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: DesignColors.freshGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.sports_tennis_rounded,
            color: DesignColors.ink,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'RallyHub',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        TextButton(
          onPressed: onLogin,
          style: TextButton.styleFrom(foregroundColor: DesignColors.freshGreen),
          child: const Text('Log in'),
        ),
      ],
    );
  }
}

class _OnboardingBadge extends StatelessWidget {
  const _OnboardingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DesignColors.freshGreen,
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        'Find your next match',
        style: TextStyle(
          color: DesignColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _OnboardingDots extends StatelessWidget {
  const _OnboardingDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 6,
          decoration: BoxDecoration(
            color: DesignColors.freshGreen,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        for (var index = 0; index < 2; index++) ...[
          Container(
            width: 8,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.36),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (index == 0) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
