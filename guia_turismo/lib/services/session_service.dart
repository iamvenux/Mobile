import 'package:shared_preferences/shared_preferences.dart';

/// Guarda token e dados básicos do usuário no armazenamento local.
class SessionService {
  static const _chaveToken = 'token';
  static const _chaveNome = 'nome';
  static const _chaveEmail = 'email';

  Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveToken, token);
  }

  Future<String?> pegarToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveToken);
  }

  Future<void> salvarUsuario(Map usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveNome, usuario['nome']?.toString() ?? '');
    await prefs.setString(_chaveEmail, usuario['email']?.toString() ?? '');
  }

  Future<String> pegarNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveNome) ?? '';
  }

  Future<String> pegarEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveEmail) ?? '';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveToken);
    await prefs.remove(_chaveNome);
    await prefs.remove(_chaveEmail);
  }
}
