import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/login_controle.dart';
import 'package:provider/provider.dart';

// tela de login, eh a 1a tela q abre se ninguem ta logado
// da p/ entrar c/ email e senha (api) ou c/ o google (firebase)
// login de teste da api: lilia@teste.com | senha123
class TelaEntrada extends StatefulWidget {
  const TelaEntrada({super.key});

  @override
  State<TelaEntrada> createState() => _TelaEntradaState();
}

// é stateful pq tem coisa q muda na tela (mostrar/esconder senha)
class _TelaEntradaState extends State<TelaEntrada> {
  // controllers pegam o q o usuario digita nos campos
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _senhaVisivel = false; // comeca c/ a senha escondida

  @override
  // qnd a tela fecha limpa os controllers p/ n ficar ocupando memoria
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  // botao entrar: chama o login_controle, se deu certo vai p/ tela principal
  Future<void> _entrar(LoginControle login) async {
    final entrou = await login.entrar(_email.text, _senha.text);
    // mounted = a tela ainda ta aberta (pq teve um await antes)
    // pushReplacement troca a tela, ai o voltar do celular n volta p/ o login
    if (entrou && mounted) {
      Navigator.pushReplacementNamed(context, 'principal');
    }
  }

  // msm coisa mas c/ o google
  Future<void> _entrarComGoogle(LoginControle login) async {
    final entrou = await login.entrarComGoogle();
    if (entrou && mounted) {
      Navigator.pushReplacementNamed(context, 'principal');
    }
  }

  @override
  Widget build(BuildContext context) {
    // pega as cores do tema rosa
    final cor = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      // o Consumer escuta o login_controle, qnd ele avisa (notifyListeners) a tela redesenha
      // ex: aparece a bolinha de carregando ou a msg de erro
      body: Consumer<LoginControle>(
        builder: (context, login, _) => Center(
          child: SingleChildScrollView( // deixa rolar qnd o teclado abre, se n da overflow
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // estica td na largura
              children: [
                // icone e nome do app no topo
                Icon(Icons.travel_explore, size: 80, color: cor.primary),
                const SizedBox(height: 8),
                Text(
                  'Guia Turismo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),

                // campo do email
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),

                // campo da senha
                TextField(
                  controller: _senha,
                  obscureText: !_senhaVisivel, // esconde a senha c/ bolinhas
                  onSubmitted: (_) => _entrar(login), // apertar enter no teclado ja tenta entrar
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    // olhinho p/ mostrar/esconder a senha
                    suffixIcon: IconButton(
                      icon: Icon(
                        _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _senhaVisivel = !_senhaVisivel),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // se o controle tiver msg de erro mostra ela em vermelho
                if (login.erro.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      login.erro,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cor.error),
                    ),
                  ),

                SizedBox(
                  height: 50,
                  // botao entrar
                  child: ElevatedButton(
                    onPressed: login.carregando ? null : () => _entrar(login), // null = botao desativado, p/ n clicar 2x enqnt carrega
                    // carregando mostra a bolinha girando, se n mostra o texto
                    child: login.carregando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // divisor do "ou" entre os dois botoes
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('ou', style: TextStyle(color: cor.outline)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 50,
                  // botao do google (passo 6 do pdf da prof)
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cor.onSurface,
                      side: BorderSide(color: cor.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: login.carregando
                        ? null
                        : () => _entrarComGoogle(login),
                    icon: const Icon(Icons.login),
                    label: const Text(
                      'Entrar com o Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
