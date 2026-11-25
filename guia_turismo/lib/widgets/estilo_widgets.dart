import 'package:flutter/material.dart';

// esse arquivo so existe p/ deixar cada componente c/ a cara rosa
// quem chama essas funcoes eh o _montarTema do aparencia_controller
// (o "cor" eh a paleta rosa q ele monta e passa p/ ca)

// barra do topo
AppBarTheme estiloAppBar(ColorScheme cor) {
  return AppBarTheme(
    centerTitle: true, // titulo no meio
    backgroundColor: cor.primary, // fundo rosa
    foregroundColor: cor.onPrimary, // texto e icones vinho
    elevation: 4, // sombrinha
  );
}

// barra de navegacao de baixo (as 4 abas da tela principal)
BottomNavigationBarThemeData estiloNavegacao(ColorScheme cor) {
  return BottomNavigationBarThemeData(
    backgroundColor: cor.primary,
    selectedItemColor: cor.onPrimary,
    unselectedItemColor: cor.onPrimary.withValues(alpha: 0.6), // as n selecionadas ficam meio apagadinhas
    type: BottomNavigationBarType.fixed, // tem q ser fixed se n a cor de fundo some
    showSelectedLabels: true,
    showUnselectedLabels: true, // mostra o nome de td as abas
    elevation: 8,
  );
}

// botoes normais (entrar, salvar, compartilhar, tentar novamente...)
ElevatedButtonThemeData estiloBotao(ColorScheme cor) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: cor.primary,
      foregroundColor: cor.onPrimary,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // borda arredondada
    ),
  );
}

// botao redondo flutuante (o de add destino e o do gps)
FloatingActionButtonThemeData estiloBotaoFlutuante(ColorScheme cor) {
  return FloatingActionButtonThemeData(
    backgroundColor: cor.primary,
    foregroundColor: cor.onPrimary,
  );
}

// cards da lista de destinos
CardThemeData estiloCard(ColorScheme cor) {
  return CardThemeData(
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 8), // espaco entre um card e outro
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

// campos de texto (login, cep, formulario)
InputDecorationTheme estiloCampo(ColorScheme cor) {
  return InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    // qnd clica no campo a borda fica rosa e mais grossa
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: cor.primary, width: 2),
    ),
  );
}
