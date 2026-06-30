import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/navigation/app_routes.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/onboarding_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/widgets/auth_gate.dart';
import 'features/home/pages/dashboard_page.dart';
import 'features/home/pages/home_route_pages.dart';
import 'features/home/pages/notifications_page.dart';
import 'features/home/pages/payment_flow_page.dart';
import 'features/home/pages/bookings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabasePublishableKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RallyHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD9FF00),
          primary: const Color(0xFF26300F),
          secondary: const Color(0xFFD9FF00),
          tertiary: const Color(0xFFB8E600),
          surface: const Color(0xFFFCFCEB),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD9FF00),
            foregroundColor: const Color(0xFF15180B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF26300F),
            side: const BorderSide(color: Color(0xFF26300F)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFFFCFCEB),
          indicatorColor: const Color(0xFFD9FF00),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected
                  ? const Color(0xFF15180B)
                  : const Color(0xFF727763),
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? const Color(0xFF15180B)
                  : const Color(0xFF727763),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFFCFCEB),
        fontFamily: 'Inter',
      ),
      routes: {
        AppRoutes.onboarding: (_) => const OnboardingPage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.home: (_) => const HomeRoutePage(),
        AppRoutes.play: (_) => const PlayRoutePage(),
        AppRoutes.courts: (_) => const CourtsRoutePage(),
        AppRoutes.sessions: (_) => const SessionsRoutePage(),
        AppRoutes.dashboard: (_) => const DashboardPage(),
        AppRoutes.discoverCourts: (_) => const DiscoverCourtsRoutePage(),
        AppRoutes.matches: (_) => const MatchesRoutePage(),
        AppRoutes.notifications: (_) => const NotificationsPage(),
        AppRoutes.profileHistory: (_) => const ProfileRoutePage(),
        AppRoutes.bookings: (_) => const BookingsPage(),
        AppRoutes.payment: (_) => const PaymentFlowPage(),
      },
      home: home ?? const AuthGate(),
    );
  }
}
