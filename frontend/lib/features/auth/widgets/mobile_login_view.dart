import 'package:flutter/material.dart';

import '../../../core/styles/design_tokens.dart';
import 'auth_layout.dart';

class MobileLoginView extends StatelessWidget {
  const MobileLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          top: 24,
          bottom: 26 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 338),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _RallyLogoStack(),
                const SizedBox(height: 10),
                const Text(
                  'RallyHub',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DesignColors.courtGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your premium pickleball network.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DesignColors.muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                const _PaddlePreview(),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: DesignColors.line),
                    boxShadow: [
                      BoxShadow(
                        color: DesignColors.ink.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: DesignColors.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 18),
                      AuthLoginForm(),
                      SizedBox(height: 16),
                      AuthRegisterFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RallyLogoStack extends StatelessWidget {
  const _RallyLogoStack();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: DesignColors.freshGreen,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: DesignColors.ink,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const Icon(
            Icons.sports_tennis_rounded,
            color: DesignColors.freshGreen,
            size: 26,
          ),
          Positioned(
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: DesignColors.ink,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'RALLY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaddlePreview extends StatelessWidget {
  const _PaddlePreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7C9), Color(0xFFFFC0AD), Color(0xFFE5FFF1)],
        ),
        boxShadow: [
          BoxShadow(
            color: DesignColors.freshGreen.withValues(alpha: 0.24),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 210,
          height: 112,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: DesignColors.ink.withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 18,
                top: 28,
                child: Container(
                  width: 48,
                  height: 3,
                  color: DesignColors.freshGreen,
                ),
              ),
              Positioned(
                right: 18,
                top: 16,
                child: Icon(
                  Icons.more_vert_rounded,
                  color: DesignColors.ink.withValues(alpha: 0.18),
                  size: 20,
                ),
              ),
              Positioned(
                left: 58,
                top: 18,
                child: Transform.rotate(
                  angle: -0.72,
                  child: Container(
                    width: 94,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F4748),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: DesignColors.ink.withValues(alpha: 0.24),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 122,
                top: 62,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: DesignColors.freshGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: 68,
                bottom: 16,
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 44,
                      height: 9,
                      decoration: BoxDecoration(
                        color: DesignColors.chalk,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
