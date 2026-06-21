import 'package:flutter/material.dart';

import '../../../core/styles/design_tokens.dart';
import '../widgets/desktop_register_view.dart';
import '../widgets/mobile_register_view.dart';
import '../widgets/responsive_wrapper.dart';
import '../widgets/tablet_register_view.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: DesignColors.chalk,
      body: ResponsiveWrapper(
        mobile: MobileRegisterView(),
        tablet: TabletRegisterView(),
        desktop: DesktopRegisterView(),
      ),
    );
  }
}
