import 'package:flutter/material.dart';
import '../widgets/responsive_wrapper.dart';
import '../widgets/mobile_register_view.dart';
import '../widgets/tablet_register_view.dart';
import '../widgets/desktop_register_view.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      body: ResponsiveWrapper(
        mobile: MobileRegisterView(),
        tablet: TabletRegisterView(),
        desktop: DesktopRegisterView(),
      ),
    );
  }
}
