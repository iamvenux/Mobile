import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _url = 'https://guia.liliaborges.com.br/login';

  /// Faz o login na API. Retorna o campo `data` da resposta
  /// ou um mapa vazio quando as credenciais são recusadas.
  Future<Map<String, dynamic>> autenticar(String email, String senha) async {
    final resposta = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    final corpo = jsonDecode(resposta.body);
    if (resposta.statusCode == 200 && corpo is Map && corpo['data'] is Map) {
      return Map<String, dynamic>.from(corpo['data'] as Map);
    }

    debugPrint('Login recusado: $corpo');
    return {};
  }
}
