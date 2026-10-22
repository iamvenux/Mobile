import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller/auth_controller.dart';
import 'controller/foto_controller.dart';
import 'controller/lugares_controller.dart';
import 'controller/tema_controller.dart';
import 'rotas.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Se já existe um token salvo, pula a tela de login.
  final token = await SessionService().pegarToken();
  final logado = token != null && token.isNotEmpty;

  runApp(GuiaTurismoApp(rotaInicial: logado ? Rotas.home : Rotas.login));
}

class GuiaTurismoApp extends StatelessWidget {
  final String rotaInicial;

  const GuiaTurismoApp({super.key, required this.rotaInicial});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TemaController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => LugaresController()),
        ChangeNotifierProvider(create: (_) => FotoController()),
      ],
      child: Consumer<TemaController>(
        builder: (context, tema, _) => MaterialApp(
          title: 'Guia Turismo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.escuro,
          themeMode: tema.modo,
          initialRoute: rotaInicial,
          routes: {
            Rotas.login: (_) => const LoginScreen(),
            Rotas.home: (_) => const HomeScreen(),
          },
        ),
      ),
    );
  }
}
