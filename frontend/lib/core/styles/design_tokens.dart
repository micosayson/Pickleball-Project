import 'package:flutter/material.dart';

class DesignColors {
  static const Color courtGreen = Color(0xFF26300F);
  static const Color freshGreen = Color(0xFFD9FF00);
  static const Color clay = Color(0xFFB8E600);
  static const Color ink = Color(0xFF15180B);
  static const Color muted = Color(0xFF727763);
  static const Color chalk = Color(0xFFFCFCEB);
  static const Color line = Color(0xFFE6E8C8);
}

class DesignTextStyles {
  static TextStyle heading(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall!.copyWith(
        color: DesignColors.ink,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      );

  static const TextStyle panelTitle = TextStyle(
    color: DesignColors.ink,
    fontSize: 16,
    fontWeight: FontWeight.w900,
  );
}
