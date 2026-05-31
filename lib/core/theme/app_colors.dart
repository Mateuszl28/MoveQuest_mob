import 'package:flutter/material.dart';

/// Centralna paleta kolorów MoveQuest.
///
/// Energetyczna, „ruchowa" tożsamość: limonkowa zieleń (aktywność) +
/// głęboki granat (questy/noc) z ciepłymi akcentami nagród.
abstract final class AppColors {
  // Marka
  static const Color primary = Color(0xFF00C853); // energetyczna zieleń
  static const Color primaryDark = Color(0xFF009624);
  static const Color secondary = Color(0xFF2962FF); // niebieski – social
  static const Color accent = Color(0xFFFFC400); // złoto – nagrody/punkty

  // Tła
  static const Color background = Color(0xFFF6F8F7);
  static const Color surface = Color(0xFFFFFFFF);

  // Semantyczne
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFF9100);
  static const Color danger = Color(0xFFE53935);

  // Tekst
  static const Color textPrimary = Color(0xFF1A1C1B);
  static const Color textSecondary = Color(0xFF5F6B65);
}
