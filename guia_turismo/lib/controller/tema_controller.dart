import 'package:flutter/material.dart';

/// Guarda se o app está no modo claro ou escuro.
class TemaController extends ChangeNotifier {
  ThemeMode _modo = ThemeMode.light;

  ThemeMode get modo => _modo;
  bool get escuro => _modo == ThemeMode.dark;
  IconData get icone => escuro ? Icons.dark_mode : Icons.light_mode;

  void alternar() {
    _modo = escuro ? ThemeMode.light : ThemeMode.dark;
    notifyListeners(); // avisa os widgets que dependem do tema
  }
}
