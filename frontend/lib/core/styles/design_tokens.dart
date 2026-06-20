import 'package:flutter/material.dart';

class DesignColors {
  static const Color courtGreen = Color(0xFF315C3A);
  static const Color freshGreen = Color(0xFF78A85A);
  static const Color clay = Color(0xFFD37A46);
  static const Color ink = Color(0xFF17221B);
  static const Color muted = Color(0xFF6A7A70);
  static const Color chalk = Color(0xFFF7FAF5);
  static const Color line = Color(0xFFE1E9DE);
}

class DesignTextStyles {
  static TextStyle heading(BuildContext context) => Theme.of(context).textTheme.headlineSmall!.copyWith(
        color: DesignColors.ink,
        fontWeight: FontWeight.w900,
      );

  static const TextStyle panelTitle = TextStyle(
    color: DesignColors.ink,
    fontSize: 16,
    fontWeight: FontWeight.w900,
  );
}
