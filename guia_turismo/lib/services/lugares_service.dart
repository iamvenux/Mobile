import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lugar_model.dart';

class LugaresService {
  static const String _endpoint = 'https://guia.liliaborges.com.br/lugares';

  final int pagina;
  final int limite;

  LugaresService({this.pagina = 1, this.limite = 10});

  Future<List<Lugar>> buscar() async {
    final resposta = await http.get(
      Uri.parse('$_endpoint?pagina=$pagina&limite=$limite'),
    );

    if (resposta.statusCode != 200) {
      throw Exception('Erro na requisição (${resposta.statusCode})');
    }

    final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
    final lista = corpo['data'] as List<dynamic>;
    return lista
        .map((item) => Lugar.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Cadastra um lugar. Precisa do token do usuário logado.
  /// Retorna a mensagem da API ou lança uma exceção em caso de erro.
  Future<String> cadastrar(Lugar lugar, String token) async {
    if (token.isEmpty) {
      throw Exception('Não autorizado. Faça login novamente.');
    }

    final resposta = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(lugar.toJson()),
    );

    final corpo = jsonDecode(resposta.body);
    final mensagem = corpo is Map ? corpo['message']?.toString() : null;

    if (resposta.statusCode != 201) {
      throw Exception(mensagem ?? 'Erro ao cadastrar');
    }
    return mensagem ?? 'Lugar cadastrado!';
  }
}
