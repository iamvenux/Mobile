import 'package:flutter/material.dart';
import 'package:guia_turismo/estilo/estilo_widgets.dart';

// controla o tema do app (rosa claro e rosa escuro) e o botao de trocar
// as funcoes de estilo de cada componente tao no estilo_widgets.dart
class AparenciaControle extends ChangeNotifier {
  // minhas cores rosas
  static const Color rosaPastel = Color(0xFFF8BBD0); // cor principal
  static const Color rosaClarinho = Color(0xFFFDE4EC); // fundinho das coisas no modo claro
  static const Color rosaEscuro = Color(0xFF6D3A4E); // fundinho no modo escuro
  static const Color vinho = Color(0xFF4A1C2E); // cor do texto em cima do rosa, p/ dar p/ ler

  // comeca no tema claro
  ThemeMode _modo = ThemeMode.light;
  ThemeMode get modo => _modo;

  // icone do botao la na appbar, muda conforme o tema
  IconData get icone =>
      _modo == ThemeMode.light ? Icons.light_mode : Icons.dark_mode;

  // monta o tema, serve tanto p/ claro qnt p/ escuro (muda so o brilho)
  static ThemeData _montarTema(Brightness brilho) {
    final escuro = brilho == Brightness.dark;
    // o fromSeed gera uma paleta inteira a partir do rosa
    // e o copyWith troca as cores principais pelas minhas
    final cor = ColorScheme.fromSeed(
      seedColor: rosaPastel,
      brightness: brilho,
    ).copyWith(
      primary: rosaPastel,
      onPrimary: vinho,
      primaryContainer: escuro ? rosaEscuro : rosaClarinho,
      onPrimaryContainer: escuro ? rosaClarinho : vinho,
      surface: escuro ? null : const Color(0xFFFFF7FA), // fundo rosinha quase branco (no escuro deixa o padrao)
    );

    // junta td, cada componente chama sua funçao do estilo_widgets
    return ThemeData(
      useMaterial3: true,
      colorScheme: cor,
      scaffoldBackgroundColor: cor.surface,
      appBarTheme: estiloAppBar(cor),
      bottomNavigationBarTheme: estiloNavegacao(cor),
      elevatedButtonTheme: estiloBotao(cor),
      floatingActionButtonTheme: estiloBotaoFlutuante(cor),
      cardTheme: estiloCard(cor),
      inputDecorationTheme: estiloCampo(cor),
    );
  }

  // o main usa esses dois no MaterialApp
  ThemeData temaClaro() => _montarTema(Brightness.light);
  ThemeData temaEscuro() => _montarTema(Brightness.dark);

  // chamado qnd aperta o botao de tema na tela principal
  void trocarTema() {
    _modo = _modo == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // avisa o Consumer do main p/ redesenhar (tipo um eventListener do js)
  }
}
