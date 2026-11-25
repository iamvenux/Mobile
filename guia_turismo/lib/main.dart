// arquivo principal, eh aq q o app comeca a rodar
// obs: as permissoes de camera e gps ficam no AndroidManifest.xml (android/app/src/main)

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/aparencia_controle.dart';
import 'package:guia_turismo/controllers/destinos_controle.dart';
import 'package:guia_turismo/controllers/imagem_controle.dart';
import 'package:guia_turismo/controllers/localizacao_controle.dart';
import 'package:guia_turismo/controllers/login_controle.dart';
import 'package:guia_turismo/firebase_options.dart';
import 'package:guia_turismo/services/armazenamento_local.dart';
import 'package:guia_turismo/services/login_google.dart';
import 'package:guia_turismo/screens/tela_entrada.dart';
import 'package:guia_turismo/screens/tela_principal.dart';
import 'package:provider/provider.dart';

// main eh async pq precisa esperar o firebase e o token antes de abrir o app
Future<void> main() async {
  // sem isso da erro qnd usa await antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // liga o app no meu projeto do firebase (guia-turismo-4bd69)
  // ta no try pq so configurei p/ android, no windows/web ele so pula e abre normal
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase não iniciado: $e');
  }

  // ve se ja tem alguem logado: ou tem o token da api salvo ou ta logado no google
  final token = await ArmazenamentoLocal().pegarToken();
  final logado = (token != null && token.isNotEmpty) || LoginGoogle.logado;

  // se ta logado ja abre direto na tela principal, se n vai p/ tela de login
  runApp(AppGuiaRosa(rotaInicial: logado ? 'principal' : 'entrada'));
}

class AppGuiaRosa extends StatelessWidget {
  // recebe do main qual tela abre primeiro
  final String rotaInicial;

  const AppGuiaRosa({super.key, required this.rotaInicial});

  @override
  Widget build(BuildContext context) {
    // o MultiProvider cria tds os controles uma vez so e deixa eles disponiveis
    // p/ qlqr tela do app (as telas pegam c/ context.read ou Consumer)
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AparenciaControle()),
        ChangeNotifierProvider(create: (_) => LoginControle()),
        ChangeNotifierProvider(create: (_) => DestinosControle()),
        ChangeNotifierProvider(create: (_) => ImagemControle()),
        ChangeNotifierProvider(create: (_) => LocalizacaoControle()),
      ],
      // o Consumer fica escutando o AparenciaControle, qnd troca o tema ele redesenha o app td
      child: Consumer<AparenciaControle>(
        builder: (context, aparencia, _) => MaterialApp(
          title: 'Guia Turismo',
          debugShowCheckedModeBanner: false, // tira aquela faixa de debug do canto
          theme: aparencia.temaClaro(),
          darkTheme: aparencia.temaEscuro(),
          themeMode: aparencia.modo, // claro ou escuro, depende do botao q apertou
          initialRoute: rotaInicial,
          // nomes das rotas e qual tela cada uma abre
          routes: {
            'entrada': (_) => const TelaEntrada(),
            'principal': (_) => const TelaPrincipal(),
          },
        ),
      ),
    );
  }
}
