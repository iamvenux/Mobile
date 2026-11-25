import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/aparencia_controller.dart';
import 'package:guia_turismo/controllers/login_controller.dart';
import 'package:guia_turismo/services/armazenamento_local_service.dart';
import 'package:guia_turismo/screens/destinos_screen.dart';
import 'package:guia_turismo/screens/favoritos_screen.dart';
import 'package:guia_turismo/screens/mapa_screen.dart';
import 'package:provider/provider.dart';

// tela principal, abre dps do login
// tem a appbar em cima e a barra de navegacao c/ 4 abas embaixo
class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _abaAtual = 0; // qual aba ta aberta (0 = inicio)

  // conteudo de cada aba, na msm ordem dos botoes la de baixo
  final List<Widget> _abas = const [
    _BoasVindas(),
    DestinosScreen(),
    FavoritosScreen(),
    MapaScreen(),
  ];

  // titulo q aparece na appbar p/ cada aba
  final List<String> _titulos = const [
    'Guia Turismo',
    'Destinos para Visitar',
    'Meus Favoritos',
    'Mapa',
  ];

  // botao sair: chama o login_controller (q apaga o token e sai do google)
  // e volta p/ tela de login
  Future<void> _sair() async {
    await context.read<LoginController>().sair();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'entrada');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_abaAtual]), // pega o titulo pelo numero da aba
        actions: [
          // botao de trocar tema claro/escuro, chama o trocarTema do aparencia_controller
          Consumer<AparenciaController>(
            builder: (context, aparencia, _) => IconButton(
              tooltip: 'Trocar tema',
              onPressed: aparencia.trocarTema,
              icon: Icon(aparencia.icone),
            ),
          ),
          IconButton(
            // botao de sair (o tooltip eh o textinho q aparece qnd segura)
            tooltip: 'Sair',
            onPressed: _sair,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      // IndexedStack mostra so a aba atual mas deixa as outras carregadas por tras
      // assim qnd volta p/ uma aba ela n recarrega do zero
      body: IndexedStack(index: _abaAtual, children: _abas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaAtual,
        onTap: (indice) => setState(() => _abaAtual = indice), // clicou numa aba, muda o numero e o setState redesenha
        items: const [
          // icone/nome de cada aba (activeIcon = icone qnd ta selecionada)
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place_outlined),
            activeIcon: Icon(Icons.place),
            label: 'Destinos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
        ],
      ),
    );
  }
}

// 1a aba (inicio): mostra a foto, nome e email de quem entrou
// o _ na frente do nome = so da p/ usar dentro desse arquivo
class _BoasVindas extends StatelessWidget {
  const _BoasVindas();

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    final armazenamento = ArmazenamentoLocalService(); // onde ficou salvo o nome/email/foto no login

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        // FutureBuilder espera os dados carregarem e dps monta a tela
        // o Future.wait busca os 3 ao msm tempo
        child: FutureBuilder<List<String>>(
          future: Future.wait([
            armazenamento.pegarNome(),
            armazenamento.pegarEmail(),
            armazenamento.pegarFoto(),
          ]),
          builder: (context, snapshot) {
            // snapshot.data eh a lista q voltou, na msm ordem do Future.wait
            // enqnt n carregou fica vazio ('')
            final nome = snapshot.data?[0] ?? '';
            final email = snapshot.data?[1] ?? '';
            final foto = snapshot.data?[2] ?? '';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // se entrou c/ google tem foto, entao mostra ela redondinha
                // se entrou c/ email (n tem foto) mostra o icone
                foto.isNotEmpty
                    ? CircleAvatar(
                        radius: 48,
                        backgroundColor: cor.primaryContainer,
                        backgroundImage: NetworkImage(foto),
                      )
                    : Icon(Icons.travel_explore, size: 96, color: cor.primary),
                const SizedBox(height: 16),
                Text(
                  nome.isEmpty ? 'Bem-vindo(a)!' : 'Olá, $nome!', // se n tiver nome so fala bem vindo
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                // so mostra o email se tiver (o ... coloca os 2 widgets direto na lista)
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(email, style: TextStyle(color: cor.outline)),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Bem-vindo ao Guia de Turismo!\n'
                  'Use o menu abaixo para navegar.',
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
