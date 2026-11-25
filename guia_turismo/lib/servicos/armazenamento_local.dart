import 'package:shared_preferences/shared_preferences.dart';

// salva coisas no proprio celular (shared_preferences)
// assim msm fechando o app o usuario continua logado
class ArmazenamentoLocal {
  // token q a api devolve no login, precisa dele p/ cadastrar destinos
  Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // o main usa p/ saber se ja ta logado
  Future<String?> pegarToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // salva nome, email e foto (a foto so tem no login c/ google)
  // o ?.toString() ?? '' eh p/ n dar erro se algum vier nulo
  Future<void> salvarUsuario(Map usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome', usuario['nome']?.toString() ?? '');
    await prefs.setString('email', usuario['email']?.toString() ?? '');
    await prefs.setString('foto', usuario['foto']?.toString() ?? '');
  }

  // esses 3 a tela de inicio usa p/ mostrar quem ta logado
  Future<String> pegarNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nome') ?? '';
  }

  Future<String> pegarEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  Future<String> pegarFoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('foto') ?? '';
  }

  // apaga td qnd o usuario sai
  Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('nome');
    await prefs.remove('email');
    await prefs.remove('foto');
  }
}
