import 'package:flutter/material.dart';

import '../../../core/styles/design_tokens.dart';
import '../widgets/mobile_register_view.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.chalk,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: const MobileRegisterView(),
        ),
      ),
    );
  }
}
