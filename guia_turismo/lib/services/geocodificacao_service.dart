import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/local_encontrado.dart';

/// Converte endereço/CEP em coordenadas (e o contrário).
///
/// Usa a API Nominatim do OpenStreetMap:
/// https://wiki.openstreetmap.org/wiki/Nominatim
///
/// Para CEP, primeiro consulta o ViaCEP (https://viacep.com.br) para
/// descobrir rua/cidade, porque o Nominatim conhece poucos CEPs do Brasil.
///
/// Regras de uso do Nominatim: no máximo 1 requisição por segundo e
/// enviar um User-Agent que identifique o app. Por isso a busca só é feita
/// quando o usuário aperta "buscar" (sem autocompletar a cada letra).
class GeocodificacaoService {
  static const String _nominatim = 'https://nominatim.openstreetmap.org';
  static const String _viaCep = 'https://viacep.com.br/ws';

  // No navegador (web) não é permitido trocar o User-Agent.
  Map<String, String> get _cabecalhos => kIsWeb
      ? const {}
      : const {'User-Agent': 'GuiaTurismoApp/1.0 (trabalho academico Flutter)'};

  /// Busca por endereço livre ("Av. Paulista, 1000") ou por CEP ("18130-000").
  Future<List<LocalEncontrado>> buscar(String texto) async {
    final termo = texto.trim();
    if (termo.isEmpty) return [];

    if (_pareceCep(termo)) {
      return _buscarPorCep(termo.replaceAll(RegExp(r'\D'), ''));
    }
    return _pesquisar({'q': termo});
  }

  /// Descobre o endereço de uma coordenada (quando o usuário toca no mapa).
  Future<String?> enderecoDe(LatLng ponto) async {
    final uri = Uri.parse('$_nominatim/reverse').replace(
      queryParameters: {
        'lat': ponto.latitude.toString(),
        'lon': ponto.longitude.toString(),
        'format': 'jsonv2',
        'accept-language': 'pt-BR',
      },
    );

    final resposta = await http.get(uri, headers: _cabecalhos);
    if (resposta.statusCode != 200) return null;

    final corpo = jsonDecode(resposta.body);
    return corpo is Map ? corpo['display_name']?.toString() : null;
  }

  // ---------------------------------------------------------------------------

  bool _pareceCep(String texto) =>
      RegExp(r'^\d{5}-?\d{3}$').hasMatch(texto.replaceAll(' ', ''));

  Future<List<LocalEncontrado>> _buscarPorCep(String cep) async {
    final resposta = await http.get(Uri.parse('$_viaCep/$cep/json/'));
    if (resposta.statusCode != 200) {
      throw Exception('CEP inválido.');
    }

    final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
    if (dados['erro'] != null) {
      throw Exception('CEP não encontrado.');
    }

    final rua = dados['logradouro']?.toString() ?? '';
    final cidade = dados['localidade']?.toString() ?? '';
    final uf = dados['uf']?.toString() ?? '';

    // 1ª tentativa: busca estruturada com rua + cidade
    var resultados = await _pesquisar({
      if (rua.isNotEmpty) 'street': rua,
      'city': cidade,
      'state': uf,
      'country': 'Brasil',
    });

    // 2ª tentativa: o próprio CEP no Nominatim
    if (resultados.isEmpty) {
      resultados = await _pesquisar({'postalcode': cep, 'country': 'Brasil'});
    }

    // 3ª tentativa: só a cidade (pelo menos centraliza no lugar certo)
    if (resultados.isEmpty && cidade.isNotEmpty) {
      resultados = await _pesquisar({'q': '$cidade, $uf'});
    }
    return resultados;
  }

  Future<List<LocalEncontrado>> _pesquisar(Map<String, String> filtros) async {
    final uri = Uri.parse('$_nominatim/search').replace(
      queryParameters: {
        ...filtros,
        'format': 'jsonv2',
        'limit': '5',
        'countrycodes': 'br',
        'accept-language': 'pt-BR',
      },
    );

    final resposta = await http.get(uri, headers: _cabecalhos);
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar endereço (${resposta.statusCode}).');
    }

    final lista = jsonDecode(resposta.body) as List<dynamic>;
    return lista
        .map((item) =>
            LocalEncontrado.fromNominatim(item as Map<String, dynamic>))
        .toList();
  }
}
