import 'package:flutter/material.dart';

import '../../../core/styles/design_tokens.dart';
import '../widgets/mobile_login_view.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.chalk,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: const MobileLoginView(),
        ),
      ),
    );
  }
}
