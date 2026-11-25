import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// faz o login na api da prof c/ email e senha
// quem chama eh o login_controle
class AcessoApi {
  final String url = 'https://guia.liliaborges.com.br/login';

  // manda email e senha e devolve os dados {token, usuario}
  // se der errado devolve um map vazio (ai o controle ve q n tem token)
  Future<Map> entrar(String email, String senha) async {
    final resposta = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'}, // avisa q ta mandando json
      body: jsonEncode({'email': email, 'senha': senha}), // jsonEncode transforma o map em texto json
    );
    final dados = jsonDecode(resposta.body); // e o jsonDecode faz o contrario
    // 200 = deu certo
    if (resposta.statusCode == 200) {
      return dados['data'];
    }
    debugPrint(dados.toString()); // mostra no console o q a api respondeu
    return {};
  }
}
