import 'package:flutter/foundation.dart';
import 'package:guia_turismo/servicos/acesso_api.dart';
import 'package:guia_turismo/servicos/armazenamento_local.dart';
import 'package:guia_turismo/servicos/login_google.dart';

// controle do login: email e senha (api da prof) e login c/ google (firebase)
// a tela_entrada chama as funcoes daq
class LoginControle extends ChangeNotifier {
  bool carregando = false; // trava os botoes enqnt ta entrando
  String erro = ''; // msg vermelha q aparece embaixo da senha

  // login normal c/ email e senha, devolve true se entrou
  Future<bool> entrar(String email, String senha) async {
    // se deixou campo vazio nem chama a api
    if (email.trim().isEmpty || senha.isEmpty) {
      erro = 'Preencha o e-mail e a senha.';
      notifyListeners();
      return false;
    }

    carregando = true;
    erro = '';
    notifyListeners();
    try {
      // manda p/ api, se der certo volta o token e os dados do usuario
      final Map dados = await AcessoApi().entrar(email.trim(), senha);
      final String? token = dados['token'];
      if (token == null) {
        erro = 'E-mail ou senha inválidos!';
        return false;
      }
      // salva o token (p/ cadastrar destinos dps) e o nome/email (p/ tela de inicio)
      await ArmazenamentoLocal().salvarToken(token);
      await ArmazenamentoLocal().salvarUsuario(dados['usuario'] ?? {});
      return true;
    } catch (e) {
      // geralmnete cai aq qnd ta sem internet
      erro = 'Não foi possível conectar. Verifique a internet.';
      debugPrint('Erro no login: $e');
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // login c/ google, chama o servico login_google q faz a parte do firebase
  Future<bool> entrarComGoogle() async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      final usuario = await LoginGoogle().entrar();
      if (usuario == null) return false; // fechou a janela sem escolher conta

      // salva nome, email e foto da conta google p/ mostrar na tela de inicio
      await ArmazenamentoLocal().salvarUsuario({
        'nome': usuario.displayName ?? '',
        'email': usuario.email ?? '',
        'foto': usuario.photoURL ?? '',
      });
      return true;
    } catch (e) {
      // geralmente eh problema de sha-1 ou o google n ta ativado no firebase
      debugPrint('Erro ao autenticar com Google: $e');
      erro = 'Não foi possível entrar com o Google.';
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // chamado pelo botao de sair da tela principal
  Future<void> sair() async {
    // se entrou pelo google, sai do google tbm (se n ele fica logado)
    if (LoginGoogle.logado) {
      try {
        await LoginGoogle().sair();
      } catch (e) {
        debugPrint('Erro ao sair do Google: $e');
      }
    }
    // apaga token, nome, email e foto do celular
    await ArmazenamentoLocal().sair();
  }
}
