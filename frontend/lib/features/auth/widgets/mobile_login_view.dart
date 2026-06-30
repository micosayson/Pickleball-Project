import 'package:flutter/material.dart';

import '../../../core/styles/design_tokens.dart';
import 'auth_layout.dart';

class MobileLoginView extends StatelessWidget {
  const MobileLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: -36,
            top: -100,
            child: _GlowBlob(
              size: 194,
              color: DesignColors.freshGreen.withValues(alpha: 0.13),
            ),
          ),
          Positioned(
            right: -28,
            bottom: -86,
            child: _GlowBlob(
              size: 236,
              color: DesignColors.courtGreen.withValues(alpha: 0.09),
            ),
          ),
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: 26 + bottomInset),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 6),
                      const _BrandRow(),
                      const SizedBox(height: 26),
                      const _IllustrationCard(),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: DesignColors.line),
                          boxShadow: [
                            BoxShadow(
                              color: DesignColors.ink.withValues(alpha: 0.06),
                              blurRadius: 26,
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
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Sign in to continue your RallyHub flow.',
                              style: TextStyle(
                                color: DesignColors.muted,
                                fontSize: 13.5,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 20),
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
          ),
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: DesignColors.freshGreen.withValues(alpha: 0.78),
            shape: BoxShape.circle,
            border: Border.all(color: DesignColors.line),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'RallyHub',
          style: TextStyle(
            color: DesignColors.ink,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 10),
        const Icon(
          Icons.notifications_none_rounded,
          color: DesignColors.ink,
          size: 20,
        ),
      ],
    );
  }
}

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF9D7), Color(0xFFFFE8A8), Color(0xFFDFF7D0)],
        ),
        border: Border.all(color: DesignColors.line),
        boxShadow: [
          BoxShadow(
            color: DesignColors.freshGreen.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              image: const DecorationImage(
                image: AssetImage('assets/images/pickleball_background.jpg'),
                fit: BoxFit.cover,
                opacity: 0.16,
              ),
            ),
          ),
          Positioned(
            left: -38,
            top: -46,
            child: Container(
              width: 142,
              height: 142,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -24,
            bottom: -10,
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                color: DesignColors.courtGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            top: 38,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 28,
                    child: Container(
                      width: 46,
                      height: 3,
                      color: DesignColors.freshGreen,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 14,
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: DesignColors.ink.withValues(alpha: 0.24),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    left: 64,
                    top: 18,
                    child: Transform.rotate(
                      angle: -0.72,
                      child: Container(
                        width: 100,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF26300F),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: DesignColors.ink.withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 126,
                    top: 64,
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
                    left: 72,
                    bottom: 14,
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
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
