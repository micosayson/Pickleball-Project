import 'package:flutter/material.dart';
import 'package:pickleball_frontend/features/auth/pages/onboarding_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plaqora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F6F52),
          primary: const Color(0xFF4F6F52),
          secondary: const Color(0xFF739072),
          tertiary: const Color(0xFFA8C686),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FBF9),
        fontFamily: 'Inter',
      ),
      home: const OnboardingPage(),
    );
  }
}
