import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/auth_controller.dart';
import '../controller/mapa_controller.dart';
import '../controller/tema_controller.dart';
import '../rotas.dart';
import '../services/session_service.dart';
import 'foto_screen.dart';
import 'lugares_screen.dart';
import 'mapa_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _aba = 0;
  bool _pediuGps = false;

  static const int _abaMapa = 1;

  static const List<String> _titulos = [
    'Guia Turismo',
    'Mapa dos lugares',
    'Lugares para visitar',
    'Foto',
  ];

  // IndexedStack mantém o estado de cada aba ao alternar entre elas
  static const List<Widget> _abas = [
    _Boasvindas(),
    MapaScreen(),
    LugaresScreen(),
    FotoScreen(),
  ];

  void _trocarAba(int i) {
    setState(() => _aba = i);

    // Só pede a permissão de localização quando o usuário abre o mapa
    if (i == _abaMapa && !_pediuGps) {
      _pediuGps = true;
      context.read<MapaController>().buscarLocal();
    }
  }

  Future<void> _sair() async {
    final auth = context.read<AuthController>();
    final navegador = Navigator.of(context);
    await auth.sair();
    navegador.pushReplacementNamed(Rotas.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_aba]),
        actions: [
          Consumer<TemaController>(
            builder: (context, tema, _) => IconButton(
              tooltip: 'Alternar tema',
              onPressed: tema.alternar,
              icon: Icon(tema.icone),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: _sair,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _aba, children: _abas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: _trocarAba,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.place), label: 'Locais'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Foto'),
        ],
      ),
    );
  }
}

/// Aba inicial com a saudação ao usuário logado.
class _Boasvindas extends StatelessWidget {
  const _Boasvindas();

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Center(
      child: FutureBuilder<String>(
        future: SessionService().pegarNome(),
        builder: (context, snapshot) {
          final nome = snapshot.data ?? '';
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.travel_explore, size: 96, color: cores.primary),
              const SizedBox(height: 16),
              Text(
                nome.isEmpty ? 'Bem-vindo(a)!' : 'Olá, $nome!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Descubra e cadastre lugares para visitar.'),
              const SizedBox(height: 4),
              const Text('Veja todos eles na aba Mapa.'),
            ],
          );
        },
      ),
    );
  }
}
