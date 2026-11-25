import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:guia_turismo/models/destino_modelo.dart';

// conversa c/ a api da prof p/ listar e cadastrar os lugares
// quem chama eh o destinos_controle
class DestinosApi {
  // obs: na api o endpoint chama "lugares", no app eu chamei de destinos
  final String endpoint = 'https://guia.liliaborges.com.br/lugares';
  int pagina = 1;
  int limite = 50; // a api manda em paginas, pedi 50 p/ aparecer bastante no mapa

  // GET: busca a lista de destinos
  Future<List<DestinoModelo>> buscarDestinos() async {
    final resposta = await http.get(
      Uri.parse('$endpoint?pagina=$pagina&limite=$limite'),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro na requisição: ${resposta.statusCode}');
    }
    // a lista vem dentro de "data"
    final Map<String, dynamic> corpo = jsonDecode(resposta.body);
    final List<dynamic> lista = corpo['data'];
    // transforma cada item do json num DestinoModelo
    return lista.map((item) => DestinoModelo.fromJson(item)).toList();
  }

  // POST: cadastra um destino novo, precisa do token do login
  // devolve 2 coisas: a msg da api e o id do lugar novo (se a api mandar)
  // o id eu preciso p/ ligar a foto no lugar certo
  Future<(String, int?)> cadastrarDestino(
    DestinoModelo destino,
    String token,
  ) async {
    // sem token a api recusa, entao ja avisa antes (acontece qnd entra pelo google)
    if (token.isEmpty) {
      throw Exception('Não autorizado: faça login com e-mail e senha.');
    }
    final resposta = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // eh aq q vai o token
      },
      body: jsonEncode(destino.toJson()),
    );
    final Map<String, dynamic> mensagem = jsonDecode(resposta.body);
    // 201 = criado
    if (resposta.statusCode != 201) {
      throw Exception(mensagem['message'] ?? 'Erro ao cadastrar');
    }
    // tenta pegar o id do lugar novo q vem dentro do "data" (se n vier fica null)
    final dados = mensagem['data'];
    final int? idNovo = dados is Map ? int.tryParse('${dados['id']}') : null;
    return (mensagem['message']?.toString() ?? 'Destino cadastrado!', idNovo);
  }
}
