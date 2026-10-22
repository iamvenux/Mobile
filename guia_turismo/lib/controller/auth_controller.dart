import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/session_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final SessionService _sessao = SessionService();

  bool carregando = false;
  String erro = '';

  /// Tenta fazer login. Retorna `true` quando deu certo.
  Future<bool> entrar(String email, String senha) async {
    if (email.trim().isEmpty || senha.isEmpty) {
      erro = 'Preencha o e-mail e a senha.';
      notifyListeners();
      return false;
    }

    carregando = true;
    erro = '';
    notifyListeners();

    try {
      final dados = await _auth.autenticar(email.trim(), senha);
      final token = dados['token'] as String?;

      if (token == null || token.isEmpty) {
        erro = 'E-mail ou senha inválidos!';
        return false;
      }

      await _sessao.salvarToken(token);
      if (dados['usuario'] is Map) {
        await _sessao.salvarUsuario(dados['usuario'] as Map);
      }
      return true;
    } catch (e) {
      debugPrint('Erro no login: $e');
      erro = 'Não foi possível entrar. Verifique sua conexão.';
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> sair() => _sessao.logout();
}
