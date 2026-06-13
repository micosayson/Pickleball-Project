import 'package:flutter/material.dart';
import 'login_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1200;
    final isTablet = size.width >= 768 && size.width < 1200;

    final horizontalPadding = isDesktop
        ? size.width * 0.15
        : (isTablet ? 48.0 : 24.0);
    final badgeFontSize = isDesktop ? 16.0 : 13.0;
    final headlineFontSize = isDesktop ? 68.0 : (isTablet ? 54.0 : 40.0);
    final subtextFontSize = isDesktop ? 20.0 : (isTablet ? 18.0 : 15.0);

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/pickleball_background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withValues(alpha: 0.52)),
          Container(color: const Color(0x66315C3A)),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFA8C686,
                          ).withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(99.0),
                          border: Border.all(
                            color: const Color(
                              0xFFA8C686,
                            ).withValues(alpha: 0.48),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.sports_tennis_rounded,
                              color: Color(0xFFA8C686),
                              size: 16.0,
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              'FIND YOUR NEXT MATCH',
                              style: TextStyle(
                                color: const Color(0xFFA8C686),
                                fontWeight: FontWeight.w900,
                                fontSize: badgeFontSize,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        'PLAY\nBEYOND\nTHE GAME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: headlineFontSize,
                          fontWeight: FontWeight.w900,
                          height: 1.06,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Discover courts, join open play,\nand build a rating from real matches.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: subtextFontSize,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28.0,
                            height: 6.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Container(
                            width: 8.0,
                            height: 6.0,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Container(
                            width: 8.0,
                            height: 6.0,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: isDesktop ? 200.0 : (isTablet ? 180.0 : 170.0),
                        height: 56.0,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFF315C3A),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 4.0,
                            shadowColor: Colors.black.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
