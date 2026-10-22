import 'package:flutter/material.dart';

/// Centraliza a construção dos temas claro e escuro do app.
class AppTheme {
  static const Color _corBase = Colors.teal;

  static ThemeData _montar(Brightness brilho) {
    final cores = ColorScheme.fromSeed(seedColor: _corBase, brightness: brilho);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cores,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: cores.primary,
        foregroundColor: cores.onPrimary,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData get claro => _montar(Brightness.light);
  static ThemeData get escuro => _montar(Brightness.dark);
}
