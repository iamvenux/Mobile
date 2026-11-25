import 'dart:convert';
import 'package:http/http.dart' as http;

// transforma um cep em latitude e longitude
// funciona em 2 partes:
// 1- o viacep diz qual eh a rua, cidade e estado do cep
// 2- o nominatim (do openstreetmap) pega esse endereco e devolve as coordenadas
// (precisa do viacep pq o nominatim n tem td os ceps cadastrados)
class BuscaCep {
  // o nominatim exige q o app se identifique, se n ele bloqueia
  static const _cabecalho = {'User-Agent': 'GuiaTurismoRosa/1.0'};

  // devolve um map c/ lat, lon e display_name (endereco completo) ou null se n achar
  Future<Map<String, dynamic>?> buscar(String cep) async {
    // tira traço, espaço e td q n for numero
    final cepLimpo = cep.replaceAll(RegExp(r'\D'), '');
    if (cepLimpo.length != 8) return null; // cep tem q ter 8 numeros

    // parte 1: viacep
    final viaCep = await http.get(
      Uri.https('viacep.com.br', '/ws/$cepLimpo/json/'),
    );
    if (viaCep.statusCode != 200) throw Exception('Erro ao buscar CEP');
    final endereco = jsonDecode(viaCep.body);
    if (endereco['erro'] != null) return null; // qnd o cep n existe o viacep manda {erro: true}

    // parte 2: monta a busca do nominatim c/ o q o viacep devolveu
    final parametros = <String, String>{
      'city': endereco['localidade'],
      'state': endereco['uf'],
      'country': 'Brasil',
      'format': 'jsonv2',
      'limit': '1', // so quero o 1° resultado
    };
    // so coloca a rua se o viacep mandou uma (cep de cidade pequena as vezes vem sem)
    final rua = endereco['logradouro']?.toString() ?? '';
    if (rua.isNotEmpty) parametros['street'] = rua;

    var resultados = await _nominatim(parametros);

    // se n achou c/ a rua, tenta so c/ a cidade (pelo menos cai na cidade certa)
    if (resultados.isEmpty && parametros.containsKey('street')) {
      parametros.remove('street');
      resultados = await _nominatim(parametros);
    }
    return resultados.isEmpty ? null : resultados.first;
  }

  // faz a requisicao p/ o nominatim, separei numa funçao pq chama ate 2x
  Future<List<dynamic>> _nominatim(Map<String, String> parametros) async {
    final resposta = await http.get(
      Uri.https('nominatim.openstreetmap.org', '/search', parametros),
      headers: _cabecalho,
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar coordenadas');
    }
    return jsonDecode(resposta.body);
  }
}
