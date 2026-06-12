import 'package:flutter/material.dart';
import 'login_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1200;
    final isTablet = size.width >= 768 && size.width < 1200;

    // Responsive padding and font sizing
    final horizontalPadding = isDesktop ? size.width * 0.15 : (isTablet ? 48.0 : 24.0);
    final badgeFontSize = isDesktop ? 16.0 : 13.0;
    final headlineFontSize = isDesktop ? 72.0 : (isTablet ? 56.0 : 42.0);
    final subtextFontSize = isDesktop ? 20.0 : (isTablet ? 18.0 : 15.0);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/pickleball_background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Dark Overlay (55%)
          Container(
            color: Colors.black.withOpacity(0.55),
          ),
          // Green Tint Overlay (#4F6F52 at 40% opacity)
          Container(
            color: const Color(0x664F6F52),
          ),
          // Safe Area for UI elements
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row (Skip Button)
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        backgroundColor: Colors.white.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Center Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA8C686).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: const Color(0xFFA8C686).withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🎾',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              'FIND YOUR SPORT MATES',
                              style: TextStyle(
                                color: const Color(0xFFA8C686),
                                fontWeight: FontWeight.w800,
                                fontSize: badgeFontSize,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // Main Headline
                      Text(
                        'PLAY\nBEYOND\nTHE GAME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: headlineFontSize,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Subtext
                      Text(
                        'Connect with athletes nearby, join events,\nbook courts, and track your ratings.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: subtextFontSize,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Bottom Row (Page Indicator and CTA)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page Indicator
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
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Container(
                            width: 8.0,
                            height: 6.0,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                        ],
                      ),
                      // Continue Button
                      SizedBox(
                        width: isDesktop ? 200.0 : (isTablet ? 180.0 : 170.0),
                        height: 56.0,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFF4F6F52),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            elevation: 4.0,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Icon(Icons.arrow_forward_rounded, size: 20.0),
                            ],
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
