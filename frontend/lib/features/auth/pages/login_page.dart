import 'package:flutter/material.dart';
import '../widgets/responsive_wrapper.dart';
import '../widgets/mobile_login_view.dart';
import '../widgets/tablet_login_view.dart';
import '../widgets/desktop_login_view.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      body: ResponsiveWrapper(
        mobile: MobileLoginView(),
        tablet: TabletLoginView(),
        desktop: DesktopLoginView(),
      ),
    );
  }
}
